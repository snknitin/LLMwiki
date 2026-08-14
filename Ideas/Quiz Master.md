---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - New Personal Workflows and Product Ideas#8. Quiz Master]]"
status: concept
difficulty: hard
priority: p1
category: quiz authoring and knowledge games
form_factor:
  - local authoring studio
  - question-of-the-day bot
  - question-pack API
deployment: local-first
source_ideas:
  - reverse-engineer K-Circle-style quiz question patterns
  - generate clue-driven brain teasers rather than plain trivia
  - publish question of the day
  - feed authored questions into Quiz Poker
tags:
  - quiz
  - question-generation
  - knowledge
  - authoring
  - puzzles
---

# Quiz Master

> A quiz-authoring studio that learns the craft patterns of high-quality clue-driven questions, converts ordinary topics into satisfying “aha” paths, and produces reviewed question packs for [[Quiz Poker]] or daily play.

## Product Outcome

Instead of asking “What is X?”, Quiz Master constructs a trail of independently meaningful clues that converge on an answer. It models the authoring process explicitly: choose a surprising connection, research source facts, select a framing archetype, order clues by information gain, remove giveaways, test ambiguity, write an explanation, and calibrate difficulty.

The user’s K-Circle yearbooks become a private style corpus for pattern discovery and evaluation. The generated output is always a draft with cited clue evidence and deterministic quality checks.

## Personal V0

1. Import a user-selected sample of 200 questions from the four yearbooks, preserving year/quiz/round/question metadata.
2. Manually label 40 questions by framing pattern, clue count, answer type, reveal structure, wordplay, difficulty, and why the question is satisfying.
3. Use those labels to induce a versioned taxonomy of question archetypes.
4. Given a topic or Wikipedia/Wikidata entity, gather source facts and candidate connections.
5. Generate three differently framed drafts with a clue-evidence ledger.
6. Run deterministic ambiguity, giveaway, source, answer-normalization, and wording checks.
7. Human-edit and playtest; record solve rate, clue where solved, confidence, and quality rating.
8. Publish one reviewed Question of the Day and export packs to [[Quiz Poker]].

## Build Boundary

**MVP:** corpus parser, annotation schema, pattern library, topic research, draft generator, review editor, question JSON export, and playtest metrics.

**Later:** image/audio/video clues, collaborative authoring, personalized difficulty, live host assistant, daily Telegram/web publishing, and automated pack balancing.

Quiz Master owns question quality and pack construction. [[Quiz Poker]] owns rooms, wagering, timing, scoring, and multiplayer reliability.

## Existing Products, Building Blocks, and Shortcuts

- [MediaWiki Action API](https://www.mediawiki.org/wiki/API:Main_page) and [Wikidata Query Service](https://query.wikidata.org/) supply entity facts, links, categories, dates, and graph connections; clue claims still retain exact sources.
- [K-Circle’s official site](https://www.kcircle.com/Home) and [yearbook page](https://www.kcircle.com/quizzes/buy-quiz-compilations-yearbook) establish the corpus and quiz-club context; the user-supplied yearbooks are the private style and evaluation material.
- [OpenAlex](https://docs.openalex.org/) and Crossref help with science/history-of-ideas questions; domain primary sources should replace encyclopedia facts when needed.
- [QTI](https://www.imsglobal.org/question/index.html) is an interoperability reference for conventional questions, while a custom versioned JSON schema can preserve clue order and reveal mechanics.
- [Anki](https://github.com/ankitects/anki), Kahoot, Quizizz, Sporcle, and trivia databases are product references for packs and delivery. They do not replace the authoring-pattern/evidence workflow.
- [spaCy](https://github.com/explosion/spaCy), sentence-transformers, and a local model can find entity connections and near-duplicate questions. Ordinary rules should test answer leakage and aliases.

## Recommended Free-First Stack

- Python/FastAPI with SQLite and a local SvelteKit/Streamlit editor.
- Docling/PyMuPDF/OCR for user-supplied yearbook ingestion.
- Pydantic schema for source facts, archetypes, clue drafts, accepted answers, explanation, and review state.
- Local embeddings and model for pattern analysis/drafting; a stronger model only if blind evaluation wins.
- Telegram bot or static site for Question of the Day.
- JSON pack adapter consumed by [[Quiz Poker]].

## Question Model

`SourceFact` stores proposition, entity, exact source span/link, date, and reliability. `QuestionArchetype` defines structural rules and examples. `QuestionDraft` stores answer entity, ordered clues, clue-source IDs, intended inference path, distractors, aliases, giveaway flags, and model/template versions. `Review` records edits and rejection reasons. `Playtest` stores participant result, solve point, confidence, time, and ambiguity report.

Useful archetypes may include progressive identification, hidden connection, lateral definition, before/after transformation, common link, sequence completion, two-domain bridge, “identify from consequences,” and apparently unrelated facts converging on one entity.

## Deterministic Quality Checks

- Every factual clue has a source.
- Answer string and aliases do not appear accidentally in clue text, filenames, or URLs shown to players.
- Clues do not independently support several plausible answers unless ambiguity is intentional.
- Earliest clue is hard but meaningful; final clue is solvable without being trivial.
- Dates, units, transliterations, and proper nouns are normalized.
- Explanation reconstructs the intended path rather than merely restating the answer.
- Pack avoids repeated answers, domains, and framing mechanisms.

## Build Slices

1. Corpus import, annotation UI, and 40-question gold set.
2. Archetype taxonomy with positive/negative examples.
3. Source-fact collector and topic-to-connection graph.
4. Structured generator and deterministic lint rules.
5. Review/playtest workflow and difficulty calibration.
6. Question-of-the-Day publisher.
7. Quiz Poker pack adapter and balanced pack builder.

## Drawbacks, Concerns, and Failure Modes

- Copying surface style produces imitation, not craft. Extract structural patterns and write new source-backed clues.
- Wikipedia association paths can be arbitrary. Each connection must be meaningful enough to explain after reveal.
- Models leak the answer through wording, capitalization, or clue order. Lint against aliases and embeddings.
- Difficulty is audience-dependent. Store audience and playtest distributions, not one universal label.
- Beautiful obscurity can become unfairness. Require a recoverable clue path and host adjudication notes.
- Generated volume can bury review. Limit daily drafts and optimize acceptance rate.

## Clever Hacks and Simpler Alternative

- Start with one archetype and twenty questions rather than reverse-engineering all four years.
- Ask the model to generate source facts and possible connections, while a deterministic template assembles the first draft.
- Show clues progressively during playtests and record the exact reveal that caused the solve.
- Maintain a “banal question transformer” that applies one selected framing rule to a normal trivia fact.
- Use rejected questions as negative examples in regression tests.

## Success Measures

- Reviewed draft acceptance rate improves without lowering playtest quality.
- Every clue is sourced and every accepted answer has aliases/adjudication notes.
- Players report a satisfying inference path rather than arbitrary obscurity.
- Difficulty predictions correlate with actual solve rates for the target group.
- Quiz Poker can import packs without manual schema repair.
- The Question of the Day remains varied across topics and archetypes.

## Product Path

Private authoring lab -> Quiz Poker content engine -> daily quiz publication -> collaborative quizmaster platform. Apply [[Scope Expansion Checklist]] before distributing corpus-derived models or public packs; this does not change the personal authoring stack.

## Related

- [[Quiz Poker]]
- [[Personal Study Curriculum]]
- [[Understand This Paper]]
- [[Taxonomy Cluster Explorer]]
- [[Project Ideas Index]]
