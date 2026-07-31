---
title: "How I cut ML inference cost 4.2x and sped it up 6.7x."
author: "Paolo Perrone"
author_url: "https://www.linkedin.com/in/ACoAAAWy1ToBOCCi0ildR12MNTXMvqvygTADf6c"
headline: "Shipping Production AI: Agents, Inference, GPU. Read by 1M+ AI engineers."
date: "2026-06-30"
posted_relative: "1mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7477828715759054849/"
activity_id: "7477828715759054849"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, ml]
---

# How I cut ML inference cost 4.2x and sped it up 6.7x.

> **Source:** [Paolo Perrone](https://www.linkedin.com/in/ACoAAAWy1ToBOCCi0ildR12MNTXMvqvygTADf6c) · Shipping Production AI: Agents, Inference, GPU. Read by 1M+ AI engineers. · 1mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7477828715759054849/)

## Post

How I cut ML inference cost 4.2x and sped it up 6.7x.

No new GPUs. Just better engineering.

1) Profile first
Found GPUs underutilized. 
Frame decoding and prep ate most of the time. Not the model itself.

2) Ditch PyTorch for production
I shipped that code for 6 months before I learned why it was bleeding money.
→ Compiled to ONNX
→ Optimized to TensorRT engines per GPU type
→ NVIDIA Triton as the single inference server

3) Producer-consumer architecture
→ Multiple CPU containers decode video and prep frames
→ Triton auto-batches for TensorRT (min/ideal/max batch sizes)
→ Shared GPU memory between producers and consumers
→ Killed gRPC/HTTP data transmission overhead

4) Brute-force the cost frontier
→ EC2 type × GPU type × CPU count × RAM × producer-consumer ratio
→ Ran every combination
→ Picked highest throughput per dollar

5) Redeploy clean
→ Sidecar pattern on EKS pods
→ Validated against live data
→ Matched pricing estimates

The lesson:

PyTorch is great for PoC.

Triton + ONNX + TensorRT is how you ship inference that scales.

What tools are you using for production inference? 👇

♻️ Repost for the engineer about to spin up their 4th EC2 instance instead of profiling their stack.

