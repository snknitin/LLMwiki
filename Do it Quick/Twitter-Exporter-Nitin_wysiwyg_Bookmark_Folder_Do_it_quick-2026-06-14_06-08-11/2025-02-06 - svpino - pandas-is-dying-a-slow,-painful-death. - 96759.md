---
title: "Pandas is dying a slow, painful death."
author: "Santiago"
username: "@svpino"
date: "2025-02-06"
tweet_url: "https://x.com/svpino/status/1887558730927296759"
tweet_type: "original"
likes: 2526
retweets: 221
replies: 71
bookmarks: 2965
views: 273751
has_media: false
extraction_quality: full
tags: ["twitter-bookmark"]
---

# Pandas is dying a slow, painful death.

> **Source:** [@svpino](https://x.com/svpino) · 2025-02-06 · 👍 2526 · 💬 71 · 🔖 2965 · 👁 273751

> 🔗 [View tweet on X](https://x.com/svpino/status/1887558730927296759)

## Tweet Content

Pandas is dying a slow, painful death.

It's the world's most popular data library, but it's slow, and many libraries have significantly improved over it.

The problem with many of these alternatives is that nobody wants to learn a new API. Let's face it: people won't migrate their codebase unless they have to.

I heard about FireDucks recently. It's up to 48x faster than Pandas, and you don't have to touch your code.

Well, there are two ways. You can change *one* line of code and get everything else run as-is:

> import fireducks.pandas as pd

You can also run your code *without* changing a single line by using an import hook:

$ python -mfireducks.imhook yourfile[.]py

FireDucks is a multi-threaded, compiler-accelerated library with a fully compatible pandas API.

It's also faster than Polars. Below is a link to some benchmarks that compare Pandas, Polars, and FireDucks. FireDucks wins, hands down.

