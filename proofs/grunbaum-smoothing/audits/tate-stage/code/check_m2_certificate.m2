-- Re-load and multiply the retained exact lift certificate.
-- Uses only public core Macaulay2 operations; does not compute a Groebner basis.

setRandomSeed 0;
S = QQ[x_1..x_8,MonomialOrder=>GRevLex];
load "verification/generated_input.m2";

E0 = S^1;
E1 = S^(toList(16:{-3}));
E2 = S^(toList(30:{-4}) | toList(120:{-6}));
E3 = S^(toList(480:{-7}) | toList(560:{-9}));
G3 = S^(apply(gInternalDegrees,degreeValue -> {-degreeValue}));

pairIndex = (i,j) -> (i*(31-i))//2 + j-i-1;
indexPairs = flatten apply(toList(0..14),i ->
  apply(toList((i+1)..15),j -> {i,j}));
indexTriples = flatten apply(toList(0..13),i ->
  flatten apply(toList((i+1)..14),j ->
    apply(toList((j+1)..15),k -> {i,j,k})));

D1 = map(E0,E1,FInput);
d2Entry = (row,column) -> (
  if column < 30 then RInput_(row,column)
  else (
    ij := indexPairs#(column-30); i := ij#0; j := ij#1;
    if row == i then -FInput_(0,j)
    else if row == j then FInput_(0,i)
    else 0_S));
D2 = map(E1,E2,matrix apply(16,row -> apply(150,column -> d2Entry(row,column))));
d3Entry = (row,column) -> (
  if column < 480 then (
    eIndex := column//30; fIndex := column%30;
    if row == fIndex then FInput_(0,eIndex)
    else if row < 30 then 0_S
    else (
      kl := indexPairs#(row-30); leftIndex := kl#0; rightIndex := kl#1;
      if rightIndex == eIndex then RInput_(leftIndex,fIndex)
      else if leftIndex == eIndex then -RInput_(rightIndex,fIndex)
      else 0_S))
  else (
    ijk := indexTriples#(column-480);
    firstIndex := ijk#0; secondIndex := ijk#1; thirdIndex := ijk#2;
    if row == 30+pairIndex(secondIndex,thirdIndex) then FInput_(0,firstIndex)
    else if row == 30+pairIndex(firstIndex,thirdIndex) then -FInput_(0,secondIndex)
    else if row == 30+pairIndex(firstIndex,secondIndex) then FInput_(0,thirdIndex)
    else 0_S));
D3 = map(E2,E3,matrix apply(150,row -> apply(1040,column -> d3Entry(row,column))));
Z = map(E2,G3,ZInput);
B = D3 | Z;
E3plusG3 = source B;

load "data/m2_lift_certificate.m2";

K1Source = S^(apply(K1SourceDegrees,d -> {-d}));
K2Source = S^(apply(K2SourceDegrees,d -> {-d}));
K1 = map(E1,K1Source,K1Entries);
Q1 = map(E2,K1Source,Q1Entries);
P1 = map(K1Source,E2,P1Entries);
K2 = map(E2,K2Source,K2Entries);
Q2 = map(E3plusG3,K2Source,Q2Entries);
P2 = map(K2Source,E3plusG3,P2Entries);

assert(isHomogeneous K1 and isHomogeneous Q1 and isHomogeneous P1);
assert(isHomogeneous K2 and isHomogeneous Q2 and isHomogeneous P2);
assert(D1*D2 == 0);
assert(D2*D3 == 0);
assert(D2*Z == 0);
assert(D1*K1 == 0);
assert(D2*Q1 == K1);
assert(K1*P1 == D2);
assert(D2*K2 == 0);
assert(B*Q2 == K2);
assert(K2*P2 == B);

print("RETAINED_MACAULAY2_LIFTS_VERIFIED");
exit 0;
