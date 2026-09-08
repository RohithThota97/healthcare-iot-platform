# Day 11 — Interview Questions

## Technical fundamentals

1. Mean vs. median vs. mode for a right-skewed vital like respiratory rate — which do you report
   for a "typical value" and why?
2. What do skewness and (excess) kurtosis tell you, and how do they change which hypothesis test
   you pick on Day 13?
3. Why does Shapiro–Wilk become useless on large samples? What do you use instead?
4. Explain MCAR, MAR, MNAR with a vitals example of each. Which one makes complete-case analysis
   biased?
5. What is Little's MCAR test actually testing, and what does a rejection let you conclude (and
   not conclude)?
6. Pearson vs. Spearman vs. Kendall — when do Pearson and Spearman disagree, and what does that
   disagreement tell you?
7. Point-biserial correlation vs. a t-test vs. logistic regression coefficient for "vital X vs.
   binary outcome" — how are they related?
8. VIF: what does VIF = 12 on `MAP` mean when you also have systolic and diastolic in the model?

## Real-world scenarios

9. SpO2 is missing 8% overall but 45% for one device model on the night shift. What's your
   hypothesis, how do you confirm it, and does it change your imputation?
10. Your P95 "normal HR" from the data is 118, but the clinical reference is 100. Reconcile —
    is your data wrong, your cohort different, or the reference conservative?
11. EDA shows HR and RR are strongly correlated. A colleague wants to drop RR as redundant.
    What do you check before agreeing?
12. A stakeholder wants "one number for data quality this week." Given your EDA, what single
    metric would you pick and what does it hide?

## Explain what you built today

13. Walk me through `eda-summary.md`. Name three concrete downstream decisions your EDA made for
    you and the evidence behind each.
14. Show me your missingness analysis. What's your MCAR/MAR/MNAR call for SpO2 and how does it
    change the Day 15 modeling?
