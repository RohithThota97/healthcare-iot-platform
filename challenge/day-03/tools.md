# Day 3 — Tools

| Tool | Purpose | Config checkpoint / trap |
|---|---|---|
| Schema Registry (Confluent CP, Apicurio, Karapace, or Redpanda's built-in) | Store + version + compat-check schemas | Reachable on its port; `GET /subjects` returns `[]`; default compat mode set explicitly |
| `avro-tools` / `fastavro` (Avro) **or** `protoc` + `protobuf` (Protobuf) | Compile & validate schemas | `fastavro.parse_schema()` or `protoc --version` works; can round-trip encode/decode a sample |
| `jsonschema` / `pandera` / `dbt` | Batch dataset schemas | Whichever you pick, one command validates a sample CSV against the schema |
| HL7 sample tooling: `hl7apy` (Python) or a sample `.hl7` file | Parse `ORU^R01` | Can extract `OBX` segments from a sample message |
| FHIR: `fhir.resources` (Python) or a sample `Observation` JSON | Validate FHIR resources | Can load a sample `Observation` and read `code`, `valueQuantity` |
| `curl` / `httpie` | Talk to the registry REST API | `POST` a schema and get a version id back |

### Registry config checkpoints

- Set the compatibility mode from your Day 1 ADR explicitly:
  `PUT /config` with `{"compatibility": "BACKWARD"}` (or via broker config). Don't rely on the
  default.
- Decide the **subject naming strategy**: `TopicNameStrategy` (`<topic>-value`) vs.
  `RecordNameStrategy` (by schema full name). This affects whether one topic can carry multiple
  event types. Record the choice.
- If using Redpanda's built-in registry, it's on `:8081` by default and speaks the Confluent API.

### Traps

- Registering a schema and *producing* with a schema are different steps. Today is registration
  + compatibility only; producing is Day 8.
- Avro `enum` symbols can't be removed under `BACKWARD` compat — plan the controlled vocabulary
  now.
- Protobuf field numbers are the contract, not field names. Never reuse a retired field number.
- Timestamps: Avro `long` + `logicalType: timestamp-millis`, not a string. Decide UTC everywhere.
