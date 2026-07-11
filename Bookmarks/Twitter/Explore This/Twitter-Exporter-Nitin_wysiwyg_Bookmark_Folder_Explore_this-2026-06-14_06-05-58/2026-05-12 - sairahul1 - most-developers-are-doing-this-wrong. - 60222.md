---
title: "Most developers are doing this wrong."
author: "Rahul"
username: "@sairahul1"
date: "2026-05-12"
tweet_url: "https://x.com/sairahul1/status/2054091054048260222"
tweet_type: "original"
likes: 110
retweets: 24
replies: 4
bookmarks: 382
views: 96464
has_media: false
extraction_quality: full
article_id: "2054087498150952960"
tags: ["twitter-bookmark", "claude", "mcp", "llm", "agents"]
---

# Most developers are doing this wrong.

> **Source:** [@sairahul1](https://x.com/sairahul1) · 2026-05-12 · 👍 110 · 💬 4 · 🔖 382 · 👁 96464

> 🔗 [View tweet on X](https://x.com/sairahul1/status/2054091054048260222)

## Article Content

Most developers are doing this wrong.

They pick CrewAI because the demos look slick on Twitter.

They chase every new framework that ships.

They jump into multi-agent systems without understanding context, tools, or harnesses.

The result is always the same: a lot of framework tourism. Zero production-ready skill.

Here is the complete 17-week roadmap to go from zero to owning a production AI feature end to end.

### THE ONE NUMBER THAT CHANGES EVERYTHING

Anthropic measured Claude Opus 4.5 on the same benchmark inside two different systems.

Inside Claude Code: 78%

Inside Smolagents: 42%

Same model. Same benchmark. 36-point gap.

That gap is not the model. That gap is harness engineering.

The harness â€” how you build the loop, manage context, dispatch tools, and orchestrate sub-agents â€” determines whether your agent is production-grade or a demo that breaks under real conditions.

This is what the roadmap is about.

### WHAT AN AGENT ENGINEER ACTUALLY DOES IN 2026

Forget the Twitter version. Here is what the job actually is:

â–¸ Design the agent loop and tool dispatch

â–¸ Engineer context with four primitives: Write, Select, Compress, Isolate

â–¸ Write tools the model selects correctly â€” not just tools that exist

â–¸ Orchestrate sub-agents with isolated context windows

â–¸ Add skills, memory, durability, and sandboxing

â–¸ Wire evals, traces, and CI gates so "better" becomes measurable

â–¸ Ship agents that survive contact with real users and real cost

The best two stacks to learn in 2026: LangGraph 1.0 + Deep Agents and the Claude Agent SDK. Everything else is either fading, getting absorbed, or a worse version of these two for production.

### THE 4 CONTEXT PRIMITIVES (LEARN THESE FIRST)

Before touching any framework, understand context engineering. This is the foundational skill.

â–¸ Write â€” scratchpads and memory files. The agent externalizes its working state so it doesn't lose it when context compresses.

â–¸ Select â€” retrieval at the point of use. You don't dump everything into context. You fetch what's relevant for this specific step.

â–¸ Compress â€” summarization at 85â€“95% of the context window. Auto-compact older turns before the window fills. Never let the agent run out of room mid-task.

â–¸ Isolate â€” sub-agents with their own context windows. Spawn a child agent for a sub-task, return a compressed summary to the parent. Never raw data.

Anthropic's multi-agent research system beat single-agent Opus 4 by 90.2% on breadth-first research using exactly this pattern â€” while burning ~15Ã— the tokens. The lesson: spend tokens on isolation, not on dumping everything into one massive context.

### PHASE 0 â€” FOUNDATIONS (WEEKS 1â€“2)

Goal: build the mental model before touching a framework.

What to learn:

Python async fundamentals. Agents are async by default. If you don't know asyncio, you'll hit walls immediately.

The Anthropic API from scratch. Don't use a wrapper yet. Build a raw tool-calling loop yourself â€” model call, tool dispatch, result injection, next model call. Understanding what the framework hides is what makes you dangerous when it breaks.

Prompt engineering from primary sources. Anthropic's Interactive Prompt Engineering Tutorial â€” 9 chapters as Jupyter notebooks against the Claude API. This is the fastest way to build real prompting muscle.

The 4 context primitives above. These are the lens you apply to every framework decision from here on.

Milestone: a raw Python loop that takes a user question, calls Claude, dispatches a tool, injects the result, and returns a final answer. No LangChain. No abstraction. Just you and the API.

Free resources:

â†’ Anthropic engineering blog (primary source for everything in this roadmap)

â†’ Anthropic Interactive Prompt Engineering Tutorial (GitHub, free)

â†’ [DeepLearning.AI](https://x.com//DeepLearning.AI)

 "Agentic AI" short course by Andrew Ng (free, 1â€“2 hours)

â†’ Latent Space newsletter by swyx â€” subscribe now, read throughout

### PHASE 1 â€” LANGGRAPH + DEEP AGENTS (WEEKS 3â€“6)

Goal: learn the dominant orchestration runtime and its packaged harness.

LangGraph is the state machine. Nodes are steps. Edges define flow. State carries context through the graph. The PostgresSaver checkpoints every node so the agent can resume after a crash.

Deep Agents is the middleware layer on top â€” planning, filesystem, sub-agents, summarization, human-in-the-loop. It packages the patterns that took engineering teams months to figure out.

What to focus on:

State schemas, nodes, edges, conditional edges. The PostgresSaver checkpointer. Time-travel debugging. Human-in-the-loop interrupts. How middleware composes.

The middleware insight most engineers miss: middleware is how you customize a packaged agent without forking it. The before_agent, wrap_model_call, before_tools, after_tools hooks let you intercept every step. Write a custom middleware in 30 lines. Know when middleware is the answer vs writing a new node.

Tools and MCP: the naive "load all MCP tools into context" pattern is broken. The correct pattern is code execution with MCP. Anthropic's approach reduced tool tokens from 150K to 2K. The defer_loading: true flag alone cut tool tokens 85% and lifted an MCP eval from 79.5% to 88.1%.

Practice project: build a "research analyst" deep agent.

Input: a research question.

The lead agent plans, writes a TODO list to a virtual filesystem, and spawns 3 search sub-agents in parallel â€” each with isolated context. Sub-agents search, write results to files, and return short summaries to the parent. Never raw search results into the parent's context. A citation sub-agent verifies claims. A writer agent produces the final report. All state persists via PostgresSaver. Kill the process mid-run, resume from where it stopped. Human-in-the-loop interrupt: agent asks for confirmation before exceeding $1 in tokens.

Milestone: working multi-step agent with durability, sub-agents, isolated context, and a human-in-the-loop interrupt.

Free resources:

â†’ LangChain Academy: Introduction to LangGraph (free, official)

â†’ Deep Agents v0.5 release notes (LangChain, April 2026)

â†’ Code execution with MCP (Anthropic, Nov 2025, official)

### PHASE 2 â€” BUILD THE HARNESS YOURSELF (WEEKS 7â€“10)

Goal: stop using a packaged harness. Build a thin one yourself.

This is the highest-leverage phase in the roadmap. You will never make the right harness trade-offs in production until you've built one from scratch.

The 10 components every modern harness has:

01 â†’ Loop control. The while-loop driving model â†’ tools â†’ model.

02 â†’ Tool dispatch. Registry, schema validation, parallel calls, error recovery, retries.

03 â†’ Context management. System-prompt assembly, message-history compaction at 85â€“95% of window, tool-response offloading at ~20K tokens, prompt caching.

04 â†’ Persistence. Checkpoint state every node. Resume, rewind, fork must be possible.

05 â†’ Sub-agent orchestration. Spawn isolated-context children, route compressed summaries back.

06 â†’ Skills and progressive disclosure. Load capabilities only when relevant. Aim for under 50 tokens of metadata per skill in context.

07 â†’ Hooks. PreToolUse, PostToolUse, PreCompact, Stop, SessionStart.

08 â†’ Observability. OTEL spans for every model call, tool call, sub-agent invocation, with token counts and latency.

09 â†’ Sandboxing. Code execution and MCP tool calls happen in a container the model never has direct credentials to.

10 â†’ Auth and secrets brokering. Credentials never enter the model's context.

The key insight: the harness does not think. It reads files, calls tools, writes logs, runs hooks. All intelligence lives in the skill files and memory files. This means you can swap the harness tomorrow and lose nothing. You can swap the model and lose nothing. The only things that accumulate value are skills, memory, and protocols â€” plain markdown and JSON in a git repo.

Practice project: write a mini-harness in ~1,500 lines of Python.

A loop wrapping the Anthropic API. Tool registry from a decorator. CLAUDE.md-style system prompt loader. Progressive-disclosure skill loader. Sub-agent spawn primitive. Filesystem offload for tool results over 20K tokens. Auto-compaction at 85% context window. Pluggable hook system. OpenTelemetry tracing. Durable resume via SQLite.

Milestone: a 1,000-word post-mortem comparing your mini-harness to Claude Agent SDK and Deep Agents. What you got right. What you cut. What you'd do differently. The code is evidence. The post-mortem is the real deliverable.

Free resources:

â†’ The Anatomy of an Agent Harness (LangChain, free) â€” the reference text for this entire phase

â†’ Improving Deep Agents with harness engineering by Vivek Trivedy â€” went from rank 30 to rank 5 on Terminal-Bench 2.0 by changing only the harness, not the model

â†’ Inside the Claude Agents SDK (ML6, free)

### PHASE 3 â€” BUILD THE EVAL HARNESS (WEEKS 11â€“13)

Goal: make your agent measurable. Without this, every "improvement" is vibes.

This is where most engineers stall. They build a great agent and can't tell whether their next change made it better or worse.

The 4 eval types you must implement:

â–¸ Single-turn evals â€” given this input, is the output right? Cheapest. Use deterministic graders where possible. Run constantly.

â–¸ Trajectory evals â€” did the agent call the right sequence of tools with the right arguments? Test single-step, full-turn, and multi-turn variants.

â–¸ LLM-as-judge â€” for open-ended outputs like research reports and code review. Calibrate against human-graded examples weekly. Score on: factual accuracy, citation quality, completeness, source quality, tool efficiency.

â–¸ End-state evals â€” for stateful agents that write to databases or edit files. Compare final state to ground truth.

The CI gate that changes everything: wire evals into GitHub Actions. Every PR runs the full suite. Block merge if the golden-set pass rate drops by â‰¥3 points. This turns evals from dashboard wallpaper into a development tool.

One warning before you design your evals: Anthropic found that models can detect when they're being evaluated and behave differently. Design your eval suite to be AI-resistant from day one or you'll bake the bias in permanently.

Pick one observability platform and don't run two:

â†’ LangSmith â€” if you live in LangGraph. Native tracing, experiments, Sandboxes.

â†’ Braintrust â€” if you want framework-agnostic CI quality gates. $249/mo flat, unlimited users.

â†’ Arize Phoenix â€” if you want OpenTelemetry-native and open source.

â†’ Inspect (UK AISI) â€” for benchmark-grade evals. Used by Anthropic, DeepMind, and Grok internally.

Milestone: a make eval target that emits a CI pass/fail summary, a LangSmith experiment URL, and one canonical benchmark score via Inspect.

### PHASE 4 â€” PRODUCTION HARDENING (WEEKS 14â€“17 AND ONGOING)

Goal: make everything survive contact with real users, real cost, and real failures.

This phase is permanent. You never finish it.

â–¸ Cost discipline

Use prompt caching aggressively â€” up to 90% savings on repeated prefixes. Cache your system prompt, tool definitions, and CLAUDE.md on every call.

Route by difficulty: Haiku 4.5 for simple turns, Sonnet 4.6 for standard tasks, Opus 4.7 for planning and hard reasoning. This alone cuts costs 50%+ with no quality loss.

Batch API for non-real-time workloads: 50% off. Multi-agent runs ~15Ã— the tokens of single-agent chat â€” only use it when the answer's value clears that bar.

â–¸ Latency

Parallel tool calls are not optional. Anthropic's own research system prompt literally says: "you MUST use parallel tool calls when creating multiple sub-agents." Apply the same rule in your harness.

Sub-agent fan-out is the single biggest latency lever: a 60-step sequential agent becomes a 10-step lead agent plus 5 parallel 10-step sub-agents. Wall clock time drops by 5â€“6Ã—.

â–¸ Safety and sandboxing

All code execution in a container â€” Modal, E2B, or Daytona. Never exec() model output in your main process.

Credentials brokered outside the model context â€” Composio handles SaaS auth without credentials ever entering the model's context window.

PreToolUse hooks that block destructive Bash, regex-block secrets, and validate file-write paths before every tool call.

Human-in-the-loop interrupts on any irreversible action. Make the approval step explicit, not optional.

â–¸ Resilience

Durable execution is non-negotiable for any agent that runs over 60 seconds. Use Inngest, Temporal, or LangGraph PostgresSaver. Checkpoint after every node. Rewind and fork must be possible.

â–¸ Monitoring

Alert on: token cost per request, tool-call failure rate, LLM-as-judge mean score nightly, p95 latency, eval regression after every deploy.

Re-baseline evals after every model upgrade. Harnesses encode assumptions about what the model can't do on its own â€” those assumptions go stale as models improve.

### THE MEMORY SYSTEM THAT MAKES AGENTS GET SMARTER OVER TIME

Most engineers skip this. It is what separates agents that plateau from agents that compound.

The four-layer memory architecture:

â–¸ Working memory (WORKSPACE.md) â€” live task state. Volatile. Cleared after every task.

â–¸ Episodic memory (AGENT_LEARNINGS.jsonl) â€” raw experience log. Every significant action, failure, correction. The agent reads this before making decisions it has been wrong about before.

â–¸ Semantic memory (LESSONS.md + DECISIONS.md) â€” distilled patterns that outlive individual episodes. Lessons the agent has compressed from failures. Architectural decisions and their rationale so the same debate never happens twice.

â–¸ Personal memory (PREFERENCES.md) â€” user conventions and style. Context, not instructions. "I prefer functional patterns over classes" tells the agent who you are, not how to write code. Keep these as context, never promote them into procedural skill steps.

The nightly dream cycle: a background process that runs after every session. It reads the episodic log, compresses what's worth keeping into semantic memory, decays entries that turned out to be wrong, and archives workspaces older than 2 days. The agent wakes up the next morning with a cleaner, more accurate memory than it went to sleep with.

Garry Tan said it best:

"If your memory dies when your harness dies, you built the harness too thick. Memory is markdown. Skills are markdown. Brain is a git repo. The harness is a thin conductor â€” it reads the files, it doesn't own them."

Own your memory. Own your skills. Keep them in plain files and git where no one can take them from you.

### THE SKILLS SYSTEM THAT GIVES YOUR AGENT EXPERTISE

Skills are markdown files that encode how tasks should be done. Each skill has a trigger (when to load it), a procedure (the skeleton), heuristics (defaults at decision forks), and constraints (the fence around the yard).

The audit question to run on every skill: is this line telling the agent how, or telling it what good looks like? If it's a how, it usually doesn't need to be there.

Progressive disclosure: the skill index loads first â€” summaries only, under 50 tokens per skill. The full SKILL.md loads only when a trigger matches. This keeps your context budget sane across a large library of skills.

The self-rewrite hook: when a skill causes three consecutive failures, the hook fires and prompts the agent to propose a conservative rewrite of that skill. The system repairs itself. You review and approve.

### THE FREE RESOURCE STACK (EVERYTHING YOU NEED IS FREE)

Blogs â€” one is enough to start:

â†’ Anthropic engineering blog â€” primary source for harness design, evals, multi-agent patterns

â†’ LangChain blog â€” where harness discipline gets formalized in public

â†’ Hamel Husain's blog â€” "Your AI Product Needs Evals" is required reading before Phase 3

Courses â€” complete these two:

â†’ [DeepLearning.AI](https://x.com//DeepLearning.AI)

 "Agentic AI" by Andrew Ng (free, 1â€“2 hours)

â†’ LangChain Academy: Introduction to LangGraph (free, official)

Newsletter â€” subscribe to one:

â†’ Latent Space by swyx â€” the technical newsletter for AI engineers

Community â€” join one:

â†’ LangChain Discord â€” the LangGraph and Deep Agents core team is active here

Repos to study:

â†’ Anthropic Cookbook (GitHub, free) â€” reference implementations of every workflow pattern

â†’ deepagents by LangChain (GitHub, free) â€” the reference open-source harness. Read the middleware files

### THE 17-WEEK TIMELINE

Weeks 1â€“2 â†’ Phase 0: Python async + raw Anthropic API + 4 context primitives

Weeks 3â€“6 â†’ Phase 1: LangGraph + Deep Agents + research analyst project

Weeks 7â€“10 â†’ Phase 2: Build your own harness + post-mortem

Weeks 11â€“13 â†’ Phase 3: Eval harness + CI gates + LangSmith

Weeks 14â€“17 â†’ Phase 4: Production hardening + cost + safety + monitoring

Ongoing â†’ Memory system + skills system + drift monitoring

By week 17: you can own a production AI feature end to end. Design the agent loop. Engineer context. Write tools the model picks correctly. Evaluate whether changes made it better. Ship it. Monitor it. Fix it when it breaks.

That is the job. That is what the market pays for.

The gap between "I'm reading the LangChain blog" and "I'm shipping a deep agent with PostgresSaver durability" is where most engineers stay forever.

Don't wait until you feel ready. You never will.

Start applying, start building in public, start shipping the moment you have a working agent. Even a small one. The market doesn't reward perfection. It rewards engineers who can make the model do something real and prove it didn't regress.

17 weeks is enough to change everything.

Follow for more full-course deep-dives on building real AI systems.

> 📄 Original article URL: https://x.com/i/article/2054087498150952960

---

## Commentary from Other Bookmarks

### @sairahul1 (Rahul) — 2026-05-12

> If you’re building AI agents and haven’t watched this Anthropic talk yet, you’re already behind.
> 
> In 22 minutes, Claude’s team exposed where the entire industry is heading next:
> 
> → tool orchestration
> → memory systems
> → observability
> → long-running agents
> → production infrastructure
> 
> Most developers are still focused on demos.
> Anthropic is building for autonomous systems at scale.
> 
> The last few minutes are the real gold 👇
> 
> Watch the full talk first.
> 
> Then read my complete roadmap on becoming an AI Agent Engineer in 2026 if you want to build what the market will actually need next.

[→ View quote tweet](https://x.com/sairahul1/status/2054171777119801764)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

