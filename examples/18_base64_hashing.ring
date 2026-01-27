/*
    18 - Base64 & Hashing
    Use Python's base64 and hashlib modules.
*/

load "python.ring"

py_init()

# ---- Base64 ----
? "=== Base64 ==="
py_set("original", "Hello, Ring + Python!")
py_exec("
import base64
_encoded = base64.b64encode(original.encode()).decode()
_decoded = base64.b64decode(_encoded).decode()
")
? "Original: " + py_get("original")
? "Encoded:  " + py_get("_encoded")
? "Decoded:  " + py_get("_decoded")

# URL-safe base64
py_exec("
_url_encoded = base64.urlsafe_b64encode(b'data with special chars: +/=').decode()
")
? ""
? "URL-safe: " + py_get("_url_encoded")

# ---- Hashing ----
? ""
? "=== Hashing ==="
py_set("message", "ring-python")
py_exec("
import hashlib
_md5    = hashlib.md5(message.encode()).hexdigest()
_sha1   = hashlib.sha1(message.encode()).hexdigest()
_sha256 = hashlib.sha256(message.encode()).hexdigest()
_sha512 = hashlib.sha512(message.encode()).hexdigest()
")

? "Input:  " + py_get("message")
? "MD5:    " + py_get("_md5")
? "SHA1:   " + py_get("_sha1")
? "SHA256: " + py_get("_sha256")
? "SHA512: " + py_get("_sha512")

# ---- HMAC ----
? ""
? "=== HMAC ==="
py_exec("
import hmac
key = b'secret-key'
msg = b'ring-python'
_hmac = hmac.new(key, msg, hashlib.sha256).hexdigest()
")
? "HMAC-SHA256: " + py_get("_hmac")
