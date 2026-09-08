# Day 7 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| Kafka **or** Redpanda (from Day 2 compose) | The bus | `rpk cluster info` / `kafka-broker-api-versions.sh` connects; broker advertises a listener your host can reach |
| `rpk` (Redpanda) or `kafka-*.sh` CLI | Create topics, inspect, consume | `rpk topic create t --if-not-exists` is idempotent |
| Schema Registry | Wire-format schema ids | `curl -s localhost:8081/subjects` returns your Day 3 subjects |
| `kcat` (kafkacat) | Low-level produce/consume with headers | `kcat -L -b localhost:9092` lists metadata; `-H` prints headers |
| `confluent-kafka` (Python, librdkafka) **or** `kafka-python` / `aiokafka` | Client code for the DLQ demo | `confluent-kafka` is faster and has the Avro serdes; needs librdkafka (bundled in wheels) |
| Redpanda Console / AKHQ / Kafka UI (optional) | Eyeball topics, messages, consumer lag | Add to compose; handy for the rest of the challenge |

### Listener trap (the #1 local Kafka pain)

The broker advertises a hostname to clients. If your app runs on the host but the broker
advertises the container name, connections hang. For local dev, advertise
`localhost:9092` (or `PLAINTEXT://localhost:9092`) for host clients, and a second internal
listener for other containers. Verify with `kcat -L`.

### Config checkpoints

- Set `min.insync.replicas` and `acks` intentions in the topic doc even on a single-broker local
  cluster (RF=1 locally, but write down what production wants).
- Decide `default.api.timeout.ms` / consumer `max.poll.interval.ms` so a slow handler doesn't
  cause a rebalance storm in the DLQ demo.
- Registry: subject compatibility mode still applies here — a producer with a new schema id must
  register-or-fail per your Day 3 ADR.

### Traps

- Auto-topic-creation hides bugs — disable it and create topics explicitly.
- Don't over-partition: 100 partitions on a laptop broker just adds latency and file handles.
- Committing offsets before the handler finishes = silent data loss on crash. Commit after.
