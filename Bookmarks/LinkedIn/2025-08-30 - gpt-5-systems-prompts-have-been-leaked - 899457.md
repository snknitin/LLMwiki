---
title: "GPT-5 systems prompts have been leaked"
saved: "August 30, 2025 8:57 AM"
date: "2025-08-30"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7360416940042899457/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7360416940042899457%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7360416940042899457"
notion_tags: "Context, Prompt"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, context, prompt]
---

# GPT-5 systems prompts have been leaked

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7360416940042899457/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7360416940042899457%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved August 30, 2025 8:57 AM · tags: Context, Prompt

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7360416940042899457/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7360416940042899457%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

GPT-5 systems prompts have been leaked, and it's a gold mine of new ideas on how to prompt this new kind of LLM!  Let me break down the gory details!

Here are the new patterns that we've found in OpenAI's prompting guide

Agentic Eagerness Dial
A tunable balance between proactivity and deference, steered via explicit prompts (“less eagerness” vs “persistence”) and the reasoning_effort knob.
Tool-Budget Governor + Escape Hatch
Hard caps on total tool calls (e.g., ≤2) paired with permission to proceed under uncertainty (“even if it might not be fully correct”) to keep latency predictable.

Parallel Fan-Out with Early-Stop
A context-gathering template: launch diverse queries in parallel, dedupe, and stop as soon as convergence/actability criteria are met; at most one refined batch if signals conflict.
Single-Escalation Rule
After the first fan-out, allow exactly one refined pass, then act—prevents infinite “just one more search” loops.

Autonomous Completion Contract
“Keep going until the user’s query is completely resolved.” Don’t bounce questions back; pick reasonable assumptions, execute, and document after.
Tool Preamble Telemetry
Short, user-visible narration before/during tool calls (goal → plan → stepwise progress → done), with configurable frequency/verbosity.

Reasoning Continuity (Responses API)
Persist and reuse prior reasoning traces across turns (previous_response_id) for cheaper, faster, more coherent multi-step agent runs.
Dual-Knob Control: Thinking vs Output
Separate levers for how hard to think (reasoning_effort) and how much to say (verbosity), including modality-scoped verbosity (low in chat, high in code tools).

Turn-Scoped Subtasks
Break long problems into discrete turns, one concrete subtask per turn, to improve reliability and checkpointing of agent progress.
Environment-Aware Autonomy
Prime the agent with product/runtime affordances (e.g., Cursor’s Undo/Reject) so it can act more boldly knowing errors are reviewable.

Spec-Tagged Instruction Blocks
Use structured XML-style sections (e.g., <tool_preambles>, <context_understanding>) to anchor adherence and allow easy cross-reference.
Prompt Contradiction Linter
Systematically detect and resolve conflicting rules (adversarial prompt examples + hierarchy fixes) to avoid wasted “reconcile the irreconcilable” reasoning.

Tool-Specific Risk Gates
Different uncertainty thresholds per tool (e.g., search = permissive, checkout/delete = strict), plus explicit stop/hand-back conditions.
Minimal-Reasoning Scaffolding
For the fastest mode, compensate with explicit planning prompts, richer preambles, and stricter tool disambiguation to prevent premature stops.

...
