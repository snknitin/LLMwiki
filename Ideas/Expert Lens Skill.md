---
type: skill-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Expert Mode and Tiny Model Game Lab#1. Expert Lens Skill]]"
status: concept
difficulty: medium
priority: p1
category: research and conversation intelligence
form_factor:
  - Codex or Hermes skill
  - local preparation workspace
  - optional live conversation copilot
deployment: local-first
source_ideas:
  - become conversant in any field by asking expert questions and using its vocabulary precisely
tags:
  - expertise
  - research
  - jargon
  - questions
  - conversation
  - calibration
---

# Expert Lens Skill

> Enter an unfamiliar field quickly enough to ask high-leverage questions, distinguish concepts that novices conflate, and speak its vocabulary precisely—without substituting jargon theatre for real understanding.

## Product Outcome

Given a domain, situation, counterpart, and desired outcome, the skill produces a compact **domain lens**: the field's objects, mechanisms, institutions, measurements, failure modes, contested terms, current constraints, and questions that expose what actually matters. It should make a user sound prepared because the user understands the local structure of the problem, not because the model sprays fashionable terminology.

The core deliverable is a conversation-ready field card backed by evidence. It teaches each specialist term through its operational meaning, contrasts it with easily confused terms, shows when an insider would use it, and supplies a plain-language paraphrase. It then generates questions at several levels: vocabulary clarification, causal diagnosis, boundary conditions, workflow, economics, failure analysis, and the assumptions on which a recommendation depends.

The skill can prepare for a meeting, interview, technical purchase, medical or legal consultation, academic discussion, sales call, community event, or a deep learning session. It complements [[Batman Prep Time Skill]]: Expert Lens owns the domain model and question quality; Batman Prep owns the complete event plan, contingencies, rehearsal, and timing.

## Invocation and Output Contract

Inputs:

- Domain and subdomain, such as “utility-scale battery storage interconnection” rather than only “energy.”
- Situation, counterpart, stakes, jurisdiction, relevant date, and desired decision or outcome.
- Current knowledge level and the concepts the user already understands.
- Available preparation time: five minutes, thirty minutes, two hours, or deep-dive mode.
- User-provided documents, URLs, notes, terminology, and whether current web research is permitted.
- Preferred mode: learn, prepare questions, rehearse, inspect an answer, or follow a live conversation.

Outputs:

1. **Domain topology:** actors, artifacts, processes, incentives, standards, and decision points.
2. **Vocabulary ladder:** foundational, working, and insider terms, each with definition, contrast, example, source, and “do not misuse as…” note.
3. **Mechanism map:** what causes what, which variables matter, and where uncertainty enters.
4. **Expert question bank:** diagnostic, counterfactual, boundary, implementation, measurement, failure, and trade-off questions.
5. **Inside-baseball distinctions:** five to ten pairs that reveal real familiarity because newcomers frequently conflate them.
6. **Conversation card:** likely branches, concise follow-ups, terms worth recognizing, and claims that need verification.
7. **Evidence ledger:** source, claim, publication/version date, authority, confidence, and applicable context.
8. **Teach-back check:** short questions that force the user to explain the concepts without jargon.

Every specialist term must pass the **paraphrase test**: if the system cannot explain the term plainly, contrast it with a neighbor, and attach it to an observable decision or mechanism, it cannot recommend using it.

## Personal V0

- Implement a Codex/Hermes skill that accepts a topic plus an upcoming conversation or decision.
- Limit each run to five authoritative sources and one screen of core briefing before optional depth.
- Extract 15–25 candidate terms, then retain only those relevant to the stated situation.
- Produce five high-leverage questions, five novice traps, three disputed or context-sensitive terms, and one causal map.
- Run a ten-minute rehearsal in which the model plays a practitioner and challenges imprecise language.
- After the real conversation, record which terms appeared, which questions unlocked useful information, where the briefing was wrong, and what the user still could not explain.
- Battle-test it across at least ten unrelated fields instead of tuning it to one impressive demonstration.

The first version needs no live microphone, browser extension, persistent vector database, or autonomous outreach. A folder containing the skill instructions, schemas, source packet, field card, and post-conversation review is enough.

## Build Boundary

**MVP:** manual topic input; primary-source search or attached-document reading; structured terminology, mechanism, question, and evidence objects; a Markdown field card; rehearsal; and correction capture.

**Later:** reusable domain packs, read-only Obsidian context, calendar-triggered preparation, audio transcription, a discreet live companion, organization-specific glossaries, and shared expert-reviewed packs.

This is not a universal authority simulator. It should explicitly distinguish **orientation**, **working fluency**, and **credentialed professional judgment**. High-stakes conclusions still go back to the relevant primary source or qualified practitioner.

## Existing Products, Building Blocks, and Shortcuts

- [DSPy](https://dspy.ai/) provides typed signatures, composable retrieval/reasoning modules, and optimizers that can improve a question-generation program against a scored example set instead of endlessly hand-editing prompts.
- [OpenAlex](https://docs.openalex.org/), the [Crossref REST API](https://www.crossref.org/documentation/retrieve-metadata/rest-api/), and official standards or regulator sites can identify canonical literature and current terminology. They are discovery layers, not proof that a paper supports a claim.
- [Wikidata Query Service](https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service/Wikidata_Query_Help) and the W3C [SKOS reference](https://www.w3.org/TR/skos-reference/) are useful prior art for representing concepts, preferred labels, aliases, broader/narrower relationships, and related terms.
- [spaCy's rule-based matching](https://spacy.io/usage/rule-based-matching) can protect exact multiword terms, abbreviations, product names, and standards identifiers before semantic clustering.
- [Sentence Transformers](https://www.sbert.net/) supports local semantic retrieval, while plain SQLite FTS5 or ripgrep is often the better first implementation for a small, inspectable source packet.
- Notebook-style source-grounded assistants, deep-research products, meeting-preparation tools, glossaries, and interview simulators each implement part of the workflow. The opportunity is the combination of **domain topology + precise distinctions + question leverage + teach-back + post-conversation correction**.

## Recommended Free-First Stack

- **Skill package:** Markdown instructions, JSON Schema/Pydantic models, reusable `field-card.md` and `conversation-review.md` templates.
- **Orchestration:** Python 3.12 with Pydantic and Typer; DSPy only after a hand-written pipeline has a real evaluation set.
- **Retrieval:** ripgrep and SQLite FTS5 first; Sentence Transformers plus FAISS/Qdrant only when the corpus becomes large enough to justify embeddings.
- **Extraction:** spaCy matchers for protected terms and a local LLM for candidate concepts, relations, questions, and plain-language paraphrases.
- **Inference:** a local OpenAI-compatible endpoint for routine extraction; an optional paid or larger local model behind the same adapter for difficult synthesis, selected only after comparative evaluation.
- **Storage:** Markdown source packs plus SQLite for terms, claims, corrections, runs, and measured outcomes.
- **Interface:** CLI or skill invocation first; a small local web view later if side-by-side source inspection becomes painful.

## Architecture and Data Model

`ExpertLensRequest` stores domain, subdomain, situation, counterpart, jurisdiction, date, user level, objective, and time budget. `SourceRecord` stores canonical URL or file hash, owner, version/publication date, retrieval time, authority type, and usable passages. `Concept` stores preferred label, aliases, plain explanation, operational definition, adjacent concepts, examples, non-examples, and sources. `MechanismEdge` stores cause, effect, conditions, confounders, and evidence. `ExpertQuestion` stores the question, question class, why it matters, expected discriminating answers, follow-ups, and evidence needed. `Claim` stores text, source spans, scope, confidence, and freshness. `ConversationReview` records observed vocabulary, useful questions, corrections, unknowns, and outcome.

The pipeline should be staged and inspectable:

1. Scope the field tightly and identify source classes before searching.
2. Retrieve primary/authoritative material and retain exact passages with provenance.
3. Extract terms, actors, metrics, mechanisms, and points of disagreement.
4. Normalize aliases and construct broader/narrower and frequently-confused relationships.
5. Generate questions from missing edges, disputed assumptions, failure modes, and the user's decision—not merely from term frequency.
6. Run entailment, source-coverage, date/jurisdiction, and paraphrase checks.
7. Render a time-budgeted field card and rehearsal.
8. Learn only from explicit user corrections and post-conversation evidence.

## Expert Question Taxonomy

- **Definition:** “When you say X, which operational definition are you using?”
- **Boundary:** “Where does this model stop applying?”
- **Mechanism:** “What is the causal path between this intervention and the measured outcome?”
- **Measurement:** “Which leading indicator moves before the lagging metric, and how noisy is it?”
- **Workflow:** “Where is the handoff, queue, approval, or reconciliation step that usually fails?”
- **Counterfactual:** “What observation would make you reverse this recommendation?”
- **Trade-off:** “What did this optimize, and what became worse as a result?”
- **Base rate:** “How often does this failure occur in the relevant population, version, or operating regime?”
- **Implementation:** “Which dependency, standard, tolerance, or migration constraint determines feasibility?”
- **Incentive:** “Who benefits from this metric or categorization, and who bears the error?”

The question generator should know that expert questions are not always obscure. Often the most credible move is asking for a definition, denominator, baseline, failure criterion, or decision rule at exactly the right moment.

## Build Slices

1. Static field-card prompt, schemas, and five-source evidence ledger.
2. Terminology extractor with aliases, contrasts, examples, and paraphrase tests.
3. Domain topology and mechanism map with inspectable source spans.
4. Question taxonomy, ranking rubric, and rehearsal mode.
5. Ten-domain evaluation set with novice, practitioner, and deliberately misleading answers.
6. Post-conversation review, corrections, and versioned reusable domain packs.
7. Optional calendar/Obsidian adapters and live transcription only after preparation mode proves useful.

## Drawbacks, Concerns, and Failure Modes

- **Jargon theatre:** fluent vocabulary can conceal shallow reasoning. Require a plain paraphrase, contrast, mechanism, and source before recommending a term.
- **Domain scope collapse:** “AI,” “finance,” or “medicine” is too broad. Ask for subfield, decision, jurisdiction, counterpart, and time horizon.
- **Stale expertise:** standards, APIs, clinical guidance, regulation, and product practice change. Record source dates and flag freshness-sensitive claims.
- **Prestige-source bias:** an authoritative source may be irrelevant to the actual operating context. Separate authority, recency, applicability, and evidentiary support.
- **Citation laundering:** retrieval does not prove entailment. Keep exact passages and test whether each claim is actually supported.
- **Over-questioning:** a barrage of sophisticated questions can make a conversation worse. Rank questions by information gain and social timing.
- **False impersonation:** preparation must not invent qualifications, hands-on experience, affiliations, or outcomes. The skill can make understanding impressive without fabricating identity.
- **Live-copilot latency:** delayed advice is distracting. Keep live mode as recognition and follow-up suggestions; do deep synthesis before or after the conversation.
- **Evaluation ambiguity:** sounding expert is subjective. Score source-grounded precision, discrimination between near concepts, question usefulness, correction rate, and user teach-back—not style alone.

## Clever Hacks and Simpler Alternative

- Start every domain pack with **10 terms, 5 distinctions, 5 questions, 3 failure modes, 1 mechanism map**.
- Mine glossaries, standards tables of contents, FAQ headings, API schemas, and review-paper taxonomies before running open-ended generation.
- Generate questions from contradictions and missing graph edges; these are more useful than generic “tell me more” prompts.
- Use a “forbidden jargon” rehearsal: explain the field without any specialist terms, then reintroduce only terms that compress a real concept.
- Build a small adversarial set where plausible-sounding definitions are subtly wrong; measure whether the skill detects them.
- Store `current_as_of`, jurisdiction, product version, and population beside every volatile claim.
- Simplest alternative: ask a strong model for a one-page briefing with five cited primary sources, then manually keep only terms you can teach back. This may deliver most personal value before any application is necessary.

## Success Measures

- At least 95% of retained factual claims have a source span and applicable date/context.
- Specialist-term precision and near-concept discrimination improve on a held-out test set.
- The user can explain at least 80% of retained terms plainly after a short delay.
- Practitioners rate the top five questions as relevant and discriminating, not merely sophisticated-sounding.
- Unsupported-confidence and fabricated-experience rates remain zero in regression tests.
- Real conversations yield more useful unknowns, decisions, or follow-ups per minute of preparation.
- Post-conversation corrections shrink across repeated work in the same domain.

## Product Path

Personal skill -> reusable private domain packs -> calendar-aware preparation workspace -> expert-reviewed team knowledge product -> optional real-time conversation companion. Keep the free/local stack for the personal version; use [[Scope Expansion Checklist]] only before distributing packs, processing other people's private conversations, or presenting the system as professional guidance.

## Related

- [[Batman Prep Time Skill]]
- [[Understand This Paper]]
- [[Personal Study Curriculum]]
- [[News Depth Telegram Skill]]
- [[Physics Claim Debunker Skill]]
- [[Project Ideas Index]]

