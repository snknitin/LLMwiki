---
title: "THIS GUY AUDITED 926 CLAUDE CODE SESSIONS AND FOUND MOST OF THE TOKEN WASTE WAS ON HIS SIDE"
author: "Om Patel"
username: "@om_patel5"
date: "2026-04-06"
tweet_url: "https://x.com/om_patel5/status/2041040306078912653"
tweet_type: "original"
likes: 1902
retweets: 154
replies: 99
bookmarks: 4435
views: 296570
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude"]
---

# THIS GUY AUDITED 926 CLAUDE CODE SESSIONS AND FOUND MOST OF THE TOKEN WASTE WAS ON HIS SIDE

> **Source:** [@om_patel5](https://x.com/om_patel5) · 2026-04-06 · 👍 1902 · 💬 99 · 🔖 4435 · 👁 296570

> 🔗 [View tweet on X](https://x.com/om_patel5/status/2041040306078912653)

## Tweet Content

THIS GUY AUDITED 926 CLAUDE CODE SESSIONS AND FOUND MOST OF THE TOKEN WASTE WAS ON HIS SIDE

everyone is blaming anthropic for the limits, so he decided to actually look at the data

858 sessions, 18,903 turns, and $1,619 estimated spend across 33 days

here's what he found:

1\ one default setting was burning 14,000 tokens per turn

Claude Code loads the full JSON schema for every tool into context at session start. whether you use them or not. 20,000 tokens of tool definitions sitting there on every single turn.

the fix: one line in your settings.json

"ENABLE_TOOL_SEARCH": "true"

context dropped from 45K to 20K instantly. across 858 sessions that one setting was wasting an estimated 264 million tokens

2\ cache expiry is the single biggest waste

54% of his turns came after a 5+ minute idle gap. 

every one of those turns re-processed the entire conversation at full price which caused a 10x cost jump

you go grab coffee. come back 5 minutes later. type your next message. everything rebuilds from scratch. the context didn't change. you didn't change. the cache just expired.

12.3 million tokens wasted on idle gaps alone

3\ 42 skills loaded. 19 of them used twice or less across 858 sessions.

every one of those skill schemas sat in context on every turn eating tokens for nothing.

4\ 1,122 redundant file reads where the same file was read 3+ times

one session read the same file 33 times.

he ALSO built a full token auditor dashboard that shows you exactly where your waste is coming from

19 charts, opens in your browser, free AND open source

## Media

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2041040187871105024/img/8U29aXc7yl0Sk22m.jpg)

**Video:** [▶ Watch](https://video.twimg.com/amplify_video/2041040187871105024/vid/avc1/1776x1080/69SDKkCx6rOqnato.mp4?tag=21) (duration: 20s)

⚠️ Video content — see [[MEDIA-REVIEW]] for full list.

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @chappyasel (Chappy Asel)

> The real limit was always you

### @JafarNajafov (Jafar Najafov)

> This is actually great. A lot of people don't know about this.

### @traderclawAI (TraderClaw)

> Most of the waste is not from the model, but from how sessions are set up and used. Small settings can have a big impact on cost

