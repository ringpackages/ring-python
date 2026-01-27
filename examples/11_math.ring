/*
    11 - Math & Science
    Use Python's math module for calculations.
*/

load "python.ring"

py_init()
py_exec("import math")

# Constants
? "=== Constants ==="
py_exec("_pi = str(math.pi)")
? "pi  = " + py_get("_pi")
py_exec("_e = str(math.e)")
? "e   = " + py_get("_e")
py_exec("_tau = str(math.tau)")
? "tau = " + py_get("_tau")

# Basic math
? ""
? "=== Basic ==="
? "sqrt(2)      = " + py_call("math.sqrt", [2])
? "pow(2, 16)   = " + py_call("math.pow", [2, 16])
? "factorial(12) = " + py_call("math.factorial", [12])
? "gcd(48, 18)  = " + py_call("math.gcd", [48, 18])
? "log2(1024)   = " + py_call("math.log2", [1024])

# Trigonometry
? ""
? "=== Trigonometry ==="
py_exec("
import math
angles = [0, 30, 45, 60, 90]
trig = []
for a in angles:
    rad = math.radians(a)
    trig.append({
        'deg': a,
        'sin': round(math.sin(rad), 4),
        'cos': round(math.cos(rad), 4),
    })
")

trig = py_get("trig")
? "deg  |  sin     |  cos"
? "-----|---------|--------"
for row in trig
    if islist(row)
        deg = "" sin = "" cos = ""
        for pair in row
            if islist(pair) and len(pair) = 2
                if pair[1] = "deg"  deg = pair[2] ok
                if pair[1] = "sin"  sin = pair[2] ok
                if pair[1] = "cos"  cos = pair[2] ok
            ok
        next
        ? "" + deg + "    |  " + sin + "  |  " + cos
    ok
next

# Statistics
? ""
? "=== Statistics ==="
py_exec("
import statistics
data = [4, 8, 6, 5, 3, 7, 9, 2, 8, 6]
stats = {
    'mean': statistics.mean(data),
    'median': statistics.median(data),
    'stdev': round(statistics.stdev(data), 4),
    'variance': round(statistics.variance(data), 4),
}
")
stats = py_get("stats")
for pair in stats
    if islist(pair) and len(pair) = 2
        ? pair[1] + ": " + pair[2]
    ok
next
