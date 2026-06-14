---
title: "An allreduce has 2N comm volume."
author: "Horace He"
username: "@cHHillee"
date: "2023-10-13"
tweet_url: "https://x.com/cHHillee/status/1712978529867211127"
tweet_type: "reply"
likes: 150
retweets: 4
replies: 5
bookmarks: 100
views: 17417
has_media: false
extraction_quality: full
tags: ["twitter-bookmark"]
---

# An allreduce has 2N comm volume.

> **Source:** [@cHHillee](https://x.com/cHHillee) · 2023-10-13 · 👍 150 · 💬 5 · 🔖 100 · 👁 17417

> 🔗 [View tweet on X](https://x.com/cHHillee/status/1712978529867211127)

## Tweet Content

An allreduce has 2N comm volume.
Reduce-scatter and all-gather both have N comm volume.
Allreduce can be created from a combination of reduce-scatter + all-gather.

DDP: Do allreduce after getting your gradients.
Zero-1: Split allreduce into reduce-scatter + all-gather (allows you to shard optimizer state)
You can now also move your all-gather into the forwards pass of the next iteration.
Zero-3: Note that if you move your all-gather into the forwards pass of the next iteration, then at the beginning of your iteration your weights are actually sharded. However, your peak memory doesn't change, because after you all-gather your weights your weights will be replicated again.

So, in order to keep your peak memory low, you just reshard your weights after using them. However, you need to use your weights again in the backwards pass, so you need another all-gather then.

In total:

DDP: one Allreduce => 2N
Zero-1: one ReduceScatter + one allgather => 2N
Zero-3/FSDP: one reducescatter + 2 allgathers (one in forwards and one in backwards) => 3N

3N/2N = 1.5

