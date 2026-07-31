---
title: "Context Engineering for AI Agents"
saved: "August 30, 2025 9:56 AM"
date: "2025-08-30"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7357220557861371906/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357220557861371906%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7357220557861371906"
notion_tags: "Context, Prompt"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, context, prompt]
---

# Context Engineering for AI Agents

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7357220557861371906/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357220557861371906%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved August 30, 2025 9:56 AM · tags: Context, Prompt

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7357220557861371906/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7357220557861371906%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Context Engineering for AI Agents – this is by far the best blog I've read on actually building agents!🔥It argues that Context Engineering >> Fine-tuning for AI agents.

"Context engineering ... allows us to ship improvements in hours instead of weeks, and kept our product orthogonal to the underlying models: If model progress is the rising tide, we want Manus to be the boat, not the pillar stuck to the seabed."

Key take-aways:
– Optimize for KV-cache hits: by keep as big a static part of the prompt as possible.
– Manage the space of tool calls using response prefill: You can force the model to call or not call tools to improve reliability.
– Use file system as persistent memory: read in files when needed, store the file name.
– Recite goals to manipulate attention: don't leave the main goal at the start of the context - get the LLM to repeat it often.
– Leave failures in the call trace: failed tool calls are evidence the models uses to adapt.
– Don't give uniform few-shot examples, diversify: the same examples in the context make the model mimic that behavior making it brittle.
