# Day 17 — Interview Questions

## Technical fundamentals

1. What is right-censoring, and why does throwing censored patients away (or treating them as
   "no event") bias your results?
2. Kaplan–Meier vs. logistic regression for "deterioration in 24 h" — what does each give you
   that the other doesn't?
3. Interpret a Cox hazard ratio of 1.8 (95% CI 1.3–2.5) for shock index. What is a hazard, and
   what does "proportional" mean?
4. What is the proportional-hazards assumption, how do you test it (Schoenfeld residuals), and
   what do you do when it's violated?
5. What is immortal-time bias and how does a landmark analysis prevent it?
6. When do you need a time-varying-covariate Cox model, and what data layout does it require?
7. Harrell's C-index — what does it measure and how does it relate to AUC?
8. Describe an MLflow model registry promotion workflow. What gates should a model pass to reach
   "Production" for a clinical use case?

## Real-world scenarios

9. Your KM curves for two units separate visually but log-rank p = 0.12. What do you report, and
   what would change your mind?
10. The Cox model says higher SpO2 *increases* hazard — the opposite of clinical sense. Walk
    through debugging that (coding, confounding, collinearity, selection).
11. A model passes every automated gate but the clinical reviewer is uneasy. How should the
    promotion policy handle "green CI but human veto"?
12. You need to roll back a production model fast because alerts spiked. What does your registry
    + serving setup need for that to take under 5 minutes?

## Explain what you built today

13. Walk me through your survival dataset definition — time origin, landmark, censoring — and
    why each choice.
14. Show me your promotion gate script. What does it check, and demonstrate it refusing a worse
    model.
