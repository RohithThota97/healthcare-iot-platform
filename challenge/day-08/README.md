# Day 8 — Producers, Consumers & Kafka Connect (HL7/FHIR)

**Phase:** Streaming & storage · **Time budget:** 10–12 h · **Skill focus:** data collection, integration
**Prereqs:** Day 7 merged; topics + DLQ + registry configured.

## Why this day matters

Now the pipe carries real traffic. You'll build a device simulator that replays your Day 5/6
stream files through Kafka with schema-registry serialization, a validating consumer that sinks
to bronze and dead-letters the rest, and an ingestion path for legacy HL7v2/FHIR that lands on
the **same** contract. This is the "synthetic event flowing end to end" gate from the parent
README.

## Challenges

### C1 — Producer / device simulator (~3 h)
- Replay `data/processed/stream/` (clean) and `stream_corrupted/` (Day 6) into the raw topics
  with registry-based serialization, correct key, and the standard headers from Day 7.
- Support rate control: `--speed` multiplier and a `--realtime` mode that respects `event_time`
  gaps. Stamp `ingest_time` at send.
- Handle the deliberately un-encodable records: the producer should route what it can't serialize
  straight to the DLQ with an error header (or a separate "producer reject" path — decide).
- Acceptance: `make produce` streams the dataset; `kcat`/console shows records with headers and
  a resolvable schema id; throughput and lag are visible.

### C2 — Validating consumer → bronze sink (~3.5 h)
- Consume raw topics, deserialize via registry, apply validation (schema already enforced;
  add business rules: physiological hard bounds, required identifiers, `event_time` sanity).
- Valid → append to a bronze store (Parquet/Delta on local FS) **idempotently** (dedup on
  `event_id`). Invalid → DLQ topic with metadata. Commit offsets only after the write.
- Emit Prometheus metrics: `healthcare_events_processed_total`, `healthcare_dlq_messages_total`,
  consumer lag, write latency (names per `docs/observability-and-cicd.md`).
- Acceptance: run producer + consumer against the corrupted stream; bronze row count + DLQ count
  + dedup count reconcile with the Day 6 ground truth within tolerance; metrics scrape on `:8000`.

### C3 — HL7/FHIR ingestion via Kafka Connect (or a documented shim) (~3 h)
- Stand up Kafka Connect (or, if Connect eats too much time, a clearly-labeled standalone
  "connector-shaped" service) that reads sample HL7v2 `ORU^R01` messages and FHIR `Observation`
  resources and produces your **canonical** vitals events, using the Day 3 mapping.
- Handle mapping failures → DLQ with the raw message attached.
- Acceptance: a sample HL7 file and a sample FHIR bundle both result in canonical events on the
  same topic your device simulator uses, consumed and sunk to bronze indistinguishably.

### C4 — End-to-end smoke test (~2 h)
- One command / test that: creates topics, starts producer + consumer, feeds a fixed small
  corrupted dataset + HL7 + FHIR samples, and asserts bronze contents, DLQ contents, and metric
  values.
- Acceptance: `make e2e` (or `pytest tests/e2e/`) green and repeatable; documented in
  `docs/streaming/e2e.md`.

### Stretch (optional)
- Add a retry topic with backoff between raw and DLQ for transient failures.
- Add exactly-once-ish: idempotent producer + transactional consume-process-produce for the
  aggregates path.

## Deliverables (branch `day-08-ingest`)

- `ingestion/producer/`, `ingestion/consumer/`, `ingestion/connect/` (config + transforms or shim)
- Bronze writer module (shared with Day 9), Prometheus metrics exporter
- `tests/e2e/`, `docs/streaming/e2e.md`
- Grafana panel or a screenshot of lag + throughput during a run

## Definition of done

- [ ] Producer replays clean + corrupted streams with headers + registry serialization + rate control.
- [ ] Consumer sinks valid events to bronze idempotently, DLQs the rest, commits offsets after write.
- [ ] Counts (bronze / DLQ / dedup) reconcile with Day 6 ground truth.
- [ ] HL7 and FHIR samples land on the canonical topic and into bronze indistinguishably.
- [ ] `make e2e` is green and repeatable; metrics scrape on `:8000`.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- `confluent-kafka` `AvroSerializer`/`AvroDeserializer` (or `ProtobufSerializer`) take a
  `SchemaRegistryClient` and handle the magic-byte wire format for you.
- Idempotent bronze append: write to a staging path keyed by `event_id`, then `MERGE`/upsert
  (Delta) or dedupe on compaction (Parquet + a periodic `DISTINCT ON (event_id)` rewrite).
- Don't block the consumer poll loop on slow writes — batch N records then write, and tune
  `max.poll.records` / `max.poll.interval.ms` so you don't rebalance mid-batch.
- Kafka Connect quickstart image: `confluentinc/cp-kafka-connect`. HL7 → you'll likely need a
  custom SMT or a small transform service; a standalone Python service is an acceptable,
  documented substitute — the *contract mapping* is the graded part.
- FHIR `Observation`: `code.coding[].code` (LOINC) → `signal_code`; `valueQuantity.value/unit`
  → `value/unit`; `effectiveDateTime` → `event_time`.
- Expose metrics with `prometheus_client.start_http_server(8000)`.
