# Healthcare IoT Real-Time Patient Monitoring Platform

A planned healthcare IoT platform for ingesting real-time patient vital signs, validating sensor data, storing time-series measurements, detecting anomalies, estimating patient risk, and supporting natural-language patient summaries.

> This repository currently contains the project structure and delivery plan only. It does not include application code or clinical data.

## Planned capabilities

- Ingest patient and sensor events through Kafka.
- Store time-series readings in InfluxDB or TimescaleDB.
- Clean, validate, and transform data with PySpark.
- Detect missing, duplicate, stale, noisy, and out-of-range readings.
- Generate rolling-window features for patient-risk prediction.
- Train and evaluate a baseline patient deterioration model.
- Provide a retrieval-augmented chatbot for patient summaries.

## Repository structure

```text
healthcare-iot-platform/
├── README.md
├── data/
│   ├── raw/              # Synthetic or de-identified source datasets
│   ├── processed/        # Validated and feature-engineered outputs
│   └── sample/           # Small examples for demos and tests
├── schemas/              # Dataset and event contracts
├── ingestion/            # Kafka producers, consumers, and topic settings
├── processing/           # PySpark cleaning, validation, and feature logic
├── storage/              # Time-series database integration and schema
├── models/               # Risk-model training, prediction, and evaluation
│   └── saved_models/     # Locally generated model artifacts
├── rag/                  # Document loading, retrieval, and chatbot workflow
├── api/                  # Planned service entry point and API routes
│   └── routes/
├── dashboard/            # Planned monitoring dashboard
├── tests/                # Planned automated tests
└── docs/                 # Architecture, data dictionary, deployment, and privacy docs
```

## Dataset plan

Only synthetic or properly de-identified data should be used.

### Planned datasets

- `patients.csv`: patient demographics and background information.
- `sensor_readings.csv`: timestamped heart rate, SpO2, ECG, temperature, blood pressure, and respiratory-rate readings.
- `device_metadata.csv`: device type, firmware, calibration, and hospital-unit metadata.
- `data_quality_events.csv`: missing, duplicate, stale, noisy, and out-of-range data-quality events.
- `clinical_events.csv`: admissions, medication events, deterioration events, and discharge events.
- `patient_risk_labels.csv`: risk scores, risk levels, and 24-hour deterioration labels.
- `feature_store.csv`: rolling-window features used by the risk model.

## 20-day delivery plan

| Day | Planned work |
|---:|---|
| 1 | Finalize requirements, architecture, and technology choices |
| 2 | Create the repository structure and documentation outline |
| 3 | Define dataset schemas and the data dictionary |
| 4 | Generate synthetic patient and device metadata |
| 5 | Generate synthetic real-time sensor readings |
| 6 | Add missing, duplicate, noisy, and out-of-range values |
| 7 | Design Kafka topics and message formats |
| 8 | Define the producer and consumer flow |
| 9 | Design InfluxDB/TimescaleDB tables |
| 10 | Define preprocessing and validation logic |
| 11 | Add sensor-quality and anomaly-detection rules |
| 12 | Create rolling-window features |
| 13 | Train a baseline patient-risk model |
| 14 | Evaluate the model and document metrics |
| 15 | Create risk-prediction output datasets |
| 16 | Prepare medical reference documents for RAG |
| 17 | Define retrieval and patient-summary workflows |
| 18 | Define API and dashboard requirements |
| 19 | Add tests, privacy documentation, and example workflows |
| 20 | Complete the README, architecture diagram, demo plan, and review |

## Safety and privacy

This is a software-development project, not a clinical decision-making system. Do not commit protected health information, real patient identifiers, credentials, model secrets, or unapproved medical content. Any future model output must be clearly labeled as experimental and reviewed for clinical safety before use.

## Enhanced architecture

The platform now separates real-time alerting from batch analytics:

- Kafka plus Schema Registry carries versioned Avro/Protobuf vitals and HL7/FHIR-normalized events. Kafka Streams/Flink computes windows, drift signals, and experimental early-warning candidates; malformed messages go to a replayable DLQ.
- S3 and Delta Lake provide bronze, silver, and gold layers. PySpark handles resampling, interpolation, duplicate detection, and artifact rejection. Databricks Unity Catalog governs lineage and masking; Snowflake is an independent BI-serving path.
- Feast or Databricks Feature Store keeps online and batch features consistent. MLflow records model lineage and promotion gates. Outputs are experimental decision support, not diagnoses.
- Neo4j models patient trajectories while pgvector or Weaviate supports semantic retrieval. LangGraph coordinates retrieval, reasoning, and safety agents with provenance and audit requirements.
- Airflow separates five-minute quality/recovery checks from nightly batch work. Prometheus/Grafana monitors lag, freshness, DLQs, quality failures, drift, and latency.

See [docs/architecture.md](docs/architecture.md), [ingestion/README.md](ingestion/README.md), and [ingestion/topics.yaml](ingestion/topics.yaml) for the contracts and operating rules.

## Local development

```bash
cp .env.example .env
docker compose up -d
make validate
```

The repository excludes raw and generated data, credentials, and model artifacts by default. The downloaded PhysioNet files under `data/raw/` must remain local and be handled under their license.

## Current status

Architecture contracts, local service wiring, topic definitions, CI stages, observability configuration, and Airflow SLA skeletons are in place. The next implementation gate is a synthetic event flowing through Kafka, schema validation, a DLQ path, and a bronze sink before enabling model or clinician-facing behavior.
