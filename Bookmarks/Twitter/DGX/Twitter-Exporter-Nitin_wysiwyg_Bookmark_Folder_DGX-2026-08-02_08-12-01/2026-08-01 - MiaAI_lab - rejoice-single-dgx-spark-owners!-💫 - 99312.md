---
title: "Rejoice single DGX Spark owners! 💫"
author: "Mia"
username: "@MiaAI_lab"
date: "2026-08-01"
tweet_url: "https://x.com/MiaAI_lab/status/2083645342277599312"
tweet_type: "original"
likes: 409
retweets: 48
replies: 47
bookmarks: 264
views: 21966
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# Rejoice single DGX Spark owners! 💫

> **Source:** [@MiaAI_lab](https://x.com/MiaAI_lab) · 2026-08-01 · 👍 409 · 💬 47 · 🔖 264 · 👁 21966

> 🔗 [View tweet on X](https://x.com/MiaAI_lab/status/2083645342277599312)

## Tweet Content

Rejoice single DGX Spark owners! 

DeepSeek v4 Flash for single DGX Spark BEATS the 2x DGX Spark version on agentic workflows!  

Haven't done full coding tests but for agentic workflows it BEATS the FP8 version running on vLLM running on dual DGX Sparks. I fully expect it to be great at coding too!

However, it's much slower, as expected:

Aggregate tok/s (1-2-4-6-8-12)
26.7 tok/s → 32.9 → 46.5 → 54.1 → 58.5 → 58.5 tok/s

Per-stream progression:
26.7 → 16.5 → 12.1 → 9.5 → 7.7 → 5.2 tok/s

That means up  to 59 tok/s across 12 concurrent sessions.

This is the best model to run on a single DGX Spark! All credits go to 
@bleysg
!

I have published a simple start/stop recipe:

https://
github.com/MiaAI-Lab/Deep
Seek-v4-Flash-One-DGX-Spark
…

I still recommend running DeepSeek v4 Flash on 2x DGX Sparks because the speed difference about 3x.

Additional details below

## Media

![](https://pbs.twimg.com/media/HOqYZJTWkAAs8P0.jpg)

