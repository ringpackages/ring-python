/*
    08 - Object-Oriented API
    Use the Ring wrapper classes for a cleaner interface.
*/

load "python.ring"

# The Python class auto-initializes the interpreter
py = new Python()
? "Python version: " + py.version()
? ""

# Execute and evaluate
py.exec("import math")
py.exec("result = math.factorial(10)")
? "10! = " + py.getVar("result")

? "sqrt(2) = " + py.callFuncArgs("math.sqrt", [2])
? ""

# PyModule — wraps a Python module
math = new PyModule("math")
? "math.pi:       " + math.getattr("pi")
? "math has sqrt: " + math.hasattr("sqrt")
? "math type:     " + math.type()
? ""

# PyList, PyDict, PyTuple
mylist = new PyList([10, 20, 30])
? "PyList: " + mylist.str() + "  len=" + mylist.len()

mydict = new PyDict([["name", "Ring"], ["year", 2016]])
? "PyDict: " + mydict.str() + "  len=" + mydict.len()

mytuple = new PyTuple([1, 2, 3])
? "PyTuple: " + mytuple.str() + "  len=" + mytuple.len()
? ""

# PyBool, PyNone
pynone = new PyNone()
? "PyNone type: " + pynone.type()

pytrue = new PyBool(true)
? "PyBool(true) value: " + pytrue.value()

# PyValue — convert any Ring value to Python object
pyval = new PyValue("Hello from Ring!")
? "PyValue str: " + pyval.str()
? "PyValue type: " + pyval.type()
