---
title: "Why Current Observability Breaks at Scale"
author: "Akshay 🚀"
username: "@akshay_pachaar"
date: "2026-06-08"
tweet_url: "https://x.com/akshay_pachaar/status/2064051835636498924"
tweet_type: "original"
likes: 1127
retweets: 150
replies: 30
bookmarks: 2578
views: 618050
has_media: false
extraction_quality: full
article_id: "2063964921495523328"
tags: ["twitter-bookmark", "llm", "cursor", "agents"]
---

# Why Current Observability Breaks at Scale

> **Source:** [@akshay_pachaar](https://x.com/akshay_pachaar) · 2026-06-08 · 👍 1127 · 💬 30 · 🔖 2578 · 👁 618050

> 🔗 [View tweet on X](https://x.com/akshay_pachaar/status/2064051835636498924)

## Article Content

When an AI agent fails in production, your observability tool shows you exactly what it did and almost nothing about how to fix it.

You get a clean trace of the run, every model call and tool that fired, how long each step took, and what it cost in tokens.

What you don't get is why it broke, the change that would fix it, or any promise the same thing won't happen again next week.

So you scroll through the trace span by span, form a theory about what went wrong, write a patch by hand, and hope it doesn't break something that was working before.

Then a new model ships with a fresh batch of failure modes, and you run that whole manual loop from the top.

The real bottleneck isn't your observability. It's everything that has to happen after the trace lands on your screen.

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063965206817144833

Everything to the left of the dotted line runs automatically. Everything to the right runs on your time, which is where production debugging actually lives.

Cursor recently shared how much engineering goes into the harness around their agent, the layer of prompts, tools, and checks wrapped around the raw model. A better harness on the same model gives far better results, and that work never really ends.

This is where every observability platform leaves you. It answers what happened, then hands back why it happened, what to change, and how to keep it from breaking again.

That gap is the loop most teams are stuck in today. Here's why it keeps reopening, and what it finally takes to close it.

## Why Current Observability Breaks at Scale

Most agent observability platforms deliver a trace and stop.

You get a span tree, latency numbers, token costs, and a dashboard. What you don't get: why it failed, what to fix, or any guarantee it won't break again.

- "What happened" â†’ the platform handles this
- "Why it happened" â†’ manual
- "Here's the fix" â†’ manual
- "This won't break again" â†’ manual

That was a reasonable product in 2023. It's the wrong abstraction for teams running agents in production today.

The problem compounds itself. Every model upgrade introduces new failure modes. Every new tool adds new edge cases. The harness gets more complex faster than any team can manually track and repair.

Here's the stack that does it.

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063965533700296704

Most platforms end at the dashboard and hand the rest to you. The right side is the loop Opik runs on its own.

## Opik: AI Observability & Evals For the Agentic Era

Opik is an [open-source](https://github.com/comet-ml/opik)

 logging, debugging, and optimization platform for AI agents and LLM applications. Opik is built around the premise that this loop should be automated, not staffed.

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063966280261287936

## The Four-Layer Stack

Opik's architecture is one connected workflow.

Trace â†’ Ollie diagnoses â†’ Ollie proposes a fix â†’ fix is applied and verified â†’ Test Suite locks the failure as a regression test â†’ back to Trace

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063966492958613504

The four layers are not separate features. They feed each other in a single loop that closes on its own.

Here's each layer.

### Layer 1: Tracing

Every LLM call, tool invocation, and retrieval step is instrumented automatically with a single decorator.

```python
import opik

@opik.track
def my_agent(query: str):
    # your agent logic here
    ...
```

Works with LangGraph, CrewAI, and 50+ frameworks out of the box. Every trace records which agent configuration was active for full reproducibility when you need to rerun a failing input later.

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063968107769864192

The four layers are not separate features. They feed each other in a single loop that closes on its own.

### Layer 2: Ollie

Every other observability platform stops at "here's your trace." Opik goes from trace to fixed code, powered by Ollie.

Ollie is a coding agent built into Opik. One agent, full context.

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063968770901839872

Ollie working through a fix in the side panel, reading and editing files only after you approve each step.

Without any code access, Ollie reads span trees, identifies failure modes, and explains the causal chain across every LLM call. Ask it, "why did the final answer ignore the retrieved context?" It walks the full span tree and surfaces the root cause.

Run opik connect from your project root, and Ollie upgrades to full code-fix mode:

- Reads your source files
- Identifies the exact lines responsible
- Proposes a diff; nothing changes without your explicit approval

Once you approve, Ollie reruns your agent against the exact inputs from the original failing trace, streams the new trace for side-by-side comparison, and locks the original failure as a regression case in your test suite.

Bad trace â†’ root cause â†’ diff â†’ approve â†’ rerun â†’ regression locked

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063969154621964289

The full path from a bad trace to a locked regression test, with your approval as the one manual step.

### Layer 3: Test Suites

Most eval workflows: build a labeled dataset, define a numerical metric, compare floats. That model works for researchers. It doesn't match how engineers think about quality.

Opik replaces it with plain-English assertions.

```python
suite = opik.TestSuite("crm-agent-v2")
suite.add_assertion("The response must include specific deal details, not just a count")
suite.add_assertion("The response must never reveal unauthorized information")
suite.run_tests()
```

Opik converts those into LLM-as-a-judge checks under the hood. Clean pass/fail per test case.

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063969762296946688

A regression suite built from real failures, with each assertion written as a plain-English check.

The part that changes the workflow: every failing trace you debug automatically becomes a new test case. The suite grows from real production failures, not synthetic scenarios someone wrote in advance.

Every cycle, the harness gets harder to break.

But even with a growing test suite, you still need a safe place to test changes before they ship. That's what Layer 4 is for.

### Layer 4: Agent sandbox

Most playgrounds are prompt playgrounds. You change a system prompt and rerun one LLM call. That answers the wrong question.

The production question is, what happens to the entire agent graph when I change this.

Opik's Agent Sandbox runs the fully instrumented agent end-to-end inside the UI. Change a prompt, swap a model, add a tool, and watch how the whole system responds across the full spanning tree. Every sandbox run produces a complete Opik trace.

Non-developer stakeholders, PMs, domain experts, and QA can safely test configurations without touching git.

## The Flywheel in Practice

The layers aren't independent features. They're one loop.

Instrument with [@opik](https://x.com/@opik)

.track. Declare an opik.Config. Something fails in production. Ollie reads the trace, reads your source, and proposes a fix. You approve. Ollie reruns the agent in the Sandbox against the original failing input. Fixes passes. Save it as a new Blueprint. The environment pointer promotes to staging. Original failure locked as a regression test.

https://x.com/akshay_pachaar/article/2064051835636498924/media/2063972378074554368

The same loop drawn end to end, from instrumenting your agent to the next failure entering at the top.

The next failure enters the same loop.

Every cycle, the harness gets harder to break.

## â€‹Closing the Loop

Observability that ends at the trace made sense when agents were simple. Once they hit production, the real work is everything after the trace, and that is the part Opik runs for you instead of leaving it on your plate.

The whole stack ships in the open, Tracing, Ollie, Test Suites, the Agent Sandbox, a 6-algorithm Agent Optimizer, and 50+ framework integrations, with the project past 19.3K stars on GitHub.

It self-hosts in three commands:

```bash
git clone https://github.com/comet-ml/opik
cd opik
./opik.```sh

The manual loop Cursor describes is the one Opik closes on its own, from a bad trace all the way to a locked regression test.

It is worth a look if you are running agents in production. 

[Check out Comet ML and Opik â†’](https://github.com/comet-ml/opik)

( don't forget to star ðŸŒŸ)

What's the current state of observability in your agent stack, and where does the debugging loop break for your team right now?

If you are building an open-source tool that AI engineers would love, reach out. We only cover tools that pass our own test, so we'll try yours first and write about it only if it holds up.

Thanks to Comet ML for sponsoring today's issue.

> 📄 Original article URL: https://x.com/i/article/2063964921495523328

