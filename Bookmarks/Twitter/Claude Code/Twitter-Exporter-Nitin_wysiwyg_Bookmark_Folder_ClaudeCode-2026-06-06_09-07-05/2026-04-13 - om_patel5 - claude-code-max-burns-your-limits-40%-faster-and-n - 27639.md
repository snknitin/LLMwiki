---
title: "CLAUDE CODE MAX BURNS YOUR LIMITS 40% FASTER AND NO ONE TOLD YOU WHY"
author: "Om Patel"
username: "@om_patel5"
date: "2026-04-13"
tweet_url: "https://x.com/om_patel5/status/2043524173016727639"
tweet_type: "original"
likes: 2107
retweets: 160
replies: 130
bookmarks: 1676
views: 263611
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude"]
---

# CLAUDE CODE MAX BURNS YOUR LIMITS 40% FASTER AND NO ONE TOLD YOU WHY

> **Source:** [@om_patel5](https://x.com/om_patel5) · 2026-04-13 · 👍 2107 · 💬 130 · 🔖 1676 · 👁 263611

> 🔗 [View tweet on X](https://x.com/om_patel5/status/2043524173016727639)

## Tweet Content

CLAUDE CODE MAX BURNS YOUR LIMITS 40% FASTER AND NO ONE TOLD YOU WHY

this guy set up an HTTP proxy to capture full API requests across 4 different Claude Code versions.

here's what he found:

Claude Code v2.1.100 silently adds ~20,000 invisible tokens to every single request. 

they are server-side so you can't see them and they don't show up in /context.

the proof:

> v2.1.98: 49,726 billed tokens
> v2.1.100: 69,922 billed tokens
> same project, same prompt, same account

v2.1.100 actually sends FEWER bytes but gets billed 20K MORE tokens. the inflation is 100% server-side.

and it's not just about billing. those 20K invisible tokens enter the model's actual context window. 

which means:

> your CLAUDE.md instructions get diluted by 20K tokens of hidden content
> quality degrades faster in long sessions
> when Claude ignores your rules you can't tell if it's because of invisible context you can't audit

the fix: downgrade to v2.1.98

npx claude-code@2.1.98

![](https://pbs.twimg.com/media/HFwNZXlXEAACNeT?format=jpg&name=small)

## Media

![](https://pbs.twimg.com/media/HFwNZXlXEAACNeT.jpg)

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @psimatrix (Rombaro Rory)

> At what point does this become blatant fraud?

### @d4m1n (Dan)

> fix: cancel Max sub

### @RaleighC (ral.eth)

> 20k tokens is insane

### @chriswinfield (Chris Winfield - Understanding A.I.)

> Token inflation crazy

