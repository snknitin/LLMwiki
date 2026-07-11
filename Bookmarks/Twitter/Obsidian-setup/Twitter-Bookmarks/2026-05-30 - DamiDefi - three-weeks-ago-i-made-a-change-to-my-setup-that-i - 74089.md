---
title: "Three weeks ago I made a change to my setup that I did not expect to matter as much as it did."
author: "Dami-Defi"
username: "@DamiDefi"
date: "2026-05-30"
tweet_url: "https://x.com/DamiDefi/status/2060653619116974089"
tweet_type: "original"
likes: 460
retweets: 66
replies_count: 21
bookmarks: 1095
views: 135800
has_media: false
article_id: "2060307282269802496"
tags: ["twitter-bookmark", "obsidian", "claude", "llm", "ai-tools"]
---

# Three weeks ago I made a change to my setup that I did not expect to matter as much as it did.

> **Source:** [@DamiDefi](https://x.com/DamiDefi) - 2026-05-30 - Likes: 460 - Bookmarks: 1095 - Views: 135800

> [View on X](https://x.com/DamiDefi/status/2060653619116974089)

## Article Content

Three weeks ago I made a change to my setup that I did not expect to matter as much as it did.

I had been running Hermes Agent for about six weeks. Using it the way most people use it: opening a terminal, typing a question, getting an answer. Occasionally running a cron job. Mostly treating it like a smarter version of a chat interface with better memory than Claude's default.

It was useful. It was not transformational.

Then I connected it to my Obsidian vault.

The first session after the connection I asked Hermes something I would normally ask Claude: "What narrative themes have been building in my research notes over the last two weeks?" Claude would have asked me to paste the notes. Hermes opened my vault, read across 23 files, and came back with three patterns I had not consciously named yet. One of them became the angle for an article that week.

That is not a smarter chatbot. That is a different category of tool.

This article is the full build. Everything I changed, everything I connected, and what the system actually does now that it could not do before.

### Why Claude Alone Has a Ceiling

Claude is still the reasoning core of my entire operation. That has not changed. But Claude has a structural limitation that no amount of prompting fixes: every session starts cold.

You can work around this with Claude Projects. Upload context files, load your CLAUDE.md, seed the project with notes. That works well and I still run it that way for writing and research.

But Claude Projects is a manual context system. You decide what goes in. You decide when to update it. The knowledge it has is the knowledge you explicitly gave it.

Hermes connected to Obsidian is something different. The vault is live. Hermes reads, creates, and edits normal markdown notes that Obsidian already understands. When I capture something new via QuickAdd or the Telegram bot, it is in the vault immediately. When Hermes runs the next morning it is reading that capture without me doing anything. The memory updates itself.

That gap between a manually curated context system and a live-reading agent changes what the tool can actually do.

### The Setup: What Changed and What Did Not

The Obsidian vault structure stayed exactly the same. Five folders, same as before: 00-Inbox, 01-Sources, 02-Ideas, 03-Projects, 04-Claude. Nothing moved. The connection does not require you to reorganise anything.

Hermes Agent v0.14 shipped May 16, 2026 with a first-class Obsidian provider. One command wires it up.

****Setup****

> hermes memory setup --provider obsidian --path ~/path/to/your/vault hermes memory status

That is the entire memory connection. Hermes now reads and writes markdown files in that vault every session. The Obsidian Local REST API plugin on localhost:27123 gives programmatic read and write access during agent execution, not just at boot.

Install the Obsidian Local REST API plugin from the community plugins browser. Enable it. Hermes handles the rest.

Two things I configured immediately after the connection:

****Scoped access.**** The safe pattern is to give Hermes access to folders meant for agent context, not your entire vault by default. I created a dedicated 04-Claude/hermes/ folder and started the connection there. After verifying clean read and write behaviour over three days, I expanded it to the full vault. Do not skip the scoped testing phase.

****SOUL.md.**** This is the file that makes Hermes feel like it knows you rather than like a smart search tool running over your notes. SOUL.md defines the agent's identity, role, tone, standards, and boundaries. It is the equivalent of CLAUDE.md but for the agent layer.

Mine looks like this:

****SOUL.md Template****

> # SoulYou are my personal research partner.## Who I Am Based in Portugal. I am a researcher first. Before I look at what anyone is saying about a topic, I read the primary source. The paper. The on-chain data. The institutional filing. The governance forum post. Information that has already been filtered through too many layers is not information. It is noise with confidence.## How I Research I go to the source before I go to the commentary. I distrust anything that arrived to me already packaged as an insight. I want the raw data and I want to form the view myself. If something is already consensus on CT or in my feed, I am already late to it or it is wrong. The signal I value is the one nobody has processed yet.## What I Expect From You Read my vault before answering anything. If the answer requires something not in my notes, tell me what primary source would resolve it. Never point me to a summary when the original exists. If you are uncertain, say so at the start of the answer, not buried at the end after you have already misled me. Surface what I have not seen. Challenge what I think I know. Do not pad. Do not flatter. Start with the answer.## Hard Rules Primary sources over secondary sources. Always. Specific over general. Always. Honest uncertainty over confident guessing. Always.

Your persona lives in a markdown file. Your facts live in another markdown file. Your conversation history lives in a SQLite database. Each one is a thing you can read, edit, and delete with normal command-line tools, which means the memory layer is debuggable in a way that "just trust the LLM" memory systems are not.

### The Three Things That Actually Changed

****1. Research questions now return vault-aware answers****

Before the connection, asking Hermes a research question produced an answer from its training data plus whatever I had pasted into that session. Useful but bounded.

After the connection, the same question routes through my vault first. When I asked about narrative positioning in the RWA sector, Hermes read my existing thesis note, my signal log entries from the previous three weeks, and two source notes I had processed from institutional research papers. The output synthesised across all of them and flagged two contradictions between my current thesis and something I had saved six weeks earlier.

I had not told it to do any of that. It did it because the vault was there and the SOUL.md told it to read before answering.

****2. The morning brief is now genuinely surprising****

The automated morning brief existed before the Hermes connection. N8N triggered it at 6am, Claude read the last seven days of captures, the output landed in my Inbox.

I moved the morning brief to Hermes after the connection. The difference is that Hermes does not just read the last seven days. It reads the last seven days and connects them to everything else in the vault. The connections it surfaces now are cross-month, not just cross-week.

The cron job setup:

****Cron Instruction****

> /cron "Every weekday at 6am, read my full Obsidian vault.Produce a morning brief with four sections: 1. Connections: two non-obvious links between recent captures and older notes. Reference specific note titles. If the connection is obvious it does not qualify. 2. Narrative signals: any pattern in my research notes pointing to something building before CT notices it. 3. Contradiction: any recent capture that conflicts with a belief in my active thesis notes. Quote both. 4. One action: the single highest-leverage thing to focus on today based on everything in the [vault.Save](https://x.com//vault.Save)
> 
>  the brief to 00-Inbox/brief-{{date}}.md"

The "narrative signals" section is the one that changed my research operation most. It is specifically designed to catch what the previous Claude-only brief missed: patterns forming across weeks of captures that point toward a narrative worth positioning in before it surfaces on CT.

****3. Telegram access to the full vault from anywhere****

Hermes runs on my desktop. A Telegram bot connects to it so I can query the vault from my phone without being near my computer. Multi-surface access means I can talk to it from Telegram while it runs.

This sounds like a minor convenience. In practice it changed when and how I research. I am on a walk and something connects to a thesis I have been building. I used to voice-note it and hope I would process it later. Now I send a message to the Telegram bot: "Does this connect to anything in my RWA thesis notes?" Hermes reads the vault and comes back with whether it does, what it connects to, and what the connection implies.

The capture-to-intelligence gap collapsed. The idea enters the vault and immediately has access to everything the vault contains.

### The SOUL.md Detail Nobody Explains

Most guides to Hermes describe SOUL.md as a personality file. That framing undersells what it actually does.

SOUL.md is the instruction layer that governs how Hermes interprets everything it reads in your vault. Without it, Hermes reads your notes as a content library. With a well-written SOUL.md, it reads your notes through the lens of who you are and what you are trying to do.

The difference in output quality is significant. The same vault query with a generic SOUL.md produces a capable answer. With a specific SOUL.md it produces an answer that sounds like it came from inside your operation.

Three things that belong in SOUL.md that most people skip:

First, your current obsessions. Not your general interests. The specific questions you are working on right now. Mine currently includes the gap between on-chain signal and social recognition in crypto narratives. Hermes now flags anything in my vault that relates to that gap without me asking.

Second, how you want to be challenged. I told Hermes explicitly to surface contradictions between my current beliefs and my saved notes. This is the most valuable thing it does and it only does it because the SOUL.md instructs it to look for those gaps.

Third, what you never want. I do not want generic market commentary. I do not want recaps of things I already know. I do not want flattery before an answer. All three are in my SOUL.md and Hermes has not produced any of them since I added them.

### What Hermes Does That Claude Cannot

This is not an argument for replacing Claude with Hermes. They do different jobs.

Hermes was built to solve the memory gap. Its persistent memory spans sessions, platforms, and devices. Claude's intelligence is superior for deep reasoning, writing, and complex analysis. The right stack is both, each doing what it is best at.

Hermes does three things Claude cannot:

It operates autonomously on a schedule. The 6am brief runs without me. Claude Projects requires me to open a session.

It writes skill files when it solves hard problems. When the agent solves a task, it writes a reusable markdown skill file, stores the outcome in persistent memory, and adjusts its approach for next time. The agent I have after six weeks of connected operation is more capable than the one I started with because it has been learning from every session.

It routes different tasks to different models automatically. I use Claude Opus for deep reasoning and writing. I delegate research sweeps and data aggregation to cheaper models via OpenRouter. Each profile has its own config, memory, skills, sessions, and SOUL.md. They share nothing by default. I run a content profile and a research profile with different model routing for each.

### The Full Setup Sequence

****Install Hermes****

> curl -fsSL [https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh](https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh)
> 
>  | bash

****Write your SOUL.md.**** This takes 30 minutes and matters more than the technical setup. Use the template above. Fill every section with real specifics about your actual work. Vague SOUL.md files produce vague outputs.

****Connect to Obsidian****

> hermes memory setup --provider obsidian --path ~/path/to/your/vault hermes memory status

Install the Obsidian Local REST API plugin in Obsidian. Enable it. Test with a scoped folder before expanding to the full vault.

****Set up the Telegram bot.**** Search BotFather on Telegram. Create a new bot. Copy the token. Add it to your Hermes config. Test by sending a message and verifying Hermes reads your vault in the response.

****Configure the morning brief cron job.**** Use the cron prompt above. Run it manually the first time and read the output. Adjust the prompt based on what is useful and what is noise before automating.

****Back up to GitHub.**** Skills live in the Hermes skills directory as SKILL.md procedures. Run a daily backup to a private GitHub repository so your full Hermes configuration, memory, and skills travel with you if you change machines.

****Cron Instruction****

> /cron "Every day at midnight, commit and push all files in ~/.hermes/ to my private GitHub repository with today's date as the commit message"

### What Six Weeks of This Actually Produces

The first two weeks feel like setup and calibration. SOUL.md needs refinement. The vault is thin enough that cross-note connections are rare.

By week four the morning brief starts producing genuinely surprising output. Hermes has enough vault depth to find connections across weeks of captures rather than just within the current week.

By week six the skill file library has grown from zero to 23 entries. Every recurring workflow I have run more than twice has been written into a skill. The agent executes those workflows faster and more accurately each time because it is not re-figuring out the approach.

The compounding that I described in the Obsidian articles as something that happens over months is happening faster with Hermes because Hermes writes to the vault as well as reads from it. Every session adds to the context layer.

The gap between this setup and a standard Claude chat session is not a matter of degree. It is a different category of tool doing a different category of job.

Follow [@damidefi](https://x.com/@damidefi)

 on X for daily Claude AI tools, crypto analysis, and the full journey to 100K. Bookmark this. Share it with one person still treating their AI assistant like a chatbot.

> Original article: https://x.com/i/article/2060307282269802496

