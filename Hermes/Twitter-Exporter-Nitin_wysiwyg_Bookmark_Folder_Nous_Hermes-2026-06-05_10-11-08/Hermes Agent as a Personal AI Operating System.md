---
title: "Hermes Agent as a Personal AI Operating System"
source: "https://x.com/IBuzovskyi/status/2063645563241844823"
author:
  - "[[@IBuzovskyi]]"
published: 2026-06-07
created: 2026-06-08
description: "Most current AI agent frameworks operate primarily as applications built on top of large language models. They can perform reasoning, call t..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/HKN9T-XWQAAg5lt?format=jpg&name=large)

Most current AI agent frameworks operate primarily as applications built on top of large language models. They can perform reasoning, call tools, and maintain context within a session, but they generally lack robust, native mechanisms for long-term structured persistence, workload isolation, autonomous expansion of their own capabilities, and reliable coordination across multiple components over extended periods of time.

Hermes Agent, developed by Nous Research, implements several architectural features that set it apart from many other agent frameworks. These include support for persistent memory across sessions, the ability to run multiple isolated execution contexts through profiles, a structured task orchestration system based on Kanban, mechanisms that allow agents to create and store reusable procedures derived from their own activity, and a messaging gateway that connects the agent to 27+ communication platforms.

This article examines Hermes through the lens of a **Personal AI Operating System**. The goal is to provide a detailed and honest analysis of its core architectural layers, how these layers interact in practice, and what the system can realistically offer as of June 2026, based on publicly available documentation and observed behavior.

## 1\. Core Layers of Hermes

To better understand the structure of Hermes, it is helpful to map its components to concepts from traditional operating systems.

![Image](https://pbs.twimg.com/media/HKOCpBNWMAATjfB?format=jpg&name=large)

## 1.1 Memory Architecture

Hermes maintains multiple distinct memory layers instead of attempting to keep all relevant information inside a single context window. The main types include:

- **Session Memory**: Context that is active during a specific task or conversation. This type of memory is typically short-lived and tied to the current session.
- **Long-term Memory**: Persistent storage of facts, insights, user preferences, and accumulated knowledge that survives across sessions and system restarts. Capped by configurable limits to prevent unbounded growth:

```yaml
memory:
  memory_enabled: true
  user_profile_enabled: true
  memory_char_limit: 2200    # ~800 tokens
  user_char_limit: 1375      # ~500 tokens
```

- **Skill Memory**: Storage of structured, reusable procedures (skills) that the agent has created or refined based on past successful work. Stored as plain markdown files in ~/.hermes/skills/.
- **Session Recall**: FTS5 full-text search with LLM summarization across the entire conversation history. Query any past session:

> Remind me of every business idea we discussed last month. What was the competitor analysis we ran 3 weeks ago?

The multi-layered memory approach is one of the foundational elements that allows Hermes to function more like a persistent system than a typical conversational agent.

**External Memory Providers:**

For use cases that require deeper intelligence beyond built-in memory, Hermes supports 8 external memory provider plugins:

- **Mem0** — knowledge graph + semantic retrieval. Loads only relevant entries per turn. 72% fewer tokens vs naive full injection.
- **Honcho** — two-peer dialectic memory. Builds separate USER + AI observations. Self-host for PII-sensitive environments.
- **Hindsight, Holographic, RetainDB, ByteRover, Supermemory, OpenViking** — additional providers with different architectures.

```text
hermes memory setup
# interactive picker, select provider
hermes memory status
# verify what's active
```

## 1.2 Profiles as Isolated Execution Environments

Profiles in Hermes allow users to create and run multiple separate instances of the agent on the same machine. Each profile maintains its own:

- Configuration and model selection
- Memory stores (both session and long-term)
- Set of installed skills
- Gateway connections and associated credentials
- Session history
- Telegram bot token
- Cron jobs
- State database

```bash
hermes profile create researcher
hermes profile create ops
hermes profile create content-lead
```

Each profile becomes its own command:

```bash
researcher setup    # configure model and API keys
researcher chat     # start a session
researcher gateway start   # connect to Telegram
```

**Example profile configurations:**

```text
researcher:
→ soul.md: deep research only. facts and numbers.
→ model: gpt-5.5 (cheaper, high volume)
→ tools: web search, firecrawl, browser-use

ops:
→ soul.md: admin tasks. calendar, email triage.
   ask for approval before sending anything.
→ model: gpt-5.5 (routine tasks)
→ tools: email, calendar, notion

content-lead:
→ soul.md: produce content. match my voice.
→ model: claude-sonnet-4 (strong writing)
→ tools: X search, web search, analytics
```

**Profile Distribution:**

Profiles can be shared via git. A research agent that works can be distributed to anyone:

```bash
cd ~/.hermes/profiles/researcher
git init && git add . && git commit -m "initial"
git push origin main
```

Anyone can install it:

```bash
hermes profile install github.com/you/researcher
```

They fill in their own API keys. Skills, soul.md, and workflows transfer. Memories and sessions stay per-machine.

Profile isolation is functional and useful for many real-world scenarios. However, it should not be understood as offering the same security or robustness guarantees as process isolation in traditional operating systems.

## 1.3 Kanban as Orchestration and State Management

The Kanban system serves as the primary coordination and state management layer in Hermes. It is responsible for several important functions:

- Creating and tracking tasks
- Managing dependencies between tasks
- Handling state transitions
- Facilitating context transfer when one task or profile hands work off to another
- Recording execution history and outcomes for each task attempt

**Statuses:** Triage → To-Do → Ready → Running → Blocked → Done → Archived

The dispatcher runs every 60 seconds, auto-assigns tasks to available workers, tracks heartbeats, detects zombie processes, and manages retry budgets.

```bash
hermes kanban list    # see the board
hermes kanban swarm   # spawn full multi-agent system:
                      # root orchestrator + parallel workers
                      # + gated verifier + gated synthesizer
                      # + shared blackboard
```

**Morning workflow example:**

```text
/goal here is my to-do list for today:

1. research trending AI topics on X
2. draft 2 posts based on findings
3. check inbox and flag urgent emails
4. pull competitor posts from last 24 hours
5. update content calendar in Notion

add each task to kanban triage.
assign to sub-agents where possible.
send me a summary on Telegram when all tasks are done.
```

One particularly important feature is the "Blocked" state. When a task enters this state, execution pauses until a human provides input or unblocks it. This design makes human oversight a structured and native part of the workflow, rather than an external or ad-hoc intervention.

By treating tasks as first-class objects with preserved context and history, the Kanban layer helps reduce the information loss that commonly occurs during handoffs in multi-agent or multi-step workflows.

## 1.4 Cron Jobs — The Scheduler

Cron jobs are time-based autonomous tasks written in plain English. No crontab syntax required.

This is the layer that transforms Hermes from a reactive tool into a proactive system. Useful information arrives before you ask for it.

**Examples of production cron jobs:**

```text
Every morning at 8am:
send me one AI story worth reacting to on X.

Every 3 hours:
scan X for fresh posts in my niche I should quote tweet.

Every day at 9pm:
check if competitors posted any outlier content today.

Every Monday at 9am:
audit my content board. flag ideas stuck for more than 7 days.

Every Friday at 6pm:
summarize what content shipped this week,
what performed, what didn't, and why.
```

Cron jobs can target specific Telegram topics, specific profiles, and specific delivery platforms (Telegram, Discord, Slack, email).

The Web Dashboard provides a full cron management UI: create, edit, pause, resume, trigger manually, view last run time and next run time.

In OS terms, cron jobs are the scheduler daemon. They ensure the system does work on a predictable cadence without human initiation.

## 1.5 /goal — Persistent Objectives (The Ralph Loop)

A normal prompt asks Hermes for one response. /goal gives Hermes an objective to work toward across multiple turns until a judge model determines the goal is achieved.

The architecture:

- Agent executes one turn toward the goal
- Judge model evaluates: done or continue?
- If continue: agent runs another turn
- If done: goal completes, result delivered
- Default max\_turns: 20. Configurable per task type.
- /goal resume resets the turn counter and continues

```bash
hermes config set goals.max_turns 20    # research, content
hermes config set goals.max_turns 50    # code, multi-step builds
```

**The structured /goal template:**

```text
/goal [OUTCOME]
using [SOURCES]
with constraints: [CONSTRAINTS]
deliverable: [DELIVERABLE]
```

**Example:**

```text
/goal decide the strongest content idea I should publish this week.
using X trending posts in my niche, competitor analysis,
my last 30 days of post performance.
with constraints: avoid repeated angles,
no generic AI hype framing.
deliverable: one final idea with title, hook,
proof assets needed, and a draft outline.
```

**The interview hack — let Hermes write its own /goal:**

```text
I want to use /goal but I don't want a vague goal.
Interview me with only the questions you need.
Then turn my answers into the strongest possible
/goal command. Include the exact outcome, context,
sources, constraints, deliverable,
and when you should stop.
```

Every /goal also becomes a Kanban card automatically, making progress visible on the board.

Core commands:

```text
/goal [description]     # start autonomous execution
/goal status            # check what's running
/goal pause             # pause without losing context
/goal resume            # continue after pause
/goal clear             # end the current goal
/subgoal [text]         # add conditions mid-execution
/undo [N]               # take back the last N turns (new in v0.16.0)
```

## 1.6 Skill Creation Mechanisms

Hermes includes functionality that allows agents to create and store reusable procedures (skills) based on their own activity. When an agent successfully completes certain types of work, it can identify patterns, formalize them, and save them for future use.

Skills are stored as plain markdown files in ~/.hermes/skills/. They are transparent, readable, and editable. No black box.

**Example — a content creation skill:**

```text
Save this as a skill called "content-post":

# Content Post Workflow

1. Check trending topics in AI agents niche via X search
2. Cross-reference with my last 14 days of posts (avoid repeats)
3. Pick the strongest angle based on engagement patterns
4. Write a draft in my voice:
   - ALL CAPS hook
   - arrows → for feature lists
   - No em-dashes, no adverbs, no throat-clearing
5. Score the draft:
   - Hook: does it stop the scroll? (1-10)
   - Bookmark fuel: would someone save this? (1-10)
   - Proof: is every claim backed by a number? (1-10)
6. If any score below 7, rewrite that section
7. Send final draft to Telegram for approval
```

**View all skills:**

```bash
hermes skills
# or
hermes dashboard    # → Skills tab
```

Hermes ships with 60+ built-in tools across terminal, web, browser, vision, image generation, TTS, and code execution. Skills layer on top of those tools to create full workflows.

In v0.16.0, the default skill set was trimmed to what you actually need — leaner out of the box, less noise. NVIDIA skills joined the trusted Skills Hub taps, bringing official CUDA-X, Omniverse, NeMo, and TensorRT-LLM skills into the catalog.

**The compounding effect:**

Agents with 20+ self-created skills finish similar future tasks approximately 40% faster than fresh instances (per Nous Research observations). This compounding is the core differentiator of Hermes.

In practice, the maturity, reliability, and degree of autonomy of skill creation vary significantly. In many cases, especially during early usage or with complex tasks, human review and curation of created skills remain important for achieving high-quality results.

## 1.7 Autonomous Curator — The Garbage Collector

As skills accumulate over weeks and months of usage, redundancy, outdated procedures, and bloat become real concerns. The Autonomous Curator addresses this.

The Curator is a background process that runs on a configurable schedule (default: 7-day cycle). It:

- Identifies redundant or overlapping skills
- Prunes skills that are no longer relevant
- Compresses and consolidates related procedures
- Optimizes the skill library for retrieval efficiency
- Revises skill descriptions for better searchability

In OS terms, the Curator functions as a garbage collector and defragmenter. It prevents the skill filesystem from degrading over time.

This is particularly important because Tool Search (covered below) relies on skill names and descriptions for retrieval. Poorly maintained descriptions degrade search accuracy.

From the NVIDIA NemoTron Labs live stream, Karan from Nous Research confirmed: "The Hermes Curator is an autonomous background feature that manages, cleans, optimizes, revises, improves, and compresses your skill library all the time."

## 1.8 Tool Search — Dynamic Linker

When you connect 15+ MCP servers, their tool schemas consume context window space on every turn — even when most tools are irrelevant to the current task.

Tool Search replaces all MCP/plugin schemas with 3 lightweight bridge tools:

- **tool\_search** — finds the right tool by name and description (BM25 retrieval)
- **tool\_describe** — loads its full schema on demand
- **tool\_call** — executes it

Each bridge tool costs approximately 300 tokens vs thousands for the full schema array.

```yaml
tools:
  tool_search:
    enabled: auto    # default, kicks in at 10% context usage
```

Three modes: **auto** (recommended), **on** (always active), **off** (disabled).

Accuracy on Opus 4 went from 49% to 74% with Tool Search enabled (Anthropic's own tests).

Core Hermes tools (terminal, memory, browser, web search) are never deferred. They stay loaded on every turn.

In OS terms, Tool Search functions as a dynamic linker. Instead of loading every shared library at startup, the system loads them on demand when the running process needs them. This preserves memory (context window) for actual work.

## 1.9 Gateway — The Network Stack

The Gateway is the layer that makes Hermes accessible from anywhere. One gateway process connects the agent to 27+ messaging platforms simultaneously:

Telegram, Discord, Slack, WhatsApp, Signal, SMS, Email, Matrix, Mattermost, Microsoft Teams, Teams Meetings, Google Chat, LINE, DingTalk, Feishu/Lark, WeCom, WeChat, QQ, Yuanbao, BlueBubbles (iMessage), SimpleX, ntfy, Open WebUI, Home Assistant, MS Graph Webhooks, and more.

```bash
hermes gateway start
```

The gateway runs as a single process. Approval buttons are native in Telegram and Slack — the agent can request human confirmation before executing sensitive actions.

**SSEP — Structured Stream-Event Protocol (v0.16.0+):**

The agent no longer streams raw text and hopes platforms can render it. Instead:

1. Agent emits typed events only: MessageChunk, MessageStop, ToolCallChunk, ToolCallFinished, Commentary, LongToolHint, GatewayNotice
2. Gateway router routes each event to the right platform adapter
3. Each adapter renders what it can and silently drops what it can't

Telegram gets animated drafts in MarkdownV2. iMessage drops tool-chrome the user doesn't need to see. Each event is immutable. Ordering is preserved per stream.

In OS terms, the Gateway is the network stack and SSEP is the display server / compositor. The agent produces a universal output format; the rendering layer adapts it per display.

**Remote access:**

The Desktop App can connect to a Hermes backend running on another machine (VPS, home server, behind Tailscale):

```bash
hermes dashboard --host 0.0.0.0
# set username and password via auth gate
# Desktop app connects via URL + credentials
```

One agent running on a VPS. Managed from Desktop on your laptop, CLI via SSH, and Telegram on your phone. All hitting the same memory, skills, and sessions.

## 1.10 Voice Mode — I/O Layer

Voice mode provides speech input and output across CLI and all messaging platforms.

```text
/voice on        # voice-to-voice mode
/voice tts       # always reply with voice
/voice off       # back to text
```

**Five speech-to-text providers:**

- Local faster-whisper (free, runs on device)
- Groq
- OpenAI Whisper
- Mistral Voxtral
- xAI Grok STT

**Five text-to-speech providers:**

- Edge TTS (free, default)
- ElevenLabs
- OpenAI
- NeuTTS (local, free)
- MiniMax

Works in Telegram voice messages, Discord voice channels (live voice conversations with the agent), WhatsApp, Signal, Slack, and CLI.

In OS terms, voice mode is the I/O layer — providing alternative input/output methods beyond text.

## 1.11 Security Layer

Hermes provides multiple security primitives for production deployments:

**Layer 1 — Bitwarden Secrets Manager (Credential Management)**

```bash
hermes secrets bitwarden setup   # wizard: installs bws, prompts for token
hermes secrets bitwarden status  # verify connection
hermes secrets bitwarden sync    # dry-run: see what gets applied
```

One bootstrap token in .env. All real credentials live in Bitwarden. Every Hermes instance pulls secrets at startup. Rotate a key once in the web app — every instance picks it up on next restart. Free tier.

**Layer 2 — iron-proxy Egress Firewall (Credential Protection)**

```bash
hermes egress install   # downloads iron-proxy binary, SHA-256 verified
hermes egress setup     # interactive wizard
hermes egress start     # spawn managed proxy daemon
```

Instead of injecting real credentials into the sandbox, Hermes gives the agent opaque proxy tokens. iron-proxy intercepts at the network boundary, swaps for the real credential, forwards the request. The sandbox never holds the actual key.

**Layer 3 — Promptware Defense**

Protection against Brainworm-class prompt injection attacks. The agent detects and rejects attempts to override its instructions through malicious content in processed documents, web pages, or tool outputs.

v0.16.0 added: CVE-2026-48710 Starlette pin, SSRF off-loop hardening, and subprocess credential stripping. 16 security-tagged issues closed in this release alone.

**Layer 4 — OpenShell (Enterprise, via NVIDIA partnership)**

For enterprise deployments, Hermes integrates with NVIDIA OpenShell and Microsoft security primitives. OpenShell provides:

- Per-user policy gates controlling what the agent can access
- Token masking at egress (agent never sees real credentials)
- Hot-swappable policies without restart
- Admin observability and audit trails

From the NVIDIA NemoTron Labs live stream, Karan from Nous Research: "The ability for me to say, as smart as you might get, there's no way you're getting through this particular gateway, there's no way I'm going to allow you to use the skill that you made because I'm not supervising you in the particular manner that I want to."

## 1.12 Extensibility — Skills Hub and MCP Catalog

**Skills Hub (**[agentskills.io](https://agentskills.io/)**):**Community-contributed skills. Browse, search, install directly from the hub through the dashboard or CLI.

**MCP Catalog:**Curated by Nous Research. Every entry via merged PR. 19,932 skills in the catalog.

```bash
hermes mcp    # interactive picker
```

**NVIDIA Skills:**Official NVIDIA agent skills integrated into the Skills Hub. CUDA-X libraries, Omniverse workflows, NeMo training and inference, TensorRT-LLM optimization, CUDA-Q quantum programming. Mirrored daily from NVIDIA product repos.

In OS terms, the Skills Hub and MCP Catalog function as a package manager. Users can discover, install, and manage capabilities without building them from scratch.

## 1.13 Interface Layer

Hermes can be accessed and managed through multiple surfaces:

**CLI (Command Line Interface):**Full feature parity. Every command, every tool, every configuration option available. The most powerful interface.

```bash
hermes          # start a session
hermes chat     # same as above
hermes doctor   # diagnostic check
hermes dump     # full system state for debugging
hermes status   # visual overview
```

**TUI (Text User Interface):**Rich terminal interface with panels and navigation. Middle ground between CLI power and visual feedback.

**Desktop App (v0.16.0 — "The Surface Release"):**Native Electron app for macOS, Windows, and Linux. Built across 100 PRs and 159 commits in a single week. First demoed at Jensen's GTC keynote.

- Side-by-side preview pane
- Built-in file browser
- Drag-and-drop files directly into chat
- Integrated voice mode
- Inline model picker in the status bar (fuzzy-searchable)
- Concurrent multi-profile sessions
- Settings UI for models, API keys, tools
- Profile management
- Artifacts viewer (every file Hermes creates)
- In-app self-update
- Full Simplified Chinese translation
- Same HERMES\_HOME directory as CLI — sessions transfer seamlessly

Download: [hermes-agent.nousresearch.com/desktop](https://hermes-agent.nousresearch.com/desktop)

If Hermes is already installed:

```bash
hermes desktop
```

**Web Dashboard:**

```bash
hermes dashboard    # opens localhost:9119
```

- Models, cron jobs, skills, profiles, kanban board
- Full browser-based admin panel: MCP catalog, messaging channels, credentials, webhooks, memory management
- Pluggable authentication: OIDC or username/password login
- Fully extensible with themes (YAML) and plugins (JS + Python)
- No data leaves localhost by default

**Messaging Platforms:**27+ platforms through the gateway (covered in section 1.9).

## 2\. The Compounding Effect

The compounding nature of Hermes is its most distinctive property and the primary reason it functions more like an operating system than a typical agent.

**Day 1:** Hermes knows nothing about you. Every task requires full instructions. You explain your workflow, your preferences, your tools. The agent is a blank slate.

**Week 2:** Hermes has accumulated memory about your projects, preferences, and working style. It stops asking questions you've already answered. Tasks that required 10 messages now require 3.

**Month 1:** Hermes has created 15-20 skills from completed work. Your content workflow, your research process, your inbox triage method — each encoded as a reusable procedure. Tasks that took the agent 20 turns on day 1 now complete in 5.

**Month 3:** With 40+ skills and deep memory, the agent operates at a level that cannot be replicated by switching to a better model with a blank context. The accumulated skills, memory, and learned preferences create a compounding advantage that grows with every session.

**The math:**Agents with 20+ self-created skills finish similar future tasks approximately 40% faster than fresh instances. This improvement compounds — each completed task potentially creates or refines a skill that accelerates future work.

**What this means in practice:**

From the NVIDIA NemoTron Labs live stream, Johnny from Nous Research described his actual workflow: "Every morning I initiate a planning session. For every planning session I get a date-key file with things I want to do. The skill looks back for the week and tells me what I've been lacking on or if there's something I said was urgent and I haven't gotten to. At 11pm a cron fires and tells me: did you do what you wanted to do."

This is a system that evolved through use. The morning planning skill, the date-key filing system, the weekly retrospective — none of these were pre-built. They emerged from Johnny's usage patterns and became permanent infrastructure.

Karan, who trained the first Hermes models, uses it for ML ablations: "I really hate doing ablations. It's tedious, time consuming. But it needs to be done. That's how you do science. Hermes does it now. And I don't have to do it."

The compounding effect is the core argument for treating Hermes as infrastructure rather than as an application. Applications provide the same value on day 90 as day 1. Infrastructure improves with investment.

## 3\. Token Economics — What It Actually Costs

Running Hermes as a personal OS has concrete costs. Understanding them is important for sustainable use.

**The agent runtime:**Hermes itself is free and open source (MIT license). The cost comes from model inference and infrastructure.

**Infrastructure options:**

![Image](https://pbs.twimg.com/media/HKOE0PlW0AInCtv?format=png&name=large)

**Minimum** VPS specs: 2 vCPU, 2GB RAM for light use.

**Recommended**: 4 vCPU, 8GB RAM for heavy use. No GPU needed — Hermes calls APIs, not the model directly.

**Model provider options:**

![Image](https://pbs.twimg.com/media/HKOE3xoWQAA1NKm?format=png&name=large)

**X API costs (pay-per-use since February 2026):**

![Image](https://pbs.twimg.com/media/HKOE7c8WgAARw2t?format=png&name=large)

Alternative: OpenTweet MCP at $5.99/month flat.

**Realistic monthly budgets:**

The token estimates below are approximations based on typical session patterns. Actual consumption depends on model, task complexity, tool output volume, and configuration. Use **/usag**e inside Hermes to measure your real numbers

Running the full content system described in this article (5 daily cron jobs, 2 content sessions/day with /goal, daily sub-agent research, kanban tracking) consumes approximately 10-11M tokens/month. Here is what that costs depending on your model strategy:

![Image](https://pbs.twimg.com/media/HKOFBmoWQAAIJd1?format=png&name=large)

The same system that costs $27/month on GPT-5.5 costs $250/month on Claude Opus. A 10x difference for the same cron jobs, the same /goals, the same sub-agents.

**Why this matters:** Hermes is model-agnostic. You pick the model per profile, per task. Routine cron jobs that scan X for trending posts do not need Opus-level reasoning. A $0 GPT-5.5 call does the same job. Reserve the expensive model for the one /goal per day where writing quality or deep reasoning makes a real difference.

**The cheapest complete path:**

![Image](https://pbs.twimg.com/media/HKOG3jlXgAABA_A?format=png&name=large)

That is a 24/7 autonomous agent with 5 daily cron jobs, persistent memory, self-improving skills, kanban task tracking, and Telegram access from your phone.

Compare: a virtual assistant doing the same work costs $500-2,000/month. A content agency costs $3,000-8,000/month.

**Note on Nous Portal:** The Plus tier ($20/month, $22 credits) works well for light usage (1-2 cron jobs, a few sessions per day). For the full content system described here, the Super tier ($100/month, $110 credits) or bring-your-own-keys is more realistic.

**Token optimization (6 methods to reduce costs):**

1. **Compact file reader** — 14% fewer tokens per file read (automatic in latest version)
2. **Prompt caching** — ~75% reduction on multi-turn sessions (Anthropic models only)
3. **/compress** — summarizes session history, drops overhead
4. **Tool Search** — loads schemas on demand instead of upfront
5. **Subagent delegation** — each subagent in own context, only summaries return
6. **Retrieval-based memory** — 72% fewer tokens vs naive full injection

**Fastest path to a working agent:**

```bash
hermes setup --portal
```

One OAuth covers model + web search + image generation + TTS + cloud browser. No separate API keys needed.

## 4\. How The Layers Chain Together

These layers compound when stacked. Here is one chain running end-to-end:

```text
8:00 AM — Cron job fires.

The content-lead profile wakes up
and starts a /goal with structure:

"find the 3 strongest content angles for today
using X trending data and my last 14 days of posts."

It spawns 3 sub-agents:
→ sub-agent 1 scans X for trending posts
→ sub-agent 2 pulls recent post performance
→ sub-agent 3 checks competitor accounts

Tool Search loads only the tools each sub-agent needs.
Prompt caching keeps system prompt costs low.
Each sub-agent runs in its own context (delegation).

All three become kanban cards.
Dispatcher tracks them in parallel.

Sub-agents finish. Content-lead runs
the content-post skill to draft 2 posts.

Drafts land in the Content topic
in Telegram for approval.

User taps approve on one. Reject the other.
The approved post publishes via xurl.

10 minutes later a competitor publishes
a reaction to the same topic.
A webhook fires.
Hermes drafts a follow-up angle
and sends it to the React topic.

Everything visible on the dashboard.
What ran, what shipped, what's pending.

At 11pm, the daily review cron fires.
Session search pulls the day's work.
Summary delivered to Telegram.
```

One day. Nine architectural layers fired. Two posts shipped. Zero manual research. Total API cost: approximately $2-4.

## 5\. Key Characteristics

**Persistence**

Hermes is explicitly designed to retain information across sessions through its memory system. This allows accumulated context and created skills to persist over time, rather than being lost after each session or restart.

**Isolation and Coordination**

The combination of Profiles and Kanban allows Hermes to support both isolation and structured collaboration. Profiles provide separation between different workloads, while Kanban enables controlled handoff and context transfer when collaboration is required.

**Self-Improvement Mechanisms**

The presence of skill creation functionality provides Hermes with a pathway for structural self-improvement. Unlike systems that rely solely on prompt engineering or manual tool definitions, Hermes can expand its own capabilities based on usage patterns. The Autonomous Curator ensures the skill library stays clean and efficient over time.

**Human Oversight as a Native Feature**

Human intervention is implemented as a first-class concept through the Blocked task state in Kanban and approval buttons in Telegram and Slack. This allows the system to pause execution cleanly, preserve context, and resume intelligently once the required input is provided.

## 6\. Practical Considerations

When using Hermes as infrastructure rather than as a simple conversational tool, several practical factors become important:

- The long-term value of the system depends heavily on how memory and created skills are managed, curated, and maintained over time. The Autonomous Curator helps, but periodic human review improves quality.
- Profile isolation is useful but requires deliberate configuration. It is not automatic and does not provide the same guarantees as traditional process isolation.
- The quality and usefulness of autonomously created skills can vary significantly. In many cases, especially early on, human review improves outcomes.
- Resource consumption, particularly model context windows and inference costs, should be actively monitored. Use /usage and /compress regularly. Enable Tool Search for heavy MCP setups.
- The effectiveness of the overall system is highly dependent on thoughtful configuration and ongoing management, rather than emerging automatically from simply running the software.
- Token economics should be understood before committing to heavy usage patterns. Start with Nous Portal Plus at $20/month and scale from there.

**Token-Aware Configuration**

Running Hermes as a full OS with multiple profiles and cron jobs consumes tokens on every session startup (system prompt + memory + skills index). Without optimization, costs can grow faster than expected.

**Use the right model for the right job:**

Not every task needs the strongest model. Matching model to task type is the single biggest cost lever.

```text
content-lead profile:
→ model: claude-sonnet-4 (strong writing, moderate cost)

researcher profile:
→ model: gpt-5.5 (cheaper, high volume via Codex at $0)

ops profile:
→ model: gpt-5.5 (routine tasks, cost-efficient)

code-reviewer profile:
→ model: claude-opus-4-8 (only for complex reasoning)
```

Use frontier models (Opus, GPT-5.5) for complex /goals. Use cheaper models for daily cron jobs and routine triage. One switch cuts your monthly bill in half.

**Lower memory limits for lightweight profiles:**

Default memory injection is 2,200 chars (~800 tokens) per turn. In a 50-turn /goal session, that is 40K tokens spent repeating memory. For profiles that don't need deep personal context:

```bash
hermes config set memory.memory_char_limit 1000
hermes config set memory.user_char_limit 500
```

**Set realistic max\_turns:**

```bash
# research and content (shorter, focused)
hermes config set goals.max_turns 20

# code tasks (longer, needs more iterations)
hermes config set goals.max_turns 50
```

50 turns on Opus can cost $5-12 per session. Set max\_turns per profile, not globally. Research profiles rarely need more than 20.

**Enable all 6 token optimizations:**

```yaml
tools:
  tool_search:
    enabled: auto    # loads schemas on demand

memory:
  memory_char_limit: 2200    # lower if not needed
  user_char_limit: 1375      # lower if not needed
```

Plus: prompt caching (automatic on Anthropic), /compress for long sessions, subagent delegation for parallel work.

**Use cheap auxiliary models for side-jobs:**

Hermes offloads compression, vision, web summarization, approval scoring, tool routing, and session titles to auxiliary models. Each slot is configurable independently. Use a cheap fast model for these while keeping your expensive model for main work:

```bash
hermes model
# set main model: claude-sonnet-4 (quality)
# set auxiliary: a fast cheap model (compression, routing)
```

This means **/compress** and auto-compression run on cheap tokens, not on your main model's pricing.

**Tune the compression threshold:**

```yaml
compression:
  threshold: 0.50    # default: compress at 50% of context window
```

Lower this to 0.30-0.40 for more aggressive compression. Sessions stay lighter, fewer tokens accumulate before the compressor fires.

**Lossless Context Management (LCM):**

```yaml
context:
  engine: "lcm"    # plugin, replaces default lossy compression
```

The default compressor is lossy — it summarizes and drops older context. LCM is a plugin alternative that preserves all context without loss while still optimizing token usage. Available via **hermes plugins → Context Engine.**

**Monitor with /usage:**

```text
/usage
```

Run this regularly. Compare token counts across sessions. If a cron job burns more tokens than expected, simplify its prompt or switch it to a cheaper model.

**Cost scaling by setup complexity:**

These are estimated ranges. Run **/usage** in Hermes to compare against your actual numbers.

![Image](https://pbs.twimg.com/media/HKOIDN3XMAEjtY3?format=png&name=large)

The cheapest path: run everything through GPT-5.5 via Codex ($20/month ChatGPT subscription, inference included). Reserve Claude or Opus for the sessions where reasoning quality makes a measurable difference in your output.

## 7\. Current Limitations (as of June 2026)

Hermes possesses several meaningful architectural strengths, but it remains an evolving system rather than a fully mature personal operating system:

- The native Desktop App significantly improves accessibility, but it does not yet provide full feature parity with the CLI/TUI for all tool interactions, particularly complex browser automation and certain local integrations.
- Running large numbers of concurrent agents or very long-running workflows can place substantial pressure on model context windows and inference resources. Careful resource management is often required.
- Profile isolation is practical and functional for many use cases, but it does not offer the same level of robustness or fault isolation as process isolation in traditional operating systems.
- Autonomous skill creation is a promising direction, but its maturity and reliability remain variable. High-quality, reusable skills often still require human curation, particularly for complex or high-stakes tasks.
- Auto-compaction during long sessions can cause context loss. The Autonomous Curator and session recall are partial solutions. Keeping full thread in context for the window's life prevents silent drift but limits session length.
- Some advanced tool integrations may still be more stable when used through the CLI/TUI rather than through the Desktop App or messaging interfaces.
- The SSEP gateway protocol is new (v0.16.0). Edge cases in per-platform rendering may exist for less common messaging platforms.

These limitations are primarily related to implementation maturity rather than fundamental architectural shortcomings. The project continues to develop actively. The v0.16.0 "Surface Release" alone included 874 commits, 542 merged PRs, and contributions from 170 community members. The prior v0.15.0 "Velocity Release" included 1,302 commits, 747 merged PRs, and 321 contributors.

## 8\. How Hermes Compares to Other Agent Frameworks

The most common question when evaluating Hermes: how does it compare to Claude Code, OpenClaw, and CrewAI? The answer is that they solve different problems and are built on different philosophies.

![Image](https://pbs.twimg.com/media/HKOIeOBWgAANIGG?format=jpg&name=large)

![Image](https://pbs.twimg.com/media/HKOImkBXoAA3DVk?format=png&name=large)

**The mental model that works (from builders who use all three):**

Claude Code is your daily driver at your desk. Best raw coding agent available. If the job is "write code, refactor code, debug code, understand this codebase," Claude Code wins.

Hermes Agent is your 24/7 infrastructure. It runs while you sleep, manages multiple workloads through profiles, compounds through skills and memory, and reaches you on Telegram from anywhere.

OpenClaw is your chat-first assistant. Largest marketplace, easiest managed hosting ($3/month), strongest non-technical user experience.

CrewAI is your orchestration framework. When you need multiple specialized agents working together on a defined pipeline in Python. Not a standalone agent — a framework for building multi-agent systems.

**One benchmark that illustrates the difference:**

An independent test ran the same 18 prompts through Claude Code (Opus 4.7), OpenClaw (Sonnet 4.6), and Hermes Agent. Hermes won 14 of 18. The 4 it lost were raw coding tasks where Claude Code's codebase understanding is unmatched. The 14 it won were tasks where memory and context from previous sessions made the difference.

The takeaway: Hermes wins when history matters. Claude Code wins when code depth matters. They are complementary, not competing.

Hermes ships **hermes claw migrate** — a built-in migration command from OpenClaw. When a product ships a named migration command for a specific competitor, the positioning is clear.

## 9\. Start Here

If you read this entire article and want to start, here are three paths based on your situation.

**Path 1 — I have 15 minutes (fastest to first result):**

```bash
# install
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# one-command setup (model + tools + gateway)
hermes setup --portal

# connect Telegram
# message @BotFather → /newbot → copy token
# paste token when hermes setup asks for it

# set your first cron job
hermes chat
> "every morning at 8am send me a summary
   of trending AI news to Telegram"

# done. tomorrow morning you'll have a briefing
# without opening a browser.
```

**Path 2 — I have an evening (full personal setup):**

1. Install Hermes and run **hermes setup --portal**
2. Connect Telegram (BotFather → token → paste)
3. Create your first profile: **hermes profile create work**
4. Write a soul.md that defines how the agent should behave
5. Set 3 cron jobs (morning briefing, competitor check, daily review)
6. Run your first **/goal** with the structured template:

```text
/goal [outcome] using [sources]
with constraints: [constraints]
deliverable: [deliverable]
```

7\. Open the dashboard: **hermes dashboard**

**8\.** Review skills after a week. Delete weak ones. Refine strong ones.

**Path 3 — I want the full OS (weekend project):**

1. Spin up a Hetzner CX22 VPS (~$7/month)
2. Install Hermes on the VPS via SSH
3. Run **hermes setup --portal**
4. Connect Telegram gateway: **hermes gateway start**
5. Create 3-4 profiles (content, research, ops, code)
6. Write soul.md for each profile
7. Set up cron jobs per profile
8. Configure Kanban for cross-profile task tracking
9. Install the Desktop app on your laptop
10. Connect Desktop to the remote backend via auth gate
11. Enable Tool Search in config.yaml
12. Lower memory char limits for token optimization
13. Set up Bitwarden Secrets Manager for credentials
14. Run for one week. Review skills, memory, and token usage.
15. Iterate. The system compounds from here.

**Priority order if overwhelmed:**Start with cron jobs (#3 in 10-hack article), /goal structure (#4), and skills (#8). These three setups change how Hermes feels overnight.

## Conclusion

Hermes Agent represents one of the more architecturally ambitious attempts among current open-source agent frameworks to move beyond simple conversational or tool-calling interfaces. Its combination of persistent memory, profile-based isolation, structured task orchestration through Kanban, plain-English cron scheduling, persistent /goal objectives, dynamic tool loading, multi-platform gateway access, voice interaction, production security primitives, and mechanisms for creating reusable procedures gives it characteristics that align more closely with the concept of a personal operating system than most other systems available today.

Karan from Nous Research, who trained the first Hermes models, described it simply: "Hermes Agent is the ability to take a language model and realize that everything that happens on your computer is text in or text out. Hermes Agent lets you do that with all the integrations on your computer. It can use your browser, your apps, everything you do on the computer. It's a general automator, general simulator of computer actions and digital actions."

At the same time, it is important to maintain realistic expectations. Hermes is not yet a fully mature personal AI operating system. Its architectural direction is promising, but real-world effectiveness still depends heavily on careful configuration, ongoing management, and an honest assessment of feature maturity.

When used thoughtfully as infrastructure, Hermes can serve as a foundation for building long-term, evolving AI-assisted workflows that compound in capability over time. The meaningful difference lies in how deliberately the system's capabilities and limitations are understood and utilized.

The agent is ready. The stack is ready. The value compounds with use.

## Related Articles

- [HERMES AGENT: THE COMPLETE GUIDE](https://x.com/IBuzovskyi/status/2059675518966894767?s=20) — installation, models, dashboard, use cases, security
- [The Complete Hermes /goal Playbook — 21 Workflows](https://x.com/IBuzovskyi/status/2059303967767593247)
- [Hermes /goal — The Full Guide](https://x.com/IBuzovskyi/status/2056764150936748082)
- [How to Make Hermes + xurl Actually Work as a System](https://x.com/IBuzovskyi/status/2057114309616885997)
- [Hermes x Bitwarden — The Security Stack](https://x.com/IBuzovskyi/status/2057914816015249515)
- [10 Hermes Agent Setups](https://x.com/IBuzovskyi/status/2062101068842975409?s=20)

Expanded versions and additional Hermes content on Substack: [https://substack.com/@yanxbt](https://substack.com/@yanxbt)

This article is based on publicly available Hermes Agent documentation (v0.16.0 "The Surface Release"), the NVIDIA NemoTron Labs live stream, and observed system behavior as of June 2026.

[@NousResearch](https://x.com/@NousResearch) [@Teknium](https://x.com/@Teknium)