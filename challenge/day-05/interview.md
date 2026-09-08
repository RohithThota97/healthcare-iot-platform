# Day 5 — Interview Questions

## Technical fundamentals

1. What is autocorrelation in a time series, and why does iid noise make a bad vitals simulator?
   How did you introduce it?
2. Explain an AR(1) / Ornstein–Uhlenbeck process in one paragraph. What do its parameters control?
3. You have signals at 1 Hz and 125 Hz. What are the storage and query implications of keeping
   them in one table vs. two?
4. What is the Nyquist frequency, and why does it matter for storing/decimating ECG waveforms?
5. How do you keep `event_time` monotonic per `(patient, signal)` in generated data, and why does
   downstream windowing care?
6. Partitioning a time-series Parquet dataset: by date vs. by unit vs. by signal — how does the
   choice interact with the queries you expect on Day 9–14?

## Real-world scenarios

7. In production, real device clocks drift and some are set to local time, not UTC. What breaks,
   and where in the pipeline do you normalize?
8. A demo needs vitals to stream at wall-clock speed for 20 minutes. How do you replay a day of
   data at 1x, and how do you speed it up to 60x without corrupting ordering?
9. The BIDMC waveform for a "patient" implies HR 130 but your synthetic numerics say HR 78 for
   the same person at the same time. Why is that a problem and how do you keep them coherent?
10. A reviewer says "your deterioration is too obvious — the model will cheat." How do you make
    the signal realistically subtle and still have a usable label?

## Explain what you built today

11. Walk me through how one patient's HR series is generated from their demographics to the final
    Parquet row.
12. How did you incorporate real BIDMC waveforms, and how would I verify the derived HR matches
    the waveform?
