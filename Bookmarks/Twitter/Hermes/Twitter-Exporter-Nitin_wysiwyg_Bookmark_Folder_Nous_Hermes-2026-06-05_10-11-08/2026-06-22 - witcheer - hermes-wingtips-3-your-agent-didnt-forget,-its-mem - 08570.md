---
title: "Hermes Wingtips #3: your agent didn't forget, its memory is a frozen snapshot."
author: "witcheer"
username: "@witcheer"
date: "2026-06-22"
tweet_url: "https://x.com/witcheer/status/2069020659829608570"
tweet_type: "original"
likes: 22
retweets: 0
replies: 8
bookmarks: 6
views: 1346
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# Hermes Wingtips #3: your agent didn't forget, its memory is a frozen snapshot.

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-06-22 · 👍 22 · 💬 8 · 🔖 6 · 👁 1346

> 🔗 [View tweet on X](https://x.com/witcheer/status/2069020659829608570)

## Tweet Content

Hermes Wingtips #3: your agent didn't forget, its memory is a frozen snapshot.

tell it something, it saves to MEMORY.md, the write hits disk right away. 
but the curated memory block in the system prompt loads once at session start and stays fixed for the whole session.

this is on purpose, to keep the prefix cache warm.

so mid-session it can act like it "forgot" what it just saved. 
it didn't: tool calls still read the live on-disk value, only the injected block is frozen. it refreshes next session.

if you need it acting on a fresh memory right now, start a new session. the save already landed, it just shows up next time.

## Media

![](https://pbs.twimg.com/media/HLajUQVW8AA7fmQ.jpg)

