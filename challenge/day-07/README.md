# Day 7 — Kafka Topics, Message Formats, Schema Registry Wiring & DLQ Design

**Phase:** Streaming & storage · **Time budget:** 10–12 h · **Skill focus:** data collection, streaming architecture
**Prereqs:** Day 6 merged; broker + registry come up with `make up`.

## Why this day matters

This is the backbone. Topic count, partition count, keys, retention, and the dead-letter design
are decisions you'll live with. Interviewers go deep here: "why 12 partitions", "what's your key",
"what happens to a poison message". Today is design + configuration + a proven DLQ path — code
that produces real traffic is Day 8.

## Challenges

### C1 — Topic topology (~3 h)
- Design the full topic list: raw vitals (numeric), raw waveform frames, HL7/FHIR-normalized,
  windowed aggregates, NEWS2 candidates, alerts, and one or more DLQ topics.
- For each: partition count (with the reasoning — target throughput, consumer parallelism,
  ordering needs), replication factor, key, retention (time and/or size), cleanup policy
  (delete vs. compact), and min in-sync replicas.
- Acceptance: `docs/streaming/topics.md` with a table and a paragraph of justification per
  non-obvious choice; a script/IaC file that creates them idempotently.

### C2 — Message format & headers (~2 h)
- Lock the on-the-wire format: Confluent wire format (magic byte + schema id + payload) or
  plain. Define standard Kafka **headers**: `event_id`, `schema_id`, `producer`, `content_type`,
  `trace_id`, `retry_count`, `original_topic` (for DLQ).
- Decide the key serde and the partitioner. Prove your key choice gives per-patient ordering
  where you need it.
- Acceptance: a written record contract doc; a decode helper that reads a raw message + headers.

### C3 — Dead-letter queue design (~3 h)
- Design the DLQ path for: schema-invalid payloads, decode failures, business-rule rejects
  (impossible vitals), and repeated processing failures.
- Specify: which topic(s), what metadata you attach (error class, stack/summary, original
  offset/partition/topic, timestamps), retry policy (in-place retry vs. retry topic vs. straight
  to DLQ), and the **replay** procedure.
- Build a minimal end-to-end proof: feed the Day 6 corrupted stream's known-bad records through
  a tiny consumer that routes them to the DLQ topic with metadata; then replay the fixable ones.
- Acceptance: a demo script shows N bad records → DLQ with metadata → M replayed successfully;
  counts match the Day 6 manifest.

### C4 — Consumer group & delivery semantics decision (~2 h)
- For each consuming path (alerting vs. bronze sink vs. analytics), choose at-least-once vs.
  effectively-once and the offset-commit strategy, and write why.
- Define what "idempotent" means for the bronze sink so replays don't double-count.
- Acceptance: `docs/streaming/delivery-semantics.md` — a table of path → semantics → commit
  strategy → idempotency mechanism.

### Stretch (optional)
- Add topic-level quotas / a throttling plan for a misbehaving device.
- Model tiered retention: hot in Kafka for N hours, then rely on bronze.

## Deliverables (branch `day-07-kafka-design`)

- `ingestion/topics/` — idempotent topic-creation script or config
- `docs/streaming/topics.md`, `record-contract.md`, `dlq-design.md`, `delivery-semantics.md`
- `ingestion/dlq/` — the routing + replay demo against Day 6 bad records
- tests: topic creator is idempotent; DLQ demo counts reconcile with the Day 6 manifest

## Definition of done

- [ ] Every topic has justified partitions, key, retention, cleanup policy.
- [ ] Standard headers defined; key choice proven to give the ordering you claim.
- [ ] DLQ demo: known-bad records routed with metadata, fixable ones replayed, counts match.
- [ ] Delivery semantics chosen per path with an idempotency story for the bronze sink.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- Partition count rule of thumb: `max(target_throughput / per_partition_throughput,
  desired_consumer_parallelism)`, then round up and leave headroom — you can add partitions but
  it breaks key→partition stability.
- Keying by `patient_id` preserves per-patient order (good for windowed NEWS2). Waveform frames
  can be keyed by `device_id` since they're processed independently. Justify per topic.
- `cleanup.policy=compact` for a "latest state per key" topic (e.g. device registry); `delete`
  with a TTL for event streams.
- DLQ is usually its own topic with `delete` retention long enough to investigate (days).
  Attach the original payload as bytes so replay is possible.
- "Effectively once" for a sink = at-least-once delivery + idempotent writes keyed by
  `event_id` (upsert / dedup on write), not Kafka transactions necessarily.
- Redpanda/Kafka: `rpk topic create` / `kafka-topics.sh --create` are fine for the idempotent
  script (`--if-not-exists`).
