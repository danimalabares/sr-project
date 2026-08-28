-- Verify the relative/absolute tangent-space distinction used in
-- PROOF_DGLA.tex.  All arithmetic is exact over QQ.

needsPackage "VersalDeformations";
assert((options VersalDeformations)#Version == "3.0");
setRandomSeed 0;

S = QQ[x_1..x_8];
I = ideal(
  x_6*x_7*x_8, x_4*x_6*x_8, x_3*x_7*x_8, x_3*x_5*x_7,
  x_3*x_4*x_8, x_2*x_7*x_8, x_2*x_5*x_7, x_2*x_5*x_6,
  x_2*x_4*x_7, x_2*x_4*x_6, x_1*x_4*x_6, x_1*x_4*x_5,
  x_1*x_3*x_8, x_1*x_3*x_6, x_1*x_3*x_5, x_1*x_2*x_5);
F = gens I;
A = S/I;

-- For a relative Tate resolution, H^1 is Hom_S(I,A)_0.  Keep the graded
-- shifts: omitting them gives a different and irrelevant degree count.
relativeBasis = ambient basis(0,Hom(I,A));
jacobianMap = transpose substitute(jacobian F,A);
absoluteBasis = CT^1(0,F);

relativeDimension = numColumns relativeBasis;
jacobianImageDimension = numColumns basis(0,image jacobianMap);
absoluteDimension = numColumns absoluteBasis;

assert(relativeDimension == 109);
assert(jacobianImageDimension == 56);
assert(absoluteDimension == 53);
assert(relativeDimension-jacobianImageDimension == absoluteDimension);

-- Track the tangent class of the actual order-three starting family.  This
-- assertion is deliberately outside the frozen completion script.
y = {
  1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,10,1,
  25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,15,1,1,8,11};
(versalF,versalR,versalG,versalC) = versalDeformation(
  F,absoluteBasis,CT^2(0,F),HighestOrder=>3,
  SmartLift=>false,DefParam=>t);
parameterRing = ring versalF#0;
evaluateAll = map(S,parameterRing,y | gens S);
firstOrder = evaluateAll versalF#1;
yColumn = transpose matrix(S,{y});
assert(firstOrder == transpose(absoluteBasis*yColumn));

out = "verification/controller_QQ.txt";
certificate = out;
certificate << "" << flush;
certificate << "field=QQ" << endl;
certificate << "VersalDeformations_version=3.0" << endl;
certificate << "relative_H1_dimension=109" << endl;
certificate << "coordinate_boundary_image_dimension=56" << endl;
certificate << "absolute_H1_dimension=53" << endl;
certificate << "relative_minus_coordinate_equals_absolute=true" << endl;
certificate << "starting_mc_linear_e_values_equal_T1_y=true" << endl;
certificate << flush;

print("relative H1 dimension=" | toString relativeDimension);
print("coordinate-boundary image dimension=" | toString jacobianImageDimension);
print("absolute H1 dimension=" | toString absoluteDimension);
print("starting MC linear e-values equal T1*y=true");
print("certificate=" | out);
exit 0;
