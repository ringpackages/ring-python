aPackageInfo = [
	:name = "Ring Python",
	:description = "Python bindings for the Ring Programming Language.",
	:folder = "ring-python",
	:developer = "ysdragon",
	:email = "youssefelkholey@gmail.com",
	:license = "MIT",
	:version = "1.0.0",
	:ringversion = "1.25",
	:versions = 	[
		[
			:version = "1.0.0",
			:branch = "master"
		]
	],
	:libs = 	[
		[
			:name = "",
			:version = "",
			:providerusername = ""
		]
	],
	:files = 	[
		"lib.ring",
		"main.ring",
		"README.md",
		"tests/python_test.ring",
		"examples/01_hello.ring",
		"examples/02_variables.ring",
		"examples/03_eval.ring",
		"examples/04_functions.ring",
		"examples/05_modules.ring",
		"examples/06_objects.ring",
		"examples/07_containers.ring",
		"examples/08_oop.ring",
		"examples/09_json.ring",
		"examples/10_strings.ring",
		"examples/11_math.ring",
		"examples/12_datetime.ring",
		"examples/13_file_io.ring",
		"examples/14_regex.ring",
		"examples/15_collections.ring",
		"examples/16_classes.ring",
		"examples/17_http.ring",
		"examples/18_base64_hashing.ring",
		"examples/19_sysinfo.ring",
		"examples/20_ytdlp.ring",
		"examples/21_numpy.ring",
		"examples/22_pandas.ring",
		"examples/23_matplotlib.ring",
		"examples/24_pillow.ring",
		"examples/25_sqlite.ring",
		"examples/26_csv.ring",
		"src/python.ring",
		"src/rust_src/Cargo.toml",
		"src/rust_src/.gitignore",
		"src/rust_src/src/lib.rs",
		"src/rust_src/build.rs",
		"src/utils/uninstall.ring",
		"src/utils/color.ring",
		"src/utils/install.ring",
		"LICENSE"
	],
	:ringfolderfiles = 	[

	],
	:windowsfiles = 	[
		"lib/windows/amd64/ring_python.dll",
		"lib/windows/amd64/ring_python_impl.dll",
		"lib/windows/i386/ring_python.dll",
		"lib/windows/i386/ring_python_impl.dll"
	],
	:linuxfiles = 	[
		"lib/linux/amd64/libring_python.so",
		"lib/linux/amd64/libring_python_impl.so",
		"lib/linux/arm64/libring_python.so",
		"lib/linux/arm64/libring_python_impl.so",
		"lib/linux/musl/amd64/libring_python.so",
		"lib/linux/musl/amd64/libring_python_impl.so",
		"lib/linux/musl/arm64/libring_python.so",
		"lib/linux/musl/arm64/libring_python_impl.so"
	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:macosfiles = 	[
		"lib/macos/amd64/libring_python.dylib",
		"lib/macos/amd64/libring_python_impl.dylib",
		"lib/macos/arm64/libring_python.dylib",
		"lib/macos/arm64/libring_python_impl.dylib"
	],
	:freebsdfiles = 	[
		"lib/freebsd/amd64/libring_python.so",
		"lib/freebsd/amd64/libring_python_impl.so"
	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:freebsdringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "ring src/utils/install.ring",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "ring src/utils/uninstall.ring",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = "",
    :remotefolder = "ring-python",
    :branch = "master",
    :providerusername = "ysdragon",
    :providerwebsite = "github.com"
]
