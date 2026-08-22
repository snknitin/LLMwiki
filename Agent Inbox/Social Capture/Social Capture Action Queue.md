---
title: Social Capture Action Queue
created: 2026-08-22
updated: 2026-08-22
status: active
type: action-queue
tags:
  - action-queue
  - social-capture
---

# Social Capture Action Queue

> [!important] Canonical active output
> New social posts, articles, screenshots, and forwarded links are **not saved here as bookmarks**. Hermes must first understand the item and then append one concrete, observable action below. The legacy `Bookmarks/` folders are read-only source caches; an old bookmark does not count as an existing action.

## Action contract

Every item must be a real action, not “read this,” “review later,” or a generic summary.

```markdown
- [ ] **Verb-led smallest useful action** — [source](URL)
  - Contains: concise explanation with the source's important specifics
  - Potential benefit: why it could help a current goal, project, or decision
  - Intent: read | learn | implement | test | idea | write | decide · stated | inferred
  - Topic: one stable, human-readable topic
  - Priority: P0 | P1 | P2 | P3
  - Impact: high | medium | low
  - Ease: quick | easy | moderate | deep
  - Important: yes | no
  - Importance reason: one evidence-based sentence
  - Urgent: yes | no
  - Urgency reason: deadline, expiry, dependency, consequence, or explicitly none
  - Done when: one observable artifact or explicit decision exists
  - Effort: 15m | 30m | 1h | 2h | half-day
  - Captured: YYYY-MM-DD via Telegram | WhatsApp import | Discord | Web
  - ID: sc_<stable-id>
```

Rules:

- Each capture must produce **at most one** rich active checkbox. A bare Telegram share is sufficient: Hermes infers the likely intent and marks it as inferred rather than interrupting capture.
- Hermes automatically sets `Important` and `Urgent`; the dashboard derives the Eisenhower quadrant. Importance requires goal/risk relevance. Urgency requires a real time-bound consequence—novelty alone is never urgent.
- Completed tasks disappear from the active matrix but remain in `Done this month`/archives for recovery; they are not irreversibly deleted.
- Prefer actions that create an artifact: test result, code spike, Feynman note, project change, content outline, or explicit decision.
- If the item is not useful enough for an action, do not add it. Report `Discarded` with a short reason.
- If it only supports work already listed, enrich the existing checkbox instead of creating a duplicate.
- Preserve the source URL on the task, but do not copy the whole post into a new note.
- Ask one short clarification only when Nitin's intended use changes the action materially.

## Today

<!-- Tasks explicitly selected for today's work. The dashboard moves blocks here; it does not duplicate them. -->

## Open backlog

<!-- Hermes appends new, ready actions below this line. Keep the queue ordered by current leverage, not capture time. -->

- [ ] **Benchmark a bounded critic–revision loop against a one-pass agent** — [source](https://x.com/petergyang/status/2090564541499498919)
  - Contains: Peter Yang proposes improving AI output by having a manager agent repeatedly challenge a worker to reconsider and try harder; the underlying mechanism is additional test-time compute and iterative critique, but vague pressure should be compared with a rubric-based evaluator rather than assumed effective.
  - Potential benefit: Tests a small, reusable orchestration pattern that could raise output quality across Jarvis/Alfred and deterministic multi-agent workflows without blindly adding expensive agent loops.
  - Intent: test · inferred
  - Topic: Agent evaluation
  - Priority: P2
  - Impact: high
  - Ease: moderate
  - Important: yes
  - Importance reason: A measured evaluator loop could materially improve the quality and reliability of Nitin's core agent stack while controlling added latency and model cost.
  - Urgent: no
  - Urgency reason: There is no deadline, expiring opportunity, or current dependency; the social post's recency is not urgency.
  - Done when: A small benchmark compares one-pass, vague “try again,” and rubric-based critic–revision outputs on five representative prompts, records quality and token/latency costs, and ends with an adopt-or-reject decision.
  - Effort: 2h
  - Captured: 2026-08-22 16:04 IST via Telegram · Hermes Swarm / Capture
  - ID: sc_f6f87d8954c6b762

- [ ] **Write a source-checked Feynman note connecting probability, insurance, and modern risk** — [source](https://x.com/betraidx/status/2090447521717858775)
  - Contains: The post tells a compressed history from Girolamo Cardano’s dice analysis in *Liber de Ludo Aleae* through Pascal, Fermat, Peter Bernstein, insurance, and Black–Scholes; its core link between gambling mathematics and quantified risk is useful, but claims such as the entire insurance industry running on one Cardano equation and nobody connecting the history before 1996 are rhetorical overstatements that require verification.
  - Potential benefit: Converts a viral finance story into active probability learning and a trustworthy seed for Nitin’s AI/quantitative personal-brand content rather than preserving an unreliable anecdote.
  - Intent: learn · inferred
  - Topic: Probability and risk
  - Priority: P2
  - Impact: medium
  - Ease: moderate
  - Important: yes
  - Importance reason: The artifact directly supports Nitin’s probability and financial-literacy goals and can become evidence-grounded educational content.
  - Urgent: no
  - Urgency reason: There is no deadline, expiring opportunity, dependency, or near-term consequence.
  - Done when: A one-page note cites credible sources, explains expected value and risk pooling with one worked dice-to-insurance example, labels the post’s accurate and exaggerated claims, and ends with three retrieval questions.
  - Effort: 1h
  - Captured: 2026-08-22 18:15 IST via Telegram · Hermes Swarm / Capture
  - ID: sc_c03359e24eacea9c

## Waiting or blocked

<!-- Move tasks here only when a specific dependency exists. -->

## Done this month

<!-- Completed tasks may stay here briefly, then move to Archives/Social Capture Actions - YYYY-MM.md. -->
