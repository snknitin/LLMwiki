---
title: "Hermes Wingtips #10: every fallback entry needs both provider and model"
author: "witcheer"
username: "@witcheer"
date: "2026-07-01"
tweet_url: "https://x.com/witcheer/status/2072321716626366479"
tweet_type: "original"
likes: 70
retweets: 4
replies: 7
bookmarks: 45
views: 5164
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# Hermes Wingtips #10: every fallback entry needs both provider and model

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-07-01 · 👍 70 · 💬 7 · 🔖 45 · 👁 5164

> 🔗 [View tweet on X](https://x.com/witcheer/status/2072321716626366479)

## Tweet Content

Hermes Wingtips #10: every fallback entry needs both provider and model

your fallback_providers list in ~/.hermes/config.yaml counts an entry as a real fallback only when it carries a provider field and a model field. 

two things worth setting:

(1) write provider and model on every entry in the chain, top to bottom.

(2) put a local model last as your floor for a cloud outage, pointing provider: custom at your own llama.cpp or vLLM endpoint.

## Media

![](https://pbs.twimg.com/media/HMJdCrHXEAAdi-k.png)

