---
title: "The biggest culprit was the power drain. The machine was working at 630mhz and used to be 2k. After..."
author: "Thanh Pham"
username: "@runsonai"
date: "2026-07-11"
tweet_url: "https://x.com/runsonai/status/2075947964090966144"
tweet_type: "reply"
likes: 24
retweets: 1
replies: 3
bookmarks: 9
views: 2125
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# The biggest culprit was the power drain. The machine was working at 630mhz and used to be 2k. After...

> **Source:** [@runsonai](https://x.com/runsonai) · 2026-07-11 · 👍 24 · 💬 3 · 🔖 9 · 👁 2125

> 🔗 [View tweet on X](https://x.com/runsonai/status/2075947964090966144)

## Tweet Content

Was tweaking my dgx spark overnight. I used to have 100 tok/s and lately noticed it went down to 60 tok/s. Something was off...and figured out why.

The biggest culprit was the power drain. The machine was working at 630mhz and used to be 2k. After I woke up, turned it off, unplugged for a min, and rebooted it. Voila...back at 2k mhz. I've seen this issue before. If your dgx spark is going slow, try the cold drain.

And with a few other tweaks, it beat my previous best benchmarks. Now at 110 tok/s with 103ms ttft. AMAZING. Now I have a custom pi with qwen harness for this model, it's going to be a workhorse for long running tasks. Might opensource it soon.

Interesting, I've only used vllm so not sure if that's the culprit. I created a watchdog that monitors every min now if 3x in a row it's below 1500, I get an alert. Will be curious how often this happens silently.

![](https://pbs.twimg.com/media/HM8-seeXAAArbZU?format=jpg&name=medium)

![](https://pbs.twimg.com/media/HM8_TfeWYAAX-Mg?format=jpg&name=medium)

## Media

![](https://pbs.twimg.com/media/HM8_TfeWYAAX-Mg.jpg)

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @AgentSparko (AgentSparko)

> This happened to me too but only when I started llama.cpp so I stopped using it and moved to vLLM exclusively and and it never happen again until a few days ago when I run Unsloth Studio. I discovered then that Unsloth Studio uses llama.cpp too.

