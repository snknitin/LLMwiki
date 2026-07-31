---
title: "DeepSeek already released 2 important papers in 2026 that give us a glimpse of what DeepSeek v4 coul..."
author: "Elie Bakouch"
author_url: "https://www.linkedin.com/in/ACoAADLuNQMBPkdtEypMvPXirXZdN0zPGqa6s9Y"
headline: "Research at Prime Intellect, prev: Hugging Face"
date: "2026-01-17"
posted_relative: "6mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7418305261171412992/"
activity_id: "7418305261171412992"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, rag]
---

# DeepSeek already released 2 important papers in 2026 that give us a glimpse of what DeepSeek v4 coul...

> **Source:** [Elie Bakouch](https://www.linkedin.com/in/ACoAADLuNQMBPkdtEypMvPXirXZdN0zPGqa6s9Y) · Research at Prime Intellect, prev: Hugging Face · 6mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7418305261171412992/)

## Post

DeepSeek already released 2 important papers in 2026 that give us a glimpse of what DeepSeek v4 could be, let's cover the latest one: Engram.

The problem: current LLMs waste their early layers reconstructing simple patterns like "Alexander the Great" or "Princess of Wales", things that could just be looked up instead of computed. That's precious depth that could be used for actual reasoning.

The solution: Engram adds a new layer specialized in efficient retrieval. It stores common n-gram patterns (sequences of 2-3 tokens) in a massive embedding table and retrieves them instantly via hashing. The model then uses a smart gating mechanism to decide "does this retrieved pattern actually make sense in my current context?" and filters out noise.

And of course it's DeepSeek, so the system design works nicely with hardware. Since retrieval indices are known from the input tokens (no need to wait for hidden states like MoE routing), you can prefetch embeddings while the GPU computes earlier layers. This means you can offload a 100B parameter table to CPU memory with less than 3% overhead, likely similar to what Gemma 3n does and why they don't count those params in the size of their model

One of the most important quotes of the paper is the last sentence: "We envision conditional memory as an indispensable modeling primitive for next-generation sparse models"

They probably meant sparse for MoE, but i could see how this helps sparse attention as well, it gives more freedom for attention so you can learn the same amount with less attention?

Overall he idea builds on previous work from google like Per-Layer Embeddings and N-grammer, they scale it and got some pretty convincing results.

## Images

![](https://media.licdn.com/dms/image/v2/D4E22AQGCjyXpIetCCQ/feedshare-shrink_480/B4EZvMdUy8HEAs-/0/1768661798574?e=1787184000&v=beta&t=73k5IfVXPgOAJ7lLEbTlXYxKBUIgVZLJhKaUBSLOKlI)

