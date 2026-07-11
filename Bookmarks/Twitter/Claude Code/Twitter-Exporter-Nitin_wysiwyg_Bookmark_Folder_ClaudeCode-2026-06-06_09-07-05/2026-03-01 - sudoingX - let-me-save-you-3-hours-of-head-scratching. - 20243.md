---
title: "let me save you 3 hours of head scratching."
author: "Sudo su"
username: "@sudoingX"
date: "2026-03-01"
tweet_url: "https://x.com/sudoingX/status/2028140767848620243"
tweet_type: "original"
likes: 612
retweets: 32
replies: 51
bookmarks: 669
views: 72501
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude", "agents"]
---

# let me save you 3 hours of head scratching.

> **Source:** [@sudoingX](https://x.com/sudoingX) · 2026-03-01 · 👍 612 · 💬 51 · 🔖 669 · 👁 72501

> 🔗 [View tweet on X](https://x.com/sudoingX/status/2028140767848620243)

## Tweet Content

let me save you 3 hours of head scratching.

if you're running local models like Qwen3.5-35B-A3B through Claude Code via llama.cpp's Anthropic endpoint, the chain will break every 3 to 5 minutes. tool call fails. flow stops. you reprompt. it recovers. 2 minutes later it stops again. the model is fine. the harness chokes on local inference latency.

switch to OpenCode. same localhost endpoint. same model. same GPU. the chain doesn't break.

the tradeoff: OpenCode sometimes loops. the model forgets what it already read and repeats the same tool call. but a loop you can interrupt. a broken chain kills your momentum and you start over.

watch both side by side. proprietary agent vs open source agent. same 3B model. different failure modes. pick your poison.

## Media

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2028139458806284289/img/sGsfHpjW1T7uoNmr.jpg)

**Video:** [▶ Watch](https://video.twimg.com/amplify_video/2028139458806284289/vid/avc1/948x534/XlV6F-ZFhnUT6vHI.mp4?tag=21) (duration: 35s)

⚠️ Video content — see [[MEDIA-REVIEW]] for full list.

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @Tradesdontlie (Trades Dont Lie)

> cant wait to run some quant ralph loops with qwen 3.5 in a few days

### @coinwitch (coin☆witch)

> i am curious if others have found the best coding experience possible is with this exact model. claude code with a fix? opencode? a vscode extension? cursor?

### @itsmuhdur (muhdur)

> Have you tried 
> http://
> pi.dev?

**Links shared:**
- https://t.co/cgjl6Oh0CO

![](https://pbs.twimg.com/card_img/2060620078266425344/RXatwPKG?format=jpg&name=small)

### @0xRaghuboi (Raghunath Prabhakar)

> kv cache quantization also seems to cause it on opencode, since i switched from 4 bit kv cache to 8 bit haven’t had any issues with looping

### @josecanciani (Jose Canciani ᯅ)

> I used it with VS Code Copilot and it worked great. 
> 
> brew install llama.cpp
> llama-server -hf unsloth/Qwen3.5-35B-A3B-GGUF:UD-IQ2_XXS
> Plus, the Llama.cpp model provider extension, so view it.

### @spark_arena (sparkarena)

> This looks too slow for Qwen3.5-35B-A3B. You can run Qwen/Qwen3.5-35B-A3B-FP8 on a single DGX spark at 100 tokens per second at concurrency 10, that’s just for decoding. For pre-fill the Spark will perform 2-3x better than M4 and the Spark can really scale horizontally which

