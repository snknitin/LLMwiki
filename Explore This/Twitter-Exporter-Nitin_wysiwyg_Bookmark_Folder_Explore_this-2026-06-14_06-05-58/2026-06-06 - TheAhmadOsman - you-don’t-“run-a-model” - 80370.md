---
title: "You don’t “run a model”"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2026-06-06"
tweet_url: "https://x.com/TheAhmadOsman/status/2063082910131880370"
tweet_type: "original"
likes: 553
retweets: 63
replies: 19
bookmarks: 442
views: 49343
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "llm", "agents"]
---

# You don’t “run a model”

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2026-06-06 · 👍 553 · 💬 19 · 🔖 442 · 👁 49343

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2063082910131880370)

## Tweet Content

You donâ€™t â€œrun a modelâ€
You run Kernels

The model is just a graph

The Inference Engine is scheduler / optimizer / executor

But the actual work? That happens in the Kernels

- MatMul Kernels
- Attention Kernels
- RMSNorm Kernels
- KV cache Kernels
- Quantized linear Kernels
- Sampling Kernels
- Fused â€œplease donâ€™t write this back to memory 9 timesâ€ Kernels

Same model, same GPU, same VRAM
Wildly different performance

Because one stack is using optimized fused Kernels that understand your hardware

And the other stack is playing hot potato with tensors through 47 tiny launches and pretending the GPU is the problem

Bad Kernels make people say:
â€œthis model is slowâ€

Good Kernels make people say:
â€œwait how is this running locally?â€

This is why Inference Engines and the Kernels implemented within them matter

The model is the recipe
The hardware is the kitchen
The Kernels are the knives, pans, burners, and the chef not cutting onions with a spoon

Most people benchmark models
The real ones benchmark the Kernels underneath

## Media

![](https://pbs.twimg.com/media/HKGK-B7W8AAIsu8.jpg)

---

## Commentary from Other Bookmarks

### @TheAhmadOsman (Ahmad) — 2026-06-08

> How to go about learning all of this?
> 
> 1st: Start with the serving engine view
> 
> - vLLM: PagedAttention, continuous batching, prefix caching, CUDA graphs
> 
> - SGLang: RadixAttention/prefix reuse, speculative decoding, MoE, structured/agent workloads
> 
> - TensorRT-LLM: NVIDIA peak stack, FP8/FP4, Wide-EP, disaggregated serving
> 
> - FlashInfer: reusable kernel/operator library for attention/GEMM/MoE/sampling
> 
> 2nd: Go down the stack
> 
> - Triton tutorials → custom fused kernels
> 
> - CUTLASS/CuTe → Tensor Core GEMM and Blackwell/Hopper details
> 
> - FlashAttention papers → attention algorithm/kernel co-design
> 
> - PagedAttention paper → KV-cache memory management
> 
> - MoE docs → routing + grouped GEMM + all-to-all
> 
> - Nsight profiling → stop guessing
> 
> 3rd: Do this mini-project sequence
> 
> 1. Implement RMSNorm in Triton; compare to PyTorch
> 
> 2. Implement fused SiLU × gate
> 
> 3. Implement simple FP16 matmul; compare to cuBLAS/rocBLAS
> 
> 4. Implement paged KV lookup for decode attention
> 
> 5. Add FP8 KV cache with per-block scales
> 
> 6. Implement toy top-k sampling on GPU
> 
> 7. Implement tiny MoE dispatch + grouped GEMM
> 
> 8. Integrate one custom op into vLLM or SGLang and profile end-to-end

[→ View quote tweet](https://x.com/TheAhmadOsman/status/2063935919481106560)

