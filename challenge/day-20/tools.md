# Day 20 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `fastapi` + `uvicorn` | The platform API | `/docs` renders OpenAPI; `/healthz` and `/metrics` respond |
| `prometheus-fastapi-instrumentator` (or manual) | API metrics | request latency/count histograms exported on `/metrics` |
| `streamlit` **or** `dash` | Clinician dashboard | reads via `requests` to the API, not files; `make dashboard` serves it |
| Apache Airflow (`apache/airflow` image, `LocalExecutor`) | SLA-tiered orchestration | `airflow standalone` or compose; DAGs mounted; `airflow dags test <dag> <date>` runs one |
| `pytest` (+ `pytest-markers`, `pytest-cov`) | Consolidated suite | markers registered in `pyproject.toml`; `make test` runs unit+integration |
| Prometheus + Grafana (from Day 2) | End-to-end observability | all `healthcare_*` metrics scraped; one "platform health" dashboard JSON in `ops/grafana/` |
| `/security-review` skill or `bandit`/`gitleaks`/`pip-audit` | Final security pass | run on the branch; triage findings |

### Config checkpoints

- API: structured JSON logging with a `correlation_id`; a log filter that drops/masks any field
  matching identifier patterns. Test that a request with a patient id does **not** put the id in
  the log line.
- Airflow: set `default_args` with `retries`, `retry_delay`, `sla`; configure an SLA-miss
  callback that emits a metric/alert. Different `schedule_interval` per tier.
- Grafana: provision datasource + dashboards from files (`ops/grafana/provisioning/`) so it's
  reproducible, not click-configured.

### Traps

- Airflow's scheduler + webserver + DB in Docker is heavy on a laptop — use `LocalExecutor`,
  disable example DAGs (`AIRFLOW__CORE__LOAD_EXAMPLES=False`), and only run the nightly DAG once
  for the demo.
- A dashboard that reads Parquet directly bypasses your API contract and auth — make it go
  through the API.
- `pytest` markers not registered → warnings become errors in strict CI. Declare them.
- Don't add new model work today. If something's broken from Days 15–18, cut scope in the demo
  script and note it in the README status — a working narrower demo beats a broken broad one.
