```@meta
CurrentModule = HPIPM
```

# JuMP / MathOptInterface

`HPIPM.Optimizer` wraps the dense QP backend for
[MathOptInterface](https://github.com/jump-dev/MathOptInterface.jl), so it works
directly from [JuMP](https://jump.dev).

```@example moi
using JuMP, HPIPM
m = Model(HPIPM.Optimizer)
set_silent(m)
@variable(m, 0 <= x <= 3)
@variable(m, y >= 0)
@constraint(m, c, x + y <= 4)
@objective(m, Min, (x - 1)^2 + (y - 2)^2)
optimize!(m)
(termination_status(m), value(x), value(y), objective_value(m))
```

## Supported problem features

| MOI feature | Maps to |
|---|---|
| `ScalarQuadraticFunction` / `ScalarAffineFunction` objective (`Min`/`Max`) | `H`, `g` |
| `VariableIndex` in `LessThan`/`GreaterThan`/`EqualTo`/`Interval` | box bounds (`idxb`, `lb`, `ub`) |
| `ScalarAffineFunction` in `EqualTo` | equality rows (`A`, `b`) |
| `ScalarAffineFunction` in `LessThan`/`GreaterThan`/`Interval` | general rows (`C`, `lg`, `ug`) |

Quadratic objectives follow MOI's convention (a diagonal term coefficient `α`
contributes `½α xᵢ²`), so they map to HPIPM's `½xᵀHx` exactly.

## Options

Set via `set_optimizer_attribute` / `MOI.RawOptimizerAttribute`:

| Name | Meaning |
|---|---|
| `"mode"` | `"SPEED_ABS"`, `"SPEED"`, `"BALANCE"` (default), `"ROBUST"` |
| `"iter_max"` | maximum interior-point iterations |
| `"tol_stat"`, `"tol_eq"`, `"tol_ineq"`, `"tol_comp"` | termination tolerances |
| `"mu0"` | initial barrier parameter |
| `MOI.Silent()` | suppress output |

## Result attributes

`TerminationStatus`, `PrimalStatus`, `DualStatus`, `VariablePrimal`,
`ObjectiveValue`, `SolveTimeSec`, `BarrierIterations`, `RawStatusString`, and
`ConstraintDual` for equality constraints. Status mapping:

| HPIPM | MOI `TerminationStatus` |
|---|---|
| `success` | `OPTIMAL` |
| `max_iter` | `ITERATION_LIMIT` |
| `min_step` | `SLOW_PROGRESS` |
| `nan_sol` | `NUMERICAL_ERROR` |
| `incons_eq` | `INFEASIBLE` |
