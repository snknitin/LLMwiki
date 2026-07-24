---
title: "The shared log (Brian)"
author: "Jason Zhou"
username: "@jasonzhou1993"
date: "2026-06-19"
tweet_url: "https://x.com/jasonzhou1993/status/2067937943545897143"
tweet_type: "original"
likes: 1176
retweets: 146
replies: 21
bookmarks: 2952
views: 504805
has_media: false
extraction_quality: full
article_id: "2067919620452032512"
tags: ["twitter-bookmark", "claude", "agents"]
---

# The shared log (Brian)

> **Source:** [@jasonzhou1993](https://x.com/jasonzhou1993) · 2026-06-19 · 👍 1176 · 💬 21 · 🔖 2952 · 👁 504805

> 🔗 [View tweet on X](https://x.com/jasonzhou1993/status/2067937943545897143)

## Article Content

![](https://pbs.twimg.com/amplify_video_thumb/2067939153476743168/img/FjAi3EiHnZR3yoAH.jpg)

At around 1:00 AM yesterday, a bunch of PRs started landing in our codebase. Not because our team was working unusually late.

They came from different agent loops: agents finding issues, picking up work, verifying changes, and opening PRs without someone manually prompting each one.

We also have an SEO loop that produces 20–40 high-quality pages every day at [@SuperDesignDev](https://x.com/@SuperDesignDev)

 . Those pages are already driving traffic to the company without me looking at it.

https://x.com/jasonzhou1993/article/2067937943545897143/media/2067933163033391105

This is the shift I want to talk about: ****loop engineering****:

> Stop treating agents as something you prompt manually, and start designing systems that can decide what to work on, execute, verify results, and improve over time.

A good loop does not just generate output. It creates a feedback system that gets more useful as it runs.

I want explains how we set things up in a way that compound

### An agent harness has two nested layers

https://x.com/jasonzhou1993/article/2067937943545897143/media/2067925720802988032

The term “agent harness” can feel vague because it covers almost everything that is not the model itself.

But I find it useful to split it into two layers: ****agent loop + outer loop****.

****1. The agent loop: help an agent complete a given task well****

The inner loop is the familiar agent runtime; Claude code, codex, etc.

You give an agent a task. It reads the relevant context, uses tools, performs work, checks the result, and continues until the task is complete. This is where most agent optimisation happens today: Better context and instructions, Skills and tool definitions, Task decomposition, Tool use

The question this layer tries to answer is:

> Given this task, how can we help the agent complete it reliably?

But it still depends on somebody deciding that this is the task worth doing. That is where the outer loop comes in.

****2. The outer loop: decide what should happen next****

The outer loop sits around the agent runtime. It is responsible for things like:

- What should trigger the agent
- What state should be preserved across sessions
- How different agents share information
- How outcomes are monitored
- How the system gets better over time

The question this layer tries to answer is:

> What should the agent work on next, and how can the system learn from the result?

This is the part where we call ****loop engineering****. A loop engineer is not just writing prompts for an agent. They are designing an environment where agents can continuously:

1. Notice something worth working on
2. Investigate it
3. Take action
4. Record what happened
5. Verify whether it worked
6. Use that result to decide what to do next

The agent loop helps an agent execute. The outer loop helps the system decide, learn, and compound.

### Loops compound when they share artifacts & logs

https://x.com/jasonzhou1993/article/2067937943545897143/media/2067925498689396736

One useful loop is great. But the really interesting part starts when multiple loops can learn from each other.

At our company, we have loops across areas like: Support, SEO, Product growth, Ads. Each of these loops has its own trigger, workflow, tools, and goals.

But they write to a ****shared artifact system.****

For example, the support loop might notice that five people have asked how to export something.

It creates a signal: ****/export-too-hidden.md****

```markdown
kind: signal
title: "Export gated behind Pro is a recurring friction / conversion point"
description: "Pricing friction, spawned (free, freq 5): users hit the export-is-Pro-only paywall (~769 hits/580 users), the cleanest Free->Pro trigger. Upgrade gate shipped."
category: friction
frequency: 6
segments: [free]
tags: [feedback, friction, pricing, export, conversion]

-----

# Detail
...

# Timeline
...
```

At the same time, the SEO loop might notice that a page is getting strong traffic but poor conversion.

It creates another signal: ****/conversion-gap-ai-wireframe-generator.md****

Then the product-growth loop can read both signals alongside product analytics. It might conclude that export is a bigger issue than the original analytics data suggested. Or it might identify that people arriving through a particular SEO page are hitting the same product friction that support is seeing.

The ads loop may discover that a keyword has a strong click-through rate but no supporting organic content. That can feed directly into the SEO loop.

This is what makes the system compound. The loops are no longer isolated automations.

They are operating from a shared Knowledge base of what the business is learning.

## The shared log (Brian)

https://x.com/jasonzhou1993/article/2067937943545897143/media/2067926504466706432

The artifact system is the shared memory layer that makes loops compound. I normally separate it into three parts, For example:

```markdown
/artifacts
  /signals
  /tickets
  /tasks
  /docs

/loops
  /support
    README.md

LOG.md
```

### 1. Artifacts

Artifacts are durable pieces of work or knowledge. They are the objects that loops read and write. Examples include signals,  docs.

Each artifact type should have:

- A clear definition what is and is NOT this type
- Consistent schema
- Lifecycle rules

For example, a signal is not just a random note. It is a structured record of something worth paying attention to.

```markdown
---
type: signal
status: open
priority: high
sources:
  - support-ticket-124
  - support-ticket-131
created_at: 2026-06-19
---

# Export is too difficult to discover

## Observation
Multiple users have asked how to export their work.

## Evidence
Five related support tickets in the past week.

## Possible causes
- Export action is visually hidden
- Users expect export in another part of the UI
- Export terminology is unclear

## Suggested next action
Run a product investigation and test a clearer export entry point.

## Timeline
Log what happened to this artifact overtime
```

The useful thing about artifacts is that they are not trapped inside one agent session. Any loop can read, update, link to, or act on them later.

### 2. Loop contracts

Every loop should have a contract. This is usually a README inside that loop’s domain folder.

For example: support-loop/README.md. The contract explains:

- The goal of the loop
- The workflow it should follow
- Backlog queue
- A timeline of important events

For example:

```markdown
---
kind: domain
domain: support
status: active
goal: Triage the support inbox, reply or escalate, and surface product or growth signals.
cadence: Hourly
tags: [support, domain]
---

# Support — inbox triage

This domain owns the support-triage workflow.

Its outputs live in the global artifact stores:

- One record per conversation → `/tickets`
- Deduplicated feedback and friction themes → `/signals`
- Engineering bugs → `/tasks`
- Run history → this file’s `## Timeline`

## Trigger

Runs hourly.

Prompt:

"Pull tickets from the past hour. Triage and handle them according to the support-triage skill."

## Workflow

1. Fetch new and newly active conversations.
2. Review tickets that need follow-up.
3. Investigate issues with the available tools.
4. Reply directly when confidence and permissions are sufficient.
5. Draft a response when human approval is required.
6. Create or update the ticket artifact.
7. Roll recurring friction into an existing signal rather than creating duplicates.
8. Create a task for clear engineering bugs.
9. Add one concise line to the timeline.

## Dedupe rules

- Returning conversation: match the external conversation ID.
- Returning customer: match email.
- Recurring feedback: increment the frequency of an existing signal.
- Never create a new signal when the theme already exists.

## Timeline

2026-06-19 — Triaged 4 new conversations. Resolved 2. Created 1 ticket,
updated the export-discoverability signal, and created 1 engineering task.
```

Every new agent session can read this contract and understand what the loop is trying to achieve.

### 3. Global logs

Finally, keep a global LOGS.md or work log.

This is useful because work is not always neatly contained within a single loop. You might manually investigate an idea, review an agent’s output, make a decision, and ask another agent to act on it. The global log captures that cross-domain context.

A simple pattern works well:

- Before major work, agents read the latest five to ten entries.
- After major work, agents add a concise summary.
- Entries should link to relevant artifacts.

For example:

```markdown
## 2026-06-19 · Support pattern found: export discoverability is now a product issue · #support #signal #product 
What: Hourly triage found three more users asking how to export their work. Updated the existing `export-too-hidden` signal rather than creating duplicates; frequency is now 8. Created an ENG task to test a clearer export entry point. Two customer replies are awaiting approval. 
Refs: [[FB-12 export-too-hidden]], [[ENG-41 improve-export-discoverability]], [[SUP-103]], [[SUP-119]], [[SUP-124]].
```

This gives every loop a lightweight way to understand what has been happening across the business.

### Let AI run business

At [@SuperDesignDev](https://x.com/@SuperDesignDev)

 our team is setting up a network of loops to scale the business in full AI native way. Together, they form an operating system for continuous improvement.

That is loop engineering.

And the teams that get good at it will not just move faster because they use agents. They will compound faster because their systems learn while they sleep.

I have put together a Loop Engineer Setup template that captures many of the practices we tried: artifact structures, loop contracts, logs, skills, and a codebase harness checklist.

You can copy it into your own repository and use Claude Code or Codex to scaffold your first loop: [https://github.com/JayZeeDesign/loop-engineer-template](https://github.com/JayZeeDesign/loop-engineer-template)

We will continusly share our experiments on running [@SuperDesignDev](https://x.com/@SuperDesignDev)

 AI natively, follow up if you interested

> 📄 Original article URL: https://x.com/i/article/2067919620452032512

---

## Commentary from Other Bookmarks

### @jasonzhou1993 (Jason Zhou) — 2026-06-22

> Loop Engineering is getting hype now.
> But not many talks about how to actually do it
> 
> So I open-sourced the template my team uses to build agent loops:
> - a shared artifact / knowledge layer
> - logging, verification
> - and a codebase harness so work compounds across runs
> 
> Plus a 20-min deep dive on how to think about it and set it up for real: https://github.com/AI-Builder-Club/loop-engineer-template
> 
> Copy the template. Adapt it to your own loops.

[→ View quote tweet](https://x.com/jasonzhou1993/status/2069002271216787464)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

