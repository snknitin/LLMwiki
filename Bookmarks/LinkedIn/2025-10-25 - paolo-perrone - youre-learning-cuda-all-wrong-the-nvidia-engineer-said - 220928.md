---
title: "'You're learning CUDA all wrong,' the NVIDIA engineer said"
author: "Paolo Perrone"
author_url: "https://www.linkedin.com/in/ACoAAAWy1ToBOCCi0ildR12MNTXMvqvygTADf6c"
headline: "Shipping Production AI: Agents, Inference, GPU. Read by 1M+ AI engineers."
date: "2025-10-25"
posted_relative: "9mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7387693771620220928/"
activity_id: "7387693771620220928"
media: "link"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, python]
---

# "You're learning CUDA all wrong," the NVIDIA engineer said

> **Source:** [Paolo Perrone](https://www.linkedin.com/in/ACoAAAWy1ToBOCCi0ildR12MNTXMvqvygTADf6c) · Shipping Production AI: Agents, Inference, GPU. Read by 1M+ AI engineers. · 9mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7387693771620220928/)

## Post

"You're learning CUDA all wrong," the NVIDIA engineer said

Then he showed me their internal training path
"Wait, you DON'T start with code?"

Here's the exact 90-day roadmap they use👇

Phase 1️⃣ Intuition (Week 1-2)
Don't touch CUDA yet. Seriously
Build your mental model of the hardware and the why first

▶︎ UC Berkeley CS 61C, Lecture 17
This is the physics layer. Understand why GPU differs from a CPU
🔗 https://lnkd.in/gVi6Bsut

▶︎ Coursera Parallel Computing Course (First 3 modules only)
Learn parallel algorithms and thinking
🔗 https://lnkd.in/g4FtxbE5

▶︎ Stanford CS231n Lecture 15 - Hardware/Software interface
See how frameworks like PyTorch use hardware for AI
🔗 https://lnkd.in/gzaR7xrZ

Phase 2️⃣ CUDA Basics (Week 3-4)
Now we code

▶︎ NVIDIA's official CUDA C++ Programming Guide (Chapters 1-5 only)
Learn threads, blocks, grids and kernel structure
🔗 https://lnkd.in/gsZsEqPp

▶︎ cuda-samples repo
Reading isn't enough. Compile, run, and modify official NVIDIA examples
🔗 https://lnkd.in/gGRgvm7G

```cuda
__global__ void vectorAdd(float *a, float *b, float *c) {
 int i = blockIdx.x * blockDim.x + threadIdx.x;
 c[i] = a[i] + b[i];
}
```

If this doesn't make sense yet, you skipped Phase 1

Phase 3️⃣ Memory Mastery (Week 5-8)
Where 90% of developers fail, and where all performance hides

▶︎ Mark Harris's GTC Talk on Coalesced Memory Access
Single most important CUDA performance concept
Learn how threads must access global memory in aligned groups
🔗 https://lnkd.in/gz6Nbe5H

▶︎ GPU Gems 3, Chapter 39 - "Parallel Prefix Sum with CUDA"
Masterclass in shared memory to avoid bank conflicts, a fundamental optimization
🔗 https://lnkd.in/gNhZRCHE

▶︎ CUDA C++ Best Practices Guide - "Memory Optimizations" Chapter
Read to understand Global, Shared, Constant, Texture memory models
🔗 https://lnkd.in/grbhz7_V

Phase 4️⃣ Real Kernels (Week 9-12)
Stop playing with toy arrays. Build something that matters

• Implement softmax (harder than you think)
• Write a basic GEMM that doesn't suck
• Port one PyTorch operation to CUDA

Repos that ship:

▶︎ tiny-cuda-nn by NVIDIA
Goldmine of highly optimized, real-world kernels for NN
🔗 https://lnkd.in/gGbFzVsb

▶︎ FlashAttention
Reading this code teaches more on memory-aware kernel design than any book
🔗 https://lnkd.in/g6sMnBsC

▶︎ Triton Language Examples
Modern, Pythonic way to write efficient GPU code, simplifying raw CUDA boilerplate
🔗 github.com/openai/triton

⚡ NVIDIA engineers 6-month shortcut

Skip CUDA
Learn Triton first (handles 80% of use cases better)
Then return to CUDA when hitting limits

The difference between you and everyone else?

You have the map
90 days from now, you'll be shipping production kernels
Not stuck debugging tutorials

♻️ Repost to give someone the shortcut you wish you had

## Links

- https://lnkd.in/gVi6Bsut
- https://lnkd.in/g4FtxbE5
- https://lnkd.in/gzaR7xrZ
- https://lnkd.in/gsZsEqPp
- https://lnkd.in/gGRgvm7G
- https://lnkd.in/gz6Nbe5H
- https://lnkd.in/gNhZRCHE
- https://lnkd.in/grbhz7_V
- https://lnkd.in/gGbFzVsb
- https://lnkd.in/g6sMnBsC

