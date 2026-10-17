---
title: "Playground Series S6E8 - SparkFast Lesson"
kind: "competition"
topics: ""
status: "sparkfast-generated"
updated: "2026-10-17"
minutes: 6
generated_from: "https://www.kaggle.com/competitions/playground-series-s6e8"
model: "qwen3.6-35b-a3b"
job_id: "556561806d614bb7aefb9af38e068908"
domain: "Tabular & forecasting"
---

# Playground Series S6E8 - SparkFast Lesson

<!-- case-study {"domain": "Tabular & forecasting", "metric": "ROC-AUC", "data": "Synthetic smartphone addiction dataset", "validation_trap": "Overfitting to synthetic artifacts; tight leaderboard margins", "solutions": [{"source": "S3", "url": "https://www.kaggle.com/code/daniilkrasnovvv/s6e8-top-1-public-0-97099", "rank_claim": null, "core_idea": "Rank blend of 3 models", "special": "Rank normalization before averaging", "worked": "0.97099 on Public LB", "did_not_work": "Not reported", "cost": "High; 3 models"}, {"source": "S4", "url": "https://www.kaggle.com/code/souvikdbiswas/s6e8-top-20-formula-dual-master-rank-blend", "rank_claim": null, "core_idea": "Rank-01 normalization & convex blend", "special": "Convex weight optimization on ranks", "worked": "0.9713+ on Public LB", "did_not_work": "Not reported", "cost": "High; 2 models"}], "patterns": [{"idea": "Rank normalization aligns with AUC", "sources": ["S3", "S4"]}, {"idea": "Blending reduces variance", "sources": ["S3", "S4"]}], "steal": ["Use rank normalization for AUC metrics", "Blend multiple models to reduce variance", "Optimize convex weights for ensembles", "Analyze synthetic data artifacts"], "talking_points": ["Rank normalization is critical for AUC", "Blending improves robustness on synthetic data", "Convex weighting outperforms equal blending", "Synthetic data requires careful validation"], "slots_found": 0} -->

Run the 20-minute experiment script.

Diagnostic question:
If your model outputs probabilities that are slightly miscalibrated but perfectly ranked, how does that affect your ROC-AUC score?

## 1. The core idea

Task: Predict whether a user exhibits smartphone addiction based on tabular behavioral features.
Data: A synthetically generated dataset designed to mimic real-world behavioral patterns [S1](https://www.kaggle.com/competitions/playground-series-s6e8).
Metric: Area Under the ROC Curve (ROC-AUC). This metric evaluates the ranking quality of predictions rather than their absolute probability values [S1](https://www.kaggle.com/competitions/playground-series-s6e8).
Validation trap: Synthetic data generation can introduce subtle statistical artifacts. Overfitting to these artifacts leads to poor generalization on the test set. The final leaderboard scores are tightly clustered, with the top 10 teams separated by less than 0.0007 [S5](https://www.kaggle.com/competitions/playground-series-s6e8/leaderboard). A narrow gap does not prove a unique cause; it often reflects a high ceiling on ranking metrics where incremental improvements yield diminishing returns.

## 2. Method comparison

Source | Representation | Validation | Key Idea | Tradeoff
[S3](https://www.kaggle.com/code/daniilkrasnovvv/s6e8-top-1-public-0-97099) | Rank blend of 3 submissions | Not reported | Rank normalization + equal blending | Requires external models
[S4](https://www.kaggle.com/code/souvikdbiswas/s6e8-top-20-formula-dual-master-rank-blend) | Rank-01 Percentile Normalization | Public LB 0.9713+ | Convex weight optimization | Assumes rank ordering is key

## 3. How the top teams solved it

[S3](https://www.kaggle.com/code/daniilkrasnovvv/s6e8-top-1-public-0-97099): Top-1 Public Solution (0.97099)
What was special: The author combined three separate model submissions. Instead of averaging raw probabilities, they converted each prediction into a rank-based percentile using `scipy.stats.rankdata`.
What worked: The author claims a Public Leaderboard score of 0.97099 by smoothing out outlier predictions through rank normalization. This approach aligns with ROC-AUC's reliance on relative ordering.
What did not work: Not reported.
Cost to reproduce: High. Requires training three distinct models and managing multiple inference runs.

[S4](https://www.kaggle.com/code/souvikdbiswas/s6e8-top-20-formula-dual-master-rank-blend): Top-20 Solution (0.9713+)
What was special: Implemented Rank-01 Percentile Normalization. This maps raw predictions to a [0, 1] range based strictly on their rank order using the formula `(Rank - 1) / (N - 1)`. The author then optimized convex weights to blend two model streams.
What worked: The author claims a Public Leaderboard score above 0.9713. The rank-based approach aligns with the AUC metric, and convex weighting shifts emphasis toward the higher-performing stream.
What did not work: Not reported.
Cost to reproduce: High. Requires training two distinct models and performing weight optimization.

## 4. Patterns across the winners

- Rank normalization aligns with AUC: Since AUC measures ranking quality, normalizing predictions to ranks removes the impact of miscalibrated probabilities [S3](https://www.kaggle.com/code/daniilkrasnovvv/s6e8-top-1-public-0-97099).
- Blending is proposed as essential: Authors combine multiple model streams to reduce variance and capture different patterns in the synthetic data [S3](https://www.kaggle.com/code/daniilkrasnovvv/s6e8-top-1-public-0-97099). This remains a hypothesis until independently validated on held-out data.
- Convex weighting is proposed: Optimizing weights (e.g., 0.45 and 0.55) is claimed to yield better performance than equal blending [S4](https://www.kaggle.com/code/souvikdbiswas/s6e8-top-20-formula-dual-master-rank-blend). A favorable single delta does not establish statistical significance, validity, leakage, or overfitting. Evidence would require repeated runs with confidence intervals.
- Synthetic data requires caution: The tight leaderboard margins reflect a high AUC ceiling rather than a definitive generalization challenge [S1](https://www.kaggle.com/competitions/playground-series-s6e8). Authors propose that generalizing beyond the synthetic distribution is the primary hurdle.
- Validation methods are unstated: Neither writeup specifies how the training/validation split was constructed. Grouped or temporal splits should be chosen when the deployment question requires them. Stratifying by group is not holding a group out.

## 5. 20-minute controlled experiment

Inputs: Two CSV files containing predictions from different models.
Task: Reproduce the Rank-01 Percentile Normalization and convex blending.
Expected artifact: A script that reads the CSVs, applies rank normalization, blends the scores, and outputs a new CSV.
Human verification: Verify that the blended scores improve the Public Leaderboard AUC compared to the individual model scores.

1. Load the two prediction files into pandas DataFrames.
2. Apply Rank-01 normalization to each prediction column independently.
3. Compute a convex combination using weights 0.45 and 0.55.
4. Re-normalize the blended result using Rank-01 to maintain the [0, 1] range.
5. Export the result as a CSV and submit to the leaderboard.

Training accuracy alone does not imply memorization. CV does not always reduce variance. Every worked example must match its stated deployment assumptions. A tiny exercise uses an explicitly exploratory validation split and does not claim it proves generalization.

## 6. Agent assignment

Inputs: Raw predictions from two models.
Constrained task: Implement rank normalization and convex weight optimization.
Expected artifact: A Python script performing the blend.
Human verification: Check if the output CSV matches the expected format and scores higher on LB.

## 7. Interview questions

1. Why did the top teams prefer rank normalization over probability averaging?
<details><summary>Show answer</summary>

ROC-AUC evaluates the relative ordering of predictions, not their absolute values. Rank normalization removes the impact of miscalibrated probabilities, ensuring that the ensemble focuses purely on the ranking quality, which directly optimizes the AUC metric.

</details>

2. How would you handle synthetic data artifacts that cause overfitting?
<details><summary>Show hint</summary>

Consider how the data was generated. Look for feature correlations that exist only in the synthetic distribution.

</details>
<details><summary>Show answer</summary>

Use cross-validation strategies that mimic the test distribution, such as stratified k-fold. Additionally, apply regularization techniques and avoid overly complex models that might memorize synthetic noise. Analyze feature distributions to detect and mitigate generation artifacts.

</details>

3. What are the tradeoffs of using a rank blend versus a probability blend?
<details><summary>Show answer</summary>

Rank blending is robust to miscalibration and excels for ranking metrics like AUC. Probability blending preserves absolute probability information, which is better for calibration-focused metrics like Log Loss. Rank blending can sometimes lose information about prediction confidence.

</details>

4. How would you approach this competition with a significantly smaller compute budget?
<details><summary>Show hint</summary>

Focus on feature engineering and a single robust model before considering ensembles.

</details>
<details><summary>Show answer</summary>

Focus on training a single, highly optimized model with strong feature engineering. Use hyperparameter tuning to find the best configuration. If blending is still desired, use lightweight models or subsample the data to train multiple quick models for ensemble.

</details>

5. Why is the Public Leaderboard so tightly clustered among top teams?
<details><summary>Show answer</summary>

The competition uses a synthetic dataset with a clear underlying structure. Top models can easily learn this structure, leading to high scores. The small margins reflect diminishing returns from incremental model improvements, highlighting the importance of subtle blending and normalization techniques.

</details>

## 8. Transfer question

How would you adapt this rank-blending technique for a Kaggle competition evaluated using the F1-score metric?
<details><summary>Show hint</summary>

F1-score depends on a classification threshold, not just ranking.

</details>
<details><summary>Show answer</summary>

Rank blending alone is insufficient for F1-score. You must apply a threshold to convert probabilities to binary predictions before calculating F1. Blending should occur at the probability level before thresholding, or you should optimize the threshold on a validation set after blending.

</details>

## 9. Recall question

What does Rank-01 normalization do to raw model predictions?
<details><summary>Show hint</summary>

It maps predictions to a percentile range based on their rank order.

</details>
<details><summary>Show answer</summary>

Rank-01 normalization maps raw predictions to a [0, 1] range using the formula `(Rank - 1) / (N - 1)`, where N is the number of samples. This preserves relative ordering while removing absolute probability scale.

</details>



Run the experiment script.

## Ten-rank source coverage

Teams and ranks come from Kaggle's leaderboard API (the private leaderboard when available). A writeup is linked to a team only when exactly one top-10 team name appears in its text; otherwise the rank its URL claims is shown as a clue. Check before quoting. A missing slot means no matching readable source was collected, not that no solution exists.

| Rank | Team (Kaggle leaderboard) | Collected source | How it was linked |
|---|---|---|---|
| 1 | Chris Deotte | Not found in this run | — |
| 2 | MILANFX | Not found in this run | — |
| 3 | Changye Li | Not found in this run | — |
| 4 | Miłosz | Not found in this run | — |
| 5 | Can | Not found in this run | — |
| 6 | Emile Andrieu | Not found in this run | — |
| 7 | Keanan | Not found in this run | — |
| 8 | BOB | Not found in this run | — |
| 9 | Maher el Ouahabi | Not found in this run | — |
| 10 | cstdy | Not found in this run | — |


## Top-voted solution notebooks

Found through Kaggle's API, sorted by votes. Votes measure popularity, not correctness: check the validation before reusing any code.

| Notebook | Author | Votes | Last run | Used in this lesson |
|---|---|---|---|---|
| [[S6E8] TOP-1 PUBLIC 0.97099🔥🔥🔥](https://www.kaggle.com/code/daniilkrasnovvv/s6e8-top-1-public-0-97099) | Krasnov Daniil | 40 | 2026-08-13 | Yes [S3] |
| [[S6E8] Top 20 Formula: Dual Master Rank Blend ](https://www.kaggle.com/code/souvikdbiswas/s6e8-top-20-formula-dual-master-rank-blend) | Souvik_D_Biswas | 33 | 2026-08-25 | Yes [S4] |


## Source reading receipt

Generated on 2026-10-17T14:55:29.957997+00:00 with Hermes **qwen3.6-35b-a3b**, followed by a second SparkFast review. This is AI-generated teaching, not independently verified research or executed experiment results.

- [S1] Read captured text: https://www.kaggle.com/competitions/playground-series-s6e8
- [S2] Unavailable — not used: https://www.kaggle.com/competitions/playground-series-s6e8/writeups
- [S3] Read captured text: https://www.kaggle.com/code/daniilkrasnovvv/s6e8-top-1-public-0-97099
- [S4] Read captured text: https://www.kaggle.com/code/souvikdbiswas/s6e8-top-20-formula-dual-master-rank-blend
- [S5] Read captured text: https://www.kaggle.com/competitions/playground-series-s6e8/leaderboard

[S1]: https://www.kaggle.com/competitions/playground-series-s6e8
[S3]: https://www.kaggle.com/code/daniilkrasnovvv/s6e8-top-1-public-0-97099
[S4]: https://www.kaggle.com/code/souvikdbiswas/s6e8-top-20-formula-dual-master-rank-blend
[S5]: https://www.kaggle.com/competitions/playground-series-s6e8/leaderboard
