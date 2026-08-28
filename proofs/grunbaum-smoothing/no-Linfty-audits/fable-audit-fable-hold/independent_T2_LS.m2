-- Third-angle check: the classical Lichtenbaum-Schlessinger T^2(A)_0,
-- computed with Macaulay2 core only (no VersalDeformations, no
-- DGAlgebras, no Tate data).  Expected: 27, matching the packages'
-- T^2 and the independent Tate-cochain H^2_0 of independent_exactness.m2.
S = QQ[x_1..x_8];
I = ideal(x_6*x_7*x_8, x_4*x_6*x_8, x_3*x_7*x_8, x_3*x_5*x_7, x_3*x_4*x_8,
  x_2*x_7*x_8, x_2*x_5*x_7, x_2*x_5*x_6, x_2*x_4*x_7, x_2*x_4*x_6,
  x_1*x_4*x_6, x_1*x_4*x_5, x_1*x_3*x_8, x_1*x_3*x_6, x_1*x_3*x_5,
  x_1*x_2*x_5);
F0 = gens I;
A = S/I;
R0 = gens ker F0;
m = flatten entries F0;
F = source F0;   -- S(-3)^16
kosz = matrix apply(16, r -> flatten apply(16, i -> apply(toList(i+1..15), j -> (
  if r == j then m#i else if r == i then -(m#j) else 0_S))));
koszMap = map(F, , kosz);
R0map = map(F, source R0, R0);
-- Koszul relations are syzygies:
assert(F0*kosz == 0);
N = subquotient(R0, koszMap);           -- R / R_0  as an S-module
Fbar = coker koszMap;                 -- F / R_0
iota = inducedMap(Fbar, N);
HN = Hom(N, A^1);
HF = Hom(Fbar, A^1);
restriction = Hom(iota, A^1);
T2LS = coker restriction;
t2 = numColumns basis(0, T2LS);
assert(t2 == 27);
print("T2_LS_degree_zero_dimension=" | toString t2);
exit 0
