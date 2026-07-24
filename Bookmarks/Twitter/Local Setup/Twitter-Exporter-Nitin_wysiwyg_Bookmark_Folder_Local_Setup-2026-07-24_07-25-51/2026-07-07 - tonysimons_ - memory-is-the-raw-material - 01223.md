---
title: "Memory Is the Raw Material"
author: "Tony Simons"
username: "@tonysimons_"
date: "2026-07-07"
tweet_url: "https://x.com/tonysimons_/status/2074634038007001223"
tweet_type: "original"
likes: 99
retweets: 18
replies: 4
bookmarks: 215
views: 10117
has_media: false
extraction_quality: full
article_id: "2074293065133461505"
tags: ["twitter-bookmark", "claude", "llm", "agents"]
---

# Memory Is the Raw Material

> **Source:** [@tonysimons_](https://x.com/tonysimons_) · 2026-07-07 · 👍 99 · 💬 4 · 🔖 215 · 👁 10117

> 🔗 [View tweet on X](https://x.com/tonysimons_/status/2074634038007001223)

## Article Content

The first two articles covered the engine ([the agent loop](https://x.com/tonysimons_/status/2073880068657471523)

) and the chassis ([deployment and setup](https://x.com/tonysimons_/status/2074253518224109718)

). The engine fires. The chassis is stable. Now the question is: does it actually get better over time?

That's not a rhetorical question.

Most AI tools ship at a fixed capability level and stay there. ChatGPT today knows roughly what it knew last week. Claude Code is the same Claude Code it was on install day. The model vendor might ship an update, but the tool itself doesn't learn from your work.

Hermes Agent does. Not because the model trains on your data. Because of three systems that work together to accumulate, formalize, and maintain what the agent learns about you, your projects, and your workflows.

## Memory Is the Raw Material

https://x.com/tonysimons_/article/2074634038007001223/media/2074312272541880321

Memory in Hermes isn't a log of everything that happened. It's a small, curated set of facts that the agent keeps in context at all times.

The system maintains two files.

- MEMORY.md holds the agent's personal notes -- environment facts, project conventions, tool quirks, completed work.
- USER.md holds your profile -- preferences, communication style, technical level, pet peeves.

Together they're capped at roughly 1,300 tokens. That's tight by design.

### Here's how memory actually behaves:

The agent writes to memory automatically when it learns something durable.

You correct it about a convention? 
It saves that.

It discovers your project uses Go 1.22 and sqlc? 
It saves that.

You ask it to remember your API key rotation schedule? 
It saves that.

### Memory is a frozen snapshot at session start.

Everything the agent remembers is loaded into its system prompt as a block of text, available immediately from the first message.

Mid-session memory changes are persisted to disk but don't appear in the prompt until the next session.

This keeps the prompt prefix stable for provider-side caching.

When memory gets full -- and at 2,200 characters for MEMORY.md, ****it will**** -- the agent doesn't silently drop entries. The tool returns an error with the current entries and usage count.

The agent then consolidates: merging related entries into shorter ones, removing stale facts, making room for the new information.

The error message shows exactly what's in memory so the agent can decide what to keep and what to cut.

Memory costs tokens in every prompt, so the agent has to decide whether a fact is important enough for permanent storage.

Session search costs nothing until you run a query.  The agent uses session search for recall -- "what did I learn about project X last week?" -- and saves to memory only what should always be in context.

## Skills Are the Procedures

https://x.com/tonysimons_/article/2074634038007001223/media/2074313091488075777

Memory stores facts. Skills store procedures.

When the agent solves a novel problem in a multi-step workflow -- five or more tool calls, significant back-and-forth, a correction from you -- it can save the approach as a skill.

The skill becomes a markdown file in ~/.hermes/skills/ with a name, description, step-by-step procedure, pitfalls section, and verification steps.

Skills use progressive disclosure to minimize token overhead. At session start, only the skill index is loaded -- a compact list of names, descriptions, and categories.

The agent calls skill_view(name) to load a skill's full content only when it actually needs it. Calling skill_view(name, path) loads supporting files like templates or scripts. Most skills are never loaded in most sessions. The token cost is just the index.

Multiple skills can be stacked in a single command. Running /github-pr-workflow /test-driven-development fix issue #123 loads both skills into the context.

The agent follows both sets of instructions for the same task. For workflows you repeat constantly, skill bundles let you group several skills under a single slash command.

https://x.com/tonysimons_/article/2074634038007001223/media/2074313986825195520

Skills come from three places.

- ****Bundled skills**** ship with Hermes and cover common workflows like code review, PR management, and research.
- ****Hub skills ****are community-contributed and installable from the Skills Hub.
- ****Agent-created skills**** are the ones the agent writes itself -- the procedural memory of your specific work patterns.

### The Background Review Is Invisible Infrastructure

Memory and skills don't just accumulate passively. After every conversation turn, Hermes forks a background review that examines what happened.

The fork runs as a separate AI agent in its own prompt cache. It never touches the active conversation.

It reviews the turn for things worth remembering: corrections you made, workflows you walked through, facts about your environment. If it finds something, it proposes a memory save or a skill patch.

This is the part of the system that makes the learning loop feel like magic.

You correct the agent once about how your project is structured. The background review catches the correction and saves it to memory.

Next session, the agent has that fact in context from the first message. You never have to say it again.

The write-approval gate lets you control this.

With memory.write_approval: true or skills.write_approval: true, every background review proposal is staged instead of committed.

You review with /memory pending or /skills pending, approve the ones that look right, reject the ones that don't. It's a safety valve for environments where you want to audit what the agent learns about you.

The background review can also run on a cheaper model. By default it uses your main chat model (which has the conversation warm in its prompt cache, so it's effectively free cache reads).

If you're running an expensive model, you can route the review to a smaller one with no meaningful quality difference. In benchmarks, memory capture was identical and skill capture was near-identical.

### The Curator Prevents Skill Rot

https://x.com/Teknium

****Teknium ****@Teknium

·

[Apr 30](https://x.com/Teknium/status/2049717907664581067)

Introducing Hermes Curator!   

The new system built in to Hermes Agent now helps you keep your skills that the self improvement loop creates in check, by consolidating and pruning automatically.

The curator does multiple things:

- keeps track of how often you use each skill,

https://x.com/Teknium/status/2049717907664581067/photo/1

The curator is the garbage collector for skills. It runs on a ticker -- every 7 days by default, when the agent has been idle for at least 2 hours

The deterministic phase transitions skills through a lifecycle. Unused for 30 days becomes stale. Unused for 90 days gets archived to ~/.hermes/skills/.archive/.

Nothing is ever deleted -- archival is recoverable with hermes curator restore <name>.

The optional LLM phase runs an auxiliary-model review. The forked agent surveys your skill library, identifies overlapping skills, proposes umbrella skills that consolidate narrow ones, and patches drift.

This phase is off by default because it costs tokens. You opt in with curator.consolidate: true or trigger it on demand with hermes curator run --consolidate.

Pinning protects critical skills. hermes curator pin <name> prevents any automated transition, archival, or deletion.

Patches and edits still go through, so the agent can improve a pinned skill's content over time, but the skill itself can never be automatically removed.

Before every curator run, a tar.gz snapshot of the entire skills directory is saved. Any run can be rolled back with hermes curator rollback. The rollback itself is reversible.

## How the System Compounds

https://x.com/tonysimons_/article/2074634038007001223/media/2074319256217419777

### Here's what ties the learning loop together:

Memory and skills are both injected into the prompt -- memory in the volatile tier (frozen per session), skills in the stable tier (always present as an index). The agent can see both at all times.

When the agent encounters a problem, it checks memory for relevant facts and loads matching skills. It executes the skill's procedure, possibly calling multiple tools.

The results feed back into the conversation. The background review examines the turn, identifies what worked, and saves it: a new memory entry for a discovered fact, a skill patch for a refined procedure.

Over multiple sessions, the cycle repeats.

Memory consolidates as it fills. Skills are curated as they age. The curator removes what stopped being useful. The agent has fewer, better entries to work with.

This is why the deployment and session decisions in Part 2 of this Master Class matter.

The learning loop only works if sessions persist. If every conversation starts from zero -- no memory, no skills, no context -- the agent can't compound. It learns in the session, forgets on restart, and never gets better.

The learning system is the product. 
The agent loop is the engine that runs it.

Without the learning system, you have a chatbot with tool access. 
With it, you have something that genuinely gets better at your work, on your machine, over time.

Memory captures what. 
Skills encode how. 
Both are static until you create them.

The next article is about writing skills that actually work -- not as theory, but as executable playbooks the agent can run without handholding.

Stay tuned!

> 📄 Original article URL: https://x.com/i/article/2074293065133461505

---

## Commentary from Other Bookmarks

### @tonysimons_ (Tony Simons) — 2026-07-08

> Part 3 is live. 🪽
> 
> This is the one where Hermes stops feeling like a chatbot with tools and starts making sense as a system that improves.
> 
> ⚕️ Memory captures what matters.Skills encode how to do the work again.
> ⚕️ The background review turns useful corrections into durable knowledge.
> ⚕️ The curator keeps the skill library from turning into a junk drawer.
> 
> That’s the learning loop.
> 
> A local system that remembers, formalizes, prunes, and gets better at your actual workflows over time.
> 
> Hermes Agent Master Class Part 3: The Learning System 👇

[→ View quote tweet](https://x.com/tonysimons_/status/2074649089942106359)

