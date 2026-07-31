---
title: "You're in a Machine Learning Interview at OpenAI, and the interviewer sets a trap:"
author: "Hao Hoang"
author_url: "https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y"
headline: "I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents"
date: "2026-02-16"
posted_relative: "5mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7429156074315816961/"
activity_id: "7429156074315816961"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, rag, career, ml]
---

# You're in a Machine Learning Interview at OpenAI, and the interviewer sets a trap:

> **Source:** [Hao Hoang](https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y) · I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents · 5mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7429156074315816961/)

## Post

You're in a Machine Learning Interview at OpenAI, and the interviewer sets a trap:

"Why do we need rerankers in RAG? If our embeddings are state-of-the-art, isn't vector search enough?"

90% of candidates walk right into it.

They say: "To get better results" or "To improve accuracy."

Wrong. That's a outcome, not an engineering reason.

The interviewer is looking for one specific architectural flaw in vector databases.

The candidates continue: "Embeddings capture semantic meaning. If the query and document are semantically similar, the dot product will be high. Therefore, vector search finds the best answers."

This logic fails in production because of 𝐓𝐡𝐞 𝐓𝐰𝐨-𝐓𝐨𝐰𝐞𝐫 𝐁𝐥𝐢𝐧𝐝𝐬𝐩𝐨𝐭.

The reality is that Vector search (Bi-Encoders) compresses the Query and the Document into two separate vectors independently.
1️⃣ Tower A encodes the Query.
2️⃣ Tower B encodes the Document.
3️⃣ They only "meet" at the very end via a simple dot product.

Because they are compressed separately, there is zero interaction between the specific words in the query and the specific words in the document. You are ranking without reading.

This leads to the "Semantic but Irrelevant" problem:
1️⃣ 𝐐𝐮𝐞𝐫𝐲: "How to prevent heart attacks?"
2️⃣ 𝐃𝐨𝐜𝐮𝐦𝐞𝐧𝐭: "Heart attacks kill millions annually."
3️⃣ 𝐑𝐞𝐬𝐮𝐥𝐭: High Cosine Similarity (both are about heart attacks).
4️⃣ 𝐔𝐬𝐞𝐫 𝐄𝐱𝐩𝐞𝐫𝐢𝐞𝐧𝐜𝐞: 0/5 stars. The document is a statistic, not a solution.

-----
𝐓𝐡𝐞 𝐒𝐨𝐥𝐮𝐭𝐢𝐨𝐧: You need a Cross-Encoder to bridge the gap.

Unlike Bi-Encoders, a Cross-Encoder feeds the Query and Document into the transformer together as a single input: [𝘊𝘓𝘚] 𝘘𝘶𝘦𝘳𝘺 [𝘚𝘌𝘗] 𝘋𝘰𝘤𝘶𝘮𝘦𝘯𝘵.

Now, the self-attention mechanism can compare every token in the query against every token in the document. It "reads" the text to understand if the document actually answers the question.
- 𝘉𝘪-𝘌𝘯𝘤𝘰𝘥𝘦𝘳 (𝘙𝘦𝘵𝘳𝘪𝘦𝘷𝘢𝘭): Fast, cheap, but shallow. Good for Recall (finding the top 100 candidates).
- 𝘊𝘳𝘰𝘴𝘴-𝘌𝘯𝘤𝘰𝘥𝘦𝘳 (𝘙𝘦𝘳𝘢𝘯𝘬𝘪𝘯𝘨): Slow, expensive, but deep. Good for Precision (sorting the top 10).

𝐓𝐡𝐞 𝐀𝐧𝐬𝐰𝐞𝐫 𝐓𝐡𝐚𝐭 𝐆𝐞𝐭𝐬 𝐘𝐨𝐮 𝐇𝐢𝐫𝐞𝐝:
"Vector search suffers from the Two-Tower Blindspot, it calculates similarity without context interaction. We use Bi-Encoders to retrieve the top 100 docs for high recall, then a Cross-Encoder to rerank the top 10 for high precision. You can't rerank the whole database because Cross-Encoders are O(N) inference costs, but you can't skip it because Bi-Encoders lack deep understanding."

#MachineLearning #ArtificialIntelligence #DeepLearning #GenerativeAI #LLM #NLP #AIEngineering

