/*
    07 - Python Containers
    Create and work with Python lists, dicts, and tuples.
*/

load "python.ring"

py_init()

# ---- Lists ----
? "=== Lists ==="
mylist = py_list([10, 20, 30, 40, 50])
? "List: " + py_str(mylist)
? "Type: " + py_type(mylist)
? "Len:  " + py_len(mylist)

# Call list methods
py_call_method(mylist, "append", [60])
py_call_method(mylist, "reverse", [])
? "After append(60) + reverse(): " + py_str(mylist)

# Empty list
empty = py_list([])
? "Empty list len: " + py_len(empty)

# ---- Dicts ----
? ""
? "=== Dicts ==="
mydict = py_dict([["name", "Ring"], ["version", "1.21"], ["year", 2016]])
? "Dict: " + py_str(mydict)
? "Type: " + py_type(mydict)
? "Len:  " + py_len(mydict)

# Get a value via Python
py_set("_d", py_value(mydict))
py_exec("_name = _d['name']")
? "dict['name'] = " + py_get("_name")

# ---- Tuples ----
? ""
? "=== Tuples ==="
mytuple = py_tuple([1, 2, 3])
? "Tuple: " + py_str(mytuple)
? "Type:  " + py_type(mytuple)
? "Len:   " + py_len(mytuple)

# ---- Constants ----
? ""
? "=== Constants ==="
? "None type:  " + py_type(py_none())
? "True value: " + py_value(py_true())
? "False value:" + py_value(py_false())
