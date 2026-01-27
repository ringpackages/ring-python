/*
    04 - Calling Python Functions
    Use py_call() to invoke any Python function by dotted path.
*/

load "python.ring"

py_init()
py_exec("import math")
py_exec("import os.path")

# Built-in functions
? "len('hello') = " + py_call("len", ["hello"])
? "abs(-42)    = " + py_call("abs", [-42])
? "max(3,7,1)  = " + py_call("max", [[3, 7, 1]])

# Module functions
? ""
? "math.sqrt(144)    = " + py_call("math.sqrt", [144])
? "math.pow(2, 10)   = " + py_call("math.pow", [2, 10])
? "math.factorial(8) = " + py_call("math.factorial", [8])

# os.path
? ""
? "os.path.join: " + py_call("os.path.join", ["/home", "user", "docs"])

# With keyword arguments (py_call with 3 params: func, args, kwargs)
py_exec("import json")
result = py_call("json.dumps", [[["x", 1], ["y", 2]]], [["indent", 2]])
? ""
? "json.dumps with indent:"
? result
