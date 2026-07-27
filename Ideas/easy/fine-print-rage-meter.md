---
type: project-spec
source: hermes-hackathon
difficulty: easy
category: consumer-document-explainer
form_factor:
  - local paste-first web app
  - browser-extension candidate
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#5. Fine Print Rage Meter]]"
status: concept
tags: [legal-text, consumer, explainability]
---

# Fine Print Rage Meter

> Surface five concerning clauses with exact excerpts and uncertainty; the comedic meter is secondary to traceability.

## Product Outcome

Paste terms or a privacy policy and receive a topic map plus five findings: clause excerpt, plain-English implication, why it matters, uncertainty, and question to ask. A playful score can summarize topic severity but must not pretend to be a legal judgment.

## User and Core Workflow

1. Paste text and optionally name the service/jurisdiction.
2. Segment and number clauses locally.
3. Retrieve candidate clauses for cancellation, arbitration, data use, renewal, liability, deletion, and changes.
4. Generate structured explanations tied to clause IDs.
5. User opens the exact source context and exports a memo.

## Demo/Personal V0

Paste-only React page, seven fixed topic checks, local model, exact clause drawer, and Markdown export. No URL fetching.

## Build Boundary

**MVP:** pasted text, clause IDs, five evidence-backed findings, uncertainty/not-found states, local processing.

**Out:** legal advice, enforceability verdicts, automated acceptance/rejection, arbitrary URL crawler, or jurisdiction-complete analysis.

## Existing Products, Building Blocks, and Shortcuts

- [Mozilla Readability](https://github.com/mozilla/readability) extracts main page text when URL import is added.
- [Playwright](https://playwright.dev/docs/api/class-page) renders JavaScript-heavy policy pages.
- [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) enforces clause, topic, explanation, severity, and uncertainty fields.
- [ToS;DR machine-readable data](https://tosdr.github.io/tosdr.org/api.html) can reuse community-reviewed findings for supported services.

## Free-First Stack

Static React/TypeScript + Zod + local Ollama; browser local storage only for explicitly saved reports. Add Readability/Playwright later in a locked-down fetcher.

## Architecture/Data Model

`Document` has numbered `Clause`s. `TopicRule` defines retrieval terms and limitations. `Finding` stores clause IDs, excerpt, implication, severity, uncertainty, and review note. `Coverage` records topics found/not found/not assessed.

## Build Slices

1. Paste/segment/search.
2. Fixed topic retrieval.
3. Evidence-constrained explanations.
4. Coverage and Markdown export.
5. Safe URL import and ToS;DR lookup.

## Drawbacks/Concerns/Failure Modes

- Missing referenced policies or jurisdiction changes meaning.
- A score creates false precision; show the underlying topics prominently.
- The model may omit or misread cross-references; surface coverage and source context.
- Arbitrary URL fetching creates SSRF risk; block private/reserved IPs, redirects, and non-HTTP schemes.

## Clever Hacks and Simpler Alternative

Drop the rage score in V0. Five exact excerpts with “what this could mean” and “needs human/legal review” are safer and more useful.

## Success Measures

- Every finding links to an exact clause.
- Unsupported topics say not found/not assessed.
- Pasted text never leaves the machine.
- User can audit all findings in under five minutes.

## Product Path

Local explainer → browser extension → consumer-policy monitoring product. Public scope needs legal review, safe-fetch infrastructure, jurisdiction boundaries, and source/model licensing.

## Related Wikilinks

- [[Contract Red Flag Memo]]
- [[Cold Email Rewrite Desk]]

