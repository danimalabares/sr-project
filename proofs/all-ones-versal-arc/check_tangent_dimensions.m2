-- Exact characteristic-zero dimensions used in the Bianchi discussion.
-- Cotangent transitivity for A=S/I identifies, for i>=2,
--
--   T^i_(A/QQ) = Ext^(i-1)_A(I/I^2,A).

S = QQ[x1,x2,x3,x4,x5,x6,x7,x8];
I = ideal(
  x6*x7*x8, x4*x6*x8, x3*x7*x8, x3*x5*x7,
  x3*x4*x8, x2*x7*x8, x2*x5*x7, x2*x5*x6,
  x2*x4*x7, x2*x4*x6, x1*x4*x6, x1*x4*x5,
  x1*x3*x8, x1*x3*x6, x1*x3*x5, x1*x2*x5);
A = S/I;
conormalOverS = I/I^2;
conormal = coker sub(presentation conormalOverS,A);
E1 = prune Ext^1(conormal,A^1);
E2 = prune Ext^2(conormal,A^1);
t2Dimension = numColumns basis(0,E1);
t3Dimension = numColumns basis(0,E2);
assert(t2Dimension == 27);
assert(t3Dimension == 24);

certificatePath =
  "proofs/all-ones-versal-arc/certificates/tangent_dimensions_QQ.txt";
out = certificatePath;
out << "" << flush;
out << "field=QQ" << endl;
out << "T2_degree_zero_dimension=27" << endl;
out << "T3_degree_zero_dimension=24" << endl << flush;
print("T2 degree-zero dimension=27");
print("T3 degree-zero dimension=24");
print("certificate=" | certificatePath);
exit 0;
