# Day 16 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `scikit-learn` | ROC/PR curves, `calibration_curve`, `CalibratedClassifierCV`, Brier | `average_precision_score` for AUPRC; `strategy='quantile'` for rare-event calibration |
| `numpy` | Seeded patient-level bootstrap | `default_rng`; resample the array of unique patient ids |
| DeLong impl | Statistical AUC comparison | vetted gist / `delong` pkg / port Sun–Xu; verify vs. a bootstrap diff CI |
| `statsmodels` | Hosmer–Lemeshow, calibration slope/intercept (logit of p vs. y) | HL isn't built-in — bin + chi-square, or use a snippet |
| `matplotlib` | Reliability diagram, ROC/PR, decision curve | Save to `docs/img/models/`; add CI bands |
| `mlflow` | Attach eval metrics/plots to Day 15 runs | `mlflow.log_metric` into the existing `run_id` |
| `dcurves` (optional) | Decision curve analysis | or implement net-benefit by hand (5 lines) |

### Traps

- Bootstrapping predictions row-wise (not patient-wise) gives falsely narrow CIs — the single
  most common evaluation mistake in interviews.
- Calibrating on the test set leaks and makes calibration look better than it is. Use a
  dedicated calibration split.
- `roc_auc_score` on a subgroup with one class present throws / is undefined — guard it.
- DeLong assumes the *same* test cases for both models (paired). If your two models scored
  different rows, you can't use it — align them first.
- AUPRC baseline is the prevalence, not 0.5 — always report prevalence next to AUPRC.
