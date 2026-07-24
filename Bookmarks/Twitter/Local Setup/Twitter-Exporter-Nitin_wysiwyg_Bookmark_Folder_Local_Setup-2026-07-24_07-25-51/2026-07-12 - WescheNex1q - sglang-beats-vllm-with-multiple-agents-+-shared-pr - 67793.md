---
title: "SGLang beats vLLM with multiple agents + shared-prefix cache ON."
author: "Wësche"
username: "@WescheNex1q"
date: "2026-07-12"
tweet_url: "https://x.com/WescheNex1q/status/2076351421083967793"
tweet_type: "original"
likes: 46
retweets: 5
replies: 7
bookmarks: 20
views: 2705
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# SGLang beats vLLM with multiple agents + shared-prefix cache ON.

> **Source:** [@WescheNex1q](https://x.com/WescheNex1q) · 2026-07-12 · 👍 46 · 💬 7 · 🔖 20 · 👁 2705

> 🔗 [View tweet on X](https://x.com/WescheNex1q/status/2076351421083967793)

## Tweet Content

SGLang beats vLLM with multiple agents + shared-prefix cache ON.

~25–45% more aggregate throughput and ~3× faster first token in our runs.

1× DGX Spark · Qwen3.6-35B:

Kv 64k ×32: 324 vs 262 tok/s
256k ×8: 134 vs 93

Shared-context agents are SGLang’s home turf 

Full runs: 
http://
github.com/Weschera/qwen-
sglang-dgx-spark
…

The catch: 
Prefix caching only matches identical prompt beginnings, token for token. “Similar” doesn’t count.
So structure your agents’ prompts shared-first, unique-last: system prompt + tools + docs at the top, the per-agent task at the bottom. 

That ordering alone is the

Example: 
Desk of 32 agents at 64k each, watching 24/7 on one Spark.

Start every prompt the same: rules, tools, playbook, market snapshot (~60k shared).
End each one unique: “you’re agent 7, your beat is semis, scan every 5 min” (~200 tokens).

The shared part gets read once and

@BrianDEvans
 this is what I was telling your earlier

A few days ago update v0.5.15 enabled qwen support, so this was impossible a week ago

## Media

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2076351359234805760/img/DALd6bP9H8teHDgl.jpg)

**Video:** [▶ Watch](https://video.twimg.com/amplify_video/2076351359234805760/vid/avc1/1024x1536/3_UwbZkKJcewWRVM.mp4?tag=28) (duration: 7s)

⚠️ Video content — see [[MEDIA-REVIEW]] for full list.

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @MiaAI_lab (Mia)

> Great job! Looks interesting enough to take sglang seriously

### @sgl_project (SGLang)

> This made our day. Thanks for running these and sharing the full setup!

