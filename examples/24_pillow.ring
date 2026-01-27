/*
    24 - Pillow (PIL)
    Image creation and manipulation.

    Requirements: pip install pillow
*/

load "python.ring"

py_init()

# ---- Create an image from scratch ----
? "=== Create Image ==="
py_exec("
from PIL import Image, ImageDraw, ImageFont

# Create a 400x200 image with a gradient
img = Image.new('RGB', (400, 200))
pixels = img.load()
for y in range(200):
    for x in range(400):
        r = int(255 * x / 400)
        g = int(255 * y / 200)
        b = 128
        pixels[x, y] = (r, g, b)

# Draw some text and shapes
draw = ImageDraw.Draw(img)
draw.rectangle([20, 20, 380, 180], outline='white', width=2)
draw.text((140, 80), 'ring-python', fill='white')
draw.ellipse([160, 50, 240, 130], outline='yellow', width=2)

img.save('example_image.png')
_size = f'{img.size[0]}x{img.size[1]}'
_mode = img.mode
")
? "Created: example_image.png"
? "Size: " + py_get("_size")
? "Mode: " + py_get("_mode")

# ---- Image info and manipulation ----
? ""
? "=== Image Manipulation ==="
py_exec("
# Resize
small = img.resize((200, 100))
small.save('example_small.png')
_small_size = f'{small.size[0]}x{small.size[1]}'

# Rotate
rotated = img.rotate(45, expand=True)
rotated.save('example_rotated.png')
_rot_size = f'{rotated.size[0]}x{rotated.size[1]}'

# Grayscale
gray = img.convert('L')
gray.save('example_gray.png')
_gray_mode = gray.mode

# Flip
flipped = img.transpose(Image.FLIP_LEFT_RIGHT)
flipped.save('example_flipped.png')
")
? "Resized:  " + py_get("_small_size")
? "Rotated:  " + py_get("_rot_size")
? "Gray mode: " + py_get("_gray_mode")
? "Flipped:  saved"

# ---- Pixel statistics ----
? ""
? "=== Pixel Statistics ==="
py_exec("
import numpy as np
arr = np.array(img)
_shape = str(arr.shape)
_mean_r = str(round(arr[:,:,0].mean(), 1))
_mean_g = str(round(arr[:,:,1].mean(), 1))
_mean_b = str(round(arr[:,:,2].mean(), 1))
")
? "Array shape: " + py_get("_shape")
? "Mean R: " + py_get("_mean_r")
? "Mean G: " + py_get("_mean_g")
? "Mean B: " + py_get("_mean_b")

# Cleanup
py_exec("
import os
for f in ['example_image.png', 'example_small.png', 'example_rotated.png', 'example_gray.png', 'example_flipped.png']:
    if os.path.exists(f):
        os.remove(f)
")
? ""
? "Cleaned up image files."
