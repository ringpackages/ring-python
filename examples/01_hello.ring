/*
    01 - Hello World
    The simplest Ring-Python program.
    Initialize Python, execute code, and evaluate an expression.
*/

load "python.ring"

py_init()

? "Python version: " + py_version()
? ""

# Execute a Python statement
py_exec("print('Hello from Python!')")

# Evaluate a Python expression and get the result in Ring
result = py_eval("1 + 2 + 3")
? "1 + 2 + 3 = " + result
