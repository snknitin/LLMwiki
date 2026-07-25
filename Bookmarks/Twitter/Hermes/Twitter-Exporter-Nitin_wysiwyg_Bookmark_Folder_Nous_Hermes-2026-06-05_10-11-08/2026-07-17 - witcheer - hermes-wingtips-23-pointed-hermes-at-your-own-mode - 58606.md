---
title: "Hermes Wingtips #23: pointed Hermes at your own model and it prints the tool call instead of running..."
author: "witcheer"
username: "@witcheer"
date: "2026-07-17"
tweet_url: "https://x.com/witcheer/status/2078094918740758606"
tweet_type: "original"
likes: 57
retweets: 2
replies: 4
bookmarks: 37
views: 6913
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# Hermes Wingtips #23: pointed Hermes at your own model and it prints the tool call instead of running...

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-07-17 · 👍 57 · 💬 4 · 🔖 37 · 👁 6913

> 🔗 [View tweet on X](https://x.com/witcheer/status/2078094918740758606)

## Tweet Content

Hermes Wingtips #23: pointed Hermes at your own model and it prints the tool call instead of running it?

if the reply comes back as raw json like {"name": "web_search", ...}, your inference server handed the tool call over as text and Hermes never got to run it.

tool calling has to be switched on at the server, and it is off until you set it:

(1) vLLM: add --enable-auto-tool-choice --tool-call-parser hermes

(2) SGLang: add --tool-call-parser qwen (or your model's parser)

(3) llama.cpp: add --jinja

![](https://pbs.twimg.com/media/HNbgUCIWwAAC3lT?format=jpg&name=medium)

## Media

![](https://pbs.twimg.com/media/HNbgUCIWwAAC3lT.jpg)

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @Systeo16 (Sam)

> Ran into this exact shape deploying Hermes. It's a provider bridging problem, not an agent bug  your inference server passes the tool schema as chat text instead of routing it as a structured function call. Quick tell: if you see the JSON in the reply, your provider isn't

### @rishflips (Rish)

> Useful tip - tool schema in the reply text almost always means the inference layer isn't doing structured tool calls.
> Curious how often people hit this on llama.cpp vs vLLM in your replies.

### @shesaidmewakeup (Shesaidmewakeup)

> Wow, that's really helpful - I'll have to bookmark this.

### @unchosen_one (unchosen.eth)

> that explains a lot actually

### @NousResearch (Nous Research)

> You're not gonna believe this
> 
> 
> http://
> shop.nousresearch.com/products/nous-
> girl-neon
> …

**Links shared:**
- https://t.co/3KCfbE9SbW

