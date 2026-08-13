---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: support knowledge operations
form_factor:
  - local support analysis dashboard
  - documentation generator
deployment: local-first with optional help-center export
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#24. Support FAQ Builder]]"
status: concept
tags:
  - support
  - faq
  - knowledge-base
---

# Support FAQ Builder

> Import support conversations and turn repeated, successfully resolved problems into draft FAQ pages, agent macros, and escalation rules with ticket-level evidence.

## Product Outcome

Reduce repeated support work while improving answer consistency. The system identifies high-volume, high-friction questions, drafts answers only from approved policy/product facts, and preserves a trace from every recommendation to anonymized ticket excerpts.

## User and Core Workflow

1. Import a bounded JSON/CSV export of tickets plus current help-center and policy documents.
2. Remove signatures, credentials, payment data, and direct identifiers.
3. Cluster customer intents and distinguish root problems from incidental wording.
4. Measure volume, resolution, reopen rate, sentiment, and escalation by cluster.
5. Draft FAQ pages, macros, and explicit “do not automate” escalation rules.
6. Support lead reviews evidence, answer accuracy, tone, ownership, and expiry.
7. Export Markdown or publish through a later approved connector, then monitor deflection and reopen outcomes.

## Demo/Personal V0

Use 100 synthetic support tickets and five product-policy documents. Produce a ranked issue list, three FAQ drafts, three macros, and a coverage report. Each sentence in a draft must cite a policy/source passage or be labeled as a proposed clarification.

## Build Boundary

- In scope: authorized exports, PII redaction, intent clustering, frequency/quality metrics, grounded drafting, review, and static export.
- Out of scope: live autonomous customer replies, training on private data without permission, inventing policy, or publishing automatically.
- Never use resolved tickets alone as truth; policy and product documentation govern answers.
- High-risk topics—security, legal, refunds, vulnerable users—route to humans.

## Existing Products, Building Blocks, and Shortcuts

- [Zendesk Tickets API](https://developer.zendesk.com/api-reference/ticketing/tickets/tickets/) defines a future authorized ingestion adapter.
- [Zendesk Help Center API](https://developer.zendesk.com/api-reference/help_center/help-center-api/introduction/) offers draft/article publishing once review controls exist.
- [Docusaurus](https://docusaurus.io/docs) can render versioned Markdown FAQs locally without building a documentation frontend.
- [Qdrant quickstart](https://qdrant.tech/documentation/quickstart/) supplies local semantic retrieval if SQLite FTS and embeddings become insufficient.
- [Microsoft Presidio](https://microsoft.github.io/presidio/) can suggest PII spans before human verification.

## Recommended Free-First Stack

- Python, FastAPI, Pydantic, Polars, and SQLite/FTS5.
- Sentence Transformers for local clustering and retrieval; HDBSCAN for exploratory clusters.
- Presidio plus custom regexes for redaction, with raw imports separated from sanitized text.
- Ollama for cluster labels and drafts constrained to retrieved approved documents.
- Streamlit for evidence review and Docusaurus for final local documentation previews.

SQLite and static Markdown are enough for thousands of tickets; defer a vector database until retrieval quality or scale proves the need.

## Architecture/Data Model

`import_batch` owns `ticket`, `message`, `redaction`, `intent_cluster`, `resolution`, `source_document`, `source_span`, `draft_article`, `macro`, `escalation_rule`, `review`, and `publication`. Sanitized messages retain offsets to encrypted/local originals. Draft claims reference source spans, while ticket excerpts justify demand—not policy truth.

## Build Slices

1. Synthetic/CSV import, schema mapping, redaction, and searchable ticket viewer.
2. Intent clustering, cluster naming, volume/reopen/escalation metrics.
3. Approved-source ingestion and citation-grounded FAQ/macro drafts.
4. Evidence review, escalation-rule editor, expiry/owner fields, and Markdown export.
5. Help-center adapters and post-publication outcome monitoring.

## Drawbacks, Concerns, and Failure Modes

- Tickets contain sensitive personal, credential, and payment information.
- Clusters can merge distinct causes or split one issue across vocabulary.
- A frequently used workaround may conflict with current policy.
- Deflection can hide unresolved customers if measured without reopen/escalation rates.
- Documentation becomes stale when products, prices, and policies change.

## Clever Hacks and Simpler Alternative

- Start with ticket subject plus final agent resolution, not entire transcripts.
- Rank gaps by volume multiplied by handling time and reopen rate.
- Require an owner and review-by date for each draft article.
- Build a “not enough approved evidence” queue that tells the team what documentation is missing.
- Simplest alternative: produce a weekly top-ten repeated-question report with links to representative tickets.

## Success Measures

- PII fixture values do not appear in sanitized exports.
- Every answer claim is cited to an approved product/policy source.
- Human reviewers accept or edit at least 70% of top cluster labels.
- Track handling time, reopen rate, escalation rate, and article helpfulness—not deflection alone.
- Expired or source-invalidated drafts cannot be published.

## Product Path

Start as a local analysis tool for exported tickets and a Markdown help center. Later add scheduled connectors, team approval, multilingual drafts, article freshness monitoring, and SaaS help-center publishing. Public release needs connector terms, tenant isolation, retention controls, and model-training assurances.

## Related

- [[Data Room Concierge]]
- [[User Research Agency]]
- [[Maintainer Desk]]
