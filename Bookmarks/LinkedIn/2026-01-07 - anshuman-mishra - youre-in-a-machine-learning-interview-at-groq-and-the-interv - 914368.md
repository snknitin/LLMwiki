---
title: "You’re in a Machine Learning interview at Groq, and the interviewer asks:"
author: "Anshuman Mishra"
author_url: "https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs"
headline: "ML @ Zomato"
date: "2026-01-07"
posted_relative: "7mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7414644565929914368/"
activity_id: "7414644565929914368"
media: "link"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, rag, career, ml, prompting]
---

# You’re in a Machine Learning interview at Groq, and the interviewer asks:

> **Source:** [Anshuman Mishra](https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs) · ML @ Zomato · 7mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7414644565929914368/)

## Post

You’re in a Machine Learning interview at Groq, and the interviewer asks:

“Why do we need prompt caching? Can’t we just resend the full context every time?”

Here’s how you answer:

Don’t say: “To save money” or “To make things faster.”

Too shallow. The real answer is the quadratic cost problem. Every token you send gets processed EVERY TIME. No caching = paying to recompute the same context thousands of times.

Here’s why naive API calls fail:

Your system sends the same 100k token context (docs, examples, system prompt) with every request. That’s 100k tokens × $3/1M input tokens × 1000 requests = $300. But 95% of those tokens NEVER CHANGE.

Computation ≠ Communication.

get this in your inbox, for free, subscribe - https://lnkd.in/g8ZJGsWj 

The caching economics are brutal:

Without caching: 100k context + 1k query = 101k tokens processed per request
First request with cache: 100k tokens (write to cache) + 1k query = 101k processed
Subsequent cached requests: 1k tokens processed (90% cost reduction)

You’re burning 90% of your budget reprocessing static context. That’s the difference between a sustainable system and bankruptcy.

The fundamental tradeoff everyone misses:

No cache (stateless): Simple architecture. Every token processed fresh. Expensive but predictable.

With cache (stateful): Complex cache invalidation. 90% cheaper for warm cache. But cache misses hurt.

This is why you can’t cache everything. You need the right cache strategy.

Why the cache hierarchy exists:

L1 (System prompt): 5k tokens, never changes (99% hit rate, 5min TTL)
L2 (Retrieved docs): 50k tokens, changes per session (70% hit rate, 5min TTL)
L3 (Few-shot examples): 20k tokens, changes per task (40% hit rate, 5min TTL)
No cache (User query): 1k tokens, always unique

No caching = $0.30/request Smart caching = $0.03/request 
That’s 10x ROI on cache engineering.

The architectural difference that matters:

No cache: process(system + docs + examples + query)
With cache: cache_hit(system + docs + examples) + process(query)
That cache_hit changes everything. 

Now your system:

- Skips redundant transformer passes
- Reuses KV cache from previous runs
- Only processes the delta (new query)

The latency improvement people ignore:

Without cache: 100k token context = ~8 seconds TTFT
With cache: 1k token query = ~0.3 seconds TTFT
That’s 25x faster time-to-first-token. Your users feel this immediately.
Speed isn’t a side effect of caching. It’s half the value.

“So how do you design prompts for optimal caching?” Interviewer leans in.

This is where you mention:

Static-first ordering: System prompt → Examples → Tools → Retrieved docs → Query

The killer combo that 10x systems use:

Cache your static context (system + examples)
Cache your retrieved docs per session
Use semantic cache for similar queries
Implement cache warming for high-traffic patterns

#chatgpt #rag #caching #llm #machinelearning

## Links

- https://lnkd.in/g8ZJGsWj

