---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#21. Jobs Search and Apply Tool]]"
status: concept
difficulty: medium
priority: urgent
urgency: personal-beta-by-2026-08-27
category: career operations
form_factor:
  - browser capture
  - local dashboard
deployment: local-first
source_ideas:
  - jobs search and apply tool
tags:
  - jobs
  - resume
  - automation
  - personal-use
---

# Jobs Search and Apply Tool

> A private job-search command center that captures roles from user-selected sources, ranks fit with visible evidence, prepares truthful application packets, and tracks follow-ups while keeping final submission under human control.

## Product Outcome

Replace scattered tabs and duplicate applications with one pipeline: discovered → qualified → preparing → ready for review → applied → interview → closed. For each role, show must-haves, likely gaps, why it fits current goals, a tailored resume diff, draft responses, and the exact evidence supporting every candidate claim.

## Personal V0

- Capture a job URL or paste the description.
- Normalize company, role, location, compensation when stated, requirements, responsibilities, deadline, and source.
- Maintain one canonical profile of skills, achievements, projects, work authorization, preferences, and forbidden claims.
- Score roles using deterministic hard filters plus an explainable fit rubric.
- Generate a tailored resume by selecting and reordering verified bullets rather than inventing experience.
- Draft a concise cover note and application answers with evidence links to the canonical profile.
- Show a redline between base and tailored documents.
- Track submission date, version used, contact, follow-up, outcome, and learning.

## Build Boundary

**MVP:** manual URL/text capture, local pipeline, fit explanation, resume/cover-note draft, export packet, and manual application.

**Later:** email ingestion, official job-feed APIs, company research, interview prep, networking suggestions, and guarded form filling. Do not mass-apply, bypass CAPTCHAs, violate job-board terms, fabricate qualifications, or submit without review.

### Month-One Personal Beta

Build the canonical profile and paste-job workflow in the first week. Apply to real roles throughout the month and keep a gold set of at least twenty job descriptions with corrected extraction, hard-filter decisions, and approved/blocked resume claims. Add browser capture only after the packet is reliable. The beta must preserve document versions, recover from backup, and make unsupported language impossible.

## Existing Products, Building Blocks, and Shortcuts

- Greenhouse’s [Job Board API](https://developers.greenhouse.io/job-board.html) and Lever’s [Postings API](https://github.com/lever/postings-api) expose jobs for individual employers; [USAJOBS](https://developer.usajobs.gov/api-reference/) offers a genuine read-only aggregate for US federal roles. They are useful connectors, not a universal job-search API.
- [JSON Resume](https://jsonresume.org/schema) provides a canonical facts schema. Render tailored views with [Typst](https://typst.app/docs/), Pandoc, or controlled HTML/CSS and then extract the PDF text back as an ATS smoke test.
- Teal, Huntr, Simplify, and Jobscan are product references for tracking, tailoring, capture, and form assistance. The local differentiator is evidence IDs, redlines, privacy, and no mass application.
- A bookmarklet using selected text is the fastest capture tool; it avoids logged-in scraping. The smallest useful flow is URL/text → five requirements → supported/partial/missing evidence → reviewed packet → open official application page.

## Free-First Stack

- **Dashboard:** local SvelteKit/Next.js; Streamlit is acceptable for the first vertical slice.
- **Service/data:** FastAPI plus SQLite.
- **Capture:** paste form or localhost bookmarklet before a Manifest V3 extension.
- **Extraction:** local LLM producing a typed schema, backed by manual correction and deterministic validation.
- **Documents:** canonical Markdown/YAML rendered through HTML/CSS or Pandoc into ATS-friendly PDF/DOCX.
- **Ranking:** hard filters and a weighted rubric before embeddings.
- **Automation:** n8n for reminders and permitted inbox ingestion, never final submission.
- **Models:** Ollama locally; a paid model only if a blind evaluation wins on extraction or editing.

## Trust and Privacy Contract

The canonical profile is the only source of candidate claims. Generated text references profile evidence IDs, and unsupported sentences are blocked. Job descriptions and application responses may contain personal data; keep them local, redact direct identifiers from unnecessary model prompts, and store credentials nowhere in the app.

## Clever Hacks and Simpler Alternative

- A bookmarklet posting the current URL and selected text to localhost is faster and less fragile than a full extension.
- Generate an “application packet” folder—job summary, score, resume diff, cover note, questions—instead of automating ATS forms.
- Track response rate by source and fit band to improve search strategy, not to encourage keyword stuffing.
- If parsing is unreliable, require manual must-have selection; correction UX beats another week of scraper and prompt work.

## Build Slices

1. Canonical profile and truthful evidence IDs.
2. Job capture and editable normalized schema.
3. Hard filters and fit explanation.
4. Resume bullet selection/redline and cover note.
5. Export packet and pipeline board.
6. Reminder/response analytics.
7. Permitted source connectors and guarded form assistance.

## Battle-Testing Gates

- Twenty corrected job fixtures rerun without regressions.
- Every generated claim resolves to a canonical evidence ID.
- Duplicate roles and changed descriptions are detected by URL/content hash.
- Exports remain readable by a plain-text parser.
- Backup/restore reproduces the application pipeline and document versions.
- A qualified role becomes a reviewed packet in under fifteen minutes.

## Product Path

Keep it personal until source access and workflow quality are proven. A responsible product can sell private application organization and evidence-grounded tailoring; “one-click apply to thousands of jobs” is a poor product direction for candidates and employers.

## Related

- [[Personal Library Website]]
- [[Goal-to-Calendar Planner]]
- [[Jarvis and Alfred]]
- [[Personal Study Curriculum]]
- [[First Month Build Program]]
- [[Project Ideas Index]]
