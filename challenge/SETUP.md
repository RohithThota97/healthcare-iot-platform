# Setup — do this before Day 1 (budget: 2–4 h)

The goal of setup is a **reproducible local environment**. If you can't rebuild it from a
fresh clone in under 30 minutes, it's not done.

## What you need to decide (not just install)

- **Python version** — pick one (3.11 is a safe default for Spark + ML libs) and pin it.
- **Environment manager** — `venv` + `pip-tools`, `conda`/`mamba`, `uv`, or `poetry`.
  Pick one and be able to justify it in an interview.
- **Container runtime** — Docker Desktop, Colima, Podman, or Rancher Desktop. You will run
  Kafka, Postgres, Prometheus, Grafana, Neo4j, and MLflow as containers.
- **JVM** — Spark and Kafka tooling need a JDK (17 is current LTS for Spark 3.5+). Decide how
  you manage it (`sdkman`, Homebrew, system).

## Baseline tooling checklist

| Tool | Purpose | Config checkpoint |
|---|---|---|
| Git + a GitHub account | Branch-per-day, PR review loop | `git config user.email` matches your account |
| Python 3.11 + env manager | All Python work | `python -V` inside the activated env is 3.11.x |
| JDK 17 | Spark, Kafka CLI tools | `java -version` prints 17; `JAVA_HOME` set |
| Docker (or Colima) + Compose v2 | Local infra | `docker compose version` works; can run `hello-world` |
| `make` | Task runner for the repo | `make` present (`xcode-select --install` on macOS) |
| `pre-commit` | Lint/format/secret-scan on commit | `pre-commit --version` |
| `duckdb` CLI | Fast local SQL over Parquet/CSV | `duckdb -c "select 1"` |
| `jq`, `yq` | Poking at JSON/YAML configs | both on `PATH` |
| A SQL client | Exploring Postgres/DuckDB | your choice (DBeaver, `psql`, VS Code ext.) |

Language-specific libraries (pandas, pyspark, scikit-learn, statsmodels, lifelines, great_expectations,
dbt, mlflow, confluent-kafka, langchain, …) get installed **on the day you first need them**, so the
dependency file grows with a reason attached to each addition. Don't front-load a 60-line
`requirements.txt` you can't explain.

## Repo hygiene to set up now

- A `Makefile` with at least `setup`, `lint`, `test`, `up` (infra), `down` targets — even if
  they're near-empty stubs today.
- `.pre-commit-config.yaml` with a formatter (black/ruff-format), a linter (ruff), and a
  secret scanner (detect-secrets or gitleaks). The parent repo's `.gitlab-ci.yml` already
  fails on committed secrets — mirror that locally.
- `docs/adr/0000-adr-process.md` — adopt a lightweight ADR format (Nygard style). Every day
  you make a technology or design choice, you write one.
- A `challenge/PROGRESS.md` row filled in per day.

## The local vs. cloud substitution table (write this as your first ADR)

| Architecture calls for | You will run locally | Why it's a fair substitute |
|---|---|---|
| Kafka + Schema Registry | Redpanda **or** Kafka+Karapace/Apicurio via Compose | Same protocol, same client code |
| S3 + Delta Lake | Local filesystem + `delta-spark` **or** MinIO | Delta is storage-agnostic |
| Databricks + Unity Catalog | Local Spark + a `catalog/` dir + documented column masking | Exercises the modeling, not the vendor |
| Snowflake serving layer | DuckDB **or** Postgres | Window functions + percentiles are ANSI-ish |
| Databricks Feature Store / Feast | Feast with a local registry + Postgres online store | Real Feast API |
| Neo4j Aura | Neo4j Community in Docker | Identical Cypher |

## Definition of done for setup

- [ ] `git clone` → `make setup` → activated env with pinned Python.
- [ ] `make up` starts at least one placeholder container and `make down` stops it.
- [ ] `pre-commit run --all-files` passes on the current repo.
- [ ] `docs/adr/0001-local-substitutions.md` written and committed.
- [ ] `challenge/PROGRESS.md` has a Day 0 entry.
