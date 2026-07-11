---
title: "A tricky LLM interview question:"
author: "Akshay 🚀"
username: "@akshay_pachaar"
date: "2026-05-07"
tweet_url: "https://x.com/akshay_pachaar/status/2052371239520629243"
tweet_type: "original"
likes: 441
retweets: 52
replies: 31
bookmarks: 614
views: 62336
has_media: false
extraction_quality: full
tags: ["twitter-bookmark", "llm"]
---

# A tricky LLM interview question:

> **Source:** [@akshay_pachaar](https://x.com/akshay_pachaar) · 2026-05-07 · 👍 441 · 💬 31 · 🔖 614 · 👁 62336

> 🔗 [View tweet on X](https://x.com/akshay_pachaar/status/2052371239520629243)

## Tweet Content

A tricky LLM interview question:

Your RAG system scores 90% retrieval accuracy on 5k company docs.

But scaling to 500k docs drops the accuracy to just 50%, with the same embedding model and retriever.

Why did this happen?

The simplest answer is that more documents mean more competition for the top-k retrieval slots. That is true, but it doesn't explain why accuracy drops this dramatically.

The answer comes down to how enterprise docs are distributed in the embedding space.

Today, a single product decision in a company generates meeting transcripts, Slack threads, Confluence docs, Jira tickets, and email threads.

They are related to the same event, so they all land in a similar region of the embedding space.

As the company operates over months, this pattern repeats for every project/customer/roadmap, and the embedding space fills up with clusters of closely related documents.

But all related docs don't contain the same facts.

→ Slack thread covers the decision made
→ Jira has the implementation deadline
→ Confluence has the technical spec
→ Email thread has the customer request

When a query is about a specific fact (like a deadline), the answer lives in one of those docs.

At a 5K corpus size, there might be 3-5 docs touching that topic, and the correct one easily lands in the top-k results.

But at a 500K corpus size, there could be 40-60 total docs, and the one containing the actual answer can easily get pushed out of the top-k by other topically relevant docs, degrading retrieval.

A recent research paper from Onyx documented this.

The researchers used their newly open-sourced EnterpriseRAG-Bench dataset.

It has 500k+ synthetic enterprise documents spread across Slack, Gmail, Jira, GitHub, Confluence, Google Drive, HubSpot, Fireflies, and Linear, with realistic noise like misfiled documents, near-duplicates, and conflicting versions.

They ran the same retrievers at five corpus sizes from 5K to 500K.

→ Vector search accuracy dropped from 90.7% at 5K documents to 50.6% at 500K docs.

→ BM25 degraded more gracefully, from 85.8% to 68.4%.

→ At every scale, higher neighborhood density in the embedding space monotonically correlated with lower recall.

The practical implication here is that retrieval accuracy on a 5k test set tells you almost nothing about production-scale performance.

Always test at a realistic volume to measure the neighborhood density in your embedding space to estimate how much headroom the retriever actually has.

The entire EnterpriseRAG-Bench dataset (500K docs with questions, and the whole evaluation harness) is open-source.

Run your retriever against it at 5K, then at 500K, and see where your own accuracy curve breaks.

I have shared the GitHub repo in the replies.

