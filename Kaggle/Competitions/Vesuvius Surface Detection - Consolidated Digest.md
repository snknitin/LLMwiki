---
title: "Vesuvius Surface Detection — Consolidated Digest"
kind: "competition"
topics: "computer-vision,segmentation,topology,ensembles,validation"
status: "partial-source-coverage"
updated: "2026-09-26"
minutes: 25
---

# Vesuvius Surface Detection — Consolidated Digest

**Do this now — 3 minutes:** draw two nearly touching sheets. Add a one-pixel bridge between them. The change is visually small but changes the number of connected objects. That is why overlap alone can be the wrong goal.

**Done today:** explain one topology error and design one check that detects it.

## The 30-second version

This completed competition asked participants to segment papyrus surfaces in 3D CT scans. Its evaluation combines surface similarity, instance consistency, and topology because accidental joins, breaks, and holes obstruct virtual unwrapping. The published final submission deadline was February 27, 2026. [Competition overview and timeline](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/overview/prizes).

**Evidence coverage:** ranks 1, 2, 5, 7 have Kaggle-ranked write-up text; ranks 3, 4, 8, 10 have discovered links without usable method bodies in this pass. Rank 3 retrieval returned “page not found”. Ranks 6 and 9 were not located. The final leaderboard was not independently captured.

## Your 25-minute path

1. **3 minutes:** draw the two-sheet example.
2. **8 minutes:** read the four method summaries.
3. **9 minutes:** make a toy binary mask with a hole, bridge, and tiny detached island.
4. **5 minutes:** write which cleanup operation helps each defect and what damage it might cause.

## Four approaches in plain language

### Rank 1 — a strong segmenter plus careful repair

Tony Li, OzanM., Yiheng Wang and PaulG describe a multi-scale nnU-Net ensemble. Their postprocessing removes small components, repairs gaps through height-map interpolation, closes small holes and fills cavities. Reported ablations take their private score from 0.596 without postprocessing to 0.627 after the full sequence. They also acknowledge difficulty separating touching sheets. These measurements belong to their pipeline; they are not guaranteed gains for another model. [Winner write-up, February 27, 2026](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/writeups/1st-place-solution-for-the-vesuvius-challenge-su).

**Study question:** why should you measure damage as well as improvement after filling a gap?

### Rank 2 — repair locally and use several confidence thresholds

Duong Nguyen and Marius Heuser ensemble two nnU-Net patch sizes and use componentwise local interpolation with multiple segmentation thresholds. Their account contrasts a global interpolation version with the selected local method and explains how label-region behavior influenced selection. [Second-place write-up, February 28, 2026](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/writeups/2nd-place-solution-vesuvius-challenge-a-postproc).

**Study question:** why might a local repair be safer than one geometric assumption applied across a whole curved sheet?

### Rank 5 — predict distance to a surface

The fifth-place method regresses a signed distance field using UNet variants, primarily an attention UNet with a SEResNeXt encoder. It averages predictions across models and augmentations, then applies topology-aware tunnel filling. The author describes full-volume inference to avoid sliding-window artifacts and bridge checks to prevent merging components. [Fifth-place write-up, February 28, 2026](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/writeups/5th-place-solution).

**Study question:** what geometric information does a distance field preserve that a hard yes/no mask discards?

### Rank 7 — a comparatively simple ensemble

DECEM and teammates report two nnU-Net models, test-time augmentation, and postprocessing. Kaggle's retrieved write-up metadata says seventh place. The numerical public/private scores in the text appear inconsistent with the ordering suggested by other top write-ups; they are therefore not used to compare ranks here. [Seventh-place write-up, February 28, 2026](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/writeups/7st-place-solution-for-the-vesuvius-challenge).

**Study question:** what can a small, understandable baseline teach you before spending on more models?

## Top-ten coverage — ranks 1 to 5

| Rank | Evidence available | Status |
|---|---|---|
| 1 | Ranked write-up, author names, method and ablation text | Summarized above |
| 2 | Ranked write-up, author names and method text | Summarized above |
| 3 | [Discovered preview link](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/writeups/quick-preview-of-the-3rd-place); page-not-found response | Needs logged-in verification; not summarized |
| 4 | [Discovered title/link](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/writeups/4-th-place-solution) | Method and rank metadata not captured |
| 5 | Ranked write-up and detailed method text | Summarized above |

## Top-ten coverage — ranks 6 to 10

| Rank | Evidence available | Status |
|---|---|---|
| 6 | No source located in bounded search | Missing |
| 7 | Ranked write-up and method summary | Summarized with score caveat |
| 8 | [Discovered title/link](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/writeups/8th-place-solution) | Method and rank metadata not captured |
| 9 | No source located in bounded search | Missing |
| 10 | [Discovered title/link](https://www.kaggle.com/competitions/vesuvius-challenge-surface-detection/writeups/10th-place-solution) | Method and rank metadata not captured |

## Combined lesson — optimize the actual failure

**Original synthesis:** these accessible solutions suggest a useful workflow: first obtain plausible surfaces, then diagnose whether remaining errors are missing regions, unwanted bridges, holes, or detached noise. Each repair has different risks. Model capacity alone does not express those geometric constraints.

For a small learning exercise, use 2D masks before 3D volumes. Count components before and after a closing operation. Look at the image as well as the score. A cleanup that removes a hole but joins two objects needs a clear tradeoff, not an automatic “improved” label.

**Next action — under 2 minutes:** draw one unwanted bridge in your notes and label the two objects it incorrectly joins.
