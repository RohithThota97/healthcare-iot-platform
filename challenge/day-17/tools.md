# Day 17 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `lifelines` | KM, log-rank, CoxPH, CoxTimeVarying, `check_assumptions`, `concordance_index` | `pip install lifelines`; `.print_summary()` renders HRs + CIs |
| `scikit-survival` (`sksurv`) (optional) | RSF, gradient-boosted survival, time-dependent AUC | needs a compiler for some wheels; only for the stretch |
| `matplotlib` | KM curves + at-risk tables | `kmf.plot_survival_function(at_risk_counts=True)` |
| `mlflow` (Registry) | Stage transitions, gate script | Registry needs a DB backend store (sqlite ok), not just file store |
| `pandas` | Build the survival frame + counting-process long format | careful with interval `start`/`stop` construction |
| `pytest` | Gate-script refusal test, data validity | deterministic thresholds fixture |

### MLflow Registry config checkpoint

- The Registry requires `--backend-store-uri` be a database (`sqlite:///mlflow.db` locally),
  not a bare directory. If you set up file-store on Day 15, migrate now.
- `MlflowClient().transition_model_version_stage(name, version, stage, archive_existing_versions=True)`.

### Traps

- Feeding post-origin covariates into a plain Cox = immortal-time bias and optimistic HRs. Use a
  landmark.
- `event` coding: `lifelines` wants 1 = event occurred, 0 = censored. Flipping it silently
  inverts every HR.
- PH assumption violations are common with vitals — don't ignore the Schoenfeld output; stratify
  or add time interaction and say what you did.
- Time-varying Cox in wide format is wrong; it needs the `(start, stop]` counting-process layout.
- C-index near 0.5 means no discrimination; near 1.0 on training only usually means leakage.
