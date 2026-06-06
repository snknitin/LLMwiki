---
title: "what's everybody using for global agent rules/instructions now?"
author: "Ian Nuttall"
username: "@iannuttall"
date: "2026-01-03"
tweet_url: "https://x.com/iannuttall/status/2007400556898463824"
tweet_type: "original"
likes: 194
retweets: 2
replies: 40
bookmarks: 307
views: 215018
has_media: false
extraction_quality: full
tags: ["twitter-bookmark", "claude", "agents"]
---

# what's everybody using for global agent rules/instructions now?

> **Source:** [@iannuttall](https://x.com/iannuttall) · 2026-01-03 · 👍 194 · 💬 40 · 🔖 307 · 👁 215018

> 🔗 [View tweet on X](https://x.com/iannuttall/status/2007400556898463824)

## Tweet Content

what's everybody using for global agent rules/instructions now?

- AGENT.⁠md/CLAUDE.⁠md
- SKILL.⁠md
- something else

example: should my commit rules be in a global file loaded into context on every request (in theory!) or a skill that gets loaded when i say "commit this"?

---

## Commentary from Other Bookmarks

### @elliotarledge (Elliot Arledge) — 2026-01-04

> ~ ❯ cat ~/.claude/CLAUDE.md
> <claude-instructions>
> 
> <python>
>   Use uv for everything: uv run, uv pip, uv venv.
> </python>
> 
> <principles>
>   <style>No emojis. No em dashes - use hyphens or colons instead.</style>
> 
>   <epistemology>
>     Assumptions are the enemy. Never guess numerical values - benchmark instead of estimating.
>     When uncertain, measure. Say "this needs to be measured" rather than inventing statistics.
>   </epistemology>
> 
>   <scaling>
>     Validate at small scale before scaling up. Run a sub-minute version first to verify the
>     full pipeline works. When scaling, only the scale parameter should change.
>   </scaling>
> 
>   <interaction>
>     Clarify unclear requests, then proceed autonomously. Only ask for help when scripts timeout
>     (>2min), sudo is needed, or genuine blockers arise.
>   </interaction>
> 
>   <ground-truth-clarification>
>     For non-trivial tasks, reach ground truth understanding before coding. Simple tasks execute
>     immediately. Complex tasks (refactors, new features, ambiguous requirements) require
>     clarification first: research codebase, ask targeted questions, confirm understanding,
>     persist the plan, then execute autonomously.
>   </ground-truth-clarification>
> 
>   <spec-driven-development>
>     When starting a new project, after compaction, or when http://SPEC.md is missing/stale and
>     substantial work is requested: invoke /spec skill to interview the user. The spec persists
>     across compactions and prevents context loss. Update http://SPEC.md as the project evolves.
>     If stuck or losing track of goals, re-read http://SPEC.md or re-interview.
>   </spec-driven-development>
> 
>   <first-principles-reimplementation>
>     Building from scratch can beat adapting legacy code when implementations are in wrong
>     languages, carry historical baggage, or need architectural rewrites. Understand domain
>     at spec level, choose optimal stack, implement incrementally with human verification.
>   </first-principles-reimplementation>
> 
>   <constraint-persistence>
>     When user defines constraints ("never X", "always Y", "from now on"), immediately persist
>     to project's local http://CLAUDE.md. Acknowledge, write, confirm.
>   </constraint-persistence>
> </principles>
> 
> <machines>
>   `ssh macbook` - MacBook Pro
>   `ssh theodolos` - local workstation, RTX 3090
>   Check which machine we are currently on before using these.
> </machines>
> 
> </claude-instructions>

[→ View quote tweet](https://x.com/elliotarledge/status/2007752112361685197)

