---
title: "i didn't expect the american open weight comeback to actually deliver the thing builders kept asking..."
author: "Sudo su"
username: "@sudoingX"
date: "2026-07-22"
tweet_url: "https://x.com/sudoingX/status/2079925715546599499"
tweet_type: "quote"
likes: 72
retweets: 6
replies: 10
bookmarks: 23
views: 23203
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# i didn't expect the american open weight comeback to actually deliver the thing builders kept asking...

> **Source:** [@sudoingX](https://x.com/sudoingX) · 2026-07-22 · 👍 72 · 💬 10 · 🔖 23 · 👁 23203

> 🔗 [View tweet on X](https://x.com/sudoingX/status/2079925715546599499)

## Tweet Content

i didn't expect the american open weight comeback to actually deliver the thing builders kept asking for. 

for a year now "open weights" has meant chinese labs, full stop, while the american side went quiet, and every time the west did drop something "open" it was late, or a toy, or it needed a rack of h100s to breathe.

builders kept asking for one boring thing the whole time: an open model actually good enough to matter, that i can run myself. on hardware i own.

poolside's laguna s 2.1 is the first american drop that just answers it, and i didn't take the launch chart's word for it, i put the whole thing on one dgx spark and measured every number.

it's a 118b mixture of experts, 8.5b active per token, open weights under a real license, and agentic coding is the entire point of it. i served it on vllm with the nvfp4 build and the dflash drafter, and the part nobody publishes is what it actually does on your own metal.

it fits. 67 gigs of weights on ram, and because only 12 of its 48 layers run full attention, the entire million token context is about 26 gigs of kv, so the full window lands near 100 of 128 gigs with room to spare. a frontier coding model, its whole context, on one box that sits next to a monitor.

speed is honest anon. single stream it's modest, about 19 tokens a second, this box was never a sprinter. but the dflash drafter climbs it to 25-30 on normal chat and 45 sustained on code, the workload it's built for, and under load it does 140 tokens a second across 16 streams, because the spark was always a serving box, not a single-stream drag race. it even holds at depth, barely fading from 19 to 14 out at 230k of context while free memory never moves.

that's the comeback that actually matters. not a press release, not a leaderboard screenshot, an open model that shows up with what people kept asking for and holds up when you measure it

but still america didn't win open source back, china still sets the pace. but this is the first one that landed the ask.

![](https://pbs.twimg.com/media/HN1ewAUawAAcNM2?format=jpg&name=small)

![](https://pbs.twimg.com/media/HN1e85TbUAAMH-1?format=jpg&name=small)

![](https://pbs.twimg.com/media/HN1fIdVaAAAKUGl?format=jpg&name=small)

![](https://pbs.twimg.com/media/HN1fJwuaUAAsRR9?format=jpg&name=small)

![](https://pbs.twimg.com/media/HN04ctlacAANPSk?format=jpg&name=medium)

## Media

![](https://pbs.twimg.com/media/HN1ewAUawAAcNM2.jpg)

![](https://pbs.twimg.com/media/HN1e85TbUAAMH-1.jpg)

![](https://pbs.twimg.com/media/HN1fIdVaAAAKUGl.jpg)

![](https://pbs.twimg.com/media/HN1fJwuaUAAsRR9.jpg)

---

## Commentary from Other Bookmarks

### @sudoingX (Sudo su) — 2026-07-22

> on one dgx spark, 128 gigs of unified memory i loaded poolside's laguna s 2.1. 
> 
> serving on vllm in nvfp4 at 30-40 tok/s. an american open weight 118b mixture of experts, 8.5b active per token, built to run on exactly this box, wired straight into hermes agent. fully local, fully open, top to bottom. the model is open, the agent is open, the box is mine.
> 
> and now the only question that matters. every model can chat, can this one WORK. can it plan a real task, call the tools, read its own output, and build something end to end, all of it on a desk box that sips power from a wall socket. this is the test the spec sheets never run. watch.

[→ View quote tweet](https://x.com/sudoingX/status/2079995550506873267)

![](https://pbs.twimg.com/media/HN2fdHRbIAAisjD.jpg)

