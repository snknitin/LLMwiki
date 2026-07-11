---
title: "if you have a single RTX 3090 and want the best local inference setup right now, here's what i lande..."
author: "Sudo su"
username: "@sudoingX"
date: "2026-03-06"
tweet_url: "https://x.com/sudoingX/status/2029768207377256952"
tweet_type: "original"
likes: 686
retweets: 57
replies: 68
bookmarks: 830
views: 46521
has_media: false
tags: ["twitter-bookmark"]
---

# if you have a single RTX 3090 and want the best local inference setup right now, here's what i lande...

> **Source:** [@sudoingX](https://x.com/sudoingX) · 2026-03-06 · 👍 686 · 💬 68 · 🔖 830 · 👁 46521

> 🔗 [View tweet on X](https://x.com/sudoingX/status/2029768207377256952)

## Tweet Content

if you have a single RTX 3090 and want the best local inference setup right now, here's what i landed on after testing 5 open source models across 7 GPU configs this month.

GPU: 1x RTX 3090 24GB
model: Qwen 3.5 27B Dense Q4_K_M (16.7GB)
context: 262K (native max)
speed: 35 tok/s generation, flat from 4K to 300K+
reasoning: built in chain of thought, survives Q4 quant

config:
llama-server -ngl 99 -c 262144 -fa on --cache-type-k q4_0 --cache-type-v q4_0

what this gives you:

- 27B params all active every token
- no speed degradation as context fills
- full reasoning mode on a consumer GPU
- 7GB VRAM headroom after model load

tested MoE (faster but less depth per token) and dense hermes (same speed, degraded under load). qwen dense hit the sweet spot for single GPU. more architecture comparisons dropping soon.

what's your single GPU setup? curious what configs people are running.

