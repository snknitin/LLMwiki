---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: career learning
form_factor:
  - local voice web app
  - practice dashboard
deployment: local desktop with optional DGX Spark inference
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#14. Mock Interview Gauntlet]]"
status: concept
---
# Mock Interview Gauntlet

> A 20-minute adaptive practice interview with replay-linked feedback grounded in the job description, resume, and a visible competency rubric.

## Product Outcome

Help a candidate improve answer structure, evidence, clarity, and handling of follow-up pressure. The system should coach observable behavior, not claim to predict hiring success.

## User and Core Workflow

The candidate uploads a job description and resume, corrects extracted requirements, and chooses interview type. A state machine selects questions, listens to the answer, asks bounded follow-ups, and records the session. The review page links rubric feedback to transcript timestamps and invites a revised answer.

## Demo/Personal V0

Support one behavioral interview: five questions, one follow-up per question, browser audio, local transcription, and a replay page. Include a text-only fallback and compare the first answer with a re-recorded attempt.

## Build Boundary

Include document intake, competency map, timed state machine, audio recording, transcript correction, rubric scoring, evidence, and retry. Exclude emotion detection, accent scoring, hiring prediction, live cheating, and employer-facing surveillance.

## Existing Products, Building Blocks, and Shortcuts

- [O*NET Web Services](https://services.onetcenter.org/) provides structured occupation and skill references.
- [MediaRecorder](https://www.w3.org/TR/mediastream-recording/) handles in-browser audio capture.
- [Whisper](https://github.com/openai/whisper) replaces paid transcription for local practice.
- [JSON Resume schema](https://jsonresume.org/schema/) offers a structured resume interchange format.

## Recommended Free-First Stack with Rationale

Use TypeScript/Next.js for the browser session, Python/FastAPI for Whisper and scoring, SQLite for runs, and Ollama or a DGX-hosted model for question selection. A deterministic state machine controls timing; the model works inside a rubric schema.

## Architecture/Data Model

Model `profiles`, `job_descriptions`, `competencies`, `question_bank`, `sessions`, `turns`, `recordings`, `transcript_segments`, `rubric_scores`, `evidence_spans`, and `retries`. Each score requires a cited answer span and a confidence field.

## Build Slices

1. JD/resume extraction, competency editor, and text interview.
2. Audio capture, local transcription, and replay.
3. Adaptive follow-ups, rubric scoring, and evidence.
4. Retry comparison and personalized practice plan.

## Drawbacks/Concerns/Failure Modes

Rubrics can encode bias; transcription errors distort feedback; generic questions feel fake; and model scores may look authoritative. Let users correct transcripts, avoid protected-trait inference, expose scoring definitions, and emphasize practice signals over verdicts.

## Clever Hacks and Simpler Alternative

Start with asynchronous “record one answer, get one evidence-linked critique.” This isolates feedback quality before building real-time turn-taking or voices.

## Success Measures

Track session completion, transcript correction rate, evidence-supported feedback, rubric agreement with self-review, improvement on retry, and weekly practice retention.

## Product Path

Personal practice coach → open-source interview trainer → role-specific learning product. Before shared accounts, paid models, employer use, or public scoring, run [[Scope Expansion Checklist]] for fairness, data rights, consent, and release obligations; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#14. Mock Interview Gauntlet]]
- [[Scope Expansion Checklist]]

