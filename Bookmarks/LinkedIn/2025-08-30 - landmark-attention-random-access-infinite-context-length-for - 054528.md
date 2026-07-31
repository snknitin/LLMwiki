---
title: "Landmark Attention: Random-Access Infinite Context Length for Transformers"
saved: "August 30, 2025 1:01 PM"
date: "2025-08-30"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7154789729996054528/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7154789729996054528%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7154789729996054528"
notion_tags: "Paper"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, paper]
---

# Landmark Attention: Random-Access Infinite Context Length for Transformers

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7154789729996054528/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7154789729996054528%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved August 30, 2025 1:01 PM · tags: Paper

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7154789729996054528/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7154789729996054528%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

🍄 Getting rid of RAG with infinite context length? TLDRs on the "Landmark Attention: Random-Access Infinite Context Length for Transformers" paper.


🌱 Non-technical TLDR
- Sometimes you need LLMs to answer questions about things they don't know, so you provide context, and this context can be long
- LLMs struggle with long texts (> 100k words): they can't remember far enough and the more you feed them the slower and more expensive they get
- Usual tricks either lose the flex to pick any part of the text or need extra stuff outside the LLM, which is meh
- These EPFL guys said, "let's break the text into chunks, use 'landmarks' (special tokens) to remember each chunk"
- Now, the LLM can "think" of the whole text while checking only the landmarks, and grab a chunk if needed
- Results: you can feed it very long inputs, it will remember everything, while not using much memory
- When you read a long text, you don't remember it word for word, you only remember the general idea of each sections, and this general idea is enough to know which section to refer to when answering a specific question about the text, so you go back and re read them just before answering


🔬 Technical TLDR:
- Split the input text in blocks of 50 tokens and append a special "landmark" token after each block
- First calculate an attention with respect to the blocks' landmark tokens, and only keep the blocks whose landmark token got the highest attention
- Then, equally divide the attention weight of the landmark to the tokens in its block to get the final attention weight per token
- In the attention layer, only consider those tokens + the few tokens preceding the current token, to keep in mind the local context
- Each attention head can select different blocks, which is a big difference compared to RAG
- The landmarks tokens act as gating mechanisms, so you don't need the KV cache for all tokens at every step, so you can offload it to CPU, though it makes it slow
- They train a GPT-2 like model from scratch (on english language books and math papers from arxiv) + finetune a llama 7B (on RedPajama)
- The methods rivals Transformer XL (model that uses memory that it recurrently updates), while requiring less FLOPS and being more interpretable as you can directly see the chunks of text used in the generation
- They introduce (do they? it's the first occurence I found of this test) the passkey retrieval task, in which they hide a given phrase in the middle of a long prompt, and ask the model to retrieve it. They get ~90% accuracy with context length going up to 32k

Thanks Amir Keivan Mohtashami & Martin Jaggi!

Links in the comments :)
