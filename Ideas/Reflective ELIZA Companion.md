---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Cognitive Support and Explanation Skills#5. Reflective ELIZA Companion]]"
status: concept
difficulty: hard
priority: p1
category: reflective companion
form_factor:
  - local chat app
  - voice or Telegram companion
deployment: local-first
source_ideas:
  - ELIZA-like conversation bot with durable personal memory
  - personality-adaptation principles and longitudinal pattern analysis
  - virtual therapist-like reflective conversations
tags:
  - eliza
  - reflection
  - memory
  - personality
  - wellbeing
---

# Reflective ELIZA Companion

> A private, longitudinal conversation companion that listens like ELIZA, remembers with precision, forms revisable hypotheses about recurring patterns, and helps turn reflection into small experiments between conversations.

## Product Outcome

The companion should feel less like a generic advice chatbot and more like a thoughtful record of the user’s inner life. It distinguishes what the user explicitly said, what happened, what was felt, and what the system inferred. It can revisit unresolved threads, notice repeated triggers or contradictions, offer alternative framings, and collaboratively choose a next experiment.

“Personality adaptation” is implemented as transparent, revisable working hypotheses—not a hidden immutable profile. The user can inspect, correct, expire, or delete every memory and inference.

## Core Conversation Modes

- **ELIZA mode:** reflective questions and paraphrases, minimal advice.
- **Pattern mode:** compare the current situation with prior episodes and surface similarities/differences.
- **Perspective mode:** generate plausible interpretations from the user, another person, and a neutral observer.
- **Experiment mode:** define one small behavior, boundary, conversation, or observation to try.
- **Review mode:** examine what changed since a prior conversation.
- **Story mode:** build a coherent timeline around a relationship, goal, fear, transition, or recurring conflict.

## Personal V0

1. Local text chat with session summaries stored as Markdown and SQLite records.
2. After each session, propose memories in four buckets: fact, preference, recurring pattern, and unresolved question.
3. Require user confirmation for high-level personality/pattern memories; routine factual notes can remain in a review queue.
4. At the start of a session, retrieve only the most relevant episodes and show which memories were used.
5. End with an optional experiment or journaling prompt and a follow-up date.
6. Create a weekly “what I may be learning about myself” note containing evidence and counterexamples.
7. Test memory accuracy, emotional usefulness, repetitiveness, and correction/deletion.

## Build Boundary

**MVP:** local text interface, session journal, structured memory proposals, retrieval with provenance, hypothesis cards, experiment/follow-up loop, and full edit/delete controls.

**Later:** voice, mood/energy check-ins, therapist-export summary, multiple conversation personas, relationship timelines, and optional connections to [[Paper Logbook]] and [[Measure Life]].

The initial project can explore therapeutic-style reflection deeply while being explicit about what it knows, remembers, and infers. It should not fabricate clinical authority or conceal model uncertainty.

## Existing Products, Building Blocks, and Shortcuts

- Joseph Weizenbaum’s original [1966 ELIZA paper](https://doi.org/10.1145/365153.365168) and the preserved [ELIZAGEN archive](https://github.com/jeffshrager/elizagen.org) are the primary design references: a general pattern engine plus a DOCTOR script created the reflective interaction.
- [SAMHSA’s motivational interviewing guide](https://library.samhsa.gov/sites/default/files/pep22-06-02-004.pdf) provides concrete reflective-listening patterns that can inform the conversation contract without being treated as a claim of professional care.
- [Letta](https://github.com/letta-ai/letta), [Mem0](https://github.com/mem0ai/mem0), and LangGraph memory patterns are implementation references for long-lived agent memory; a custom SQLite schema may be easier to inspect.
- [Ollama](https://docs.ollama.com/api) or llama.cpp supports local private conversation; stronger paid models can sit behind the same adapter for blind comparison.
- [ActivityPub is not needed]; Markdown and SQLite are enough for one user. Obsidian backlinks make themes and episodes visible without building a knowledge-graph UI.
- Day One, Rosebud, Replika, Wysa, Woebot-style tools, and conventional therapy journals are product references. The differentiator is user-auditable memory, evidence-linked hypotheses, and a local-first data model.

## Recommended Free-First Stack

- Tauri + React/Svelte or a local web app for chat and memory inspection.
- SQLite with full-text search; optional local embeddings in Qdrant/LanceDB only after lexical retrieval is insufficient.
- Ollama/llama.cpp model adapter and optional Whisper/Piper for local voice.
- Pydantic/Zod structured session summaries and memory proposals.
- Encrypted local backup/export to Markdown/JSON.

## Memory Architecture

Keep separate stores:

- `Episode`: dated event or conversation summary with transcript spans.
- `Fact`: user-stated factual information.
- `Preference`: stated likes, aversions, or working styles.
- `Hypothesis`: revisable interpretation with supporting and contradicting episode IDs.
- `OpenThread`: unresolved concern, decision, or relationship question.
- `Experiment`: chosen action, prediction, review date, and outcome.
- `MemoryRevision`: append-only record of edits, merges, expiry, or deletion.

Retrieval should use current topic, people, emotion, time, and open threads. Never silently promote a one-session inference into personality truth.

## Build Slices

1. Local chat, session record, and export.
2. Structured summary and memory-proposal review.
3. Relevant-memory retrieval with visible citations.
4. Hypothesis/evidence/counterexample cards.
5. Experiment and scheduled follow-up loop.
6. Weekly pattern note and regression evaluation.
7. Voice and integrations only after memory quality is trustworthy.

## Drawbacks, Concerns, and Failure Modes

- Reflective language can create an illusion of understanding. Show evidence and invite correction.
- The model may reinforce the user’s framing. Ask for counterexamples and alternate interpretations.
- Too much remembered detail feels invasive and harms retrieval. Store less, summarize deliberately, and expire low-value memories.
- Repetition quickly breaks the relationship. Track question/response patterns and penalize canned reflections.
- Memory edits must cascade into derived hypotheses. Keep provenance and recompute affected summaries.
- A companion can become a substitute for action. End sessions with an optional observation or experiment and review it later.

## Clever Hacks and Simpler Alternative

- Start as an Obsidian session template plus a local summarizer; no chat UI is required.
- Use classic deterministic ELIZA reflection rules for the first response, then call a model only when context makes it useful.
- Limit each session to one open thread and one experiment.
- Present “I may be noticing…” cards with supporting and contradicting examples.
- Add a “forget this line and everything derived from it” operation from day one.

## Success Measures

- Retrieved memories are judged relevant and accurate.
- The user corrects fewer hypotheses across versions.
- Conversations surface new distinctions rather than generic reassurance.
- Experiments are reviewed and produce durable lessons.
- Export/restore and selective deletion preserve data integrity.
- The user reports better clarity after sessions, not merely longer chats.

## Product Path

Private local companion -> personal reflection toolkit -> optional clinician/export collaboration -> privacy-first reflective product. If other people use it or it makes therapy/health claims, run [[Scope Expansion Checklist]]; keep the personal memory architecture and auditability intact.

## Related

- [[Feedback Mirror]]
- [[Angel and Demon Companion]]
- [[Paper Logbook]]
- [[Measure Life]]
- [[Parallel Presence Companions]]
- [[Project Ideas Index]]
