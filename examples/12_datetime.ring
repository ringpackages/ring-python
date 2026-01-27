/*
    12 - Date & Time
    Use Python's datetime module from Ring.
*/

load "python.ring"

py_init()

# Current date and time
py_exec("
from datetime import datetime, timedelta

now = datetime.now()
_now_str = now.strftime('%Y-%m-%d %H:%M:%S')
_date = now.strftime('%A, %B %d, %Y')
_time = now.strftime('%I:%M %p')
")

? "=== Current Date & Time ==="
? "Timestamp: " + py_get("_now_str")
? "Date:      " + py_get("_date")
? "Time:      " + py_get("_time")

# Date arithmetic
? ""
? "=== Date Arithmetic ==="
py_exec("
today = datetime.now()
future = today + timedelta(days=30)
past   = today - timedelta(days=90)

_future = future.strftime('%Y-%m-%d')
_past   = past.strftime('%Y-%m-%d')

# Days until new year
ny = datetime(today.year + 1, 1, 1)
_days_to_ny = (ny - today).days
")

? "30 days from now:  " + py_get("_future")
? "90 days ago:       " + py_get("_past")
? "Days to new year:  " + py_get("_days_to_ny")

# Parsing dates
? ""
? "=== Parsing Dates ==="
py_exec("
dates = ['2024-01-15', '2023-06-30', '2025-12-25']
parsed = []
for d in dates:
    dt = datetime.strptime(d, '%Y-%m-%d')
    parsed.append({
        'input': d,
        'day_name': dt.strftime('%A'),
        'day_of_year': dt.timetuple().tm_yday,
    })
")

parsed = py_get("parsed")
for row in parsed
    if islist(row)
        input = "" day = "" doy = ""
        for pair in row
            if islist(pair) and len(pair) = 2
                if pair[1] = "input"       input = pair[2] ok
                if pair[1] = "day_name"    day = pair[2] ok
                if pair[1] = "day_of_year" doy = pair[2] ok
            ok
        next
        ? input + " → " + day + " (day " + doy + ")"
    ok
next
