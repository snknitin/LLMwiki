---
title: "You're in a Machine Learning Interview at Perplexity, and the interviewer asks:"
author: "Anshuman Mishra"
author_url: "https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs"
headline: "ML @ Zomato"
date: "2025-10-04"
posted_relative: "10mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7380217740675993600/"
activity_id: "7380217740675993600"
media: "link"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, rag, career, ml]
---

# You're in a Machine Learning Interview at Perplexity, and the interviewer asks:

> **Source:** [Anshuman Mishra](https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs) · ML @ Zomato · 10mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7380217740675993600/)

## Post

You're in a Machine Learning Interview at Perplexity, and the interviewer asks: 

"Why do we need rerankers in RAG? Isn't semantic search enough?" 

Here's how you answer:

Don't say: "To get better results" or "To improve accuracy." 

Too vague. 

The real answer is the two-tower bottleneck. 

> Your embedding model creates separate vectors for query and document. 
> No interaction = no understanding of relevance. 

You're ranking without reading.


Here's why pure vector search fails: 

- Your bi-encoder computes similarity as dot(query_vec, doc_vec).
- But "How to prevent heart attacks?" and "Heart attacks kill millions" have high cosine similarity - yet one is a question, the other a statistic. 

Semantic ≠ Relevant.

NOTE - consider subscribing my free newsletter - https://lnkd.in/gCPD6fUz for such content daily, now back to post. 

The retrieval-reranking gap is brutal:

- Retrieval@100 with embeddings: ~85% recall
- Top-10 from those 100: ~60% precision
- After reranking top-100: ~85% precision

You're leaving 25% accuracy on the table by not reranking. That's the difference between a useful system and a broken one.

The fundamental tradeoff everyone misses:

> Bi-encoders (retrieval): Encode once, compare millions. Fast but shallow.
> Cross-encoders (rerankers): Joint encoding of query+doc. Sees full interaction but O(n) inference cost.

This is why you can't rerank your entire corpus. You need both.

Why the two-stage pipeline exists:

Stage 1 (Retrieval): 10M docs → Top 100 (1ms, $0.0001)
Stage 2 (Reranking): 100 docs → Top 10 (50ms, $0.01)

Skip reranking = Fast but wrong
Rerank everything = Accurate but $100/query
Smart pipeline = Best of both


The architectural difference that matters:

- Bi-encoder: encode(query) • encode(doc)
- Cross-encoder: encode([query, SEP, doc])

That [SEP] token changes everything. Now your model sees:

1. Query-document word interactions
2. Actual answer containment
3. Contextual relevance


Why cross-encoders are expensive:

> 100 documents to rerank
> Each needs full forward pass through BERT/similar
> 100 × 512 tokens × 12 layers = 614K token computations
> Can't precompute (query-dependent)
> Must run at query time

This is why rerankers are the last step, not the first.

'So how do you make reranking fast enough for production?' Interviewer leans in. 

This is where you mention:

> Distillation (6-layer vs 12-layer cross-encoders)
> Listwise reranking (batch scoring)
> Hybrid approaches (ColBERT's late interaction)

Speed vs quality tradeoff is everything.


The answer that gets you hired:

- Rerankers solve the two-tower limitation of embeddings
- Cross-encoders see full query-document interaction
- The cost is O(n) inference, so you only rerank top-k candidates
- It's not optional for production RAG—it's the precision multiplier


That's it! 

Drop your questions about rerankers and RAG architecture below.


#chatgpt #rag #ai #ml #machinelearning #interview #job #hiring #datascience #l…

## Links

- https://lnkd.in/gCPD6fUz

