/*
    23 - Matplotlib
    Generate charts and save them as image files.

    Requirements: pip install matplotlib
*/

load "python.ring"

py_init()

# ---- Bar chart ----
? "=== Bar Chart ==="
py_exec("
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

languages = ['Ring', 'Python', 'Rust', 'Go', 'Java']
popularity = [15, 95, 45, 55, 80]

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.bar(languages, popularity, color=['#2D54CB', '#3776AB', '#DEA584', '#00ADD8', '#ED8B00'])
ax.set_title('Programming Language Popularity', fontsize=14, fontweight='bold')
ax.set_ylabel('Popularity Score')
ax.set_ylim(0, 100)

for bar, val in zip(bars, popularity):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2, str(val), ha='center', fontsize=11)

plt.tight_layout()
plt.savefig('chart_bar.png', dpi=100)
plt.close()
")
? "Saved: chart_bar.png"

# ---- Line chart ----
? ""
? "=== Line Chart ==="
py_exec("
import numpy as np

x = np.linspace(0, 2 * np.pi, 100)
fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(x, np.sin(x), label='sin(x)', linewidth=2)
ax.plot(x, np.cos(x), label='cos(x)', linewidth=2)
ax.set_title('Trigonometric Functions', fontsize=14, fontweight='bold')
ax.set_xlabel('x (radians)')
ax.set_ylabel('y')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('chart_line.png', dpi=100)
plt.close()
")
? "Saved: chart_line.png"

# ---- Pie chart ----
? ""
? "=== Pie Chart ==="
py_exec("
labels = ['Python', 'JavaScript', 'Java', 'C/C++', 'Other']
sizes = [35, 25, 18, 12, 10]
colors = ['#3776AB', '#F7DF1E', '#ED8B00', '#00599C', '#AAAAAA']

fig, ax = plt.subplots(figsize=(7, 7))
ax.pie(sizes, labels=labels, colors=colors, autopct='%1.0f%%', startangle=90, textprops={'fontsize': 12})
ax.set_title('Language Market Share', fontsize=14, fontweight='bold')

plt.tight_layout()
plt.savefig('chart_pie.png', dpi=100)
plt.close()
")
? "Saved: chart_pie.png"

# Cleanup
py_exec("
import os
for f in ['chart_bar.png', 'chart_line.png', 'chart_pie.png']:
    if os.path.exists(f):
        os.remove(f)
")
? ""
? "Cleaned up chart files."
