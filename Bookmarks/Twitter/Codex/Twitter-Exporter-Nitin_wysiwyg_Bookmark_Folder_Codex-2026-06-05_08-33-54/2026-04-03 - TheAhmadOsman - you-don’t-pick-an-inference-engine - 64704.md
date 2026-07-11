---
title: "You don’t pick an Inference Engine"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2026-04-03"
tweet_url: "https://x.com/TheAhmadOsman/status/2040162154398064704"
tweet_type: "original"
likes: 793
retweets: 64
replies: 40
bookmarks: 1091
views: 125847
has_media: false
tags: ["twitter-bookmark", "llm"]
---

# You don’t pick an Inference Engine

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2026-04-03 · 👍 793 · 💬 40 · 🔖 1091 · 👁 125847

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2040162154398064704)

## Tweet Content

You don’t pick an Inference Engine

  You pick a Hardware Strategy
   and the Engine follows

Inference Engines Breakdown
 (Cheat Sheet at the bottom)

> llama.cpp
runs anywhere
CPU, GPU, Mac, weird edge boxes
best when VRAM is tight and RAM is plenty
hybrid offload, GGUF, ultimate portability
not built for serious multi-node scale

> MLX
Apple Silicon weapon
unified memory = “fits” bigger models
than VRAM would allow but also slower than GPUs
clean dev stack (Python/Swift/C++)
sits on Metal (and expanding beyond)
now supports CUDA + distributed too
great for Mac-first workflows, not prod serving

> ExLlamaV2
single RTX box go brrr
EXL2 quant, fast local inference
perfect for 1/2/3/4 GPU(s) setups (4090/3090)
not meant for clusters or non-CUDA

> ExLlamaV3
same idea, but bigger ambition
multi-GPU, MoE, EXL3 quant
consumer rigs pretending to be datacenters
still CUDA-first, still rough edges depending on model

> vLLM
default answer for prod serving
continuous batching, KV cache magic
tensor / pipeline / data parallel
runs on CUDA + ROCm (and some CPUs)
this is your “serve 100s of users” engine

> SGLang
vLLM but more systems-brained
routing, disaggregation, long-context scaling
expert parallel for MoE
built for ugly workloads at scale
lives on top of CUDA / ROCm clusters
this is infra nerd territory

> TensorRT-LLM
maximum NVIDIA performance
FP8/FP4, CUDA graphs, insane throughput
multi-node, multi-GPU, fully optimized
pure CUDA stack, zero portability

  (And underneath all of it:
  Transformers → model architecture
  layer → CUDA / ROCm / TT-Metal
  → compute layer)

What actually happens under the hood:

> Transformers defines the model
> CUDA / ROCm executes it
> TT-Metal (if you’re insane) lets you write the kernel yourself

  The Inference Engine is just
  the orchestrator (simplified)

When running LLMs locally,
the bottleneck isn’t just “VRAM size”

 It isn’t even the model

It’s:
- memory bandwidth (the real limiter)
- KV cache (explodes with long context)
- interconnect (PCIe vs NVLink vs RDMA)
- scheduler quality (batching + engine design)
- runtime overhead (activations, graphs, etc)

  (and your compute stack decides all of this)

 P.S. Unified Memory is way slower than VRAM

Cheat Sheet / Rules of Thumb

> laptop / edge / weird hardware → llama.cpp
> Mac workflows → MLX
> 1–4 RTX GPUs → ExLlamaV2/V3
> general serving → vLLM
> complex infra / long context / MoE → SGLang
> NVIDIA max performance → TensorRT-LLM

---

## Commentary from Other Bookmarks

### @TheAhmadOsman (Ahmad) — 2026-05-04

> Let me make local AI easy for you
> 
> Give Codex Cli the tweet below &amp; tell it:
> 
> - Infer the right Inference Engine from your hardware + tweet content below
> - Use uv+venv
> - Pick the right kernels
> - Tune flags, batching, KVCache, etc
> - Optimize for your hardware &amp; chosen model
> 
> Enjoy

[→ View quote tweet](https://x.com/TheAhmadOsman/status/2051389218686116045)

