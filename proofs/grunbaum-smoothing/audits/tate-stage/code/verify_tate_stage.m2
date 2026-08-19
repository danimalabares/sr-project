-- Exact low Tate-stage certification using only public core Macaulay2 operations.
-- No package is loaded and no DG-algebra cycle-killing routine is called.

setRandomSeed 0;
S = QQ[x_1..x_8,MonomialOrder=>GRevLex];
load "verification/generated_input.m2";

assert(numRows FInput == 1 and numColumns FInput == 16);
assert(numRows RInput == 16 and numColumns RInput == 30);
assert(numRows ZInput == 150 and numColumns ZInput == 136);
assert(#gInternalDegrees == 136);
assert(take(gInternalDegrees,16) == toList(16:5));
assert(drop(gInternalDegrees,16) == toList(120:6));

E0 = S^1;
E1 = S^(toList(16:{-3}));
E2 = S^(toList(30:{-4}) | toList(120:{-6}));
E3 = S^(toList(480:{-7}) | toList(560:{-9}));
G3 = S^(apply(gInternalDegrees,degreeValue -> {-degreeValue}));

assert(all(degrees E1,entry -> entry === {3}));
assert(take(degrees E2,30) == toList(30:{4}));
assert(drop(degrees E2,30) == toList(120:{6}));
assert(take(degrees E3,480) == toList(480:{7}));
assert(drop(degrees E3,480) == toList(560:{9}));
assert(take(degrees G3,16) == toList(16:{5}));
assert(drop(degrees G3,16) == toList(120:{6}));

-- Zero-based lexicographic index for (i,j), 0 <= i < j < 16.
pairIndex = (i,j) -> (i*(31-i))//2 + j-i-1;
indexPairs = flatten apply(toList(0..14),i ->
  apply(toList((i+1)..15),j -> {i,j}));
indexTriples = flatten apply(toList(0..13),i ->
  flatten apply(toList((i+1)..14),j ->
    apply(toList((j+1)..15),k -> {i,j,k})));
assert(#indexPairs == 120 and #indexTriples == 560);
assert(all(0..119,index ->
  pairIndex((indexPairs#index)#0,(indexPairs#index)#1) == index));

D1 = map(E0,E1,FInput);

-- E2 basis: f_1,...,f_30, then e_i e_j in lexicographic order i<j.
d2Entry = (row,column) -> (
  if column < 30 then RInput_(row,column)
  else (
    ij := indexPairs#(column-30);
    i := ij#0;
    j := ij#1;
    if row == i then -FInput_(0,j)
    else if row == j then FInput_(0,i)
    else 0_S));
D2raw = matrix apply(16,row -> apply(150,column -> d2Entry(row,column)));
D2 = map(E1,E2,D2raw);

-- E3 basis: e_i f_j with i outer/j inner, then e_i e_j e_k, i<j<k.
d3Entry = (row,column) -> (
  if column < 480 then (
    eIndex := column//30;
    fIndex := column%30;
    if row == fIndex then FInput_(0,eIndex)
    else if row < 30 then 0_S
    else (
      kl := indexPairs#(row-30);
      leftIndex := kl#0;
      rightIndex := kl#1;
      if rightIndex == eIndex then RInput_(leftIndex,fIndex)
      else if leftIndex == eIndex then -RInput_(rightIndex,fIndex)
      else 0_S))
  else (
    ijk := indexTriples#(column-480);
    firstIndex := ijk#0;
    secondIndex := ijk#1;
    thirdIndex := ijk#2;
    if row == 30+pairIndex(secondIndex,thirdIndex) then FInput_(0,firstIndex)
    else if row == 30+pairIndex(firstIndex,thirdIndex) then -FInput_(0,secondIndex)
    else if row == 30+pairIndex(firstIndex,secondIndex) then FInput_(0,thirdIndex)
    else 0_S));
D3raw = matrix apply(150,row -> apply(1040,column -> d3Entry(row,column)));
D3 = map(E2,E3,D3raw);
Z = map(E2,G3,ZInput);
B = D3 | Z;
E3plusG3 = source B;

assert(isHomogeneous D1);
assert(isHomogeneous D2);
assert(isHomogeneous D3);
assert(isHomogeneous Z);
assert(target B === E2);

-- Requested chain identities, checked as exact polynomial-matrix identities.
failurePath = "verification/FAILED_CLASS.m2";
firstNonzeroColumn = M -> first select(0..(numColumns M-1),column -> M_{column} != 0);
writeFailedContainment = (failureName,cycleMatrix,remainderMatrix) -> (
  failedColumn := firstNonzeroColumn remainderMatrix;
  failureOut := openOut failurePath;
  failureOut << "-- Exact nonzero normal remainder: certification failed." << endl;
  failureOut << "failureName = " << toExternalString failureName << ";" << endl;
  failureOut << "failedColumn = " << toString failedColumn << ";" << endl;
  failureOut << "cycleEntries = " <<
    toExternalString(entries cycleMatrix_{failedColumn}) << ";" << endl;
  failureOut << "normalRemainderEntries = " <<
    toExternalString(entries remainderMatrix_{failedColumn}) << ";" << endl;
  close failureOut;
  print("LOW_TATE_STAGE_FAILED: " | failureName
    | "; explicit class written to " | failurePath);
  exit 1);
requireZeroComposite = (failureName,compositeMatrix) -> (
  if compositeMatrix != 0 then
    writeFailedContainment(failureName,compositeMatrix,compositeMatrix));

requireZeroComposite("D1_D2_nonzero",D1*D2);
requireZeroComposite("D2_D3_nonzero",D2*D3);
requireZeroComposite("D2_Z_nonzero",D2*Z);

-- Full, unbounded syzygy modules.  quotientRemainder supplies explicit lifts.
K1 = syz D1;
assert(D1*K1 == 0);
(Q1,remainderK1) = quotientRemainder(K1,D2);
assert(D2*Q1+remainderK1 == K1);
if remainderK1 != 0 then writeFailedContainment("H_1_nonzero",K1,remainderK1);
assert(D2*Q1 == K1);
(P1,remainderD2) = quotientRemainder(D2,K1);
assert(K1*P1+remainderD2 == D2);
if remainderD2 != 0 then
  writeFailedContainment("im_D2_not_contained_in_ker_D1",D2,remainderD2);
assert(remainderD2 == 0);
assert(K1*P1 == D2);

K2 = syz D2;
assert(D2*K2 == 0);
(Q2,remainderK2) = quotientRemainder(K2,B);
assert(B*Q2+remainderK2 == K2);
if remainderK2 != 0 then writeFailedContainment("H_2_nonzero",K2,remainderK2);
assert(B*Q2 == K2);
(P2,remainderB) = quotientRemainder(B,K2);
assert(K2*P2+remainderB == B);
if remainderB != 0 then
  writeFailedContainment("im_D3_Z_not_contained_in_ker_D2",B,remainderB);
assert(remainderB == 0);
assert(K2*P2 == B);

assert(isHomogeneous K1 and isHomogeneous Q1 and isHomogeneous P1);
assert(isHomogeneous K2 and isHomogeneous Q2 and isHomogeneous P2);

-- Retain exact, independently re-loadable generators and lifts.  These are
-- polynomial matrices, not Hilbert functions or finite-degree summaries.
certificatePath = "verification/m2_lifts.generated.m2";
certificateOut = openOut certificatePath;
certificateOut << "-- Exact low Tate-stage module certificate over QQ." << endl;
K1SourceDegreesText = toExternalString(apply(degrees source K1,d -> first d));
K2SourceDegreesText = toExternalString(apply(degrees source K2,d -> first d));
certificateOut << "K1SourceDegrees = " << K1SourceDegreesText << ";" << endl;
certificateOut << "K1Entries = " << toExternalString(entries K1) << ";" << endl;
certificateOut << "Q1Entries = " << toExternalString(entries Q1) << ";" << endl;
certificateOut << "P1Entries = " << toExternalString(entries P1) << ";" << endl;
certificateOut << "K2SourceDegrees = " << K2SourceDegreesText << ";" << endl;
certificateOut << "K2Entries = " << toExternalString(entries K2) << ";" << endl;
certificateOut << "Q2Entries = " << toExternalString(entries Q2) << ";" << endl;
certificateOut << "P2Entries = " << toExternalString(entries P2) << ";" << endl;
close certificateOut;

summaryPath = "verification/m2_summary.txt";
summaryOut = openOut summaryPath;
summaryOut << "verdict=certified" << endl;
summaryOut << "field=QQ" << endl;
summaryOut << "D1_shape=1x16" << endl;
summaryOut << "D2_shape=16x150" << endl;
summaryOut << "D3_shape=150x1040" << endl;
summaryOut << "Z_shape=150x136" << endl;
summaryOut << "B_shape=150x1176" << endl;
summaryOut << "D1_D2_zero=true" << endl;
summaryOut << "D2_D3_zero=true" << endl;
summaryOut << "D2_Z_zero=true" << endl;
summaryOut << "ker_D1_equals_im_D2=true" << endl;
summaryOut << "ker_D2_equals_im_D3_Z=true" << endl;
summaryOut << "K1_generators=" << toString numColumns K1 << endl;
summaryOut << "K2_generators=" << toString numColumns K2 << endl;
summaryOut << "certificate=" << certificatePath << endl;
close summaryOut;

print("MACAULAY2_LOW_TATE_STAGE_CERTIFIED");
print("K1_generators=" | toString numColumns K1);
print("K2_generators=" | toString numColumns K2);
print("certificate=" | certificatePath);
exit 0;
