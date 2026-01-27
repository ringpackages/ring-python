/*
    21 - NumPy
    Array computing, linear algebra, and statistics with NumPy.

    Requirements: pip install numpy
*/

load "python.ring"

py_init()
py_exec("import numpy as np")

# ---- Array creation ----
? "=== Array Creation ==="
py_exec("
a = np.array([1, 2, 3, 4, 5])
_repr = repr(a)
_shape = str(a.shape)
_dtype = str(a.dtype)
")
? "Array:  " + py_get("_repr")
? "Shape:  " + py_get("_shape")
? "Dtype:  " + py_get("_dtype")

# Special arrays
py_exec("
_zeros = repr(np.zeros((2, 3)))
_ones  = repr(np.ones((2, 3)))
_range = repr(np.arange(0, 1, 0.2))
_lin   = repr(np.linspace(0, 1, 5))
")
? ""
? "zeros(2,3):       " + py_get("_zeros")
? "ones(2,3):        " + py_get("_ones")
? "arange(0,1,0.2):  " + py_get("_range")
? "linspace(0,1,5):  " + py_get("_lin")

# ---- Arithmetic ----
? ""
? "=== Element-wise Operations ==="
py_exec("
a = np.array([10, 20, 30, 40, 50])
b = np.array([1, 2, 3, 4, 5])
_add  = repr(a + b)
_mul  = repr(a * b)
_sqrt = repr(np.sqrt(a))
_sum  = str(np.sum(a))
_mean = str(np.mean(a))
")
? "a + b:     " + py_get("_add")
? "a * b:     " + py_get("_mul")
? "sqrt(a):   " + py_get("_sqrt")
? "sum(a):    " + py_get("_sum")
? "mean(a):   " + py_get("_mean")

# ---- Matrix operations ----
? ""
? "=== Matrix Operations ==="
py_exec("
m = np.array([[1, 2], [3, 4]])
_det = str(round(np.linalg.det(m), 2))
_inv = repr(np.linalg.inv(m))
_T   = repr(m.T)
_dot = repr(np.dot(m, m))
")
? "Matrix:      " + py_eval("repr(m)")
? "Determinant: " + py_get("_det")
? "Inverse:     " + py_get("_inv")
? "Transpose:   " + py_get("_T")
? "m @ m:       " + py_get("_dot")

# ---- Statistics ----
? ""
? "=== Statistics ==="
py_exec("
data = np.random.seed(42)
data = np.random.normal(100, 15, 1000)
stats = {
    'mean':   round(np.mean(data), 2),
    'std':    round(np.std(data), 2),
    'min':    round(np.min(data), 2),
    'max':    round(np.max(data), 2),
    'median': round(np.median(data), 2),
}
")
stats = py_get("stats")
? "1000 samples from Normal(mean=100, std=15):"
for pair in stats
    if islist(pair) and len(pair) = 2
        ? "  " + pair[1] + ": " + pair[2]
    ok
next

# ---- Boolean indexing ----
? ""
? "=== Filtering ==="
py_exec("
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6, 5])
_gt4 = repr(arr[arr > 4])
_even = repr(arr[arr % 2 == 0])
")
? "Array:       " + py_eval("repr(arr)")
? "Values > 4:  " + py_get("_gt4")
? "Even values: " + py_get("_even")
