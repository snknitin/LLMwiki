---
title: "Netflix foundation model for personalized recommendations"
saved: "April 17, 2025 10:50 PM"
date: "2025-04-17"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7317104261090185216/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7317104261090185216%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7317104261090185216"
notion_tags: "LLM, Recsys"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, llm, recsys]
---

# Netflix foundation model for personalized recommendations

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7317104261090185216/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7317104261090185216%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 17, 2025 10:50 PM · tags: LLM, Recsys

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7317104261090185216/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7317104261090185216%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

In Netflix's recent blog post on their foundation model for personalized recommendations (March 2025) (https://lnkd.in/grBhzECy), they describe an elegant mechanism: the model learns to merge adjacent user actions into higher-level tokens. These composite tokens aren’t predefined—they emerge during training, letting the model abstract over user behavior patterns more effectively.

This reminded me of the great time working with Abdul Fatir Ansari , the Chronos inventor (https://lnkd.in/gnU4qJG8), the open-source foundation model series for time series forecasting. In Chronos v1, input time series are tokenized via discretization—a necessary step for applying language modeling techniques. But in Chronos Bolt, the architecture changes: raw float time series values are directly fed into the model, inspired by ViT-style encoding. This design choice reduces quantization noise.

What's particularly compelling is how both Netflix and Chronos move beyond next-token prediction, producing multiple tokens in parallel. In time series, this allows faster and more coherent long-horizon forecasting. For Netflix’s recommender system, it shifts optimization toward long-term user satisfaction—potentially avoiding short-term engagement traps like clickbait and aligning better with user intent over time.

These parallels suggest a broader trend: sequence models that operate at adaptive granularity and optimize for meaningful long-term patterns.
