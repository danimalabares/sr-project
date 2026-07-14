import Mathlib

set_option linter.style.header false

/-!
# Grünbaum sphere T¹ computation
-/

abbrev Facet := List Nat

def facets : List Facet :=
  [ [1,2,3,4], [1,2,3,7], [1,2,6,7],
    [1,3,4,7], [1,5,6,7], [2,3,4,5],
    [2,3,6,7], [3,4,6,7], [3,4,5,6],
    [4,5,6,7], [2,3,5,8], [2,3,6,8],
    [3,5,6,8], [1,2,6,8], [1,5,6,8],
    [1,2,4,8], [2,4,5,8], [1,4,7,8],
    [1,5,7,8], [4,5,7,8] ]

theorem number_of_facets : facets.length = 20 := by
  rfl

def hasEdge (a b : Nat) (F : Facet) : Bool :=
  F.contains a && F.contains b

def edgeValency (a b : Nat) : Nat :=
  (facets.filter (fun F => hasEdge a b F)).length

theorem edgeValency_13 : edgeValency 1 3 = 3 := by
  rfl


-- T1 computation

abbrev Edge := Nat × Nat

def edges : List Edge :=
  [ (1,2), (1,3), (1,4), (1,5),
    (1,6), (1,7), (1,8),
    (2,3), (2,4), (2,5),
    (2,6), (2,7), (2,8),
    (3,4), (3,5), (3,6),
    (3,7), (3,8),
    (4,5), (4,6), (4,7),
    (4,8),
    (5,6), (5,7), (5,8),
    (6,7), (6,8),
    (7,8) ]

def valency3Edges : List Edge :=
  edges.filter
    (fun e => edgeValency e.1 e.2 == 3)

def valency4Edges : List Edge :=
  edges.filter
    (fun e => edgeValency e.1 e.2 == 4)

theorem number_valency3_edges :
    valency3Edges.length = 7 := by
  rfl

theorem number_valency4_edges :
    valency4Edges.length = 9 := by
  rfl

theorem edge_contribution_to_T1 :
    5 * valency3Edges.length
      + 2 * valency4Edges.length = 53 := by
  rfl
