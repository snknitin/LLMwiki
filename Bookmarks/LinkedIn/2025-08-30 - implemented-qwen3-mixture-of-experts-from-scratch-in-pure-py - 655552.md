---
title: "implemented Qwen3 Mixture-of-Experts from Scratch in pure PyTorch"
saved: "August 30, 2025 9:54 AM"
date: "2025-08-30"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7357401606549655552/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357401606549655552%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7357401606549655552"
notion_tags: "LLM, Usage"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, llm, usage]
---

# implemented Qwen3 Mixture-of-Experts from Scratch in pure PyTorch

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7357401606549655552/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357401606549655552%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved August 30, 2025 9:54 AM · tags: LLM, Usage

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7357401606549655552/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357401606549655552%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

I (finally) implemented Qwen3 Mixture-of-Experts from Scratch in pure PyTorch
The Qwen3 model suite recently added new open-weight models (Instruct, Thinking, and Coder), and I couldn't resist...

As I mentioned a few weeks ago, I've been using the older (and smaller) Qwen3 dense models as a starting point for experimentation and research due to their really good performance. 

After last week's release, I finally sat down and coded the MoE variants as well.
The purpose of this re-implementation is to have human-readable code to better understand the internals and make it easier to adapt or modify for downstream tasks.

If you are curious, you can check out the notebook here: https://lnkd.in/g_zb6K26

tldr:
- Qwen3 Coder Flash (30B-A3B) architecture
- MoE setup with 128 experts, 8 active per token
- Pure PyTorch in a standalone Jupyter notebook
- Roughly 60 GB memory requirement (runs on a single A100 or newer)
  
Happy tinkering!
