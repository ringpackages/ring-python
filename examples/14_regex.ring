/*
    14 - Regular Expressions
    Use Python's re module for pattern matching.
*/

load "python.ring"

py_init()
py_exec("import re")

# ---- Simple matching ----
? "=== Pattern Matching ==="
py_set("text", "My phone is 555-1234 and office is 555-5678")
py_exec("
import re
matches = re.findall(r'\d{3}-\d{4}', text)
")
phones = py_get("matches")
? "Found phone numbers:"
for p in phones
    ? "  " + p
next

# ---- Email extraction ----
? ""
? "=== Email Extraction ==="
py_set("html", "Contact us at support@example.com or sales@company.org for info")
py_exec("
emails = re.findall(r'[\w.+-]+@[\w-]+\.[\w.-]+', html)
")
emails = py_get("emails")
? "Found emails:"
for e in emails
    ? "  " + e
next

# ---- Search and groups ----
? ""
? "=== Search with Groups ==="
py_set("log", "2025-02-27 14:30:55 ERROR Connection timeout after 30s")
py_exec("
m = re.search(r'(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) (\w+) (.+)', log)
if m:
    _date = m.group(1)
    _time = m.group(2)
    _level = m.group(3)
    _msg = m.group(4)
")
? "Date:    " + py_get("_date")
? "Time:    " + py_get("_time")
? "Level:   " + py_get("_level")
? "Message: " + py_get("_msg")

# ---- Substitution ----
? ""
? "=== Substitution ==="
py_set("messy", "too    many     spaces    here")
py_exec("clean = re.sub(r'\s+', ' ', messy)")
? "Before: '" + py_get("messy") + "'"
? "After:  '" + py_get("clean") + "'"
