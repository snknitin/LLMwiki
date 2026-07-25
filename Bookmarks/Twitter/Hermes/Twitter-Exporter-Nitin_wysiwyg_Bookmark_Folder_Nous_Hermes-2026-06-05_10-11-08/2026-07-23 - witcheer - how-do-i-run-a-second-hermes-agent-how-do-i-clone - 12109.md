---
title: "how do I run a second Hermes Agent? how do I clone a working install? how do I move to a new machine..."
author: "witcheer"
username: "@witcheer"
date: "2026-07-23"
tweet_url: "https://x.com/witcheer/status/2080263307483812109"
tweet_type: "original"
likes: 265
retweets: 22
replies: 34
bookmarks: 295
views: 11209
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "mcp", "agents"]
---

# how do I run a second Hermes Agent? how do I clone a working install? how do I move to a new machine...

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-07-23 · 👍 265 · 💬 34 · 🔖 295 · 👁 11209

> 🔗 [View tweet on X](https://x.com/witcheer/status/2080263307483812109)

## Tweet Content

how do I run a second Hermes Agent? how do I clone a working install? how do I move to a new machine? how do I separate work from personal?

the answer is one feature: Hermes Profiles.

a Profile is a fully separate agent on the same machine. it has its own config, API keys, SOUL.md, memory, skills, sessions, cron jobs, and gateway. your default install is itself a profile.

here are a handful of things you can do with Profiles:

(1) create one:

`hermes profile create coder`

you also get a `coder` command: `coder chat`, `coder setup`, `coder gateway start`.

(2) split work from personal:

`hermes profile create work --clone`

it keeps the same config, keys, skills, and personality, but starts with fresh memory and sessions. you can put a different Telegram or Discord bot token in each profile’s .env and run both gateways side by side.

(3) create a snapshot on the same machine:

`hermes profile create backup --clone-all`

it copies everything except session history.

(4) move to a new machine:

`hermes profile export coder`

this creates a `coder.tar.gz` you can transfer over. then on the new machine:

`hermes profile import coder.tar.gz`

export includes session history, so the agent arrives with its past intact.

(5) give the agent to someone else:

`hermes profile install github[.]com/you/research-bot --alias`

this installs the SOUL, config, skills, cron jobs, and MCP connections from a git repo.

happy to answer any remaining questions in the comments :)

![](https://pbs.twimg.com/media/HN6Rwj5awAA5N0F?format=jpg&name=medium)

## Media

![](https://pbs.twimg.com/media/HN6Rwj5awAA5N0F.jpg)

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @507plife (Nathan A)

> Now just let us be able to group the slack and telegram sessions by profile.  As well. It is helpful for troubleshooting coworker issues. As we have a 30 person team using it. All the slack threads go to one area in the bottom corner of the desktop

