if isWindows()
	loadlib("ring_python.dll")
but isLinux() or isFreeBSD()
	loadlib("libring_python.so")
but isMacOSX()
	loadlib("libring_python.dylib")
else
	raise("Unsupported OS! You need to build the library for your OS.")
ok

load "src/python.ring"
