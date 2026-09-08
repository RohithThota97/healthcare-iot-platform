# Day 3 — Interview Questions

## Technical fundamentals

1. Walk through Avro schema resolution. When a consumer with the writer's schema and its own
   reader's schema deserialize a record, what rules apply to added/removed/renamed fields?
2. Why does Protobuf care about field *numbers* and Avro care about field *names + order*?
   What mistake does each make easy?
3. What is a schema registry's subject-naming strategy and why does it matter if you want one
   topic to carry multiple event types?
4. `BACKWARD` vs. `FORWARD` vs. `FULL` vs. `*_TRANSITIVE` compatibility — give a concrete schema
   change that each one allows and forbids.
5. You have 1 Hz numerics and 125 Hz ECG. Design the message framing. Why not one message per
   ECG sample? Why not one message per patient per second with everything in it?
6. `event_time` vs. `ingest_time` vs. `processing_time` — define all three and name one metric
   or feature that needs each.
7. Long/tall format (`signal_code`, `value`) vs. wide format (`hr`, `spo2`, … columns) for the
   silver vitals table — trade-offs for storage, query, and adding a new device type.
8. How would you represent "SpO2 is 97 but the sensor reported low signal quality" in the
   schema? Where does data quality metadata live?

## Real-world scenarios

9. A device vendor ships firmware that changes `temperature` from Celsius to Fahrenheit with no
   schema change. Nothing errors. How do you catch this, and how could the schema/contract have
   made it loud instead of silent?
10. Two hospitals send SpO2 with different LOINC codes and different units. You need one silver
    table. Walk the mapping and canonicalization design.
11. You need to add a `patient_id` field to the event, but 200 legacy devices will never send it.
    How do you evolve the schema and the pipeline without a flag day?
12. A downstream team says your "optional field" broke their job because they did positional
    decoding. Whose bug is it, and what contract change prevents a repeat?

## Explain what you built today

13. Show me your vitals schema. Defend three specific type/nullability choices.
14. Demonstrate the evolution test — what compatible change passed, what breaking change was
    rejected, and what mode enforced that?
