---
title: "****One command installs it. One login arms it. By week 2 it builds workflows you never taught it.**..."
author: "Moysei"
username: "@0xMoysei"
date: "2026-06-30"
tweet_url: "https://x.com/0xMoysei/status/2071991899653570814"
tweet_type: "original"
likes: 61
retweets: 2
replies: 4
bookmarks: 102
views: 167986
has_media: false
extraction_quality: full
article_id: "2071989404965470208"
tags: ["twitter-bookmark", "claude", "agents"]
---

# ****One command installs it. One login arms it. By week 2 it builds workflows you never taught it.**...

> **Source:** [@0xMoysei](https://x.com/0xMoysei) · 2026-06-30 · 👍 61 · 💬 4 · 🔖 102 · 👁 167986

> 🔗 [View tweet on X](https://x.com/0xMoysei/status/2071991899653570814)

## Article Content

****One command installs it. One login arms it. By week 2 it builds workflows you never taught it.****

A 29-year-old freelance automation consultant in Lisbon spent his evenings on the same 3 jobs for clients: pulling transcripts, drafting posts, sorting inboxes. In March he moved all of it onto one agent running on a $5 VPS. He talks to it from Telegram on his phone. It keeps working with his laptop shut.

The agent is Hermes, built by Nous Research. It is the one agent with a built-in learning loop. After any task that takes 5 or more steps, it writes the method into a skill file and reuses it next time. His voice, his formats, his checks, saved once and patched every time they drift. He did not fine-tune a model. He gave it a folder.

### 1. What Hermes is, in one line

A self-improving agent that creates skills from experience, searches its own past sessions, and builds a model of how you work across conversations. Run it on a $5 VPS, a GPU box, or serverless that costs almost nothing when idle. Point it at any model: Nous Portal, OpenRouter, OpenAI, or your own endpoint. Switch with hermes model, no code changes.

### 2. Install it in one command

****On Mac or Linux:****

> curl -fsSL [https://hermes-agent.nousresearch.com/install.sh](https://hermes-agent.nousresearch.com/install.sh)
> 
>  | bash

Windows ships a PowerShell installer; phones use the Termux path. Run hermes doctor straight after. It flags missing provider config, broken env vars, and bad paths before you lose an hour to a typo.

### 3. Arm it with one login

Run hermes setup --portal. One OAuth covers a model plus 4 tools: web search, image generation, text-to-speech, and a cloud browser. No 5 separate API keys to collect. Want your own keys per tool? Run hermes setup for the full walkthrough, or Blank Slate to start with terminal and file tools only and switch the rest on yourself.

### 4. Give it a model with room to think

Hermes rejects any model under 64,000 tokens of context at startup. A smaller window cannot hold a multi-step tool-calling job. Claude, GPT, Gemini, Qwen, and DeepSeek all clear it. Running a local model? Set its context to at least 64K.

### 5. Run it two ways

Terminal: hermes or hermes --tui for the modern interface. Gateway: hermes gateway puts it on Telegram, Discord, Slack, WhatsApp, Signal, or Email. Both share 1 session database. Start a job at your desk, finish it from your phone on the train, same memory and same skills.

### 6. Teach it your work as skills

Skills are plain knowledge files. Drop one in ~/.hermes/skills/ and it goes live with no registration. They load only when the agent reaches for them, so they cost 0 tokens until used. List them with hermes skills list, pull more from the Hub with hermes skills install. After a hard task, Hermes offers to save the method as a skill on its own. Want eyes on that loop? Set write_approval: true and approve every skill it writes.

### 7. Let it split the work

https://x.com/0xMoysei/article/2071991899653570814/media/2071993589752578048

The delegate_task tool spawns subagents with their own toolsets and a clean context. One researches, one drafts, one reviews, all at once. Each starts fresh, so you hand it everything it needs up front. For repeat clients, run profiles: separate config, keys, memory, and Telegram bot per agent on 1 machine.

### 8. Put it on a schedule

Built-in cron fires jobs on an interval and delivers the result to any platform. A new file in a folder, a morning brief at 7, a weekly report, none of it needs you to press a button. Pair the terminal tool with a Docker backend and it behaves like a persistent sandbox: install a package once, it stays for the session.

### 9. What to point it at

- Content: pull a transcript with yt-dlp, write the post inside your skill, send the draft to Telegram for approval before it posts.
- Inbox and calendar: read, sort, draft replies, book slots over email or messaging.
- Research: fan out subagents across sources, collect summaries into 1 report.
- Code: review, refactor, and run across a repo through the github-pr-workflow skill.
- Documents: read 50 PDFs, pull the numbers, return a structured brief.

### 10. How people earn with it

https://x.com/0xMoysei/article/2071991899653570814/media/2071993506025881600

Sell the output, not the setup. 3 grounded paths:

- Done-for-you automations. Build a client's inbox-to-CRM or booking flow once, charge a setup fee plus a retainer. Agencies price these builds from a few hundred to a few thousand each (self-reported).
- Content production. Run a faceless channel or a client's posting pipeline end to end, video in, posts out.
- Productized skills. Package a workflow as a skill and share it through the Skills Hub for others to install.

The math that makes it hold: the agent runs on a $5 box, and the code that coordinates its subagents bills 0 tokens, only the model calls cost. Your floor stays low while the work compounds.

It does not get tired, and it never forgets what it learned yesterday.

### Thanks for reading

If this saved you a weekend of trial and error, that is the whole point. Follow for the build logs and the skills I ship next, and bookmark this for the day you run hermes setup yourself. Build something with it, then come tell me what it learned.

> 📄 Original article URL: https://x.com/i/article/2071989404965470208

---

## Commentary from Other Bookmarks

### @0xMoysei (Moysei) — 2026-06-30

> Nous Research just published the manual on an agents.
> 
> Most agents die the same way. Every session resets.
> You re-paste the files, re-explain the context, rebuild the workflow from zero. They never compound.
> 
> So Hermes moved the upkeep into a closed loop. It curates its own memory, writes its own skills, and refines them while it uses them. You bring the problem. It remembers how it solved the last one.
> 
> raw memory stays grounded in a real machine it returns to, not a chat window. Each solved problem becomes a tool it calls again later.
> 
> One gateway, more than 20 surfaces. Start in the terminal, continue from Telegram, no context lost. Runs on a $5 VPS that hibernates when idle.
> 
> Most agents forget you. Hermes keeps the books.

[→ View quote tweet](https://x.com/0xMoysei/status/2072081527186313343)

![](https://pbs.twimg.com/media/HMGDCrhXYAAGHIQ.png)

