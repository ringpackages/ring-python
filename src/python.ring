# This file is part of the Ring Python library.

class Python

    func init
        py_init()

    func exec code
        return py_exec(code)

    func eval expr
        return py_eval(expr)

    func importModule module
        return py_import(module)

    func callFunc cFunc
        return py_call(cFunc)

    func callFuncArgs cFunc, args
        return py_call(cFunc, args)

    func callFuncKwargs cFunc, args, kwargs
        return py_call(cFunc, args, kwargs)

    func set name, value
        return py_set(name, value)

    func getVar name
        return py_get(name)

    func version
        return py_version()

class PyObject

    ptr

    func init p
        ptr = p

    func getattr name
        return py_getattr(ptr, name)

    func hasattr name
        return py_hasattr(ptr, name)

    func callMethod name
        return py_call_method(ptr, name)

    func callMethodArgs name, args
        return py_call_method(ptr, name, args)

    func callMethodKwargs name, args, kwargs
        return py_call_method(ptr, name, args, kwargs)

    func isinstance cType
        return py_isinstance(ptr, cType)

    func type
        return py_type(ptr)

    func repr
        return py_repr(ptr)

    func str
        return py_str(ptr)

    func len
        return py_len(ptr)

    func dir
        return py_dir(ptr)

    func value
        return py_value(ptr)

class PyModule from PyObject

    func init name
        ptr = py_import(name)

class PyNone from PyObject

    func init
        ptr = py_none()

class PyBool from PyObject

    func init bVal
        if bVal
            ptr = py_true()
        else
            ptr = py_false()
        ok

class PyList from PyObject

    func init aVal
        if aVal != NULL
            ptr = py_list(aVal)
        else
            ptr = py_list()
        ok

class PyDict from PyObject

    func init aVal
        if aVal != NULL
            ptr = py_dict(aVal)
        else
            ptr = py_dict()
        ok

class PyTuple from PyObject

    func init aVal
        if aVal != NULL
            ptr = py_tuple(aVal)
        else
            ptr = py_tuple()
        ok

class PyValue from PyObject

    func init xVal
        ptr = py_object(xVal)
