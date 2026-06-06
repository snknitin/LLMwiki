---
title: "how /goal works in Hermes Agent"
author: "Shann³"
username: "@shannholmberg"
date: "2026-05-23"
tweet_url: "https://x.com/shannholmberg/status/2058178662818865342"
tweet_type: "original"
likes: 227
retweets: 22
replies: 20
bookmarks: 248
views: 21349
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# how /goal works in Hermes Agent

> **Source:** [@shannholmberg](https://x.com/shannholmberg) · 2026-05-23 · 👍 227 · 💬 20 · 🔖 248 · 👁 21349

> 🔗 [View tweet on X](https://x.com/shannholmberg/status/2058178662818865342)

## Tweet Content

how /goal works in Hermes Agent

you give the agent a standing goal. after every turn, a judge model checks if it's complete.

if not, Hermes auto-continues with the judge's reasoning. The loop runs until the goal is met, you pause, or the turn token budget is exhausted.

this is when to use /goal:

> the task has clear "done" criteria
> you'd otherwise type "keep going" 3+ times
> the agent can verify its own progress

skip /goal when:

> a single turn does the job
> you want to steer every iteration
> your taste IS the deliverable

what I've used it for:

> "/goal: go over our 10,000+ sales call transcripts and find insights + learnings, write up themes with supporting quotes"

more AI marketing use cases I'm testing:

> "/goal: draft 10 SEO blogs targeting [keyword cluster] and queue them for human review in our CMS"
> "/goal: enrich every lead in this spreadsheet with company size, recent funding, tech stack, and recent X activity until all 200 rows are filled"
> "/goal: take this article, atomize into platform-specific posts for LinkedIn, X, Threads, and Bluesky, queue them for tomorrow's review"
> "/goal: pull analytics from GA, Search Console, and HubSpot, identify what worked last week, ship the weekly marketing report to Slack"

how it works:

> 1. you set /goal <objective>
> 2. Hermes does the first turn
> 3. a judge model reviews and returns done or continue
> 4. if continue, Hermes auto-fires the next turn with the judge's reasoning
> 5. loop runs until done, paused, cleared, or turn budget (default 20) hits

/subgoal lets you append criteria mid-loop without resetting. "fix the failing tests" → mid-run → "/subgoal also add a regression test". the judge waits until both are done.

goal state lives in the session db, so /resume picks up where you left off.

works on every surface: CLI, telegram, discord, slack, signal, whatsapp, sms, imessage, webhook, API

## Media

![](https://pbs.twimg.com/media/HJAelgTaYAAxlWp.jpg)

---

## Commentary from Other Bookmarks

### @shannholmberg (Shann³) — 2026-05-24

> /goal is the simplest way to get your Hermes Agent running autonomously
> 
> here's how it works:
> 
> you give the agent a standing goal. after every turn, a judge model checks if it's complete. if not, Hermes auto-continues with the judge's reasoning. the loop runs until the goal is met, you pause it, or the turn token budget runs out.
> 
> this means your agent can work through multi-step tasks without you babysitting every action.
> 
> I'm testing two ways to structure this:
> 
> > multi-agent kanban: each specialist agent picks up tasks from a shared board and works toward the overall goal
> > single agent with subgoals: one agent breaks down the main goal into smaller subgoals and executes them in sequence
> 
> both work, but kanban is better for parallel workflows across different domains. subgoals work better for linear processes where each step depends on the last.
> 
> my rule for what to automate with /goal: if you don't need to be in the loop for taste or judgment, it's a good candidate.
> 
> examples that work well:
> 
> > data collection and formatting
> > recurring research reports
> > monitoring and alerting workflows
> > file organization and cleanup
> > CRM updates from call transcripts
> 
> examples that don't work:
> 
> > creative copywriting that needs your voice
> > strategic decisions with multiple valid paths
> > client-facing content that requires approval
> 
> visualized how /goal runs below.

[→ View quote tweet](https://x.com/shannholmberg/status/2058637557030850568)

![](https://pbs.twimg.com/media/HJG_8oebUAAKK22.jpg)

