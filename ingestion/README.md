# Ingestion contract

Kafka producers must use Schema Registry, set `event_id` as the idempotency key, and attach `source_system`, `schema_id`, and `correlation_id` headers. Kafka Connect adapters normalize legacy HL7/FHIR messages before publishing `clinical.raw.v1`; they do not forward direct identifiers downstream.

Malformed payloads are copied to `vitals.dlq.v1` with the original bytes encrypted, validation error, producer, schema id, and replay status. Replay is an explicit operator action and must preserve the original event id.