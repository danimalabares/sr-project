import pickle
from sage.interfaces.singular import singular

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

cmd = "module M = " + ",\n".join(gens) + ";"
singular.eval(cmd)

print("first syzygy module M")
for c in ["nrows(M)", "ncols(M)", "size(M)"]:
    try:
        print(c, "=", singular.eval(c + ";"))
    except Exception as e:
        print(c, "failed:", e)

singular.eval("module M2 = syz(M);")

print()
print("second syzygy module M2")
for c in ["nrows(M2)", "ncols(M2)", "size(M2)"]:
    try:
        print(c, "=", singular.eval(c + ";"))
    except Exception as e:
        print(c, "failed:", e)

print()
print("M2 =")
print(singular.eval("print(M2);"))
