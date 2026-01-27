/*
    25 - SQLite
    Database operations using Python's built-in sqlite3 module.
    (No external dependencies required)
*/

load "python.ring"

py_init()

cDB = "example.db"
py_set("db_path", cDB)

# ---- Create database and table ----
? "=== Create Database ==="
py_exec("
import sqlite3

conn = sqlite3.connect(db_path)
cur = conn.cursor()

cur.execute('''
    CREATE TABLE IF NOT EXISTS employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        department TEXT NOT NULL,
        salary REAL NOT NULL,
        hire_year INTEGER NOT NULL
    )
''')

# Insert sample data
employees = [
    ('Alice',   'Engineering', 95000, 2019),
    ('Bob',     'Marketing',   72000, 2020),
    ('Charlie', 'Engineering', 88000, 2018),
    ('Diana',   'Sales',       68000, 2021),
    ('Eve',     'Engineering', 102000, 2017),
    ('Frank',   'Marketing',   75000, 2019),
    ('Grace',   'Sales',       71000, 2020),
    ('Hank',    'Engineering', 91000, 2018),
]

cur.executemany('INSERT INTO employees (name, department, salary, hire_year) VALUES (?, ?, ?, ?)', employees)
conn.commit()

_count = str(cur.execute('SELECT COUNT(*) FROM employees').fetchone()[0])
")
? "Created " + py_get("_count") + " records in " + cDB

# ---- Query all ----
? ""
? "=== All Employees ==="
py_exec("
rows = cur.execute('SELECT id, name, department, salary, hire_year FROM employees ORDER BY id').fetchall()
_header = 'ID | Name    | Department  | Salary  | Year'
_sep    = '---|---------|-------------|---------|-----'
_lines = []
for r in rows:
    _lines.append(str(r[0]).ljust(2) + ' | ' + r[1].ljust(7) + ' | ' + r[2].ljust(11) + ' | $' + str(int(r[3])).ljust(6) + ' | ' + str(r[4]))
_table = chr(10).join(_lines)
")
? py_get("_header")
? py_get("_sep")
? py_get("_table")

# ---- Aggregate queries ----
? ""
? "=== Department Statistics ==="
py_exec("
stats = cur.execute('''
    SELECT department,
           COUNT(*) as cnt,
           ROUND(AVG(salary), 0) as avg_sal,
           MIN(salary) as min_sal,
           MAX(salary) as max_sal
    FROM employees
    GROUP BY department
    ORDER BY avg_sal DESC
''').fetchall()

_stats_lines = []
for s in stats:
    _stats_lines.append(s[0].ljust(12) + ' | ' + str(s[1]) + ' employees | avg $' + str(int(s[2])) + ' | range $' + str(int(s[3])) + '-$' + str(int(s[4])))
_stats_table = chr(10).join(_stats_lines)
")
? py_get("_stats_table")

# ---- Filter ----
? ""
? "=== Engineers earning > $90k ==="
py_exec("
top = cur.execute('''
    SELECT name, salary FROM employees
    WHERE department = 'Engineering' AND salary > 90000
    ORDER BY salary DESC
''').fetchall()

_top_lines = []
for t in top:
    _top_lines.append('  ' + t[0] + ': $' + str(int(t[1])))
_top_table = chr(10).join(_top_lines)
")
? py_get("_top_table")

# ---- Update ----
? ""
? "=== Give 10% raise to Sales ==="
py_exec("
cur.execute('UPDATE employees SET salary = salary * 1.10 WHERE department = ?', ('Sales',))
conn.commit()

updated = cur.execute('SELECT name, salary FROM employees WHERE department = ? ORDER BY name', ('Sales',)).fetchall()
_upd_lines = []
for u in updated:
    _upd_lines.append('  ' + u[0] + ': $' + str(int(u[1])))
_upd_table = chr(10).join(_upd_lines)
_upd_count = str(len(updated))
")
? py_get("_upd_count") + " rows updated"
? py_get("_upd_table")

# ---- Delete ----
? ""
? "=== Remove employees hired before 2018 ==="
py_exec("
cur.execute('DELETE FROM employees WHERE hire_year < 2018')
conn.commit()
_del_count = str(cur.rowcount)
_remaining = str(cur.execute('SELECT COUNT(*) FROM employees').fetchone()[0])
")
? py_get("_del_count") + " removed, " + py_get("_remaining") + " remaining"

# ---- Cleanup ----
py_exec("
conn.close()
import os
os.remove(db_path)
")
? ""
? "Cleaned up " + cDB
