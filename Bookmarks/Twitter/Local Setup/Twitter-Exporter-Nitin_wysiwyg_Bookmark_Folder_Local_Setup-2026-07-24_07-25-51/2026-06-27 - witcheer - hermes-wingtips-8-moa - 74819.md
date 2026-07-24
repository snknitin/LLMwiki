---
title: "Hermes Wingtips #8: MoA"
author: "witcheer"
username: "@witcheer"
date: "2026-06-27"
tweet_url: "https://x.com/witcheer/status/2070888011508674819"
tweet_type: "original"
likes: 196
retweets: 21
replies: 19
bookmarks: 113
views: 10920
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# Hermes Wingtips #8: MoA

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-06-27 · 👍 196 · 💬 19 · 🔖 113 · 👁 10920

> 🔗 [View tweet on X](https://x.com/witcheer/status/2070888011508674819)

## Tweet Content

Hermes Wingtips #8: MoA

the new Mixture of Agents virtual model fans every turn out to four reference models plus an aggregator. 

I put it on a fresh Hermes box: gpt-5.5, deepseek-v4-pro and sonnet-4.6 as references, opus-4.8 as the aggregator.

measured on the box: 

- a single opus call ran 27.9k tokens for ~$0.14
- the full MoA turn ran 28.6k tokens for ~$0.15, the same within a cent

the system prompt and tool schemas dominate that number, and the references run on stripped context, so the four extra calls stay cheap. 
for one question, you get the whole ensemble for barely more than a single model.

and the quality is the point: Nous's HermesBench puts an opus + gpt-5.5 MoA at 0.8202 vs 0.7607 / 0.7412 for those models alone. 

it is 5 calls a turn, so it scales with task length, which is exactly why Nous frames it for "genuinely difficult problems" and on that ground it's one of the better-value things they've shipped.

## Media

![](https://pbs.twimg.com/media/HL1FipXWAAAvkmQ.jpg)

