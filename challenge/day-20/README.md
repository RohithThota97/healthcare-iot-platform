# Day 20 — API, Dashboard, SLA-Tiered Airflow, Tests, Observability, Privacy Docs & Final Review

**Phase:** RAG, serving, ops · **Time budget:** 10–12 h · **Skill focus:** tooling, orchestration, delivery
**Prereqs:** Days 1–19. This day is integration + hardening + presentation, not new modeling.

## Why this day matters

Everything so far is components. Today you make it a *platform*: a service in front of it, a
dashboard a clinician could look at, orchestration that respects the two SLA tiers, a test suite
and CI that actually gate, observability wired end to end, honest privacy/compliance docs, and a
final review pass. Then you rehearse the whole story for the Day 20 mock interview.

## Challenges

### C1 — API service (~2 h)
- A FastAPI (or similar) service exposing: `GET /patients/{id}/risk` (latest score + trend +
  contributing features), `GET /patients/{id}/vitals?window=`, `POST /ask` (the Day 19 RAG
  agent), `GET /healthz`, `GET /metrics`.
- Auth stub (API key / bearer), request logging with correlation IDs, **no PHI in logs**.
- Acceptance: `api/` runs via `make api`; OpenAPI docs render; endpoints return real data from
  your stores; a smoke test hits each.

### C2 — Dashboard (~2 h)
- A Streamlit/Dash (or static + API) dashboard: unit overview (patients by risk band), a
  per-patient vitals + risk timeline, the DQ scorecard, and the drift/monitoring panel.
- Acceptance: `make dashboard` serves it; it reads through the API (not straight from files);
  a screenshot in `docs/img/dashboard/`.

### C3 — SLA-tiered Airflow (~3 h)
- Two (or more) DAGs split by SLA tier:
  - **Real-time/near-real-time tier:** sensors on Kafka lag + Delta freshness; short schedule;
    tight SLA; triggers streaming health checks and micro-batch silver.
  - **Nightly batch tier:** full silver rebuild → dbt/GE contracts → feature materialize →
    batch scoring → drift/perf monitors → registry gate check.
- Real retries, SLAs, alerting on miss, and task-level idempotency.
- Acceptance: `airflow dags list` shows both; a local run of the nightly DAG completes green on
  sample data; the SLA/alert config is real, not default.

### C4 — Test suite, CI, observability, privacy (~3 h)
- Consolidate tests into `tests/` with markers (`unit`, `integration`, `e2e`, `data_quality`).
  CI runs unit+integration on every PR; e2e on a schedule or label.
- Observability end to end: every long-running component exports the `healthcare_*` metrics from
  the observability doc; Prometheus scrapes them; Grafana has a single "platform health"
  dashboard; `ops/alert-rules.yml` covers Kafka lag, DLQ rate, Delta freshness, feature drift,
  model perf, and pipeline SLA miss.
- `docs/privacy.md`: data classification, where PHI-adjacent data lives, masking/access-control
  approach (Unity Catalog substitute), audit-log schema (actor, purpose, resource, model
  version, decision, timestamp), retention, and a GDPR erasure procedure across every store
  (bronze, silver, feature store, model, graph, vector DB).
- Acceptance: `make test` green; CI green; Grafana health dashboard screenshot; `docs/privacy.md`
  covers all stores with a concrete erasure runbook.

### C5 — Final review & demo (~2 h)
- Update the top-level `README.md` "Current status" and the 20-day plan table with what's
  actually done vs. deferred.
- Write `docs/DEMO.md`: a 10-minute scripted walkthrough (start infra → produce a deteriorating
  patient → see DQ + drift → see the alert → query the RAG agent → show the dashboard).
- Run `/security-review` (or a manual pass) on the branch; fix or file what it finds.
- Do the **Day 20 mock interview** from [INTERVIEW-PREP.md](../INTERVIEW-PREP.md); record it.
- Acceptance: `docs/DEMO.md` runs end to end in one sitting; mock interview done and weak spots
  logged in `PROGRESS.md`.

## Deliverables (branch `day-20-integration`)

- `api/`, `dashboard/`, `ops/airflow/` DAGs, consolidated `tests/`, `.github/workflows/` updated
- `ops/alert-rules.yml` extended, `ops/grafana/` dashboards
- `docs/privacy.md`, `docs/DEMO.md`, updated root `README.md`
- Final PR against `main` summarizing the whole build

## Definition of done

- [ ] API serves risk / vitals / ask / health / metrics; no PHI in logs; smoke tests pass.
- [ ] Dashboard reads through the API; screenshot committed.
- [ ] Two SLA-tiered Airflow DAGs with real retries/SLAs; nightly DAG runs green on sample data.
- [ ] `tests/` markered; CI gates unit+integration; e2e runs on schedule/label.
- [ ] End-to-end observability: `healthcare_*` metrics + Grafana health board + 6 alert rules.
- [ ] `docs/privacy.md` covers every store + a concrete GDPR erasure runbook.
- [ ] `docs/DEMO.md` runs in one sitting; Day 20 mock interview recorded; `PROGRESS.md` updated.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Keep the API thin: it reads from DuckDB/Postgres/feature store/MLflow, it doesn't recompute.
- Airflow locally: the `apache/airflow` Docker image or `astro`/`standalone`; `LocalExecutor` is
  plenty. Put DAGs in `ops/airflow/dags/` and mount them.
- SLA tiers = separate DAGs with different `schedule_interval`, `sla`, `retries`, and alert
  routing — plus Kafka-lag / Delta-freshness sensors gating the real-time one.
- Task idempotency: every task writes to a deterministic partition keyed by the run's logical
  date so a re-run overwrites cleanly.
- Erasure runbook: bronze (rewrite the affected Parquet/Delta partitions minus the patient),
  silver/gold (rebuild from bronze), feature store (delete entity rows online + offline),
  model (document that retraining excludes them; you don't un-train), graph (`DETACH DELETE`),
  vector DB (delete chunks — you shouldn't have PHI chunks anyway).
- For the demo, script it as a `Makefile` target sequence so it's repeatable under pressure.
