---
title: "Hermes Wingtips #4: which file is your agent's brain"
author: "witcheer"
username: "@witcheer"
date: "2026-06-23"
tweet_url: "https://x.com/witcheer/status/2069385776756895880"
tweet_type: "original"
likes: 86
retweets: 11
replies: 5
bookmarks: 79
views: 4438
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude", "cursor", "agents"]
---

# Hermes Wingtips #4: which file is your agent's brain

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-06-23 · 👍 86 · 💬 5 · 🔖 79 · 👁 4438

> 🔗 [View tweet on X](https://x.com/witcheer/status/2069385776756895880)

## Tweet Content

Hermes Wingtips #4: which file is your agent's brain

~ SOUL.md is who the agent is: slot #1 in the system prompt, it replaces the default identity. 

~ USER.md is who you are. 

~ MEMORY.md is the facts it keeps about your work. 

~ AGENTS.md is your project's rules, found by walking the directory.

~~~
what you need to understand is that project rule files are first-match-wins. 
Hermes loads only one of .hermes.md, AGENTS.md, CLAUDE.md, .cursorrules, in that order. 

a .hermes.md in the repo shadows your AGENTS.md with no warning, and the rules you wrote never load.

SOUL.md is exempt, it always loads on its own from ~/.hermes/SOUL.md. 

if Hermes is ignoring your project instructions, check for a higher-priority file next to them. and it caps every one of these at 20,000 characters, then truncates the rest.

## Media

![](https://pbs.twimg.com/media/HLfvWPTXUAApBwA.png)

