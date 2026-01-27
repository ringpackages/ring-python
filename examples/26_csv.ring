/*
    26 - CSV Processing
    Read, write, and process CSV data using Python's built-in csv module.
    (No external dependencies required)
*/

load "python.ring"

py_init()

cFile = "example_data.csv"

# ---- Write CSV ----
? "=== Write CSV ==="
py_set("csv_path", cFile)
py_exec("
import csv

rows = [
    ['Name', 'Department', 'Salary', 'Years'],
    ['Alice',   'Engineering', 95000, 5],
    ['Bob',     'Marketing',   72000, 3],
    ['Charlie', 'Engineering', 88000, 4],
    ['Diana',   'Sales',       68000, 2],
    ['Eve',     'Engineering', 102000, 7],
    ['Frank',   'Marketing',   75000, 4],
    ['Grace',   'Sales',       71000, 3],
]

with open(csv_path, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerows(rows)

_count = len(rows) - 1
")
? "Wrote " + py_get("_count") + " records to " + cFile

# ---- Read CSV ----
? ""
? "=== Read CSV ==="
py_exec("
with open(csv_path, 'r') as f:
    reader = csv.DictReader(f)
    records = list(reader)
_headers = list(records[0].keys())
_total = len(records)
")
? "Headers: " + py_eval("', '.join(_headers)")
? "Records: " + py_get("_total")

# ---- Process: Department summary ----
? ""
? "=== Department Summary ==="
py_exec("
from collections import defaultdict
dept = defaultdict(lambda: {'count': 0, 'total_salary': 0, 'total_years': 0})

for r in records:
    d = r['Department']
    dept[d]['count'] += 1
    dept[d]['total_salary'] += int(r['Salary'])
    dept[d]['total_years'] += int(r['Years'])

summary = []
for d, v in sorted(dept.items()):
    summary.append({
        'dept': d,
        'count': v['count'],
        'avg_salary': round(v['total_salary'] / v['count']),
        'avg_years': round(v['total_years'] / v['count'], 1),
    })
")

summary = py_get("summary")
? "Department   | Count | Avg Salary | Avg Years"
? "-------------|-------|------------|----------"
for row in summary
    if islist(row)
        dept = "" count = "" sal = "" yrs = ""
        for pair in row
            if islist(pair) and len(pair) = 2
                if pair[1] = "dept"       dept = pair[2] ok
                if pair[1] = "count"      count = pair[2] ok
                if pair[1] = "avg_salary" sal = pair[2] ok
                if pair[1] = "avg_years"  yrs = pair[2] ok
            ok
        next
        ? dept + " | " + count + "     | $" + sal + "   | " + yrs
    ok
next

# ---- Filter and export ----
? ""
? "=== Top Earners (>= $80k) ==="
py_exec("
top = [r for r in records if int(r['Salary']) >= 80000]
_top_names = [r['Name'] + ' ($' + r['Salary'] + ')' for r in top]
")
top_names = py_get("_top_names")
for n in top_names
    ? "  " + n
next

# Cleanup
py_exec("
import os
os.remove(csv_path)
")
? ""
? "Cleaned up " + cFile
