use std::env;
use std::path::PathBuf;

fn main() {
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let manifest_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    let profile = env::var("PROFILE").unwrap_or("release".into());
    let target = env::var("TARGET").unwrap_or_default();

    // Cargo puts output in target/<profile>/ OR target/<triple>/<profile>/
    // when --target is used. Output loader to both locations to be safe.
    let base_dir = manifest_dir.join("target").join(&profile);
    let triple_dir = if !target.is_empty() {
        Some(manifest_dir.join("target").join(&target).join(&profile))
    } else {
        None
    };

    // Compile the loader .so
    // This tiny C library:
    // 1. Has ZERO Python symbol dependencies (loads cleanly via Ring's loadlib)
    // 2. dlopen's libpython with RTLD_GLOBAL (makes Python symbols available)
    // 3. dlopen's libring_python_impl.so (the real Rust/PyO3 library)
    // 4. Forwards ringlib_init to the real library
    let loader_c = out_dir.join("loader.c");
    std::fs::write(&loader_c, LOADER_SOURCE).unwrap();

    // Platform-specific loader compilation
    let is_windows = target.contains("windows");
    let is_macos = target.contains("apple") || target.contains("darwin");

    std::fs::create_dir_all(&base_dir).ok();
    if let Some(ref td) = triple_dir {
        std::fs::create_dir_all(td).ok();
    }

    if is_windows {
        // On Windows, the loader is compiled by the C compiler from the host
        // For cross-compilation from Linux CI, we skip loader compilation
        // and rely on the Rust cdylib being named ring_python_impl.dll
        // The loader .dll is built separately or by MSVC on Windows CI
        let loader_dll = base_dir.join("ring_python.dll");
        let status = std::process::Command::new("cl.exe")
            .args([
                "/LD", "/O2", &format!("/Fe:{}", loader_dll.to_str().unwrap()),
                loader_c.to_str().unwrap(),
            ])
            .status();
        if status.is_err() || !status.unwrap().success() {
            let status = std::process::Command::new("cc")
                .args([
                    "-shared", "-O2",
                    "-o", loader_dll.to_str().unwrap(),
                    loader_c.to_str().unwrap(),
                ])
                .status()
                .expect("Failed to compile loader");
            assert!(status.success(), "Failed to compile loader .dll");
        }
        if let Some(ref td) = triple_dir {
            std::fs::copy(&loader_dll, td.join("ring_python.dll")).ok();
        }
    } else if is_macos {
        let loader_dylib = base_dir.join("libring_python.dylib");
        let status = std::process::Command::new("cc")
            .args([
                "-shared", "-fPIC", "-O2",
                "-install_name", "@rpath/libring_python.dylib",
                "-o", loader_dylib.to_str().unwrap(),
                loader_c.to_str().unwrap(),
                "-ldl",
            ])
            .status()
            .expect("Failed to compile loader");
        assert!(status.success(), "Failed to compile loader .dylib");
        if let Some(ref td) = triple_dir {
            std::fs::copy(&loader_dylib, td.join("libring_python.dylib")).ok();
        }
    } else {
        // Linux, FreeBSD, etc.
        let loader_so = base_dir.join("libring_python.so");
        std::fs::create_dir_all(&base_dir).ok();
        let status = std::process::Command::new("cc")
            .args([
                "-shared", "-fPIC", "-O2",
                "-Wl,-soname,libring_python.so",
                "-o", loader_so.to_str().unwrap(),
                loader_c.to_str().unwrap(),
                "-ldl",
            ])
            .status()
            .expect("Failed to compile loader");
        assert!(status.success(), "Failed to compile loader .so");
        if let Some(ref td) = triple_dir {
            std::fs::create_dir_all(td).ok();
            std::fs::copy(&loader_so, td.join("libring_python.so")).ok();
        }
    }

    println!("cargo:rerun-if-changed=build.rs");

    // On macOS, allow undefined symbols (resolved at runtime by the loader)
    if is_macos {
        println!("cargo:rustc-cdylib-link-arg=-undefined");
        println!("cargo:rustc-cdylib-link-arg=dynamic_lookup");
    }
}

const LOADER_SOURCE: &str = r#"
/*
 * ring_python loader — loads libpython globally, then loads the real impl.
 * This file has ZERO Python dependencies so dlopen always succeeds.
 */
#ifdef _WIN32

#include <windows.h>
#include <stdio.h>

typedef void (*ringlib_init_fn)(void*);
static HMODULE real_lib = NULL;

static HMODULE try_load(const char* name) {
    return LoadLibraryA(name);
}

static void load_python(void) {
    /* Try python3.dll (stable ABI on Windows) */
    if (try_load("python3.dll")) return;

    /* Try version-specific */
    char buf[64];
    for (int minor = 30; minor >= 7; minor--) {
        snprintf(buf, sizeof(buf), "python3%d.dll", minor);
        if (try_load(buf)) return;
    }
}

void ringlib_init(void* pRingState) {
    load_python();

    /* Find impl next to this loader */
    char path[MAX_PATH];
    HMODULE self;
    GetModuleHandleExA(
        GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
        (LPCSTR)ringlib_init, &self);
    GetModuleFileNameA(self, path, MAX_PATH);

    /* Replace filename with impl name */
    char* slash = strrchr(path, '\\');
    if (!slash) slash = strrchr(path, '/');
    if (slash) slash[1] = '\0'; else path[0] = '\0';
    strcat(path, "ring_python_impl.dll");

    real_lib = LoadLibraryA(path);
    if (!real_lib) {
        fprintf(stderr, "ring_python: cannot load %s (error %lu)\n", path, GetLastError());
        return;
    }

    ringlib_init_fn real_init = (ringlib_init_fn)GetProcAddress(real_lib, "ringlib_init");
    if (!real_init) {
        fprintf(stderr, "ring_python: ringlib_init not found in impl\n");
        return;
    }
    real_init(pRingState);
}

#else /* Unix (Linux, macOS, *BSD) */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef void (*ringlib_init_fn)(void*);
static void* real_lib = NULL;

#ifdef __APPLE__
  #define RTLD_GLOBAL_FLAG 0x8
  #define LIBEXT "dylib"
  #define IMPLNAME "libring_python_impl.dylib"
#else
  #define RTLD_GLOBAL_FLAG 0x100
  #define LIBEXT "so"
  #define IMPLNAME "libring_python_impl.so"
#endif

static int try_dlopen(const char* name) {
    return dlopen(name, RTLD_LAZY | RTLD_GLOBAL_FLAG) != NULL;
}

static void load_python_global(void) {
    /* Try generic name first */
    char buf[64];
    snprintf(buf, sizeof(buf), "libpython3.%s", LIBEXT);
    if (try_dlopen(buf)) return;

    /* Try version-specific (newest first) */
    for (int minor = 30; minor >= 7; minor--) {
        snprintf(buf, sizeof(buf), "libpython3.%d.%s", minor, LIBEXT);
        if (try_dlopen(buf)) return;
        #ifndef __APPLE__
        snprintf(buf, sizeof(buf), "libpython3.%d.so.1.0", minor);
        if (try_dlopen(buf)) return;
        #endif
    }
}

static void build_impl_path(const char* base, char* out, size_t sz) {
    const char* slash = strrchr(base, '/');
    if (slash) {
        int dirlen = (int)(slash - base);
        snprintf(out, sz, "%.*s/" IMPLNAME, dirlen, base);
    } else {
        snprintf(out, sz, IMPLNAME);
    }
}

void ringlib_init(void* pRingState) {
    /* Step 1: Load libpython into global symbol table */
    load_python_global();

    /* Step 2: Find and load the real impl library (next to this loader) */
    Dl_info info;
    char path[4096];
    real_lib = NULL;

    if (dladdr((void*)ringlib_init, &info) && info.dli_fname) {
        /* Try next to the path the linker used (may be a symlink) */
        build_impl_path(info.dli_fname, path, sizeof(path));
        real_lib = dlopen(path, RTLD_LAZY | RTLD_GLOBAL_FLAG);

        /* If not found, resolve symlinks and try next to the real file */
        if (!real_lib) {
            char resolved[4096];
            if (realpath(info.dli_fname, resolved)) {
                build_impl_path(resolved, path, sizeof(path));
                real_lib = dlopen(path, RTLD_LAZY | RTLD_GLOBAL_FLAG);
            }
        }
    }

    /* Last resort: try bare name (relies on LD_LIBRARY_PATH / system paths) */
    if (!real_lib) {
        snprintf(path, sizeof(path), IMPLNAME);
        real_lib = dlopen(path, RTLD_LAZY | RTLD_GLOBAL_FLAG);
    }

    if (!real_lib) {
        fprintf(stderr, "ring_python: cannot load " IMPLNAME ": %s\n", dlerror());
        return;
    }

    /* Step 3: Forward to real ringlib_init */
    ringlib_init_fn real_init = (ringlib_init_fn)dlsym(real_lib, "ringlib_init");
    if (!real_init) {
        fprintf(stderr, "ring_python: ringlib_init not found in %s\n", path);
        return;
    }
    real_init(pRingState);
}

#endif
"#;