---
type: project-spec
source: hermes-hackathon
difficulty: hard
category: regtech
form_factor:
  - local compliance calendar
  - evidence checklist
deployment: local-first
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#6. Compliance Autopilot]]"
status: concept
tags:
  - india
  - compliance
  - deadlines
---

# Compliance Autopilot

> A source-dated obligation register for one Indian company that explains applicability, prepares evidence, and keeps filing/signing with the founder and their CA/CS.

## Product Outcome

Replace scattered reminders with a living compliance ledger: obligation, legal/source basis, entity facts that trigger it, period, due-date rule, current official date, owner, preparer checklist, evidence, professional confirmation, and completion receipt. “Autopilot” means dependable preparation and follow-through, not unsupervised legal judgment.

## User and Core Workflow

The founder answers a versioned entity questionnaire. A rule pack proposes MCA, GST, TDS, payroll, and board obligations with explanations. The user or professional confirms applicability. The system produces a calendar and evidence checklist, imports completion receipts, and flags source changes or missing inputs. Draft forms/checklists remain non-authoritative until approved.

## Demo/Personal V0

Model one fictional Indian private limited company with GST registration and a small payroll. Encode ten manually verified obligations for one quarter, show why each applies, generate `.ics`/Markdown reminders, and simulate an official due-date extension that supersedes the original date.

## Build Boundary

No filing, DSC use, portal credential storage, tax/legal advice, penalty guarantee, or claim of complete coverage. Do not scrape authenticated government portals. Every rule needs jurisdiction, entity predicates, effective dates, source URL, reviewer, and “last checked.”

## Existing Products, Building Blocks, and Shortcuts

- The [MCA portal](https://www.mca.gov.in/) and official V3 guidance are the source of truth for company forms; link users to the current form rather than reproducing portal logic.
- The [GST Portal GSTR-1 guide](https://tutorial.gst.gov.in/userguide/returns/GSTR_1.htm) documents filing cadence and dates, including that notified extensions can change them.
- The [Income Tax e-Filing portal](https://www.incometax.gov.in/iec/foportal/) exposes an official tax calendar, while current [TDS transition guidance](https://www.incometax.gov.in/iec/foportal/help/all-topics/e-filing-services/tds-compliance) shows why rules must be effective-dated.
- [OpenFisca](https://github.com/openfisca/openfisca-core) is a useful rules-engine reference; its model is a shortcut for versioned calculations, not an India compliance content source.

## Recommended Free-First Stack

Use Python/FastAPI, Pydantic rule schemas, SQLite, APScheduler, and a local SvelteKit calendar/checklist UI. Store official PDFs/pages as hashes plus links, not copied law text alone. Use deterministic rules for applicability and dates; a local model may summarize changes only with source spans.

## Architecture/Data Model

Entities: `EntityProfileVersion`, `Fact`, `RulePack`, `ObligationRule`, `ObligationInstance`, `Source`, `DueDateRevision`, `EvidenceRequirement`, `Task`, `ProfessionalReview`, and `CompletionReceipt`. Separate rule truth from company facts and generated instances so any date can be recomputed.

## Build Slices

1. Versioned company questionnaire.
2. Ten-rule fixture pack with source metadata.
3. Applicability explanations and calendar generation.
4. Evidence checklist and reminder policy.
5. Due-date revision/supersession.
6. Professional review and completion receipt archive.

## Drawbacks, Concerns, and Failure Modes

Applicability is nuanced; portals and laws change; circulars extend dates; entity facts go stale. Missing one obligation causes disproportionate harm, while false positives create alert fatigue. Official pages may be inaccessible or ambiguous. Sensitive corporate/tax data needs strict local access and backup.

## Clever Hacks and Simpler Alternative

Build a “compliance compiler” from a CA-reviewed spreadsheet: predicates, cadence, date formula, evidence, and source. Generate tasks and `.ics`; do not build portal automation. A weekly “facts changed?” prompt is more valuable than another chatbot.

## Success Measures

- Every calendar item explains applicability and links to a current primary source.
- A source/date revision updates affected instances without erasing history.
- No item is marked complete without evidence or professional override.
- The fixture company’s expected ten obligations reproduce exactly.
- Users can export a quarter’s evidence packet in one action.

## Product Path

Keep the first version personal and co-managed with a CA/CS. A commercial vertical would require jurisdiction-specific expert content operations, professional liability boundaries, secure integrations, and continuously monitored official sources.

## Related

- [[Tax Packet Autopilot]]
- [[Finance Ops Agency]]
- [[Personal Finance Cockpit]]
