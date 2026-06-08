---
title: "17 prompts that make Hermes run while you sleep (copy-paste inside)"
source: "https://x.com/Mnilax/status/2063697740526399833"
author:
  - "[[@Mnilax]]"
published: 2026-06-08
created: 2026-06-08
description: "In February 2026, Nous Research released Hermes Agent: an open-source, self-hosted agent that doesn't live inside an IDE and doesn't forget ..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/HKOnPerWsAAgxaR?format=jpg&name=large)

In February 2026, Nous Research released Hermes Agent: an open-source, self-hosted agent that doesn't live inside an IDE and doesn't forget when the tab closes. It runs as a daemon on your own box, keeps memory across sessions, takes scheduled jobs in plain language, and writes its own reusable skills from experience.

**It became one of the fastest-moving open-source agents of the year: a runaway GitHub star count and one of the most-used agents on OpenRouter. It recently went terminal-native with a new TUI.**

Then I ran it as my own standing infrastructure for 5 weeks, on a $5 VPS, with Claude as the model underneath.

The tool is real. But a blank Hermes install does nothing on its own. It's a runtime, not a workflow. What turns it from "interesting repo i starred" into "thing that did 3 hours of my work overnight" is the prompts you give it on day one, and almost nobody shares those.

So here are mine. Below: the 17 prompts and config lines i actually paste, the moments that earned the sharpest ones their place, and the 3 mistakes i made first so you can skip them.

If you want to skip the explanations and just paste, the full set is at the end.

# Why this matters

Almost every AI tool you use is session-based. Claude Code, Cursor, the chat window: you open it, work, close it, and the context dies with the session. That's the right design for what they do, and Claude Code is still the better tool for coding inside a single project.

But a whole class of work isn't session-shaped: the brief that should be ready before you wake, the build that should be watched whether you're looking or not, the inbox filling while you're heads-down. Session tools can't hold it, because they aren't running when it happens.

That's the gap Hermes fills. **It's persistent (memory survives the session), scheduled (it acts on a clock, not your attention), and reachable (Telegram, Discord, Slack, email, not a tab you forgot).** The model thinks. Hermes keeps it pointed at your work when you're not there.

![Image](https://pbs.twimg.com/media/HKOnXoEXEAAezmm?format=png&name=large)

A blank install gives you all of that capability and zero of the workflow. The prompts below are the workflow.

# The setup: three things before any prompt runs

Before any prompt does anything, three things have to be true. Two are config commands (recipes 15 and 16 below); the third is just where you run it. Pulled up front so the rest makes sense:

- **A model with real context.** A small local model drops tool calls mid-task on multi-step jobs. A frontier model has the headroom. Claude clears it easily.
- **A backend that doesn't bill you to sit idle.** A serverless backend hibernates between jobs so a 24/7 agent isn't a 24/7 invoice.
- **A persistent home.** Your laptop is not it. A $5 VPS is, because the lid closing shouldn't kill your 3am job.

![Image](https://pbs.twimg.com/media/HKOnkrvWYAAG3PZ?format=png&name=large)

Get those three set and the 17 prompts below have something to run on. Skip them and recipe 1 dies the first night.

# The 17 prompts I actually run

Some of these earned their place with a specific failure. For those i'll show the moment; for the rest, just what it does and the prompt.

## 1\. The 7am brief instead of a notifications pile

The first job every persistent agent should own is the thing you do half-asleep before real work starts.

```text
every weekday at 7am, pull my unread GitHub notifications and the open PRs across my repos, summarize what changed and what's blocking each one, then send it to me on Telegram as 3-5 bullets
```

**The moment:** I was spending the first 35 minutes of every morning doing this by hand across 6 repos, before a single line of real work. Five days a week, that's about 3 hours a week of triage i was doing at my most expensive time of day, on autopilot. Now it's waiting in Telegram before i sit down, and the 35 minutes is gone.

## 2\. The repo watch that only speaks when it matters

A monitor that pings you for everything gets muted in a day. The skill is in the silence.

```text
watch [org/repo]. stay silent unless CI goes red or a new issue opens with the label "bug". when either happens, message me the failing job name or the issue body, and nothing else
```

**The moment:** a red CI on a Friday deploy i didn't see until Monday, three days of broken main behind a ten-minute fix. now it pings in ~90 sec and stays silent otherwise.

## 3\. Inbox triage across every channel you own

Hermes connects to Telegram, Discord, Slack, WhatsApp, Signal and email from one process, which means triage can finally happen in one place.

```text
every hour, check my connected channels, group new messages by sender and urgency, auto-archive newsletters and notifications, and only escalate the ones that mention a deadline, a person waiting on me, or money
```

**The moment:** Roughly 120 messages a day across six platforms, and a client DM that sat unanswered for two days because it was buried under Discord noise. The escalation rule, deadline, a person waiting, or money, is the whole prompt. Everything else gets archived and i never see it.

![Image](https://pbs.twimg.com/media/HKOoTl8W4AA7B35?format=jpg&name=large)

## 4\. The Friday research digest that dedupes itself

```text
every Friday at 6pm, search for new releases and serious discussion in [your topic], dedupe against what you sent me last week, and deliver a 5-bullet digest with links to Telegram
```

**Effect:** ~2 hr of Friday feed-scrolling becomes a 5-bullet read. the dedupe clause is the trick: it remembers last week, so what lands is genuinely new.

## 5\. "Make sense of this repo" in one message

```text
clone [repo url], summarize the architecture in 5 bullets, find the main entrypoint and the single riskiest file, then draft a clean PR workflow for contributing to it
```

**Effect:** the cold-start day on an unfamiliar codebase compressed to a ~4 min map good enough to start from. not a substitute for understanding the code, a substitute for not knowing where anything is.

## 6\. The long task you hand off at night

```text
research [question], compare the top 3 options on price, limits, and lock-in, and send me the result when it's done tonight. don't wait on me for follow-ups, make reasonable assumptions and list them at the top
```

**Effect:** the "don't wait on me, make assumptions and list them" clause is what turns a 2am stall into a result waiting by morning.

## 7\. Watch competitors' changelogs, not your feeds

```text
every day at 9am, check the changelog and pricing pages of [product A], [product B], [product C], and only message me when something actually changed: a new feature, a price move, a deprecation. quote the exact diff
```

**Effect:** you hear about a competitor's move the morning it ships, not when a customer brings it up.

## 8\. The nightly review of your own code

```text
every night at 11pm, look at today's commits across my repos and flag anything risky: a TODO left in, a console.log shipped, a function over 80 lines, a changed path with no test. summarize as a short list i read with coffee
```

**The moment:** I shipped a **console.log** with a token in it and didn't notice for a week. The nightly pass now catches that class of thing before i'm awake, and the list is usually three lines, sometimes zero. It's the cheapest code review i run.

## 9\. The stand-up it writes for you

```text
every weekday at 9:55am, assemble my stand-up: what closed since yesterday, what's in progress, what's blocked, pulled from my repos and connected channels, formatted as three short bullets
```

**Effect:** you walk into stand-up with it already written, instead of reconstructing yesterday from memory.

## 10\. A radar for your own name

```text
once a day, search for new mentions of [my project or handle] across the web and the platforms i'm on, ignore the praise, and escalate bug reports, complaints, and anyone asking a question i haven't answered
```

**Effect:** the angry user and the quiet bug report find you, instead of you finding them three days late.

## 11\. Turn a 90-minute talk into 5 bullets

```text
take [video or podcast url], pull the transcript, and give me the argument in 5 bullets with timestamps for the parts worth watching in full. skip the intro and the sponsor read
```

**Effect:** the talk everyone's quoting, read in two minutes, with timestamps for the parts actually worth your 90.

## 12\. "Explain this error and propose the fix"

```text
here's a stack trace: [paste]. search my repo for the cause, explain what's actually failing in two sentences, and draft the smallest patch that fixes it without touching anything else
```

**The moment:** A production stack trace i'd normally lose an hour bisecting. I handed it over and got the failing line, a two-sentence cause, and a three-line patch back before i'd finished reading the trace myself. I still review the patch. I just don't hunt for the needle anymore.

## 13\. Inbox-zero, but it drafts the replies

```text
for routine emails (scheduling, intros, status pings), draft a reply in my voice and hold it in a queue for my one-tap approval. never send anything on your own. escalate anything that needs a real decision
```

**Effect:** the dozen "sounds good, Thursday works" replies are written and waiting for your yes, not your attention. Nothing leaves without your tap.

## 14\. An on-call agent that diagnoses before it pages you

```text
when a monitoring alert fires, don't just forward it. pull the last 50 lines of the relevant logs, check what deployed recently, and send me a one-paragraph first guess at the cause alongside the raw alert
```

**Effect:** the 3am page arrives with a hypothesis attached, not just a red light. A subagent with its own terminal does the log pull, so the diagnosis costs you nothing.

## 15\. Point it at Claude (one line, no lock-in)

```text
hermes config set model anthropic/claude-opus-4.8
```

**The moment:** I started on a cheap local model to keep costs near zero. It dropped tool calls halfway through any multi-step job, because it couldn't hold the context a real workflow needs. Recipes 1 through 14 all quietly failed in ways that were hard to debug.

Swapping the model to Claude in one line fixed every one of them at once, because the failures were never the prompts, they were the model underneath. You can swap back with the same command, there's no lock-in.

## 16\. Serverless backend so idle costs almost nothing

```text
hermes config set terminal.backend daytona
```

**The moment:** My first month ran on an always-on backend, and the idle compute, the 23 hours a day it sat doing nothing between jobs, quietly added up to more than the work itself cost. A serverless backend hibernates when idle and wakes on demand, which took the standing cost of a 24/7 agent down to pennies between jobs.

## 17\. Turn a good run into a permanent skill

```text
that worked. save it as a reusable skill called "morning-brief" so you run it the same way next time without me re-explaining the format
```

**The moment:** I re-explained the exact format of my morning brief four times before it occurred to me to make it permanent. Hermes writes its own SKILL.md from the run and reuses it after that, so the fifth time i just said "run the morning brief" and it knew. This is the compounding part: every prompt that works once becomes a capability you never type again.

![Image](https://pbs.twimg.com/media/HKOwtn2XEAAnVUX?format=png&name=large)

# The numbers

I logged the same week of standing work twice: once done by hand the way i always had, once handed to Hermes running these prompts. Same week, same tasks.

![Image](https://pbs.twimg.com/media/HKOw2miWEAARVbm?format=png&name=large)

**Unattended** = ran on schedule or async with no input from me after the initial prompt.

The headline isn't the hours saved, though there are several. It's that none of this work happened at a time i had to be awake for. The brief runs at 7 whether i'm up or not. The repo is watched on a weekend. The research lands Friday night. The scarce resource was never the time, it was my attention, and the point of a persistent agent is that the work stops competing for it.

## What didn't work

The first two weeks were mostly me learning what a prompt to a standing agent has to contain that a prompt to a chat window doesn't.

1. **Vague schedules.** "Send me updates on my repos" produced a firehose. With no escalation rule, the agent reported everything, and a report you can't skim is a report you mute. Every scheduled prompt now carries an explicit "only tell me when X" clause.
2. **No token budget on hourly jobs.** A chatty hourly triage quietly spent more in a week than i'd planned for the month, because nothing capped it. Persistent plus unbounded is how you get a surprise bill. Scope the cadence to what you'll actually read, and check spend in the first week.
3. **A cheap model to save money.** Covered in recipe 15. Small local models drop tool calls mid-task and fail in ways that look like prompt bugs. The model is not the place to economize.

## Where this bites

Three honest tradeoffs, because self-hosting an always-on agent isn't free of strings.

**You're the admin now.** Updates, uptime, and the permission model are yours. An agent that remembers everything and acts on your machine has to be kept on a tighter leash than a chatbot that forgets when the tab closes.

**It runs shell commands on your behalf.** Set a Docker or serverless backend with isolation before you give it real access, not after it's already touching your files. The sandbox is a day-one decision, not a later one.

**The hype is loud.** Star counts swing wildly between blog posts and a lot of the "deployment guide" content is affiliate noise. Judge it by what it does for your week, not by the leaderboard.

# The full set (copy-paste ready)

Two config lines set once, then fifteen prompts pasted into the agent. That's the 17: fourteen jobs, plus the one that turns any good run into a permanent skill.

```bash
# config (set once)
hermes config set model anthropic/claude-opus-4.8
hermes config set terminal.backend daytona
```

```text
# 1. morning brief
every weekday at 7am, pull my unread GitHub notifications and open PRs, summarize what changed and what's blocking each, send to Telegram as 3-5 bullets

# 2. repo watch
watch [org/repo]. stay silent unless CI goes red or a new issue opens with label "bug". then message me the failing job name or the issue body, nothing else

# 3. inbox triage
every hour, check my connected channels, group by sender and urgency, auto-archive newsletters, only escalate ones mentioning a deadline, a person waiting on me, or money

# 4. research digest
every Friday at 6pm, search new releases and serious discussion in [topic], dedupe against last week, deliver a 5-bullet digest with links to Telegram

# 5. repo cold-start
clone [repo url], summarize the architecture in 5 bullets, find the main entrypoint and the single riskiest file, draft a clean PR workflow for contributing

# 6. async research
research [question], compare top 3 options on price, limits, lock-in, send the result tonight when done. don't wait on me, make reasonable assumptions and list them at the top

# 7. competitor watch
every day at 9am, check the changelog and pricing pages of [product A], [product B], only message me when something changed: a feature, a price move, a deprecation. quote the diff

# 8. nightly code review
every night at 11pm, look at today's commits and flag anything risky: a TODO left in, a console.log shipped, a function over 80 lines, a changed path with no test. short list

# 9. stand-up
every weekday at 9:55am, assemble my stand-up from my repos and channels: what closed, what's in progress, what's blocked, as three short bullets

# 10. mention radar
once a day, search for new mentions of [my project or handle] across the web and my platforms, ignore praise, escalate bug reports, complaints, and unanswered questions

# 11. talk to bullets
take [video or podcast url], pull the transcript, give me the argument in 5 bullets with timestamps for the parts worth watching. skip the intro and sponsor read

# 12. explain this error
here's a stack trace: [paste]. search my repo for the cause, explain what's failing in two sentences, draft the smallest patch that fixes it without touching anything else

# 13. inbox-zero drafts
for routine emails (scheduling, intros, status), draft a reply in my voice and hold it in a queue for my approval. never send on your own. escalate anything needing a real decision

# 14. on-call diagnosis
when a monitoring alert fires, pull the last 50 lines of the relevant logs, check what deployed recently, and send me a one-paragraph first guess at the cause with the raw alert

# 17. make it permanent (after any good run)
that worked. save it as a reusable skill called "[name]" so you run it the same way next time without me re-explaining
```

## How to install

One command for the runtime, then run the setup wizard:

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
hermes setup
```

**hermes setup** walks you through connecting Telegram, Discord, Slack, WhatsApp, Signal or Email and runs it as a service. Then paste the config and prompts above.

# The mental model

A prompt to a chat window is a question. A prompt to a persistent agent is a job description: it needs a trigger (a schedule or an event), a body (what to do), and an escalation rule (when to bother you). Drop any of the three and the prompt either never fires, does the wrong thing, or buries you in noise.

![Image](https://pbs.twimg.com/media/HKO0g8GW8AA09yl?format=png&name=large)

That's the whole shift. You stop thinking "what do i want to ask" and start thinking "what standing work do i want off my plate, and on what terms do i want to hear about it."

Your week isn't my week. If you don't live across six chat platforms, skip recipe 3. If you never touch unfamiliar repos, skip recipe 5. **Paste the 17, keep the ones that map to work you actually repeat, and delete the rest.** Three recipes tuned to your real routine beat seventeen you set up once and never read.

# Closing

Nous Research shipped a runtime that a lot of people starred and a lot of people use. Most of them are still staring at a blank install, because the repo gives you the engine and not the route.

The engine isn't the point. The point is that the brief is ready at 7, the build watches itself over the weekend, and the research lands while you sleep, none of it competing for your attention because none of it needs you in the loop.

17 prompts. 5 weeks on a $5 VPS. Three hours of my week that no longer happen while i'm awake.

If this saved you a morning, repost it. Part 2 next week: the cron schedules and self-written skills that survived a month, and the three i deleted.

> **The work runs. You don't have to be awake.** bookmark -> paste the prompts into a fresh install tonight repost -> if it saved you a morning of triage more: [t.me/aiXmnimi](https://t.me/aiXmnimi)