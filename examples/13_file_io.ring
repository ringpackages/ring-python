/*
    13 - File I/O via Python
    Read and write files using Python's built-in functions.
*/

load "python.ring"

py_init()

cTempFile = "example_output.txt"

# ---- Write a file ----
? "=== Writing File ==="
py_set("filepath", cTempFile)
py_exec("
lines = [
    'Line 1: Hello from ring-python!',
    'Line 2: This file was written by Python,',
    'Line 3: called from Ring.',
    'Line 4: Pretty cool, right?',
]
with open(filepath, 'w') as f:
    f.write('\\n'.join(lines))
_line_count = len(lines)
")
? "Wrote " + py_get("_line_count") + " lines to " + cTempFile

# ---- Read it back ----
? ""
? "=== Reading File ==="
py_exec("
with open(filepath, 'r') as f:
    content = f.read()
_lines = content.strip().split('\\n')
_total = len(_lines)
")

? "Read " + py_get("_total") + " lines:"
lines = py_get("_lines")
for line in lines
    ? "  " + line
next

# ---- File info ----
? ""
? "=== File Info ==="
py_exec("
import os
stat = os.stat(filepath)
_size = stat.st_size
_exists = os.path.exists(filepath)
_abspath = os.path.abspath(filepath)
")
? "Size:     " + py_get("_size") + " bytes"
? "Exists:   " + py_get("_exists")
? "Abs path: " + py_get("_abspath")

# ---- Cleanup ----
py_exec("os.remove(filepath)")
? ""
? "Cleaned up " + cTempFile
