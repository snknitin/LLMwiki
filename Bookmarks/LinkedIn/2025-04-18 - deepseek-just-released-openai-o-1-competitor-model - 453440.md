---
title: "Deepseek just released OpenAI O-1 competitor model"
saved: "April 18, 2025 4:18 PM"
date: "2025-04-18"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7287168215355453440/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7287168215355453440%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7287168215355453440"
notion_tags: "Paper"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, paper]
---

# Deepseek just released OpenAI O-1 competitor model

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7287168215355453440/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7287168215355453440%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 18, 2025 4:18 PM · tags: Paper

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7287168215355453440/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7287168215355453440%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

RL is all you need! 🍭🧠 Deepseek just released OpenAI O-1 competitor model (DeepSeek-R1 & DeepSeek-R1-Zero) with an MIT license!!

Their Zero model is just base model (DeepSeek-v3-base) + large scale RL without SFT! It achieves amazing reasoning capabilities. Note: RL = GRPO (not PPO).

BUT - they encountered some issues with it:
* poor readability
* language mixing (sounds like some cracked technical talent I knew that was poor at communication but great at problem solving)

DeepSeek-R1 is basically DeepSeek-R1-Zero + multi-stage training

This is how their multi-stage pipeline looks like:
1. Start with thousands of cold-start CoT data to fine-tune the base
2. RL stage similar to Zero
3. new SFT through rejection sampling data + supervised data (writing, self-cognition, etc.) -> ~600k data points
4. RL again - to make the model harmless/helpful, etc.

The length of the response increases during the training as an emergent property. Reflection, exploration of alternatives, and other approaches simply emerge without being programmed for.

Their RL mainly uses 2 rewards:
* accuracy rewards (e.g. unit tests for code can be used to compute accuracy)
* format rewards (gets rewarded if it separates the "thinking" and the "answer" parts by <think> tags, the reward that forces it to use the same language consistently without switching back & forth)

Interesating enough no outcome/process RMs were involved! So their pipeline is really simplified.

They also release 6 dense models (1.5B - 70B range) distilled from DeepSeek-R1 based on Qwen/Llama.

I definitely didn't expect Chinese to be leading in the open-source AI. Big congrats to DeepSeek team!
