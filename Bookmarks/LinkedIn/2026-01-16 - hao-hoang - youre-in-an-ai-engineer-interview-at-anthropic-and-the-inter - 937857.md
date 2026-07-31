---
title: "You're in an AI Engineer interview at Anthropic and the interviewer asks:"
author: "Hao Hoang"
author_url: "https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y"
headline: "I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents"
date: "2026-01-16"
posted_relative: "6mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7417898516594937857/"
activity_id: "7417898516594937857"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, career]
---

# You're in an AI Engineer interview at Anthropic and the interviewer asks:

> **Source:** [Hao Hoang](https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y) · I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents · 6mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7417898516594937857/)

## Post

You're in an AI Engineer interview at Anthropic and the interviewer asks: 

"We're training a new model for the legal and medical domain. What's the production risk of just using a standard, pre-trained Llama 3 tokenizer, and what's your fix?"

Most candidates say: "It's not optimal, but the tokenizer will just use subwords for the OOV (out-of-vocabulary) terms like 'aneurysm'. The model will eventually learn the combinations during fine-tuning."

Wrong. This answer ignores the real production bottleneck: compute cost.

The reality is that tokenization is a 𝐥𝐞𝐚𝐤𝐲 𝐚𝐛𝐬𝐭𝐫𝐚𝐜𝐭𝐢𝐨𝐧.

Using a general tokenizer on a specialized corpus is like trying to write a legal brief using only the 1000 most common English words. It's possible, but painfully inefficient.

Here's the production-level problem:
- Critical domain terms ("glioblastoma," "subpoena," "lis pendens") don't exist in the general-purpose vocabulary.
- The tokenizer will shatter them into tiny, meaningless pieces. 'Glioblastoma' might become 'gl', 'io', 'bl', 'as', 'to', 'ma'.
- This causes sequence length bloat. A 500-word medical abstract that should be 700 tokens suddenly becomes 2800 tokens.

And this is where the budget explodes.

The core cost of a Transformer is the attention mechanism: O(n^2) complexity.
Your sequence length (n) just 4x'd. Your compute and memory cost isn't 4x... it's 16x.

You are burning 90% of your multi-million dollar GPU cluster budget just teaching the model to re-assemble basic domain vocabulary, before it can even start learning medical reasoning. You also smash your context window, fitting far less useful information into the model's view.

𝐓𝐡𝐞 𝐚𝐧𝐬𝐰𝐞𝐫 𝐭𝐡𝐚𝐭 𝐠𝐞𝐭𝐬 𝐲𝐨𝐮 𝐡𝐢𝐫𝐞𝐝:

"This is a compute efficiency trap. Re-using the tokenizer is a false economy that will cause massive sequence length bloat. This will skyrocket our O(n^2) attention cost and waste millions in training flops.

The fix is to train a new, domain-specific tokenizer from scratch on our medical and legal corpus. This small, one-time preprocessing cost will create efficient, meaningful tokens and dramatically reduce our overall training budget."

#AI #MLEngineering #LLM #DataScience #MachineLearning #DeepLearning #Tokenization

