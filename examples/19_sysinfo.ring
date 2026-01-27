/*
    19 - System Information
    Gather system info using Python's platform, os, and sys modules.
*/

load "python.ring"

py_init()

py_exec("
import platform
import sys
import os

info = {
    'system':     platform.system(),
    'release':    platform.release(),
    'machine':    platform.machine(),
    'processor':  platform.processor() or 'N/A',
    'python_ver': platform.python_version(),
    'node':       platform.node(),
    'py_impl':    platform.python_implementation(),
    'py_path':    sys.executable,
    'cpu_count':  os.cpu_count(),
    'cwd':        os.getcwd(),
    'pid':        os.getpid(),
}
")

info = py_get("info")

? "=== System Information ==="
for pair in info
    if islist(pair) and len(pair) = 2
        ? "  " + pair[1] + ": " + pair[2]
    ok
next

# Environment variables
? ""
? "=== Environment (first 10) ==="
py_exec("
_env = [(k, v[:60]) for k, v in sorted(os.environ.items())[:10]]
")
env = py_get("_env")
for pair in env
    if islist(pair) and len(pair) = 2
        ? "  " + pair[1] + " = " + pair[2]
    ok
next
