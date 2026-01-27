/*
    20 - yt-dlp: Real-World Example
    Demonstrates using the yt-dlp Python library from Ring.
    
    Requirements: pip install yt-dlp
*/

load "python.ring"

py_init()

? "=== yt-dlp via ring-python ==="
? ""

# Import yt-dlp
yt_dlp = py_import("yt_dlp")
? "yt-dlp module loaded successfully"

# Get yt-dlp version
py_exec("import yt_dlp; _ver = yt_dlp.version.__version__")
? "yt-dlp version: " + py_get("_ver")
? ""

# Example video URL
video_url = "https://www.youtube.com/watch?v=kGmH-aUNZ8Y"

? "=== Extracting Video Info ==="
? "URL: " + video_url
? ""

# Configure yt-dlp options and extract info
py_exec("
import yt_dlp

ydl_opts = {
    'quiet': True,
    'no_warnings': True,
    'extract_flat': False,
}

with yt_dlp.YoutubeDL(ydl_opts) as ydl:
    info = ydl.extract_info('" + video_url + "', download=False)
")

info = py_get("info")

? "Video Information:"
? "----------------------------------------"

if islist(info)
    for item in info
        if islist(item) and len(item) = 2
            key = item[1]
            value = item[2]
            
            if key = "title"
                ? "Title: " + value
            but key = "uploader"
                ? "Uploader: " + value
            but key = "duration"
                ? "Duration: " + value + " seconds"
            but key = "view_count"
                ? "Views: " + value
            but key = "like_count"
                ? "Likes: " + value
            but key = "upload_date"
                ? "Upload Date: " + value
            but key = "description"
                if len(value) > 100
                    ? "Description: " + left(value, 100) + "..."
                else
                    ? "Description: " + value
                ok
            ok
        ok
    next
ok

? "----------------------------------------"
? ""

# Get available formats (first 10)
? "=== Available Formats ==="

py_exec("
formats = info.get('formats', [])
format_list = []
for f in formats[:10]:
    format_list.append({
        'format_id': f.get('format_id', 'N/A'),
        'ext': f.get('ext', 'N/A'),
        'resolution': f.get('resolution', 'N/A'),
        'filesize': f.get('filesize', 0) or 0,
        'vcodec': f.get('vcodec', 'none'),
        'acodec': f.get('acodec', 'none'),
    })
")

formats = py_get("format_list")

if islist(formats)
    ? "Format ID | Extension | Resolution | Size (MB) | Video | Audio"
    ? "----------|-----------|------------|-----------|-------|------"
    
    for fmt in formats
        if islist(fmt)
            format_id = "" ext = "" resolution = ""
            filesize = 0  vcodec = "" acodec = ""
            
            for pair in fmt
                if islist(pair) and len(pair) = 2
                    k = pair[1]  v = pair[2]
                    if k = "format_id" format_id = v ok
                    if k = "ext"       ext = v ok
                    if k = "resolution" resolution = v ok
                    if k = "filesize"  filesize = v ok
                    if k = "vcodec"    vcodec = v ok
                    if k = "acodec"    acodec = v ok
                ok
            next
            
            size_mb = ""
            if filesize > 0
                size_mb = "" + (filesize / 1048576)
                if len(size_mb) > 6
                    size_mb = left(size_mb, 6)
                ok
            else
                size_mb = "N/A"
            ok
            
            if len(vcodec) > 6 vcodec = left(vcodec, 6) ok
            if len(acodec) > 6 acodec = left(acodec, 6) ok
            
            ? format_id + " | " + ext + " | " + resolution + " | " + size_mb + " | " + vcodec + " | " + acodec
        ok
    next
ok

? ""
? "=== Done ==="
