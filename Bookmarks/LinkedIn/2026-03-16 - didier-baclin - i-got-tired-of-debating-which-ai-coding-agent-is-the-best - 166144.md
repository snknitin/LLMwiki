---
title: "I got tired of debating which AI coding agent is 'the best.'"
author: "Didier Baclin"
author_url: "https://www.linkedin.com/in/ACoAAABbSkcBJPQ8txg6L8V8X49GoRtCEPb4Yz0"
headline: "CTO, Datasharp – Building AI-powered B2B data platform | Ex-Amazon & Zopa"
date: "2026-03-16"
posted_relative: "4mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7439219493052166144/"
activity_id: "7439219493052166144"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, agents, llm, mcp, prompting]
---

# I got tired of debating which AI coding agent is "the best."

> **Source:** [Didier Baclin](https://www.linkedin.com/in/ACoAAABbSkcBJPQ8txg6L8V8X49GoRtCEPb4Yz0) · CTO, Datasharp – Building AI-powered B2B data platform | Ex-Amazon & Zopa · 4mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7439219493052166144/)

## Post

I got tired of debating which AI coding agent is "the best." 
So I built a system that runs Claude, Codex, and Gemini in parallel, each one doing what it's strongest at. Today I'm open-sourcing it.

Using a single AI coding agent is already starting to feel irrational.

Not because any of them are bad.
Because they are not good at the same things.
- One is better at architecture and review.
- One is faster at precision fixes and CI work.
- One is stronger on broad context and frontend polish.

So why are we still pretending the winning setup is to pick one and force it to do everything?
That feels less like a workflow decision and more like carrying over old software habits into a new era.

So I built CodeFleet.
It is an open-source MCP server that lets Claude Code orchestrate Claude, Codex, and Gemini coding agents inside one workflow.

The core idea is simple:
Stop choosing one model. Start coordinating specialists.

With CodeFleet, each agent gets its own isolated git worktree, can run in parallel, and can pass outputs through a structured workflow. 
That means less prompt-copying, fewer context resets, and a process that feels much closer to working with a real team.

The bigger point is this:
I do not think the future of AI coding is “which model wins?”
I think it is orchestration.
The teams that get the most leverage will not be the ones with one favorite agent.
They will be the ones that know how to combine several well.

Repo in comments.

Are you still choosing one coding agent or building workflows that use the strengths of all of them?

#AgenticAI #OpenSource #DeveloperTools

## Images

![](https://media.licdn.com/dms/image/v2/D4E22AQF2BJc5NgzpjA/feedshare-shrink_480/B4EZzzAuTNJEAk-/0/1773603579558?e=1787184000&v=beta&t=ukqvcyP00F9xxgdMvzxXKs1pT_3VRP_EOg_r9pwdvow)

