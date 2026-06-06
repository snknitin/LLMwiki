---
title: "You hooked up Telegram. You picked a model. You type prompts, get answers, close the tab."
author: "shmidt"
username: "@shmidtqq"
date: "2026-05-04"
tweet_url: "https://x.com/shmidtqq/status/2051307460208578864"
tweet_type: "original"
likes: 813
retweets: 75
replies: 39
bookmarks: 1956
views: 143338
has_media: false
extraction_quality: full
article_id: "2051218927263338496"
tags: ["twitter-bookmark", "claude", "llm", "agents"]
---

# You hooked up Telegram. You picked a model. You type prompts, get answers, close the tab.

> **Source:** [@shmidtqq](https://x.com/shmidtqq) · 2026-05-04 · 👍 813 · 💬 39 · 🔖 1956 · 👁 143338

> 🔗 [View tweet on X](https://x.com/shmidtqq/status/2051307460208578864)

## Article Content

You hooked up Telegram. You picked a model. You type prompts, get answers, close the tab.

You're using 8% of Hermes.

The other 92%, persistent memory, session branching, file rollbacks, voice mode, 17-platform reach, custom slash commands, sits there untouched while you treat a fully-loaded agent like a slightly smarter ChatGPT.

This article is the 92%. 15 features, ranked by impact. Most Hermes users haven't touched a single one.

Quick context for newcomers: Hermes is a provider-agnostic AI agent. 100+ pre-built skills. Runs on 17 messengers from one process. Swaps models mid-session without restarting. Built portable, extensible, yours, not locked to one vendor like every other agent on the market.

Now the list.

### PART 1: The Setup You Skipped

> ****1. /personality + SOUL.md****

Hermes reads SOUL.md at boot. Whatever's in it becomes your agent's voice forever, every session, every platform. /personality switches between named personas on the fly.

Stop typing "you are a senior X expert" at the start of every chat. Write it once.

> ****2. MEMORY.md + USER.md****

Two persistent files, read every session. MEMORY.md = project notebook. USER.md = what it knows about you. Indexed with FTS5 + LLM summarizer, so a memory from 8 weeks ago surfaces in today's session.

You stop re-explaining yourself.

> ****3. /insights [days]****

Cross-session analytics. Tokens burned, providers used, where the agent stalled, what you keep returning to. /insights 30 = last month at a glance.

https://x.com/shmidtqq/article/2051307460208578864/media/2051231106595266560

> ****4. /snapshot****

Save full Hermes state before doing something risky. Break things on purpose. /snapshot restore <id> to come back. Rollbacks for the agent itself.

### PART 2: Mid-Flight Controls

> ****5. /branch (alias /fork)****

Branch the session like a git commit. Try a riskier path without burning your good context. Doesn't pan out? Come back.

https://x.com/shmidtqq/article/2051307460208578864/media/2051231267312549888

> ****6. /rollback****

Filesystem checkpoints. Agent nuked your code? Skip git /rollback. Hermes saves every file it touched.

> ****7. /btw****

Ephemeral side question. Uses session context, calls no tools, doesn't get persisted. The "quick gut check" command.

https://x.com/shmidtqq/article/2051307460208578864/media/2051226555754397696

> ****8. /steer and /queue****

Three tool calls into a long run, you realize the agent is hitting prod instead of staging. Don't kill it. /steer use staging not prod. Next tool call sees the note. Cache stays warm. /queue lines up the next turn without breaking the current one.

https://x.com/shmidtqq/article/2051307460208578864/media/2051226417824735232

> ****9. /yolo, /fast, /reasoning****

Three power toggles. /yolo skips dangerous-command approvals. /fast flips to OpenAI Priority or Anthropic Fast Mode. /reasoning sets effort level for reasoning models. Most people stay on defaults forever and wonder why their sessions feel slow.

### PART 3: The Provider Lock-In That Isn't

> ****10. /model [--provider] [--global]****

One command swaps the model. No restart. Anthropic Opus 4.7, OpenAI Codex (GPT-5.5 via OAuth, no API key), OpenRouter, NVIDIA NIM, Kimi, Gemini, AWS Bedrock, Vercel AI Gateway, Xiaomi MiMo, Step Plan, Arcee.

https://x.com/shmidtqq/article/2051307460208578864/media/2051226608359407617

/model anthropic:claude-opus-4-7 for the heavy lift. /model openrouter:kimi-k2.6 for grunt work. State carries over.

> ****11. Auxiliary Models****

The agent compresses context, summarizes sessions, generates titles, runs vision. You can route each to a different model. Opus 4.7 for the main brain, Haiku 4.5 for compression, a tiny model for titles.

Stop paying Opus rates for Haiku-grade work.

### PART 4: The Reach You Never Activated

> ****12. The 17-Platform Gateway****

Telegram, Discord, Slack, WhatsApp, Signal, Email, SMS, Matrix, Mattermost, Feishu, WeCom, DingTalk, BlueBubbles, Home Assistant, QQBot, plus CLI and voice. One Hermes process drives all of them.

> ****13. /voice: Real-Time Voice on 4 Platforms****

CLI, Telegram DMs, Discord channels, Discord voice rooms. Type /voice and talk. Walking, driving, eyes on something else, done.

https://x.com/shmidtqq/article/2051307460208578864/media/2051226662457491456

> ****14. Cron + /webhook-subscriptions****

Built-in scheduler. Plain language schedules.

> "Every Friday 5pm, summarize this week's GitHub commits, post to Slack [#standups](https://x.com/search?q=%23standups&src=hashtag_click)
> 
> ."

Pair with /webhook-subscriptions for the inverse: GitHub, Vercel, Stripe, uptime checks push payloads straight to your DMs. Zero tokens. Zero LLM cost. Zero latency.

You're paying Zapier for this every month.

### PART 5: What Separates Real Users from Tourists

> ****15. Skills Are Slash Commands****

This is the one. 100+ skills out of the box, every one a slash command. Hit /, autocomplete fires.

```
/architecture-diagram, /excalidraw, /manim-video, /research-paper-writing, /linear, /google-workspace, /imessage, /youtube-content, /codex, /claude-code, /test-driven-development, /systematic-debugging.
```

You can write your own. I built /sage. It spots outliers in my niche, scouts trends, drafts QTs and threads in my voice. Built once. Type /sage in any session, any platform, runs forever.

Tourists use slash commands once a week. Real users built their entire workflow into them.

https://x.com/shmidtqq/article/2051307460208578864/media/2051226869014339585

You paid for an agent with persistent memory, 100+ skills, filesystem rollback, session branching, mid-flight steering, 17-platform reach, real-time voice, multi-provider routing, auxiliary model routing, cron, webhooks, and custom slash commands.

You used it as a slightly fancier telegram bot.

The tool wasn't underdelivering. You never gave it the instructions it was waiting for.

I publish settings, configurations, and unreleased Hermes tricks like these on my Telegram channel before they appear elsewhere.

If you want to get the next 15 and the SOUL.md, USER.md, and /sage files I run daily, subscribe to my tg: [https://t.me/+JmDeelv5UCwwMTcy](https://t.me/+JmDeelv5UCwwMTcy)

That's where you'll find all the interesting stuff!

> 📄 Original article URL: https://x.com/i/article/2051218927263338496

