---
title: "You're in a Senior ML Interview at NVIDIA. The interviewer sets a trap:"
author: "Hao Hoang"
author_url: "https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y"
headline: "I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents"
date: "2026-01-28"
posted_relative: "6mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7422246248113553408/"
activity_id: "7422246248113553408"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, career, ml]
---

# You're in a Senior ML Interview at NVIDIA. The interviewer sets a trap:

> **Source:** [Hao Hoang](https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y) · I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents · 6mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7422246248113553408/)

## Post

You're in a Senior ML Interview at NVIDIA. The interviewer sets a trap:

"You attach a new, random linear head to a pre-trained Transformer. Do you unfreeze all layers and start backprop immediately?"

90% of candidates walk right into the trap.

Their answer is: "Of course. End-to-end training allows the backbone to adapt to the new task immediately. If we have the compute, why artificially restrict the model by freezing layers?"

It feels efficient. It works in the tutorials.
-----
𝐓𝐡𝐞 𝐑𝐞𝐚𝐥𝐢𝐭𝐲: They aren't accounting for 𝐓𝐡𝐞 𝐆𝐫𝐚𝐝𝐢𝐞𝐧𝐭 𝐒𝐡𝐨𝐜𝐤𝐰𝐚𝐯𝐞.

Their classification head is initialized with random noise. This means their initial loss is high, and their initial gradients are mathematical garbage.

When they backpropagate this "noise" through their perfectly pre-trained backbone, they aren't adapting the features. They are shattering them.

The backbone features (which were already robust) are forced to move aggressively to accommodate a random, untrained head. You destroy the pre-trained structure before the head even learns which way is up.

-----
𝐓𝐡𝐞 𝐒𝐨𝐥𝐮𝐭𝐢𝐨𝐧: You must respect the initialization gap. The fix is executing "𝐋𝐢𝐧𝐞𝐚𝐫 𝐏𝐫𝐨𝐛𝐢𝐧𝐠, 𝐭𝐡𝐞𝐧 𝐅𝐢𝐧𝐞-𝐓𝐮𝐧𝐢𝐧𝐠" 𝐏𝐫𝐨𝐭𝐨𝐜𝐨𝐥

- 𝘗𝘩𝘢𝘴𝘦 1 (𝘛𝘩𝘦 𝘚𝘩𝘪𝘦𝘭𝘥): Freeze the backbone parameters. Train only the new linear head. Since the features are fixed, this is effectively a convex optimization problem. It converges rapidly.
- 𝘗𝘩𝘢𝘴𝘦 2 (𝘛𝘩𝘦 𝘙𝘦𝘧𝘪𝘯𝘦𝘮𝘦𝘯𝘵): Once the head is sensible, unfreeze the backbone.
- 𝘗𝘩𝘢𝘴𝘦 3 (𝘛𝘩𝘦 𝘋𝘳𝘪𝘧𝘵): Lower your learning rate (e.g., from 1e-3 to 1e-5) and fine-tune the full model to adapt the features slightly for the specific task.

𝐓𝐡𝐞 𝐀𝐧𝐬𝐰𝐞𝐫 𝐓𝐡𝐚𝐭 𝐆𝐞𝐭𝐬 𝐘𝐨𝐮 𝐇𝐢𝐫𝐞𝐝: "Never fine-tune a backbone against a random head. We must align the head to the existing feature space before we allow the feature space to shift."

#NLP #MachineLearning #DeepLearning #Transformers #AIEngineering #MLEngineer #Optimization

