import pickle
from sage.interfaces.singular import singular

PRIME = 32003
K = GF(PRIME)

Rff = PolynomialRing(K, ['x1','x2','x3','x4','x5','x6','x7','x8'])
x1,x2,x3,x4,x5,x6,x7,x8 = Rff.gens()

with open("../part-1.pkl", "rb") as f:
    data = pickle.load(f)

R = data["R"]
syz = data["syz"]

singular.eval("ring rr = 32003,(x1,x2,x3,x4,x5,x6,x7,x8),dp;")

def to_singular(p):
    p = R(p)
    if p == 0:
        return "0"
    return str(p)

gens = []
for r in range(syz.nrows()):
    entries = [to_singular(syz[r,j]) for j in range(syz.ncols())]
    gens.append("[" + ",".join(entries) + "]")

singular.eval("module M = " + ",\n".join(gens) + ";")
singular.eval("module M2 = syz(M);")

nrows = int(singular.eval("nrows(M2);"))
ncols = int(singular.eval("ncols(M2);"))

print("M2 size =", nrows, "x", ncols)

entries = {}
for i in range(1, nrows + 1):
    for j in range(1, ncols + 1):
        s = singular.eval("M2[%d,%d];" % (i,j)).strip()
        s = s.replace("\n", "")
        if s != "0":
            entries[(i-1,j-1)] = Rff(s)

M2sage = matrix(Rff, nrows, ncols, entries, sparse=True)

# Convert original syzygy matrix to GF(32003)
syz_ff = matrix(
    Rff,
    syz.nrows(),
    syz.ncols(),
    lambda i,j: Rff(str(R(syz[i,j])))
)

print("check syz^T * M2 = 0:",
      (syz_ff.transpose() * M2sage).is_zero())

data_out = {
    "M2": M2sage,
    "syz_ff": syz_ff,
}

save(data_out, "cache/second_syzygies.sobj")
print("Wrote cache/second_syzygies.sobj")
