---
title: "The difference between a disposable chatbot and an agent that compounds is about 30 minutes of setup..."
author: "Tom"
username: "@tomcrawshaw01"
date: "2026-07-27"
tweet_url: "https://x.com/tomcrawshaw01/status/2081729327541227555"
tweet_type: "original"
likes: 417
retweets: 39
replies: 12
bookmarks: 1184
views: 51228
has_media: false
extraction_quality: full
article_id: "2081729322088611841"
tags: ["twitter-bookmark", "obsidian", "agents"]
---

# The difference between a disposable chatbot and an agent that compounds is about 30 minutes of setup...

> **Source:** [@tomcrawshaw01](https://x.com/tomcrawshaw01) · 2026-07-27 · 👍 417 · 💬 12 · 🔖 1184 · 👁 51228

> 🔗 [View tweet on X](https://x.com/tomcrawshaw01/status/2081729327541227555)

## Article Content

The difference between a disposable chatbot and an agent that compounds is about 30 minutes of setup, and almost nobody shows you how.

This article is based on my full video walkthrough. Watch it here: [https://youtu.be/MFi3RUGzwtM](https://youtu.be/MFi3RUGzwtM)

### Most people install Hermes and stop there

You got it running, connected it to Telegram, asked it a few things. And it works. You could use it exactly like that and I'd still argue it's ahead of OpenClaw and most agents out there.

But if that's all you've done, you're using a fraction of what it can do.

You re-explain your business every session. You re-teach the same process every week. You close the tab and tomorrow you're talking to a stranger again.

That's how I ran mine for weeks, until I set up the two features that change what the agent actually is: memory and skills.

### Two small files remember everything you'd otherwise repeat

Memory lives in two plain text files Hermes manages for you.

[MEMORY.md](http://MEMORY.md)

 is what it's picked up about your setup, your file structure, the lessons from past work.

[USER.md](http://USER.md)

 is who you are. Your role, your preferences, your writing style, what to steer clear of. Mine even holds the persona I gave my agent, a classic northern British lad called Dave, because if I'm cloning myself in AI I may as well commit.

Both files get read at the start of every session, which is why they're deliberately small. Think sticky notes, not a journal.

When Hermes picks up a useful correction, it saves it and shows you a quick memory-updated message. You can open the files and edit anything, ask it to interview you to build a solid base, or turn on approval mode so it asks before changing anything.

### Feed it too much memory and your agent gets worse

More memory does not mean a smarter agent.

A bloated memory file makes the agent worse, because those files get injected into every session and every line costs tokens and attention.

Hermes knows this. When the files get full it doesn't pile more in, it forces itself to consolidate and keep only what matters.

Your job is the same. Review them now and then, and keep them lean.

### Skills turn a process you did once into a command you run forever

Memory helps Hermes remember information. Skills teach it how to do things.

A skill is just a repeatable process Hermes saves and reuses instead of figuring it out from scratch every time. How you answer a customer query, how you qualify a lead, how you build a weekly report.

Once a process works, you run /learn and it becomes a reusable skill. Build them from your own documents and past tasks, install community ones, or tweak the defaults Hermes ships with.

You can also chain several skills into a single command, or spin off sub-agents that split a bigger job across a small team working in parallel, instead of one agent grinding through every phase in a line.

One warning from experience: a skill is only as good as the process you teach it. If the process is messy, Hermes repeats the mess. Your V1 skill will change as you use it, and that's the point.

### One cron job makes your agent show up to work without you

Once a skill works, you can put it on a schedule with cron, and Hermes runs it automatically in the background.

This is why I run mine on a VPS. It runs 24/7, so when my laptop's closed the agent isn't. Not the only way to run Hermes, there's a desktop app now too, but 24/7 is the point.

Skills are where you stop giving Hermes more information and start giving it new capabilities it keeps using.

### It checks its own work before you ever see it

The feature that made me trust automating any of this: self-verification.

Before Hermes shows me anything, it checks its output against my own rules. If a hook doesn't carry a real number, a name, or a concrete example, it fixes it or bins it. It's judging its own work, so I don't wake up to filler.

And behind the scenes, the Curator keeps your skill library clean by quietly archiving the ones you've stopped using. If you have keepers you only need every few weeks, pin them so they never get swept.

### Wednesday, 9pm: what my agent does while I'm still at dinner

Let me show you the whole thing working, because this is where memory, skills, cron, and self-checking come together.

Every mentorship call I run gets recorded and transcribed through Granola. I've already got a written playbook for turning those calls into short talking-head reels.

The old way: me, manually mining a transcript for ideas, drafting hooks, checking each one against my recording rules.

The new way: thirty minutes after my Wednesday call ends, Hermes pulls the newest transcript, mines it with my five-point extract, drafts three talk cards in my template (a spoken hook, then Proof, Tension, and Close as bullets), verifies each one against my rules, appends the keepers to my notes file, and messages me the hooks so I can pick one from my phone.

The first cron job it set up loaded the wrong skills, and I only caught it because I asked for a summary of what it had created. Ask for the summary. Check its work once, then let it run.

### The journey timeline is the proof it's working

If you want to see the compounding with your own eyes, run /journey.

It shows a timeline of every skill Hermes has created, every memory file it's updated, and every cron job running, filling in over weeks of use.

That's the difference in one screen. Not a smarter chatbot. An agent that's measurably better this month than last month because you've been using it.

And every week you leave it unset up is another week of re-explaining yourself to a stranger.

### Set up the two files and one cron job this week

Start with the built-in memory and keep it lean. Teach it one process you actually repeat, turn it into a skill with /learn, and pin your best skills so the Curator never touches them.

Add a bigger knowledge system later, only when you actually need it. I point mine at an Obsidian vault for SOPs and client notes, and providers like Honcho exist if you want more, but the two files are the foundation.

The full build, including the two exact prompts I used, is in the video: [https://youtu.be/MFi3RUGzwtM](https://youtu.be/MFi3RUGzwtM)

### There's no secret setting. There's a setup

Memory gives it context. Skills give it capability. Cron makes it show up to work.

Stop repeating yourself, and Hermes starts getting better the more you use it.

> 📄 Original article URL: https://x.com/i/article/2081729322088611841

