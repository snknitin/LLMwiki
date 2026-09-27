---
title: "ROGII Wellbore Geology - SparkFast Lesson"
kind: "competition"
topics: "validation,computer-vision,geology,synthetic-data,ensembles"
status: "sparkfast-generated"
updated: "2026-09-26"
minutes: 20
generated_from: "Competitions/ROGII Wellbore Geology - Consolidated Digest.md"
model: "spark-fast"
job_id: "0c03960c6b6f4dc1a9047873be0825f5"
---

# ROGII Wellbore Geology - SparkFast Lesson

**Do this now — 3 minutes:** choose the intended prediction setting: unseen wells, or unseen rows from already observed wells. Then write which identifiers must stay out of training.

**Done today:** a split audit and a saved experiment plan. Generating this lesson does not mean the experiment or assignment has been performed.

<details><summary>Show the validation explanation</summary>

For an unseen-well evaluation, randomly splitting rows can place correlated rows from the same well in both training and validation, producing an optimistic estimate of generalization to new wells. Grouping by well addresses that overlap. It does not by itself prevent leakage through preprocessing, typewell corrections, synthetic-data construction, or a second-stage ensemble. The actual error gap is an empirical question, not guaranteed to have a particular sign.

</details>

## Core idea and source-backed comparison

The competition predicts the target `tvt` along horizontal wells and scores row-level RMSE [S1][S1]. The accessible solutions use gamma-ray (GR) matching, trajectory information and typewell references. The table reports only what the captured excerpts support; an unavailable validation detail is not evidence of a flawed method.

| Source | Representation and method | Validation evidence in captured excerpt | Qualification |
|---|---|---|---|
| [Second-place account][S3] | Anchor-grid CNN predicts conditional moves; dynamic programming decodes a path | Describes robustness to dominant wells; exact splitter not captured | Synthetic wells follow explicit geological assumptions; those assumptions may fail |
| [Fifth-place account][S4] | CNNs on TVT × measured-depth images; synthetic pretraining and short real-data fine-tuning | CV/OOF comparisons are discussed; exact splitter not captured | More realistic synthetic data was the author's strategy, not proof that it removes distribution shift |
| [Seventh-place account][S5] | HMM, learned emissions and UNet refinement; auxiliary signals gated by refiner disagreement | Explicit five-fold GroupKFold over 773 wells | HMM is a meaningful baseline; the author reports additional improvement from later stages |

| Source | Representation and method | Validation evidence in captured excerpt | Qualification |
|---|---|---|---|
| [Ninth-place account][S6] | Candidate-position images, multiple models and position-dependent blending | Three fold seeds × five GroupKFold folds | Final stack is banded nonnegative least squares plus spread calibration; it is not the third-place sequential SoftMax gate |
| [First-place account][S7] | ConvNeXt U-Net alignment model with particle-filter and spatial-neighbor features | Reports three seeds × five folds; splitter not named in the captured text | Author reports local gains but public degradation from neighbor features; this does not establish the reason for the discrepancy |
| [Third-place account][S8] | HMM/PF and neural candidates combined by a sequential SoftMax gate | Five well-grouped folds under five split patterns, with fold-local and OOF safeguards described | Correct information boundaries are required at both base-model and gate stages |

**What transfers:** match validation to the intended setting, preserve realistic uncertainty, and measure the incremental value of each component. Several authors report local/public/private disagreements. This supports investigating split mismatch and noisy model selection; it does not make local CV infallible or guarantee that synthetic data bridges a private-test gap.

## Worked example — a proposed fold-local typewell correction

**Hypothesis:** a sibling-well residual correction improves an uncorrected-reference baseline. The fifth-place author describes the correction idea [S4][S4]; the procedure below adds explicit evaluation boundaries. It is a proposed reproduction, not a claim about unobserved source code.

1. **Split wells first.** For each outer fold, set aside all evaluation wells and their hidden-region targets.
2. **Fit the correction using that fold's training wells only.** Align eligible training GR observations using their training TVT labels; estimate a median GR residual per typewell/TVT bin. Fit binning, smoothing and fallback choices without outer-validation targets.
3. **Freeze and apply the reference.** Add the fitted correction to the matching typewell. For a typewell without eligible training support, use the unchanged reference or a predefined fallback. Do not compute a sibling correction from held-out labels.
4. **Compare matched pipelines.** Train baseline and corrected-reference models on identical outer-training wells and score exactly the same held-out target rows. Refit all learned preprocessing inside each training fold.
5. **Save the evidence.** Record fold well IDs, correction-support counts, predictions, pooled row-level RMSE, per-well errors and runtime. Report gains or regressions; do not assume improvement.

Use only information available under the intended inference contract. If visible pre-prediction labels are allowed for a held-out well, model that boundary explicitly; never use its hidden target region. Grouping by well evaluates new wells, not necessarily unseen typewell systems. Test a separate system-held-out setting if that is the deployment question.

## Controlled experiment — split audit before score comparison

**Time budget:** 20 minutes for a small prepared dataset and existing baseline. Full-data training, feature engineering or repeat runs may exceed this; no runtime guarantee is made. If permitted data and features are not already available, save the plan and stop at the audit.

**Question:** how do row-random and well-grouped evaluation differ for this baseline? This comparison can expose a risk, but different train/validation compositions also affect scores; the gap alone does not isolate a causal leakage effect.

1. **3 minutes:** define target rows, inference-available features, the fixed small data slice, metric and training budget. Exclude hidden-target-derived inputs.
2. **5 minutes:** create a row-random split and a well-grouped split with comparable training proportions. Record row counts, well counts and train/validation well overlap.
3. **7 minutes:** if the prepared baseline fits the remaining budget, run the same model family in both settings. Fit imputers, scalers, corrections and feature selection on training data only. Otherwise save the commands for a later session.
4. **3 minutes:** record measured RMSE and per-well errors, or mark each run `not run`. The row-wise score may be lower, similar or higher; investigate the observed result.
5. **2 minutes:** save the split audit and one interpretation in `Journey/Practice Log.md` using Obsidian. Link a notebook or result file if one exists.

**Expected artifact:** a two-row comparison with split definition, row/well counts, overlap, preprocessing boundary, measured score or `not run`, and result-file reference. Repeated split assignments can later test sensitivity; a handful of seeds is not automatically a statistical significance test. If reporting uncertainty, respect the well as the dependent sampling unit.

## Optional agent assignment — toy synthesis, not a validated simulator

**Input:** a permitted small set of outer-training wells, a typewell lookup, and a fixed random seed. Do not use held-out wells' targets, residuals or estimated distributions.

**Task proposal:** generate a small synthetic set while keeping the chosen structural assumptions explicit. For a fixed per-well datum, preserve the selected structural path based on `TVT + Z`, change the TVT path, and derive the corresponding Z consistently. Regenerate GR from the typewell at the new TVT, then add a residual process estimated only from training wells. Arbitrarily shifting TVT while retaining the old GR is not the same construction.

**Expected artifacts:** a CSV with well ID, measured depth, TVT, observed GR and Z; a source-well/split manifest; generator parameters; and a short check report. Check geometry consistency, lookup range, missing values and residual autocorrelation. Matching a few summary statistics does not validate geological realism or establish benefit. A held-out experiment must determine whether the synthetic data helps. This assignment has not been executed.

## Transfer question — a gate that can run without knowing the answer

How could you adapt the third-place SoftMax-gating idea [S8][S8] to house-price regression? Which inputs would still be available when the sale price is unknown?

<details><summary>Show a hint</summary>

Candidate inputs include the base models' predictions, their disagreement, and permitted property features. True per-sample residual magnitude requires the actual target and cannot be an inference-time feature.

</details>

<details><summary>Show a worked answer</summary>

Inside each outer training fold, construct cross-fitted base predictions and train the gate from them. Use actual training targets only to compute the gate's loss or training labels. Fit preprocessing and any learned uncertainty/error estimator inside the same training boundary. Evaluate the complete base-plus-gate pipeline on an outer held-out set that was excluded from every fitting and selection stage.

If a predicted-error feature is desired, it must come from an additional estimator trained and cross-fitted without the row's held-out target. It must also be computable for a new case. For new cases, supply only the same inference-available feature types; never the true error. Compare the learned gate with simple averaging before crediting its added complexity.

</details>

## Recall question

In the seventh-place authors' refiner experiment, why did an unrealistically accurate training conditioning channel encourage copying rather than robust correction?

<details><summary>Show the answer</summary>

The authors describe a mismatch between the first-pass model's errors on its own training wells and on held-out wells [S5][S5]. A refiner trained on overly clean conditioning can learn a shortcut. They report using synthetic wells with deliberately corrupted conditioning to teach correction. This is their diagnosis and remedy for that pipeline, not proof that real-data refiners generally fail. Honest cross-fitting, realistic corruption and held-out checks are alternatives to evaluate.

</details>

**State:** lesson generated and editorially reviewed; exercises, training and transfer remain **not performed**.

**Next — under 2 minutes:** open `Journey/Practice Log.md` in Obsidian and write the intended prediction setting. This reader does not provide an answer-submission chat.

## Ten-rank source coverage

URL labels are discovery clues, not verified final placements. This collector has not verified the final leaderboard. A missing slot means no matching readable source was collected, not that no solution exists.

| Rank slot | Collected source | Final placement |
|---|---|---|
| 1 | [S7](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/1st-place-solution) (URL claims this rank) | Unverified |
| 2 | [S3](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/2nd-place-solution-anchorcnn-conditional-probab) (URL claims this rank) | Unverified |
| 3 | [S8](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/3rd-place-solution) (URL claims this rank) | Unverified |
| 4 | Not found in this run | Unverified |
| 5 | [S4](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/5th-place-solution) (URL claims this rank) | Unverified |
| 6 | Not found in this run | Unverified |
| 7 | [S5](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/7th-place-solution-hmm-unet-agent-is-all-you) (URL claims this rank) | Unverified |
| 8 | Not found in this run | Unverified |
| 9 | [S6](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/9th-place-solution) (URL claims this rank) | Unverified |
| 10 | Not found in this run | Unverified |

## Source reading receipt

Generated on 2026-09-26T14:34:29.108776+00:00 with Hermes **spark-fast**, followed by a second SparkFast review. This is AI-generated teaching, not independently verified research or executed experiment results.

- [S1] Read (bounded excerpt): https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/overview
- [S2] Captured missing-page response; unusable source: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups
- [S3] Read (bounded excerpt): https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/2nd-place-solution-anchorcnn-conditional-probab
- [S4] Read (bounded excerpt): https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/5th-place-solution
- [S5] Read (bounded excerpt): https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/7th-place-solution-hmm-unet-agent-is-all-you
- [S6] Read (bounded excerpt): https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/9th-place-solution
- [S7] Read (bounded excerpt): https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/1st-place-solution
- [S8] Read (bounded excerpt): https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/3rd-place-solution

[S1]: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/overview
[S2]: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups
[S3]: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/2nd-place-solution-anchorcnn-conditional-probab
[S4]: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/5th-place-solution
[S5]: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/7th-place-solution-hmm-unet-agent-is-all-you
[S6]: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/9th-place-solution
[S7]: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/1st-place-solution
[S8]: https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/3rd-place-solution

## Codex editorial review

Reviewed on 2026-09-26 against the eight saved source captures for job `0c03960c6b6f4dc1a9047873be0825f5`. This is a technical editorial review, not a rerun of the authors' experiments or a verification of final leaderboard ranks.

- Corrected blanket GroupKFold attributions: S5, S6 and S8 explicitly describe it; S3/S4 do not specify the splitter in their captured excerpts, and S7 reports seed/fold counts without naming it. Corrected the ninth-place final combiner to banded NNLS/spread calibration.
- Added training-fold-only boundaries for typewell corrections, preprocessing, synthetic-data estimation and gate training. Removed true target residual magnitude as an inference-time gate input; distinguished training loss targets from deployable features.
- Removed guaranteed score direction and broad claims about synthetic data, local CV and real-data refiners. Qualified the split experiment, uncertainty assessment and toy-synthesis assumptions.
- Replaced “complete” with generated/reviewed versus not-performed exercise states. Replaced unsupported “paste here” instructions with an Obsidian practice-log artifact.
- Corrected the receipt's S2 label from “Read” to “Captured missing-page response; unusable source”: its captured body says “We can't find that page” and supplies no usable write-up listing. The model/date generation statement and other receipt entries are retained. S3–S8 are truncated excerpts, not full-source reviews. This review did not change raw source captures or job generation records.

Source-capture file SHA-256 at review: `2ba748827c1b8442880b09ab1a3e2628c473d0bd9df6a65dd2b59016080a0677`.
