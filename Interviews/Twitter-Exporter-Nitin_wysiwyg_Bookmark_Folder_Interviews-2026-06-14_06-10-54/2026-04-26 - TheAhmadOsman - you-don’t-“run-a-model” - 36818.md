---
title: "You don’t “run a model”"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2026-04-26"
tweet_url: "https://x.com/TheAhmadOsman/status/2048234466519236818"
tweet_type: "original"
likes: 971
retweets: 100
replies: 38
bookmarks: 803
views: 154406
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "llm", "agents"]
---

# You don’t “run a model”

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2026-04-26 · 👍 971 · 💬 38 · 🔖 803 · 👁 154406

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2048234466519236818)

## Tweet Content

You don’t “run a model”
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
- Fused “please don’t write this back to memory 9 times” Kernels

Same model, same GPU, same VRAM
Wildly different performance

Because one stack is using optimized fused Kernels that understand your hardware

And the other stack is playing hot potato with tensors through 47 tiny launches and pretending the GPU is the problem

Bad Kernels make people say:
“this model is slow”

Good Kernels make people say:
“wait how is this running locally?”

This is why Inference Engines and the Kernels implemented within them matter

The model is the recipe
The hardware is the kitchen
The Kernels are the knives, pans, burners, and the chef not cutting onions with a spoon

Most people benchmark models
The real ones benchmark the Kernels underneath

## Media

![](https://pbs.twimg.com/media/HGzKSSraQAElKQ7.jpg)

---

## Commentary from Other Bookmarks

### @TheAhmadOsman (Ahmad) — 2026-04-26

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

[→ View quote tweet](https://x.com/TheAhmadOsman/status/2048413820259832050)

