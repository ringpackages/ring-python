/*
    10 - String Operations
    Use Python's rich string methods from Ring.
*/

load "python.ring"

py_init()

text = py_object("  Hello, World!  ")

? "Original:  '" + py_str(text) + "'"
? "strip():   '" + py_call_method(text, "strip", []) + "'"
? "lower():   '" + py_call_method(text, "lower", []) + "'"
? "upper():   '" + py_call_method(text, "upper", []) + "'"
? "title():   '" + py_call_method(text, "title", []) + "'"

# Replace and split
? ""
msg = py_object("one-two-three-four")
? "Original: " + py_str(msg)
? "Replace '-' with ' ': " + py_call_method(msg, "replace", ["-", " "])

parts = py_call_method(msg, "split", ["-"])
? "Split by '-':"
for p in parts
    ? "  [" + p + "]"
next

# f-strings via py_exec
? ""
py_set("lang", "Ring")
py_set("lib", "ring-python")
py_exec("banner = f'{lang} + Python = {lib}'")
? py_get("banner")

# String formatting
? ""
py_exec("
rows = []
for i in range(1, 6):
    rows.append(f'{i:>3} | {i**2:>5} | {i**3:>7}')
header = '{:>3} | {:>5} | {:>7}'.format('n', 'n^2', 'n^3')
")
? "Power table:"
? py_get("header")
? "----|-------|--------"
rows = py_get("rows")
for row in rows
    ? row
next
