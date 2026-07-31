---
title: "ZeRO shards optimizer states, gradients, and parameters to slash memory usage?"
saved: "August 30, 2025 9:25 AM"
date: "2025-08-30"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7357042246489133059/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357042246489133059%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7357042246489133059"
notion_tags: "MLOps"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, mlops]
---

# ZeRO shards optimizer states, gradients, and parameters to slash memory usage?

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7357042246489133059/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357042246489133059%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved August 30, 2025 9:25 AM · tags: MLOps

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7357042246489133059/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357042246489133059%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Wanted to understand how ZeRO shards optimizer states, gradients, and parameters to slash memory usage? 

Using a 4-parameter model, I manually trace the forward/backward passes and optimizer step, showing when communication like reduce-scatter and all-gather occurs and what data is passed between GPUs.

I hope this article helps to build an intuition for how fully sharded data parallelism operates under the hood. This article has been written with the assistance of Google Gemini 2.5 Pro and works off Stanford CS336 lecture 7 on parallelism.

#ZeRO #DeepLearning #LLM #MachineLearning #DataParallelism #PyTorch
