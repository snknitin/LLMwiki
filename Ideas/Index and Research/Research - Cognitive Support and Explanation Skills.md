---
type: research-note
status: active
created: 2026-08-14
scope: cognitive-support-and-explanation-skills
tags:
  - research
  - personal-skills
  - local-first
  - cognitive-support
  - explanation
---

# Research - Cognitive Support and Explanation Skills

This dossier refines four personal, local-first ideas into buildable skill/workflow concepts. The central design rule is to keep facts, schedules, calculations, state, and provenance in deterministic code; use a language model for decomposition, hypothesis generation, reflection, and explanation. All external links below point to official documentation, original papers, first-party product descriptions, or source repositories.

## 1. Batman Prep Time Skill

### Refined concept

Batman Prep Time is a calendar-aware research and contingency skill. It notices or accepts a future event, deadline, trip, interview, meeting, purchase, medical appointment, or difficult conversation, then constructs the smallest preparation package likely to improve the outcome. Its differentiator is not ordinary task scheduling; it joins an 80/20 primer, a pre-mortem, contingency triggers, and time-bounded preparation actions into one brief.

The skill can share a personal-context adapter with Brain Blast and the ADHD skill, but it should be independently usable and independently evaluated. Its natural trigger is an event/deadline, its output is a preparation brief, and its success is measured after the event.

### Core workflow and output contract

1. Read an upcoming event or accept a manually entered deadline.
2. Restate the outcome, date, location, participants, stakes, constraints, and missing information.
3. Classify the event type and load a small domain checklist without assuming every event needs web research.
4. Build an 80/20 primer: the few facts, concepts, people, documents, or rehearsals that most increase readiness.
5. Run a pre-mortem and create a contingency table with failure, probability band, impact, early signal, prevention, fallback, and latest decision time.
6. Generate a preparation checklist fitted into available windows. Proposed calendar blocks remain uncommitted until accepted.
7. Attach direct sources and confidence to externally researched claims.
8. End with a two-minute `if nothing else` checklist and a post-event review prompt.

The [Google Calendar `events.list` method](https://developers.google.com/calendar/api/v3/reference/events/list) retrieves upcoming events with a read-only scope, while [`freebusy.query`](https://developers.google.com/workspace/calendar/api/v3/reference/freebusy/query) identifies preparation windows. If later iterations propose blocks, show an exact diff before using the [event creation API](https://developers.google.com/workspace/calendar/api/guides/create-events). Google documents current [usage limits and pricing thresholds](https://developers.google.com/workspace/calendar/api/guides/quota); a single-user skill will be far below normal limits, but it should cache and use incremental synchronization.

### Existing products and useful shortcuts

- [Motion](https://www.usemotion.com/) and [Reclaim Tasks](https://reclaim.ai/features/tasks) demonstrate deadline-, duration-, priority-, and calendar-aware task placement. Borrow their separation of due date from work slots, not their full scheduling surface.
- Google Calendar is the official event-context source. An exported `.ics` file conforming to [RFC 5545](https://www.rfc-editor.org/rfc/rfc5545) is a zero-OAuth fallback and an excellent first prototype input.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) can constrain primers, risk rows, tasks, and sources to a JSON schema instead of relying on prose parsing.
- [APScheduler](https://github.com/agronholm/apscheduler) or Windows [`schtasks /create`](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks-create) can generate morning or event-relative briefs without a hosted workflow service.

### Free-first stack and architecture

Use Python 3.12, Typer, Pydantic, SQLite, Google Calendar read-only API or `.ics` import, APScheduler/Task Scheduler, Markdown output into Obsidian, and Ollama for local synthesis. A small FastAPI editor is optional after the CLI brief proves useful.

Key records are `events`, `briefs`, `risk_rows`, `prep_actions`, `sources`, and `postmortems`. Each brief retains an input snapshot hash, template/model version, accepted edits, and post-event result. The calendar adapter, time-window calculation, risk scoring, proposal state, and source ledger remain deterministic.

### Evaluation plan

Run it retrospectively on ten past events without exposing the post-event notes. Score primer relevance, sourced-claim coverage, obvious contingency recall, false-alarm load, action feasibility, and whether it finds the failure that actually mattered. Then run a four-week prospective pilot measuring preparation minutes, checklist completion, usefulness, unhandled surprises, proposed-block acceptance, and post-event confidence. Compare against a two-week manual baseline.

### Failure modes and simpler alternative

- Over-preparation can become avoidance; impose a preparation budget and end with one physical action.
- Risk generation can catastrophize; rank by likelihood, impact, detectability, and preparation cost, then cap the visible list.
- Research can drown the event; do no web research when the needed preparation is merely documents, travel time, or rehearsal.
- Calendar OAuth can dominate the build; V0 can accept pasted event text or an `.ics` export and write a Markdown brief.
- A very small version is a reusable pre-mortem template plus a command that inserts event data. Add scheduling only after ten useful runs.

### Deferred expansion line

This assumes private use with the owner's calendar. Before distribution, shared calendars, third-party attendee profiles, or automated calendar writes, run [[Scope Expansion Checklist]]; that future release review should not change the local V0 stack.

## 2. Brain Blast Skill

### Refined concept

Brain Blast is a personal invention skill for everyday problems. It should create genuinely different solution mechanisms, expose hidden assumptions, and end in cheap experiments. It is not a generic brainstormer that returns ten polished variations of the first obvious idea.

The skill may optionally read the same active-project and preference context as Batman Prep Time, but its trigger, state, output, and evaluation are separate. It should work from a one-off problem with no calendar access and should remain useful as a simple CLI or Telegram command.

### Core workflow and output contract

1. Capture the problem, desired outcome, affected person/system, constraints, available resources, deadline, reversibility, and attempts already made.
2. Ask at most two high-value questions. If unanswered, make the assumptions explicit.
3. Rewrite the problem from at least three frames: remove the cause, reduce the damage, change the timing, or change who performs the work.
4. Apply a deterministic operator deck: remove, invert, substitute, combine, split, reorder, borrow from another domain, automate only the bottleneck, use the constraint, make it reversible, or solve the adjacent problem.
5. Require candidates from at least four distinct mechanism clusters.
6. Score candidates on expected utility, novelty against the personal idea archive, effort, reversibility, time-to-test, and likely failure mode.
7. Produce three experiment cards: hypothesis, smallest test, cost/time box, success signal, disconfirming result, and next decision.
8. Log the later outcome so the system learns which creative operators work for this user and problem class.

### Existing products and building blocks

- [IDEO.org's Design Kit Brainstorm method](https://www.designkit.org/methods/brainstorm.html) and [Gut Check method](https://www.designkit.org/methods/gut-check.html) separate broad idea generation from constraint-aware selection. Borrow that deliberate phase change instead of issuing the same generic brainstorm prompt from start to finish.
- [Miro AI](https://miro.com/ai/) demonstrates assisted clustering, summarization, and idea expansion in a visual workspace. Its clustering behavior is a useful benchmark, but a private skill can produce a Markdown mechanism map without a canvas.
- [Goblin Tools](https://goblin.tools/) shows how one focused transformation can beat a large assistant surface. Its task breakdown and estimator are useful downstream tools when a Brain Blast experiment needs decomposition.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) can enforce the operator, mechanism, assumption, score, and experiment schema.
- [OR-Tools](https://developers.google.com/optimization) is a useful free deterministic solver when a problem turns out to be routing, assignment, scheduling, packing, or another constraint problem. The skill should classify such cases and call a solver rather than merely propose "use AI."

### Free-first stack and architecture

Use Python/Typer or a minimal Telegram bot, Pydantic schemas, SQLite, an Obsidian Markdown archive, and Ollama. Keep the operator deck as version-controlled YAML. Optional adapters can invoke OR-Tools, a spreadsheet, web search, or a small simulator only when the problem type warrants it.

Store `problems`, `frames`, `assumptions`, `candidates`, `mechanisms`, `experiments`, `ratings`, and `outcomes`. Novelty should be estimated against prior ideas with lexical search first; embeddings can wait until the archive is large. The model proposes candidates; code enforces mechanism diversity, calculates weighted scores, and records experiment outcomes.

### Evaluation plan

Build a 40-problem personal benchmark spanning household friction, study, software, travel, health habits, money, social coordination, and content creation. Hide candidate origin and rate ideas the next day on mechanism distinctness, novelty, usefulness, feasibility, reversibility, and whether an experiment began within 24 hours. Count mechanism clusters, not idea count.

Compare three conditions: ordinary free-form prompt, operator deck without personal history, and operator deck plus prior outcome history. A good run produces at least four mechanisms, avoids repeating already failed approaches without a changed assumption, and creates one test cheap enough to start now.

### Failure modes and simpler alternative

- Novelty theater produces impractical spectacle; every finalist needs a test, cost, owner, and disconfirming result.
- Ten ideas may be semantic duplicates; cluster by mechanism and reject a run with fewer than four clusters.
- The skill may overfit the user's history and stop surprising them; reserve one `wild but testable` slot from a low-frequency operator.
- Scoring can conceal preferences; show the raw criteria and allow weights to change per problem.
- The simplest version is a Markdown template with twelve operator prompts and a five-column experiment table. An LLM only fills candidates; the user chooses and records the outcome.

### Deferred expansion line

This assumes private ideation over the owner's problems and notes. Before packaging it as consulting, team innovation, or a public product using shared invention history, run [[Scope Expansion Checklist]]; that later review should not change the best local stack.

## 3. Personalized ADHD Skill Upgrade

### Refined concept

Upgrade `i-have-adhd` into a personal execution-support skill that learns which environmental and task-shaping interventions help this specific user start, continue, and finish work. It should not be a generic article about ADHD, a diagnostic system, or a personality label. The durable asset is an editable personal operating manual tied to observed outcomes.

This can share a read-only context adapter with Batman Prep Time and receive experiment ideas from Brain Blast, but it stays independent: its core trigger is friction in the present moment, its output is one appropriate intervention, and its success is lower start latency or better follow-through.

### Evidence-informed workflow

The [NICE ADHD guideline](https://www.nice.org.uk/guidance/ng87/chapter/recommendations) supports tailored information, daily structure, environmental modifications, shorter periods of focus with movement breaks, written instructions, and visual reminders. Translate these into configurable software behaviors rather than universal prescriptions:

1. User invokes `/stuck`, `/start`, `/resume`, `/plan`, or `/reset` with the current task.
2. Skill asks for the smallest missing detail: unclear outcome, emotional resistance, insufficient energy, distraction, excessive size, missing resource, or time uncertainty.
3. It offers one primary intervention and at most two alternatives: next visible action, five-minute start, smaller chunk, visible timer, distraction removal, movement break, body-double, externalized checklist, parking lot, or intentional deferral.
4. The user selects, edits, or rejects it.
5. A lightweight follow-up records started/not started, minutes worked, completion, and why it failed.
6. The weekly review proposes `keep`, `change`, or `delete` updates to the personal operating manual.

Saved social-media advice can be imported as an **idea inbox**, but popularity is not evidence and nothing should become a personal rule until the user deliberately tests and confirms it. The skill should preserve source URLs and the user's own annotation.

### Existing products and useful shortcuts

- [Tiimo](https://www.tiimoapp.com/) demonstrates a visual planner designed for different neurotypes. Borrow low-friction visual sequencing, persistent cues, and time visibility, not a full planner clone.
- [Goblin Tools](https://goblin.tools/) demonstrates one-click task decomposition and estimation. It is the closest fast benchmark for `break it smaller`; the personalized upgrade should learn the user's preferred granularity and retain outcomes.
- [Motion](https://www.usemotion.com/) and [Reclaim Tasks](https://reclaim.ai/features/tasks) show automatic time-blocking and rescheduling. Use them as references or optional external schedulers rather than rebuilding calendar optimization into this skill.
- [NICE NG87](https://www.nice.org.uk/guidance/ng87/chapter/recommendations) provides the high-trust basis for structure, tailored information, environmental modification, written instructions, visual reminders, and shorter focus periods.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) can constrain task decomposition and proposed profile updates. Deterministic rules should select among high-confidence proven interventions before asking a model.

### Free-first stack and personal profile

The smallest implementation is a Codex/Hermes-style local skill with `SKILL.md`, a versioned `personal-operating-manual.md`, JSON/YAML intervention cards, and a SQLite outcome log. A Python/Typer helper can schedule follow-ups and calculate metrics; Telegram or a tiny local PWA is optional. Use Ollama only for free-text classification, decomposition, and weekly wording.

Keep these records separate:

- explicit preferences stated by the user;
- inferred patterns with evidence count, confidence, and expiry;
- intervention cards with trigger, steps, time box, and contraindicating context;
- task attempts and outcomes;
- rejected advice so it is not repeatedly resurfaced;
- imported tips awaiting a personal experiment.

Weak inferences should expire. Every weekly profile change must be shown as a diff. Do not feed the model the full personal archive when a task, recent attempts, and a few relevant confirmed rules suffice.

### Evaluation plan

Collect a two-week baseline, then alternate skill-on and ordinary-workflow days for four weeks when practical. Track start latency, time-estimate error, uninterrupted work interval, completion ratio, unplanned switching, task carry-over, intervention acceptance, and usefulness. Measure burden too: prompts per task, time spent planning, and ignored reminders.

For profile quality, sample persistent rules weekly and mark accurate, situational, stale, or wrong. A strong system has high confirmed-rule precision, low repeated-rejection rate, and decreasing prompt burden. The goal is less friction and more reliable follow-through, not maximum productivity or medical symptom change.

### Failure modes and simpler alternative

- The skill can become another avoidance ritual; cap interaction at 60 seconds before proposing a five-minute start.
- Too many reminders become wallpaper; use event-triggered interventions and a notification budget.
- A stale profile can become self-fulfilling; expire weak inferences and make the weekly diff easy to reject.
- Task decomposition can produce microscopic bureaucracy; learn preferred chunk size and show one next action by default.
- Advice imported from TikTok or elsewhere can be confidently wrong; keep it in an experiment inbox until personally tested.
- The simplest version is one `/stuck` template plus a weekly Markdown operating-manual review. Add inference only after the outcome log contains enough evidence.

### Deferred expansion line

This is private productivity support, not diagnosis or treatment. Before distributing it, making health claims, importing other people's personal material, or operating as coaching software, run [[Scope Expansion Checklist]]; that future review should not distort the local skill design.

## 4. News Depth Telegram Skill

### Refined concept

Build a Telegram skill that accepts a news link or forwarded text and explains the same evidence at three depths: ELI5, ELI12, and adult. The three outputs must not be independent summaries. They should be views over one shared claim-and-source graph so that simplification changes vocabulary and prerequisite knowledge without silently changing facts, certainty, or causal direction.

The useful differentiation is not "short, medium, long." It is:

- **ELI5:** the basic situation, actors, one concrete analogy clearly labeled as analogy, why it matters, and what is still unknown.
- **ELI12:** a short timeline, essential vocabulary, causal chain, competing explanations, and two good follow-up questions.
- **Adult:** precise claims, actor incentives, primary evidence, uncertainties, disputed points, omitted context, and what evidence would change the assessment.

The bot should also offer `Sources`, `What changed?`, `Quiz me`, and `Compare coverage` buttons. Telegram's [Bot API](https://core.telegram.org/bots/api) and official [bot tutorial](https://core.telegram.org/bots/tutorial) support messages, callbacks, and inline keyboards without a custom mobile client.

### Existing products and what they establish

- [Particle](https://particle.news/blog/introducing-particle-the-news-organized) is the closest direct precedent: its first-party description includes ELI5, 5Ws, Opposite Sides, translations, questions, entities, and story following. It validates demand, while leaving room for a private Telegram workflow with a transparent three-level evidence contract.
- [Kagi Summarize](https://help.kagi.com/kagi/summarizer/) accepts pages, videos, and podcasts and includes ELI5 plus multiple summary lengths. Its [Summarizer API](https://help.kagi.com/kagi/api/summarizer.html) is a fast paid benchmark or fallback, not necessary for a local-first implementation.
- [Ground News](https://help.ground.news/en/articles/3189505) compares how left-, center-, and right-rated sources cover the same story. Borrow cross-coverage comparison and visible source diversity; do not collapse article-level evidence into a single outlet-bias score.
- [Google Fact Check Tools `claims.search`](https://developers.google.com/fact-check/tools/api/reference/rest/v1alpha1/claims/search) can surface existing published fact checks for a textual claim. It is a lead, not a truth oracle or substitute for checking the cited evidence.

### Evidence pipeline

1. Resolve redirects and retain the submitted URL, canonical URL, retrieval time, byline, publication time, and a content hash.
2. Extract ordinary article content with [Mozilla Readability](https://github.com/mozilla/readability). Its own documentation recommends sanitizing untrusted output, so use [DOMPurify](https://github.com/cure53/DOMPurify) before rendering HTML.
3. Split the article into atomic claims: event, actor, action, time, quantity, quotation, causal claim, prediction, and opinion.
4. Mark which claims are directly supported by the submitted article and which require outside context.
5. Retrieve only a small, explicit context set: linked primary documents, official statements/data, original research, and diverse first-party reporting. Use the [Crossref REST API](https://www.crossref.org/documentation/retrieve-metadata/rest-api/) for scholarly metadata and the [arXiv API](https://info.arxiv.org/help/api/index.html) for discovery when the topic is scientific. Metadata discovery is not itself evidence; follow the DOI or paper.
6. Generate a canonical fact sheet with confidence and dispute fields.
7. Render the three reading levels from that fact sheet, then run an invariance check for changed numbers, dates, agents, polarity, causality, and certainty.
8. Send a compact ELI5 card first and let inline buttons reveal depth rather than flooding the chat.

For V0, avoid open web crawling entirely: explain the submitted article, use the links it cites, and let the user request extra research. This dramatically reduces latency and source-selection complexity.

### Free-first stack and data model

Node.js/TypeScript is the cleanest fit because Mozilla Readability and DOMPurify are native JavaScript libraries. Use grammY or Telegraf as the Telegram wrapper, `undici` for HTTP, JSDOM + Readability for extraction, Zod for schemas, SQLite for cache/history, and Ollama for local generation. A Python implementation is also reasonable, but mixing a Python bot with a Node extraction worker adds complexity without proving more value.

Store:

- `stories`: submitted/canonical URL, timestamps, article snapshot hash, extractor result;
- `claims`: normalized text, type, source span, confidence, dispute status;
- `sources`: publisher/issuer, URL, source class, date, retrieved hash;
- `claim_sources`: support, contradiction, context, or mere mention;
- `renders`: depth, prompt/model version, output, invariance-test result;
- `feedback`: too simple, too detailed, confusing term, missing context, factual correction.

The model may propose claims and explanations, but source spans, dates, numbers, URL normalization, cache identity, and tier-difference checks should be code-owned.

### Evaluation plan

Build a 60-story set across politics, economics, science, technology, courts, conflict, and local news. Include breaking stories that later changed, opinion columns, corrections, live blogs, paywalls, press releases, and articles with important charts.

Measure:

- atomic claim precision and recall against a human-authored fact sheet;
- citation entailment: whether the linked span actually supports the sentence;
- source coverage and number of unsupported contextual additions;
- cross-tier invariance for entities, numbers, dates, causal direction, negation, and uncertainty;
- comprehension via three questions answered after reading each tier;
- user-selected depth, `Sources` opens, corrections, latency, local token count, and cache hit rate.

Readability formulas can be a weak lint, not the success metric. An ELI5 output can have short sentences and still teach the wrong mental model. The decisive test is whether a reader can explain the event accurately and distinguish known facts from interpretation.

### Failure modes and simpler alternatives

- **Simplification deletes the caveat:** generate the canonical fact sheet first and run tier invariance tests.
- **An analogy is mistaken for mechanism:** label analogies explicitly and include one sentence explaining where each analogy breaks.
- **One article becomes "the truth":** display `according to this report` and keep article claims separate from independently verified context.
- **Breaking news goes stale:** put an `as of` timestamp on every card and make `What changed?` compare stored claim graphs.
- **Extraction fails on paywalls or scripts:** accept pasted text, screenshots, or a Telegram-forwarded excerpt as a first-class fallback.
- **The research path becomes expensive:** V0 can be one Telegram message, one extracted article, one structured model call, and three deterministic render templates. Kagi's API is a convenient benchmark if local extraction is the bottleneck.

### Deferred expansion line

This assumes private use with user-submitted links. Public operation later requires a separate review of source access, quotation/display, publisher terms, moderation, corrections, and news-personalization policy through [[Scope Expansion Checklist]]; none of those concerns should force a different personal V0 stack.

## 5. Reflective ELIZA Companion

### Refined concept and truthful boundary

The valuable project is an ELIZA-inspired reflective companion with durable, user-editable memory and controllable conversation style. It should not promise to "accurately psychoanalyze and treat" the user. A generative model cannot establish a clinical diagnosis or treatment relationship merely by remembering conversations. The useful personal product is a thinking partner that listens, reflects, notices tentative patterns, asks whether an interpretation fits, and helps the owner journal or choose a next step.

Joseph Weizenbaum's original [1966 ELIZA paper](https://doi.org/10.1145/365153.365168) is essential design context. ELIZA separated a general pattern-processing engine from a DOCTOR script and used decomposition, reassembly, keyword precedence, and limited memory to create strikingly convincing reflective dialogue. The lesson is two-sided: reflection can be effective with simple machinery, and people can attribute much more understanding than the system possesses.

### Conversation contract

A strong default turn sequence is:

1. reflect the user's meaning or emotion without claiming certainty;
2. ask one clarifying question;
3. retrieve at most a few relevant memories with visible provenance;
4. state a pattern as a hypothesis: "I may be connecting this incorrectly...";
5. ask the user to confirm, edit, or reject it;
6. ask whether they want to stay with the feeling, explore the pattern, or make a plan;
7. end with an editable session summary containing the user's own words, open questions, and any chosen commitment.

[SAMHSA's motivational interviewing guide](https://library.samhsa.gov/sites/default/files/pep22-06-02-004.pdf) is a useful primary manual for reflective listening and respectful, client-centered conversation. Borrow the interaction principles, not the claim that a local bot is delivering professional motivational interviewing or psychotherapy.

Personality-adaptation ideas should become **editable response-style cards**, not automatic personality typing. Examples: prefers direct questions; becomes defensive when advice arrives too early; wants concrete options after reflection; responds well to humor; dislikes generic reassurance; wants contradictions challenged. Separate explicit preferences from low-confidence inferences, temporary mood from stable preference, and descriptive pattern from diagnosis.

### Existing products, projects, and reusable components

- The original ELIZA paper supplies the minimal reflective-dialogue architecture and a regression transcript. The [ELIZAGEN source archive](https://github.com/jeffshrager/elizagen.org) preserves rediscovered ELIZA material and is better historical grounding than a generic chatbot imitation.
- [Replika's first-party memory documentation](https://help.replika.com/hc/en-us/articles/37208679176077-How-does-Replika-s-memory-work) describes layered memory, visible memory editing, manual additions, and feedback reinforcement. The key feature to borrow is memory inspectability, while keeping the local implementation's provenance and correction rules stricter.
- [Woebot's original randomized trial](https://mental.jmir.org/2017/2/e19/) evaluated a structured, decision-tree conversational intervention with mood check-ins, tailoring, goals, accountability, and reflection. It is evidence for carefully bounded conversational flows, not evidence that any free-form LLM companion is therapeutic.
- [Letta](https://github.com/letta-ai/letta) is an open-source reference for stateful agents with persistent memory. It can accelerate a prototype, though a simple SQLite schema may be easier to understand and audit for one companion.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) or [llama.cpp](https://github.com/ggml-org/llama.cpp) provides local inference. Structured output is important for separating the conversational response from proposed memory writes and session metadata.
- [SQLite FTS5](https://www.sqlite.org/fts5.html) supplies lexical retrieval, [sqlite-vec](https://github.com/asg017/sqlite-vec) can add local vector search, and [SQLCipher](https://github.com/sqlcipher/sqlcipher) is an optional encrypted SQLite variant.

### Memory architecture

Do not store one endlessly rewritten biography. Use an append-mostly ledger:

- `episodes`: timestamped session summaries linked to source message IDs;
- `facts`: user-confirmed people, places, preferences, and circumstances;
- `hypotheses`: tentative patterns with confidence, supporting/contradicting episodes, and status;
- `commitments`: user-chosen actions, due/review date, and outcome;
- `style_preferences`: explicit or inferred, confidence, last confirmation;
- `corrections`: old value, corrected value, reason, and affected memories;
- `messages`: immutable local transcript or hashed pointer if the user prefers not to retain full text.

Every memory shown to the model needs `source`, `created_at`, `last_confirmed`, `confidence`, and `status`. Retrieval should combine recent context, FTS5, optional embeddings, and deliberate diversity. Before inserting a new fact, search for a contradiction. Proposed memories should appear after the response as `remember / edit / discard`; rejected memories must not quietly return through an old summary.

The companion needs explicit modes: `reflect`, `challenge`, `problem-solve`, `journal`, and `quiet company`. Mode selection is more dependable than expecting a model to infer the desired kind of support from every message.

### Free-first stack and build slices

Recommended V0: Python/FastAPI or a Tauri desktop shell; SQLite + FTS5; optional sqlite-vec after lexical retrieval is measured; Ollama with a capable local model; Pydantic/Zod schemas; and a Markdown session export into Obsidian. Start with text. Voice adds transcription, turn-taking, and emotional ambiguity without testing the core value.

Build slices:

1. deterministic ELIZA-style reflection rules plus session journaling;
2. local LLM response constrained by a conversation policy;
3. proposed memory writes with approve/edit/delete;
4. memory browser, contradiction view, and provenance links;
5. weekly pattern review that shows evidence and asks the user what fits;
6. regression evaluator before model or prompt changes.

A surprisingly strong simpler alternative is a daily journal command that asks five reflective questions, stores the answers locally, and produces a weekly pattern memo. Add open-ended conversation only if the owner actually returns for dialogue rather than just summaries.

### Evaluation plan

Create a fixed suite of synthetic conversations covering uncertainty, shame, anger, grief, relationship conflict, procrastination, changing preferences, false memories, contradiction, and requests for diagnosis. Include paired cases where only one detail changes.

Evaluate four layers:

- **Reflection fidelity:** does the paraphrase preserve the user's meaning, emotion, agency, and uncertainty without intensifying it?
- **Memory quality:** precision of recalled facts, contradiction rate, stale-memory rate, proportion with traceable source, and correction propagation.
- **Conversation quality:** user rating for `felt understood`, `helped me see something`, `asked before advising`, `did not flatter`, and `left me clearer`; also measure repetitive-question and generic-reassurance rates.
- **Boundary reliability:** zero invented clinical diagnoses, false claims of professional care, fabricated memories, or hidden memory writes in the regression suite.

The Woebot trial measured engagement, acceptability, and validated symptom scales in a specific intervention. For a personal companion V0, do not imitate clinical outcome claims. Measure clarity, reflection usefulness, memory accuracy, chosen-action follow-through, and whether the owner would voluntarily use it again.

### Failure modes and clever defenses

- **Sycophancy feels warm but reinforces bad conclusions:** require alternative interpretations and a `challenge me gently` control; score agreement without evidence.
- **The system invents a personal history:** every recalled detail links to a memory card; unsupported memories are blocked from the response.
- **A personality label becomes destiny:** store response preferences and observed situations, never a single hidden type.
- **Summaries slowly distort the transcript:** keep immutable episode sources and evaluate summary-to-source entailment before compaction.
- **The companion asks questions forever:** after two reflections, explicitly ask whether the user wants exploration or action.
- **A large agent framework hides behavior:** start with SQLite, a small retrieval function, and visible prompts. Adopt Letta only if its memory lifecycle solves a measured limitation.

### Deferred expansion line

This is a private self-reflection tool, not clinical diagnosis or treatment. Any future distribution, health claim, clinician workflow, shared memory, or operation for vulnerable users requires a dedicated evidence, safety, privacy, and consent review through [[Scope Expansion Checklist]]; that later release work should not distort the local technical prototype.

## 6. Physics Claim Debunker Skill

### Refined concept

Build a local **Physics Claim Auditor** that takes an extraordinary claim and produces a reproducible claim card. The word `debunker` is useful as motivation but dangerous as an algorithm: the system should be willing to conclude `inconsistent`, `implausible under stated assumptions`, `unsupported`, `compatible but unproven`, or `not testable as phrased`. Absence of an obvious physics violation is not proof that a claim is true.

The model's job is to steelman and formalize the claim. Code owns units, algebra, numerical estimates, uncertainty propagation, and test results. Evidence links should lead to original measurements, official datasets, standards, or primary papers rather than a model-generated bibliography.

### Seven-pass audit

1. **Normalize the claim.** Preserve the exact quote, URL/file, speaker, date, and context. Rewrite it into variables, predicted observables, boundary conditions, timescale, spatial scale, and an explicit strongest reasonable interpretation. Ask which missing premise would most change the result.
2. **Dimensional check.** Convert every equation and numerical statement into quantities with units. The [BIPM SI Brochure](https://www.bipm.org/en/publications/si-brochure) is the authority for SI definitions. Reject additions or equalities with incompatible dimensions before doing detailed arithmetic.
3. **Order-of-magnitude model.** Construct a lower bound, central Fermi estimate, and generous upper bound. Show assumptions as sliders or editable cells. Report ratios and powers of ten, not false precision.
4. **Conservation and accounting.** Track energy, momentum, angular momentum, charge, mass-energy, entropy/information where relevant, and flows across the system boundary. Noether's original [Invariant Variation Problems](https://arxiv.org/abs/physics/0503066) is foundational context for the relationship between symmetries and conservation laws; the tool still needs domain-specific equations and boundary conditions.
5. **Mechanism and limiting factor.** Identify the proposed coupling, required energy source/sink, bottleneck, waste heat, signal propagation, material strength, or biological rate. Compare it with the most generous physically plausible mechanism, not a straw man.
6. **Falsifiability and discriminating test.** State an observation that the claim predicts, the null/alternative outcomes, measurement precision required, confounders, and what result would reduce belief. If no observation can differ, return `not testable as phrased`.
7. **Evidence and uncertainty.** Retrieve relevant primary sources, propagate stated uncertainty, distinguish measurement from interpretation, check corrections/retractions, and publish a verdict whose confidence is limited by the weakest premise.

### Existing tools and primary building blocks

- [Pint](https://pint.readthedocs.io/en/stable/) represents values with physical units, converts units, checks dimensionality, and includes a command-line converter. It should parse and normalize user-entered quantities before any model explanation.
- [SymPy's unit systems](https://docs.sympy.org/latest/modules/physics/units/index.html) handle symbolic quantities, dimensions, and unit conversion. Use SymPy for algebra and equation solving; use Pint for ergonomic runtime quantities rather than forcing one library to do both jobs.
- The Python [uncertainties package](https://pythonhosted.org/uncertainties/) propagates numerical uncertainty. For nonlinear or poorly specified problems, add an explicit Monte Carlo path instead of pretending first-order propagation is enough.
- [NIST's CODATA constants database](https://physics.nist.gov/cuu/Constants/index.html) supplies recommended constants and uncertainties. Record the database/version date with each calculation so later changes are reproducible.
- [Wolfram|Alpha APIs](https://products.wolframalpha.com/api/) provide a hosted computation benchmark and currently advertise limited free non-commercial API access. They are a useful cross-check, not the sole calculation engine or source of evidentiary claims.
- [Crossref's public REST API](https://www.crossref.org/documentation/retrieve-metadata/rest-api/) and the [arXiv API](https://info.arxiv.org/help/api/index.html) help discover papers and DOI metadata. Always follow the result to the original paper and record whether it is a preprint, published version, correction, or retraction.
- [Google Fact Check Tools](https://developers.google.com/fact-check/tools/api/reference/rest/v1alpha1/claims/search) can reveal whether a claim has already been reviewed and how it was phrased. Treat returned reviews as leads; the physics card should still expose its own assumptions and calculations.

There is no widely used consumer product that performs this whole physics-first audit. That is the opportunity: combine a transparent calculator/notebook with a claim-evidence ledger, rather than making another prose fact-check chatbot.

### Free-first stack and artifact format

Recommended V0: Python, Typer CLI, Pydantic, Pint, SymPy, uncertainties, NumPy, Jupyter or Quarto for reproducible calculation reports, SQLite for claim/evidence history, and Ollama only for claim parsing and explanations. Add a Streamlit or local web UI after the notebook template is proven.

```powershell
python -m pip install pint sympy uncertainties numpy jupyter
pint-convert 1 horsepower watt
jupyter lab
```

Each result should be a self-contained Markdown/HTML card with:

- exact claim and steelmanned formal claim;
- variable table with value, unit, range, source, and confidence;
- equations plus dimensional result;
- lower/central/upper estimates;
- conservation ledger and system boundary diagram;
- sensitivity ranking showing which assumption drives the verdict;
- decisive observation or test;
- evidence table and direct links;
- verdict, confidence, limitations, and a machine-readable JSON attachment;
- code/environment hash so the calculation can be rerun.

Never let the model calculate silently. It must propose a typed calculation plan; the Python kernel executes it; the renderer inserts actual values back into the narrative.

### Evaluation plan

Create a benchmark of at least 80 claims in four classes:

- trivial unit/dimensional errors;
- plausible-looking claims off by three or more orders of magnitude;
- claims that violate conservation only after the correct system boundary is drawn;
- claims compatible with physics but unsupported or not falsifiable as worded.

For each, keep an expert-authored variable table, calculation, uncertainty range, evidence set, and acceptable verdict labels. Add metamorphic tests: convert every input to different units, reorder premises, widen an uncertainty interval, and replace a number with an equivalent scientific notation. The verdict and physical result should remain invariant where appropriate.

Measure unit-parse accuracy, dimensional-check accuracy, numerical relative error, uncertainty coverage, missing-premise detection, evidence precision, citation support, verdict calibration, and abstention quality. Track whether the tool finds the same dominant assumption as the reference solution. A model that confidently produces the correct label for the wrong equation fails.

Property-based tests are particularly valuable:

- unit conversion must not change a dimensionless ratio;
- increasing an energy requirement cannot decrease the minimum required power at fixed time;
- widening all input uncertainty cannot shrink the output interval without explanation;
- equivalent algebraic forms must produce the same central estimate;
- removal of a necessary premise must lower confidence or trigger a question.

### Failure modes and simpler alternatives

- **Garbage premises yield precise nonsense:** show a premise completeness score and ask for the single most consequential missing input before calculating.
- **The system attacks a weak version of the claim:** store the original quote beside the steelman and let the user edit the formalization.
- **A valid equation is applied outside its regime:** every equation record needs applicability conditions and failure regimes.
- **Conservation is applied to an open system as if closed:** force an explicit system boundary and input/output ledger.
- **Primary-source search becomes citation theater:** require a source excerpt/table/figure that supports each numerical input; metadata alone is insufficient.
- **The model's prose outruns the math:** generate the verdict only after code execution and block numerical sentences without a result ID.
- **The full agent is too large:** the smallest valuable version is a `claim.md` template plus a Jupyter notebook that performs unit checks, a three-point Fermi estimate, and an editable evidence table. A Telegram wrapper can come later.

### Deferred expansion line

This assumes private analysis and user-supplied claims. Before public fact-checking, publication, or automated judgments about named people and organizations, review evidence standards, correction/appeal workflows, defamation risk, source display, and moderation through [[Scope Expansion Checklist]]; those future release concerns should not change the local computation-first stack.

### Related

- [[Project Ideas Index]]
- [[Research - Existing Product and Shortcut Atlas]]
- [[Personal Study Curriculum]]
- [[Personal Signal Intelligence OS]]
- [[Understand This Paper]]
- [[Scope Expansion Checklist]]
