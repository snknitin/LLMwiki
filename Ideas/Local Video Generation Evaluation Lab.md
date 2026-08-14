---
type: evaluation-workflow-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Creator Growth and Local Video Pipelines#7. Local Video Generation Evaluation Lab]]"
status: experiment-ready
difficulty: hard
priority: p1
category: local generative video evaluation
form_factor:
  - CLI benchmark harness
  - ComfyUI and Diffusers runners
  - local comparison dashboard
deployment: RTX workstation plus optional DGX Spark
source_ideas:
  - test MiniMax H3 local RTX video generation
  - compare Hailuo MiniMax Higgsfield and open local video pipelines
tags:
  - video-generation
  - rtx
  - benchmark
  - comfyui
  - minimax-h3
---

# Local Video Generation Evaluation Lab

> A reproducible lab for answering one practical question: which exact local or hosted video-generation configuration produces an acceptable clip for a specific job on the available hardware, at an acceptable latency, memory footprint, setup burden, and cost?

## Product Outcome

The lab runs a fixed creator-task suite through versioned model/runtime adapters, records exact configuration and hardware telemetry, validates output media, supports blind pairwise review, and produces a Pareto view of quality, acceptance rate, time-to-first-acceptable-clip, latency, peak VRAM/RAM, disk footprint, and hosted cost.

It is not a prompt gallery or universal leaderboard. Results belong to a task, model revision, runtime, precision, attention backend, offload mode, resolution, frames, steps, seed, and machine.

## Important Deployment Clarification

- MiniMax [H3-Base](https://huggingface.co/MiniMaxAI/MiniMax-H3) has open local weights and supports short audio-video generation. H3-Context-IR and 2K regeneration are not the same local base release and may use hosted MiniMax services.
- [Hailuo 2.3/02](https://platform.minimax.io/docs/guides/video-generation) is a hosted asynchronous API comparison, not a downloadable local RTX model.
- [Higgsfield CLI](https://github.com/higgsfield-ai/cli) submits hosted jobs; it does not make the catalog models run locally.
- Component/download size is not peak VRAM. The harness must measure VRAM, RAM, wall time, and failure on the exact workstation.

## Personal V0

1. Inventory workstation GPU, VRAM, RAM, disk, driver, CUDA, Python/PyTorch, and ComfyUI.
2. Implement one ComfyUI runner and one Diffusers runner that emit a shared run manifest.
3. Start with one low-memory sanity model, one documented quality candidate, and one hosted control—not every model.
4. Create 24 fixed cases covering people, motion, object physics, product detail/text, camera movement, first/last frames, reference preservation, narrative continuity, audio/lip sync, 9:16 ads, and talking-head/B-roll.
5. Use three seeds for serious comparisons.
6. Measure cold/warm time, generation/decode, P50/P95, peak VRAM/RAM, failures/retries, output dimensions/frames/audio, and disk.
7. Run blinded pairwise review and record accept/reject plus manual edit minutes.

## Build Boundary

**MVP:** hardware/software inventory, shared run manifest, one ComfyUI runner, one Diffusers runner, FFmpeg validation, telemetry, one low-memory local baseline, one quality candidate, one hosted control, fixed task cases, and blind pairwise review.

**Later:** a broader model matrix, automated VBench subsets, multi-GPU/DGX runners, distributed queues, public result publishing, and packaged model installation. The lab evaluates official weights and runtimes; it does not implement a new video model or silently combine hosted preprocessing with a “local” result.

## Candidate Build Order

1. **Harness sanity:** Wan2.1 1.3B, LTX-Video, or quantized CogVideoX.
2. **16 GB class:** [HunyuanVideo-1.5](https://github.com/Tencent-Hunyuan/HunyuanVideo-1.5) 480p distilled documents a 14 GB offloaded minimum and an RTX 4090 result under 75 seconds.
3. **24 GB class:** Wan2.2 TI2V-5B plus an empirical H3 preview test; do not promise H3 fit from file sizes.
4. **Larger memory:** LTX-2 and less aggressive H3 configurations.
5. **Low-VRAM/long output:** [FramePack](https://github.com/lllyasviel/framepack), with honest per-frame time.
6. **Hosted controls:** Hailuo and one Higgsfield workflow, recording date, queue, generation, download, and cost.
7. **DGX Spark:** treat as a distinct hardware runner, not directly comparable to desktop RTX timings.

## Existing Products, Building Blocks, and Shortcuts

- [ComfyUI’s MiniMax H3 guide](https://docs.comfy.org/tutorials/video/minimax/minimax-h3) provides native H3 workflows and practical component variants.
- [Diffusers memory optimization](https://huggingface.co/docs/diffusers/optimization/memory) and quantization documentation define offload/precision options that must be recorded as experimental variables.
- Official repositories for [Wan2.1](https://github.com/Wan-Video/Wan2.1), [Wan2.2](https://github.com/Wan-Video/Wan2.2), [LTX-2](https://github.com/Lightricks/LTX-2), [CogVideoX](https://huggingface.co/zai-org/CogVideoX-5b), and FramePack provide candidate runners.
- [VBench](https://github.com/Vchitect/VBench) offers standardized diagnostic dimensions; human blind review remains the decision method.
- FFmpeg/ffprobe validates duration, resolution, frame rate, corrupt frames, audio presence, sample rate, and A/V drift.
- NVIDIA tooling (`nvidia-smi`) plus process telemetry supplies memory/utilization; record sampling interval and peak limitations.

## Recommended Free-First Stack

- Python/Typer CLI and Pydantic run manifests.
- ComfyUI API adapter plus per-model Diffusers environments.
- SQLite/Parquet results and YAML/JSON sidecars.
- FFmpeg/ffprobe media validation.
- pynvml/nvidia-smi, psutil, and monotonic timers for telemetry.
- Static HTML or SvelteKit blinded pairwise review UI.
- VBench subset after the core harness is trustworthy.

## Immutable Run Manifest

Record task case, runner, workflow hash, exact model/component revisions and file hashes, OS/GPU/VRAM/driver/CUDA/PyTorch, precision/quantizer/attention/offload/tiling, prompt and structured scene spec, input assets, resolution/frames/fps/steps/guidance/seed, cold/warm timestamps, peak resources, success/error, output hash, and hosted cost fields.

`H3 INT8 + NVFP4 + Sage Attention + group offload` is a different benchmark subject from BF16 + standard attention. Never combine their best quality and best speed in one row.

## Build Slices

1. Hardware/software inventory and task-case manifest.
2. FFmpeg validator, telemetry, and dummy runner.
3. Low-memory local baseline and reproducibility test.
4. ComfyUI/Diffusers adapter boundary.
5. Blind pairwise review and Pareto dashboard.
6. HunyuanVideo-1.5/Wan/H3 candidates based on hardware.
7. Hosted Hailuo/Higgsfield controls.
8. Relevant VBench diagnostics and periodic regression suite.

## Drawbacks, Concerns, and Failure Modes

- “Runs on 8 GB” may hide unusable CPU offload. Always report wall time and peak system RAM.
- Workflow defaults can change. Hash JSON and every component.
- Quantization may harm temporal/audio quality even if one frame looks good.
- Hosted models drift. Label model name and test date.
- One seed is anecdotal. Use multiple seeds and acceptance rate.
- Automatic metrics can disagree with the creator task. Pair them with blind review and edit effort.
- Installing every model wastes disk and setup time. Make the harness earn each download.

## Clever Hacks and Simpler Alternative

- V0 can be a CLI that writes manifests plus a static pairwise-review page.
- Test output validation and telemetry on a tiny model before large downloads.
- Use one literal shared scene specification plus one disclosed model-specific prompt.
- Track **accepted clips per GPU-hour** and **time to first acceptable clip**, not only generation time.
- Preserve failed runs; reliability is a product metric.

## Success Measures

- A run reproduces from its manifest or clearly reports unavailable dependencies.
- Model/config comparisons are blind and task-specific.
- The dashboard never confuses file size, VRAM, and system RAM.
- Failures, queue time, decode time, and retries are included.
- The lab selects a practical renderer for Meta ads, shorts B-roll, or animatics with defensible evidence.

## Product Path

Personal RTX benchmark harness -> shared internal renderer-selection service -> open reproducibility toolkit -> hosted evaluation product. Apply [[Scope Expansion Checklist]] before publishing benchmarks or packaging model workflows; retain hashes and provenance now.

## Related

- [[Meta Ad Creative Studio]]
- [[Longform-to-Shorts Studio]]
- [[Manga-to-Animatic Studio]]
- [[Creator Content Engine]]
- [[Auto-GTM Engine]]
- [[Project Ideas Index]]
