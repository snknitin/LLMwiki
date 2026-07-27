---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Spatial Media and Experimental Ideas#13. Audio Watermark and Perception Lab]]"
status: concept
difficulty: hard
priority: p2
category: audio research
form_factor:
  - local experiment dashboard
deployment: workstation plus DGX Spark
source_ideas:
  - code or subliminal messaging in music and songs
tags:
  - audio
  - watermarking
  - perception
  - provenance
---

# Audio Watermark and Perception Lab

> A transparent laboratory for embedding/detecting machine-readable audio watermarks, testing robustness under edits, and running level-matched ABX perception experiments—not a covert persuasion system.

## Product Outcome

Given local audio, embed a declared watermark/payload, apply a controlled attack matrix, measure detector behavior, and compare perceptual quality. Pair signal watermarking with a signed provenance sidecar so the lab shows what each mechanism can and cannot prove.

## Personal V0

- Import local speech/music and generate unwatermarked controls.
- Embed an AudioSeal-style watermark and optional small payload.
- Apply resampling, codecs, cropping, time stretch, pitch shift, mixing, denoising, clipping, and analog-like noise.
- Measure true/false positives, localization, payload recovery, and robustness curves.
- Run randomized, loudness-matched ABX listening sessions.
- Store seed, model, transform chain, detector threshold, and result.
- Compare watermark against a signed hash/manifest baseline.

## Build Boundary

**MVP:** offline local files, one watermark scheme, ten declared transforms, decoy controls, and ABX UI.

**Later:** multiple schemes, streaming detection, adversarial attacks, C2PA-compatible manifests, rights-clean training, and larger listener studies. Covert persuasive/political/commercial messaging and unsafe inaudible-signal experiments are excluded.

## Existing Products, Building Blocks, and Shortcuts

- [AudioSeal](https://github.com/facebookresearch/audioseal) provides open watermark embedding/detection, payloads, localization, and streaming support; it is the obvious first scheme.
- Google [SynthID](https://deepmind.google/models/synthid/) is a product reference for generated-audio watermarking, while [C2PA](https://spec.c2pa.org/specifications/) provides signed provenance manifests that can complement or replace a signal watermark.
- FFmpeg/SoX implement the attack matrix; librosa provides measurements. A local Streamlit page can run ABX tests and plot false positives/robustness.
- Simplest baseline: signed sidecar hash with no signal modification. If it solves provenance, the watermark experiment remains a research comparison rather than mandatory infrastructure.

## Free-First Stack

- **Models:** Python, PyTorch, and AudioSeal.
- **Transforms:** FFmpeg/SoX and librosa.
- **UI:** Streamlit/Gradio experiment console.
- **Data:** SQLite/Parquet plus content-addressed audio artifacts.
- **Provenance:** signed JSON sidecars and hashes; C2PA experiment later.
- **Compute:** workstation first; DGX Spark for batch/adversarial testing.
- **Safety:** hard output limiter and documented listening level.

## Clever Hacks and Simpler Alternative

- Include unwatermarked decoys in every detector run to expose false positives.
- Calibrate loudness before ABX; small gain differences bias judgment.
- Report robustness, perceptual quality, payload capacity, and localization separately.
- A signed sidecar may solve the actual provenance requirement without modifying sound.
- Freeze transform recipes so schemes are compared on identical attacks.

## Build Slices

1. Artifact/experiment schema and controls.
2. One embed/detect pipeline.
3. Attack matrix and robustness dashboard.
4. ABX interface and level matching.
5. Signed provenance baseline.
6. Multi-scheme/adversarial evaluation.

## Battle-Testing Gates

- False-positive tests include varied unwatermarked sources.
- Every transform is reproducible from config.
- Listening output is limited and sessions are randomized.
- Detector thresholds are selected on held-out data.
- Claims distinguish scheme detection from proof of authorship.

## Product Path

This is a strong DGX research project and possible open evaluation toolkit. Product or public-audio use can receive its release audit later; the current lab remains private and transparent.

## Related

- [[Song Phrase Mosaic]]
- [[Neural Fractal Visualizer]]
- [[Visual Token Compiler]]
- [[Project Ideas Index]]
