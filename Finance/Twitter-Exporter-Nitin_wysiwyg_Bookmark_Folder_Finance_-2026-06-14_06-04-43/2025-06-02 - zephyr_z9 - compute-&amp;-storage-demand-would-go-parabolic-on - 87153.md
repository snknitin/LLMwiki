---
title: "Compute &amp; storage demand would go parabolic once proper long video generation comes online (15mi..."
author: "Zephyr"
username: "@zephyr_z9"
date: "2025-06-02"
tweet_url: "https://x.com/zephyr_z9/status/1929606952100987153"
tweet_type: "quote"
likes: 3645
retweets: 146
replies: 53
bookmarks: 2354
views: 6813405
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "llm"]
---

# Compute &amp; storage demand would go parabolic once proper long video generation comes online (15mi...

> **Source:** [@zephyr_z9](https://x.com/zephyr_z9) · 2025-06-02 · 👍 3645 · 💬 53 · 🔖 2354 · 👁 6813405

> 🔗 [View tweet on X](https://x.com/zephyr_z9/status/1929606952100987153)

## Tweet Content

Compute & storage demand would go parabolic once proper long video generation comes online (15min-1hr)
Lots of good memory (SSD & HDD) stocks can be picked up rn  
https://
x.com/ResearchQf/sta
/ResearchQf/status/1927110437964820725
…

## Media

![](https://pbs.twimg.com/media/GsdWEUobIAATCfA.png)

---

## Commentary from Other Bookmarks

### @zephyr_z9 (Zephyr) — 2026-01-22

> 1150%
> Did u listen to me, anon??

[→ View quote tweet](https://x.com/zephyr_z9/status/2014128360159346814)

![](https://pbs.twimg.com/media/G_Oe6p5aYAALuiC.png)

### @bubbleboi (bubble boi) — 2026-01-07

> Bought Sandisk around this time and never sold and I am still not selling anytime soon. My thesis has always been the same… 
> 
> In modern LLM’s storing & referencing KV Cache is the largest bottleneck. For models like ChatGPT & Gemini it has got so big that you can’t fit it on a single node  NVL72 node you need multiple nodes with networking in between. KV Cache also scales linearly with model size & context so the chase for larger and larger MoE models makes this a behemoth. 
> 
> So where do you store the KV Cache? To answer this we need to understand the basics of computer engineering. There are a few ways you can tackle it, you could add more HBM memory to hold it, scale to more servers and use networking to share it between them, or keep it on “disk” which is muuuuch slower than HBM or even DDR memory. 
> 
> So for the longest we just decided to scale out to more servers and this makes sense at first if you remove yourself from the inference mindset. If you are doing training or sharing hardware among researchers this is actually a more ideal setup no big KV Cache to carry around training small experiments and focusing on bandwidth over latency… 
> 
> But inference is a latency game. Adding network hops and switches in between to read memory adds latency and all the networking hardware Nvidia makes is optimized for bandwidth not latency. So when you are serving models the literal physical location of a specific part of your cache ends up dramatically increasing your tail latency. If you think LLM serving was going to keep growing this was not going to be a sustainable solution and could leave the door open for a competitor to come up with an inference only server solution which I’m sure big labs and big tech were researching.  
> 
> So you might think just add more HBM? Adding more HBM increases your costs lowers your yield and negligibly improves your memory bandwidth compared to just increasing the pin speed which gives way more bang for buck. Even if you did stack a terabyte of HBM on a GPU the bandwidth won’t scale to make it usable and having more HBM will increase the time you need to refresh it to stop data corruption which will increase latency. 
> 
> So with these constraint on HBM & Networking killing inference latency what do you do? Contrary to what you would get taught in your EECS class you move up the hierarchy to “disk” and the fastest memory there is flash. Instead of having more and more nodes of GPUs with expensive networking equipment you can just do the brain dead simple thing and pack a bunch of flash on each node. Flash access latency is still lower than networking and if you DMA into your GPU ‘s memory cleverly you can hide that latency by overlapping writing to HBM from disk with consuming it in logic. The simple dumb easy solution wins you just gotta write better hardware drivers lmao. 
> 
> This is why Sandisk & Western Digital were always going to win but Sandisk was a more pure play flash company so their top line exploded even more. I don’t think the prevalence of flash in AI is fully appreciated yet either. As I said longer context lengths & larger models = larger KV cache =  more flash. Additionally with video models you need even longer context windows + fast access to video’s you generated for users + videos for training. 
> 
> The dance between HBM, Networking, & Flash will most likely lean towards flash every-time just cause of scale & cost. I fully expect Sandisk to be worth $150B by the end of this year b/c of this.

[→ View quote tweet](https://x.com/bubbleboi/status/2008695723626238056)

