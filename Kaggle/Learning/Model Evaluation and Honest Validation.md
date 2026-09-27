---
title: "Model Evaluation and Honest Validation"
kind: "learning"
topics: "validation,metrics,tabular,competition-strategy"
status: "ready"
updated: "2026-09-26"
minutes: 20
---

# Model Evaluation and Honest Validation

**Do this now — 3 minutes:** write the sentence “My model will be tested on ___ that it has never seen.” Fill the blank with people, future dates, wells, hospitals, or another real unit. Your split should respect that unit.

**Done today:** save a short validation contract containing the prediction target, metric, split rule, and one leakage check.

## The 30-second version

Kaggle's Model Evaluation guide covers raw regression errors, regression metrics, classification errors, classification metrics, and cross-validation. It supplies separate Auto MPG and Titanic setup notebooks so learners can focus on evaluation. Its visible page does not establish a publication date. [Kaggle guide](https://www.kaggle.com/learn-guide/model-evaluation).

The central question is practical: **does this score measure the situation you actually care about?** A good score on an easy split can be less useful than a worse score on a realistic split.

## Your 20-minute path

1. **3 minutes:** identify the real unit of generalization.
2. **7 minutes:** inspect [Cross Validation](https://www.kaggle.com/code/jeffpoulshaju/cross-validation), linked from the guide.
3. **5 minutes:** fill out the validation contract below.
4. **5 minutes:** compare your contract with the ROGII case study and record one change you would make.

## The validation contract

```text
Prediction target:
Metric and whether higher/lower is better:
What an unseen example means:
Split method and random seed:
What data preprocessing is fitted only on training rows:
Leakage check:
One untouched final check:
```

**Random rows:** useful when rows are reasonably independent and drawn from the same target population. Repeated measurements from one person can break that assumption.

**Grouped split:** keep related examples together. If training and validation share a person's records, the model may recognize that person instead of learning a transferable pattern.

**Time split:** train on the past and evaluate on a later period when the intended use is forecasting. Features must also be available at prediction time; splitting by date does not automatically remove future information.

**Out-of-fold predictions:** predictions made on rows excluded from a model's fitting fold. These are useful for comparing models and training a stacker. If preprocessing or model selection leaks validation information, an “OOF” filename does not make predictions honest.

## Metrics without the fog

| Decision | Question to ask |
|---|---|
| Regression error | Are large misses especially costly, or should each absolute miss count evenly? |
| Imbalanced classification | How many positive examples exist, and what does a missed positive cost? |
| Probability quality | Are predicted probabilities useful and calibrated, or is only ranking needed? |
| Threshold choice | Was the cutoff selected using validation data and the actual objective? |
| Competition metric | Does my local implementation match the published definition and aggregation? |

The guide links dedicated [regression metrics](https://www.kaggle.com/code/jeffpoulshaju/regression-performance-metrics) and [classification metrics](https://www.kaggle.com/code/jeffpoulshaju/classification-performance-metrics) notebooks. Notebook bodies were not individually captured in this first digest; the table is an original decision aid.

## A competition lesson

The ROGII seventh-place authors report that public leaderboard ordering contradicted their local CV ordering; private results later supported the local ordering. Their explanation is a useful reminder that a leaderboard subset can differ from your local sample. This is their retrospective account, not an independent replication. [Seventh-place write-up](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/7th-place-solution-hmm-unet-agent-is-all-you).

## Tiny practice task

Take a dataset with repeated entities. Compare a random row split with an entity-grouped split using the same simple model. Record both results and the number of shared entities between train and validation. Do not assume a large score gap proves one particular cause; inspect the split and features.

**Done means:** one table, one leakage check, and three sentences describing which split better matches deployment.

Continue: [[ROGII Wellbore Geology - Consolidated Digest]] · [[Vesuvius Surface Detection - Consolidated Digest]]
