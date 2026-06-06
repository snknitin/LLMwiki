---
title: "How to set up Claude Code so it runs like a full dev team:"
author: "Alvaro Cintas"
username: "@dr_cintas"
date: "2026-05-07"
tweet_url: "https://x.com/dr_cintas/status/2052417046789714123"
tweet_type: "original"
likes: 2753
retweets: 483
replies: 46
bookmarks: 4289
views: 245837
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude", "agents"]
---

# How to set up Claude Code so it runs like a full dev team:

> **Source:** [@dr_cintas](https://x.com/dr_cintas) · 2026-05-07 · 👍 2753 · 💬 46 · 🔖 4289 · 👁 245837

> 🔗 [View tweet on X](https://x.com/dr_cintas/status/2052417046789714123)

## Tweet Content

How to set up Claude Code so it runs like a full dev team:

5 folders. That's the entire system.

1. CLAUDE.md → Memory. 

Your repo's constitution. Naming rules, structure, expectations. One global file for all projects, one local file per repo.

2. skills/ → Knowledge. 

Reusable workflows Claude auto-invokes by matching the task description. No slash commands. It just knows.

3. hooks/ → Guardrails. 

Shell scripts that run before and after every tool call. Block dangerous commands. Auto-lint on save. Ping Slack on deploy. Deterministic. Not AI.

4. subagents/ → Delegation. 

Isolated agents with their own context window. A code reviewer that only sees the diff. A test runner with custom permissions. Keeps your main session clean.

5.plugins/ → Distribution. 

Bundle the whole system into one install. Every teammate gets the same skills, same hooks, same agents. Aligned from day one.

This is the Agent Development Kit. Five layers, one stack.

To learn how and get the full Claude guide:

1. Go to 
http://
simplifyingai.co
2. Subscribe free by just writing your email.
3. Open my welcome email and get the free resources.

Repost  to help someone in your network.

It’s so good!

![](https://pbs.twimg.com/media/HHumasrboAA6xBO?format=jpg&name=small)

## Media

![](https://pbs.twimg.com/media/HHumasrboAA6xBO.jpg)

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @LucaCaponeX (Luca Capone | Vibe Coder)

> This is my exact setup. Non-tech, started 14 months ago with zero coding. The skills/ folder was the biggest unlock. Went from repeating myself every session to Claude just... knowing.

### @thearslaniqbal (Arslan Iqbal)

> This setup looks clean on paper, but it quietly assumes all workflows can be cleanly decomposed into folders.
> 
> Real dev work is messy state + context switching, not everything fits neatly into “skills vs subagents.”

