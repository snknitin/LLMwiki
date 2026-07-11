---
title: "🚨 NVIDIA just pulled off something crazy: making bounding box detection 10x faster by ripping out t..."
author: "Charly Wargnier"
username: "@DataChaz"
date: "2026-06-01"
tweet_url: "https://x.com/DataChaz/status/2061369635124162762"
tweet_type: "original"
likes: 478
retweets: 61
replies: 28
bookmarks: 660
views: 65972
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "llm"]
---

# 🚨 NVIDIA just pulled off something crazy: making bounding box detection 10x faster by ripping out t...

> **Source:** [@DataChaz](https://x.com/DataChaz) · 2026-06-01 · 👍 478 · 💬 28 · 🔖 660 · 👁 65972

> 🔗 [View tweet on X](https://x.com/DataChaz/status/2061369635124162762)

## Tweet Content

NVIDIA just pulled off something crazy: making bounding box detection 10x faster by ripping out the exact step the entire industry assumed was mandatory â†“

Every VLM grounding model treats boxes like sentences, predicting them token by token. Itâ€™s inherently slow.

Enter LocateAnything (trending #1 on HF, CVPR 2026).

Itâ€™s an advanced 3B vision-language model that finds any object, UI target, or text using natural language by asking a simple question:

Why serialize a box at all?

The four corners are coupled.

It predicts the whole box atomically, in one parallel step.

The impact of parallel decoding:
â†’ 12.7 boxes/sec on a single H100 (10x faster than Qwen3-VL, 2.5Ã— vs Rex-Omni)
â†’ Accuracy goes up, not down (+3.8% F1 on LVIS, big wins at IoU 0.95)
â†’ Dense scenes (300 boxes) hit ~25 BPS while sequential falls off a cliff
â†’ Built-in fallback: reverts to sequential decoding if the output looks wrong
â†’ Trained on 785M boxes / 138M queries across referring, GUI, and OCR tasks

The breakthrough isn't just speed.

Itâ€™s realizing that forcing structured outputs through text-shaped pipes creates artificial bottlenecks.

Boxes were never tokens.

Repo, demo, weights, paper, and other resources in the  â†“

## Media

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2061369584503132161/img/6_u5mGD0aHP1Efxz.jpg)

**Video:** [▶ Watch](https://video.twimg.com/amplify_video/2061369584503132161/vid/avc1/814x720/CKxZAr8bWLWuOZdn.mp4?tag=14) (duration: 16s)

⚠️ Video content — see [[MEDIA-REVIEW]] for full list.

