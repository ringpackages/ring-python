<div align="center">

# Ring Python

Use Python from your Ring applications.

[language-ring]: https://img.shields.io/badge/language-Ring-2D54CB.svg?style=for-the-badge&labelColor=414868
[build-status]: https://img.shields.io/github/actions/workflow/status/ysdragon/ring-python/main.yml?branch=master&label=build&style=for-the-badge&labelColor=414868&color=8c73cc
[last-commit]: https://img.shields.io/github/last-commit/ysdragon/ring-python?style=for-the-badge&labelColor=414868&color=8c73cc
[version]: https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Fraw.githubusercontent.com%2Fysdragon%2Fring-python%2Fmaster%2Fpackage.ring&search=%3Aversion\s*%3D\s*%22([^%22]%2B)%22&replace=%241&style=for-the-badge&label=version&labelColor=414868&color=7664C6
[license]: https://img.shields.io/github/license/ysdragon/ring-python?style=for-the-badge&label=License&labelColor=414868&color=8c73cc
[issues]: https://img.shields.io/github/issues/ysdragon/ring-python?color=8c73cc&style=for-the-badge&labelColor=414868

[![][language-ring]](https://ring-lang.github.io/)
[![][build-status]](https://github.com/ysdragon/ring-python/actions)
[![][last-commit]](https://github.com/ysdragon/ring-python/pulse)
[![][version]](#)
[![][license]](https://github.com/ysdragon/ring-python/blob/master/LICENSE)
[![][issues]](https://github.com/ysdragon/ring-python/issues)

</div>

Ring Python is a Ring library that provides Python bindings for the [Ring](https://ring-lang.github.io/) programming language, powered by [PyO3](https://pyo3.rs/). Call Python functions, import Python modules, exchange data between Ring and Python, and leverage the entire Python ecosystem from your Ring programs.

## Features

- **Full Python Embedding:** Initialize the Python interpreter and execute arbitrary Python code from Ring.
- **Two-Way Data Exchange:** Pass strings, numbers, lists, and dicts between Ring and Python seamlessly.
- **Module Import:** Import any installed Python package (`numpy`, `pandas`, `matplotlib`, etc.) and call its functions directly.
- **Object-Oriented API:** Clean Ring classes (`Python`, `PyObject`, `PyModule`, `PyList`, `PyDict`, `PyTuple`) wrapping the low-level functions.
- **Method Calls with kwargs:** Call Python functions and methods with positional args, keyword args, or both.
- **Cross-Platform:** Builds for Linux (glibc and musl), macOS, Windows, and FreeBSD.

## Getting Started

### Prerequisites

- **[Ring](https://ring-lang.github.io/download.html):** Version 1.25 or higher.
- **[Python](https://www.python.org/downloads/):** Version 3.7 or higher (development headers required on Linux).

### Installation

<details>
<summary>Click here for instructions on <img width="20" height="20" src="https://www.kernel.org/theme/images/logos/favicon.png" /> Linux</summary>

Install Python development headers:

*   **<img width="16" height="16" src="https://www.debian.org/favicon.ico" /> Debian/Ubuntu:** `sudo apt install python3-dev`
*   **<img width="16" height="16" src="https://archlinux.org/static/favicon.png" /> Arch Linux:** `sudo pacman -S python`
*   **<img width="16" height="16" src="https://fedoraproject.org/favicon.ico" /> Fedora:** `sudo dnf install python3-devel`
*   **<img width="16" height="16" src="https://www.alpinelinux.org/alpine-logo.ico" /> Alpine Linux:** `sudo apk add python3-dev`

</details>

<details>
<summary>Click here for instructions on <img width="20" height="20" src="https://www.freebsd.org/favicon.ico" /> FreeBSD</summary>

*   **FreeBSD:** `sudo pkg install python3`

</details>

<details>
<summary>Click here for instructions on <img width="20" height="20" src="https://developer.apple.com/favicon.ico" /> macOS</summary>

Install Python 3 via Homebrew:
```sh
brew install python3
```

</details>

<details>
<summary>Click here for instructions on <img width="20" height="20" src="https://blogs.windows.com/wp-content/uploads/prod/2022/09/cropped-Windows11IconTransparent512-32x32.png" /> Windows</summary>

Install Python 3 from [python.org](https://www.python.org/downloads/). Make sure "Add Python to PATH" is checked during installation.

</details>

**Install the library using RingPM:**
```sh
ringpm install ring-python from ysdragon
```

## Usage

### Low-Level API

Use the `py_*` functions directly for full control:

```ring
load "python.ring"

py_init()

# Execute Python code
py_exec("import math")

# Evaluate expressions
result = py_eval("2 ** 10")
? "2^10 = " + result    # 1024

# Call functions with arguments
? "sqrt(144) = " + py_call("math.sqrt", [144])    # 12

# Exchange variables
py_set("name", "Ring")
py_exec("greeting = f'Hello from {name}!'")
? py_get("greeting")    # Hello from Ring!
```

### Object-Oriented API

Use the Ring wrapper classes for a cleaner interface:

```ring
load "python.ring"

py = new Python()
? "Python " + py.version()

# Execute and evaluate
py.exec("import json")
result = py.eval("[x**2 for x in range(5)]")
? result    # [0, 1, 4, 9, 16]

# Work with Python modules
math = new PyModule("math")
? "pi = " + math.getattr("pi")
? "has sqrt: " + math.hasattr("sqrt")

# Python containers
mylist = new PyList([10, 20, 30])
? "List: " + mylist.str()
? "Length: " + mylist.len()

mydict = new PyDict([["name", "Ring"], ["year", 2016]])
? "Dict: " + mydict.str()
```

### Real-World Example: NumPy

```ring
load "python.ring"

py = new Python()
py.exec("import numpy as np")

# Create array and compute statistics
py.exec("
data = np.array([1, 2, 3, 4, 5])
_mean = str(np.mean(data))
_std  = str(np.std(data))
_dot  = str(np.dot(data, data))
")

? "Mean: " + py.getVar("_mean")
? "Std:  " + py.getVar("_std")
? "Dot:  " + py.getVar("_dot")
```

For more examples, see the [`examples/`](examples/) directory.

## API Reference

### Low-Level Functions

| Category | Functions |
|----------|-----------|
| **Core** | `py_init()`, `py_version()`, `py_exec()`, `py_eval()` |
| **Variables** | `py_set()`, `py_get()` |
| **Modules** | `py_import()` |
| **Calls** | `py_call()`, `py_call_method()` |
| **Objects** | `py_object()`, `py_value()`, `py_getattr()`, `py_hasattr()` |
| **Type Info** | `py_type()`, `py_isinstance()`, `py_repr()`, `py_str()`, `py_len()`, `py_dir()` |
| **Constants** | `py_none()`, `py_true()`, `py_false()` |
| **Containers** | `py_list()`, `py_dict()`, `py_tuple()` |

### Ring Classes

| Class | Description |
|-------|-------------|
| **Python** | Main class — `exec()`, `eval()`, `importModule()`, `callFunc()`, `callFuncArgs()`, `callFuncKwargs()`, `set()`, `getVar()`, `version()` |
| **PyObject** | Base wrapper — `getattr()`, `hasattr()`, `callMethod()`, `callMethodArgs()`, `callMethodKwargs()`, `isinstance()`, `type()`, `repr()`, `str()`, `len()`, `dir()`, `value()` |
| **PyModule** | Import wrapper — `init(name)` loads a Python module |
| **PyNone** | Python `None` |
| **PyBool** | Python `True`/`False` |
| **PyList** | Python list from Ring list |
| **PyDict** | Python dict from Ring key-value pairs |
| **PyTuple** | Python tuple from Ring list |
| **PyValue** | Convert any Ring value to Python object |

## Development

### Prerequisites

- **Rust:** Latest stable version with Cargo.
- **[Ring](https://github.com/ring-lang/ring):** Fully built Ring installation (required by `ring-lang-rs` for linking).
- **Python:** Version 3.7+ with development headers.

### Build Steps

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/ysdragon/ring-python.git
   cd ring-python
   ```

2. **Set the `RING` Environment Variable:**
   ```bash
   # Unix
   export RING=/path/to/ring

   # Windows (PowerShell)
   $env:RING = "X:\path\to\ring"
   ```

3. **Build the Rust Library:**
   ```sh
   cd src/rust_src
   cargo build --release
   ```

The compiled library will be in `src/rust_src/target/release/`.

## Resources

- [Python Documentation](https://docs.python.org/3/)
- [PyO3 — Rust bindings for Python](https://pyo3.rs/)
- [Ring Language](https://ring-lang.github.io/)

## Contributing

Contributions are welcome! If you have ideas for improvements or have found a bug, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file for details.
