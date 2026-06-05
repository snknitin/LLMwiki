---
title: "Today I’m doing some testing with the RTX 3070 Ti. Let’s see what we can fit in 8GB VRAM, I’ll split..."
author: "left curve dev"
username: "@leftcurvedev_"
date: "2026-05-08"
tweet_url: "https://x.com/leftcurvedev_/status/2052702607420830193"
tweet_type: "quote"
likes: 79
retweets: 10
replies: 10
bookmarks: 61
views: 153030
has_media: false
tags: ["twitter-bookmark"]
---

# Today I’m doing some testing with the RTX 3070 Ti. Let’s see what we can fit in 8GB VRAM, I’ll split...

> **Source:** [@leftcurvedev_](https://x.com/leftcurvedev_) · 2026-05-08 · 👍 79 · 💬 10 · 🔖 61 · 👁 153030

> 🔗 [View tweet on X](https://x.com/leftcurvedev_/status/2052702607420830193)

## Tweet Content

Today I’m doing some testing with the RTX 3070 Ti. Let’s see what we can fit in 8GB VRAM, I’ll split this into two parts:

1) Finding the sweet spot for the -ncmoe parameter for maximum speed on base llama.cpp

2) Trying Turboquant, DFlash and MTP integrations to either fit more context or achieve higher tok/s

I’ll share the full flags and setups as always

---

## Commentary from Other Bookmarks

### @leftcurvedev_ (left curve dev) — 2026-05-08

> Anyone with 8GB or 12GB VRAM setups needs to understand that "-ncmoe" is the key flag to boost performance on llama.cpp
> 
> Here are my results for Qwen3.6 35B A3B, with 64k q8_0 context on a 8GB RTX 3070Ti:
> 
> ⚪️ no flag → 8.7 tok/s
> RAM: 13.6GB & VRAM: 7.8GB
> 
> 🔴 -ncmoe 35 → 27.5 tok/s
> RAM: 12.1GB & VRAM: 4.3GB
> 
> 🟢 -ncmoe 30 → 32.5 tok/s
> RAM: 12GB & VRAM: 5.6GB
> 
> 🔵 -ncmoe 25 → 40.9 tok/s
> RAM: 12GB & VRAM: 6.9GB
> 
> Please note the ram and vram usage you see are total usage of a windows pc, with the model running. My friend's setup: 8GB VRAM and 16GB RAM. You can boost performance by switching to Linux, just something to keep in mind.
> 
> Basically, this flag keeps the MoE experts in the first X layers on your CPU + RAM, instead of eating all your VRAM straight away. This is a smart hybrid offload way that lets you run bigger models without OOM while keeping the rest on your GPU for speed.
> 
> As we can see on the data, there's a sweet spot. When we lower it from 35 to 25, speed bumps +50% because there are more layers on your GPU (look at the VRAM usage). The key here is to play around with the number and fit as much as possible on your VRAM, goal is to have 1GB/800MB headroom to avoid stress.
> 
> ↓ server flags below

[→ View quote tweet](https://x.com/leftcurvedev_/status/2052812387955151062)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

