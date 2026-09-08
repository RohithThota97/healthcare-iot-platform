# Day 2 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `pyproject.toml` build backend (hatchling / setuptools / poetry-core) | Installable package | `pip install -e ".[dev]"` succeeds from a clean env |
| Lockfile tool (`uv pip compile`, `pip-tools`, `poetry lock`, `conda-lock`) | Deterministic installs | Lockfile committed; regenerating it produces no diff |
| `docker compose` v2 | Local infra stack | `docker compose config` validates; every service has a `healthcheck` |
| `pre-commit` | Local gates | `pre-commit install` run once; `pre-commit run --all-files` clean |
| `ruff` (+ `ruff format`) or `black` + `flake8` | Lint + format | One formatter only; CI and pre-commit use the same version |
| `detect-secrets` or `gitleaks` | Secret scanning | Baseline committed; hook fails on a planted `AWS_SECRET_ACCESS_KEY=...` |
| GitHub Actions | PR CI | Workflow triggers on `pull_request`; uses dependency caching |
| `pytest` | Test runner | `pytest -q` green with at least one real assertion |

### Compose starter services (grow into these later)

- **Broker:** `redpandadata/redpanda` (single binary, Kafka API) *or* `confluentinc/cp-kafka`
  + `confluentinc/cp-schema-registry`. Pick now; you'll configure it properly on Day 7.
- **Postgres:** `postgres:16` — will back the feature store online store and MLflow later.
- **Prometheus:** `prom/prometheus` mounting the repo's existing `ops/prometheus.yml`.
- **Grafana:** `grafana/grafana` with Prometheus pre-provisioned as a datasource.

### Traps

- Compose without healthchecks makes `make up` "succeed" before Kafka is listening — every Day 7+
  script then flakes. Fix it here.
- Don't pin container images to `latest`; pin a tag so CI and your laptop match.
- Secret scanners flag base64 in test fixtures. Learn the allowlist/inline-ignore syntax now,
  not at 11 p.m. on Day 8.
