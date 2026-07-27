---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#4. Jarvis and Alfred]]"
status: concept
difficulty: hard
priority: p1
category: personal agents
form_factor:
  - desktop assistant
  - mobile chat
  - voice interface
deployment: desktop plus DGX Spark
source_ideas:
  - Jarvis and Alfred as executive assistants
tags:
  - agents
  - executive-assistant
  - local-models
---

# Jarvis and Alfred

> A two-role executive-assistant system: Jarvis handles fast operational execution; Alfred protects priorities, context, relationships, and long-term judgment.

## Product Outcome

The separation makes the system legible. Jarvis turns requests into bounded tasks, gathers information, prepares drafts, and runs approved tools. Alfred maintains the weekly agenda, notices neglected commitments, challenges overload, and asks whether a task should exist at all.

## Personal V0

- Unified inbox for typed, voice, email-forwarded, and Telegram requests.
- Jarvis produces a plan, tool list, risk level, and preview before action.
- Alfred generates a morning brief and weekly review from calendar, tasks, and chosen goals.
- Both share a structured memory of projects, people, commitments, and preferences with source timestamps.
- Low-risk actions may be prepared automatically; external changes require approval.
- Every action has a receipt: inputs, tool calls, outputs, and rollback or follow-up.
- A “why do you know this?” command reveals memory provenance.

## Build Boundary

**MVP:** local chat, read-only calendar/tasks, file search, draft creation, and an approval queue.

**Later:** email sending, calendar writes, travel, purchases, calls, and mobile voice. Never grant broad shell, financial, or messaging permissions to an unbounded conversational agent.

## Existing Products, Building Blocks, and Shortcuts

- [Home Assistant Assist pipelines](https://developers.home-assistant.io/docs/voice/pipelines/) already model wake/input → speech-to-text → intent/conversation → text-to-speech for a local voice assistant. Reuse it when voice becomes necessary.
- [Open WebUI](https://docs.openwebui.com/) is a ready local interface for Ollama/OpenAI-compatible models, tools, knowledge, and agent experiments; it can validate commands before a bespoke shell.
- [Model Context Protocol](https://modelcontextprotocol.io/specification/) standardizes tools/resources, and [n8n](https://github.com/n8n-io/n8n) supplies many deterministic connectors. Keep MCP/n8n behind typed `read`, `propose`, and `commit` wrappers.
- Simplest alternative: keyboard-driven daily brief plus command palette. “Jarvis” and “Alfred” can be two modes over one memory and permission system; personality must never change authority.

## Free-First Stack

- **Interface:** Open WebUI or a small local web/desktop client for rapid iteration.
- **Agent runtime:** explicit Python state machines or LangGraph for durable, inspectable workflows.
- **Automation:** n8n for deterministic connectors and human approvals.
- **Data:** Postgres/SQLite for entities and events; full-text search before vector memory.
- **Models:** Ollama for routing/drafting; vLLM on DGX Spark for larger local models; paid provider only for opt-in hard tasks.
- **Voice:** faster-whisper plus Piper/another local TTS, with push-to-talk first.
- **Secrets:** OS keychain or dedicated secret store; per-tool scopes and allowlists.

## Authority Model

Classify tools as read, draft, reversible write, consequential write, and prohibited. Model output never directly invokes consequential tools; a policy layer checks a typed action and asks for confirmation showing the exact diff. Memory has expiry, sensitivity, and source fields.

## Build Slices

1. Request inbox, task schema, and action receipts.
2. Read-only calendar/file tools.
3. Jarvis planning and draft workflows.
4. Alfred daily/weekly review.
5. Memory provenance and correction.
6. Reversible writes with approvals and idempotency.
7. Voice and remote access.

## Success Measures

- Requests never disappear without a final state.
- The assistant reduces planning/admin time measurably.
- Zero unapproved external actions.
- Memory corrections persist and stale assumptions expire.
- The system can recover safely after interruption or tool failure.

## Product Path

This is initially a personal agent harness and shared foundation for several other ideas. Later it could become an open-source skill collection, managed home-agent appliance, or vertical executive assistant. Security and auditability are product features, not backend chores.

## Related

- [[Goal-to-Calendar Planner]]
- [[NPC Mode Personal Coach]]
- [[Motto Agent Council]]
- [[Personal Signal Intelligence OS]]
- [[Project Ideas Index]]
