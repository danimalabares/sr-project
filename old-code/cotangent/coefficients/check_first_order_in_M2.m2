R = QQ[x_1..x_8]

f1  = x_6*x_7*x_8
f2  = x_4*x_6*x_8
f3  = x_3*x_7*x_8
f4  = x_3*x_5*x_7
f5  = x_3*x_4*x_8
f6  = x_2*x_7*x_8
f7  = x_2*x_5*x_7
f8  = x_2*x_5*x_6
f9  = x_2*x_4*x_7
f10 = x_2*x_4*x_6
f11 = x_1*x_4*x_6
f12 = x_1*x_4*x_5
f13 = x_1*x_3*x_8
f14 = x_1*x_3*x_6
f15 = x_1*x_3*x_5
f16 = x_1*x_2*x_5

I = ideal(f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16)
f = gens I

g1  = 1403*x_1^2*x_5 - 1417*x_1*x_5*x_6 - 6417*x_1*x_5*x_7
g2  = 0_R
g3  = 0_R
g4  = 0_R
g5  = 4225*x_2*x_5^2
g6  = 0_R
g7  = 0_R
g8  = 0_R
g9  = 3849*x_1*x_3^2 + 8966*x_1*x_3*x_4
g10 = 0_R
g11 = 0_R
g12 = -4457*x_4^2*x_8
g13 = 0_R
g14 = 0_R
g15 = 0_R
g16 = -4457*x_2*x_4*x_8

g = matrix{{g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,g15,g16}}

s = syz f
phi = g * s
rem = phi % gens gb I

print("number of M2 syzygy generators = " | toString numColumns s)
print("remainder of g * syz(gens I) modulo I =")
print(rem)

if rem == 0 then (
    print("PASS: the chosen g_i define a first-order deformation.")
) else (
    error("FAIL: some syzygy image is not in I.")
)
