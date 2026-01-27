/*
    02 - Variables
    Exchange data between Ring and Python using py_set() / py_get().
*/

load "python.ring"

py_init()

# Send Ring values to Python
py_set("name", "Ring")
py_set("year", 2016)
py_set("pi", 3.14159)

# Use them in Python code
py_exec("greeting = f'{name} was created in {year}'")

# Read Python values back into Ring
? "Greeting: " + py_get("greeting")
? "Pi from Python: " + py_get("pi")
? ""

# Lists round-trip
py_set("colors", ["red", "green", "blue"])
colors = py_get("colors")
? "Colors:"
for c in colors
    ? "  - " + c
next
? ""

# Dicts round-trip (Ring list of [key, value] pairs)
py_set("person", [["name", "Alice"], ["age", 30]])
person = py_get("person")
? "Person:"
for pair in person
    ? "  " + pair[1] + ": " + pair[2]
next
