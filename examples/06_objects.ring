/*
    06 - Python Objects
    Create Python objects and call methods on them.
*/

load "python.ring"

py_init()

# Create a Python string object
pystr = py_object("hello world")

# Object info
? "Type: " + py_type(pystr)
? "Repr: " + py_repr(pystr)
? "Str:  " + py_str(pystr)
? "Len:  " + py_len(pystr)

# Call methods
? ""
? "upper():            " + py_call_method(pystr, "upper", [])
? "title():            " + py_call_method(pystr, "title", [])
? "replace('world'):   " + py_call_method(pystr, "replace", ["world", "Ring"])
? "split():            "

words = py_call_method(pystr, "split", [])
for w in words
    ? "  - " + w
next

# Type checking
? ""
pyint = py_object(42)
? "42 is int: " + py_isinstance(pyint, "int")
? "42 is str: " + py_isinstance(pyint, "str")

pyfloat = py_object(3.14)
? "3.14 type: " + py_type(pyfloat)

# Get value back into Ring
? ""
? "py_value(42):    " + py_value(pyint)
? "py_value(3.14):  " + py_value(pyfloat)
? "py_value('hello world'): " + py_value(pystr)
