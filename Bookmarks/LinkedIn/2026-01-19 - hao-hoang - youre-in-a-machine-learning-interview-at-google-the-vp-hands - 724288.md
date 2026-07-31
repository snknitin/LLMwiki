---
title: "You're in a Machine Learning interview at Google. The VP hands you a fraud detection model with a 0...."
author: "Hao Hoang"
author_url: "https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y"
headline: "I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents"
date: "2026-01-19"
posted_relative: "6mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7418982602419724288/"
activity_id: "7418982602419724288"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, career, ml]
---

# You're in a Machine Learning interview at Google. The VP hands you a fraud detection model with a 0....

> **Source:** [Hao Hoang](https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y) · I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents · 6mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7418982602419724288/)

## Post

You're in a Machine Learning interview at Google. The VP hands you a fraud detection model with a 0.98 ROC AUC and asks:

"Is this model ready to ship?"

90% of candidates walk right into the trap.

The textbook answer is to look at the score and celebrate. They said:
"0.98 is phenomenal. The curve hugs the top-left corner perfectly. The separation between classes is distinct. Let's deploy."

------
𝐓𝐡𝐞 𝐑𝐞𝐚𝐥𝐢𝐭𝐲: They aren't optimizing for a balanced dataset; they are optimizing for a massive imbalance (e.g., 1 fraud per 100,000 transactions).

The ROC Curve is chemically addicted to 𝐓𝐫𝐮𝐞 𝐍𝐞𝐠𝐚𝐭𝐢𝐯𝐞𝐬.

Because the 𝐅𝐚𝐥𝐬𝐞 𝐏𝐨𝐬𝐢𝐭𝐢𝐯𝐞 𝐑𝐚𝐭𝐞 (𝐅𝐏𝐑) uses the total number of negatives (legitimate transactions) in the denominator, a massive pool of legitimate traffic dilutes your errors.

You can have a model that misses 50% of fraud cases, but because you have 10 million legitimate transactions, the ROC line still looks perfect. It is lying to you.

-----
𝐓𝐡𝐞 𝐒𝐨𝐥𝐮𝐭𝐢𝐨𝐧:
To pass the interview, you need to identify 𝐓𝐡𝐞 𝐌𝐚𝐣𝐨𝐫𝐢𝐭𝐲 𝐌𝐢𝐫𝐚𝐠𝐞.

You must switch metrics immediately to the 𝘗𝘳𝘦𝘤𝘪𝘴𝘪𝘰𝘯-𝘙𝘦𝘤𝘢𝘭𝘭 (𝘗𝘙) 𝘊𝘶𝘳𝘷𝘦.
- ROC includes True Negatives (the massive majority).
- PR Curve ignores True Negatives entirely.

It focuses exclusively on the minority class performance. When you switch the plot, that "perfect" 0.98 ROC often collapses into a jagged, embarrassing 0.12 PR AUC, revealing that your model is mostly hallucinating or missing the actual crime.

𝐓𝐡𝐞 𝐀𝐧𝐬𝐰𝐞𝐫 𝐓𝐡𝐚𝐭 𝐆𝐞𝐭𝐬 𝐘𝐨𝐮 𝐇𝐢𝐫𝐞𝐝:
"ROC scores are optimistic proxies in high-imbalance domains. For fraud or rare disease detection, I ignore 𝘙𝘖𝘊 and optimize for 𝘈𝘳𝘦𝘢 𝘜𝘯𝘥𝘦𝘳 𝘵𝘩𝘦 𝘗𝘳𝘦𝘤𝘪𝘴𝘪𝘰𝘯-𝘙𝘦𝘤𝘢𝘭𝘭 𝘊𝘶𝘳𝘷𝘦 (𝘈𝘜𝘗𝘙𝘊) to ensure we aren't hiding poor recall behind a wall of easy negatives."

#MachineLearning #DeepLearning #MLEngineering #AIEngineering #NeuralNetworks #ModelOptimization

