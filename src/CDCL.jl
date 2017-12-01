module CDCL

"A `Variable` with name `nm`"
struct Variable
  nm::Symbol
end

"Generate `Variable`s with same name as julia variable"
macro vars(varnames...)
  varassigns = map(varnames) do varname
    local vname = esc(varname)
    @show vname
    vname = varname
    :($vname = Variable(Symbol($vname)))
  end
  @show length(varassigns)
  aba = Expr(:block, varassigns...)
  dump(aba)
  aba
end

Base.show(io::IO, v::Variable) = Base.show(io, v.nm)

"A literal is either a variable `x_i` or its complement `¬x_1`"
struct Literal
  var::Variable
  isneg::Bool
end

Base.show(io::IO, l::Literal) = l.isneg ? show(io, Symbol(:¬, l.var.nm)) : show(io, l.var)
Literal(nm::Symbol, isneg=false) = Literal(Variable(nm), isneg)
¬(l::Literal) = Literal(l.var, !l.isneg)
# ∨(x::)

"A disjunction of `Literal`s"
struct Clause
  lits::Set{Literal}
end

"""In the context of search algorithms for SAT, variables can be *assigned* a
logic value, either 0 or 1. Alternatively, variables may also be *unassigned*.
Assignments to the problem variables can be defined as a function ``ν: X → {0 ,u, 1}``
where ``u`` denotes an `undefined` value used when a variable has not been assigned
a value in ``{0, 1}``"""
Assignment = Dict{Literal, Int}
const UNASSIGNED = -1
isunassigned(var::Variable, ν::Assignment) = = ν[variable] == UNASSIGNED
isassigned(var::Variable, ν::Assignment) = !isunassigned(var, ν)

"Given an assignment ``ν``, if all variables are assigned a value in ``\{ 0 , 1 \}``,
then ``ν`` is referred to as a *complete* assignment."
iscomplete(ν::Assignment) = all(isassigned(var) for var in vars(ν))

"Otherwise it is a *partial* assignment."
ispartial(ν::Assignment) = !iscomplete(ν)

"""Assignments serve for computing the values of literals, clauses and the com-
plete CNF formula, respectively, l ν , ω ν and φ ν .  A total order is defined on
the possible assignments, 0 <u< 1.

Moreover, 1 − u = u . As a result, the following definitions apply:
lν =  ν ( x i )if l = x i 1 − ν ( x i )if l = ¬ x i (4.3) ω ν =max { l ν | l ∈ ω } (4.4) φ ν =min { ω ν | ω ∈ φ } (4.5
"""
value(l::Literal, ν::Assignment) = l.isneg ? ν[l.var] : 1 - ν[l.var]
value(ω::Clause, ν::Assignment) = max((value(l, ν) for l in literals(ω))...)
value(φ::CNF, ν::Assignment) = min((value(ω, ν) for ω in clauses(ϕ))...)


"Clauses are characterized as *unsatisfied*, *satisfied*, *unit* or, *unresolved*"
@enum unsatisfied, satisfied, unit, unresolved

"A clause is unsatisfied if all its literals are assigned value 0"
issat(φ::Clause, ν::Assignment) = all(ν(var)==1 for var in vars(φ))

"A clause is satisfied if at least one of its literals is assigned value 1"
isunsat(φ::Clause, ν::Assignment) = all(ν(var)==0 for var in vars(φ))

"A clause is unit if all literals but one are assigned value 0, and the remaining literal is unassigned."
isunit(φ::Clause, ν::Assignment) = any(ν(var)==0 for var in vars(φ))

"Finally, a clause is unresolved if it is neither unsatisfied, nor satisfied, nor unit"
isunresolved(φ::Clause, ν::Assignment) =
  !issat(φ, ν) && !isunsat(φ, ν) && !isunit(φ, ν)

end
