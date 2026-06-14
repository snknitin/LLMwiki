---
title: "Took a look at @databricks's new open source 132 billion model called DBRX!"
author: "Daniel Han"
username: "@danielhanchen"
date: "2024-03-27"
tweet_url: "https://x.com/danielhanchen/status/1772981050530316467"
tweet_type: "original"
likes: 970
retweets: 164
replies: 22
bookmarks: 561
views: 107851
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# Took a look at @databricks's new open source 132 billion model called DBRX!

> **Source:** [@danielhanchen](https://x.com/danielhanchen) · 2024-03-27 · 👍 970 · 💬 22 · 🔖 561 · 👁 107851

> 🔗 [View tweet on X](https://x.com/danielhanchen/status/1772981050530316467)

## Tweet Content

Took a look at 
@databricks
's new open source 132 billion model called DBRX!

1) Merged attention QKV clamped betw (-8, 8)
2) Not RMS Layernorm - now has mean removal unlike Llama
3) 4 active experts / 16. Mixtral 2/8 experts.
4) 
@OpenAI
's TikToken tokenizer 100K. Llama splits digits. TikToken allows 1, 2 & 3 digits. Native ChatML format.
5) Cool system prompt!
6) Loss balancing coef 0.05 vs Mixtral 0.02.
7) Has 
@UnslothAI
's correct RoPE upcasting found from our Gemma bug fixes!
8) 12 Trillion tokens! Blog says high quality data most important.
9) I think float8 was used? Can't confirm.
Source: 
https://
github.com/databricks/dbr
x/blob/main/model/modeling_dbrx.py
â€¦

## Media

![](https://pbs.twimg.com/media/GJrhm_jb0AAT3Y0.png)

