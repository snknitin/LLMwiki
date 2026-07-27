---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: social-quiz
form_factor:
  - shareable web app
  - private result card
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#27. Compatibility Duet]]"
status: concept
tags:
  - compatibility
  - quizzes
  - privacy
---

# Compatibility Duet

> A consent-based two-person conversation starter that reveals overlap and discussion prompts—not a prediction of relationship success.

## Product Outcome

Person A answers a short values/preferences interview and sends a one-time link. Person B answers independently without seeing A’s responses. Only after both finish does the app unlock a joint card showing areas of alignment, productive difference, and suggested questions. Either person can delete the session.

## User and Core Workflow

1. A chooses relationship context, creates a private session, and answers 12–20 questions.
2. A previews data use and sends an expiring invite.
3. B consents and completes the same or complementary questions.
4. Deterministic scoring compares dimensions and hides raw sensitive answers unless both opted to reveal them.
5. Both receive the same result card and discussion prompts.
6. Either participant can delete; unfinished sessions expire automatically.

## Demo/Personal V0

Run a localhost app with two browser profiles, six dimensions, a random invite code, and a deterministic radar/table result. Use SQLite and a 24-hour expiry. No accounts or public sharing.

## Build Boundary

**MVP:** one context, 16 fixed questions, mutual consent, expiring link, deterministic dimension scores, symmetric result, delete control.

**Out:** diagnosis, attachment-style claims, mental-health assessment, “soulmate percentage,” contact scraping, hidden tracking, public leaderboards, dating-platform integration, and unilateral profiles of another person.

## Existing Products, Building Blocks, and Shortcuts

- The [International Personality Item Pool](https://ipip.ori.org/) offers public-domain items and scoring guidance, replacing improvised personality questions when a validated construct is appropriate.
- [JSON Schema](https://json-schema.org/specification) provides a stable, validated question/answer/result contract across client and server.
- The [Web Cryptography API](https://www.w3.org/TR/WebCryptoAPI/) supplies standard browser primitives for random IDs, hashing, and encryption; it should not be used to invent a novel protocol.
- [Convex realtime](https://docs.convex.dev/realtime) could later replace polling for the “partner completed” unlock experience, but local V0 needs only refresh.

## Free-First Stack

- **App:** SvelteKit with server routes and progressive enhancement.
- **Storage:** SQLite; hash invite tokens and encrypt particularly sensitive answer blobs with a well-reviewed library.
- **Scoring:** TypeScript functions with versioned weights; optional LLM only for tone-safe discussion prompts.
- **Cards:** deterministic SVG/HTML rendered to PNG.
- **Expiry:** scheduled local cleanup plus expiry checks on every access.

## Architecture/Data Model

`DuetSession` stores context, status, expiry, and two participant slots. `QuestionVersion` freezes wording/scoring. `ResponseSet` stores answers and reveal preferences. `DimensionScore` stores each side and comparison rule. `ResultCard` references scoring version. `DeletionReceipt` records only non-identifying audit metadata.

## Build Slices

1. Question bank and deterministic score tests.
2. Create/join session with token hashing and expiry.
3. Independent response flow and mutual unlock.
4. Result card, reveal controls, and deletion.
5. Optional prompt generation and shareable cropped card.

## Drawbacks/Concerns/Failure Modes

- A single percentage implies scientific certainty; show dimensions and prompts, not a verdict.
- One person may pressure another to participate or reveal answers. Make decline/deletion silent and easy.
- Sensitive responses can harm relationships if exposed. Default to derived results only.
- Free-text generation can overinterpret. Ground prompts in explicit dimension rules and use tentative language.
- Browser links can be forwarded. Use expiring, single-use participant tokens and optional passphrases.

## Clever Hacks and Simpler Alternative

- A printable two-column question deck may prove the conversation value before any backend.
- Use “same / different / worth discussing” labels instead of a compatibility score.
- Keep the result symmetric so one participant is never framed as the problem.
- Include “three questions for your next conversation,” which is more actionable than a fancy chart.

## Success Measures

- Both participants finish at least 60% of started sessions.
- Every session can be deleted by either participant.
- No raw answer is revealed without explicit mutual choice.
- Test users describe results as “a useful conversation starter,” not “a diagnosis.”

## Product Path

Private local quiz → expiring hosted duet → themed friend/couple/team packs → paid conversation product. Public scope needs consent UX, age gating, data retention/security review, and careful claims language.

## Related Wikilinks

- [[AI Founder Archetype Quiz]]
- [[Clicky for Hinge]]
- [[Relationship Check-in Prompts]]

