---
title: "DeepSeek V4 Flash 0731 can now be run locally! 🐳"
author: "Unsloth AI"
username: "@UnslothAI"
date: "2026-07-31"
tweet_url: "https://x.com/UnslothAI/status/2083231049434435596"
tweet_type: "quote"
likes: 3342
retweets: 425
replies: 149
bookmarks: 1051
views: 432982
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# DeepSeek V4 Flash 0731 can now be run locally! 🐳

> **Source:** [@UnslothAI](https://x.com/UnslothAI) · 2026-07-31 · 👍 3342 · 💬 149 · 🔖 1051 · 👁 432982

> 🔗 [View tweet on X](https://x.com/UnslothAI/status/2083231049434435596)

## Tweet Content

DeepSeek V4 Flash 0731 can now be run locally! 

Run DeepSeek V4 Flash lossless 4-bit on 168GB RAM and 3-bit on 110GB RAM.

V4 Flash 0731 outperforms V4 Pro. Run via Unsloth or llama.cpp. Smaller quants coming today.

Guide: 
https://
unsloth.ai/docs/models/de
epseek-v4
…
GGUF: 
https://
huggingface.co/unsloth/DeepSe
ek-V4-Flash-0731-GGUF
…

## Media

![](https://pbs.twimg.com/media/HOkfiGraYAAxGnW.jpg)

---

## Commentary from Other Bookmarks

### @sudoingX (Sudo su) — 2026-08-02

> unsloth says you can run deepseek v4 flash 0731 locally. i put the full 284b on a single dgx spark. and i'll be straight with the other spark owners, it did not just work.
> 
> the "3bit fits in 110gb" line has an asterisk. the q3_k_xl and the q3_k_m are both a full 128gb, and both OOM the moment you load them fully on the gpu. the 128gb box only gives you around 121gb of usable vram and the desktop eats into that, i watched it try to grab 127gb and die.
> 
> i had to walk down the quant ladder to iq3_xxs at 104gb before the whole model sat on the gpu with zero offload. that's the one that actually fits. anything bigger either OOMs or forces layers onto the cpu and drags the whole thing to a crawl.
> 
> but it's sitting there now. 284 billion parameters, fully resident on my dgx spark. i'm holding the speed numbers, they deserve their own drop. next is the real battery, decode speed, context scaling, and quality, all run in the open.
> 
> spark owners, the exact quant that fits and the full setup are in the reply below👇

[→ View quote tweet](https://x.com/sudoingX/status/2083704720833847754)

![](https://pbs.twimg.com/media/HOrOZOrbQAArxsa.png)

