---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: customer-support-operations
form_factor:
  - local analysis dashboard
  - agency deliverable generator
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch A#31. Customer Support Agency]]"
status: concept
tags:
  - customer-support
  - operations
  - knowledge-base
---

# Customer Support Agency

> Turn a ticket sample into a reviewed support operating system: issue taxonomy, macros, escalation tree, FAQ candidates, and a quality rubric.

## Product Outcome

Upload a de-identified ticket export and product/policy documents. The app clusters recurring requests, identifies unresolved or risky patterns, drafts response macros and FAQ candidates, proposes escalation rules, and scores a sample with an auditable rubric. It helps an operator design support—not impersonate one unsupervised.

## User and Core Workflow

1. Import CSV/JSON tickets and a product policy pack.
2. Detect/redact direct identifiers before model processing.
3. Normalize threads, channel, status, resolution, tags, and timestamps.
4. Cluster issues and sample representative tickets.
5. Draft macros/FAQ/escalation rules grounded in policy excerpts.
6. Human reviews, tests on holdout tickets, and exports an operations pack.

## Demo/Personal V0

Use 100 synthetic tickets with five issue families and known escalation cases. Produce a cluster dashboard, ten macros, five FAQ drafts, one decision tree, and a quality-score table. No live helpdesk connector or auto-replies.

## Build Boundary

**MVP:** CSV/JSON import, de-identification, issue clustering, policy-grounded drafts, review queue, holdout evaluation, Markdown/CSV export.

**Out:** autonomous customer replies, refunds/account actions, live inbox takeover, identity resolution, sentiment-based priority alone, employee performance ranking, and multi-client tenancy.

## Existing Products, Building Blocks, and Shortcuts

- [Chatwoot](https://github.com/chatwoot/chatwoot) is an open-source, self-hosted omnichannel support desk and can replace building an inbox if the project later needs live operations.
- Zendesk’s [Tickets API](https://developer.zendesk.com/api-reference/ticketing/tickets/tickets/) provides structured ticket fields and incremental export paths for an integration phase.
- Intercom’s [Conversations API](https://developers.intercom.com/docs/references/2.10/rest-api/api.intercom.io/conversations) exposes paginated conversation data behind authenticated apps.
- Help Scout’s [List Conversations API](https://developer.helpscout.com/mailbox-api/endpoints/conversations/list/) supports status/tag/mailbox filtering and links to full threads.

## Free-First Stack

- **Analysis:** Python, Polars, scikit-learn, and sentence-transformers for transparent clustering.
- **App:** Streamlit for upload, redaction review, clusters, and macro approval.
- **Model:** local Ollama for structured draft generation grounded in approved policies.
- **Storage:** SQLite plus encrypted/local import directory; keep a de-identified working table.
- **Evaluation:** deterministic rubric runner and a hand-labeled holdout sample.
- **Export:** Markdown operations handbook, CSV macro library, and Mermaid decision tree.

## Architecture/Data Model

`ImportBatch` owns `TicketThread` and `Message`; raw and de-identified text are separated. `IssueCluster` has keywords, centroid, representatives, and reviewer label. `PolicyEvidence` stores source excerpts. `MacroDraft` and `FAQDraft` reference cluster and policy IDs. `EscalationRule` stores conditions/action/owner. `QualityReview` records rubric dimension, evidence, and reviewer correction.

## Build Slices

1. Synthetic import schema and direct-identifier redaction.
2. Clustering plus representative sample review.
3. Policy evidence library and grounded macro drafts.
4. Escalation tree, FAQ export, and rubric.
5. Holdout evaluation and one read-only helpdesk adapter.

## Drawbacks/Concerns/Failure Modes

- Ticket exports contain names, emails, order IDs, payment fragments, and health/legal details. Redact locally and minimize retention.
- Clusters overrepresent high-volume trivial issues. Rank by frequency, effort, risk, and churn signal separately.
- Macros can invent policy or sound robotic. Require policy references and owner approval.
- Sentiment is noisy and biased; use explicit urgency/account-risk signals and human escalation.
- API exports are paginated, rate-limited, and permission-sensitive. Start with a user-provided export.

## Clever Hacks and Simpler Alternative

- Start with “top 20 reasons people contact us” and a hand-labeled spreadsheet; automate only repeated work.
- Use active learning: ask the user to label only uncertain representative tickets, then propagate.
- Build macros as slots plus policy variables instead of fully generated prose.
- Score response quality with evidence-backed checkboxes before attempting an LLM critic.

## Success Measures

- Redaction tests remove all seeded identifiers before model input.
- At least 80% of tickets fit a reviewer-approved issue taxonomy.
- Every macro/FAQ claim links to approved policy evidence.
- Holdout reviewers accept at least 80% of escalation recommendations.
- Initial operations pack is produced in under one hour from a clean export.

## Product Path

Personal analysis notebook → repeatable agency deliverable → connected team QA desk → support-operations SaaS. Expansion requires customer-data agreements, access controls, retention/deletion guarantees, audit logs, and connector/license review.

## Related Wikilinks

- [[community-ops-agency|Community Ops Agency]]
- [[google-review-reply-desk|Google Review Reply Desk]]
