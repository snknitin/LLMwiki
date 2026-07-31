---
title: "You're in a Computer Vision Engineer interview at Meta and the interviewer drops this on you:"
author: "Hao Hoang"
author_url: "https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y"
headline: "I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents"
date: "2026-01-11"
posted_relative: "7mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7416086404272791552/"
activity_id: "7416086404272791552"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, career]
---

# You're in a Computer Vision Engineer interview at Meta and the interviewer drops this on you:

> **Source:** [Hao Hoang](https://www.linkedin.com/in/ACoAAC57HBIBaE6MAWK8KhWGU9U6G2MVTyczD9Y) · I share daily insights on AI agents, LLMs, Data Science, Machine Learning | I help AI engineers crack top-tier interviews | 68K+ community | LLM System Design, RAG, Agents · 7mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7416086404272791552/)

## Post

You're in a Computer Vision Engineer interview at Meta and the interviewer drops this on you:

"We're debating between 𝘌𝘢𝘳𝘭𝘺 𝘍𝘶𝘴𝘪𝘰𝘯 and 𝘚𝘭𝘰𝘸 𝘍𝘶𝘴𝘪𝘰𝘯 for our new video understanding model. Everyone knows 𝘚𝘭𝘰𝘸 𝘍𝘶𝘴𝘪𝘰𝘯 captures motion better, but what is the specific computational consequence of maintaining that temporal dimension through multiple layers that kills our training budget?"

Don't say: "𝘚𝘭𝘰𝘸 𝘍𝘶𝘴𝘪𝘰𝘯 is slower because 3D convolutions are just more complex than 2D convolutions."

Technically true, but it misses the actual bottleneck.

The real killer isn't just the operation complexity, it's the feature map volume explosion.

When you do 𝘌𝘢𝘳𝘭𝘺 𝘍𝘶𝘴𝘪𝘰𝘯, you collapse the temporal dimension (T) immediately in the first layer. You’re essentially turning a video into an image instantly. Your subsequent feature maps are just H x W x C.

In 𝘚𝘭𝘰𝘸 𝘍𝘶𝘴𝘪𝘰𝘯, you are maintaining that T dimension deep into the network.
1️⃣ 𝐓𝐡𝐞 𝐌𝐞𝐦𝐨𝐫𝐲 𝐓𝐫𝐚𝐩: You aren't just storing weights; you are storing activations for every single time step across multiple layers.

2️⃣ 𝐓𝐡𝐞 𝐁𝐚𝐧𝐝𝐰𝐢𝐝𝐭𝐡 𝐛𝐨𝐭𝐭𝐥𝐞𝐧𝐞𝐜𝐤: Your GPU memory fills up with intermediate activations, forcing you to drastically reduce batch size.

3️⃣ 𝐓𝐡𝐞 𝐑𝐞𝐬𝐮𝐥𝐭: You might get better accuracy, but your throughput tanks because you're moving massive 4D tensors (T x H x W x C) through memory instead of compact 3D ones.

It's like trying to photocopy a book by photocopying every single page individually versus just photocopying the summary on the back cover. One is 100x more data to manage.

𝐓𝐡𝐞 𝐀𝐧𝐬𝐰𝐞𝐫 𝐓𝐡𝐚𝐭 𝐆𝐞𝐭𝐬 𝐘𝐨𝐮 𝐇𝐢𝐫𝐞𝐝:

"The bottleneck is the activation memory footprint. By maintaining temporal resolution through intermediate layers, we increase the volume of stored activations by a factor of T, which forces smaller batch sizes and destroys parallelization efficiency on the GPU."

#ComputerVision #DeepLearning #MachineLearning #VideoUnderstanding #AIInterviews #GPUOptimization #TechCareers

