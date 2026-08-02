---
title: "if you own a single dgx spark and want to run the big moes, here's the one rule that saves you a was..."
author: "Sudo su"
username: "@sudoingX"
date: "2026-07-30"
tweet_url: "https://x.com/sudoingX/status/2082629254731440546"
tweet_type: "original"
likes: 200
retweets: 13
replies: 24
bookmarks: 180
views: 27235
has_media: false
extraction_quality: full
tags: ["twitter-bookmark"]
---

# if you own a single dgx spark and want to run the big moes, here's the one rule that saves you a was...

> **Source:** [@sudoingX](https://x.com/sudoingX) · 2026-07-30 · 👍 200 · 💬 24 · 🔖 180 · 👁 27235

> 🔗 [View tweet on X](https://x.com/sudoingX/status/2082629254731440546)

## Tweet Content

if you own a single dgx spark and want to run the big moes, here's the one rule that saves you a wasted weekend: keep your model weights under about 80 gigs.

that's the balance point. weights are only half the bill, the other half is kv cache, and that's where your context actually lives. stay under 80 and you've got 35 to 45 gigs left to scale context and run a spec decoder. cross it and you're fighting the box for every token.

three moes i've run on mine and exactly where they land:

1. laguna s 2.1 - 67 gigs, a genuine coding beast. ~35 tok/s with its dflash drafter, up to 45 on sustained code, poolside from scratch and it holds context for days. 

http://
huggingface.co/poolside/Lagun
a-S-2.1-NVFP4
…

2. qwen 3.5 122b - 74 gigs, the all-rounder. ~35 tok/s with mtp and it holds that line whether it's writing code or prose, no swings. a few months old and still trading punches with the newest king. 

http://
huggingface.co/unsloth/Qwen3.
5-122B-A10B-NVFP4
…

3. stepfun 3.7 flash - the cautionary one. the q4 crams in at 108 gigs, way over the line, so it runs slow with almost no room to breathe, and the nvfp4 won't load at all, it wedged my box twice trying. this is what living above 80 looks like. 
http://
huggingface.co/stepfun-ai/Ste
p-3.7-Flash-GGUF
…

the two i'd put on your desk tonight are laguna and qwen, both moe, both under the line, both a joy to run. that's the spark's whole personality, feed it a fat moe that only fires a few billion params a token and it flies. stay under 80, keep the context room, and the box never lets you down.

