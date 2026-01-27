/*
    03 - Expressions & Eval
    Evaluate Python expressions and get typed results back in Ring.
*/

load "python.ring"

py_init()

# Numbers
? "2 ** 10 = " + py_eval("2 ** 10")
? "22 / 7  = " + py_eval("22 / 7")

# Strings
? py_eval("'hello' + ' ' + 'world'")
? py_eval("'ring-python'.upper()")

# Lists
squares = py_eval("[x**2 for x in range(6)]")
? "Squares: "
for s in squares
    ? "  " + s
next

# Dicts (returned as list of [key, value] pairs)
? ""
person = py_eval("{'name': 'Alice', 'age': 30}")
? "Person:"
for pair in person
    if islist(pair) and len(pair) = 2
        ? "  " + pair[1] + ": " + pair[2]
    ok
next

# Boolean
? ""
? "10 > 5 = " + py_eval("10 > 5")
? "10 < 5 = " + py_eval("10 < 5")
