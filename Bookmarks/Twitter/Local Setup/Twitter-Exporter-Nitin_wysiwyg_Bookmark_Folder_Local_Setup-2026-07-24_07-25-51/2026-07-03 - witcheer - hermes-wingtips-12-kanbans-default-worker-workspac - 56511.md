---
title: "Hermes Wingtips #12: kanban's default worker workspace is scratch"
author: "witcheer"
username: "@witcheer"
date: "2026-07-03"
tweet_url: "https://x.com/witcheer/status/2073051003482456511"
tweet_type: "original"
likes: 59
retweets: 3
replies: 6
bookmarks: 39
views: 3599
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# Hermes Wingtips #12: kanban's default worker workspace is scratch

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-07-03 · 👍 59 · 💬 6 · 🔖 39 · 👁 3599

> 🔗 [View tweet on X](https://x.com/witcheer/status/2073051003482456511)

## Tweet Content

Hermes Wingtips #12: kanban's default worker workspace is scratch

you're handing a kanban task to a Hermes agent and want to keep the files it writes? one thing to know before you run it.

by default each kanban worker runs in a scratch workspace, and Hermes clears that workspace the moment the task completes. indeed, throwaway chores should not leave directories behind.

to keep the output, give the task its own workspace when you create it:

```
hermes kanban create "your task" --workspace dir:/absolute/path
```

two things to get right:

(1) name the workspace with dir: for anything you want to survive the run. no flag means scratch, cleared on completion.

(2) make the path absolute. Hermes accepts a relative path at create with no error, then rejects it when the worker spawns.

## Media

![](https://pbs.twimg.com/media/HMTyUjOWoAAzu6Z.jpg)

