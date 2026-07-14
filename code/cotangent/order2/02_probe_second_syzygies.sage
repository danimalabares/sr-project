import pickle

with open("../part-1.pkl", "rb") as f:
    data = pickle.load(f)

R = data["R"]
I = data["I"]
syz = data["syz"]

print("R =", R)
print("I gens =", len(I.gens()))
print("syz type =", type(syz))
print("syz size =", syz.nrows(), "x", syz.ncols())
print()

def tryit(name, func):
    print("Trying:", name)
    try:
        out = func()
        print("  success")
        print("  type =", type(out))
        if hasattr(out, "nrows"):
            print("  size =", out.nrows(), "x", out.ncols())
        else:
            print("  repr =", out)
    except Exception as e:
        print("  failed:", e)
    print()

tryit("syz.syzygy_module()",
      lambda: syz.syzygy_module())

tryit("syz.left_kernel()",
      lambda: syz.left_kernel())

tryit("syz.right_kernel()",
      lambda: syz.right_kernel())

tryit("syz.row_module().syzygy_module()",
      lambda: syz.row_module().syzygy_module())

tryit("syz.transpose().syzygy_module()",
      lambda: syz.transpose().syzygy_module())
