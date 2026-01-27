/*
    15 - Python Collections & Comprehensions
    Demonstrate list/dict comprehensions and collections module.
*/

load "python.ring"

py_init()

# ---- List comprehensions ----
? "=== List Comprehensions ==="

py_exec("squares = [x**2 for x in range(10)]")
? "Squares 0-9: "
squares = py_get("squares")
for s in squares
    ? "  " + s
next

py_exec("evens = [x for x in range(20) if x % 2 == 0]")
? ""
? "Even numbers 0-19:"
evens = py_get("evens")
for e in evens
    ? "  " + e
next

# ---- Dict comprehension ----
? ""
? "=== Dict Comprehension ==="
py_exec("
word = 'abracadabra'
freq = {ch: word.count(ch) for ch in set(word)}
")
freq = py_get("freq")
? "Character frequency in 'abracadabra':"
for pair in freq
    if islist(pair) and len(pair) = 2
        ? "  '" + pair[1] + "' → " + pair[2]
    ok
next

# ---- collections.Counter ----
? ""
? "=== Counter ==="
py_exec("
from collections import Counter
words = 'the cat sat on the mat the cat'.split()
counts = dict(Counter(words).most_common())
")
counts = py_get("counts")
? "Word counts:"
for pair in counts
    if islist(pair) and len(pair) = 2
        ? "  " + pair[1] + ": " + pair[2]
    ok
next

# ---- Sorting ----
? ""
? "=== Sorting ==="
py_exec("
data = [
    {'name': 'Charlie', 'age': 25},
    {'name': 'Alice', 'age': 30},
    {'name': 'Bob', 'age': 20},
]
by_name = sorted(data, key=lambda x: x['name'])
by_age  = sorted(data, key=lambda x: x['age'])
_names = [p['name'] for p in by_name]
_ages  = [p['name'] + '(' + str(p['age']) + ')' for p in by_age]
")
? "By name: " + py_eval("', '.join(_names)")
? "By age:  " + py_eval("', '.join(_ages)")
