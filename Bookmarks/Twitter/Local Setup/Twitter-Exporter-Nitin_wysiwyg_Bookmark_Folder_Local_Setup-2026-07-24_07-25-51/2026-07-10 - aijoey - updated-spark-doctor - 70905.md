---
title: "Updated Spark Doctor"
author: "Joey"
username: "@aijoey"
date: "2026-07-10"
tweet_url: "https://x.com/aijoey/status/2075596394006470905"
tweet_type: "original"
likes: 123
retweets: 9
replies: 8
bookmarks: 171
views: 8545
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# Updated Spark Doctor

> **Source:** [@aijoey](https://x.com/aijoey) · 2026-07-10 · 👍 123 · 💬 8 · 🔖 171 · 👁 8545

> 🔗 [View tweet on X](https://x.com/aijoey/status/2075596394006470905)

## Tweet Content

Updated Spark Doctor

DGX Spark owners keep hitting the same wall:

You `pip install torch`… and it pulls a CUDA 12 wheel onto a CUDA 13 box.
`
http://
libcudart.so.12` fails. GB10 kernels aren’t there. Half a day gone.

Spark Doctor now catches that automatically.

One command:
`spark-doctor scan`

New in this update — it flags:
• cu12 PyTorch on CUDA 13 / GB10
• missing `libcudart`
• SM_121 not in the torch arch list
• nvcc older than the driver

Still covers the original DGX Spark checks: 14 W power cap, unified-memory pressure, thermal risk, Docker runtime, recipe validation.

Read only. No auto fixes. No telemetry. Just: what’s wrong, why, and what to try next.


https://
github.com/joeynyc/spark-
doctor
…

Glad you like it!

Very welcome! I'm going to make the multi spark experience much smoother.

![](https://pbs.twimg.com/media/HM3_3KOXEAAK0tm?format=jpg&name=medium)

## Media

![](https://pbs.twimg.com/media/HM3_3KOXEAAK0tm.jpg)

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @lloyd094 (Christopher Harlan)

> This is super awesome. Thank you!

### @whiskeyhacker (WhiskeyHacker)

> Thank you!
> 
> Going to try it on standalone then push to my two clusters!

