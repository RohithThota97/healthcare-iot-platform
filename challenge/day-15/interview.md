# Day 15 — Interview Questions

## Technical fundamentals

1. Why split by time *and* by patient for this problem? What does each split protect against?
2. Interpret a logistic regression coefficient of 0.53 for a standardized feature. What's the
   odds ratio, and what does the 95% CI add?
3. Why is random k-fold CV wrong here? Describe expanding-window CV and its trade-offs.
4. `scale_pos_weight` / class weights vs. SMOTE vs. threshold tuning — what does each actually
   change, and which affects calibration?
5. Why must SMOTE be applied inside the CV loop on the training fold only? What happens if it
   isn't?
6. Gain importance vs. permutation importance vs. SHAP — what does each measure and where does
   each mislead?
7. Your GBM gets AUC 0.88, the logistic regression 0.81. What are the reasons you might still
   ship the logistic regression?
8. What is Hosmer–Lemeshow testing, and why might a high-AUC model still fail it?

## Real-world scenarios

9. The model's top feature by importance is "number of BP readings in last hour". Why is that a
   red flag, and how do you check whether it's leakage or a real signal?
10. Prevalence is 3%. Your model predicts "no deterioration" for everyone and gets 97% accuracy.
    Explain to a non-technical manager why that's worthless and what metric you'd show instead.
11. You must pick an alerting threshold. Walk through the cost trade-off (missed deterioration
    vs. alarm fatigue) and how you'd get the numbers to decide.
12. Retraining monthly, the model keeps picking different top features. Is that a problem? How
    do you make it stable enough to trust?

## Explain what you built today

13. Walk me through your training-dataset construction. Where exactly is the label-time cutoff,
    and what test proves nothing after it leaked in?
14. Show me your model card. What are the three most important limitations you wrote down?
