# Day 14 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| DuckDB / Postgres | SQL feature build | `RANGE BETWEEN INTERVAL` windowing supported in your engine |
| `pyspark` | Batch feature build (training path) | `spark.sql.session.timeZone=UTC`; `rangeBetween` on a long-cast timestamp |
| `feast` | Feature store (offline + online + PIT joins) | `feast apply` succeeds; `feature_store.yaml` has a file offline store + a Postgres online store |
| Postgres (from compose) | Feast online store | `feast materialize` writes rows; `psql` shows them |
| `pandas` | Reconciliation diff, hand-check | Compare on a sorted, keyed join; report `max(abs(diff))` per feature |
| `pytest` | PIT + skew tests | Deterministic fixtures with a known "future" row that must be excluded |

### Config checkpoints

- One source of truth for each feature's cutoff logic — a shared Python function imported by both
  the Spark job and the online path. Don't re-express the window in two places.
- Feast `feature_store.yaml`: set `offline_store: type: file` (your gold Parquet) and
  `online_store: type: postgres`. Record the registry location.
- Decide feature timestamp semantics: is `feature_timestamp` the bucket start or bucket end?
  Write it down; it's the #1 reconciliation mismatch.

### Traps

- SQL `ROWS BETWEEN N PRECEDING` counts rows, not time — wrong on irregular data. Use `RANGE`
  with an interval.
- Spark `rangeBetween` needs a numeric ordering column (cast timestamp to `long` seconds).
- Feast `get_historical_features` is PIT-correct by design, but only if your entity spine
  timestamps are the label times — not "now".
- Postgres online store: `feast materialize-incremental` vs. `materialize` — know which you ran
  when a value looks stale.
- Float aggregation order differs between Spark and SQL — a `1e-9` diff is fine; a `1e-2` diff
  is a real bug.
