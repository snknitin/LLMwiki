---
title: "𝗟𝗮𝘁𝗲 𝗶𝗻𝘁𝗲𝗿𝗮𝗰𝘁𝗶𝗼𝗻 𝗺𝗼𝗱𝗲𝗹𝘀 like ColBERT, ColPali and ColQwen are game changers for..."
author: "Victoria Slocum"
username: "@victorialslocum"
date: "2026-03-04"
tweet_url: "https://x.com/victorialslocum/status/2029222636006326367"
tweet_type: "original"
likes: 229
retweets: 34
replies: 5
bookmarks: 198
views: 10281
has_media: true
tags: ["twitter-bookmark", "llm", "agents"]
---

# 𝗟𝗮𝘁𝗲 𝗶𝗻𝘁𝗲𝗿𝗮𝗰𝘁𝗶𝗼𝗻 𝗺𝗼𝗱𝗲𝗹𝘀 like ColBERT, ColPali and ColQwen are game changers for...

> **Source:** [@victorialslocum](https://x.com/victorialslocum) · 2026-03-04 · 👍 229 · 💬 5 · 🔖 198 · 👁 10281

> 🔗 [View tweet on X](https://x.com/victorialslocum/status/2029222636006326367)

## Tweet Content

𝗟𝗮𝘁𝗲 𝗶𝗻𝘁𝗲𝗿𝗮𝗰𝘁𝗶𝗼𝗻 𝗺𝗼𝗱𝗲𝗹𝘀 like ColBERT, ColPali and ColQwen are game changers for 𝗶𝗻𝗳𝗼𝗿𝗺𝗮𝘁𝗶𝗼𝗻-𝗱𝗲𝗻𝘀𝗲 𝗼𝗿 𝗺𝘂𝗹𝘁𝗶𝗺𝗼𝗱𝗮𝗹 𝗱𝗮𝘁𝗮, especially with PDFs.

Here's how they work:

Dense retrieval models can be categorized by their type of "interaction" - how they compute whether a document matches a search query. There are three main approaches:

 𝗡𝗼-𝗜𝗻𝘁𝗲𝗿𝗮𝗰𝘁𝗶𝗼𝗻: Creates a single embedding per document, compares to query embedding. Less nuance able to be encoded in the embedding means less accuracy with information-dense text. This is most standard embedding models.

 𝗙𝘂𝗹𝗹-𝗜𝗻𝘁𝗲𝗿𝗮𝗰𝘁𝗶𝗼𝗻: Processes query and document together (like cross-encoders). Great for reranking, but doesn't scale - requires a lot of compute power.

 𝗟𝗮𝘁𝗲 𝗜𝗻𝘁𝗲𝗿𝗮𝗰𝘁𝗶𝗼𝗻: Store 𝘁𝗼𝗸𝗲𝗻-𝗹𝗲𝘃𝗲𝗹 multi-vector embeddings instead of a single document embedding, then calculate the maximum similarity score between query tokens and document tokens at a later stage, after precomputing embeddings offline. This means you get the detailed contextual understanding of full-interaction models with the scalability of no-interaction models.

𝗖𝗼𝗹𝗕𝗘𝗥𝗧 pioneered this approach for text retrieval and then 𝗖𝗼𝗹𝗣𝗮𝗹𝗶 and 𝗖𝗼𝗹𝗤𝘄𝗲𝗻 extend late interaction to visual content using Vision Language Models (VLMs).

ColBERT and ColQwen are great for 𝗣𝗗𝗙 𝗽𝗿𝗼𝗰𝗲𝘀𝘀𝗶𝗻𝗴 because they treat entire PDF documents as images, which means you don't have to use OCR or complex chunking strategies.

𝗣𝗗𝗙 𝗽𝗿𝗼𝗰𝗲𝘀𝘀𝗶𝗻𝗴 𝗽𝗶𝗽𝗲𝗹𝗶𝗻𝗲 𝘄𝗶𝘁𝗵 𝗺𝘂𝗹𝘁𝗶𝗺𝗼𝗱𝗮𝗹 𝗺𝗼𝗱𝗲𝗹𝘀:
• Convert the entire PDF to an image
• Process it through a VLM encoder (PaliGemma for ColPali, Qwen2-VL for ColQwen)
• Generate multi-vector embeddings for image patches
• Use late interaction mechanism to match against text queries

This means figures in documents stay contextually placed with the text, and documents are processed similarly to how a human would read them. Great for RAG pipelines over financial documents, legal contracts, research papers - anything with mixed content formats and dense information.
𝗜 𝗷𝘂𝘀𝘁 𝘄𝗿𝗼𝘁𝗲 𝗮 𝗯𝗹𝗼𝗴 𝗽𝗼𝘀𝘁 𝗼𝗻 𝗵𝗼𝘄 𝘁𝗼 𝗯𝘂𝗶𝗹𝗱 𝘁𝗵𝗶𝘀 𝗳𝗼𝗿 𝗹𝗲𝗴𝗮𝗹 𝗱𝗼𝗰𝘂𝗺𝗲𝗻𝘁 𝗥𝗔𝗚: 
https://
weaviate.io/blog/legal-rag
-app?utm_source=channels&utm_medium=vs_social&utm_campaign=agent_skills&utm_content=ee064dca-3522-46aa-9653-8675fc2f27a6
…

Late interaction models require more memory because of those multi-vector embeddings, but strategies like MUVERA compensate for this. The richer contextual understanding and simplified preprocessing pipeline often makes it worth it for information dense text or data where you need multimodal understanding.

![](https://pbs.twimg.com/media/HCk_MRXWgAALIg9?format=jpg&name=small)

## Media

![](https://pbs.twimg.com/media/HCk_MRXWgAALIg9.jpg)

