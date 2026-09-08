# Observability and CI/CD

## What observability means here

Observability makes the platform's internal state visible through **metrics, logs, traces, and
audit events**. It answers whether data arrived, whether it was valid, whether processing is fresh,
and whether model behavior changed. It is not a substitute for clinical review.

The Prometheus rules in `ops/alert-rules.yml` cover four first signals:

- **Kafka lag:** consumers are falling behind real-time ingestion.
- **DLQ rate:** malformed or out-of-contract events are increasing.
- **Delta freshness:** bronze/silver/gold tables are stale.
- **Feature drift:** live feature distributions differ from the training baseline.

The future application metrics should use names such as `healthcare_events_processed_total`,
`healthcare_dlq_messages_total`, `healthcare_delta_table_age_seconds`, and
`healthcare_feature_drift_score`. Logs must contain correlation IDs and event IDs, but never direct
patient identifiers or raw clinical payloads. Audit records should capture actor, purpose, resource,
model version, policy decision, and timestamp.

## What CI/CD artifacts mean here

`.gitlab-ci.yml` describes the automated delivery path:

1. **Validate:** compile Python and check basic repository structure.
2. **Quality:** inspect data-contract changes without requiring PHI or a production dataset.
3. **Security:** fail when common credential or private-key patterns are committed.
4. **Package:** attach build metadata so a deployed artifact can be traced to a commit.
5. **Deploy:** require manual protected-environment approvals for staging and production.

When implementation exists, the placeholder package job should build the stream/ETL image, publish
versioned schemas, run dbt/Great Expectations checks, and register model artifacts in MLflow. A model
must not be promoted solely because CI is green: evaluation, drift, privacy, rollback, and clinical
governance gates remain separate requirements.

## Local use

The configuration expects a service exposing Prometheus metrics on `localhost:8000`. A local
Prometheus instance can load `ops/prometheus.yml`; Grafana can use Prometheus as its data source.
Production credentials, alert routing, retention, and PHI access policies belong in protected
deployment configuration, never in this repository.