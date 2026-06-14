---
title: "last week, LMSYS quietly dropped one of the cleanest"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2025-12-27"
tweet_url: "https://x.com/TheAhmadOsman/status/2004761075284127861"
tweet_type: "original"
likes: 410
retweets: 59
replies: 13
bookmarks: 430
views: 23534
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "llm"]
---

# last week, LMSYS quietly dropped one of the cleanest

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2025-12-27 · 👍 410 · 💬 13 · 🔖 430 · 👁 23534

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2004761075284127861)

## Tweet Content

last week, LMSYS quietly dropped one of the cleanest
â€œlearn LLM inferenceâ€ projects out there  

> Mini-SGLang

itâ€™s basically a production-grade serving stack
compressed into ~5k lines of readable Python

in this project, youâ€™ll implement the core mechanics
behind modern LLM inference systems:

> FlashAttention-3 + FlashInfer
> fully working kernels

> tensor parallelism
> scale decode cleanly across GPUs

> chunked prefill
> serve long context without blowing memory

> JIT-compiled CUDA ops
> see how kernels are stitched at runtime

> overlap scheduling
> hide CPU orchestration behind GPU compute

> radix cache
> reuse KV cache across shared prefixes

> OpenAI-compatible API
> serve models like production systems do

what makes it special

> online + offline inference
> streaming output
> overlap scheduling actually implemented
> no toy shortcuts

everything you learn here transfers directly
to real serving stacks

youâ€™ll understand

> how schedulers work under concurrency
> where latency actually hides
> how KV reuse changes throughput
> why chunking beats naive prefill
> how TP interacts with cache + decode

the design philosophy

> small codebase
> fully type-annotated
> modular
> debuggable
> meant to be read end-to-end

run it yourself

> single-GPU: small models
> multi-GPU: 70B-class models
> same codepath, same API

if you want to actually learn LLM inference
> not slides
> not diagrams

> read the code (with your favorite LLM)
> step through the scheduler
> trace the cache
> break it
> fix it

this is what modern LLM serving looks like

## Media

![](https://pbs.twimg.com/media/G9JWqlyWQAAh_z9.jpg)

