# Day 12 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `dbt-core` + `dbt-duckdb` (or `dbt-postgres`) | Model + test silver/gold | `dbt debug` green; `profiles.yml` points at your Day 9 warehouse |
| `dbt-expectations` and/or `elementary-data` (optional) | GE-style + anomaly tests in dbt | Add to `packages.yml`, `dbt deps` |
| `great_expectations` (1.x) | Contract at the bronze→silver boundary | `great_expectations` (not `great-expectations` typo); `gx.get_context()` works file-based |
| `PyDeequ` (alternative to GE) | JVM-based data-quality on Spark | Needs Spark + the Deequ jar; only if you're already deep in Spark |
| `scipy.stats` | KS, Wasserstein, chi-square, entropy (KL/JS) | `wasserstein_distance`, `ks_2samp`, `entropy` |
| `scikit-learn` | Isolation Forest / LOF (stretch) | `IsolationForest(contamination=...)` — set contamination from your injected rate |
| `river` (optional) | Online/streaming drift (ADWIN, Page-Hinkley) | Only if you want streaming drift for Day 18 |

### Config checkpoints

- dbt: set `materialized` per model (view for silver-thin, table for gold), and a `--target`
  for `dev` vs. `ci`.
- GE: use the modern fluent API + a file-based `DataContext` committed to the repo; store the
  baseline as an asset, not inline.
- Pin the drift baseline: commit `analysis/drift/baseline/*.json` (bin edges + frequencies +
  the window it came from).

### Traps

- dbt + DuckDB single-file DB locks under concurrent access — run dbt and ad-hoc queries
  serially, or use separate DB files.
- PSI/KL blow up when a bin has zero probability — add a small epsilon or use `JS` divergence
  (bounded, symmetric).
- GE version churn: the 0.15 vs 0.18 vs 1.x APIs are very different. Pick 1.x and follow *its*
  docs only.
- A drift metric with no baseline window definition is meaningless — always record "baseline =
  which dates, which filter".
