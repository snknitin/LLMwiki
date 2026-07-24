---
title: "tmux is the most non-negotiable piece of my entire stack. not the gpu, not the models. tmux. let me..."
author: "Sudo su"
username: "@sudoingX"
date: "2026-07-10"
tweet_url: "https://x.com/sudoingX/status/2075457428536295897"
tweet_type: "original"
likes: 363
retweets: 19
replies: 32
bookmarks: 398
views: 17202
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "claude", "cursor", "agents"]
---

# tmux is the most non-negotiable piece of my entire stack. not the gpu, not the models. tmux. let me...

> **Source:** [@sudoingX](https://x.com/sudoingX) · 2026-07-10 · 👍 363 · 💬 32 · 🔖 398 · 👁 17202

> 🔗 [View tweet on X](https://x.com/sudoingX/status/2075457428536295897)

## Tweet Content

tmux is the most non-negotiable piece of my entire stack. not the gpu, not the models. tmux. let me show you why anon.

this is my machine right now, 14 named sessions, every one an agent or a service with its own lane.

1. every agent lives in its own session with a real name. reviewer, builder, server, research, content. names are what make delegation real, "check the reviewer pane" is an instruction a human or another agent can follow, and when something breaks at 2am i know exactly which door to knock on.

2. the big agents spawn their own subagents inside those lanes. the reviewer audits a task, writes the brief, hands it to the builder session, then sits there waiting to tear the PR apart. builders fan out their own workers when the task is wide. i read conclusions, not diffs, and the tree of agents underneath stays their problem.

3. one pane serves a 27b model on localhost, the next pane runs the agent that talks to it. the model and its consumers are neighbors in the same house, no cloud between them, and when i want to swap the model i restart one pane and nobody else notices.

4. grok sits in its own pane with live x search, that's the research desk, it pulls timelines and receipts while everything else builds. claude runs planning and the files. cursor agents write the code. three vendors, one terminal, zero browser tabs, and they read each other's work through the panes.

5. no ide anywhere. every serious agent is a cli now, and the terminal quietly became the better ide while nobody was looking. syntax highlighting doesn't ship features, agents do.

6. everything survives me. close the laptop, kill the connection, reboot the router, the fleet keeps its state. attach tomorrow morning and every conversation sits exactly where i left it mid-thought. tmux is the persistence layer of the whole
company.

this is not a dev setup. it's an office. every session is an employee that never clocks out. if you run agents and you don't run tmux, you're running them with one hand.

and the part that takes it to the next level. put the machine on a tailnet, install termius on your phone, ssh in, attach. the entire fleet in your pocket, every agent mid thought exactly where you left it. 

i check builds from bed and answer the reviewer from cafes. the office

![](https://pbs.twimg.com/media/HM2AkzYacAAu-9I?format=jpg&name=medium)

## Media

![](https://pbs.twimg.com/media/HM2AkzYacAAu-9I.jpg)

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @doodlestein (Jeffrey Emanuel)

> Agreed, that’s why I built my ntm orchestration tool as a wrapper around tmux, named_tmux_manager. It basically just adds some nice abstractions on top to make it more ergonomic for agents:

**Links shared:**
- https://t.co/Jy5dUxrtXv

### @alexellisuk (Alex Ellis)

> Seriously, have a look at the tmux manager I built - video on my profile. 
> 
> I got fed up of tmux list-sessions/attach and switching in/out. 
> 
> On top feedback from agent events shows me which to look at and when.

