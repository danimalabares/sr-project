# Analyze the zero-locus Z of the 27 candidate quadrics.

import random

load("cache/obstruction_quadrics_ff32003.sage")

K = GF(32003)
gens = P.gens()
nvars = len(gens)

print()
print("Analyzing Z = V(quadrics) in A^%d" % nvars)
print("number of quadrics =", len(quadrics))
print()

def vars_in_poly(q):
    out = set()
    for e, c in q.dict().items():
        if c == 0:
            continue
        for i, a in enumerate(e):
            if a != 0:
                out.add(i)
    return out

# ------------------------------------------------------------
# Variable usage
# ------------------------------------------------------------

used = sorted(set().union(*[vars_in_poly(q) for q in quadrics]))
unused = [i for i in range(nvars) if i not in used]

print("used variables =", len(used), used)
print("unused/free variables =", len(unused), unused)
print()

# ------------------------------------------------------------
# Connected components of variable interaction graph
# ------------------------------------------------------------

parent = list(range(nvars))

def find(a):
    while parent[a] != a:
        parent[a] = parent[parent[a]]
        a = parent[a]
    return a

def union(a, b):
    ra, rb = find(a), find(b)
    if ra != rb:
        parent[rb] = ra

for q in quadrics:
    vs = sorted(vars_in_poly(q))
    if len(vs) >= 2:
        for v in vs[1:]:
            union(vs[0], v)

blocks = {}
for v in used:
    blocks.setdefault(find(v), []).append(v)

blocks = sorted([sorted(b) for b in blocks.values()],
                key=lambda b: (len(b), b))

print("variable blocks:")
for i, b in enumerate(blocks, 1):
    print(" block %d: size %d:" % (i, len(b)), b)
print()

# ------------------------------------------------------------
# Quadrics by block
# ------------------------------------------------------------

block_quadrics = []

for b in blocks:
    bs = set(b)
    qs = []
    for q in quadrics:
        if vars_in_poly(q) <= bs:
            qs.append(q)
    block_quadrics.append(qs)

for i, (b, qs) in enumerate(zip(blocks, block_quadrics), 1):
    print("block %d has %d quadrics" % (i, len(qs)))
print()

# ------------------------------------------------------------
# Compute block dimensions
# ------------------------------------------------------------

block_dims = []

for i, (b, qs) in enumerate(zip(blocks, block_quadrics), 1):
    names = ["y%d" % j for j in b]
    Rb = PolynomialRing(K, names)
    images = []
    for j in range(nvars):
        if j in b:
            images.append(Rb.gen(b.index(j)))
        else:
            images.append(Rb(0))

    phi = P.hom(images, Rb)
    qs_b = [phi(q) for q in qs]
    Jb = Rb.ideal(qs_b)

    print("Computing dimension of block", i, "...")
    try:
        d = Jb.dimension()
        block_dims.append(d)
        print(" block", i, "dimension =", d)
    except Exception as e:
        block_dims.append(None)
        print(" block", i, "dimension failed:", e)
    print()

if all(d is not None for d in block_dims):
    full_dim = len(unused) + sum(block_dims)
    print("Predicted full dimension of Z =",
          len(unused), "+", sum(block_dims), "=", full_dim)
print()

# ------------------------------------------------------------
# Find sparse nonzero points on Z
# ------------------------------------------------------------

def eval_quadrics(vec):
    subs = {gens[i]: K(vec[i]) for i in range(nvars)}
    return [q.subs(subs) for q in quadrics]

def is_solution(vec):
    return all(v == 0 for v in eval_quadrics(vec))

samples = []

# deterministic samples: coordinate axes
for i in range(nvars):
    v = [K(0)] * nvars
    v[i] = K(1)
    if is_solution(v):
        samples.append(v)

print("coordinate-axis solutions =", len(samples))

# random sparse samples
random.seed(int(1))

for support_size in range(2, 8):
    found = 0
    tries = 2000

    for _ in range(tries):
        supp = random.sample(range(nvars), support_size)
        v = [K(0)] * nvars
        for j in supp:
            v[j] = K(random.randrange(int(1), int(32003)))

        if is_solution(v):
            samples.append(v)
            found += 1
            if found <= 5:
                print("sparse solution support size",
                      support_size, "support =", supp)

        if found >= 20:
            break

    print("support size", support_size,
          "found", found, "solutions in", tries, "tries")

print()
print("total stored sample points =", len(samples))

save(samples, "cache/sample_points_on_Z.sobj")
print("Wrote cache/sample_points_on_Z.sobj")
