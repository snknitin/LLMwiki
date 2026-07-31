---
title: "Implementing Direct Preference Optimization (DPO"
saved: "April 19, 2025 2:51 PM"
date: "2025-04-19"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7200478041586753536/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7200478041586753536%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7200478041586753536"
notion_tags: "LLM, RL"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, llm, rl]
---

# Implementing Direct Preference Optimization (DPO

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7200478041586753536/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7200478041586753536%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 19, 2025 2:51 PM · tags: LLM, RL

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7200478041586753536/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7200478041586753536%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Implementing Direct Preference Optimization (DPO) is much more convenient than using Reinforcement Learning from Human Feedback (RLHF) with Proximal Policy Optimization (PPO) for tuning preferences in large language models (LLMs). Can the process be simplified further? 
It appears so, according to the new "SimPO: Simple Preference Optimization with a Reference-Free Reward" paper (https://lnkd.in/gt_Eqjrg). 
This approach eliminates the need for a reference model and uses the average log probability of a sequence as the implicit reward.
Based on the Alpaca Eval2 and Arena benchmarks, this SimPO approach outperforms DPO noticeably.
