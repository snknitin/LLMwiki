---
title: "Model Evaluation and Honest Validation - SparkFast Lesson"
kind: "learning"
topics: "validation,metrics,tabular,competition-strategy"
status: "sparkfast-generated"
updated: "2026-09-26"
minutes: 5
generated_from: "Learning/Model Evaluation and Honest Validation.md"
model: "spark-fast"
job_id: "e1d7b321e82441a1bb6c8427e2d05331"
---

# Model Evaluation and Honest Validation - SparkFast Lesson

## Diagnostic Question
If you train a model on a dataset and evaluate it on the exact same data, what does the resulting high accuracy actually tell you about the model's ability to handle new customer data?

<details><summary>Show answer</summary>

It measures fit to the training sample. By itself it does not estimate performance on new customers; high training accuracy alone does not establish memorization or overfitting [S5](https://www.kaggle.com/code/jeffpoulshaju/introduction-to-model-evaluation).

</details>

## Core Idea: Honest Validation
Honest validation measures how well a model predicts unseen data, not how well it memorizes training data. A train/validation gap is a signal to investigate, not a diagnosis of its cause [S5](https://www.kaggle.com/code/jeffpoulshaju/introduction-to-model-evaluation).

Data leakage occurs when information from outside the training set influences the model, such as applying scaling or imputation to the full dataset before splitting [S8](https://www.kaggle.com/code/jeffpoulshaju/model-evaluation-faqs). This contaminates the evaluation and can make its scores optimistic; the size and direction of the effect depend on the data and transformation.

A single holdout split can be noisy. Cross-validation rotates multiple validation folds, providing a more robust estimate of generalization by averaging performance across different data partitions [S2](https://www.kaggle.com/code/jeffpoulshaju/cross-validation). However, a train/validation gap alone does not prove a unique cause. It requires investigation into feature complexity, data distribution shifts, or leakage. No universal overfitting threshold exists. Choose grouped or temporal splits when the deployment question requires them. Stratifying by group is not holding a group out. Negative R-squared means the model performs worse than the applicable mean baseline on that evaluation set, not that the model is fundamentally broken [S8](https://www.kaggle.com/code/jeffpoulshaju/model-evaluation-faqs). Cross-validation can reduce dependence on one split when its splitting assumptions match the intended use. It does not always reduce variance or guarantee reliability.

Metric selection must align with the problem type. Accuracy alone can conceal poor minority-class performance on imbalanced datasets [S4](https://www.kaggle.com/code/jeffpoulshaju/classification-performance-metrics). For classification, use Precision, Recall, or AUC to capture failure modes [S4](https://www.kaggle.com/code/jeffpoulshaju/classification-performance-metrics)[S8](https://www.kaggle.com/code/jeffpoulshaju/model-evaluation-faqs). For regression, use RMSE or MAE to quantify error magnitude [S6](https://www.kaggle.com/code/jeffpoulshaju/understanding-regression-errors).

## Worked Example: Titanic Survival (Proposed)

**Question:** does adding one feature improve a simple baseline under a fixed validation design?

Assume the learning exercise treats passenger rows as exchangeable and that `Pclass` and `Sex` are available at prediction time. This is a simplifying assumption: relatives or travel groups can violate row independence. A deployment question about new families would need groups held out. The linked Titanic notebook is a starting dataset example, not evidence for the results of this proposed experiment [S10](https://www.kaggle.com/code/jeffpoulshaju/titanic-data-preprocessing-model-fitting).

1. Reserve 20% as a final holdout before selecting features. Keep its labels out of the agent's experiment inputs.
2. On the remaining development data, use the same five stratified folds for both logistic-regression pipelines. Fit imputation and encoding separately inside each training fold [S2](https://www.kaggle.com/code/jeffpoulshaju/cross-validation)[S8](https://www.kaggle.com/code/jeffpoulshaju/model-evaluation-faqs).
3. Compare `Pclass` alone with `Pclass` plus `Sex`. Hold algorithm, folds, seed and hyperparameters fixed.
4. Record each validation-fold score and the paired differences. Inspect errors and variation; a small positive mean delta alone is not proof of a reliable improvement.
5. Choose an approach using development evidence, refit on development data, then evaluate the final holdout once. Do not cross-validate or repeatedly select features on that holdout.

These are proposed steps. No experiment has been run by the tutor. A high training score and lower validation score may motivate an overfitting investigation, but also check distribution differences and other causes.

## 20-Minute Controlled Experiment

Use an already available permitted dataset. If obtaining or cleaning data takes longer, spend this session only preparing the split and baseline.

For a small exploratory exercise, use one fixed training/validation split inside the development data. This is **validation**, not the final test set. The single result is preliminary.

1. **3 minutes:** predict whether adding the feature will help and why. Record the split seed and any grouping assumption.
2. **7 minutes:** fit a logistic-regression pipeline on `Pclass`, with preprocessing fitted only on training rows.
3. **5 minutes:** add `Sex` with an encoder fitted inside the same pipeline. Change nothing else.
4. **3 minutes:** save both validation scores, their difference, row counts, feature lists and seed in `evaluation_results.json`.
5. **2 minutes:** inspect one error and explain a limitation. Plan a paired cross-validation check before treating the difference as reliable.

Neither a favorable score delta nor a particular train-score pattern makes the change automatically valid. Leakage requires inspecting what information was available and how it was used.

## Agent Assignment

Give the agent the development data, target, fixed split definition, permitted features and a time budget. Keep the final holdout out of its inputs.

Ask it to create one reproducible script, the two fitted pipeline specifications, and `evaluation_results.json`. Require real stdout or saved outputs; missing results must remain missing.

Audit these four things:

1. Splits have disjoint row identifiers and, where required, disjoint groups.
2. Preprocessing is fitted only on training data within each fold.
3. The baseline and intervention use identical validation rows and metric code.
4. Reported scores match an actual rerun. The agent's explanation is not execution evidence.

**Finish condition:** one reproducible paired comparison, one checked leakage risk, and three sentences explaining what the result does and does not establish.

## Transfer & Recall
How would your validation strategy change if you were predicting house prices (regression) instead of survival (classification), and which metrics would you prioritize?

<details><summary>Show hint</summary>

Regression requires metrics that quantify continuous error. Consider RMSE or MAE [S3](https://www.kaggle.com/code/jeffpoulshaju/regression-performance-metrics)[S6](https://www.kaggle.com/code/jeffpoulshaju/understanding-regression-errors). Also consider whether the deployment question requires grouped or temporal splits to catch distribution shifts.

</details>

<details><summary>Show answer</summary>

For regression, prioritize RMSE or MAE to align with business costs [S3](https://www.kaggle.com/code/jeffpoulshaju/regression-performance-metrics)[S6](https://www.kaggle.com/code/jeffpoulshaju/understanding-regression-errors). If house prices are influenced by market trends over time, use a temporal split instead of a random split to prevent future data from leaking into the past.

</details>

Why does fitting a scaler on the full dataset before splitting the data invalidate your validation results?

<details><summary>Show hint</summary>

Think about what information the model sees during training that it would not see in production.

</details>

<details><summary>Show answer</summary>

It lets validation/test observations influence the fitted transformation [S8](https://www.kaggle.com/code/jeffpoulshaju/model-evaluation-faqs). For a standard scaler, that includes means and variances. This contaminates the evaluation and may make it optimistic; fit the transformation on each training partition and apply it unchanged to validation/test data.

</details>

## Source reading receipt

Generated on 2026-09-26T14:29:31.943059+00:00 with Hermes **spark-fast**, followed by a second SparkFast review. This is AI-generated teaching, not independently verified research or executed experiment results.

- [S1] Read (bounded excerpt): https://www.kaggle.com/learn-guide/model-evaluation
- [S2] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/cross-validation
- [S3] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/regression-performance-metrics
- [S4] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/classification-performance-metrics
- [S5] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/introduction-to-model-evaluation
- [S6] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/understanding-regression-errors
- [S7] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/classification-errors
- [S8] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/model-evaluation-faqs
- [S9] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/mpg-data-preprocessing-model-fitting
- [S10] Read (bounded excerpt): https://www.kaggle.com/code/jeffpoulshaju/titanic-data-preprocessing-model-fitting

[S1]: https://www.kaggle.com/learn-guide/model-evaluation
[S2]: https://www.kaggle.com/code/jeffpoulshaju/cross-validation
[S3]: https://www.kaggle.com/code/jeffpoulshaju/regression-performance-metrics
[S4]: https://www.kaggle.com/code/jeffpoulshaju/classification-performance-metrics
[S5]: https://www.kaggle.com/code/jeffpoulshaju/introduction-to-model-evaluation
[S6]: https://www.kaggle.com/code/jeffpoulshaju/understanding-regression-errors
[S7]: https://www.kaggle.com/code/jeffpoulshaju/classification-errors
[S8]: https://www.kaggle.com/code/jeffpoulshaju/model-evaluation-faqs
[S9]: https://www.kaggle.com/code/jeffpoulshaju/mpg-data-preprocessing-model-fitting
[S10]: https://www.kaggle.com/code/jeffpoulshaju/titanic-data-preprocessing-model-fitting

## Editorial review

Codex corrected validation/test separation, causal overclaims and the proposed exercise after the two SparkFast passes on 2026-09-26. This lesson combines SparkFast generation with explicit editorial corrections; it is not evidence of an executed experiment. Method check: https://scikit-learn.org/stable/common_pitfalls.html
