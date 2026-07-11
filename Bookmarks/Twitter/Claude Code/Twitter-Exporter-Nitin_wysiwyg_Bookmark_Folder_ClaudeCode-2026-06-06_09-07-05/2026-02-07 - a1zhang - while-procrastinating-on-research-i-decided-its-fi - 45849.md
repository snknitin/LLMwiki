---
title: "while procrastinating on research I decided it's finally time to add RLMs to pypi!"
author: "alex zhang"
username: "@a1zhang"
date: "2026-02-07"
tweet_url: "https://x.com/a1zhang/status/2020263239653945849"
tweet_type: "original"
likes: 683
retweets: 28
replies: 16
bookmarks: 264
views: 80447
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude", "agents"]
---

# while procrastinating on research I decided it's finally time to add RLMs to pypi!

> **Source:** [@a1zhang](https://x.com/a1zhang) · 2026-02-07 · 👍 683 · 💬 16 · 🔖 264 · 👁 80447

> 🔗 [View tweet on X](https://x.com/a1zhang/status/2020263239653945849)

## Tweet Content

while procrastinating on research I decided it's finally time to add RLMs to pypi!

`pip install rlms`

## Media

![](https://pbs.twimg.com/media/HAlqbbZWwAAINnL.jpg)

---

## Commentary from Other Bookmarks

### @tenobrus (Tenobrus) — 2026-02-09

> lotta chatter about RLMs and whether or not they're useful over coding agents. i decided to just go ahead and try. i had claude code implement itself an RLM skill using bash as the execution environment / files as the variables. this is effectively implemented "inside a coding agent" in that all it requires is some bash scripts and all it does is invoke further claude code instances, but it is a genuinely different processing pattern. native subagents also aren't recursive, they can't invoke further subagents, and they don't necessarily have the same framing of files as "variables". 
> 
> i started trying to benchmark vs the oolong benchmark from the paper, and it worked but was burning through my usage. so my main test here was on Frankenstein. when i asked raw Claude Code to read Frankenstein and tell me how many named characters there are, it basically decides it's too big, searches for the ~20 characters it remembers, confirms it finds them, and tells me about the 20. when use the /rlm skill with the same question, it actually fans out and recursively processes the entire thing, and gives me the full 29 named characters including obscure ones only mentioned in Elizabeth's letter that opus doesn't actually remember in its weights.
> 
> here's the skill link, try it out. as i've warned in the past, i dont actually recommend u install this directly! i could be either malicious or compromised and installing something to ur claude is a big commitment. consider either just pasting in the readme into ur own agent and asking it for a "clean room" implementation, or if that doesn't work great asking one agent to summarize the skill and a second agent to implement it strictly from the summary.
> 
> https://github.com/Tenobrus/claude-rlm

[→ View quote tweet](https://x.com/tenobrus/status/2020770310958768449)

![](https://pbs.twimg.com/media/HAs26QgbEAADzDr.jpg)

