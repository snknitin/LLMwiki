---
title: "https://"
author: "Leila Clark"
username: "@leilavclark"
date: "2024-06-25"
tweet_url: "https://x.com/leilavclark/status/1805700631199642094"
tweet_type: "original"
likes: 204
retweets: 35
replies: 2
bookmarks: 204
views: 25817
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# https://

> **Source:** [@leilavclark](https://x.com/leilavclark) · 2024-06-25 · 👍 204 · 💬 2 · 🔖 204 · 👁 25817

> 🔗 [View tweet on X](https://x.com/leilavclark/status/1805700631199642094)

## Tweet Content

https://
imbue.com/research/70b-i
nfrastructure/
â€¦

This is a really great post on what it takes to prepare a datacenter for large-scale ML training. It's rare to see a detailed devops write-up like this in the wild on anything!

Some highlights:
- They had 4,092 H100 GPUs spread across 511 boxes - 8 GPUs per box.

- To train they needed to make sure that all the boxes were set up correctly, and a shocking number of them weren't:

> As is typical in setting up large GPU clusters, we found that about 10% of the machines failed to boot, mostly due to physical issues with the servers. Some issues we encountered included: unconnected or miswired Ethernet cables, hardware issues in iDRAC, broken power supply units, bad NVME (nonvolatile memory express) drives, missing internal wires, and network cards or GPUs failing to show up.

- Some of the issues were just standard computer issues (nowadays we are all spoiled thanks to AWS and never have to deal with this ):

> For instance, during the first few provisions, the clocks were so far off that HTTPS certificate validation issues prevented anything from being installed via apt.
and

> GPU-related errors, which were mostly fixed by reseating the cards in their slots: physically sliding out the 200-pound server from the rack, removing all the cables in between the cover and the GPUs, then taking the GPUs out and putting them in again before replacing all the cables and reracking the server.

-  Setting up InfiniBand was extremely painful:

> However, almost every switch port began reporting excessively high temperatures, sometimes exceeding 70 degrees Celsius, even though they werenâ€™t transmitting data yet. We discovered that the issue stemmed from open spaces between switches in the same networking racks, which caused hot air to recirculate back to the front.

they eventually moved to trying to just find a set of servers that 'worked' and then expanded from there:

> There is a crucial nuance that often gets lost, however: itâ€™s not that every machine has a uniform 3% chance of failing; rather, a small number of malcontent machines repeatedly break in different ways until theyâ€™re properly fixed. This highlighted the advantage of having a large number of machines on the same fabric. Instead of playing whack-a-mole on our large training run with random machines, we could instead focus on growing a set of known reliable, or â€œgolden,â€ machines.

Then they wrote a bunch of health checks (which they've released!): disk space, docker health checks, psb health, etc.

Now that the hardware was ~roughly working as expected, they got to handle the software issues:

> Errors like Forward order differs across ranks: `rank 0 is all-gathering 43 parameters while rank 1228 is all-gathering 1 parameters`. We found that this was a quirk of PyTorch Fully Sharded Data Parallel (FSDP) implementation that could be resolved by a relaunch.

as well as classic oom problems

It ends with a bunch of comments on MFU and what can cause it to drop. There's many things, all of which are fairly common - too much CPU use by other processes, networking issues, etc. My favourite is that, unsurprisingly, they had to confront the ultimate nemesis of the Python programmer: the garbage collector:

> Theoretically, this would be caused by heat accumulation on the switches, but we never saw that. Instead, we used Python and NVIDIA profilers to determine that the degradation seemed to be the result of automatic garbage collection. ...
> We used a synchronous distributed training algorithm, FSDP, which is based on ZeRO-3. During a blocking operation, a single worker process running garbage collection could slow down every other worker. With hundreds of worker processes, this could result in significant slowdowns.

Finally, as they put it:
> Upon completing the above steps, one can achieve good performance when training a modelâ€¦at least until something inevitably breaks.

One interesting takeaway they had was that it's useful to have 10-20% more machines that you need, so it would be easy to relaunch. I can see the merits of this, though it also sounds pretty expensive - that's a lot of extra GPUs to pay for!

Anyway, thanks to the 
@imbue_ai
 team for this writeup - it was super interesting and full of fun war stories.

## Media

![](https://pbs.twimg.com/media/GQ8ij0QbwA8hsaV.jpg)

