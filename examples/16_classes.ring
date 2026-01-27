/*
    16 - Python Classes from Ring
    Define Python classes and use them from Ring.
*/

load "python.ring"

py_init()

# Define a Python class
py_exec("
class Calculator:
    def __init__(self):
        self.history = []

    def add(self, a, b):
        result = a + b
        self.history.append(f'{a} + {b} = {result}')
        return result

    def multiply(self, a, b):
        result = a * b
        self.history.append(f'{a} * {b} = {result}')
        return result

    def get_history(self):
        return self.history

    def clear(self):
        self.history.clear()
")

# Create an instance
py_exec("calc = Calculator()")
calc = py_get("calc")

# Use it
? "=== Calculator ==="
py_exec("r1 = calc.add(10, 20)")
? "10 + 20 = " + py_get("r1")

py_exec("r2 = calc.multiply(6, 7)")
? "6 * 7 = " + py_get("r2")

py_exec("r3 = calc.add(100, 200)")
? "100 + 200 = " + py_get("r3")

? ""
? "History:"
py_exec("_hist = calc.get_history()")
hist = py_get("_hist")
for entry in hist
    ? "  " + entry
next

# ---- Another class: a simple Stack ----
? ""
? "=== Stack ==="
py_exec("
class Stack:
    def __init__(self):
        self._items = []

    def push(self, item):
        self._items.append(item)

    def pop(self):
        return self._items.pop() if self._items else None

    def peek(self):
        return self._items[-1] if self._items else None

    def size(self):
        return len(self._items)

    def __repr__(self):
        return f'Stack({self._items})'
")

py_exec("
s = Stack()
s.push('Ring')
s.push('Python')
s.push('Rust')
_repr = repr(s)
_size = s.size()
_top = s.peek()
_popped = s.pop()
_after = repr(s)
")

? "Stack:      " + py_get("_repr")
? "Size:       " + py_get("_size")
? "Peek:       " + py_get("_top")
? "Pop:        " + py_get("_popped")
? "After pop:  " + py_get("_after")
