---
title: "watching a 27b local model write its own benchmark report just now and i'm sitting with this for a s..."
author: "Sudo su"
username: "@sudoingX"
date: "2026-05-06"
tweet_url: "https://x.com/sudoingX/status/2052051592770469894"
tweet_type: "quote"
likes: 139
retweets: 8
replies: 9
bookmarks: 65
views: 29950
has_media: true
tags: ["twitter-bookmark", "agents"]
---

# watching a 27b local model write its own benchmark report just now and i'm sitting with this for a s...

> **Source:** [@sudoingX](https://x.com/sudoingX) · 2026-05-06 · 👍 139 · 💬 9 · 🔖 65 · 👁 29950

> 🔗 [View tweet on X](https://x.com/sudoingX/status/2052051592770469894)

## Tweet Content

watching a 27b local model write its own benchmark report just now and i'm sitting with this for a sec.

gave carnice-v2 27b (kaios SFT on qwen 3.6 dense, trained on hermes agent traces) a self-report card task, find your hardware, find your model file, find the llama.cpp commit you're running on, run a self-benchmark via curl, write a markdown report, verify it, tell me the path.

it called 19 tool in 12 minutes across 42 messages, 11 terminal calls for hardware and git probing, 6 todo updates as it worked through the plan, plus one write_file for the report and one read_file to verify it, no hand holding.

the verify step is what i can't get over, carnice wrote the file then read it back THEN said done, plan execute and VERIFY, that loop actually closing is the rare bird.

running on a 5090 mobile, 21 gb vram peak at 99% gpu, 16.71 tok/s on the singleprompt streaming bench, llama.cpp commit 75f3bc94e from apr 13 (vulkan flash attention dp4a shader), 262k context, fa on, kv cache q4_0/q4_0.

zero hallucinated tools either, the prompt listed bash and python_run from my v0.1 spec but hermes actually ships terminal and execute_code, carnice adapted to the real registry without inventing anything.

this is run 1 of my new personal tool-use benchmark, consumer hardware, harness-agnostic methodology, visible traces. vanilla qwen 3.6 head to head next, video QT after, see for yourself.

## Media

![](https://pbs.twimg.com/media/HHpZ390bgAAgeNm.jpg)

![](https://pbs.twimg.com/media/HHpaAJnbwAAzw65.png)

![](https://pbs.twimg.com/media/HHpZ67Pb0AAnIJa.jpg)

![](https://pbs.twimg.com/media/HHpZ9gPboAA1amN.png)

---

## Commentary from Other Bookmarks

### @sudoingX (Sudo su) — 2026-05-06

> the full 12-minute run sped to 80 seconds, watch carnice v2 cycle through plan, terminal probe, todo update, write the report, then read it back to verify, until the loop closes. no edit cuts, no narration, just the model working at 5x time.
> 
> the rare-bird verify moment lands in the last 20 seconds, write_file then read_file then done. closed loop on consumer hardware, you can watch it happen.

[→ View quote tweet](https://x.com/sudoingX/status/2052056149525213520)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

