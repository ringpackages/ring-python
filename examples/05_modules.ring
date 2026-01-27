/*
    05 - Importing Modules
    Import Python modules and access their attributes.
*/

load "python.ring"

py_init()

# Import modules using py_import() — returns a pointer
math = py_import("math")
json = py_import("json")
os   = py_import("os")
sys  = py_import("sys")

# Access module attributes with py_getattr()
? "math.pi = " + py_getattr(math, "pi")
? "math.e  = " + py_getattr(math, "e")

# Check if an attribute exists
? ""
? "math has 'sqrt':  " + py_hasattr(math, "sqrt")
? "math has 'hello': " + py_hasattr(math, "hello")

# Get the current working directory
? ""
? "CWD: " + py_call("os.getcwd", [])

# List sys.path entries
? ""
? "Python sys.path:"
py_exec("import sys; _paths = sys.path[:5]")
paths = py_get("_paths")
for p in paths
    ? "  " + p
next

# Get module dir listing (first 10 items)
? ""
? "First 10 items in dir(math):"
dirlist = py_dir(math)
for i = 1 to 10
    ? "  " + dirlist[i]
next
