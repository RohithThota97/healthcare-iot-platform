# Enhanced architecture

## Boundaries

1. **Ingestion.** Device producers publish `vitals.raw.v1`; Kafka Connect normalizes permitted HL7/FHIR feeds into `clinical.raw.v1`. Avro is the default contract and Protobuf is acceptable for waveform payloads. Schema Registry uses backward-compatible evolution. Invalid payloads go to `vitals.dlq.v1` with a reason, source, schema id, and correlation id, never silently dropped.
2. **Streaming.** Kafka Streams or Flink owns keyed state by `patient_token` and `device_token`. It computes sliding windows, sampling-rate observations, drift scores, and an experimental early-warning candidate. A candidate is an alerting signal, not a diagnosis; downstream consumers enforce deduplication, cooldowns, and human review.
3. **Lakehouse.** Bronze stores immutable source envelopes in S3/Delta. Silver applies identity-safe normalization, unit conversion, interpolation/resampling, duplicate detection, artifact rejection, and Great Expectations/Deequ checks. Gold publishes aggregate features and quality events. Delta Z-ordering is appropriate for `patient_token`, `device_token`, and `event_time`; ECG waveforms may also use TimescaleDB/InfluxDB for low-latency retrieval.
4. **Serving.** Snowflake receives approved gold tables for BI and dashboards through a separate serving path. ML training and inference do not depend on Snowflake availability. Unity Catalog owns lineage, table permissions, row filters, and PHI masking policies in the Databricks deployment.
5. **ML.** Feast or Databricks Feature Store is the single feature definition source for online inference and batch training. MLflow tracks datasets, code, metrics, model signatures, approvals, and rollback versions. Drift monitoring compares feature distributions and performance proxies; it must never auto-promote a model into clinical use.
6. **GraphRAG.** Neo4j stores `Patient -> Encounter -> Vital -> Intervention -> Outcome` relationships using tokens only. pgvector or Weaviate stores embeddings for approved reference content. LangGraph coordinates retrieval, clinical reasoning, and safety agents. The safety agent blocks diagnosis, unsupported treatment recommendations, direct-identifier requests, and answers without provenance.
7. **Operations.** Airflow separates real-time recovery/quality DAGs from nightly batch DAGs, with Kafka-lag and Delta-freshness sensors. Prometheus/Grafana covers lag, throughput, DLQ rate, freshness, quality failures, model drift, and agent latency. Audit logs record access purpose, actor, source documents, model version, and response policy outcome.

## Reliability and security invariants

- At-least-once delivery is expected; every consumer is idempotent on `event_id`.
- Partition only on a non-identifying routing token after privacy review.
- Retention, deletion, and reprocessing policies are explicit per environment. Raw data is encrypted in transit and at rest.
- Secrets come from a managed secret store or protected CI variables. `.env` and raw data are ignored by Git.
- No real PHI, credentials, or unapproved clinical reference material may be committed.
- NEWS2 and other scores are research outputs until clinically validated and institutionally approved.

## Topic contract

| Topic | Producer | Consumer | Retention |
|---|---|---|---|
| `vitals.raw.v1` | device gateway | stream processor, bronze sink | short/regulated |
| `clinical.raw.v1` | HL7/FHIR Connect | trajectory normalizer, bronze sink | regulated |
| `vitals.alert-candidate.v1` | stream processor | alert service, audit sink | short |
| `vitals.dlq.v1` | validators | quarantine/replay workflow | regulated |
| `quality.events.v1` | silver jobs | quality dashboard, Airflow | long |

## Promotion gates

An environment may progress only when contract compatibility, replay/idempotency, data-quality thresholds, privacy checks, model evaluation, drift thresholds, audit logging, and manual clinical governance review all pass. A passing software test is not evidence of clinical safety.