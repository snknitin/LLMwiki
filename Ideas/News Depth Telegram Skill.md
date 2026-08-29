---
type: skill-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Cognitive Support and Explanation Skills#4. News Depth Telegram Skill]]"
status: concept
difficulty: medium
priority: p1
category: news explanation
form_factor:
  - Telegram bot
  - reusable explanation skill
deployment: local-first
source_ideas:
  - explain any news topic at ELI5 and ELI12 depth in Telegram
tags:
  - news
  - explanation
  - telegram
  - citations
  - media-literacy
---

# News Depth Telegram Skill

> Send a headline, link, screenshot, or question to Telegram and receive a layered, source-backed explanation that can move from “five-year-old intuition” to adult detail without pretending that complexity has disappeared.

## Product Outcome

The bot turns a news item into a navigable explanation rather than one long summary. The first screen answers what happened and why it matters. Buttons reveal background, actors and incentives, timeline, disputed claims, numbers in scale, primary evidence, and an adult technical/legal/economic explanation.

“ELI5” and “ELI12” are reading modes, not truth-confidence levels. Simplification must preserve causality, distinguish fact from analogy, and explicitly state what was omitted.

## User and Core Workflow

1. User forwards a URL, Telegram post, image, pasted text, or topic.
2. The skill identifies the event, date, geography, entities, and the exact claim needing explanation.
3. It retrieves several high-trust sources, prioritizing primary documents and direct statements while retaining publication timestamps.
4. It separates confirmed facts, attributed claims, analysis, and unknowns.
5. It builds one internal explanation graph, then renders several depths:
   - **60 seconds:** what happened, why now, why care.
   - **ELI5:** one concrete analogy plus the core causal chain.
   - **ELI12:** vocabulary, actors, timeline, incentives, and counterpoint.
   - **Adult/technical:** primary evidence, mechanisms, numbers, uncertainty, and links.
6. Buttons ask `why?`, `what happened before?`, `who benefits?`, `show disagreement`, `check this number`, or `quiz me`.
7. Useful explainers can be saved into Obsidian or passed to [[Personal Study Curriculum]].

## Personal V0

- Accept pasted headline/text and one URL through Telegram.
- Research a maximum of five sources and preserve exact source dates.
- Return a 150-word quick explanation plus expandable ELI5, ELI12, timeline, and evidence blocks.
- Add one “what would change this explanation?” uncertainty section.
- Save the final Markdown and feedback locally.
- Test on twenty stories across science, markets, geopolitics, technology, policy, and local news.

## Build Boundary

**MVP:** explicit user query, URL/text ingestion, primary-source search, layered explanation, citations, Telegram buttons, and local archive.

**Later:** voice notes, screenshots/OCR, recurring topic dossiers, daily briefs from [[Personal Signal Intelligence OS]], spaced-repetition follow-ups, and multilingual explanations.

This skill explains reported events. It does not predict markets, make legal/medical decisions, or silently convert opinion into fact.

## Existing Products, Building Blocks, and Shortcuts

- [Telegram Bot API](https://core.telegram.org/bots/api) supplies forwarded messages, inline keyboards, edits, files, and command routing; a single-user allowlist is enough for the personal bot.
- [Trafilatura](https://github.com/adbar/trafilatura/trafilatura), [Mozilla Readability](https://github.com/mozilla/readability), and Playwright cover ordinary article extraction before a paid browsing service is necessary.
- [GDELT](https://www.gdeltproject.org/) can discover coverage and timelines; use owning institutions, government releases, filings, court documents, papers, and direct transcripts as evidence wherever possible.
- [Wikidata](https://www.wikidata.org/wiki/Wikidata:Data_access) and Wikipedia page history are useful for entity orientation and vocabulary, not for replacing current primary reporting.
- Perplexity, Gemini, ChatGPT, Ground News, and Artifact-like readers are product references for sourced summaries and perspective comparison. The differentiator is layered pedagogy, an explicit claim ledger, personal memory, and local archiving.
- The simplest alternative is a reusable prompt that returns four fixed blocks for a pasted article. Build a bot only after the format proves useful.

## Recommended Free-First Stack

- **Bot:** Python with `python-telegram-bot` or TypeScript with grammY.
- **Research worker:** FastAPI/Python, direct web fetch + Readability/Trafilatura, Playwright fallback, and a strict source budget.
- **Storage:** SQLite for queries, sources, claims, feedback, and saved explainers; Markdown export to Obsidian.
- **Model routing:** strong hosted research model for time-sensitive retrieval if desired; local model for rewriting depth levels and quizzes.
- **Schemas:** Pydantic/Zod claim records with source, quote/span pointer, timestamp, status, and confidence.
- **Scheduling:** APScheduler/n8n only for followed topics; user-triggered requests need no queue beyond a simple job table.

## Explanation Contract

Every answer contains:

- **As-of time** and event date.
- **One-sentence answer.**
- **Causal chain** with no missing step hidden by an analogy.
- **Claim ledger:** confirmed, claimed-by, inferred, disputed, unknown.
- **Scale:** denominators, baseline, and comparison when numbers matter.
- **What the simple version leaves out.**
- **Source links** placed next to the claims they support.
- **Correction path** so the user can challenge an entity, date, number, or mechanism.

## Architecture and Data Model

`Question` owns user input and requested depth. `EventEntity` normalizes people, organizations, places, and dates. `SourceDocument` stores URL, publisher/owner, published/retrieved timestamps, extraction route, and hash. `Claim` stores proposition, type, evidence spans, counterevidence, and status. `ExplanationGraph` contains prerequisite concepts and causal edges. `RenderedExplanation` stores depth/template/model versions. `Feedback` records unclear, too simple, wrong, useful, or follow-up.

## Build Slices

1. Telegram text/link intake and one-source extraction.
2. Claim ledger and quick/ELI5/ELI12 renderers.
3. Multi-source reconciliation and timeline.
4. Inline follow-up buttons and saved Markdown.
5. Evaluation fixtures and correction replay.
6. Screenshot, audio, multilingual, and scheduled topic features.

## Drawbacks, Concerns, and Failure Modes

- Breaking news changes quickly. Display timestamps and allow regeneration rather than overwriting history.
- Simplification can remove the premise that makes a claim true. Include “what this leaves out.”
- More sources do not automatically mean more truth. Prefer independent evidence and primary artifacts over repeated syndication.
- Analogies can teach the wrong mechanism. Label the mapping and its limit.
- A model may fabricate a consensus or disagreement. Tie each position to a named source.
- The bot can become another stream of low-value information. Keep it pull-based and connect it to deliberate study/action.

## Clever Hacks and Simpler Alternative

- Generate one canonical adult explanation first, then derive simpler layers from its claim graph instead of independently prompting each version.
- Use Telegram message edits and buttons so the chat remains compact.
- Add a `numbers` button that runs deterministic calculations and unit conversions outside the model.
- Store recurring actors and concepts as small background cards; later explainers link rather than repeat them.
- Turn the final explanation into three recall questions only when the user taps `learn this`.

## Success Measures

- Every factual claim in the adult layer has a source or is explicitly marked inference/unknown.
- Test users can answer the event’s who/what/why after the ELI12 layer.
- Corrections to entities, dates, and numbers survive regeneration.
- Median first response stays within the chosen latency budget.
- The user saves or follows up on a meaningful fraction of explainers instead of merely requesting more summaries.

## Product Path

Personal Telegram skill -> reusable research/explanation harness skill -> classroom/media-literacy tool -> multi-user news explainer. Before public operation, run [[Scope Expansion Checklist]] for data retention, publisher/platform use, moderation, high-stakes domains, and deployment. These later concerns do not change the local bot stack.

## Related

- [[Personal Signal Intelligence OS]]
- [[Personal Study Curriculum]]
- [[Physics Claim Debunker Skill]]
- [[YouTube Learning Center]]
- [[Project Ideas Index]]
