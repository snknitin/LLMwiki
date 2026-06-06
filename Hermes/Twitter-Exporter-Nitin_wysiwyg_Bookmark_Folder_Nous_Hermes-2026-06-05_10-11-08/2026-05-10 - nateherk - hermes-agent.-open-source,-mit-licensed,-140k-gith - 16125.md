---
title: "Hermes Agent. Open source, MIT licensed, 140K GitHub stars and growing fast. Built by Nous Research."
author: "Nate Herk"
username: "@nateherk"
date: "2026-05-10"
tweet_url: "https://x.com/nateherk/status/2053308681299616125"
tweet_type: "original"
likes: 888
retweets: 90
replies: 19
bookmarks: 2412
views: 459750
has_media: false
extraction_quality: full
article_id: "2053303508602896394"
tags: ["twitter-bookmark", "claude", "agents"]
---

# Hermes Agent. Open source, MIT licensed, 140K GitHub stars and growing fast. Built by Nous Research.

> **Source:** [@nateherk](https://x.com/nateherk) · 2026-05-10 · 👍 888 · 💬 19 · 🔖 2412 · 👁 459750

> 🔗 [View tweet on X](https://x.com/nateherk/status/2053308681299616125)

## Article Content

Hermes Agent. Open source, MIT licensed, 140K GitHub stars and growing fast. Built by Nous Research.

This is the full breakdown. The mental model, the setup, the API key handling, the first cron worth running, the dashboard, the scaling rules, and every piece of practical advice I'd give you if we were sitting down to build one together.

### TL;DR

→ Hermes is an open source agent that grows with you. VPS, Mac Mini, laptop, Docker, even Android via Termux.

→ Five pillars: Memory, Skills, Soul, Crons, Self-Improving Loop.

→ Connects to Telegram, Discord, Slack, WhatsApp, iMessage.

→ I don't replace Claude Code with it. Hermes is the on-the-go, voice-first, scheduled-automation layer that lives in your pocket.

### What Hermes Actually Is

It's the agent in your pocket.

Claude Code is my daily driver for knowledge work and coding at my desk.

Hermes is what I talk to from Telegram while I'm walking the dog, on a flight, or away from the laptop.

Same brain, different interface.

Out of the box, 91 skills ship with it. The community hub has 520+ more. 16 of those are official Anthropic skills. I've never had to install Excalidraw or a transcription skill. Both were already there.

My main one runs:

→ A daily AI news briefing posted to my Skool community

→ YouTube comment monitoring with sarcastic-but-not-rude replies

→ Skool community engagement

→ Morning business summaries

→ Server health checks

→ Research reports

→ Follow-up reminders

All scheduled. All from natural language.

I once asked it to make a video about itself using HyperFrames. It did the research. Installed HyperFrames on its own. Used vision to grade its own output. Iterated. Shipped a video that wasn't half bad.

The mindset shift: Hermes understands Hermes better than you do. Just ask it.

### Hermes vs Claude Code vs OpenClaw

These are not the same tool. Don't pick one.

→ ****Claude Code**** is Anthropic's coding assistant. Lives in your terminal next to your code. You sit and drive it. Daily driver for desk work.

→ ****OpenClaw**** was created by Peter Steinberger (now at OpenAI). 350K+ stars. NVIDIA built Nemo Claw on top of it. Strong on-the-go agent.

→ ****Hermes ****is lighter, faster, more focused on the self-improvement loop. Built for people who want to tinker with open source models like Qwen and LLaMA.

I switched from OpenClaw to Hermes because OpenClaw was crashing too often after rapid updates. Hermes has been more stable for me.

The unlock: all of these can run side by side on the same GitHub repo. Your business context, skills, and memory live in version control. Then any agent (Claude Code, Hermes, OpenClaw, Codex) can plug into it.

The terminology shifts (Claude.md vs Agents.md vs Hermes files) but each agent understands its own conventions. Tell it "make this repo work for you" and it adapts.

### The Five Pillars

This is the mental model that makes Hermes click. Skip this and nothing else makes sense.

1️⃣ ****Memory****

https://x.com/nateherk/article/2053308681299616125/media/2053306794420649987

→ user.md is who you are, your style, your preferences, things you don't like

→ memory.md is your projects, your environment, your business context

→ Both load at session start so the agent doesn't wake up stateless every time

→ Think Memento. Agents wake up with no memory unless you've built the context for them

→ Hermes auto-extracts facts and updates these files as you work

→ Don't be passive. Tell it: "Chuck that in memory" or "Update user.md so I never have to repeat that"

→ Save durable preferences and facts. Use session search for old conversations (stored in SQLite)

→ Never put secrets or temporary task status in memory

2️⃣ ****Skills****

https://x.com/nateherk/article/2053308681299616125/media/2053306982895960071

→ Procedural memory. Reusable playbooks

→ Recipe analogy: ask for chocolate chip pancakes from memory and they're inconsistent. Pull up the recipe and they come out the same every time.

→ Stored as skill.md files with YAML front matter

→ Front matter tells the agent when to invoke the skill (progressive disclosure)

→ The body only loads when the skill is invoked, so you don't bloat the context

→ Hermes analyzes your conversations and offers to turn repeated patterns into skills

→ Give feedback and skills update over time

3️⃣ ****Soul****

https://x.com/nateherk/article/2053308681299616125/media/2053307049480433664

→ soul.md shapes the agent's personality

→ Spin up six Hermes agents and each one can have its own vibe

→ Concise, sarcastic, blunt, formal, whatever fits the role

→ My YouTube comment Hermes is sarcastic but not rude. That's all in the soul

→ Evolves over time as you give it feedback

4️⃣ ****Crons****

https://x.com/nateherk/article/2053308681299616125/media/2053307121198903301

→ This is where Hermes leaves Claude Code in the dust

→ Tell it "every morning at 6am do X" and it just does it

→ Each cron runs in a fresh isolated session and sends results back to chat

→ Useful flags: CONTEXTFROM passes one job's output into the next. WORKDIR runs tools from a project folder. NOAGENT runs a script without the agentic harness loop (just executes the workflow, no agent reasoning)

→ Cron sessions cannot recursively create more cron jobs, so the prompt has to be self-contained

→ You can also set time-bounded crons. "For the next 12 hours, run every 10 minutes, then kill it" works the same way the /loop slash command works in Claude Code

5️⃣ ****Self-Improving Loop****

https://x.com/nateherk/article/2053308681299616125/media/2053307180044910592

→ Do work, get feedback, save to memory

→ Turn repeatable steps into skills

→ Search past sessions when old context matters

→ The more you use it, the better it gets

→ Honest caveat: automatic doesn't mean magic. The loop works best when you correct it on the spot, ask it to save things, and let it create new skills after complex work

https://x.com/nateherk/article/2053308681299616125/media/2053307234172477444

There's also a sixth honorable mention: agents.md (Codex's version, similar to Claude.md). Project-level context. Useful when you're using Hermes in the terminal for coding.

Also, my Hermes agent generated all of these Excalidraw diagrams ;)

### The Claude Code Trick That Saves You

This is the move most people skip. Don't.

Build a Claude Code project to manage your Hermes agents.

I have one called `vps-agents`. Inside it, every agent has its own folder. Mine has bull (my trading bot), my main Hermes, uppit-os, and claus (my personal assistant).

Each folder stores:

→ The IP address

→ The admin username and password

→ Notes on which API keys live where

→ Container setup details

→ Docker info

→ Security and integration notes

Why it matters: when something breaks at 11pm, I don't dig through Hostinger looking for passwords. I open Claude Code, point it at the project, and it fixes the agent for me.

You're building the assistant for the assistant.

### Setting Up Your VPS On Hostinger

A VPS is a computer in the cloud you rent. Get an IP, get a password, SSH in, install stuff. Done.

Here's the path:

→ Pick a plan. KVM2 is plenty to start. KVM1 if you want cheap. Scale up later if you need more CPU/RAM

→ Annual plan saves real money. Use code NATEHURK for 10% off

→ Choose Ubuntu 24.04 LTS as the OS

→ The Hostinger marketplace has a Hermes Agent one-click install if you want to skip the manual route

→ Set a root password (you can regenerate it later if you forget)

→ Turn on the free malware scanner

Now the choice that matters: install at the root of the VPS or use Docker?

→ ****Root install:**** Hermes lives directly on the VPS at the root level

→ ****Docker container (one-click):**** Each agent gets its own isolated container with its own keys, memory, and tools

https://x.com/nateherk/article/2053308681299616125/media/2053307557150654469

I went Docker. Each agent stays cleanly separated. Easy to spin up a marketing Hermes, a finance Hermes, or a content Hermes later, each in their own container, each with their own .env.

Pro tip: change the hostname so your VPS list stays organized. Mine looks like `youtube-hermes.vps`. Hostinger's UI updates instantly.

### Onboarding Hermes

Once the container is deployed, hit Open. Punch in the admin username and password. Onboarding fires.

Here's the inference provider call. Hermes supports tons of providers. The cheapest one for most people:

→ OpenAI Codex via OAuth. Plugs your existing ChatGPT subscription ($20, $100, or $200/mo) into Hermes instead of burning API tokens.

For open-source-purist mode you can run Qwen or LLaMA locally. I'm not there yet. Plan to experiment.

Choose your model (GPT-5.5 in my case). Set up messaging. Pick Telegram from the list with the spacebar.

Telegram setup, 90 seconds:

1️⃣ Open Telegram, message BotFather, type `/newbot`

2️⃣ Name your bot. Username has to end in "Bot"

3️⃣ Copy the token. Paste it back into the Hermes terminal

4️⃣ Get your Telegram user ID from the USERINFO bot

5️⃣ Paste the user ID into Hermes to lock the bot to you

Tools that ship enabled: Vision, Browser Automation, Image Gen, Text-to-Speech, Terminal Commands, Task Planning, Skills.

Save everything Hermes prints during onboarding (settings paths, API key paths, config paths) into your Claude Code project. Future-you will thank present-you.

Here's what stood out. I didn't have to know any of this before I started. I just asked Hermes and Claude Code to explain it as I went.

### API Keys, Done The Right Way

Don't paste API keys in chat. Even if the model is private, the key is now in conversation history.

If you're using a hosted model and you accidentally drop one, just rotate it. Not the end of the world. But best practice is never paste them.

The right way:

1️⃣ SSH into your container

2️⃣ Run `hermes config set GITHUB_TOKEN [your_token]`

3️⃣ The key gets saved into the container's `/opt/data/.env`. Never seen by the model. Never in logs.

Same pattern for every key. Named per agent. Scoped to the minimum permissions that agent actually needs.

If you ever need to wipe or rotate a key, ask Hermes for the Nano command to open the right .env. The first time I tried this, the command pointed at the root VPS .env, not the container's. Hermes corrected itself once I told it the agent runs inside Docker. Lesson: you don't need to understand the path tree, you just need to communicate clearly what you're seeing.

### The First Cron Worth Building

Connect Hermes to a private GitHub repo. Then schedule a nightly sync.

If the VPS gets corrupted, your skills and memory are gone. With a GitHub backup, you spin up a new Hermes, point it at the repo, and you're back online.

I told my agent: "Every night at midnight Central, push everything except secrets to my private GitHub repo."

It built the skill. Set the cron. Wrote the .gitignore so secrets never get committed. Done.

The annoying part: containers run in UTC by default. Hermes self-checks Central time on the hour to handle daylight savings. It figured that out on its own.

Token best practice: classic GitHub token, scoped to repo + contents (read and write) only. Don't grant more than the agent needs.

That's the loop. Natural language in. Working automation out.

### CLI vs Telegram

Same agent, same brain, same skills, same memory, same window. Different interfaces.

→ ****CLI (terminal)**** is the cockpit. Best for deep work, coding, hardcore building. You can see context usage, manage compaction, hit slash commands, and live in there like an operating system.

→ ****Telegram ****is the remote control. Best for scheduled jobs, quick tasks, voice messages, on-the-go knowledge work, talking to it from your phone.

Telegram has less visibility into context. The session feels ambiguous because auto-compaction runs under the hood and you can't really see when. So don't vibe code apps from Telegram. Risk of context rot is too high.

But for "Hey check ClickUp," "research this for me," "schedule this cron," "post to Skool" — Telegram is faster than the CLI ever could be.

Token-based context, not message-based. The model always sees system prompt + user.md + soul.md + memory.md. That all has to fit. As you approach the limit, auto-compaction fires.

### Two Paths To Your First Skill

There are two ways to add a skill.

→ ****Describe an outcome.**** "Every night at midnight Central, sync this repo." Hermes builds the skill, names it, sets the cron, ships it.

→ ****Install one from a URL.**** Grab a skill from the community hub or your own Claude Code projects. Tell Hermes the link. It installs and registers it.

I tested by asking Hermes to install the official HyperFrames skill and generate a 5-second video introducing itself based on its own soul.md. It did the install, ran the skill, and produced a usable clip with no extra hand-holding.

Watch the agent while it's working. If you wanted it to invoke a skill and it didn't, that's your signal to tell it: "Update the YAML front matter so this skill triggers when I say things like X."

That's how skills actually get sharp.

### Treat Hermes Like A New Hire

This is non-negotiable.

→ Each Hermes agent gets its own accounts (Gmail or agent mail), not yours

→ Each agent gets its own API keys, scoped tight

→ Use named API keys per agent (OpenRouter, Perplexity, etc.) so you can see which agent is spending what

→ Least privilege rule: only the credentials and tools needed for the job

→ Marketing agent doesn't need read access to QuickBooks. Finance agent does

You wouldn't hand a brand new intern your credit card. Don't hand it to your agent either.

Lock down the VPS too. Set up a firewall on Hostinger, restrict to your IP, block unused ports. Build a skill that runs a nightly security audit. Hermes can attack its own setup and report what it found.

I didn't know anything about firewalls before this. Hermes and Claude Code walked me through it. The agents teach you the system.

### Maintenance Rules

These are the rules I follow to keep an agent sharp:

→ Wrong twice on the same thing? Correct it on the spot and tell it to update the relevant skill or memory

→ Same instruction twice? Ask Hermes to write a skill for it

→ Verbose or off-tone? Edit the soul

→ New scheduled task? Build a skill, then ask Hermes to schedule it

→ Something breaks? Check memory.md first. Stale memory is the number one cause of weird agent behavior

Audit any time. "Read me your memory file. Read me your soul file." See what's in there. Cut what's wrong.

This isn't a tool you finish setting up. It's a teammate you keep training.

### Compaction Will Hit. Don't Panic

Eventually you'll hit the auto-compaction threshold. Mine fired around 170K tokens (threshold is roughly 136K).

When it fails, Hermes inserts a fallback context marker, pauses crons that need pausing, and updates memory before continuing.

If you don't understand what just happened, paste the message back to it: "Explain this to me. What does that fallback marker mean?" It'll explain. That's part of the loop.

### When To Spin Up A Second Hermes

Simple decision tree:

https://x.com/nateherk/article/2053308681299616125/media/2053308060559392773

→ Needs its own credentials, secrets, or tools? → New agent

→ Needs its own long-term memory? → New agent

→ Ongoing, repeated work that's basically a separate role? → New agent

→ Otherwise → Keep it in your main personal one

Recommendation: get max use out of your main personal Hermes first. Once you've built five or ten skills there, splitting becomes obvious.

Migration is easy. Skills, crons, soul, memory are all markdown files. Move them, point the new agent at them, you're running.

https://x.com/nateherk/article/2053308681299616125/media/2053308140272189441

Bad pattern: one mega-agent with every API key, every skill, every cron. High confusion. High blast radius when something breaks.

Good pattern: a main personal Hermes plus split-off agents for marketing, finance, content, or whatever vertical fits. Each in its own Docker container. Each with scoped keys. Each with its own .env that never gets committed to GitHub.

https://x.com/nateherk/article/2053308681299616125/media/2053308217493430272

Your main Hermes can help you plan the org structure. Treat it like your COO. Ask it: "Based on what we've built, what should I split off first?" It'll have an opinion.

### The Dashboard And Kanban Board

Hermes ships with its own dashboard. Recent sessions, connected platforms, keys, configs, skills, plug-ins, crons, and a Kanban board for assigning tasks across multiple agents.

To open it the first time you have to tunnel into your container, open the gateway, and run a few commands. It's clunky on first try.

https://x.com/nateherk/article/2053308681299616125/media/2053308541989978113

The fix: tell your Hermes "I want to open the dashboard. Walk me through it." Once it works, ask it to save the steps as a skill so future opens are three commands.

https://x.com/nateherk/article/2053308681299616125/media/2053308637720838144

I rarely use the dashboard because most of my Hermes work happens on the go. But if you're running multiple agents and want to assign tasks visually, the Kanban board is solid.

### Wrap

Hermes isn't a replacement for Claude Code.

It's the on-the-go, voice-first, scheduled-automation layer that lives in your pocket and grows with you.

Get one running. Connect Telegram. Set the GitHub backup. Build a couple of skills. The compounding starts after that.

I walk through the full setup, every command, every gotcha, in the video. Link in the first reply.

> 📄 Original article URL: https://x.com/i/article/2053303508602896394

---

## Commentary from Other Bookmarks

### @nateherk (Nate Herk) — 2026-05-10

> Hermes actually is the real deal.
> 
> I just dropped a one hour course on it. 
> 
> All the way from setting one up to understanding how to build an army of them.
> 
> Give this a read.

[→ View quote tweet](https://x.com/nateherk/status/2053308985575362681)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

### @shannholmberg (Shann³) — 2026-05-10

> Nate Herk just wrote the most thorough Hermes Agent setup guide on the internet
> 
> Here are 12 lessons you need to know before you build your own 🧵

[→ View quote tweet](https://x.com/shannholmberg/status/2053477584068063708)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

