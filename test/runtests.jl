using CDCL

function test_cnf()
  @vars x1, x2, x3, x4
  cnf = (x1 ∨ ¬x2) ∧ (x2 ∨ x3) ∧ (x2 ∨ ¬x4) ∧ (¬x1 ∨ ¬x3 ∨ x4)
end
