/*
    22 - Pandas
    Data analysis with DataFrames.

    Requirements: pip install pandas
*/

load "python.ring"

py_init()
py_exec("import pandas as pd")

# ---- Create DataFrame ----
? "=== Create DataFrame ==="
py_exec("
df = pd.DataFrame({
    'name':   ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve'],
    'age':    [28, 34, 22, 45, 31],
    'city':   ['NYC', 'LA', 'NYC', 'Chicago', 'LA'],
    'salary': [75000, 82000, 55000, 95000, 70000],
})
_repr = df.to_string()
_shape = str(df.shape)
")
? py_get("_repr")
? ""
? "Shape: " + py_get("_shape")

# ---- Basic info ----
? ""
? "=== Column Types ==="
py_exec("_dtypes = df.dtypes.to_string()")
? py_get("_dtypes")

# ---- Statistics ----
? ""
? "=== Describe ==="
py_exec("_desc = df.describe().to_string()")
? py_get("_desc")

# ---- Filtering ----
? ""
? "=== Filter: salary > 70000 ==="
py_exec("
high_salary = df[df['salary'] > 70000]
_filtered = high_salary.to_string()
")
? py_get("_filtered")

# ---- Group by ----
? ""
? "=== Group by City ==="
py_exec("
grouped = df.groupby('city').agg({
    'salary': ['mean', 'count'],
    'age': 'mean'
}).round(0)
_grouped = grouped.to_string()
")
? py_get("_grouped")

# ---- Sorting ----
? ""
? "=== Sort by Age ==="
py_exec("_sorted = df.sort_values('age').to_string()")
? py_get("_sorted")

# ---- New column ----
? ""
? "=== Add Tax Column (30%) ==="
py_exec("
df['tax'] = (df['salary'] * 0.30).astype(int)
df['net']  = df['salary'] - df['tax']
_final = df.to_string()
")
? py_get("_final")

# ---- Export to CSV string ----
? ""
? "=== CSV Output ==="
py_exec("_csv = df.to_csv(index=False)")
? py_get("_csv")
