/*
    09 - JSON Processing
    Use Python's json module to parse and generate JSON.
*/

load "python.ring"

py_init()
py_exec("import json")

# ---- Parsing JSON ----
? "=== Parse JSON ==="
jsonstr = '{"name": "Ring", "version": ' + version() + ', "features": ["OOP", "Functional", "Declarative"]}'

py_set("raw", jsonstr)
py_exec("parsed = json.loads(raw)")
parsed = py_get("parsed")

? "Parsed JSON:"
for pair in parsed
    if islist(pair) and len(pair) = 2
        key = pair[1]
        value = pair[2]
        if islist(value)
            ? "  " + key + ":"
            for item in value
                ? "    - " + item
            next
        else
            ? "  " + key + ": " + value
        ok
    ok
next

# ---- Generating JSON ----
? ""
? "=== Generate JSON ==="

# Build a Ring structure, send to Python, dump as JSON
data = [
    ["language", "Ring"],
    ["year", 2016],
    ["tags", ["embedded", "python", "cross-platform"]]
]

py_set("data", data)
py_exec("pretty = json.dumps(data, indent=2, sort_keys=True)")
? py_get("pretty")

# ---- Round-trip ----
? ""
? "=== Round-trip ==="
py_exec("
original = {'pi': 3.14159, 'items': [1, 2, 3], 'nested': {'a': True}}
encoded = json.dumps(original)
decoded = json.loads(encoded)
match = original == decoded
")

? "Encoded: " + py_get("encoded")
? "Round-trip match: " + py_get("match")
