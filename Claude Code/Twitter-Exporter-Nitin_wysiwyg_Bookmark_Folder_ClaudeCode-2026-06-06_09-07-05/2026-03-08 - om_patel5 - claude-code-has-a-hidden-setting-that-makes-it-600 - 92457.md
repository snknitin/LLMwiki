---
title: "claude code has a hidden setting that makes it 600x faster and almost nobody knows about it"
author: "Om Patel"
username: "@om_patel5"
date: "2026-03-08"
tweet_url: "https://x.com/om_patel5/status/2030479131222192457"
tweet_type: "original"
likes: 5676
retweets: 245
replies: 192
bookmarks: 13317
views: 839764
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude"]
---

# claude code has a hidden setting that makes it 600x faster and almost nobody knows about it

> **Source:** [@om_patel5](https://x.com/om_patel5) · 2026-03-08 · 👍 5676 · 💬 192 · 🔖 13317 · 👁 839764

> 🔗 [View tweet on X](https://x.com/om_patel5/status/2030479131222192457)

## Tweet Content

claude code has a hidden setting that makes it 600x faster and almost nobody knows about it

by default it uses text grep to find functions. 

it doesn't understand your code at all. that's why it takes 30-60 seconds and sometimes returns the wrong file

there's a flag called ENABLE_LSP_TOOL that connects it to language servers. same tech that powers vscode's ctrl+click to jump straight to the definition

after enabling it:

> "add a stripe webhook to my payments page" - claude finds your existing payment logic in 50ms instead of grepping through hundreds of files

> "fix the auth bug on my dashboard" - traces the actual call hierarchy instead of guessing which file handles auth

> after every edit it auto-catches type errors immediately instead of you finding them 10 prompts later

also saves tokens because claude stops wasting context searching for the wrong files

2 minute setup and it works for 11 languages

thats what i was thinking as well

![](https://pbs.twimg.com/media/HC20PVeXAAA2tAe?format=jpg&name=900x900)

## Media

![](https://pbs.twimg.com/media/HC20PVeXAAA2tAe.jpg)

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @micahtid (micah)

> why is this not enabled by default

### @jarredsumner (Jarred Sumner)

> - LSP is enabled by default
> - Sadly, it doesn’t make Claude 600x faster
> - it is kind of popula but probably too hard to use. It works well in some codebases.

### @alankingny (Alan King)

> This is a viral engagement-bait post. The claims are fabricated:
> - "600x faster" — made up number
> - "ENABLE_LSP_TOOL" — doesn't exist in Claude Code's settings or environment
> variables
> - "50ms definition lookup" — not a real feature
> - "auto-catches type errors after every edit" —

### @recrsn (Amitosh)

> Bunch of misinformation here, LSP will give little benefit (often worse) with too high memory usage and more token usage. Don’t do it

