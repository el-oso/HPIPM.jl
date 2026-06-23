```@meta
CurrentModule = HPIPM
```

# API reference

## Dense QP

```@docs
DenseQP
solve
set!(::DenseQP)
solve!(::DenseQP)
set_g!
```

### Dense accessors

```@docs
HPIPM.status(::DenseQP)
HPIPM.iterations(::DenseQP)
HPIPM.objective
HPIPM.primal
HPIPM.dual_eq
HPIPM.residuals
```

## OCP QP

```@docs
OCPQP
set!(::OCPQP)
solve!(::OCPQP)
HPIPM.state
HPIPM.input
HPIPM.states
HPIPM.inputs
```

## MathOptInterface

```@docs
HPIPM.Optimizer
```

## Low-level bindings

The complete auto-generated C bindings live in the submodule `HPIPM.LibHPIPM`
(e.g. `HPIPM.LibHPIPM.d_dense_qp_ipm_solve`). The wrapper above is built on top
of them; reach for them only for functionality not yet surfaced.
