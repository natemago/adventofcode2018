def load_input(filename):
    points = []
    with open(filename) as f:
        for line in f:
            line = line.strip()
            if line:
                points.append([int(n) for n in line.split(',')])
    return points

def dist(p1, p2=None):
    p2 = p2 or [0,0,0,0]
    d = 0
    for i in range(0, len(p1)):
        d += abs(p1[i] - p2[i])
    return d

def get_within(point, r, points):
    result = []
    for p in points:
        if p != point and dist(p, point) <= r:
            result.append(p)
    return result

def dbscan(points, r):
    c = 0
    label = {}
    noise = set()
    for p in points:
        if label.get(tuple(p)):
            continue
        seed = get_within(p, r, points)
        if len(seed) < 1:
            noise.add(tuple(p))
        c = c + 1
        label[tuple(p)] = c
        while len(seed):
            n = seed.pop()
            if tuple(n) in noise:
                label[tuple(n)] = c
            if label.get(tuple(n)):
                continue
            label[tuple(n)] = c

            N = get_within(n, r, points)
            if len(N) >= 1:
                for k in N:
                    if k not in seed:
                        seed.append(k)
    
    return c, len(noise)


print (dbscan(load_input("input"), 3))


