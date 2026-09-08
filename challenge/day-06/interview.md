# Day 6 — Interview Questions

## Technical fundamentals

1. Give a taxonomy of data-quality problems for streaming sensor data. For each, name the
   real-world cause and the statistic that detects it.
2. "Stale sensor" and "missing data" both show up as flat lines in a chart. How do you tell
   them apart programmatically?
3. A unit error (Celsius vs. Fahrenheit) leaves every individual value physiologically
   plausible. What kinds of checks can still catch it?
4. Why does the *order* in which you apply cleaning steps (dedup, interpolate, artifact-reject)
   change the result? Give an example.
5. What's the difference between at-least-once delivery duplicates and application-level
   duplicates? Does the same dedup key handle both?
6. What is "ground truth" for a data-quality system and why is a labeled `data_quality_events`
   table worth the effort?

## Real-world scenarios

7. In production you can't inject defects — you inherit them. How would you *discover* the defect
   taxonomy for a real feed you've never seen?
8. A subtle 2% calibration drift on one device model is within every hard range check. How would
   you ever catch it, and how fast?
9. Out-of-order events arrive 30 s late on average, 5 min late at p99. How does that constrain
   your windowing and your "data is complete" decision downstream?
10. Ops asks "what's our data quality SLO?" Propose 3 measurable DQ SLOs for this platform and
    how you'd report them.

## Explain what you built today

11. Walk me through one injector — how it corrupts data and how it records ground truth.
12. Which of your injected defects do you expect to be hardest for downstream contracts to
    catch, and why?
