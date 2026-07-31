---
title: "I've replaced $4,000/month in LLM infrastructure costs with 8 open-source repos."
author: "Paolo Perrone"
author_url: "https://www.linkedin.com/in/ACoAAAWy1ToBOCCi0ildR12MNTXMvqvygTADf6c"
headline: "Shipping Production AI: Agents, Inference, GPU. Read by 1M+ AI engineers."
date: "2026-04-03"
posted_relative: "4mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7445960834821935104/"
activity_id: "7445960834821935104"
media: "link"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm]
---

# I've replaced $4,000/month in LLM infrastructure costs with 8 open-source repos.

> **Source:** [Paolo Perrone](https://www.linkedin.com/in/ACoAAAWy1ToBOCCi0ildR12MNTXMvqvygTADf6c) · Shipping Production AI: Agents, Inference, GPU. Read by 1M+ AI engineers. · 4mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7445960834821935104/)

## Post

I've replaced $4,000/month in LLM infrastructure costs with 8 open-source repos.

$48,000/year. Gone.

Here's the swap list:

1️⃣ Paid serving API → vLLM (74K ⭐)
Self-hosted inference. PagedAttention, continuous batching.
$0.03/token → $0.002/token overnight.
https://lnkd.in/eeT_HM2B

2️⃣ Cloud fine-tuning platform → Unsloth (50K ⭐)
2x faster. 70% less VRAM. Single A100.
Replaced an $800/month service.
https://lnkd.in/gJZtH4Y4

3️⃣ Paid transcription API → whisper.cpp (45K ⭐)
OpenAI Whisper in C/C++. Runs locally.
Was paying $0.006/minute × 200K minutes. $1,200/month → $0.
https://lnkd.in/ehNtjbSi

4️⃣ Expensive GPU instances → llama.cpp (92K ⭐)
GGUF quantization. 70B models on consumer hardware.
Dev and testing moved from cloud to MacBooks.
https://lnkd.in/eJrUg_qd

5️⃣ Default attention → Flash Attention (21K ⭐)
40% VRAM reduction on long context. Non-negotiable.
Every serving framework uses it. Do you understand WHY it works?
https://lnkd.in/eYkuRuxC

6️⃣ Commercial dev environment → Ollama (158K ⭐)
One command to run any model locally.
Replaced a $200/month tool for the team.
github.com/ollama/ollama

7️⃣ $2,000 CUDA course → LeetCUDA (9K ⭐)
200+ CUDA kernels. Tensor Cores, Flash Attention, HGEMM.
Free. Better than anything I've paid for.
https://lnkd.in/eUfgpwW6

8️⃣ ""Understanding transformers"" bootcamp → llm.c (28K ⭐)
Karpathy's LLM training in raw C/CUDA.
Taught me more about what PyTorch hides than any course.
github.com/karpathy/llm.c

$4,000/month → $200/month. 95% reduction. Same output.

530K+ combined stars. All free.

Which swap would save your team the most? 👇

💾 Bookmark this before your next infrastructure review.

## Links

- https://lnkd.in/eeT_HM2B
- https://lnkd.in/gJZtH4Y4
- https://lnkd.in/ehNtjbSi
- https://lnkd.in/eJrUg_qd
- https://lnkd.in/eYkuRuxC
- https://lnkd.in/eUfgpwW6

