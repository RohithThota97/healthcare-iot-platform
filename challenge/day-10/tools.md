# Day 10 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `pyspark` 3.5.x | The transform engine | `SparkSession.builder.master("local[*]")`; `spark.range(5).show()` works; JDK 17 |
| `delta-spark` (matching Spark version) | Read/write Delta silver | `configure_spark_with_delta_pip` or the right `--packages`; version must match Spark |
| Spark UI (`localhost:4040`) | See stages, tasks, skew, shuffle | Reachable while a job runs; screenshot the skewed stage |
| `scipy` / `pandas` (inside pandas UDFs) | Hampel, spline, Sav–Gol | `pyarrow` installed so pandas UDFs work; watch Arrow max records per batch |
| `pytest` + a tiny local Spark fixture | Test the transforms on fixtures | Session-scoped Spark fixture; keep test data 10s of rows |

### Spark config checkpoints

- `spark.sql.adaptive.enabled=true` and `spark.sql.adaptive.skewJoin.enabled=true` — turn on AQE
  and *then* measure, so you can speak to what it did.
- `spark.sql.shuffle.partitions` — the default 200 is silly for local; set it to ~ `2–3 ×
  cores`.
- `spark.sql.execution.arrow.pyspark.enabled=true` for pandas UDF performance.
- Set `spark.driver.memory` if you OOM on a wide collect (you shouldn't be collecting).

### Traps

- `delta-spark` version mismatch with Spark = cryptic `NoSuchMethod` errors. Pin both.
- Windowed operations without an explicit frame default to
  `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` — not what you want for a rolling median.
- `pandas_udf` grouped-map gives you the whole group in memory — fine per patient-signal, not
  fine if you group too coarsely.
- Timezones: Spark reads timestamps as session-local. Set `spark.sql.session.timeZone=UTC`.
- Local Spark on Apple Silicon: use a native `arm64` JDK; Rosetta JDK is slow.
