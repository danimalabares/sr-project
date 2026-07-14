import Mathlib

set_option linter.style.header false

/-!
# Order-2 certificate infrastructure
-/

namespace SrT1.Order2

abbrev K := ZMod 32003
abbrev Vec := List K
abbrev Row := List (Nat × K)

def getCoeff (x : Vec) (i : Nat) : K :=
  x.getD i 0

def dotRow (row : Row) (x : Vec) : K :=
  row.foldl
    (fun acc term =>
      acc + term.2 * getCoeff x term.1)
    0

def checkRows
    (rows : List Row)
    (rhs : Vec)
    (solution : Vec) : Bool :=
  (List.zip rows rhs).all
    (fun rb =>
      decide (dotRow rb.1 solution = rb.2))

end SrT1.Order2
