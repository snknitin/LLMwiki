---
title: "You're in a Machine Learning Engineer interview at OpenAI. The interviewer sets a trap:"
author: "Hao Hoang"
author_url: "https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y"
headline: "I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents"
date: "2025-12-12"
posted_relative: "8mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7405214643289260033/"
activity_id: "7405214643289260033"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, rag, career, ml]
---

# You're in a Machine Learning Engineer interview at OpenAI. The interviewer sets a trap:

> **Source:** [Hao Hoang](https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y) · I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents · 8mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7405214643289260033/)

## Post

You're in a Machine Learning Engineer interview at OpenAI. The interviewer sets a trap:

"We need to optimize inference for batch size 128. Should we use Speculative Decoding?"

90% of candidates walk right into the trap.

They answer: "No. At batch size 128, the GPU is fully saturated (compute-bound). Running a draft model just adds overhead and kills throughput."

It sounds logical. It is standard textbook advice.
It is also completely wrong for modern workloads.

Here is the blind spot.
The candidates are assuming standard RAG (2k tokens). But in Long Context Inference (100k+ tokens), the bottleneck shifts violently.

The candidates aren't stalled by matrix multiplication, they are choking on memory bandwidth.

-----
𝐓𝐡𝐞 𝐑𝐞𝐚𝐥𝐢𝐭𝐲:
- Model Weights are shared across the batch (loaded once).
- KV Cache is unique to every single request (loaded 128 times).

At 128k context, moving that massive KV cache from VRAM to the compute unit takes longer than the actual math. Your A100 isn't calculating; it's waiting for data.

-----
𝐓𝐡𝐞 𝐒𝐨𝐥𝐮𝐭𝐢𝐨𝐧: The Senior Engineer knows the fix: 𝐒𝐞𝐥𝐟-𝐒𝐩𝐞𝐜𝐮𝐥𝐚𝐭𝐢𝐯𝐞 𝐊𝐕 𝐂𝐨𝐦𝐩𝐫𝐞𝐬𝐬𝐢𝐨𝐧.

Instead of using a separate draft model, you use the same 70B model to speculate, but you only load the Top-1% of the KV cache.

Because you are memory-bound, fetching a tiny cache is instant. You speculate the next token cheaply, then verify with the full cache. Since the bottleneck was IO, you get the speedup without the compute penalty.

𝐓𝐡𝐞 𝐀𝐧𝐬𝐰𝐞𝐫 𝐓𝐡𝐚𝐭 𝐆𝐞𝐭𝐬 𝐘𝐨𝐮 𝐇𝐢𝐫𝐞𝐝:
"For Long Context, high batch sizes remain memory-bound due to unique KV Caches. We enable self-speculation to bypass the I/O bottleneck, trading cheap compute for expensive memory bandwidth."

