# Day 8 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| `confluent-kafka[avro]` (or `[protobuf]`) | Producer/consumer + registry serdes | `SchemaRegistryClient({'url': ...})` resolves; serializer round-trips a sample |
| `prometheus-client` | Export ingestion metrics | `start_http_server(8000)`; `curl localhost:8000/metrics` shows your counters |
| Kafka Connect (`confluentinc/cp-kafka-connect`) | HL7/FHIR → canonical events | REST API on `:8083`; `GET /connector-plugins` lists what's installed |
| `hl7apy` or `python-hl7` | Parse `ORU^R01` | Extract `MSH`, `PID`, `OBR`, `OBX` from the sample |
| `fhir.resources` | Validate/parse FHIR `Observation` | `Observation.parse_obj(json)` then read `code`, `valueQuantity` |
| `delta-spark` **or** `deltalake` (Python, no JVM) | Bronze table with upsert/MERGE | `deltalake` (rust) is lighter for a pure-Python sink; `delta-spark` if you want SQL MERGE |
| Kafka UI (Redpanda Console / AKHQ) | Watch lag, inspect messages/headers | Consumer-group lag view working |

### Config checkpoints

- Producer: `enable.idempotence=true`, `acks=all`, `linger.ms` small for the alerting path.
- Consumer: `enable.auto.commit=false`; commit explicitly after the batch write succeeds.
- `max.poll.records` sized so `records * write_time < max.poll.interval.ms`.
- Registry serializer: `auto.register.schemas` — decide true (dev) vs. false (prod-like, fail if
  unregistered) and record it.

### Traps

- The advertised-listener trap from Day 7 bites here too if you run the producer on the host.
- `deltalake` Python and `delta-spark` write compatible tables but have different APIs — pick one
  for the bronze writer and reuse it Day 9.
- Kafka Connect HL7 has no great off-the-shelf source connector; budget-box it. A documented
  standalone shim that emits the canonical contract is fine — say so in the ADR.
- Metrics server on `:8000` collides with anything else on that port (Django, etc.). Pick a free
  one and update `ops/prometheus.yml`.
