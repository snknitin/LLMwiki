---
title: "You’re in a Machine Learning interview at Perplexity, and the interviewer asks:"
author: "Anshuman Mishra"
author_url: "https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs"
headline: "ML @ Zomato"
date: "2025-10-07"
posted_relative: "10mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7381312845394694144/"
activity_id: "7381312845394694144"
media: "link"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, agents, llm, rag, career, ml]
---

# You’re in a Machine Learning interview at Perplexity, and the interviewer asks:

> **Source:** [Anshuman Mishra](https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs) · ML @ Zomato · 10mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7381312845394694144/)

## Post

You’re in a Machine Learning interview at Perplexity, and the interviewer asks:

“Why do we need hybrid search? Isn’t vector search with embeddings enough?”

Here’s how you answer:

Don’t say: “To combine different approaches” or “For better coverage.”

Too generic. The real answer is the semantic-lexical gap. 

Your embeddings understand meaning but ignore exact matches. Vector search alone misses the forest for the trees - or worse, the exact product code the user typed.

Here’s why pure vector search fails:

Your query is “iPhone 15 Pro Max 256GB.” Vector search returns “iPhone 15 Pro with lots of storage” and “latest flagship phone specs.” But the user wants EXACT model + EXACT capacity.

Semantic understanding ≠ Precision matching.

btw i post daily, don't miss by subbing to my newsletter - https://lnkd.in/g8ZJGsWj 

The retrieval failure modes are brutal:

Pure vector search:

> Query: “ML-2847 error code” → Returns: General ML troubleshooting (0% useful)
> Query: “React 18.2.0 breaking changes” → Returns: React 18 overview (no version precision)

Pure keyword search (BM25):

> Query: “how to fix car not starting” → Returns: Docs with “car” and “starting” but about starting a car business

You need both. Always.

The performance gap across real benchmarks:

> BM25 alone: 67% MRR@10
> Dense retrieval alone: 71% MRR@10
> Hybrid (proper fusion): 82% MRR@10

That’s 15% improvement over the “best” single method. In production, that’s thousands of better answers per day.

The fundamental tradeoff everyone misses:

> BM25 (sparse vectors): Term frequency matching. Perfect for exact keywords, acronyms, codes. Fails at synonyms.
> Dense embeddings: Semantic similarity. Perfect for meaning, paraphrases. Fails at exact matches.

This is why you can’t pick one. You need intelligent fusion.

The scoring difference that matters:

BM25: score(q,d) = Σ IDF(term) × TF(term,d) × norm(d)
Dense: score(q,d) = cosine(embed(q), embed(d))

These scores aren’t comparable! BM25 gives 0-15, cosine gives 0.7-0.95.

This is why naive averaging fails. You need score normalization.

The fusion algorithms you must know:

1. Reciprocal Rank Fusion (RRF):
score(d) = Σ 1/(k + rank_method_i(d))
No score normalization needed
Robust to score scale differences
Used by Elastic, Pinecone

2. Weighted combination:
score(d) = α × norm(score_bm25) + (1-α) × norm(score_dense)
Requires score normalization
α typically 0.3-0.5
More control but more tuning

The answer that gets you hired:

Hybrid search combines lexical precision with semantic understanding
BM25 catches exact matches embeddings miss; embeddings catch meaning BM25 misses
The cost is running two retrievals + fusion (adds ~10ms)

It’s not optional for production search - it’s the recall multiplier

#rag #search #chatgpt #machinelearning #datacience #aiagents

## Links

- https://lnkd.in/g8ZJGsWj

