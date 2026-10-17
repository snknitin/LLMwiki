---
title: "ROGII Wellbore Geology — Reverse case study"
kind: "reverse"
topics: "validation,computer-vision,geology,synthetic-data,ensembles"
status: "sparkfast-generated"
updated: "2026-10-17"
minutes: 15
generated_from: "Competitions/ROGII Wellbore Geology - SparkFast 0c03960c.md"
model: "qwen3.6-35b-a3b"
job_id: "a58168a74a9f417ca9dc0133eafc0f73"
---

# ROGII Wellbore Geology — Reverse case study

<!-- reverse-case {"title": "ROGII Wellbore Geology: Project Post-Mortem Draft", "setting": "A senior data scientist is presenting a draft of the ROGII competition project to the VP of Geosciences. The goal is to justify the new prediction pipeline for deployment on unseen wells. The draft mixes correct practices with critical errors.", "sections": [{"name": "Problem Framing & Data", "steps": [{"id": "1", "text": "We defined the prediction target as `tvt` and established a deployment goal of predicting unseen wells using only pre-drill and early-drill features.", "verdict": "sound", "category": "Problem Framing", "difficulty": "easy", "why": "Matches the competition objective and standard deployment constraints.", "good_catch": "Correctly identified the target and the inference-time feature boundary.", "source": "S1"}, {"id": "2", "text": "We split the 773 wells into training and validation sets using a random row-wise shuffle, ensuring 80% of all GR measurements were used for training.", "verdict": "flawed", "category": "Entity Overlap", "difficulty": "easy", "why": "Random row splitting leaks well-level correlation. The lesson mandates GroupKFold by well to evaluate unseen wells.", "good_catch": "You need to group by well, not rows, to prevent leakage.", "source": "planted"}, {"id": "3", "text": "We constructed typewell bins by aligning gamma-ray observations to their measured depth and TVT labels to estimate median residuals per bin.", "verdict": "sound", "category": "Feature Engineering", "difficulty": "easy", "why": "This aligns with the fifth-place approach for residual correction.", "good_catch": "Correctly used TVT and GR for binning.", "source": "S4"}, {"id": "4", "text": "We fitted the GR imputation scaler and typewell binning parameters on the full dataset before splitting to ensure consistent feature distributions across all folds.", "verdict": "flawed", "category": "Preprocessing Leakage", "difficulty": "easy", "why": "Fitting preprocessing on full data leaks target information into features.", "good_catch": "Fit scalers and binning only on training folds.", "source": "planted"}]}, {"name": "Modelling & Validation", "steps": [{"id": "5", "text": "We generated synthetic wells by arbitrarily shifting the TVT path while retaining the original GR signature to augment the training set.", "verdict": "flawed", "category": "Synthetic Data Assumption", "difficulty": "hard", "why": "Shifting TVT while keeping GR breaks geological consistency. The lesson warns these assumptions fail.", "good_catch": "Synthetic data must derive GR from the new TVT, not retain the old signal.", "source": "planted"}, {"id": "6", "text": "We trained an anchor-grid CNN to predict conditional moves and used dynamic programming to decode the optimal path.", "verdict": "sound", "category": "Modelling", "difficulty": "easy", "why": "Mirrors the second-place solution's architecture.", "good_catch": "Correctly implemented the anchor-grid CNN approach.", "source": "S3"}, {"id": "7", "text": "We added a UNet refiner conditioned on the first-pass model's predictions, achieving a 0.5% local RMSE improvement on the training wells.", "verdict": "flawed", "category": "Refiner Shortcut", "difficulty": "hard", "why": "Refiners trained on clean conditioning copy errors. The lesson shows this causes shortcutting.", "good_catch": "Condition the refiner on realistic corruption, not the model's own predictions.", "source": "planted"}, {"id": "8", "text": "We implemented a GroupKFold split over the 773 wells to evaluate generalization to unseen wells, recording per-well errors.", "verdict": "sound", "category": "Validation", "difficulty": "easy", "why": "GroupKFold by well is the correct split for this problem.", "good_catch": "Correctly used GroupKFold for well-level evaluation.", "source": "S5"}]}, {"name": "Evaluation & Conclusions", "steps": [{"id": "9", "text": "We selected the final model architecture by tuning the number of CNN filters on the public leaderboard until we achieved a score of 0.42.", "verdict": "flawed", "category": "Tuning on Test Set", "difficulty": "medium", "why": "Tuning on the public leaderboard is tuning on the test set.", "good_catch": "Select models on a held-out private validation set.", "source": "planted"}, {"id": "10", "text": "We compared the baseline RMSE of 1.20 to our new model's 1.15 and reported a 5% reduction in error.", "verdict": "flawed", "category": "Arithmetic Error", "difficulty": "easy", "why": "1.20 to 1.15 is a 4.2% reduction, not 5%.", "good_catch": "Calculate percentage reduction correctly: (1.20-1.15)/1.20.", "source": "planted"}, {"id": "11", "text": "We used a sequential SoftMax gate to combine the HMM and neural candidates, weighting models based on their disagreement.", "verdict": "sound", "category": "Ensembling", "difficulty": "medium", "why": "Matches the third-place solution's gating strategy.", "good_catch": "Correctly implemented the SoftMax gate.", "source": "S8"}, {"id": "12", "text": "We incorporated spatial-neighbor features to capture local geological trends, which improved our local cross-validation score by 2%.", "verdict": "flawed", "category": "Public Degradation", "difficulty": "hard", "why": "The first-place account reports neighbor features degrade public scores despite local gains.", "good_catch": "Verify neighbor features don't leak spatial info before deploying.", "source": "planted"}]}, {"name": "Deployment", "steps": [{"id": "13", "text": "We included the true per-sample residual magnitude in the deployment pipeline as an uncertainty estimator for the gate.", "verdict": "flawed", "category": "Inference-Time Feature", "difficulty": "medium", "why": "True residuals require the target, which is unknown at inference.", "good_catch": "Use a predicted-error estimator trained on cross-fitted residuals.", "source": "planted"}, {"id": "14", "text": "We saved fold well IDs, correction-support counts, and predictions to track runtime and verify no held-out targets were used.", "verdict": "sound", "category": "Experiment Tracking", "difficulty": "easy", "why": "Aligns with the fifth-place author's evidence-saving protocol.", "good_catch": "Good practice to track fold IDs and correction counts.", "source": "S4"}, {"id": "15", "text": "We concluded the typewell correction provided no benefit because the OOF RMSE difference was 0.001, which is within the noise of a single run.", "verdict": "flawed", "category": "Absence of Evidence", "difficulty": "medium", "why": "A 0.001 gap is empirical and might be real; dismissing it ignores the lesson's warning about gap sign.", "good_catch": "Report the gap and investigate, don't assume noise without a significance test.", "source": "planted"}]}], "debrief": [{"question": "If you could fix only two things to make this pipeline deployable, which would they be?", "answer": "Fix the split to GroupKFold (prevents well-level leakage) and remove the inference-time true residual (it requires the target, which is unknown at deployment)."}, {"question": "Why did the synthetic data step fail to improve geological realism?", "answer": "Retaining the old GR while shifting TVT violates the geological coupling. GR must be derived from the new TVT to maintain consistency."}, {"question": "How should the 0.001 RMSE difference be reported?", "answer": "As an empirical gap to investigate, not dismissed as noise, since the lesson states the gap sign is not guaranteed."}]} -->

> Fictional write-up for practice, generated by Hermes qwen3.6-35b-a3b from [[Competitions/ROGII Wellbore Geology - SparkFast 0c03960c]]. Sound steps follow the cited writeups or standard practice; mistakes are planted and are not claims about any team.

**Your task.** A senior data scientist is presenting a draft of the ROGII competition project to the VP of Geosciences. The goal is to justify the new prediction pipeline for deployment on unseen wells. The draft mixes correct practices with critical errors. Mark each step sound, flawed or partly flawed, and say why.

## Problem Framing & Data

1. We defined the prediction target as `tvt` and established a deployment goal of predicting unseen wells using only pre-drill and early-drill features.
2. We split the 773 wells into training and validation sets using a random row-wise shuffle, ensuring 80% of all GR measurements were used for training.
3. We constructed typewell bins by aligning gamma-ray observations to their measured depth and TVT labels to estimate median residuals per bin.
4. We fitted the GR imputation scaler and typewell binning parameters on the full dataset before splitting to ensure consistent feature distributions across all folds.

## Modelling & Validation

5. We generated synthetic wells by arbitrarily shifting the TVT path while retaining the original GR signature to augment the training set.
6. We trained an anchor-grid CNN to predict conditional moves and used dynamic programming to decode the optimal path.
7. We added a UNet refiner conditioned on the first-pass model's predictions, achieving a 0.5% local RMSE improvement on the training wells.
8. We implemented a GroupKFold split over the 773 wells to evaluate generalization to unseen wells, recording per-well errors.

## Evaluation & Conclusions

9. We selected the final model architecture by tuning the number of CNN filters on the public leaderboard until we achieved a score of 0.42.
10. We compared the baseline RMSE of 1.20 to our new model's 1.15 and reported a 5% reduction in error.
11. We used a sequential SoftMax gate to combine the HMM and neural candidates, weighting models based on their disagreement.
12. We incorporated spatial-neighbor features to capture local geological trends, which improved our local cross-validation score by 2%.

## Deployment

13. We included the true per-sample residual magnitude in the deployment pipeline as an uncertainty estimator for the gate.
14. We saved fold well IDs, correction-support counts, and predictions to track runtime and verify no held-out targets were used.
15. We concluded the typewell correction provided no benefit because the OOF RMSE difference was 0.001, which is within the noise of a single run.

## Debrief

- If you could fix only two things to make this pipeline deployable, which would they be?
- Why did the synthetic data step fail to improve geological realism?
- How should the 0.001 RMSE difference be reported?

## Answer key

<details><summary>Open only after reviewing every step</summary>

| # | Verdict | Category | Difficulty | Why | Source |
|---|---|---|---|---|---|
| 1 | sound | Problem Framing | easy | Matches the competition objective and standard deployment constraints. | S1 |
| 2 | flawed | Entity Overlap | easy | Random row splitting leaks well-level correlation. The lesson mandates GroupKFold by well to evaluate unseen wells. | planted |
| 3 | sound | Feature Engineering | easy | This aligns with the fifth-place approach for residual correction. | S4 |
| 4 | flawed | Preprocessing Leakage | easy | Fitting preprocessing on full data leaks target information into features. | planted |
| 5 | flawed | Synthetic Data Assumption | hard | Shifting TVT while keeping GR breaks geological consistency. The lesson warns these assumptions fail. | planted |
| 6 | sound | Modelling | easy | Mirrors the second-place solution's architecture. | S3 |
| 7 | flawed | Refiner Shortcut | hard | Refiners trained on clean conditioning copy errors. The lesson shows this causes shortcutting. | planted |
| 8 | sound | Validation | easy | GroupKFold by well is the correct split for this problem. | S5 |
| 9 | flawed | Tuning on Test Set | medium | Tuning on the public leaderboard is tuning on the test set. | planted |
| 10 | flawed | Arithmetic Error | easy | 1.20 to 1.15 is a 4.2% reduction, not 5%. | planted |
| 11 | sound | Ensembling | medium | Matches the third-place solution's gating strategy. | S8 |
| 12 | flawed | Public Degradation | hard | The first-place account reports neighbor features degrade public scores despite local gains. | planted |
| 13 | flawed | Inference-Time Feature | medium | True residuals require the target, which is unknown at inference. | planted |
| 14 | sound | Experiment Tracking | easy | Aligns with the fifth-place author's evidence-saving protocol. | S4 |
| 15 | flawed | Absence of Evidence | medium | A 0.001 gap is empirical and might be real; dismissing it ignores the lesson's warning about gap sign. | planted |

</details>

**If you could fix only two things to make this pipeline deployable, which would they be?** Fix the split to GroupKFold (prevents well-level leakage) and remove the inference-time true residual (it requires the target, which is unknown at deployment).

**Why did the synthetic data step fail to improve geological realism?** Retaining the old GR while shifting TVT violates the geological coupling. GR must be derived from the new TVT to maintain consistency.

**How should the 0.001 RMSE difference be reported?** As an empirical gap to investigate, not dismissed as noise, since the lesson states the gap sign is not guaranteed.
