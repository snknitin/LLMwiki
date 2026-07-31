---
title: "trick that can improve RAG performance by 10%-50%."
saved: "April 19, 2025 3:02 PM"
date: "2025-04-19"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7130570149786492928/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7130570149786492928%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7130570149786492928"
notion_tags: "RAG"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, rag]
---

# trick that can improve RAG performance by 10%-50%.

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7130570149786492928/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7130570149786492928%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 19, 2025 3:02 PM · tags: RAG

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7130570149786492928/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7130570149786492928%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

There’s a neat little trick that can improve RAG performance by 10%-50%.

Background: RAG chatbots are based on semantic search—you turn chunks of text from a knowledge base into embedding vectors (numerical representations). When a user asks a question, it's also converted into an embedding vector. The system then finds text chunks from the knowledge base that are closest to the question’s vector, often using measures like cosine similarity. These close text chunks are used as context to generate an answer.

But there’s a core problem with this approach: there’s a hidden assumption here that text chunks close in embedding space to the question contain the right answer. However, this isn't always true. For example, the question “How old are you?” and the answer “27” might be far apart in embedding space, even though “27” is the correct answer.

To solve this problem, you can improve retrieval by fine-tuning the embeddings. In a nutshell, you create a small dataset where each pair of embeddings (like the embedding for “How old are you?” and “27”) is labeled with 1 if they should be close (i.e., they are a relevant question-answer pair), and -1 if not. This fine-tuning process adjusts the embeddings so that relevant question-answer pairs are closer in the embedding space.

This can improve retrieval performance significantly. 

Interactive example: https://lnkd.in/du--PUMy
OpenAI cookbook: https://lnkd.in/dyV5bWtt
