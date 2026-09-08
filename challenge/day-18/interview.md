# Day 18 — Interview Questions

## Technical fundamentals

1. Data drift vs. prediction drift vs. concept drift vs. label drift — define each and give a
   vitals example. How do you tell them apart in production?
2. Why must a PSI baseline be the frozen training distribution rather than a rolling recent
   window?
3. You can't measure model performance in real time because labels take 24 h. How do you build a
   performance monitor around that constraint?
4. Design an alert de-bounce scheme so a single noisy SpO2 reading doesn't page a nurse. What
   are the parameters and how do you tune them?
5. What's a sensible retrain trigger? Why do you need hysteresis, and what does flapping look
   like without it?
6. How do you make a batch scoring job idempotent and safely re-runnable for a date range?
7. What goes in an alert payload so a clinician can act on it and an engineer can debug it?
8. Shadow mode / champion-challenger — what is it, and what does it let you validate that
   offline eval can't?

## Real-world scenarios

9. 3 a.m.: alert volume is 5x normal. Is it a real deterioration cluster, a data-quality
   problem, a drifted model, or a threshold bug? Walk your triage using your dashboards.
10. PSI on two features crossed 0.25 four days ago; AUPRC hasn't moved. Do you retrain? What
    else do you check?
11. A new device model rolls out to one unit. Every feature drifts for that unit. How do you
    keep monitoring useful instead of one big red light?
12. The streaming model and the nightly batch scores disagree for the same patient at the same
    time. Where do you look first?
13. Legal asks you to stop scoring one patient immediately (erasure request) while the stream is
    live. How?

## Explain what you built today

14. Walk me through the full loop: feature → score → alert → Kafka → observability. Where's the
    latency budget spent?
15. Show me your retrain policy truth table. Defend one threshold.
