---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: learning-tools
form_factor:
  - local web app
  - study package generator
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#30. Course Notes to Quiz Product]]"
status: concept
tags:
  - study
  - quizzes
  - flashcards
---

# Course Notes to Quiz Product

> Turn notes into source-linked practice, then learn from mistakes instead of merely generating a pile of cards.

## Product Outcome

Upload or paste course notes and receive a concise outline, flashcards, varied quiz questions, answer explanations, and a practice session that points back to the exact source passage. Unsupported questions are rejected. The personal V0 optimizes for trustworthy study and rapid feedback, not LMS breadth.

## User and Core Workflow

1. Import Markdown, text, or a clean PDF and split it into source-addressable sections.
2. Confirm topics, learning objectives, and excluded material.
3. Generate candidate cards/questions with answer, distractor rationale, difficulty, and source IDs.
4. Validate that the answer is recoverable from the cited source; user reviews low-confidence items.
5. Run a quiz, record confidence/correctness, and schedule weak concepts.
6. Export selected cards/questions to common study formats.

## Demo/Personal V0

Paste one chapter of personal notes. Generate ten questions and twenty flashcards, each with a source excerpt/link. Run a five-question local session and export Markdown plus Moodle GIFT. No accounts or PDF OCR in the first slice.

## Build Boundary

**MVP:** Markdown/text import, heading-aware chunks, MCQ/short-answer/flashcards, source citations, review queue, local practice history, GIFT/CSV export.

**Out:** plagiarism detection, graded assessment, proctoring, institutional analytics, arbitrary web research, multi-tenant classrooms, auto-submission to an LMS, and claims of guaranteed learning.

## Existing Products, Building Blocks, and Shortcuts

- Anki’s [FSRS documentation](https://docs.ankiweb.net/deck-options.html) provides a mature spaced-repetition path rather than inventing a scheduler immediately.
- [AnkiConnect](https://github.com/FooSoft/anki-connect) can create cards in desktop Anki, replacing custom cross-device review in a later phase.
- Moodle’s [GIFT format](https://docs.moodle.org/en/GIFT_format) is a simple text interchange for multiple-choice, true/false, short-answer, matching, and numerical questions.
- [1EdTech QTI](https://www.1edtech.org/standards/qti/index) is the fuller assessment interchange standard when LMS portability becomes important.

## Free-First Stack

- **App:** Python + FastAPI/HTMX or Streamlit for the quickest local study flow.
- **Parsing:** Markdown parser and PyMuPDF for clean PDFs later.
- **Model:** Ollama with strict question JSON schema.
- **Retrieval:** SQLite FTS5 first; embeddings only for cross-section concepts.
- **Storage:** SQLite for sources, items, attempts, and scheduling state.
- **Export:** Markdown, CSV, GIFT; AnkiConnect optional.

## Architecture/Data Model

`SourceDocument` has immutable `SourceChunk` IDs and hashes. `LearningObjective` maps to chunks. `StudyItem` stores type, stem, choices, correct answer, explanation, difficulty, and source IDs. `ValidationResult` records entailment/retrieval checks and reviewer decision. `Attempt` stores response, confidence, correctness, and latency. `ReviewState` schedules the next exposure.

## Build Slices

1. Paste/import and source chunk browser.
2. Flashcard generation with citations.
3. Question generation, distractor checks, and review.
4. Practice session and weak-topic summary.
5. GIFT/CSV/Anki export and spaced repetition.

## Drawbacks/Concerns/Failure Modes

- Generated questions can test facts not in notes. Require source IDs and reject unsupported answers.
- Plausible distractors may be ambiguous. Validate each against the source and allow “multiple correct” flags.
- Card volume creates an illusion of learning. Cap generation and prioritize objectives/weakness.
- PDF extraction can scramble equations and tables. Start with Markdown and expose parser confidence.
- Course materials may be copyrighted. Keep uploads local and exports personal unless rights are clear.

## Clever Hacks and Simpler Alternative

- Generate “question seeds” first, then have the user approve before expanding answers/distractors.
- Use cloze deletions for factual notes; they are cheaper and less hallucination-prone than complex MCQs.
- Ask for confidence before revealing the answer; calibration is a useful learning signal.
- Export to Anki rather than rebuilding a mature scheduler across devices.

## Success Measures

- 100% of accepted items link to at least one source chunk.
- Fewer than 5% of reviewed questions are ambiguous or unsupported.
- User reaches a useful first quiz within two minutes of paste.
- Weak-topic performance improves across repeated sessions.
- Exported GIFT/CSV imports without manual repair.

## Product Path

Personal local study tool → desktop/student product → course-specific packs → educator/LMS workflow. Expansion needs content-rights policy, accessibility, assessment validity, and data privacy review.

## Related Wikilinks

- [[Fine Print Rage Meter]]
- [[Contract Red Flag Memo]]
