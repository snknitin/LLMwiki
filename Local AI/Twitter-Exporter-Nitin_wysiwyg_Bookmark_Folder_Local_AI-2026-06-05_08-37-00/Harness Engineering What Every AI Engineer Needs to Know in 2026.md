---
title: "Harness Engineering: What Every AI Engineer Needs to Know in 2026"
source: "https://x.com/sairahul1/status/2063544956158185927"
author:
  - "[[@sairahul1]]"
published: 2026-06-07
created: 2026-06-08
description: "In February 2026, a small OpenAI team shipped 1 million lines of production code.They didn't write a single line by hand.The AI agents wrote..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/HKMT253bsAAkeaf?format=jpg&name=large)

In February 2026, a small OpenAI team shipped 1 million lines of production code.

They didn't write a single line by hand.

The AI agents wrote it.

The humans designed the system that made the agents reliable.

That system has a name now.

**Harness Engineering.**

Within weeks, Anthropic published 3 papers on it.

ThoughtWorks formalized a framework.

Philipp Schmid at Hugging Face called it "the most important discipline of 2026."

A new engineering discipline materialized in 90 days.

And almost nobody outside AI infrastructure teams understands it yet.

This article explains everything.

No fluff. No academic jargon. Just the mental models you need to actually use this.

Save this. You will read it twice.

## PART 1: WHAT A HARNESS ACTUALLY IS (The concept that changes how you think about AI)

**1\. The Harness Definition**

![Image](https://pbs.twimg.com/media/HKMONPZbMAAuFzj?format=jpg&name=large)

The simplest definition comes from ThoughtWorks:

→ **Agent = Model + Harness**

The harness is everything that isn't the model.

The constraints that keep the agent on track. The feedback loops that catch mistakes. The documentation that tells the agent where it is. The tools it has permission to use.

Strip away the harness → raw language model guessing its way through your codebase.

Add the right harness → system that ships production code.

The name comes from horse tack.

A harness is the reins, saddle, and bit that channel a powerful but unpredictable animal in a useful direction.

You don't make the horse smarter. You design the equipment that makes its strength useful.

**2\. The OS Analogy**

![Image](https://pbs.twimg.com/media/HKMOQ4-b0AAM8FP?format=jpg&name=large)

Philipp Schmid gave the best technical framing:

Think of it like a computer.

→ **Model = CPU** (raw processing power)

→ **Context window = RAM** (limited, volatile working memory)

→ **Harness = Operating System** (manages what the CPU sees and when)

→ **Agent = The Application** running on top

Your model is powerful.

But without an OS managing memory, scheduling tasks, and enforcing rules — it's just silicon.

Most people are running apps with no operating system.

That's why their agents fail in production.

**3\. What Changed in 2026**

![Image](https://pbs.twimg.com/media/HKMOVkEbcAA-to2?format=jpg&name=large)

LangChain ran the same model on Terminal Bench 2.0 twice.

Same model. Different harness.

→ Old harness: 52.8% score

→ New harness: 66.5% score

Vercel went the opposite direction.

They removed 80% of their agent's tools.

Result? Better performance.

Not worse.

The uncomfortable truth of 2026:

→ The agent was never the hard part.

→ The harness is.

If 2025 was the year AI agents proved they could write code…

2026 is the year we discovered the environment matters more than the model.

## PART 2: THE 5 HARNESS ARTIFACTS (What a harness actually looks like in practice)

**4\. AGENT.md / CLAUDE.md Files**

![Image](https://pbs.twimg.com/media/HKMOYwYacAAAoNm?format=jpg&name=large)

The most universal harness artifact.

Markdown files distributed throughout your codebase.

The agent reads them at the start of every session — like onboarding docs for a new engineer joining the team.

What goes in them:

→ Project context

→ Coding conventions

→ Architecture decisions

→ "How we do things here" guidance

→ What's currently in progress

OpenAI calls them AGENT.md.

Anthropic calls them CLAUDE.md.

Cursor uses .cursorrules.

Different names. Same principle.

One file per major module. Updated as the project evolves.

Without them: the agent starts every session blind. With them: the agent starts every session informed.

**5\. JSON Feature Lists (The Progress Tracker)**

![Image](https://pbs.twimg.com/media/HKMO0D7boAAYE9h?format=jpg&name=large)

When an agent builds a whole app over multiple sessions, it starts each session with a blank context window.

How does it know what's already done?

A JSON file.

Each entry defines:

→ A feature

→ How to verify it works

→ Pass / Fail status

The agent reads this at session start. Picks the highest-priority failing feature. Implements it. Marks it passing. Commits. Repeats.

Why JSON and not Markdown?

Anthropic found agents are less likely to accidentally overwrite JSON than Markdown.

Small detail. Matters a lot in 6-hour autonomous runs.

**6\. Session Initialization Routines**

![Image](https://pbs.twimg.com/media/HKMO5MVaMAAHqik?format=jpg&name=large)

Every session starts the same way.

Every. Single. Time.

Anthropic's 7-step boot sequence:

1. Confirm working directory
2. Read git logs and progress files
3. Check feature list for highest-priority incomplete item
4. Start the dev server
5. Run basic end-to-end verification
6. Implement one feature
7. Commit with descriptive message + update progress

Without this:

The agent wastes its first 20 minutes figuring out what already exists.

Every session is reinventing the wheel.

With it:

The agent starts instantly informed and moves directly to work.

**7\. Sprint Contracts**

![Image](https://pbs.twimg.com/media/HKMO9V1awAAFI8f?format=jpg&name=large)

Before the agent writes a single line of code:

Two agents negotiate.

Generator agent proposes:

→ What it will build

→ How success will be verified

Evaluator agent reviews:

→ Is the proposal complete?

→ Are the success criteria clear?

Only after both agree does implementation begin.

It's a design review.

Except both participants are AI.

Why does this matter?

Agents that plan and execute in the same pass produce unreliable output.

The planning step — even when done by AI — dramatically improves output quality.

**8\. Structured Task Templates**

![Image](https://pbs.twimg.com/media/HKMPGK6asAAUILK?format=jpg&name=large)

Before any coding:

The harness analyzes the real codebase.

It produces a grounded impact map:

→ Real file paths (not hallucinated ones)

→ Real symbol names that actually exist

→ Existing patterns to follow

→ Concrete acceptance criteria

Then implementation begins.

This sounds obvious.

But most teams skip it.

The agent guesses at file structures. Invents API endpoints that don't exist. Builds something that doesn't fit the codebase.

Grounded context before execution → massively better output.

## PART 3: THE THREE CAMPS (Three teams hit the same wall — and built three different ladders)

**9\. OpenAI: Environment-First**

![Image](https://pbs.twimg.com/media/HKMPmclbcAAPPxQ?format=jpg&name=large)

OpenAI's Codex team had an absurd problem.

1 million lines of production code. Zero written by hand.

At that scale, you can't code-review every line.

So they didn't.

Instead:

They designed the environment so thoroughly that the agents produced reviewable output in the first place.

Their approach:

→ Strict dependency flows (Types → Config → Repo → Service → Runtime → UI)

→ AGENT.md files throughout the codebase

→ Agents wired directly into CI/CD pipelines

The philosophy: **Design the environment. Then let the agent loose.**

The proof: Sora Android app. 4 engineers. 28 days. #1 on Play Store. 99.9% crash-free.

Codex handled 70% of internal pull requests weekly.

**10\. Anthropic: Separate the Doer from the Judge**

![Image](https://pbs.twimg.com/media/HKMPriAbAAA0jBO?format=jpg&name=large)

Anthropic had a different problem.

When they asked the agent to evaluate its own output:

It would confidently praise the work.

Even when, to a human observer, the quality was obviously mediocre.

Self-evaluation doesn't work.

The agent was both the student and the teacher.

And it was giving itself straight A's.

Their fix: **Three specialized agents.**

→ **Planner** — turns a 2-sentence prompt into a full product spec

→ **Generator** — implements features one sprint at a time

→ **Evaluator** — uses browser automation to test the running app like a real user

The insight: making a standalone evaluator skeptical is far easier than making a generator critical of its own work.

Result: Solo agent (no harness): $9, 20 min

→ broken app Full harness: $200, 6 hours

→ working software with polished UI

**11\. ThoughtWorks: The 2×2 Framework**

![Image](https://pbs.twimg.com/media/HKMPvtSa4AALRwq?format=jpg&name=large)

ThoughtWorks arrived from a different angle.

They weren't building a product.

They were watching 50+ engineering teams fail at the same things.

Their insight: classify every harness control along two axes.

**Axis 1:** When does it run?

→ Feedforward = before the agent acts (guides)

→ Feedback = after the agent acts (sensors)

**Axis 2:** How does it work?

→ Computational = deterministic, milliseconds (linters, type checkers, test suites)

→ Inferential = uses an LLM, seconds (code review agent, semantic analysis)

The 2×2:

→ Computational Feedforward: type systems, linters, architectural rules

→ Computational Feedback: test suites, coverage analysis, mutation testing

→ Inferential Feedforward: spec documents, constraint descriptions

→ Inferential Feedback: LLM code reviewers, behavior validators

Neither feedforward nor feedback alone works.

You need both.

## PART 4: THE 5 PRINCIPLES EVERY CAMP AGREES ON (Three teams never coordinated. They arrived here independently.)

**12\. Principle 1: Context Beats Instructions**

![Image](https://pbs.twimg.com/media/HKMQM19aoAAve50?format=jpg&name=large)

OpenAI: "Give a map, not a 1,000-page manual."

Anthropic: JSON feature lists and progress files so agents always know where they are.

Red Hat: Analyze the real codebase before generating any tasks.

ThoughtWorks: "Feedforward."

Different words. Same discovery.

Showing the agent the current state of the world consistently outperforms telling it what to do abstractly.

→ Grounded in real file paths

→ code that fits the codebase

→ Working from a vague description

→ hallucinated file paths and invented APIs

The lesson: **Before the agent types anything, make sure it knows exactly where it is.**

**13\. Principle 2: Planning and Execution Must Be Separated**

![Image](https://pbs.twimg.com/media/HKMQURsbgAAEctZ?format=jpg&name=large)

OpenAI: humans design environment, agents execute.

Anthropic: dedicated Planner agent runs before Generator touches any code.

ThoughtWorks: mandatory human review checkpoint between planning and implementation.

Red Hat: Phase 1 (impact map) and Phase 2 (implementation) with a hard gate between.

Every camp discovered this independently:

**Letting an agent plan and execute in the same pass produces unreliable output.**

The planning step doesn't have to be done by a human.

But it has to be a separate step, with its output reviewed before implementation begins.

**14\. Principle 3: Feedback Loops Are Non-Negotiable**

![Image](https://pbs.twimg.com/media/HKMQaebbwAA9wsx?format=jpg&name=large)

OpenAI: agents wired into CI/CD and observability systems.

Anthropic: dedicated Evaluator agent using browser automation.

ThoughtWorks: formalized as "sensors." Warned that feedforward-only approaches never confirm whether guides actually work.

Three approaches to the same principle:

→ OpenAI uses automated tests and CI

→ Anthropic uses another LLM

→ ThoughtWorks says use both, layered

They disagree on who provides the feedback.

They don't disagree on whether you need it.

**A harness without feedback is just a prompt with extra steps.**

**15\. Principle 4: One Thing at a Time**

![Image](https://pbs.twimg.com/media/HKMQhHbb0AAhevu?format=jpg&name=large)

OpenAI: breaks goals into smaller building blocks, works depth-first.

Anthropic: enforces one-feature-per-sprint with a commit after each.

ThoughtWorks: phased lifecycle (pre-integration → post-integration → continuous monitoring).

Agents that try to do too much at once:

→ Run out of context

→ Lose coherence

→ Silently drop requirements

The Anthropic routine:

Read progress → Pick ONE feature → Implement → Commit → Repeat

Forced incrementalism is universal across every successful harness.

**16\. Principle 5: The Codebase IS the Documentation**

![Image](https://pbs.twimg.com/media/HKMQoZxacAAEuu7?format=jpg&name=large)

OpenAI: embeds AGENT.md files in the repo.

Anthropic: stores feature lists, progress files, and git history as the agent's continuity mechanism.

ThoughtWorks: measures "harnessability" — how legible the codebase is to agents.

Nobody maintains a separate knowledge base for the agent.

The repo is the single source of truth.

If a convention, constraint, or architectural decision isn't in the codebase — the agent won't know about it.

Practical implication:

→ Teams that invest in code organization get better agent performance for free.

→ Messy repos + AI agents = chaos, but at scale.

## PART 5: THE PARADOX — BUILD TO DELETE (The most counterintuitive truth in harness engineering)

**17\. Harness Decay Is Real**

![Image](https://pbs.twimg.com/media/HKMRQilasAAGqtY?format=jpg&name=large)

When Anthropic upgraded from Opus 4.5 to Opus 4.6:

Sprint decomposition — which had been essential — became dead weight.

The model's improved planning made it redundant.

A harness component that was load-bearing in March was overhead by April.

Then Opus 4.7 landed.

The model started verifying its own outputs.

The Evaluator agent's job description started shrinking.

This is **harness decay**.

Every component in a harness encodes an assumption about what the model can't do.

As models improve → those assumptions expire → the component becomes overhead.

Opus 4.5: sprint decomposition + per-sprint evaluation

Opus 4.6: no sprint decomposition + single-pass evaluation (saves 38% cost)

Opus 4.7: model starts self-verifying → evaluator role shrinks further

**18\. Build to Delete**

![Image](https://pbs.twimg.com/media/HKMRWgEb0AAnYQE?format=jpg&name=large)

Philipp Schmid's advice:

**"Build to delete."**

Design every harness component to be removable.

Test each component periodically by turning it off and measuring whether output quality changes.

If it doesn't change: delete it.

Manus refactored their harness 5 times in 6 months. LangChain restructured 3 times in 1 year. Vercel removed 80% of tools → got better performance.

These aren't signs of bad engineering.

They're the natural consequence of building on top of rapidly improving models.

Carrying dead harness components costs tokens on every single run. Zero extra quality. Pure waste.

**19\. The Cost Reality**

![Image](https://pbs.twimg.com/media/HKMRa_2a4AAvh7S?format=jpg&name=large)

The honest numbers from Anthropic's A/B test:

→ Solo agent (no harness): $9, 20 minutes

→ working UI, broken core functionality

→ Full harness (Opus 4.5): $200, 6 hours

→ working software, polished UI, correct physics

That's a 22x cost increase.

For a functioning product vs a demo that only looks right in screenshots.

Whether that's expensive or cheap depends entirely on what a broken release costs your team.

But here's what nobody talks about:

The harness + model combination evolves.

The $200 harness became $124 with one model upgrade.

The trend line:

→ Better model = simpler harness = cheaper run = faster output

The engineers winning in 2026 aren't writing the best code.

They're designing the best constraints.

And then being willing to throw those constraints away the moment they stop earning their keep.

## CLOSING

![Image](https://pbs.twimg.com/media/HKMvHx_bQAA47bM?format=jpg&name=large)

Everything you just learned:

**What a harness is:**

→ 1. Agent = Model + Harness

→ 2. Model = CPU. Harness = Operating System.

→ 3. Same model, better harness = +13% performance

**The 5 harness artifacts:**

→ 4. CLAUDE.md / AGENT.md — onboarding docs for agents

→ 5. JSON feature lists — progress tracker + test suite in one

→ 6. Session initialization routines — same 7-step boot every time

→ 7. Sprint contracts — agents negotiate before coding

→ 8. Structured task templates — real file paths, real patterns

**The three camps:**

→ 9. OpenAI: design the environment, let agent loose

→ 10. Anthropic: separate the doer from the judge

→ 11. ThoughtWorks: 2×2 feedforward/feedback framework

**The 5 universal principles:**

→ 12. Context beats instructions

→ 13. Planning and execution must be separated

→ 14. Feedback loops are non-negotiable

→ 15. One thing at a time

→ 16. The codebase is the documentation

**The paradox:**

→ 17. Harness decay — what worked last month hurts this month

→ 18. Build to delete — test and remove dead components

→ 19. The cost reality — better model = simpler harness = cheaper run

The engineers winning in 2026 aren't writing the best code.

They're designing the best constraints.

And being willing to throw those constraints away the moment they stop earning their keep.

If this was useful:

→ Repost to reach builders in your network

→ Follow [@sairahul1](https://x.com/@sairahul1) for more like this every week

→ Bookmark this — you'll reference it when your agents start misbehaving

I write about AI, building products, and what's actually working in 2026.