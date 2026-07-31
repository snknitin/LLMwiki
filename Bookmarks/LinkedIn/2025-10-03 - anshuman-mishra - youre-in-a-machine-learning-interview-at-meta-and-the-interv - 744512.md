---
title: "You’re in a Machine Learning interview at Meta, and the interviewer asks:"
author: "Anshuman Mishra"
author_url: "https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs"
headline: "ML @ Zomato"
date: "2025-10-03"
posted_relative: "10mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7379785274647744512/"
activity_id: "7379785274647744512"
media: "link"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, rag, career, ml]
---

# You’re in a Machine Learning interview at Meta, and the interviewer asks:

> **Source:** [Anshuman Mishra](https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs) · ML @ Zomato · 10mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7379785274647744512/)

## Post

You’re in a Machine Learning interview at Meta, and the interviewer asks:

Why is scaling context length so hard? What’s the fundamental bottleneck?’

Here’s how you answer:

Don’t say: ‘Memory limitations’ or ‘GPU constraints.’ 
Wrong framing. 
The real answer is the O(n²) complexity of self-attention. Every token must attend to every other token. 
Double your context? You 4x your compute. It’s not linear scaling - it’s exponential pain.

NOTE - if you want to read this kinda content daily, consider subscribing my free newsletter - https://lnkd.in/gCPD6fUz

Here’s the math that breaks everything: 

→ 8K context = 64M attention computations. 
→ 128K context = 16B computations
→ 1M context = 1T computations. 

Your compute cost doesn’t grow with n, it grows with n². This is why throwing money at the problem doesn’t solve it.

The architectural constraint everyone misses:
- Full attention means an 8×8 matrix for 8 tokens, 128K×128K matrix for 128K tokens.
- Memory isn’t just storing tokens - it’s storing every possible token relationship.
- At 1M tokens, you need to materialize a 1M×1M attention matrix. That’s 1 trillion float values.

This is why context length is the great divider:

- GPT-4, Llama = 128-200K max (hitting the O(n²) wall) 
- Claude, Gemini 1M = Heavy optimization + unknown architecture tricks + $$$
- Most open source = 32K or less (the practical ceiling) 
- Startups = Can’t afford to compete on context

‘So how do you actually scale past 128K?’ Interviewer leans forward.

This is where Sliding Window Attention (SWA) can help. 

> Instead of every token attending to every token, each token only attends to a fixed window around it. 
> Complexity drops from O(n²) to O(n×w). Suddenly 1M tokens becomes feasible.

The clever part: local attention + deep layers = global understanding.

Token 1 doesn’t directly see token 100K, but through 32 layers of propagation, information flows across the entire sequence. 
Like how CNNs build from edges to objects - each layer has local receptive field but stacks create global vision.
The implementation trick that makes it work: Split Q and K into overlapping chunks (size 2w, overlap w). 

Do attention within chunks only. 
One PyTorch matmul operation. 
Yes, you compute 2x more than theoretically optimal. 
But you go from “impossible” to “runs on one GPU.” That’s the tradeoff that matters.


The answer that gets you hired: 
‘Scaling context is hard because attention is fundamentally O(n²). Full attention at 1M tokens is computationally intractable for most. The solution isn’t more hardware - it’s architectural changes like SWA that break the quadratic bottleneck. Gemini likely uses SWA variants + massive optimization. The math dictates the limits.’

The follow-up that makes you stand out: ‘The interesting question isn’t “how do we get 1M context” - it’s “do we need it?” 

#machinelearning #rag #meta #interview #hiring #cs #ai #datascience #jobs #llm #chatgpt

## Links

- https://lnkd.in/gCPD6fUz

