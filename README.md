# Healthcare IoT Real-Time Patient Monitoring Platform

A planned healthcare IoT platform for ingesting real-time patient vital signs, validating sensor
data, storing time-series measurements, running statistical analysis, detecting anomalies,
estimating patient risk, and supporting natural-language patient summaries.

> This repository currently contains the project structure, architecture, statistical-method
> reference, and delivery plan only. It does not include production application code or real
> clinical data. Any model or statistical output is experimental decision support, not a diagnosis.

## Skills focus (why this project exists)

The primary goal is to build strong, transferable data skills. Every stage below is designed to
practice one or more of:

1. **Data collection** — Kafka producers/consumers, Kafka Connect (HL7/FHIR), batch file ingest
   (PhysioNet BIDMC), schema registry, dead-letter handling.
2. **Data transformation** — PySpark reshaping, resampling, joins, window functions, medallion
   (bronze → silver → gold) modeling.
3. **Data cleaning** — missing/duplicate/stale/noisy/out-of-range handling, imputation,
   artifact rejection, referential-integrity repair.
4. **SQL** — window functions, percentiles, gaps-and-islands, time bucketing, statistical
   aggregates, data-quality queries (see [SQL patterns to master](#sql-patterns-to-master)).
5. **Statistical methods** — descriptive stats, distribution checks, hypothesis testing,
   correlation, regression, time-series stats, drift detection, survival analysis, model
   evaluation (see [Statistical methods reference](#statistical-methods-reference)).
6. **Supporting tooling** — dbt, Great Expectations/Deequ, Airflow, MLflow, feature store,
   GraphRAG, Prometheus/Grafana.

## Planned capabilities

- Ingest multi-device vitals (HR, SpO2, ECG, BP, temperature, respiratory rate) through Kafka with
  a schema registry, plus a Kafka Connect layer for legacy HL7/FHIR feeds from bedside monitors.
- Compute stateful stream analytics in flight — sliding-window aggregations, sensor-drift
  detection, and early-warning scoring (e.g. NEWS2) — before data lands.
- Store curated data in a medallion lakehouse, with time-series-optimized storage for
  high-frequency ECG waveforms.
- Clean, resample, and validate data with PySpark and layered data-quality contracts.
- Run structured exploratory and confirmatory **statistical analysis** on vitals, data-quality
  events, and outcomes.
- Serve consistent features to real-time inference and batch training through a feature store.
- Run anomaly-detection and early-deterioration models that feed alerts back into the stream.
- Answer relational and temporal clinical questions with a GraphRAG + hybrid-retrieval agent.
- Operate under SLA-tiered orchestration with full observability and HIPAA/GDPR audit logging.

## Architecture

The platform separates the real-time alerting path from the batch analytics and ML compute paths.

### Ingestion & streaming

- **Kafka + Schema Registry** carrying versioned Avro/Protobuf messages for multi-device vitals
  (HR, SpO2, ECG, BP).
- **Kafka Connect** to normalize legacy HL7/FHIR feeds from bedside monitors into the same event
  contracts.
- **Kafka Streams / Flink** for stateful stream processing: sliding-window aggregations,
  sensor-drift detection, and early-warning scoring (e.g. NEWS2) computed in flight before landing.
- **Dead-letter queues + schema evolution handling** for malformed or out-of-spec device payloads,
  with replay support.

### Storage & compute

- **Medallion lakehouse (bronze / silver / gold)** on S3 + Databricks Delta Lake, with **Unity
  Catalog** for lineage and column-level access control (PHI masking).
- **Snowflake** as the serving layer for BI and clinician dashboards, decoupled from the ML
  compute path.
- **Time-series-optimized storage** (Delta with Z-ordering, or a dedicated TSDB such as InfluxDB /
  TimescaleDB) for high-frequency ECG waveform data specifically.

### Transformation & data quality

- **PySpark** for large-scale cleansing: interpolation and resampling for inconsistent sampling
  rates, artifact rejection (motion / noise) using signal-processing heuristics.
- **dbt tests** extended with anomaly-detection-based quality checks (statistical drift, not just
  static ranges) and referential integrity across patient / device / encounter dimensions.
- **Great Expectations or Deequ** for data contracts between ingestion and downstream ML consumers.
- **Statistical profiling** at every layer: completeness/validity/uniqueness rates, value
  distributions, cardinality, and drift metrics (see below).

### Statistical analysis layer

Runs on silver/gold tables in SQL (Snowflake) and Python/PySpark notebooks. Feeds three consumers:
data-quality gates, feature selection, and model evaluation. Full catalog in
[Statistical methods reference](#statistical-methods-reference).

- **Exploratory data analysis (EDA)** — descriptive statistics, distribution shape, missingness
  maps, correlation structure, per-patient and per-device breakdowns.
- **Confirmatory analysis** — hypothesis tests comparing deteriorating vs. stable patients,
  device types, or hospital units; effect sizes and confidence intervals, not just p-values.
- **Time-series statistics** — stationarity, autocorrelation, decomposition, spectral analysis of
  ECG/PPG, rolling and windowed summaries that also become model features.
- **Drift & statistical process control** — PSI, KS, KL/JS divergence, CUSUM and control charts
  for sensor drift and input/label drift monitoring.
- **Outcome analysis** — logistic regression and survival analysis for time-to-deterioration.

### ML / feature layer

- **Feature store** (Feast or Databricks Feature Store) so real-time inference and batch training
  share consistent features.
- **Anomaly-detection / early-deterioration models** (LSTM / temporal CNN, or gradient-boosted
  models on engineered features) feeding alerts back into the stream.
- **Statistical model evaluation** — ROC/PR AUC with bootstrap CIs, calibration (Brier score,
  calibration curves, Hosmer–Lemeshow), DeLong test to compare models, subgroup fairness checks.

### RAG / agentic layer

- **GraphRAG** reusing the existing Neo4j + Docling pattern: patient trajectories modeled as a
  graph (encounters → vitals → interventions → outcomes) so the agent can answer relational and
  temporal questions ("what changed after medication X"), not just similarity-retrieve chunks.
- **LangChain / LangGraph** for multi-agent orchestration: a retrieval agent, a clinical-reasoning
  agent, and a guardrail / safety agent that flags out-of-scope or diagnostic-sounding responses.
- **LoRA fine-tuning** on a clinical-domain base model, Hugging Face for embeddings, and PyTorch
  for custom scoring heads.
- **Vector DB** (pgvector / Weaviate) alongside Neo4j for hybrid graph + semantic retrieval.

### Orchestration, ops, compliance

- **Airflow DAGs split by SLA tier** (real-time alerting vs. nightly batch), with sensors on Kafka
  lag and Delta table freshness.
- **Docker + GitLab CI/CD** with separate pipelines for data infrastructure vs. model artifacts
  (**MLflow** model registry).
- **Observability**: Prometheus / Grafana on pipeline health, model-drift monitoring, and audit
  logging for HIPAA / GDPR compliance.

## Data flow (end to end)

```text
Devices / bedside monitors
    │  vitals + HL7/FHIR
    ▼
Kafka (Schema Registry) ──► DLQ (malformed) ──► replay
    │
    ▼
Kafka Streams / Flink  ── windowed aggregates, drift signals, NEWS2 candidates
    │
    ▼
Bronze (raw, append-only)                       [profiling: row counts, arrival lag]
    │  PySpark: resample, dedupe, interpolate, artifact reject
    ▼
Silver (clean, conformed)                        [profiling: completeness, validity, ranges]
    │  dbt + Great Expectations/Deequ contracts
    │  STATISTICAL ANALYSIS: EDA, distribution checks, hypothesis tests, correlation
    ▼
Gold (features, aggregates, labels)              [drift: PSI / KS / control charts]
    │
    ├──► Feature store ──► real-time inference ──► alerts back to Kafka
    ├──► Model training ──► MLflow ──► statistical evaluation (AUC, calibration, subgroup)
    ├──► Snowflake ──► BI / clinician dashboards
    └──► Neo4j + vector DB ──► GraphRAG multi-agent chatbot
```

Statistical analysis sits on the silver/gold boundary: it both **gates** promotion (quality and
drift thresholds) and **produces** the rolling-window features and labels used downstream.

## Statistical methods reference

Grouped by purpose. This is a study guide — pick the method that matches the question and the data
type. "Where" indicates the most practical tool for each on this platform.

### 1. Descriptive & exploratory statistics

| Method | Use it for | Where |
|---|---|---|
| Mean, median, mode | Central tendency of vitals per patient/device/window | SQL, PySpark |
| Variance, standard deviation, range, IQR | Spread and variability; noise level | SQL (`STDDEV`, `VAR_POP`), PySpark |
| Percentiles / quantiles (P1, P5, P50, P95, P99) | Reference ranges, alarm thresholds, tail behavior | SQL (`PERCENTILE_CONT`), NumPy |
| Skewness, kurtosis | Distribution asymmetry and tail heaviness (HR, RR are right-skewed) | SciPy, pandas |
| Frequency tables, cardinality, value counts | Categorical profiling (device type, unit, alarm code) | SQL `GROUP BY`, pandas |
| Cross-tabulation / contingency tables | Relationship between two categoricals (unit × deterioration) | pandas `crosstab`, SQL |
| Grouped/rolling summaries | Per-patient, per-hour, per-device aggregates → features | SQL window funcs, PySpark |

### 2. Distribution analysis & assumption checks

| Method | Use it for | Where |
|---|---|---|
| Histogram, KDE, ECDF | Visual distribution shape before choosing a test | matplotlib/seaborn |
| Q–Q plot | Check normality visually | statsmodels, SciPy |
| Shapiro–Wilk test | Normality test (small–medium samples) | SciPy |
| Kolmogorov–Smirnov / Anderson–Darling | Goodness of fit to a reference distribution | SciPy |
| Levene's / Bartlett's test | Equal-variance assumption before ANOVA / t-test | SciPy |
| Fitting distributions (normal, log-normal, Poisson, exponential) | Model inter-arrival times, event counts, waveform amplitude | SciPy `fit` |

### 3. Missing-data analysis

| Method | Use it for | Where |
|---|---|---|
| Missingness rate per column / per patient / per time bucket | Quantify the problem | SQL, pandas |
| MCAR / MAR / MNAR reasoning, Little's MCAR test | Decide whether dropping rows biases results | statsmodels, manual |
| Missingness correlation heatmap | See if gaps co-occur (device dropout) | missingno, pandas |
| Imputation: forward-fill / last-observation-carried-forward | Short vitals gaps | PySpark, pandas |
| Linear / spline interpolation, resampling | Irregular sampling rates on continuous signals | pandas, SciPy |
| Mean/median imputation | Simple baseline; record an "imputed" flag | SQL, PySpark |
| KNN imputation, MICE (iterative) | Multivariate gaps where columns are correlated | scikit-learn, statsmodels |

### 4. Outlier & anomaly detection (statistical)

| Method | Use it for | Where |
|---|---|---|
| Z-score (mean ± k·SD) | Symmetric, roughly-normal signals | SQL, NumPy |
| Modified z-score (median + MAD) | Robust to existing outliers; preferred for vitals | NumPy/SciPy |
| IQR / Tukey fences (Q1 − 1.5·IQR, Q3 + 1.5·IQR) | Non-parametric range check | SQL, pandas |
| Grubbs' test, Dixon's Q | Single-outlier test in a small sample | outlier_utils, manual |
| Hampel filter (rolling median + MAD) | Spike removal in streaming waveforms | pandas rolling |
| Seasonal-Hybrid ESD (S-H ESD) | Outliers in seasonal time series | pyculiarity-style |
| Isolation Forest, LOF, DBSCAN | Multivariate / contextual anomalies across vitals | scikit-learn |
| Physiological range rules | Hard clinical bounds (e.g. HR 20–250) as a first pass | SQL, dbt tests |

### 5. Time-series statistics (vitals & waveforms)

| Method | Use it for | Where |
|---|---|---|
| Resampling / aggregation to fixed cadence | Align devices with different sampling rates | pandas `resample`, PySpark |
| Rolling mean / std / min / max / slope | Trend features, deterioration signals | SQL window funcs, pandas |
| EWMA (exponentially weighted moving average) | Responsive smoothing, alarm de-bounce | pandas `ewm` |
| Savitzky–Golay filter | Smooth ECG/PPG while preserving peak shape | SciPy |
| Differencing | Remove trend; make a series stationary | pandas |
| ADF & KPSS tests | Test stationarity before ARIMA-type modeling | statsmodels |
| ACF / PACF | Identify autocorrelation / lag structure | statsmodels |
| STL / seasonal decomposition | Split trend, seasonal (circadian), residual | statsmodels |
| FFT / periodogram / power spectral density | Heart-rate & respiration frequency from waveform (BIDMC) | SciPy `signal` |
| Cross-correlation, time-lagged correlation | Lead/lag between SpO2 drop and HR rise | statsmodels, NumPy |
| Change-point detection (PELT, binary segmentation) | Detect regime shifts in a patient's trajectory | ruptures |

### 6. Hypothesis testing & group comparison

| Method | Use it for | Where |
|---|---|---|
| One-sample / two-sample t-test | Compare a mean to a reference or between two groups (normal data) | SciPy |
| Welch's t-test | Two groups, unequal variances (the safe default t-test) | SciPy |
| Paired t-test / Wilcoxon signed-rank | Before vs. after an intervention on the same patient | SciPy |
| Mann–Whitney U | Two groups, non-normal or ordinal | SciPy |
| One-way ANOVA / Kruskal–Wallis | 3+ groups (units, device models) parametric / non-parametric | SciPy, statsmodels |
| Tukey HSD / Games–Howell | Post-hoc pairwise after ANOVA | statsmodels |
| Chi-square test of independence | Two categoricals (device type vs. alarm frequency) | SciPy |
| Fisher's exact test | Same, but small cell counts | SciPy |
| Permutation / bootstrap tests | Any statistic, no distributional assumptions | NumPy, scikit-learn |
| Multiple-testing correction: Bonferroni, Benjamini–Hochberg FDR | When running many tests (per-vital, per-unit) | statsmodels |

### 7. Effect size, estimation & uncertainty

| Method | Use it for | Where |
|---|---|---|
| Cohen's d, Hedges' g | Standardized mean difference (report with every t-test) | pingouin, manual |
| Odds ratio, risk ratio, risk difference | Deterioration risk between exposure groups | statsmodels |
| Cramér's V, phi | Strength of association for categoricals | scipy/manual |
| Confidence intervals (t, normal, Wilson for proportions) | Communicate precision, not just point estimates | statsmodels |
| Bootstrap CIs | CI for medians, AUC, and other non-closed-form stats | scikit-learn, NumPy |

### 8. Correlation, association & feature screening

| Method | Use it for | Where |
|---|---|---|
| Pearson correlation | Linear association between continuous vitals | SQL (`CORR`), pandas |
| Spearman / Kendall's tau | Monotonic / rank association, robust to outliers | SciPy, pandas |
| Point-biserial correlation | Continuous vital vs. binary outcome | SciPy |
| Partial correlation | Association controlling for a confounder (age, unit) | pingouin |
| Mutual information | Non-linear dependence for feature selection | scikit-learn |
| Variance Inflation Factor (VIF) | Detect multicollinearity before regression | statsmodels |
| Correlation matrix / clustermap | Overview of feature redundancy | seaborn |

### 9. Regression & modeling statistics

| Method | Use it for | Where |
|---|---|---|
| Ordinary least squares (OLS) linear regression | Explain a continuous target; interpret coefficients | statsmodels |
| Regression diagnostics | Residual plots, Breusch–Pagan (heteroscedasticity), Durbin–Watson (autocorrelation), QQ of residuals, Cook's distance | statsmodels |
| Logistic regression | 24-hour deterioration label; interpretable baseline | statsmodels, scikit-learn |
| Regularized regression (Ridge, Lasso, Elastic Net) | Many correlated features; built-in selection | scikit-learn |
| Mixed-effects models (random intercept per patient) | Repeated measures — vitals are not independent within a patient | statsmodels `MixedLM` |
| Generalized Estimating Equations (GEE) | Population-average effects with within-patient correlation | statsmodels |
| Poisson / negative binomial regression | Count outcomes (number of alarms, events per day) | statsmodels |

### 10. Survival / time-to-event analysis

| Method | Use it for | Where |
|---|---|---|
| Kaplan–Meier estimator | Time-to-deterioration curves, handling censoring | lifelines |
| Log-rank test | Compare survival curves between groups | lifelines |
| Cox proportional hazards | Effect of vitals/features on deterioration hazard | lifelines |
| Time-varying covariates, Schoenfeld residuals | Check the proportional-hazards assumption | lifelines |

### 11. Drift, monitoring & statistical process control

| Method | Use it for | Where |
|---|---|---|
| Population Stability Index (PSI) | Feature / score distribution shift over time | Python, SQL bins |
| KS test, Wasserstein (earth-mover) distance | Continuous distribution drift (training vs. live) | SciPy |
| KL / Jensen–Shannon divergence | Categorical / binned distribution drift | SciPy |
| Chi-square drift test | Categorical feature drift | SciPy |
| Shewhart control charts (X̄-R, p-charts) | Sensor calibration drift, per-device error rate | Python, SQL |
| CUSUM, EWMA control charts | Detect small persistent shifts early | Python |
| PSI/AUC decay tracking | Model performance degradation → retrain trigger | MLflow + jobs |

### 12. Data-quality statistics

| Metric | Definition | Where |
|---|---|---|
| Completeness rate | non-null / total per column, per partition | SQL, Deequ |
| Validity rate | rows passing range/type/format rules | dbt tests, GE |
| Uniqueness / duplicate rate | distinct keys / total; exact + fuzzy dupes | SQL |
| Timeliness / staleness | now − max(event_time); gap distribution | SQL |
| Referential integrity rate | child rows with a matching parent (reading → patient/device/encounter) | SQL anti-joins |
| Consistency checks | cross-field rules (systolic > diastolic; SpO2 ≤ 100) | dbt, GE |
| Distribution stability | day-over-day PSI/KS on key columns | Python job |

### 13. Model-evaluation statistics

| Method | Use it for | Where |
|---|---|---|
| Confusion matrix, precision, recall, F1, specificity | Threshold-based classifier performance | scikit-learn |
| ROC curve & AUC, PR curve & AUC | Threshold-independent performance; PR-AUC for rare deterioration | scikit-learn |
| Bootstrap CIs for metrics | Uncertainty on AUC/F1 | scikit-learn, NumPy |
| DeLong test | Compare two models' ROC AUCs statistically | Python impl |
| Calibration curve, Brier score, Hosmer–Lemeshow | Are predicted probabilities trustworthy? | scikit-learn, statsmodels |
| Decision curve analysis | Net clinical benefit across thresholds | Python |
| Subgroup / fairness metrics | Performance by age, sex, unit, device | Python |
| Stratified k-fold, nested CV, time-series split | Honest generalization estimates; respect temporal order | scikit-learn |
| Class-imbalance handling: prevalence, class weights, SMOTE (train only) | Rare-event modeling | imbalanced-learn |

### Choosing a test — quick guide

- **Comparing 2 group means**, normal-ish, unequal variance → Welch's t-test (+ Cohen's d).
- **Comparing 2 groups**, skewed / ordinal → Mann–Whitney U.
- **Before vs. after on same patient** → paired t-test or Wilcoxon signed-rank.
- **3+ groups** → ANOVA (+ Tukey) or Kruskal–Wallis (+ Dunn).
- **Two categorical variables** → chi-square, or Fisher's exact for small counts.
- **Association, continuous** → Pearson (linear) or Spearman (monotonic / outliers).
- **Binary outcome, interpretable** → logistic regression (report odds ratios + CIs).
- **Repeated measures per patient** → mixed-effects model or GEE, not plain OLS.
- **Time to an event with censoring** → Kaplan–Meier + Cox.
- **"Has the data changed?"** → PSI / KS / JS divergence + a control chart.
- Always report an **effect size and a confidence interval**, and correct for **multiple testing**.

## SQL patterns to master

Practice these on the silver/gold tables (Snowflake syntax; adapt for Spark SQL):

- **Aggregation & grouping** — `GROUP BY`, `HAVING`, `GROUP BY ROLLUP/CUBE`, `FILTER (WHERE …)`,
  conditional aggregation with `CASE`.
- **Window functions** — `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`/`LEAD`, `FIRST_VALUE`/
  `LAST_VALUE`, `SUM/AVG … OVER (PARTITION BY patient_id ORDER BY event_time ROWS BETWEEN …)`.
- **Percentiles & stats aggregates** — `PERCENTILE_CONT`, `PERCENTILE_DISC`, `MEDIAN`, `STDDEV`,
  `VAR_POP`, `CORR`, `REGR_SLOPE`, `REGR_INTERCEPT`, `COVAR_POP`.
- **Time bucketing** — `DATE_TRUNC`, `TIME_SLICE`/`DATE_BIN`, generating a calendar/spine and
  `LEFT JOIN` to expose gaps.
- **Gaps-and-islands** — detect stale streams and missing intervals: difference of two
  `ROW_NUMBER()`s, or compare `event_time` to `LAG(event_time)` against the expected cadence.
- **Sessionization** — group readings into encounters/episodes with a running sum over a
  "new session" flag.
- **Deduplication** — `QUALIFY ROW_NUMBER() OVER (PARTITION BY natural_key ORDER BY ingest_time
  DESC) = 1`.
- **Referential integrity** — `LEFT JOIN … WHERE parent.id IS NULL` anti-joins; `EXCEPT` to diff
  expected vs. actual keys.
- **Data-quality queries** — completeness (`COUNT(col)/COUNT(*)`), range violations, duplicate
  counts, staleness, and cross-field consistency as a single reusable `dq_checks` view.
- **CTEs & readability** — layered `WITH` steps; `EXPLAIN` and pruning/clustering awareness.
- **Reshaping** — `PIVOT` / `UNPIVOT`, `LATERAL FLATTEN` for semi-structured device payloads.

## Repository structure

```text
healthcare-iot-platform/
├── README.md
├── data/
│   ├── raw/              # Synthetic or de-identified source datasets (incl. PhysioNet BIDMC)
│   ├── processed/        # Validated and feature-engineered outputs
│   └── sample/           # Small examples for demos and tests
├── schemas/              # Dataset and event contracts (Avro/Protobuf, HL7/FHIR mappings)
├── ingestion/            # Kafka producers, consumers, Connect config, topic settings, DLQ
├── processing/           # PySpark cleaning, resampling, validation, and feature logic
├── analysis/             # EDA notebooks, statistical tests, drift reports  (to be added)
├── storage/              # Lakehouse (bronze/silver/gold) and time-series database integration
├── models/               # Risk-model training, prediction, evaluation, feature store
│   └── saved_models/     # Locally generated model artifacts
├── rag/                  # Graph modeling, retrieval, multi-agent chatbot workflow
├── api/                  # Planned service entry point and API routes
│   └── routes/
├── dashboard/            # Planned monitoring dashboard
├── tests/                # Planned automated tests and data-quality suites
└── docs/                 # Architecture, data dictionary, deployment, and privacy docs
```

## Dataset plan

Only synthetic or properly de-identified data should be used. Downloaded PhysioNet files under
`data/raw/` (e.g. the BIDMC PPG and Respiration dataset) must remain local and be handled under
their license.

### Planned datasets

- `patients.csv`: patient demographics and background information.
- `sensor_readings.csv`: timestamped heart rate, SpO2, ECG, temperature, blood pressure, and
  respiratory-rate readings.
- `device_metadata.csv`: device type, firmware, calibration, and hospital-unit metadata.
- `data_quality_events.csv`: missing, duplicate, stale, noisy, and out-of-range data-quality events.
- `clinical_events.csv`: admissions, medication events, deterioration events, and discharge events.
- `patient_risk_labels.csv`: risk scores, risk levels, and 24-hour deterioration labels.
- `feature_store.csv`: rolling-window features used by the risk model.

## 20-day delivery plan

| Day | Planned work | Skill focus |
|---:|---|---|
| 1 | Finalize requirements, architecture, and technology choices | — |
| 2 | Create the repository structure and documentation outline | — |
| 3 | Define dataset and event schemas (Avro/Protobuf) and the data dictionary | collection |
| 4 | Generate synthetic patient and device metadata | collection |
| 5 | Generate synthetic real-time sensor readings; load PhysioNet BIDMC | collection |
| 6 | Inject missing, duplicate, noisy, stale, and out-of-range values | cleaning |
| 7 | Design Kafka topics, message formats, schema registry, and DLQ | collection |
| 8 | Define producer, consumer, and Kafka Connect (HL7/FHIR) flow | collection |
| 9 | Design lakehouse layers and time-series tables; write SQL profiling views | SQL |
| 10 | PySpark preprocessing: resampling, interpolation, dedupe, artifact rejection | transform + clean |
| 11 | **EDA**: descriptive stats, distribution & normality checks, missingness analysis | statistics |
| 12 | Sensor-quality, statistical outlier, and drift rules; dbt/GE data contracts | statistics + SQL |
| 13 | **Hypothesis testing & correlation**: deteriorating vs. stable, feature screening | statistics |
| 14 | Rolling-window features (SQL window funcs + PySpark); feature-store definitions | SQL + transform |
| 15 | Train baseline logistic-regression and gradient-boosted risk models | statistics + ML |
| 16 | **Statistical model evaluation**: ROC/PR AUC + bootstrap CI, calibration, subgroup | statistics |
| 17 | Survival analysis (Kaplan–Meier, Cox) for time-to-deterioration; register in MLflow | statistics |
| 18 | Risk-prediction output datasets; stream feedback; PSI/control-chart drift monitors | statistics |
| 19 | Prepare medical reference docs and graph model; retrieval + multi-agent workflow | tooling |
| 20 | API, dashboard, SLA-tiered Airflow; tests, observability, privacy docs; README + review | tooling |

## Safety and privacy

This is a software-development project, not a clinical decision-making system. Do not commit
protected health information, real patient identifiers, credentials, model secrets, or unapproved
medical content. Any future model or statistical output must be clearly labeled as experimental,
pass the guardrail agent, and be reviewed for clinical safety before use. Audit logging and access
control (Unity Catalog masking, column-level permissions) are required for any PHI-adjacent path.

## Current status

The initial repository scaffold, enhanced architecture, statistical-method reference, and 20-day
plan are in place. Implementation will be added incrementally. The next implementation gate is a
synthetic event flowing end to end through Kafka, schema validation, a DLQ path, and a bronze sink
before enabling any model or clinician-facing behavior.
