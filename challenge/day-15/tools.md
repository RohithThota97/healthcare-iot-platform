# Day 15 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `scikit-learn` | Pipelines, CV, LR, metrics | `Pipeline` with `ColumnTransformer`; `TimeSeriesSplit` |
| `statsmodels` | LR inference: OR, CI, p, Hosmer–Lemeshow | `Logit`/`GLM(Binomial)`; `.summary()` and `.conf_int()` |
| `xgboost` **or** `lightgbm` | Gradient-boosted baseline | early stopping API differs by version; pin it |
| `imbalanced-learn` | SMOTE / class weights done inside CV | use `imblearn.pipeline.Pipeline`, not sklearn's, so resampling stays in-fold |
| `shap` | Interpretability for the GBM | `shap.TreeExplainer`; sample rows if slow |
| `mlflow` | Experiment tracking + (Day 17) registry | `MLFLOW_TRACKING_URI` set; `mlflow ui` shows runs; autolog optional |

### MLflow config checkpoints

- Local: `mlflow server --backend-store-uri sqlite:///mlflow.db --artifacts-destination
  ./mlruns` (or the compose service). Point `MLFLOW_TRACKING_URI` at it.
- One experiment name per model family; log the git SHA and the dataset split boundaries as
  params so a run is reproducible.
- Log the *exact* feature list and the training window as artifacts.

### Traps

- Random `train_test_split` on time-series = leakage and inflated AUC. Split by time and by
  patient.
- SMOTE before the split (or in a plain sklearn Pipeline) leaks synthetic neighbours into
  validation. Use `imblearn.pipeline.Pipeline`.
- `LogisticRegression` default has L2 penalty and `C=1.0` — that's regularization; for pure
  inference use `statsmodels` or `penalty=None`.
- XGBoost early stopping needs an eval set from the *training* period, not the held-out test.
- SHAP on 100k rows is slow — explain a sample, note it.
