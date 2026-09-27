---
title: "ROGII Wellbore Geology — Consolidated Digest"
kind: "competition"
topics: "validation,computer-vision,geology,synthetic-data,ensembles"
status: "partial-source-coverage"
updated: "2026-09-26"
minutes: 25
---

# ROGII Wellbore Geology — Consolidated Digest

**Do this now — 3 minutes:** compare the public/private scores in the second-place row below. Write one sentence explaining why “best public score” and “best model” can differ.

**Done today:** identify one representation idea and one validation rule you can reuse in a different problem.

## The 30-second version

The retrieved August 2026 solution write-ups describe predicting a well's geological position using gamma-ray/typewell information, spatial representations, and sequence structure. The published final submission deadline was August 5, 2026, and the competition awards points and medals. [Official overview](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/overview). The useful lesson is to design the representation and validation around the physical problem. This is a **partial consolidated study document**, not a claim that all ten teams published accessible solutions.

**Evidence coverage:** five top-ten ranks have Kaggle write-up rank metadata in retrieved text: 1, 2, 5, 7, 9. Detailed method text was available for 2, 5, 7, 9. Rank 3 has a discovered title/link only. No final leaderboard was independently downloaded; page rank metadata is the rank evidence used here.

## Your 25-minute path

1. **3 minutes:** inspect the public/private example.
2. **8 minutes:** read the four method notes.
3. **9 minutes:** sketch a reusable representation for your own sequential problem.
4. **5 minutes:** complete the validation contract in [[Model Evaluation and Honest Validation]].

## What the accessible solutions teach

### Rank 2 — a probability distribution over a path

The author describes **AnchorCNN**, conditional probabilistic path modeling. The reported selected final configuration scored OOF 5.140, public 6.146, private 5.802; an earlier configuration scored OOF 5.624, public 5.780, private 6.126. Lower is better for these reported errors. The public ordering therefore favored the earlier configuration while OOF and private favored the selected one. These are author-reported experimental results. [Second-place source, August 6, 2026](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/2nd-place-solution-anchorcnn-conditional-probab).

**Study question:** when several geological positions are plausible, what is lost by predicting only one number immediately?

### Rank 5 — synthetic training before real-data fine-tuning

The fifth-place write-up describes a CNN approach centered on synthetic data, followed by brief fine-tuning on real wells. Its reported synthetic-only private score was 6.342; the fine-tuned configuration reached 5.835. The author argues that the smaller private gain than local/public gain suggests distribution differences. Treat that explanation as a hypothesis supported by this experiment, not a proven description of the hidden test distribution. [Fifth-place source, August 7, 2026](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/5th-place-solution).

**Study question:** which realistic variations would your synthetic generator need to preserve, and which artifacts could a model exploit?

### Rank 7 — combine structural assumptions with learned corrections

The seventh-place authors combine a hidden Markov model, learned emissions, and UNet-based refinement. They describe training refiners on realistic synthetic prediction mistakes before a short real-data fine-tune. Their retrospective warns that public leaderboard ordering reversed local validation ordering; private results later favored the local ordering. [Seventh-place source, August 5, 2026](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/7th-place-solution-hmm-unet-agent-is-all-you).

**Study question:** can a refiner learn to repair realistic upstream errors if it sees only unrealistically clean training inputs?

### Rank 9 — turn matching into an image, then vary the blend by position

The ninth-place write-up represents a well on a candidate-position by measured-depth grid. CNNs predict a categorical position distribution; multiple seeds/folds and position-dependent blending combine the models. Different components contribute differently along the well. [Ninth-place source, August 5, 2026](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/9th-place-solution).

**Study question:** if error mechanisms change along a sequence, when would one global ensemble weight be too restrictive?

## Top-ten coverage — ranks 1 to 5

| Rank | Evidence available | Next research action |
|---|---|---|
| 1 | [Ruby's winner page](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/1st-place-solution), rank metadata and August 6 date; method body unavailable to this retrieval | Read method body in logged-in browser; do not infer architecture |
| 2 | Ranked source and method excerpt, August 6 | Compare full training/validation details |
| 3 | [Title/link only](https://www.kaggle.com/competitions/rogii-wellbore-geology-prediction/writeups/3rd-place-solution) | Verify page rank and read body |
| 4 | Not located in this bounded research pass | Search write-ups and discussions; check final leaderboard |
| 5 | Ranked source and method excerpt, August 7 | Inspect synthetic generator and data restrictions |

## Top-ten coverage — ranks 6 to 10

| Rank | Evidence available | Next research action |
|---|---|---|
| 6 | Not located | Search write-ups and discussions |
| 7 | Ranked source and method excerpt, August 5 | Trace refinement inputs and OOF construction |
| 8 | Not located; a public-8th/private-86th page was excluded | Verify final private placement before inclusion |
| 9 | Ranked source and method excerpt, August 5 | Read positional blending and calibration details |
| 10 | Not located | Search write-ups and discussions |

“Not located” does not mean no solution exists. A top-ten title is not sufficient proof of final top-ten placement. August dates in the source rows are publication dates, separate from the final competition deadline.

## Combined lesson — your reusable experiment

**Original synthesis:** representation, realistic upstream errors, and independent validation recur across the accessible material. That does not establish that one method caused the final rank or that these methods transfer unchanged.

Build a tiny sequential prediction exercise with two representations: ordinary rows and a candidate-position grid. Hold out entire sequences. Keep the same data and metric; compare one simple baseline before adding an ensemble. Record the method, validation score, runtime, and one failure example.

**Next action — under 2 minutes:** open [[Model Evaluation and Honest Validation]] and fill only “What an unseen example means”.
