import re
from PIL import Image

def load_input(fn):
    with open(fn) as f:
        return [parse(line.strip()) for line in f]

def parse(line):
    m = re.match(r"#(?P<id>\d+) @ (?P<x>\d+),(?P<y>\d+): (?P<width>\d+)x(?P<height>\d+)", line)
    if not m:
        raise Exception("Faulty line: %s" % line)
    id = int(m.group("id"))
    x = int(m.group("x"))
    y = int(m.group("y"))
    width = int(m.group("width"))
    height = int(m.group("height"))
    return (id, x, y, width, height)

def overlay(mx, id, x, y, w, h):
    for i in range(x, x+w):
        for j in range(y, y+h):
            mx[j][i] += id

m = [[0 for _ in range(0, 1000)] for _ in range(0, 1000)]

for inst in load_input("input"):
    overlay(m, *inst)

img = Image.new('RGB', (1000, 1000))

for i in range(0, len(m)):
    for j in range(0, len(m[i])):
        d = m[i][j]
        img.putpixel((j, i), d)

img.save('visualization.png')