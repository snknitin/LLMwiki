---
title: "Model Evaluation and Honest Validation — Reverse case study"
kind: "reverse"
topics: "validation,metrics,tabular,competition-strategy"
status: "sparkfast-generated"
updated: "2026-10-17"
minutes: 12
generated_from: "Learning/Model Evaluation and Honest Validation - SparkFast 10ef88a5.md"
model: "qwen3.6-35b-a3b"
job_id: "7d933a6d0dd64fdd87f015831fc08319"
---

# Model Evaluation and Honest Validation — Reverse case study

<!-- reverse-case {"title": "Warehouse Energy Forecasting Pipeline Review", "setting": "Senior DS writing to VP of Data Science to justify the new forecasting model for the Q3 review. We want to show the model is production-ready and outperforms the legacy heuristic.", "sections": [{"name": "Problem framing", "steps": [{"id": "1", "text": "We defined the objective as minimizing absolute error in daily energy consumption to reduce procurement costs. The business goal is to ensure we never over-purchase energy while avoiding expensive spot-market penalties.", "verdict": "sound", "category": "Problem Framing", "difficulty": "easy", "why": "The objective is clear, measurable, and aligned with business value. No technical pitfalls here.", "good_catch": "Clear goal. Good alignment with business costs.", "source": "planted"}]}, {"name": "Data", "steps": [{"id": "2", "text": "We loaded the raw sensor logs and applied StandardScaler across the entire dataset to ensure all features share the same distribution before splitting.", "verdict": "flawed", "category": "Preprocessing", "difficulty": "medium", "why": "Fitting preprocessing on the full dataset leaks information from the future into the training set. Statistics (mean, std) computed on test data influence train data, inflating performance.", "good_catch": "Preprocessing must fit only on training data. Global scaling leaks test stats.", "source": "planted"}, {"id": "3", "text": "To capture weather impact, we engineered a feature representing the average temperature over the next 48 hours, as energy demand is heavily driven by upcoming conditions.", "verdict": "flawed", "category": "Leakage", "difficulty": "hard", "why": "Using future values (next 48 hours) to predict current targets is target leakage. The model cannot use this information at inference time, making the score unrealistic.", "good_catch": "Future features leak target info. Check feature timestamps against target timestamp.", "source": "planted"}]}, {"name": "Validation", "steps": [{"id": "4", "text": "We performed a random 80/20 train-test split to maximize the training data size and ensure the class distribution of energy levels remained balanced.", "verdict": "flawed", "category": "Temporal Leakage", "difficulty": "hard", "why": "Time-series data has a fixed order. Random shuffling breaks causality and allows future data to leak into the past. This creates an invalid evaluation that overestimates performance.", "good_catch": "Random split breaks time-series causality. Use temporal splits or walk-forward validation.", "source": "planted"}, {"id": "5", "text": "For robustness, we implemented walk-forward cross-validation, training on historical windows and validating on the immediate next period.", "verdict": "sound", "category": "Validation Strategy", "difficulty": "easy", "why": "Walk-forward validation respects the temporal order and matches deployment assumptions where future data arrives sequentially.", "good_catch": "Walk-forward CV respects time order. Correct for time-series.", "source": "S1"}]}, {"name": "Modelling", "steps": [{"id": "6", "text": "We established a naive baseline using the mean consumption of the past week to quantify the improvement of our ML approach.", "verdict": "sound", "category": "Baseline", "difficulty": "easy", "why": "Establishing a simple baseline is standard practice to ensure the complex model adds value.", "good_catch": "Baseline established. Good practice to compare against simple heuristic.", "source": "planted"}, {"id": "7", "text": "We tuned the XGBoost hyperparameters using Optuna, evaluating each candidate configuration directly against the held-out test set to select the best performing model.", "verdict": "flawed", "category": "Tuning on Test Set", "difficulty": "medium", "why": "Using the test set for hyperparameter tuning contaminates it. The test set becomes part of the development process, leading to inflated scores and poor generalization to unseen data.", "good_catch": "Test set must remain hidden during tuning. Use validation set for hyperparameter search.", "source": "planted"}, {"id": "8", "text": "We increased tree depth to 15 and removed regularization to capture every nuance in the sensor data, which significantly reduced training loss.", "verdict": "flawed", "category": "Overfitting", "difficulty": "medium", "why": "High complexity without regularization risks overfitting. A large gap between training and validation performance indicates the model memorizes noise rather than learning generalizable patterns.", "good_catch": "High depth + no regularization risks overfitting. Check train vs val gap.", "source": "planted"}]}, {"name": "Evaluation", "steps": [{"id": "9", "text": "We reported the Mean Absolute Error (MAE) on the validation set, as this metric directly aligns with our goal of minimizing procurement cost variance.", "verdict": "sound", "category": "Metric Selection", "difficulty": "easy", "why": "MAE is interpretable and matches the business goal of minimizing absolute deviation. It is a robust metric for regression tasks.", "good_catch": "MAE aligns with business goal. Good metric choice.", "source": "planted"}, {"id": "10", "text": "Our error analysis showed higher errors on weekends; we concluded that the model cannot predict weekend behavior because weekend consumption patterns are fundamentally different and non-stationary.", "verdict": "flawed", "category": "Correlation vs Causation", "difficulty": "hard", "why": "This attributes the error to the data nature rather than model limitations or missing features. It ignores survivorship bias and overgeneralizes. The issue is likely solvable with better features or handling.", "good_catch": "Don't blame data. Investigate missing features or data quality for weekends.", "source": "planted"}]}, {"name": "Conclusions and deployment", "steps": [{"id": "11", "text": "The model is ready for deployment as the validation score is stable; we will update the weights manually whenever we notice performance degradation.", "verdict": "flawed", "category": "Drift", "difficulty": "medium", "why": "Relying on manual updates ignores data drift. Production environments require automated monitoring and retraining triggers to maintain performance over time.", "good_catch": "Manual updates are insufficient. Implement automated drift detection and retraining.", "source": "planted"}, {"id": "12", "text": "We will deploy the model in shadow mode first to compare predictions against the legacy system without affecting control logic.", "verdict": "sound", "category": "Deployment", "difficulty": "easy", "why": "Shadow mode allows safe validation of the new model in production without risk to the business operations.", "good_catch": "Shadow mode is safe. Good deployment strategy.", "source": "planted"}]}], "debrief": [{"question": "If you could fix only two things to make this pipeline production-ready, which would they be?", "answer": "1. Fix the temporal leakage by removing future features and using walk-forward splits. 2. Implement automated drift monitoring and shadow deployment to ensure long-term stability."}, {"question": "Why is the random split particularly dangerous for this specific problem compared to a tabular classification task?", "answer": "Time-series data has a fixed order and causality. Random splits allow future information to leak into the past, breaking the temporal dependency that the model must learn to predict the future."}, {"question": "The team claims the weekend errors are due to 'non-stationary' patterns. What is the risk of accepting this explanation?", "answer": "It stops investigation. It assumes the problem is unsolvable rather than a symptom of missing features, data quality issues, or model bias. It is a correlation read as causation."}]} -->

> Fictional write-up for practice, generated by Hermes qwen3.6-35b-a3b from [[Learning/Model Evaluation and Honest Validation - SparkFast 10ef88a5]]. Sound steps follow the cited writeups or standard practice; mistakes are planted and are not claims about any team.

**Your task.** Senior DS writing to VP of Data Science to justify the new forecasting model for the Q3 review. We want to show the model is production-ready and outperforms the legacy heuristic. Mark each step sound, flawed or partly flawed, and say why.

## Problem framing

1. We defined the objective as minimizing absolute error in daily energy consumption to reduce procurement costs. The business goal is to ensure we never over-purchase energy while avoiding expensive spot-market penalties.

## Data

2. We loaded the raw sensor logs and applied StandardScaler across the entire dataset to ensure all features share the same distribution before splitting.
3. To capture weather impact, we engineered a feature representing the average temperature over the next 48 hours, as energy demand is heavily driven by upcoming conditions.

## Validation

4. We performed a random 80/20 train-test split to maximize the training data size and ensure the class distribution of energy levels remained balanced.
5. For robustness, we implemented walk-forward cross-validation, training on historical windows and validating on the immediate next period.

## Modelling

6. We established a naive baseline using the mean consumption of the past week to quantify the improvement of our ML approach.
7. We tuned the XGBoost hyperparameters using Optuna, evaluating each candidate configuration directly against the held-out test set to select the best performing model.
8. We increased tree depth to 15 and removed regularization to capture every nuance in the sensor data, which significantly reduced training loss.

## Evaluation

9. We reported the Mean Absolute Error (MAE) on the validation set, as this metric directly aligns with our goal of minimizing procurement cost variance.
10. Our error analysis showed higher errors on weekends; we concluded that the model cannot predict weekend behavior because weekend consumption patterns are fundamentally different and non-stationary.

## Conclusions and deployment

11. The model is ready for deployment as the validation score is stable; we will update the weights manually whenever we notice performance degradation.
12. We will deploy the model in shadow mode first to compare predictions against the legacy system without affecting control logic.

## Debrief

- If you could fix only two things to make this pipeline production-ready, which would they be?
- Why is the random split particularly dangerous for this specific problem compared to a tabular classification task?
- The team claims the weekend errors are due to 'non-stationary' patterns. What is the risk of accepting this explanation?

## Answer key

<details><summary>Open only after reviewing every step</summary>

| # | Verdict | Category | Difficulty | Why | Source |
|---|---|---|---|---|---|
| 1 | sound | Problem Framing | easy | The objective is clear, measurable, and aligned with business value. No technical pitfalls here. | planted |
| 2 | flawed | Preprocessing | medium | Fitting preprocessing on the full dataset leaks information from the future into the training set. Statistics (mean, std) computed on test data influence train data, inflating performance. | planted |
| 3 | flawed | Leakage | hard | Using future values (next 48 hours) to predict current targets is target leakage. The model cannot use this information at inference time, making the score unrealistic. | planted |
| 4 | flawed | Temporal Leakage | hard | Time-series data has a fixed order. Random shuffling breaks causality and allows future data to leak into the past. This creates an invalid evaluation that overestimates performance. | planted |
| 5 | sound | Validation Strategy | easy | Walk-forward validation respects the temporal order and matches deployment assumptions where future data arrives sequentially. | S1 |
| 6 | sound | Baseline | easy | Establishing a simple baseline is standard practice to ensure the complex model adds value. | planted |
| 7 | flawed | Tuning on Test Set | medium | Using the test set for hyperparameter tuning contaminates it. The test set becomes part of the development process, leading to inflated scores and poor generalization to unseen data. | planted |
| 8 | flawed | Overfitting | medium | High complexity without regularization risks overfitting. A large gap between training and validation performance indicates the model memorizes noise rather than learning generalizable patterns. | planted |
| 9 | sound | Metric Selection | easy | MAE is interpretable and matches the business goal of minimizing absolute deviation. It is a robust metric for regression tasks. | planted |
| 10 | flawed | Correlation vs Causation | hard | This attributes the error to the data nature rather than model limitations or missing features. It ignores survivorship bias and overgeneralizes. The issue is likely solvable with better features or handling. | planted |
| 11 | flawed | Drift | medium | Relying on manual updates ignores data drift. Production environments require automated monitoring and retraining triggers to maintain performance over time. | planted |
| 12 | sound | Deployment | easy | Shadow mode allows safe validation of the new model in production without risk to the business operations. | planted |

</details>

**If you could fix only two things to make this pipeline production-ready, which would they be?** 1. Fix the temporal leakage by removing future features and using walk-forward splits. 2. Implement automated drift monitoring and shadow deployment to ensure long-term stability.

**Why is the random split particularly dangerous for this specific problem compared to a tabular classification task?** Time-series data has a fixed order and causality. Random splits allow future information to leak into the past, breaking the temporal dependency that the model must learn to predict the future.

**The team claims the weekend errors are due to 'non-stationary' patterns. What is the risk of accepting this explanation?** It stops investigation. It assumes the problem is unsolvable rather than a symptom of missing features, data quality issues, or model bias. It is a correlation read as causation.
