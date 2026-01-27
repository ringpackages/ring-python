use libc::c_void;
use pyo3::prelude::*;
use pyo3::types::{PyBool, PyDict, PyFloat, PyInt, PyList, PyString, PyTuple};
use ring_lang_rs::*;
use std::ffi::CString;
use std::sync::OnceLock;

static PY_INITIALIZED: OnceLock<bool> = OnceLock::new();

const PYOBJECT_TYPE: &[u8] = b"PyObject\0";

type PyObj = Py<PyAny>;

/// Unix-like (Linux, FreeBSD, NetBSD, OpenBSD, etc.): Use dlopen with RTLD_GLOBAL
#[cfg(all(unix, not(target_os = "macos")))]
fn preload_libpython_global() {
    use std::ffi::CString;

    const RTLD_LAZY: libc::c_int = 0x1;
    const RTLD_GLOBAL: libc::c_int = 0x100;

    if try_dlopen(c"libpython3.so".as_ptr(), RTLD_LAZY | RTLD_GLOBAL) {
        return;
    }

    for minor in (7..=30).rev() {
        let name = CString::new(format!("libpython3.{minor}.so")).unwrap();
        if try_dlopen(name.as_ptr(), RTLD_LAZY | RTLD_GLOBAL) {
            return;
        }
    }
}

/// macOS: Use dlopen with macOS-specific RTLD_GLOBAL (0x8 vs 0x100 on Linux)
#[cfg(target_os = "macos")]
fn preload_libpython_global() {
    use std::ffi::CString;

    const RTLD_LAZY: libc::c_int = 0x1;
    const RTLD_GLOBAL: libc::c_int = 0x8;

    if try_dlopen(c"libpython3.dylib".as_ptr(), RTLD_LAZY | RTLD_GLOBAL) {
        return;
    }

    for minor in (7..=30).rev() {
        let name = CString::new(format!("libpython3.{minor}.dylib")).unwrap();
        if try_dlopen(name.as_ptr(), RTLD_LAZY | RTLD_GLOBAL) {
            return;
        }
    }
}

#[cfg(unix)]
fn try_dlopen(name: *const core::ffi::c_char, flags: libc::c_int) -> bool {
    !unsafe { libc::dlopen(name, flags) }.is_null()
}

/// Windows: Use LoadLibraryW to load Python DLL
#[cfg(target_os = "windows")]
fn preload_libpython_global() {
    #[link(name = "kernel32")]
    unsafe extern "system" {
        fn LoadLibraryW(lpLibFileName: *const u16) -> *mut libc::c_void;
    }

    fn try_load(name: &str) -> bool {
        let wide: Vec<u16> = name.encode_utf16().chain(std::iter::once(0)).collect();
        !unsafe { LoadLibraryW(wide.as_ptr()) }.is_null()
    }

    if try_load("python3.dll") {
        return;
    }

    for minor in (7..=30).rev() {
        if try_load(&format!("python3{minor}.dll")) {
            return;
        }
    }
}

extern "C" fn free_pyobject(_state: *mut c_void, ptr: *mut c_void) {
    if !ptr.is_null() {
        Python::attach(|_py| unsafe {
            let _ = Box::from_raw(ptr as *mut PyObj);
        });
    }
}

fn ensure_initialized() -> bool {
    *PY_INITIALIZED.get_or_init(|| {
        preload_libpython_global();
        Python::initialize();
        true
    })
}

fn ring_to_pyobject<'py>(
    py: Python<'py>,
    list: RingList,
    index: u32,
) -> PyResult<Bound<'py, PyAny>> {
    if ring_list_isstring(list, index) {
        let s = ring_list_getstring_str(list, index);
        Ok(PyString::new(py, &s).into_any())
    } else if ring_list_isnumber(list, index) {
        let n = ring_list_getdouble(list, index);
        if n.fract() == 0.0 && n >= i64::MIN as f64 && n <= i64::MAX as f64 {
            Ok(PyInt::new(py, n as i64).into_any())
        } else {
            Ok(PyFloat::new(py, n).into_any())
        }
    } else if ring_list_islist(list, index) {
        let sublist = ring_list_getlist(list, index);
        ring_list_to_pyobject(py, sublist)
    } else {
        Ok(py.None().into_bound(py))
    }
}

fn ring_list_to_pyobject<'py>(py: Python<'py>, list: RingList) -> PyResult<Bound<'py, PyAny>> {
    let size = ring_list_getsize(list) as u32;

    let mut is_dict = true;
    if size > 0 {
        for i in 1..=size {
            if ring_list_islist(list, i) {
                let item = ring_list_getlist(list, i);
                if ring_list_getsize(item) != 2 || !ring_list_isstring(item, 1) {
                    is_dict = false;
                    break;
                }
            } else {
                is_dict = false;
                break;
            }
        }
    } else {
        is_dict = false;
    }

    if is_dict {
        let dict = PyDict::new(py);
        for i in 1..=size {
            let item = ring_list_getlist(list, i);
            let key = ring_list_getstring_str(item, 1);
            let value = ring_to_pyobject(py, item, 2)?;
            dict.set_item(key, value)?;
        }
        Ok(dict.into_any())
    } else {
        let pylist = PyList::empty(py);
        for i in 1..=size {
            let item = ring_to_pyobject(py, list, i)?;
            pylist.append(item)?;
        }
        Ok(pylist.into_any())
    }
}

fn pyobject_to_ring(p: *mut c_void, py: Python, obj: &Bound<PyAny>) -> bool {
    if obj.is_none() {
        return true;
    }

    if let Ok(b) = obj.cast::<PyBool>() {
        ring_ret_number!(p, if b.is_true() { 1.0 } else { 0.0 });
        return true;
    }

    if let Ok(i) = obj.extract::<i64>() {
        ring_ret_number!(p, i as f64);
        return true;
    }

    if let Ok(f) = obj.extract::<f64>() {
        ring_ret_number!(p, f);
        return true;
    }

    if let Ok(s) = obj.extract::<String>() {
        ring_ret_string!(p, &s);
        return true;
    }

    if let Ok(list) = obj.cast::<PyList>() {
        let ring_list = ring_new_list!(p);
        for item in list.iter() {
            pyobject_to_ring_list(py, &item, ring_list);
        }
        ring_ret_list!(p, ring_list);
        return true;
    }

    if let Ok(tuple) = obj.cast::<PyTuple>() {
        let ring_list = ring_new_list!(p);
        for item in tuple.iter() {
            pyobject_to_ring_list(py, &item, ring_list);
        }
        ring_ret_list!(p, ring_list);
        return true;
    }

    if let Ok(dict) = obj.cast::<PyDict>() {
        let ring_list = ring_new_list!(p);
        for (key, value) in dict.iter() {
            let item = ring_list_newlist(ring_list);
            if let Ok(k) = key.extract::<String>() {
                ring_list_addstring_str(item, &k);
            } else {
                ring_list_addstring_str(item, &key.to_string());
            }
            pyobject_to_ring_list(py, &value, item);
        }
        ring_ret_list!(p, ring_list);
        return true;
    }

    let repr = obj.to_string();
    ring_ret_string!(p, &repr);
    true
}

fn pyobject_to_ring_list(py: Python, obj: &Bound<PyAny>, list: RingList) {
    if obj.is_none() {
        ring_list_addstring_str(list, "");
        return;
    }

    if let Ok(b) = obj.cast::<PyBool>() {
        ring_list_addint(list, if b.is_true() { 1 } else { 0 });
        return;
    }

    if let Ok(i) = obj.extract::<i64>() {
        ring_list_adddouble(list, i as f64);
        return;
    }

    if let Ok(f) = obj.extract::<f64>() {
        ring_list_adddouble(list, f);
        return;
    }

    if let Ok(s) = obj.extract::<String>() {
        ring_list_addstring_str(list, &s);
        return;
    }

    if let Ok(pylist) = obj.cast::<PyList>() {
        let sublist = ring_list_newlist(list);
        for item in pylist.iter() {
            pyobject_to_ring_list(py, &item, sublist);
        }
        return;
    }

    if let Ok(tuple) = obj.cast::<PyTuple>() {
        let sublist = ring_list_newlist(list);
        for item in tuple.iter() {
            pyobject_to_ring_list(py, &item, sublist);
        }
        return;
    }

    if let Ok(dict) = obj.cast::<PyDict>() {
        let sublist = ring_list_newlist(list);
        for (key, value) in dict.iter() {
            let item = ring_list_newlist(sublist);
            if let Ok(k) = key.extract::<String>() {
                ring_list_addstring_str(item, &k);
            } else {
                ring_list_addstring_str(item, &key.to_string());
            }
            pyobject_to_ring_list(py, &value, item);
        }
        return;
    }

    ring_list_addstring_str(list, &obj.to_string());
}

ring_func!(py_init, |p| {
    ring_check_paracount!(p, 0);
    ensure_initialized();
    ring_ret_number!(p, 1.0);
});

ring_func!(py_version, |p| {
    ring_check_paracount!(p, 0);
    ensure_initialized();
    Python::attach(|py| {
        let version = py.version();
        ring_ret_string!(p, version);
    });
});

ring_func!(py_exec, |p| {
    ring_check_paracount!(p, 1);
    ring_check_string!(p, 1);
    ensure_initialized();

    let code = ring_get_string!(p, 1).to_string();
    let code_cstr = CString::new(code).unwrap();

    Python::attach(|py| match py.run(code_cstr.as_c_str(), None, None) {
        Ok(_) => ring_ret_number!(p, 1.0),
        Err(e) => {
            ring_error!(p, &format!("Python error: {}", e));
        }
    });
});

ring_func!(py_eval, |p| {
    ring_check_paracount!(p, 1);
    ring_check_string!(p, 1);
    ensure_initialized();

    let expr = ring_get_string!(p, 1).to_string();
    let expr_cstr = CString::new(expr).unwrap();

    Python::attach(|py| match py.eval(expr_cstr.as_c_str(), None, None) {
        Ok(result) => {
            pyobject_to_ring(p, py, &result);
        }
        Err(e) => {
            ring_error!(p, &format!("Python error: {}", e));
        }
    });
});

ring_func!(py_import, |p| {
    ring_check_paracount!(p, 1);
    ring_check_string!(p, 1);
    ensure_initialized();

    let module_name = ring_get_string!(p, 1).to_string();

    Python::attach(|py| match py.import(&module_name) {
        Ok(module) => {
            let obj: PyObj = module.unbind().into_any();
            let boxed = Box::new(obj);
            let ptr = Box::into_raw(boxed);
            ring_ret_managed_cpointer!(p, ptr, PYOBJECT_TYPE, free_pyobject);
        }
        Err(e) => {
            ring_error!(p, &format!("Import error: {}", e));
        }
    });
});

ring_func!(py_getattr, |p| {
    ring_check_paracount!(p, 2);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);
    ensure_initialized();

    let attr_name = ring_get_string!(p, 2).to_string();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            match bound.getattr(&*attr_name) {
                Ok(attr) => {
                    pyobject_to_ring(p, py, &attr);
                }
                Err(e) => {
                    ring_error!(p, &format!("Attribute error: {}", e));
                }
            }
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_call, |p| {
    ring_check_paracount_range!(p, 1, 3);
    ring_check_string!(p, 1);
    ensure_initialized();

    let func_path = ring_get_string!(p, 1).to_string();

    Python::attach(|py| {
        let parts: Vec<&str> = func_path.rsplitn(2, '.').collect();

        let (module_path, func_name) = if parts.len() == 2 {
            (parts[1], parts[0])
        } else {
            ("builtins", parts[0])
        };

        let module = match py.import(module_path) {
            Ok(m) => m,
            Err(e) => {
                ring_error!(p, &format!("Import error for '{}': {}", module_path, e));
                return;
            }
        };

        let func = match module.getattr(func_name) {
            Ok(f) => f,
            Err(e) => {
                ring_error!(p, &format!("Function '{}' not found: {}", func_name, e));
                return;
            }
        };

        let args = if ring_api_paracount(p) >= 2 && ring_api_islist(p, 2) {
            let ring_args = ring_get_list!(p, 2);
            let size = ring_list_getsize(ring_args) as u32;
            let mut py_args: Vec<PyObj> = Vec::with_capacity(size as usize);
            for i in 1..=size {
                let arg = ring_to_pyobject(py, ring_args, i).unwrap();
                py_args.push(arg.unbind());
            }
            PyTuple::new(py, py_args).unwrap()
        } else {
            PyTuple::empty(py)
        };

        let kwargs = if ring_api_paracount(p) >= 3 && ring_api_islist(p, 3) {
            let ring_kwargs = ring_get_list!(p, 3);
            let dict = PyDict::new(py);
            let size = ring_list_getsize(ring_kwargs) as u32;
            for i in 1..=size {
                if ring_list_islist(ring_kwargs, i) {
                    let item = ring_list_getlist(ring_kwargs, i);
                    if ring_list_getsize(item) >= 2 && ring_list_isstring(item, 1) {
                        let key = ring_list_getstring_str(item, 1);
                        let value = ring_to_pyobject(py, item, 2).unwrap();
                        dict.set_item(key, value).ok();
                    }
                }
            }
            Some(dict)
        } else {
            None
        };

        let result = if let Some(kw) = kwargs {
            func.call(args, Some(&kw))
        } else {
            func.call1(args)
        };

        match result {
            Ok(res) => {
                pyobject_to_ring(p, py, &res);
            }
            Err(e) => {
                ring_error!(p, &format!("Call error: {}", e));
            }
        }
    });
});

ring_func!(py_call_method, |p| {
    ring_check_paracount_range!(p, 2, 4);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);
    ensure_initialized();

    let method_name = ring_get_string!(p, 2).to_string();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);

            let args = if ring_api_paracount(p) >= 3 && ring_api_islist(p, 3) {
                let ring_args = ring_get_list!(p, 3);
                let size = ring_list_getsize(ring_args) as u32;
                let mut py_args: Vec<PyObj> = Vec::with_capacity(size as usize);
                for i in 1..=size {
                    let arg = ring_to_pyobject(py, ring_args, i).unwrap();
                    py_args.push(arg.unbind());
                }
                PyTuple::new(py, py_args).unwrap()
            } else {
                PyTuple::empty(py)
            };

            let kwargs = if ring_api_paracount(p) >= 4 && ring_api_islist(p, 4) {
                let ring_kwargs = ring_get_list!(p, 4);
                let dict = PyDict::new(py);
                let size = ring_list_getsize(ring_kwargs) as u32;
                for i in 1..=size {
                    if ring_list_islist(ring_kwargs, i) {
                        let item = ring_list_getlist(ring_kwargs, i);
                        if ring_list_getsize(item) >= 2 && ring_list_isstring(item, 1) {
                            let key = ring_list_getstring_str(item, 1);
                            let value = ring_to_pyobject(py, item, 2).unwrap();
                            dict.set_item(key, value).ok();
                        }
                    }
                }
                Some(dict)
            } else {
                None
            };

            let method = match bound.getattr(&*method_name) {
                Ok(m) => m,
                Err(e) => {
                    ring_error!(p, &format!("Method '{}' not found: {}", method_name, e));
                    return;
                }
            };

            let result = if let Some(kw) = kwargs {
                method.call(args, Some(&kw))
            } else {
                method.call1(args)
            };

            match result {
                Ok(res) => {
                    pyobject_to_ring(p, py, &res);
                }
                Err(e) => {
                    ring_error!(p, &format!("Method call error: {}", e));
                }
            }
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_set, |p| {
    ring_check_paracount!(p, 2);
    ring_check_string!(p, 1);
    ensure_initialized();

    let var_name = ring_get_string!(p, 1).to_string();

    Python::attach(|py| {
        let globals = py.import("__main__").unwrap().dict();

        let value: Bound<PyAny> = if ring_api_isstring(p, 2) {
            let s = ring_get_string!(p, 2);
            PyString::new(py, s).into_any()
        } else if ring_api_isnumber(p, 2) {
            let n = ring_get_number!(p, 2);
            if n.fract() == 0.0 && n >= i64::MIN as f64 && n <= i64::MAX as f64 {
                PyInt::new(py, n as i64).into_any()
            } else {
                PyFloat::new(py, n).into_any()
            }
        } else if ring_api_islist(p, 2) {
            let list = ring_get_list!(p, 2);
            ring_list_to_pyobject(py, list).unwrap()
        } else {
            py.None().into_bound(py)
        };

        match globals.set_item(&var_name, value) {
            Ok(_) => ring_ret_number!(p, 1.0),
            Err(e) => {
                ring_error!(p, &format!("Failed to set variable: {}", e));
            }
        }
    });
});

ring_func!(py_get, |p| {
    ring_check_paracount!(p, 1);
    ring_check_string!(p, 1);
    ensure_initialized();

    let var_name = ring_get_string!(p, 1).to_string();

    Python::attach(|py| {
        let globals = py.import("__main__").unwrap().dict();

        match globals.get_item(&var_name) {
            Ok(Some(value)) => {
                pyobject_to_ring(p, py, &value);
            }
            Ok(None) => {
                ring_error!(p, &format!("Variable '{}' not found", var_name));
            }
            Err(e) => {
                ring_error!(p, &format!("Error getting variable: {}", e));
            }
        }
    });
});

ring_func!(py_isinstance, |p| {
    ring_check_paracount!(p, 2);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);
    ensure_initialized();

    let type_name = ring_get_string!(p, 2).to_string();
    let type_cstr = CString::new(type_name).unwrap();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            let type_obj = match py.eval(type_cstr.as_c_str(), None, None) {
                Ok(t) => t,
                Err(_) => {
                    ring_ret_number!(p, 0.0);
                    return;
                }
            };
            let result = bound.is_instance(&type_obj).unwrap_or(false);
            ring_ret_number!(p, if result { 1.0 } else { 0.0 });
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_type, |p| {
    ring_check_paracount!(p, 1);
    ring_check_cpointer!(p, 1);
    ensure_initialized();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            match bound.get_type().name() {
                Ok(name) => ring_ret_string!(p, &name.to_string()),
                Err(_) => ring_ret_string!(p, "unknown"),
            }
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_repr, |p| {
    ring_check_paracount!(p, 1);
    ring_check_cpointer!(p, 1);
    ensure_initialized();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            match bound.repr() {
                Ok(r) => ring_ret_string!(p, &r.to_string()),
                Err(e) => ring_error!(p, &format!("Repr error: {}", e)),
            }
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_str, |p| {
    ring_check_paracount!(p, 1);
    ring_check_cpointer!(p, 1);
    ensure_initialized();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            match bound.str() {
                Ok(s) => ring_ret_string!(p, &s.to_string()),
                Err(e) => ring_error!(p, &format!("Str error: {}", e)),
            }
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_len, |p| {
    ring_check_paracount!(p, 1);
    ring_check_cpointer!(p, 1);
    ensure_initialized();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            match bound.len() {
                Ok(len) => ring_ret_number!(p, len as f64),
                Err(e) => ring_error!(p, &format!("Len error: {}", e)),
            }
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_dir, |p| {
    ring_check_paracount!(p, 1);
    ring_check_cpointer!(p, 1);
    ensure_initialized();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            match bound.dir() {
                Ok(dir_list) => {
                    let ring_list = ring_new_list!(p);
                    for item in dir_list.iter() {
                        if let Ok(s) = item.extract::<String>() {
                            ring_list_addstring_str(ring_list, &s);
                        }
                    }
                    ring_ret_list!(p, ring_list);
                }
                Err(e) => ring_error!(p, &format!("Dir error: {}", e)),
            }
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_hasattr, |p| {
    ring_check_paracount!(p, 2);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);
    ensure_initialized();

    let attr_name = ring_get_string!(p, 2).to_string();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            let result = bound.hasattr(&*attr_name).unwrap_or(false);
            ring_ret_number!(p, if result { 1.0 } else { 0.0 });
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_object, |p| {
    ring_check_paracount!(p, 1);
    ensure_initialized();

    Python::attach(|py| {
        let value: Bound<PyAny> = if ring_api_isstring(p, 1) {
            let s = ring_get_string!(p, 1);
            PyString::new(py, s).into_any()
        } else if ring_api_isnumber(p, 1) {
            let n = ring_get_number!(p, 1);
            if n.fract() == 0.0 && n >= i64::MIN as f64 && n <= i64::MAX as f64 {
                PyInt::new(py, n as i64).into_any()
            } else {
                PyFloat::new(py, n).into_any()
            }
        } else if ring_api_islist(p, 1) {
            let list = ring_get_list!(p, 1);
            ring_list_to_pyobject(py, list).unwrap()
        } else {
            py.None().into_bound(py)
        };

        let obj: PyObj = value.unbind();
        let boxed = Box::new(obj);
        let ptr = Box::into_raw(boxed);
        ring_ret_managed_cpointer!(p, ptr, PYOBJECT_TYPE, free_pyobject);
    });
});

ring_func!(py_value, |p| {
    ring_check_paracount!(p, 1);
    ring_check_cpointer!(p, 1);
    ensure_initialized();

    if let Some(obj) = ring_get_pointer!(p, 1, PyObj, PYOBJECT_TYPE) {
        Python::attach(|py| {
            let bound = obj.bind(py);
            pyobject_to_ring(p, py, bound);
        });
    } else {
        ring_error!(p, "Invalid Python object pointer");
    }
});

ring_func!(py_none, |p| {
    ring_check_paracount!(p, 0);
    ensure_initialized();

    Python::attach(|py| {
        let none: PyObj = py.None();
        let boxed = Box::new(none);
        let ptr = Box::into_raw(boxed);
        ring_ret_managed_cpointer!(p, ptr, PYOBJECT_TYPE, free_pyobject);
    });
});

ring_func!(py_true, |p| {
    ring_check_paracount!(p, 0);
    ensure_initialized();

    Python::attach(|py| {
        let val: PyObj = PyBool::new(py, true).to_owned().unbind().into_any();
        let boxed = Box::new(val);
        let ptr = Box::into_raw(boxed);
        ring_ret_managed_cpointer!(p, ptr, PYOBJECT_TYPE, free_pyobject);
    });
});

ring_func!(py_false, |p| {
    ring_check_paracount!(p, 0);
    ensure_initialized();

    Python::attach(|py| {
        let val: PyObj = PyBool::new(py, false).to_owned().unbind().into_any();
        let boxed = Box::new(val);
        let ptr = Box::into_raw(boxed);
        ring_ret_managed_cpointer!(p, ptr, PYOBJECT_TYPE, free_pyobject);
    });
});

ring_func!(py_list, |p| {
    ring_check_paracount_range!(p, 0, 1);
    ensure_initialized();

    Python::attach(|py| {
        let pylist = if ring_api_paracount(p) == 1 && ring_api_islist(p, 1) {
            let ring_list = ring_get_list!(p, 1);
            ring_list_to_pyobject(py, ring_list).unwrap()
        } else {
            PyList::empty(py).into_any()
        };

        let obj: PyObj = pylist.unbind();
        let boxed = Box::new(obj);
        let ptr = Box::into_raw(boxed);
        ring_ret_managed_cpointer!(p, ptr, PYOBJECT_TYPE, free_pyobject);
    });
});

ring_func!(py_dict, |p| {
    ring_check_paracount_range!(p, 0, 1);
    ensure_initialized();

    Python::attach(|py| {
        let pydict = if ring_api_paracount(p) == 1 && ring_api_islist(p, 1) {
            let ring_list = ring_get_list!(p, 1);
            ring_list_to_pyobject(py, ring_list).unwrap()
        } else {
            PyDict::new(py).into_any()
        };

        let obj: PyObj = pydict.unbind();
        let boxed = Box::new(obj);
        let ptr = Box::into_raw(boxed);
        ring_ret_managed_cpointer!(p, ptr, PYOBJECT_TYPE, free_pyobject);
    });
});

ring_func!(py_tuple, |p| {
    ring_check_paracount_range!(p, 0, 1);
    ensure_initialized();

    Python::attach(|py| {
        let pytuple = if ring_api_paracount(p) == 1 && ring_api_islist(p, 1) {
            let ring_list = ring_get_list!(p, 1);
            let size = ring_list_getsize(ring_list) as u32;
            let mut items: Vec<PyObj> = Vec::with_capacity(size as usize);
            for i in 1..=size {
                let item = ring_to_pyobject(py, ring_list, i).unwrap();
                items.push(item.unbind());
            }
            PyTuple::new(py, items).unwrap().into_any()
        } else {
            PyTuple::empty(py).into_any()
        };

        let obj: PyObj = pytuple.unbind();
        let boxed = Box::new(obj);
        let ptr = Box::into_raw(boxed);
        ring_ret_managed_cpointer!(p, ptr, PYOBJECT_TYPE, free_pyobject);
    });
});

ring_libinit! {
    "py_init" => py_init,
    "py_version" => py_version,
    "py_exec" => py_exec,
    "py_eval" => py_eval,
    "py_import" => py_import,
    "py_call" => py_call,
    "py_call_method" => py_call_method,
    "py_set" => py_set,
    "py_get" => py_get,
    "py_getattr" => py_getattr,
    "py_hasattr" => py_hasattr,
    "py_isinstance" => py_isinstance,
    "py_type" => py_type,
    "py_repr" => py_repr,
    "py_str" => py_str,
    "py_len" => py_len,
    "py_dir" => py_dir,
    "py_object" => py_object,
    "py_value" => py_value,
    "py_none" => py_none,
    "py_true" => py_true,
    "py_false" => py_false,
    "py_list" => py_list,
    "py_dict" => py_dict,
    "py_tuple" => py_tuple,
}
