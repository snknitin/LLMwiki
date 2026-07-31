---
title: "An 80B model on 8GB VRAM. No quantization. Full precision. This shouldn't work."
author: "Paolo Perrone"
author_url: "https://www.linkedin.com/in/ACoAAAWy1ToBOCCi0ildR12MNTXMvqvygTADf6c"
headline: "Shipping Production AI: Agents, Inference, GPU. Read by 1M+ AI engineers."
date: "2026-04-26"
posted_relative: "3mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7454208175375015936/"
activity_id: "7454208175375015936"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm]
---

# An 80B model on 8GB VRAM. No quantization. Full precision. This shouldn't work.

> **Source:** [Paolo Perrone](https://www.linkedin.com/in/ACoAAAWy1ToBOCCi0ildR12MNTXMvqvygTADf6c) · Shipping Production AI: Agents, Inference, GPU. Read by 1M+ AI engineers. · 3mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7454208175375015936/)

## Post

An 80B model on 8GB VRAM. No quantization. Full precision. This shouldn't work.

oLLM just made it possible. Here's how:

𝘛𝘩𝘦 𝘱𝘳𝘰𝘣𝘭𝘦𝘮:

qwen3-next-80B needs ~190GB VRAM for baseline inference.
Most engineers don't have $15K worth of GPUs sitting around.

𝘛𝘩𝘦 𝘴𝘰𝘭𝘶𝘵𝘪𝘰𝘯:

oLLM offloads intelligently:

→ Layer weights load from SSD directly to GPU, one at a time
→ KV cache offloads to SSD, loads back when needed
→ FlashAttention-2 with online softmax (no full attention matrix)
→ Chunked MLP for large intermediate projections

𝘛𝘩𝘦 𝘯𝘶𝘮𝘣𝘦𝘳𝘴 (RTX 3060 Ti, 8GB):

→ qwen3-next-80B: 160GB weights, 50K context, ~190GB baseline → 7.5GB with oLLM
→ gpt-oss-20B: 13GB weights, 10K context, ~40GB baseline → 7.3GB with oLLM
→ gemma3-12B: 25GB weights, 50K context, ~45GB baseline → 6.7GB with oLLM
→ llama3-8B: 16GB weights, 100K context, ~71GB baseline → 6.6GB with oLLM

𝘛𝘩𝘦 𝘵𝘳𝘢𝘥𝘦𝘰𝘧𝘧:

Speed. qwen3-next-80B runs at ~1 tok/2s.
Not for real-time chat. Perfect for:

→ Contract and compliance analysis
→ Medical literature processing
→ Large log file analysis
→ Historical chat extraction

𝘛𝘩𝘦 𝘴𝘵𝘢𝘤𝘬:

Built on HuggingFace Transformers and PyTorch.
Works on NVIDIA, AMD, and Apple Silicon.
MIT licensed. 2.4K GitHub stars.

pip install --no-build-isolation ollm

Full repo: https://lnkd.in/e6dP4886

What's the first model you'd run locally if VRAM wasn't the bottleneck? 👇

💾 Save this for when your next model doesn't fit in VRAM.

## Links

- https://lnkd.in/e6dP4886

## Images

![](https://media.licdn.com/dms/image/v2/D4E22AQGgU0NvqiTvxw/feedshare-shrink_480/B4EZ3Kq1bcKAAk-/0/1777221720079?e=1787184000&v=beta&t=5sZzWFJJnpGS3K4Kd5flNLIa4cZCeXX9uMYKoPMOwuE)

