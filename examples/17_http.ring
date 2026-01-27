/*
    17 - HTTP Requests
    Use Python's urllib to make HTTP requests.
    (No external dependencies required)
*/

load "python.ring"

py_init()

# ---- Simple GET request ----
? "=== GET Request ==="
py_exec("
import urllib.request
import json

url = 'https://httpbin.org/get'
req = urllib.request.Request(url, headers={'User-Agent': 'ring-python/0.1'})
with urllib.request.urlopen(req, timeout=10) as resp:
    _status = resp.status
    _body = json.loads(resp.read().decode())
    _origin = _body.get('origin', 'unknown')
    _ua = _body.get('headers', {}).get('User-Agent', 'unknown')
")

? "URL:        https://httpbin.org/get"
? "Status:     " + py_get("_status")
? "Origin IP:  " + py_get("_origin")
? "User-Agent: " + py_get("_ua")

# ---- POST request ----
? ""
? "=== POST Request ==="
py_exec("
import urllib.request
import json

data = json.dumps({'message': 'Hello from Ring!', 'number': 42}).encode()
req = urllib.request.Request(
    'https://httpbin.org/post',
    data=data,
    headers={'Content-Type': 'application/json', 'User-Agent': 'ring-python/0.1'},
    method='POST'
)
with urllib.request.urlopen(req, timeout=10) as resp:
    _post_status = resp.status
    body = json.loads(resp.read().decode())
    _echoed = body.get('data', '')
")

? "Status:  " + py_get("_post_status")
? "Echoed:  " + py_get("_echoed")

# ---- Fetch JSON API ----
? ""
? "=== JSON API ==="
py_exec("
url = 'https://httpbin.org/uuid'
with urllib.request.urlopen(url, timeout=10) as resp:
    _uuid = json.loads(resp.read().decode())['uuid']
")
? "Random UUID: " + py_get("_uuid")
