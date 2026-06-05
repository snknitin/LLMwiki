---
title: "step-by-step LLM Engineering Projects"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2025-12-19"
tweet_url: "https://x.com/TheAhmadOsman/status/2002073445438226505"
tweet_type: "original"
likes: 397
retweets: 33
replies: 9
bookmarks: 517
views: 20684
has_media: false
tags: ["twitter-bookmark", "llm"]
---

# step-by-step LLM Engineering Projects

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2025-12-19 · 👍 397 · 💬 9 · 🔖 517 · 👁 20684

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2002073445438226505)

## Tweet Content

step-by-step LLM Engineering Projects

each project = one concept learned the hard (i.e. real) way

    Tokenization & Embeddings

> build byte-pair encoder + train your own subword vocab
> write a “token visualizer” to map words/chunks to IDs
> one-hot vs learned-embedding: plot cosine distances

    Positional Embeddings

> classic sinusoidal vs learned vs RoPE vs ALiBi: demo all four
> animate a toy sequence being “position-encoded” in 3D
> ablate positions—watch attention collapse

    Self-Attention & Multihead Attention

> hand-wire dot-product attention for one token
> scale to multi-head, plot per-head weight heatmaps
> mask out future tokens, verify causal property

    transformers, QKV, & stacking

> stack the Attention implementations with LayerNorm and residuals → single-block transformer
> generalize: n-block “mini-former” on toy data
> dissect Q, K, V: swap them, break them, see what explodes

    Sampling Parameters: temp/top-k/top-p

> code a sampler dashboard — interactively tune temp/k/p and sample outputs
> plot entropy vs output diversity as you sweep params
> nuke temp=0 (argmax): watch repetition

    KV Cache (Fast Inference)

> record & reuse KV states; measure speedup vs no-cache
> build a “cache hit/miss” visualizer for token streams
> profile cache memory cost for long vs short sequences

    Long-Context Tricks: Infini-Attention / Sliding Window

> implement sliding window attention; measure loss on long docs
> benchmark “memory-efficient” (recompute, flash) variants
> plot perplexity vs context length; find context collapse point

    Mixture of Experts (MoE)

> code a 2-expert router layer; route tokens dynamically
> plot expert utilization histograms over dataset
> simulate sparse/dense swaps; measure FLOP savings

    Grouped Query Attention

> convert your mini-former to grouped query layout
> measure speed vs vanilla multi-head on large batch
> ablate number of groups, plot latency

    Normalization & Activations

> hand-implement LayerNorm, RMSNorm, SwiGLU, GELU
> ablate each—what happens to train/test loss?
> plot activation distributions layerwise

    Pretraining Objectives

> train masked LM vs causal LM vs prefix LM on toy text
> plot loss curves; compare which learns “English” faster
> generate samples from each — note quirks

    Finetuning vs Instruction Tuning vs RLHF

> fine-tune on a small custom dataset
> instruction-tune by prepending tasks (“Summarize: ...”)
> RLHF: hack a reward model, use PPO for 10 steps, plot reward

    Scaling Laws & Model Capacity

> train tiny, small, medium models — plot loss vs size
> benchmark wall-clock time, VRAM, throughput
> extrapolate scaling curve — how “dumb” can you go?

    Quantization

> code PTQ & QAT; export to GGUF/AWQ; plot accuracy drop

    Inference/Training Stacks:

> port a model from HuggingFace to Deepspeed, vLLM, ExLlama
> profile throughput, VRAM, latency across all three

    Synthetic Data

> generate toy data, add noise, dedupe, create eval splits
> visualize model learning curves on real vs synth

    each project = one core insight. build. plot. break. repeat.

> don’t get stuck too long in theory
> code, debug, ablate, even meme your graphs lol
> finish each and post what you learned

your future self will thank you later

