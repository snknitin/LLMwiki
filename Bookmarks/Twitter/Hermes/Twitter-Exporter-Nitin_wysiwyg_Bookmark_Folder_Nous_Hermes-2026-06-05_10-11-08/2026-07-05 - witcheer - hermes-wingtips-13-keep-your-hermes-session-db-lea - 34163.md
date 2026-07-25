---
title: "Hermes Wingtips #13: keep your Hermes session db lean"
author: "witcheer"
username: "@witcheer"
date: "2026-07-05"
tweet_url: "https://x.com/witcheer/status/2073728726496334163"
tweet_type: "original"
likes: 231
retweets: 13
replies: 18
bookmarks: 227
views: 14607
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# Hermes Wingtips #13: keep your Hermes session db lean

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-07-05 · 👍 231 · 💬 18 · 🔖 227 · 👁 14607

> 🔗 [View tweet on X](https://x.com/witcheer/status/2073728726496334163)

## Tweet Content

Hermes Wingtips #13: keep your Hermes session db lean

your Hermes agent keeps every session in one SQLite db at ~/.hermes/state.db, and we ship auto-prune off by default, so none of your history disappears: it all stays searchable.

we keep it lean: hundreds of sessions sit in about 10-15MB. it only starts to drag up near 384MB and ~1000 sessions. I run Hermes 24/7 on my Mac Mini, so mine is well past that at 924M.

when you push it that hard, one command keeps it snappy: 

hermes sessions prune (it only touches ended sessions, never your active ones). 

and if you want it automatic, set sessions[.]auto_prune: true.

## Media

![](https://pbs.twimg.com/media/HMdcj6DXQAAdq8x.jpg)

