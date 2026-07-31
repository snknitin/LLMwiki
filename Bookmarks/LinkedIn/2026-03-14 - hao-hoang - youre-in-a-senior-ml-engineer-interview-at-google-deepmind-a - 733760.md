---
title: "You're in a Senior ML Engineer interview at Google DeepMind and the interviewer asks:"
author: "Hao Hoang"
author_url: "https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y"
headline: "I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents"
date: "2026-03-14"
posted_relative: "4mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7438545644031733760/"
activity_id: "7438545644031733760"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, career, ml]
---

# You're in a Senior ML Engineer interview at Google DeepMind and the interviewer asks:

> **Source:** [Hao Hoang](https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y) · I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents · 4mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7438545644031733760/)

## Post

You're in a Senior ML Engineer interview at Google DeepMind and the interviewer asks:

"You have 100 million production samples for a high-dimensional classification task. Why is opting for a 𝘎𝘦𝘯𝘦𝘳𝘢𝘵𝘪𝘷𝘦 𝘔𝘰𝘥𝘦𝘭 𝘸𝘪𝘵𝘩 𝘢 𝘴𝘵𝘳𝘰𝘯𝘨 𝘎𝘢𝘶𝘴𝘴𝘪𝘢𝘯 𝘱𝘳𝘪𝘰𝘳, like GDA, actually a liability compared to a low-assumption Deep Learning model?"

Don't say: "GDA is better because it models the joint distribution P(X,Y) and is more mathematically complete."

That's a textbook answer. In production, 𝘤𝘰𝘮𝘱𝘭𝘦𝘵𝘦𝘯𝘦𝘴𝘴 doesn't win, 𝘧𝘭𝘦𝘹𝘪𝘣𝘪𝘭𝘪𝘵𝘺 does. If they give that answer,they've already lost the role.

When we have 100 million samples, the data is trying to tell you the truth, but your 𝐈𝐧𝐝𝐮𝐜𝐭𝐢𝐯𝐞 𝐁𝐢𝐚𝐬 is shouting over it.

A "strong prior" (like assuming your data is Gaussian) is like trying to fit a gourmet, 12-course meal into a pre-packaged bento box. When you only have a few scraps of data, the box helps keep things organized. But when you have a feast, the box just gets in the way of the food.

Here is why strong assumptions erode at scale:
1️⃣ 𝐓𝐡𝐞 𝐌𝐨𝐝𝐞𝐥 𝐂𝐚𝐩𝐚𝐜𝐢𝐭𝐲 𝐂𝐞𝐢𝐥𝐢𝐧𝐠: Strong priors act as a hard constraint. If your data distribution has "heavy tails" or complex non-linearities (which 100M samples will definitely have), a Gaussian model physically cannot represent them. You've capped your performance before the first epoch.

2️⃣ 𝐀𝐬𝐲𝐦𝐩𝐭𝐨𝐭𝐢𝐜 𝐁𝐢𝐚𝐬: In the "Small Data" regime, assumptions are a lifeline (they prevent overfitting). In the "Big Data" regime, assumptions become Asymptotic Bias. Even with infinite data, a biased model will never converge to the true distribution.

3️⃣ 𝐃𝐢𝐬𝐜𝐫𝐢𝐦𝐢𝐧𝐚𝐭𝐢𝐯𝐞 𝐃𝐨𝐦𝐢𝐧𝐚𝐧𝐜𝐞: At scale, you don't need to model how the data was generated (P(X|Y)). You only care about the 𝐃𝐞𝐜𝐢𝐬𝐢𝐨𝐧 𝐁𝐨𝐮𝐧𝐝𝐚𝐫𝐲. Deep Learning models, with their weak priors, allow the architecture to "learn the features" rather than forcing the features to fit a bell curve.

𝐓𝐡𝐞 𝐚𝐧𝐬𝐰𝐞𝐫 𝐭𝐡𝐚𝐭 𝐠𝐞𝐭𝐬 𝐲𝐨𝐮 𝐡𝐢𝐫𝐞𝐝: In the Small Data regime, we use assumptions to fill in the gaps. In the Big Data regime, we remove assumptions to get out of the data's way. A Senior Engineer knows that Model Capacity must scale with Data Volume. Otherwise, your "strong prior" is just a fancy word for a bottleneck.

#MachineLearning #DeepLearning #BigData #MLOps #AIArchitecture #DataScience #ArtificialIntelligence

