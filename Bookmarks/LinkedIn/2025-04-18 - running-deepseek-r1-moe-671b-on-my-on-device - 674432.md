---
title: "running DeepSeek R1 MoE 671B on my on device"
saved: "April 18, 2025 4:21 PM"
date: "2025-04-18"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7290291485990674432/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7290291485990674432%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7290291485990674432"
notion_tags: "LLM, Usage"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, llm, usage]
---

# running DeepSeek R1 MoE 671B on my on device

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7290291485990674432/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7290291485990674432%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 18, 2025 4:21 PM · tags: LLM, Usage

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7290291485990674432/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7290291485990674432%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

I’m running DeepSeek R1 MoE 671B on my on device AI backend for all my apps at ~70% of its resources. This is Unsloth’s R1 dynamic quantization GGUF at 2.51-bit (3.5/2.5bit). I’ve also experimented with the 1.58-bit, which performs OKish but lacks the full potential.

I’m using llama.cpp and offloading half of the MoE layers onto the GPU VRAM, while simultaneously allocating the rest into 69% of the Linux RAM. This leaves 1/3 of the resources available for the rest of my desktop applications and the rest of the on-device AI platform, including the in-memory cache, ZFS cache, 2 DSPy processes, vector DB, 1 safety SLM, and 1 coding LLM.

Over the weekend, I plan to explore different profiles to determine the optimal configuration for utilizing the full MoE locally as my primary workhorse. 

Make sure you own your AI. AI in the cloud is not aligned with you; it’s aligned with the company that owns it.
