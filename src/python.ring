/*
 * Ring Python Library
 * 
 * Provides Python bindings for the Ring programming language,
 * powered by PyO3 (Rust bindings for Python).
 * 
 * This library supports:
 *   - Executing arbitrary Python code and evaluating expressions
 *   - Two-way data exchange (strings, numbers, lists, dicts)
 *   - Importing and calling any installed Python package
 *   - Object-oriented wrappers for Python types
 *   - Method calls with positional and keyword arguments
 *   - Type checking, introspection, and conversion
 */

/**
 * Class Python: Main class for interacting with the Python interpreter.
 * 
 * Provides methods for executing Python code, evaluating expressions,
 * importing modules, calling functions, and exchanging variables.
 * 
 * Example usage:
 *   load "python.ring"
 *   
 *   py = new Python()
 *   py.exec("import math")
 *   ? py.eval("math.pi")
 *   
 *   py.set("name", "Ring")
 *   py.exec("greeting = f'Hello from {name}!'")
 *   ? py.getVar("greeting")
 */
class Python

    /**
     * Initializes the Python interpreter.
     * Called automatically when creating a new Python instance.
     */
    func init
        py_init()

    /**
     * Executes arbitrary Python code.
     * @param code Python source code string.
     * @return 1 on success, 0 on failure.
     */
    func exec code
        return py_exec(code)

    /**
     * Evaluates a Python expression and returns the result.
     * @param expr Python expression string.
     * @return The evaluated result (string, number, list, or pointer).
     */
    func eval expr
        return py_eval(expr)

    /**
     * Imports a Python module.
     * @param module Module name (e.g., "math", "json", "numpy").
     * @return Pointer to the imported module object.
     */
    func importModule module
        return py_import(module)

    /**
     * Calls a Python function with no arguments.
     * @param cFunc Fully qualified function name (e.g., "os.getcwd").
     * @return The function's return value.
     */
    func callFunc cFunc
        return py_call(cFunc)

    /**
     * Calls a Python function with positional arguments.
     * @param cFunc Fully qualified function name (e.g., "math.sqrt").
     * @param args Ring list of arguments.
     * @return The function's return value.
     */
    func callFuncArgs cFunc, args
        return py_call(cFunc, args)

    /**
     * Calls a Python function with positional and keyword arguments.
     * @param cFunc Fully qualified function name.
     * @param args Ring list of positional arguments.
     * @param kwargs Ring list of [key, value] pairs for keyword arguments.
     * @return The function's return value.
     */
    func callFuncKwargs cFunc, args, kwargs
        return py_call(cFunc, args, kwargs)

    /**
     * Sets a variable in the Python global namespace.
     * @param name Variable name.
     * @param value Value to set (string, number, list, or dict-like list).
     * @return 1 on success.
     */
    func set name, value
        return py_set(name, value)

    /**
     * Gets a variable from the Python global namespace.
     * @param name Variable name.
     * @return The variable's value.
     */
    func getVar name
        return py_get(name)

    /**
     * Gets the Python interpreter version string.
     * @return Version string (e.g., "3.13.5 (main, ...)").
     */
    func version
        return py_version()

/**
 * Class PyObject: Base wrapper for any Python object.
 * 
 * Provides methods for attribute access, method calls, type checking,
 * introspection, and value conversion. All other Py* classes inherit
 * from this class.
 * 
 * Example usage:
 *   obj = new PyObject(py_object("hello"))
 *   ? obj.type()       # str
 *   ? obj.len()        # 5
 *   ? obj.callMethod("upper")  # HELLO
 */
class PyObject

    ptr

    /**
     * Initializes a PyObject wrapper around a Python object pointer.
     * @param p Pointer to a Python object (from py_object(), py_import(), etc.).
     */
    func init p
        ptr = p

    /**
     * Gets an attribute from the Python object.
     * @param name Attribute name.
     * @return The attribute value.
     */
    func getattr name
        return py_getattr(ptr, name)

    /**
     * Checks if the Python object has a given attribute.
     * @param name Attribute name.
     * @return 1 if attribute exists, 0 otherwise.
     */
    func hasattr name
        return py_hasattr(ptr, name)

    /**
     * Calls a method on the Python object with no arguments.
     * @param name Method name.
     * @return The method's return value.
     */
    func callMethod name
        return py_call_method(ptr, name)

    /**
     * Calls a method on the Python object with positional arguments.
     * @param name Method name.
     * @param args Ring list of arguments.
     * @return The method's return value.
     */
    func callMethodArgs name, args
        return py_call_method(ptr, name, args)

    /**
     * Calls a method on the Python object with positional and keyword arguments.
     * @param name Method name.
     * @param args Ring list of positional arguments.
     * @param kwargs Ring list of [key, value] pairs for keyword arguments.
     * @return The method's return value.
     */
    func callMethodKwargs name, args, kwargs
        return py_call_method(ptr, name, args, kwargs)

    /**
     * Checks if the Python object is an instance of a given type.
     * @param cType Type name string (e.g., "int", "str", "list").
     * @return 1 if the object is an instance, 0 otherwise.
     */
    func isinstance cType
        return py_isinstance(ptr, cType)

    /**
     * Gets the type name of the Python object.
     * @return Type name string (e.g., "int", "str", "list", "module").
     */
    func type
        return py_type(ptr)

    /**
     * Gets the repr() string of the Python object.
     * @return The Python repr string.
     */
    func repr
        return py_repr(ptr)

    /**
     * Gets the str() string of the Python object.
     * @return The Python str string.
     */
    func str
        return py_str(ptr)

    /**
     * Gets the length of the Python object.
     * @return Length as a number (for strings, lists, dicts, tuples, etc.).
     */
    func len
        return py_len(ptr)

    /**
     * Gets the list of attributes and methods of the Python object.
     * @return Ring list of attribute/method name strings.
     */
    func dir
        return py_dir(ptr)

    /**
     * Converts the Python object back to a Ring value.
     * @return The converted Ring value (string, number, or list).
     */
    func value
        return py_value(ptr)

/**
 * Class PyModule: Wrapper for importing and working with Python modules.
 * Inherits all methods from PyObject.
 * 
 * Example usage:
 *   math = new PyModule("math")
 *   ? math.getattr("pi")       # 3.14159...
 *   ? math.hasattr("sqrt")     # 1
 */
class PyModule from PyObject

    /**
     * Imports a Python module by name.
     * @param name Module name (e.g., "math", "json", "os").
     */
    func init name
        ptr = py_import(name)

/**
 * Class PyNone: Wrapper for Python's None value.
 * Inherits all methods from PyObject.
 * 
 * Example usage:
 *   none = new PyNone()
 *   ? none.type()   # NoneType
 *   ? none.str()    # None
 */
class PyNone from PyObject

    /**
     * Creates a Python None object.
     */
    func init
        ptr = py_none()

/**
 * Class PyBool: Wrapper for Python boolean values.
 * Inherits all methods from PyObject.
 * 
 * Example usage:
 *   t = new PyBool(true)
 *   ? t.str()      # True
 *   ? t.value()    # 1
 */
class PyBool from PyObject

    /**
     * Creates a Python boolean object.
     * @param bVal Ring boolean (true/false).
     */
    func init bVal
        if bVal
            ptr = py_true()
        else
            ptr = py_false()
        ok

/**
 * Class PyList: Wrapper for Python list objects.
 * Inherits all methods from PyObject.
 * 
 * Example usage:
 *   lst = new PyList([1, 2, 3])
 *   ? lst.str()    # [1, 2, 3]
 *   ? lst.len()    # 3
 */
class PyList from PyObject

    /**
     * Creates a Python list from a Ring list.
     * @param aVal Ring list of values.
     */
    func init aVal
        if aVal != NULL
            ptr = py_list(aVal)
        else
            ptr = py_list()
        ok

/**
 * Class PyDict: Wrapper for Python dict objects.
 * Inherits all methods from PyObject.
 * 
 * Example usage:
 *   d = new PyDict([["name", "Ring"], ["year", 2016]])
 *   ? d.str()    # {'name': 'Ring', 'year': 2016}
 *   ? d.len()    # 2
 */
class PyDict from PyObject

    /**
     * Creates a Python dict from a Ring list of key-value pairs.
     * @param aVal Ring list of [key, value] pairs.
     */
    func init aVal
        if aVal != NULL
            ptr = py_dict(aVal)
        else
            ptr = py_dict()
        ok

/**
 * Class PyTuple: Wrapper for Python tuple objects.
 * Inherits all methods from PyObject.
 * 
 * Example usage:
 *   t = new PyTuple([1, 2, 3])
 *   ? t.str()    # (1, 2, 3)
 *   ? t.len()    # 3
 */
class PyTuple from PyObject

    /**
     * Creates a Python tuple from a Ring list.
     * @param aVal Ring list of values.
     */
    func init aVal
        if aVal != NULL
            ptr = py_tuple(aVal)
        else
            ptr = py_tuple()
        ok

/**
 * Class PyValue: Converts any Ring value to a Python object.
 * Inherits all methods from PyObject.
 * 
 * Example usage:
 *   v = new PyValue(42)
 *   ? v.type()     # int
 *   ? v.value()    # 42
 */
class PyValue from PyObject

    /**
     * Creates a Python object from any Ring value.
     * @param xVal Ring value (string, number, or list).
     */
    func init xVal
        ptr = py_object(xVal)
