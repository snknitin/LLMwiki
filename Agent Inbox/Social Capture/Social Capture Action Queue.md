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

- [ ] **Run a Google L6 readiness diagnostic before collecting more prep material** — [source](https://www.teamblind.com/post/how-to-prepare-for-google-l6-level-india-f8h658yj)
  - Contains: A Microsoft L64 engineer with 14 years of experience asks how to prepare for Google India L6, naming NeetCode 150, Hello Interview, mock interviews, and difficulty retaining system-design concepts. The most useful replies recommend solving designs from requirements and data/storage constraints, making mistakes before studying reference solutions, using repeated mocks and feedback, and discussing real distributed-system trade-offs; suggested resources include Alex Xu’s two system-design volumes, Hello Interview’s design questions and story builder, and Alex Croitor for behavioral preparation, while commenters disagree on whether NeetCode 150 is sufficient.
  - Potential benefit: Replaces passive resource accumulation with a measured baseline tailored to Nitin’s senior AI-career goal, exposing whether coding, architecture, communication, or leadership evidence is the actual constraint before committing to a long preparation plan.
  - Intent: test · inferred
  - Topic: Google L6 preparation
  - Priority: P1
  - Impact: high
  - Ease: moderate
  - Important: yes
  - Importance reason: A calibrated L6 gap map directly supports Nitin’s goal of moving into a high-compensation AI engineering, MTS, or principal data-science role and prevents months of unfocused interview study.
  - Urgent: yes
  - Urgency reason: No application, interview date, expiring opening, or other near-term consequence is stated.
  - Done when: One target Google L6 job family is selected, one timed coding problem and one 45-minute system-design mock are scored against explicit rubrics, and a one-page gap map identifies the next three drills with evidence for each.
  - Effort: 2h
  - Matrix order: 1000
  - Captured: 2026-08-23 10:39 IST via Telegram · Hermes Swarm / Capture
  - ID: sc_b9cabd2eedaaca56

- [ ] **Outline a four-post dual-DGX-Spark build-in-public series** — [source](https://x.com/sudoingX/status/2090304783370559565)
  - Contains: Sudo says NVIDIA supplied both of his DGX Sparks after a year of consistently publishing hands-on local-AI work as a solo builder; the attached photo visibly shows two DGX Spark units, branded packaging, and a high-speed cable, while the quoted post proposes joining the systems for larger distributed-model workloads.
  - Potential benefit: Turns Nitin’s unusually relevant two-Spark setup into a repeatable, evidence-first content arc that can build AI credibility and make his technical work legible to collaborators or sponsors without copying the post’s motivational framing.
  - Intent: write · inferred
  - Topic: AI personal brand
  - Priority: P1
  - Impact: high
  - Ease: moderate
  - Important: yes
  - Importance reason: Publishing real dual-Spark experiments directly advances Nitin’s AI credibility goal while extracting public value from hardware he already owns.
  - Urgent: no
  - Urgency reason: There is no deadline, expiring opportunity, or current dependency; social visibility compounds through consistency rather than requiring an immediate reaction to this post.
  - Done when: One Markdown outline specifies four artifact-led posts—hardware and cluster setup, link validation, a larger-model benchmark, and lessons—with a hook, evidence to capture, and one reader takeaway for each.
  - Effort: 1h
  - Captured: 2026-08-22 22:20 IST via Telegram · Hermes Swarm / Capture
  - ID: sc_19529a865b85742d

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

- [ ] **Run a LongCat-Video-Avatar 1.5 feasibility spike on one DGX Spark** — [source](https://x.com/0xJokker/status/2090441836317811176)
  - Contains: The Spanish post demonstrates turning one image plus audio into a minutes-long synchronized talking-person video. The underlying Meituan LongCat project is genuinely open source under MIT, with code at `meituan-longcat/LongCat-Video`, downloadable Avatar and Avatar 1.5 weights, audio-text-image-to-video, multi-character audio, continuation, distilled inference, and optional INT8 loading; the viral claim of replacing an entire studio still needs a local quality and resource test.
  - Potential benefit: Establishes whether Nitin’s DGX hardware can provide a private, reusable talking-avatar pipeline for AI tutorials and personal-brand content without recurring commercial generation fees.
  - Intent: test · inferred
  - Topic: Local AI video
  - Priority: P2
  - Impact: high
  - Ease: deep
  - Important: yes
  - Importance reason: A working local avatar pipeline would directly support Nitin’s content-production goal while exploiting hardware he already owns.
  - Urgent: no
  - Urgency reason: The model and weights are publicly available with no stated deadline, expiry, or immediate dependency.
  - Done when: One DGX Spark generates a 20-second clip from Nitin-owned or explicitly authorized image and audio inputs, with setup steps plus runtime, memory use, lip-sync and motion artifacts recorded, ending in a go/no-go decision for a reusable workflow.
  - Effort: half-day
  - Captured: 2026-08-22 19:42 IST via Telegram · Hermes Swarm / Capture
  - ID: sc_1e85b5bd109c8475

## Waiting or blocked

<!-- Move tasks here only when a specific dependency exists. -->

## Done this month

<!-- Completed tasks may stay here briefly, then move to Archives/Social Capture Actions - YYYY-MM.md. -->
