---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Personal Systems and Product Ideas#21. Jobs Search and Apply Tool]]"
upgrade_research_dossier: "[[Research - New Personal Workflows and Product Ideas#7. Jobs Search and Apply Tool Upgrade]]"
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
  - scheduled JobFinder with company level location and compensation filters
  - recency-query and direct hiring-manager discovery tactics
  - ATS and interview-platform preparation
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
- Maintain an explicit target-company watchlist with role families, levels, locations, salary floor, remote policy, and search connectors.
- Run scheduled searches daily, including configurable recency filters such as job-board URL parameters and public “we are hiring” posts.
- Link likely recruiters, hiring managers, team leads, alumni, and warm paths to a role, then draft a grounded outreach note.
- Generate a preparation dossier for shortlisted roles: company/product context, likely screen format, verified skill gaps, practice plan, and [[Batman Prep Time Skill]] handoff.

## Build Boundary

**MVP:** manual URL/text capture, local pipeline, fit explanation, resume/cover-note draft, export packet, and manual application.

**Later:** email ingestion, official job-feed APIs, company research, interview preparation, networking suggestions, form filling, and configurable approved submission automation. Never fabricate qualifications; every candidate claim still resolves to the canonical evidence profile.

### Month-One Personal Beta

Build the canonical profile and paste-job workflow in the first week. Apply to real roles throughout the month and keep a gold set of at least twenty job descriptions with corrected extraction, hard-filter decisions, and approved/blocked resume claims. Add browser capture only after the packet is reliable. The beta must preserve document versions, recover from backup, and make unsupported language impossible.

## Existing Products, Building Blocks, and Shortcuts

- Greenhouse’s [Job Board API](https://developers.greenhouse.io/job-board.html) and Lever’s [Postings API](https://github.com/lever/postings-api) expose jobs for individual employers; [USAJOBS](https://developer.usajobs.gov/api-reference/) offers a genuine read-only aggregate for US federal roles. They are useful connectors, not a universal job-search API.
- [Ashby’s public job postings API](https://developers.ashbyhq.com/docs/public-job-posting-api) is another strong target-company connector and can include compensation when the employer publishes it.
- [JSON Resume](https://jsonresume.org/schema) provides a canonical facts schema. Render tailored views with [Typst](https://typst.app/docs/), Pandoc, or controlled HTML/CSS and then extract the PDF text back as an ATS smoke test.
- Teal, Huntr, Simplify, and Jobscan are product references for tracking, tailoring, capture, and form assistance. The local differentiator is evidence IDs, redlines, privacy, and no mass application.
- A bookmarklet using selected text is the fastest capture tool; it avoids logged-in scraping. The smallest useful flow is URL/text → five requirements → supported/partial/missing evidence → reviewed packet → open official application page.
- [Schema.org JobPosting](https://schema.org/JobPosting) is a useful normalized record when company career pages expose structured data. Search adapters should store the exact query, capture timestamp, and raw posting hash.
- Treat ATS or HackerRank-style scores as test adapters, not universal truth. Build an internal deterministic lint report—parseability, section recognition, keyword evidence, chronology, links, and unsupported claims—and compare it against several external tools on a fixed resume/job set.

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

## Scheduled Discovery and Preparation Upgrade

The scheduled agent keeps a user-defined target universe: companies, company career/ATS identifiers, role families, levels, locations, remote policy, salary floor, excluded keywords, and source-specific query recipes. It polls Greenhouse, Lever, Ashby, official career pages/JSON-LD, saved alert emails, and explicitly configured searches. LinkedIn recency parameters and “we are hiring” post searches are useful personal discovery recipes, but every result is normalized into the same source-independent record.

Daily flow:

1. Poll target-company sources and broader saved searches.
2. Store immutable posting snapshot, first/last seen, exact query, source ID, and content hash.
3. Deduplicate reposts and detect changed descriptions.
4. Apply hard gates for company, level, location/remote, work authorization, and compensation.
5. Rank the remainder using verified career evidence, domain fit, recency, and an actual network/outreach path.
6. Generate a top queue plus “why not” explanations for near misses.
7. On approval, produce the application packet, likely recruiter/hiring-manager/team leads, a grounded outreach draft, and an interview-preparation dossier for [[Batman Prep Time Skill]].
8. Open/fill the official form with the reviewed packet; record screenshot/receipt and schedule follow-up according to the selected automation policy.

Treat “ATS 95” as an internal reproducible lint target, not a portable recruiter score. Report parseability, section recognition, truthful terminology coverage, chronology, link validity, text extraction, and unsupported claims. Compare this local rubric with Jobscan/HackerRank-style or ATS simulators on a fixed fixture set and keep only checks that predict real parsing or outcomes.

## Build Slices

1. Canonical profile and truthful evidence IDs.
2. Job capture and editable normalized schema.
3. Hard filters and fit explanation.
4. Resume bullet selection/redline and cover note.
5. Export packet and pipeline board.
6. Reminder/response analytics.
7. Permitted source connectors and guarded form assistance.
8. Target-company scheduler, recency-query library, and “we are hiring” discovery.
9. Contact graph, reviewed outreach drafts, and interview-preparation dossiers.
10. Configurable submission queue with screenshots/receipts for approved flows.

## Battle-Testing Gates

- Twenty corrected job fixtures rerun without regressions.
- Every generated claim resolves to a canonical evidence ID.
- Duplicate roles and changed descriptions are detected by URL/content hash.
- Exports remain readable by a plain-text parser.
- Backup/restore reproduces the application pipeline and document versions.
- A qualified role becomes a reviewed packet in under fifteen minutes.
- Daily search jobs can rerun idempotently, explain why each role was found, and detect reposts or changed descriptions.
- Search-to-screen and outreach-to-reply rates can be segmented by source, company, fit band, and tactic.

## Product Path

Keep it personal until source access and workflow quality are proven. A responsible product can sell private application organization and evidence-grounded tailoring; “one-click apply to thousands of jobs” is a poor product direction for candidates and employers.

## Related

- [[Personal Library Website]]
- [[Goal-to-Calendar Planner]]
- [[Jarvis and Alfred]]
- [[Personal Study Curriculum]]
- [[First Month Build Program]]
- [[Batman Prep Time Skill]]
- [[Project Ideas Index]]
