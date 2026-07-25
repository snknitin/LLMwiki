---
title: "Hermes Wingtips #16: gateway won't restart after a reboot? enable lingering"
author: "witcheer"
username: "@witcheer"
date: "2026-07-08"
tweet_url: "https://x.com/witcheer/status/2074942527996838105"
tweet_type: "original"
likes: 35
retweets: 1
replies: 1
bookmarks: 22
views: 4355
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# Hermes Wingtips #16: gateway won't restart after a reboot? enable lingering

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-07-08 · 👍 35 · 💬 1 · 🔖 22 · 👁 4355

> 🔗 [View tweet on X](https://x.com/witcheer/status/2074942527996838105)

## Tweet Content

Hermes Wingtips #16: gateway won't restart after a reboot? enable lingering

a user-service gateway runs under your login, so it stops at logout and won't come back after a reboot until you enable lingering.

headless VPS, zero root per restart:

```
hermes gateway install
sudo loginctl enable-linger $USER
```

or go boot-level: `sudo hermes gateway install --system`

## Media

![](https://pbs.twimg.com/media/HMutNlRXEAAmChv.jpg)

