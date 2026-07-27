---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: sales operations agents
form_factor:
  - local agent workbench
  - CRM export pipeline
deployment: local-first with optional approved SaaS connectors
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#17. Sales Development Agency]]"
status: concept
tags:
  - sales
  - crm
  - enrichment
---

# Sales Development Agency

> A research-and-drafting desk that turns an ideal-customer profile into a sourced account brief, ranked contacts, human-reviewed outreach, call notes, and a CRM-ready import.

## Product Outcome

Produce a small, defensible pipeline rather than a giant scraped list. Every company claim carries a URL and retrieval date; every email remains a draft until approved. The useful artifact is a CRM import plus an evidence packet explaining why each account belongs.

## User and Core Workflow

1. Define ICP, exclusions, geography, deal size, and trigger signals.
2. Import a user-owned account list or discover a bounded set from permitted sources.
3. Research company facts, likely pain, relevant role, and confidence.
4. Deduplicate contacts and optionally verify business addresses through an authorized provider.
5. Draft a short sequence and call opener from cited facts.
6. Review, suppress, edit, and export CSV to the CRM.
7. Import outcomes later so scoring can be evaluated rather than guessed.

## Demo/Personal V0

Use 20 companies from a manually supplied CSV. Research only public company pages and selected registries, generate one account brief and one email draft per account, and export a HubSpot-compatible CSV. Do not send messages or crawl social networks.

## Build Boundary

- In scope: ICP rubric, bounded research, provenance, deduplication, ranking, draft creation, suppression list, and CSV export.
- Out of scope: credentialed scraping, automated bulk outreach, guessed personal addresses, purchasing lead lists, or autonomous CRM writes.
- Require an explicit approval checkpoint before export and another before any future send connector.
- Store business contact data minimally and support deletion by source batch.

## Existing Products, Building Blocks, and Shortcuts

- [HubSpot CRM imports](https://developers.hubspot.com/docs/api/crm/imports) define a concrete import contract; generating its CSV is much simpler than building a CRM.
- [Hunter Email Verifier API](https://hunter.io/api-documentation/v2) can validate an address the user is authorized to process; treat its result as a signal, not permission to contact.
- [Google Sheets API](https://developers.google.com/sheets/api) makes a familiar review queue and lightweight shared handoff without a custom grid.
- [Companies House API](https://developer.company-information.service.gov.uk/) and [SEC EDGAR APIs](https://www.sec.gov/search-filings/edgar-application-programming-interfaces) offer authoritative company facts for applicable jurisdictions.

## Recommended Free-First Stack

- Python, FastAPI, and Pydantic for typed enrichment jobs and CSV contracts.
- SQLite plus FTS5 for a transparent local account/evidence store.
- Playwright only for permitted public pages that lack an API; cache raw evidence and rate-limit by domain.
- Ollama or llama.cpp for extraction and drafting; reserve a paid model for selected low-confidence accounts.
- Streamlit for the first approval UI and Polars for deterministic import/export transforms.

This stack keeps the first version local and inspectable. Sheets or HubSpot are output adapters, not core dependencies.

## Architecture/Data Model

`campaign` owns `icp_rule`, `account`, `contact`, `evidence`, `signal`, `draft`, `suppression`, and `outcome`. Evidence records URL, excerpt, retrieval time, parser version, and content hash. Scores store component values and model/rule versions. A state machine moves drafts through `researched`, `needs_review`, `approved`, `exported`, and optionally `sent`.

## Build Slices

1. ICP form, account CSV import, deduplication, and HubSpot CSV export.
2. Evidence fetcher, source viewer, and rule-based company scoring.
3. Role/contact matching, optional verification adapter, and suppression workflow.
4. Grounded email/call drafts with inline citations and approval queue.
5. Outcome import, score calibration, and connector plug-ins.

## Drawbacks, Concerns, and Failure Modes

- Public facts can be stale, while role and email inference can be wrong.
- Outreach can become spam or violate platform terms and local marketing/privacy rules.
- A persuasive model can invent urgency or falsely imply a relationship.
- Proxy metrics such as opens reward noise; replies, meetings, and complaints reveal more.
- Automated scoring may encode biased industry, location, or company-size assumptions.

## Clever Hacks and Simpler Alternative

- Start from a user-curated list; improve research quality before attempting discovery.
- Make “why now?” require one recent, cited signal or leave it blank.
- Use deterministic message blocks around one grounded custom sentence.
- Hash normalized domains and emails to deduplicate before any model call.
- Simplest alternative: a spreadsheet add-on that fills evidence, score, and draft columns for ten selected accounts.

## Success Measures

- At least 90% of factual draft claims resolve to stored evidence.
- Fewer than 5% duplicate accounts or contacts in exported batches.
- A 20-account batch can be reviewed in under 30 minutes.
- Zero messages sent without explicit approval and zero suppressed contacts exported.
- Track positive replies and complaints when real outcomes become available.

## Product Path

Begin as a personal local research desk, then package repeatable vertical ICP templates. A paid product could add team review, CRM synchronization, licensed enrichment, audit logs, and usage-based research credits. Licensing and provider terms matter at release time; they do not need to complicate the local prototype.

## Related

- [[Microsite Factory]]
- [[Winback Agency]]
- [[AI Implementation Agency]]
