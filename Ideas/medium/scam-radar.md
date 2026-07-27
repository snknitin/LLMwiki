---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: trust and safety
form_factor:
  - local evidence dashboard
  - browser-friendly checker
deployment: local desktop
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch B#27. Scam Radar]]"
status: concept
---
# Scam Radar

> Analyze a freelance gig, client, job post, domain, or link into a timestamped evidence report with risks, unknowns, and next checks—not a false “safe” verdict.

## Product Outcome

Help the user slow down before sending money, identity documents, or work. The report separates observed red flags, external threat intelligence, unverifiable claims, and practical verification steps.

## User and Core Workflow

Paste text, URL, email headers, or a redacted document. The system extracts entities and claims, checks URL/domain intelligence, searches a user-approved evidence set, and displays a weighted rubric. The user inspects receipts, marks outcomes, exports a redacted report, or follows official reporting links.

## Demo/Personal V0

Evaluate 30 known benign/scam examples with pasted text and URLs. Run deterministic text checks, RDAP domain lookup, Safe Browsing lookup, evidence timeline, and a redacted HTML report. Do not upload private documents to third parties.

## Build Boundary

Include local parsing, URL normalization, domain registration, threat-list checks, evidence timeline, uncertainty, redaction, and reporting links. Exclude doxxing, identity verification guarantees, active engagement with scammers, malware execution, and definitive safety certification.

## Existing Products, Building Blocks, and Shortcuts

- [Google Safe Browsing](https://developers.google.com/safe-browsing) checks URLs against threat lists for a non-commercial prototype.
- [VirusTotal’s official Python client](https://virustotal.github.io/vt-py/) can inspect URL/hash intelligence without automatically uploading private files.
- [RDAP RFC 9082](https://datatracker.ietf.org/doc/html/rfc9082) and the [IANA bootstrap](https://www.iana.org/assignments/rdap-dns/rdap-dns.xhtml) provide standardized domain data.
- India’s [National Cyber Crime Reporting Portal](https://www.cybercrime.gov.in/) is the official escalation destination.

## Recommended Free-First Stack with Rationale

Use Python, FastAPI, SQLite, httpx, a local rules engine, Ollama for claim extraction, and an HTMX evidence UI. Keep external lookups optional and cache only necessary results. Rules and timestamps remain independent of model prose.

## Architecture/Data Model

Model `cases`, `artifacts`, `entities`, `claims`, `checks`, `observations`, `evidence_sources`, `risk_rules`, `scores`, `unknowns`, and `outcomes`. Every check stores provider, query, timestamp, response summary, and expiration.

## Build Slices

1. Paste/redact flow, deterministic checklist, report.
2. URL canonicalization, RDAP, Safe Browsing, evidence timeline.
3. Weighted risk model, unknowns, feedback labels.
4. Optional hash-only VirusTotal and official report pack.

## Drawbacks/Concerns/Failure Modes

New scams evade lists; benign new domains look suspicious; absence of reports is not safety; and third-party checks can leak data. Show evidence age and confidence, distinguish risk from proof, avoid private uploads, and tell users to verify via independent channels.

## Clever Hacks and Simpler Alternative

Build a “pause checklist” browser share target: it extracts payment pressure, off-platform requests, identity mismatch, and URL age, then forces a 60-second review before the user continues.

## Success Measures

Track known-case precision/recall, false reassurance count, evidence freshness, private-data redactions, harmful actions avoided, reports filed, and outcome feedback collected.

## Product Path

Personal checker → open-source evidence toolkit → supervised trust product. Before browser distribution, shared reports, commercial intelligence APIs, or payments, run [[Scope Expansion Checklist]] for privacy, security claims, provider terms, moderation, and release needs; keep the local stack unchanged.

## Related Wikilinks

- [[Research - Hermes Batch B#27. Scam Radar]]
- [[Scope Expansion Checklist]]

