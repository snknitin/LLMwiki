---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Dunbar Dossier and Personal Relationship Intelligence#1. Dunbar Dossier]]"
status: concept
difficulty: hard
priority: p1
category: personal relationship intelligence
form_factor:
  - private web dashboard
  - Obsidian dossier library
  - scheduled agent workflows
deployment: DGX Spark service with Windows capture worker over private Tailscale
source_ideas:
  - Dunbar 150 relationship roster and personal dossiers
  - scheduled Instagram, LinkedIn, and X updates
  - meeting history and pre-meeting briefings
  - WhatsApp export communication-style cards
  - birthday, anniversary, and keep-in-touch assistance
tags:
  - dunbar-number
  - personal-crm
  - relationship-intelligence
  - social-memory
  - meeting-briefing
  - local-first
  - n8n
  - obsidian
  - sqlite
  - agents
---

# Dunbar Dossier

> A local-first personal relationship memory and briefing system that helps one person remember shared history, keep promises, prepare for meetings, and invest attention across an intentional 5/15/50/150 network.

The product uses an elegant intelligence-file aesthetic, but its category is **Personal Relationship Intelligence** or **Personal Relationship Management (PRM)**. It is not a sales pipeline and its success is not measured by how much information is collected. The durable principle is: automate memory, provenance, preparation, and reminders; preserve curiosity, judgment, emotional effort, and communication for the human.

## Product Outcome

Dunbar Dossier turns a bounded list of people into detailed, source-aware **Biographic Intelligence Briefing Packets (BIBPs)**. Each packet combines identity and photographs; education and career chronology; residences, travel, and vacations; interests, passions, fandom, sports teams, views, and affiliations; partner/family context; first- and second-order associations; online and in-person interaction patterns; communication/behavioral analysis; the owner's shared history; and explicit uncertainties. Before a meeting, the same evidence produces a brief that can be read in under two minutes. Afterward, a short field note updates the history and follow-ups.

The home screen answers:

- Who am I meeting soon, and what should I remember?
- Which promises, introductions, celebrations, or follow-ups are due?
- Who have I intentionally chosen to stay in touch with but may have neglected?
- What changed in the lives or work of people I care about, and what is the source?
- Which machine-suggested updates still need my review?

Treat 150 as a chosen attention budget, not a scientific law. People may be archived without losing their history, and the active roster does not need to be full.

### Primary surfaces

1. **Today:** upcoming meetings, important dates, open promises, a deliberately small check-in queue, and new observations awaiting review.
2. **The 150:** concentric 5/15/50/150, list, and filtered views with manual ring placement and neutral cadence states.
3. **Person File / BIBP:** identity and images; biographical/career/location/travel timelines; interests, opinions, affiliations, family/partner context; typed social graph; digital footprint; analytical hypotheses; relationship history; contradictions, gaps, sources, and private manual notes.
4. **Meeting Brief:** last meaningful interaction, changes since then, two or three conversation threads, promises, possible support, sensitive/stale topics, and source freshness.
5. **Change Inbox:** proposed person matches and fact changes with evidence, date, confidence, and accept/edit/reject controls.
6. **Relationship Review:** time and attention allocation, intentionally paused ties, unresolved commitments, and relationships the user wants to deepen—without red decay scores or streak shame.

### Visual language

Use a readable monospaced/typewriter face, manila-folder tabs, paper texture, stamped states, evidence footnotes, source thumbnails, association maps, chronology strips, and optional redactions. The aesthetic must communicate epistemic state: `CONFIRMED`, `CORROBORATED`, `OBSERVED`, `ANALYTICAL HYPOTHESIS`, `CONTRADICTED`, `STALE`, and `REVIEW NEEDED`. Internally call people `Person`, not `target` or `asset`.

## Personal V0

Build a private vertical slice around the 43 people currently visible in the user's Notion `150 - Dunbar's Number` database, but deeply curate only five people first.

- Import the Notion table from CSV; use the API after the connection is reauthenticated.
- Preserve every raw row and show an import reconciliation screen rather than guessing field mappings.
- Create stable person IDs, aliases, verified handles, manual Dunbar rings, desired cadence, and archive state.
- For five people, generate the full BIBP skeleton: identity/photos, education/career episodes, residence/travel episodes, interests/fandom, views/affiliations, family/partner and association graph, recent signals, analytical hypotheses, relationship history, contradictions, gaps, and source annex.
- Manually enter how the relationship began, last meaningful interactions, shared interests/activities, important dates, open conversational threads, and promises; these analyst overrides outrank later agent guesses.
- Record a meeting involving multiple participants and generate a one-screen pre-meeting briefing.
- Generate deterministic Obsidian Markdown person files and a `Dunbar Dossier.base` view.
- Add one calendar adapter that triggers a briefing for matched attendees.
- Import one WhatsApp chat export, normalize it, and create an expiring communication-style card with evidence and sample count.
- Add a Change Inbox and one public-source adapter only after the manual/core workflow is useful.
- Produce one daily situation report with a strict notification cap.
- Create an encrypted consistent backup and complete a clean restore test.

The first proof is not “scrape three platforms.” It is: **does the meeting brief improve recall and follow-through, and does the interaction log remain easy enough to maintain?**

### Current Notion migration

The live page verified through the Notion connector on 2026-08-25 contains 43 people in **Intentional Relationship Aid**. All 43 have `LastContacted`, `Contact Freq`, `Location`, and at least one `Relationship` tag; 34 have `Organization`; 31 have `Industry`; nine link to the companion chat database. Cadence is 17 bi-monthly, 16 monthly, four bi-weekly, three quarterly, two semesterly, and one weekly. The linked **Chats with people example** database contains three dated, person-linked chat records. Do not copy personal names into this build spec or migration logs. The importer should:

1. import through the Notion connector/API when available, with CSV as a repeatable fallback, and store source page URL, export time, row identity, and raw JSON/CSV payload;
2. map obvious identity fields into a proposed person;
3. retain unknown columns in `import_payload` until mapped;
4. detect possible duplicates using confirmed email, phone, LinkedIn URL, and user-approved handles—not name alone;
5. let the user choose ring/category and confirm merges;
6. preserve the existing `Relationship` and `Industry` tags without destructive remapping, and preserve the “Contact Every?” and “Chat?” formulas as migration documentation rather than durable facts;
7. produce an import report: accepted, merged, skipped, and unresolved rows, accounting for every one of the 43 source pages.

## Build Boundary

**MVP:** private 150-person roster; identities/aliases/photos; biographical, education, career, residence, travel, interest, affiliation, relationship, and association records; interaction/meeting history; important dates; commitments and follow-ups; accepted/versioned facts; source captures and candidate observations; analytical hypotheses and contradictions; Change Inbox; exact/FTS search; calendar-triggered meeting briefs; generated Obsidian BIBPs; daily digest; private API/MCP; n8n scheduling; audited mutations; encrypted backups and restore.

**One connector after core validation:** choose LinkedIn export/public profile, X timeline/private List, or ScrapeCreators based on which five test people have the most useful public signal. A connector is optional to product value.

**Later:** additional contacts/calendars, more public-source adapters, Windows authenticated capture worker, CardDAV/vCard projection, richer relationship graph, voice-note transcription, and Dashboard Command Center registration.

**Out for V0:** direct SQL access by agents; live SQLite over a network share; a mobile app; a graph database; a vector database; full browser monitoring of 150 people; automatic ring changes; personality diagnosis; inferred sensitive traits; automated likes/follows/comments; automatic emotionally significant messages; multi-user accounts; public deployment.

The product can draft birthdays, anniversaries, check-ins, introductions, and follow-ups, but it must not mark a copied draft as sent or send it automatically. User-confirmed sends become interactions.

## Existing Products, Building Blocks, and Shortcuts

- [Monica](https://github.com/monicahq/monica) is the closest open-source PRM reference. It already models contacts, relationships, reminders, birthdays, notes, activities, tasks, and personal history. Borrow its humane information architecture before inventing a larger CRM.
- [Bonds](https://github.com/naiba/bonds) is a Monica-inspired Go/React PRM with full-text search, reminder delivery, CardDAV/CalDAV, personal access tokens, verification flags, and an MCP endpoint. Its agent boundary is especially relevant.
- [Dex](https://getdex.com/) demonstrates LinkedIn/email/calendar/contact aggregation, keep-in-touch reminders, and meeting context. Its strength is reducing manual data entry; its enrichment should not become unreviewed truth.
- [Clay Reconnect](https://library.clay.earth/hc/en-us/articles/6817306147355-Reconnect) shows how a reminder can move after a detected interaction. Reuse the interaction-aware cadence idea, not an opaque relationship score.
- [Covve](https://covve.com/personal-crm) is a useful reference for post-call capture, contact news, and pre-call context.
- [SQLite](https://www.sqlite.org/about.html), [FTS5](https://www.sqlite.org/fts5.html), and JSON functions provide the relational, temporal, full-text, and semi-structured core without a database server.
- [Obsidian](https://obsidian.md/help/Files%2Band%2Bfolders/How%2BObsidian%2Bstores%2Bdata) provides local Markdown projections; [Bases](https://obsidian.md/help/bases) can provide table/card views without making Markdown the transactional store.
- [n8n Schedule Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/) orchestrates scheduled work. Use HTTP calls to the Dunbar service and run n8n's [security audit](https://docs.n8n.io/hosting/securing/security-audit/) after adding integrations.
- [Google People](https://developers.google.com/people/v1/contacts), [Google Calendar incremental sync](https://developers.google.com/workspace/calendar/api/guides/sync), and Microsoft Graph contact/calendar delta APIs provide useful official inputs.
- A LinkedIn first-party [connections export](https://www.linkedin.com/help/linkedin/answer/a566336/export-connections-from-linkedin) is a better seed than assuming open API access to every connection. LinkedIn states that most permissions require approval and open consumer access is narrow ([official access guide](https://learn.microsoft.com/en-us/linkedin/shared/authentication/getting-access)).
- Meta's official Instagram collection documents that the Facebook Login API cannot access consumer accounts, so it is not a universal friend-monitoring interface ([official collection](https://www.postman.com/meta/instagram/documentation/6yqw8pt/instagram-api)).
- The [X API](https://docs.x.com/x-api/overview) exposes public posts and user timelines but currently uses pay-per-use billing; a private X List and aggressive caching can reduce reads ([billing](https://docs.x.com/x-api/fundamentals/post-cap)).
- [ScrapeCreators](https://docs.scrapecreators.com/) offers one public-data API across Instagram, LinkedIn, X, and other platforms plus n8n support and caching. Put it behind a replaceable adapter and retain raw responses.
- [Playwright](https://playwright.dev/docs/auth) can support a narrowly scoped Windows capture worker with a dedicated browser profile. Never upload browser authentication state to Spark or store it in the vault.
- [JSContact RFC 9553](https://datatracker.ietf.org/doc/html/rfc9553) is a strong JSON interchange export; [vCard 4.0](https://datatracker.ietf.org/doc/html/rfc6350) is the practical address-book projection. Neither replaces the evidence/fact model.
- Declassified CIA records use **Biographic Intelligence** and **Biographic Profile** for person-centric research ([CIA memorandum](https://www.cia.gov/readingroom/document/cia-rdp78-05597a000300080059-2), [Biographic Profile](https://www.cia.gov/readingroom/document/cia-rdp80-01826r000800030025-8)). Army guidance for a HUMINT support package explicitly includes associations, family, residence, travel, and employment history ([ATP 2-22.82](https://irp.fas.org/doddir/army/atp2-22-82.pdf)).
- A military [Target Intelligence Package](https://irp.fas.org/doddir/army/fm34-36/ch2.htm) is technically a mission package about a target and operational area, not simply a person biography. The project's person-centric export is therefore named **Biographic Intelligence Briefing Packet**.
- [ODNI ICD 203](https://www.dni.gov/files/documents/ICD/ICD-203.pdf) supplies the right analytical discipline for opinions, affiliations, and psychological/behavioral patterns: distinguish information, assumptions, and judgments; explain uncertainty; show alternatives; and state what would change the assessment.

**Fastest product test:** use Monica or Bonds for a week, then prototype only the missing Dunbar-ring, evidence-review, Obsidian-render, and meeting-brief features. A good alternative V0 is a SQLite service plus generated Markdown and an Obsidian Base—no custom dashboard until the workflow earns one.

## Recommended Free-First Stack

### Chosen V0

- **Always-on host:** FirstSpark, with private access over Tailscale.
- **API/MCP service:** Python 3.12+, FastAPI, Pydantic, SQLAlchemy 2, and Alembic. Expose explicit commands; do not expose arbitrary SQL.
- **Canonical data:** current SQLite 3.51.3+ on the Spark's local filesystem, WAL, foreign keys, `STRICT` tables where practical, busy timeout, FTS5, and JSON functions. Verify the actual runtime version and compile options.
- **Dashboard:** SvelteKit + TypeScript, served privately from Spark. Register its URL in [[Dashboard Command Center]] later if useful.
- **Workflow orchestration:** self-hosted n8n on Spark using one due-work dispatcher, HTTP Request nodes, idempotency keys, retries, and a visible failure queue.
- **Obsidian output:** deterministic atomic Markdown renderer plus an Obsidian Base. Generated person files are read-only projections; manual prose lives in separately owned notes or enters through the dashboard.
- **Models:** the existing local Spark model gateway for typed observation extraction, communication-style summaries, and brief drafts. Use schemas and evidence IDs; identity matching, dates, dedupe, and cadence remain deterministic.
- **Multimodal enrichment:** local OCR plus the existing Spark vision-capable model route for captions, places, activities, object/team cues, and proposed co-appearances. Explicit tags/captions and user confirmation outrank visual identity proposals.
- **Authenticated capture:** optional Python/Playwright worker on Windows with a separate persistent profile per platform and a narrow Tailscale endpoint.
- **Raw evidence:** content-addressed files under a private application-data directory outside Git and the Obsidian vault.
- **Backups:** SQLite Online Backup API or `VACUUM INTO`, encrypted and hashed snapshots, daily/weekly/monthly rotation, integrity check, and monthly restore test.
- **Testing:** pytest, Hypothesis for parser/idempotency properties, Playwright for dashboard flows, golden Markdown fixtures, and synthetic person/source data.

### Why SQLite rather than PostgreSQL first

The dataset is small, but the evidence history can be rich. SQLite still handles this comfortably. The important concurrency decision is not database brand; it is a single mutation service. n8n and agents call the service, so WAL's one-writer model is sufficient and easier to back up. Promote to PostgreSQL only when measured write contention, several independently deployed services, or high-availability requirements make the single-host service a real bottleneck.

Never access the SQLite file through Obsidian Sync, SMB, NVIDIA Sync, or another replicated/network filesystem. All direct database connections stay on Spark.

## Architecture and Data Model

### Trust and lifecycle architecture

```text
Notion/contacts/calendar/export/public source
                    ↓
             n8n or Windows worker
                    ↓
      immutable SourceCapture + run manifest
                    ↓
       deterministic normalization and diff
                    ↓
       Observation / proposed FactAssertion
                    ↓
               Change Inbox
                    ↓ owner accepts/edits/rejects
          accepted temporal assertion
                    ↓
        dossier / digest / meeting brief
                    ↓
          Obsidian and private dashboard
```

The canonical database and generated views have separate lifecycles. Pausing a source stops new captures but does not delete its evidence. Archiving a person removes them from the active 150 but preserves history. Regenerating Markdown never changes facts. n8n execution history is telemetry, not data.

### Storage locations

```text
/home/snknitin/.local/share/dunbar-dossier/
  dunbar.sqlite
  blobs/sha256/
  captures/YYYY/MM/<source>/
  imports/
  exports/jscontact/
  exports/vcard/
  backups/

/home/snknitin/.config/dunbar-dossier/config.toml

<Obsidian vault>/Dunbar Dossier/
  People/
  Manual Notes/
  Briefings/
  Meetings/
  Dunbar Dossier.base
```

No live data, credentials, chat archives, browser state, generated person file, or backup belongs in the Git repository.

### Core records

| Record | Important fields and invariants |
|---|---|
| `Person` | stable ULID/UUID, display/preferred name, status, merge redirect, row version |
| `RosterMembership` | active interval, manual Dunbar layer, desired cadence, priority; at most 150 active memberships |
| `ExternalIdentity` | platform, normalized identifier, canonical URL, verified flag; unique per platform/identifier |
| `SourceSubscription` | person/source, enabled state, freshness budget, next due, cursor, last success/error |
| `SourceCapture` | source URI/item ID, published/fetched times, content hash, raw blob, parser/run version |
| `Observation` | person, capture, type, text/JSON, dedupe key, review state, evidence quality, confidence |
| `FactAssertion` | predicate/value, valid interval, recorded time, evidence, review state, superseded assertion |
| `Record` / `TemporalExtent` | immutable superclass plus uncertain start/end bounds, precision, real-world validity, discovery time, sensitivity, and review state |
| `EvidenceSpan` / `RecordEvidence` | exact quote, text position, JSON pointer, timecode, image bounding box, content hash, and whether it supports, refutes, or contextualizes a record |
| `Interaction` | time, type, channel, title, summary/detail, source, creator, version |
| `InteractionParticipant` | many-to-many link between one interaction and its people |
| `ImportantDate` | date type/value, recurrence, evidence, review state |
| `ConversationThread` | topic/open question, source interaction, sensitivity, status |
| `Commitment` / `Followup` | owner, person, reason, due time, status, linked interaction |
| `CommunicationProfile` | person/channel, generated/expiry time, sample count, guidance JSON, model/prompt version, confidence |
| `AuditEvent` | actor, reason, correlation ID, record, before/after patch, timestamp |

Additional normalized records support a professional packet:

| Record | Purpose |
|---|---|
| `Entity` | organization, place, group, topic, sports team, public person, or other packet entity with aliases |
| `LifeEpisode` | employment, education, residence, relocation, trip/vacation, conference, project, membership, hobby, fandom, or public relationship with uncertain start/end bounds |
| `RelationshipEdge` | typed family/partner/friend/colleague/classmate/teammate/community/online/co-appearance/co-location edge with time window and evidence |
| `MediaItem` / `MediaAppearance` | images/stories/posts, OCR/caption, time/location claims, explicit tags, and confirmed or unresolved people/entities |
| `TopicSignal` | dated stated position or behavior-derived interest/opinion evidence with context and polarity |
| `AnalyticAssessment` | time-bounded judgment, confidence, evidence for/against, assumptions, alternatives, gaps, expiry, and review state |
| `ContradictionSet` | incompatible claims preserved together until resolved |
| `AnalystOverride` | durable user correction, lock, suppression, split/merge, redaction, or annotation that regeneration cannot overwrite |
| `PacketVersion` | reproducible `as_of` packet type, section hashes, source coverage, generator versions, and snapshot |
| `InformationRequirement` | prioritized missing question and the evidence that could resolve it |
| `RetrievalProfile` / `RetrievalGrant` | API-enforced record, field, sensitivity, location-precision, quote-length, and freshness limits for each agent purpose |
| `PacketTemplate` / `PacketRun` / `PacketSectionOutput` | reproducible template/query/prompt versions, records and evidence used, rendered sections, content hashes, and final snapshot |

Keep `source_published_at`, `fetched_at`, `valid_from`/`valid_to`, and `recorded_at` separate. Facts are never overwritten: insert a new assertion and supersede or close the old one. A current-facts view returns accepted, non-superseded assertions as of a date.

Do not use one vague confidence score. Store **source reliability**, **information directness**, **identity-match confidence**, **extraction confidence**, **semantic certainty**, **review state**, and **sensitivity** separately. Represent “during 2022” or “around June” as earliest/latest temporal bounds with `year`, `month`, or `approximate` precision; never fabricate the first day of a month. The evidence-span model borrows from [W3C PROV-O](https://www.w3.org/TR/prov-o/) and the [Web Annotation Data Model](https://www.w3.org/TR/annotation-model/) so each rendered sentence can reveal the exact supporting fragment.

Use normalized episode tables for career, education, residence, travel, affiliation, expressed opinion, interest/fandom, family/partner relationships, social-edge signals, media assets, appearances, and co-appearance events. A multiplex graph keeps meetings, messages, mentions, comments, likes, tags, explicit relationships, and co-appearances as different edge types. SQLite recursive CTEs are sufficient at this scale; a graph database is not required.

### Provenance classes

Every claim is explicitly one of:

- `user_recorded_fact`
- `contact_shared_fact`
- `public_observation`
- `machine_inference`
- `unverified_candidate`

User corrections outrank model output. A new scrape missing a field does not delete an old fact. Ambiguous social announcements stay observations. Sensitive fields can be marked excluded from general agent retrieval and meeting brief generation.

### Agent mutation API

```text
search_people(query)
get_person_brief(person_id, as_of)
get_person_profile(person_id, retrieval_profile, as_of)
get_claim_evidence(record_id)
append_observation(person_id, evidence, idempotency_key)
record_interaction(participants, occurred_at, note)
propose_fact(person_id, predicate, value, provenance)
accept_or_reject_fact(assertion_id)
add_analyst_override(target_id, action, reason, expected_version)
get_people_due_for_contact(before)
merge_people(loser_id, survivor_id, expected_versions)
render_dossier(person_id, template_version, as_of)
```

Ingestion agents may append captures and observations. Curation agents may see candidates, provenance, and contradiction cases. Briefing agents may read meeting-relevant accepted facts and source-backed recent observations. Message drafters receive a smaller allowlist: preferred name, last interaction, safe interests, confirmed milestones, and approved communication guidance. Raw chats, exact addresses/locations, face embeddings, intimate details, and sensitive hypotheses never enter a general vector index. Only the owner/curator may accept sensitive facts, merge people, delete data, change retrieval grants, expose restricted fields, or confirm a send. Enforce these scopes in SQL/API code before retrieval; a prompt is not access control. Use row versions and conditional updates; stale clients receive a conflict. Use idempotency keys for all n8n/import retries.

### Deduplication

Prefer, in order:

1. source plus stable source-item ID;
2. canonical source URL;
3. source + person + published time + normalized content hash;
4. for WhatsApp: timestamp + speaker + normalized text hash + attachment name.

Poll with a small overlap window, persist per-source cursors/watermarks, and hash normalized snapshots before model work. Identical snapshots generate no observation and no LLM call.

### Meeting brief contract

A one-screen brief contains meeting context, last meaningful interaction, relevant changes since then, two or three conversation threads, promises/follow-ups, possible support or shared activity, important/sensitive topics, and a freshness/source footer. It never converts uncertain social content into a speaking point without a warning.

After the meeting, a 30–90 second field note records what mattered, what the person chose to share, promises, next action, and whether another meeting is desired. One group meeting creates one interaction with several participants.

### Communication-style card

Parse exported chats into raw archives, normalized messages, derived features, candidate memories, and a compact versioned style card. Track language/code-switching, preferred formality, typical message length, emoji/voice-note tolerance, preferred channel, and examples of the user's own successful messages. Include sample count, expiry, model/prompt version, evidence IDs, and confidence. Do not infer personality or motives from delayed replies and do not imitate the contact's voice.

### Automatic enrichment and analyst control

Agents automatically refresh source captures, media metadata, explicit tags/captions, normalized timelines, source diffs, interaction aggregates, packet versions, and analytical drafts. Clear self-stated/corroborated facts may auto-promote according to a per-predicate owner policy. Partner/family relationships, ideology, recurring emotional/psychological patterns, inferred residence, untagged-person identity, and other sensitive interpretations may update automatically only in the visibly labelled **Analytical Hypotheses** section until confirmed.

Manual edits do not fight the renderer. They create `AnalystOverride` records and accepted assertions with source `owner_correction`. Overrides can lock a field, suppress a source, split/merge an identity, redact a section, or add an annotation. Future agent runs may present contrary evidence, but cannot erase or silently replace the override.

| Tier | Automatic behavior | Packet status |
|---|---|---|
| 0 — evidence | save permitted source item, media hash, metadata, OCR/ASR, exact evidence fragments, anonymous face clusters, and interaction counts | source/media annex |
| 1 — deterministic fact | verified handle, user-authored meeting note, calendar attendance, explicit structured role/location field, duration calculation, source freshness | `VERIFIED` or `SELF-STATED`, with source/date |
| 2 — candidate | possible trip, probable job transition, recurring hobby, public milestone, frequently appearing person, communication feature | `OBSERVED`/`CANDIDATE`; may update automatically without becoming a confirmed fact |
| 3 — analysis | image-derived location, partner/family meaning, ideology/group interpretation, closeness, face identity, psychological/behavioral pattern, contradiction resolution | `ANALYTICAL HYPOTHESIS`; requires curator acceptance for factual promotion |
| 4 — prohibited inference | clinical diagnosis, moral/risk score, private address, intimate status or conflict inferred from absence/co-appearance | never generated as a dossier claim |

The practical rule is: **agents observe broadly, infer cautiously, and promote narrowly**. Manual review is concentrated on sensitive meaning and identity, not on routine raw capture or deterministic processing.

### Biographic enrichment rules

- Calculate employment and education duration from temporal episodes and show unknown boundaries as ranges.
- Distinguish `based in`, `previously lived in`, `frequently present in`, and `visited`; never infer home from one trip.
- Cluster explicit place names/geotags/captions into proposed trips, preserving event-date uncertainty and publication lag. Count reviewed trip episodes and distinct places, not posts.
- Separate explicit self-described interests/teams/groups from behavior-derived affinity. Repeated, diverse, recent evidence can raise confidence; one like/follow cannot.
- Store issue-specific stated-position timelines rather than one permanent ideology label. Preserve reversals and contrary evidence.
- Infer partner/family context from explicit terms and user knowledge first. Co-appearance is supporting evidence, not relationship status.
- Build typed online and offline association graphs. Show comments, mentions, messages, co-appearances, co-location, and user-recorded meetings as separate evidence channels and visible time windows.
- Describe recurring affective language or behavior in a period and offer alternative explanations; do not create clinical diagnoses.
- Prefer explicit tags, captions, and user-confirmed identity in images. A vision model may propose an unresolved co-appearance, never silently name an unknown face.

### Multimodal extraction pipeline

1. **Capture:** save structured profile fields, posts, captions, tags, mentions, visible comments, stories/highlights when available, exported chats, calendar items, and meeting notes as immutable source items.
2. **Deduplicate and preprocess:** SHA-256 and perceptual hashes; EXIF/XMP/IPTC extraction; FFmpeg scene-change keyframes and bounded video sampling; audio extraction; local ASR; OCR; thumbnails. Record story expiry and preserve observation time.
3. **Atomic extraction:** separate tool-free structured extractors for organizations/roles, dates, places, activities, teams/brands, stated positions, family terms, interaction types, OCR signage, and image regions. Treat all captured content as untrusted prompt-injection input.
4. **Cross-modal reconciliation:** combine caption, location tag, OCR, calendar, and visual cues without flattening them. Preserve the IPTC distinction between the location where media was created and the location shown in it ([IPTC Photo Metadata](https://www.iptc.org/std/photometadata/documentation/userguide/)).
5. **Candidate generation:** emit a typed record with temporal precision, basis, sensitivity, supporting/refuting evidence IDs, source-independence group, and review tier.
6. **Counterexample and contradiction pass:** search for incompatible dates, alternative explanations, reposted copies, throwbacks, concurrent roles/homes, and stale evidence before rendering.
7. **Packet render:** the renderer reads approved records and visible hypotheses—not raw media—and writes claim-level citations and an `as_of` snapshot.

Suggested local components are FFmpeg, ExifTool, PaddleOCR or Tesseract, faster-whisper, the existing Spark VLM route, and optional SigLIP/OpenCLIP embeddings for visual retrieval. Face embeddings, if tested, stay in a restricted encrypted index; begin with anonymous recurring-face contact sheets and require user labelling before propagation.

## Biographic Intelligence Briefing Packet Contract

The professional naming hierarchy is:

- **Biographic Intelligence File:** the canonical accumulated evidence, facts, observations, interactions, and analysis for one person;
- **Biographic Intelligence Profile:** the current full analytic synthesis rendered from that file;
- **Relationship Brief:** the meeting-specific extract;
- **Dossier Packet / BIBP:** the complete export containing profile, brief, chronology, graph, media index, source register, and audit appendices.

Use an explicitly personal handling banner such as `PERSONAL // PRIVATE // LOCAL-ONLY`, not authentic government seals or real `SECRET`/`TOP SECRET` markings. An internal stylistic record number may use `DD-201-0042` while documentation makes clear it is a Dunbar Dossier identifier.

Every full packet is versioned and rendered `as_of` a date. It contains:

1. cover/record control and representative media;
2. executive relationship brief;
3. key judgments, confidence, alternatives, and information gaps;
4. identity resolution, aliases, accounts, and mistaken-identity exclusions;
5. current-status snapshot;
6. master biographic chronology;
7. education and intellectual development;
8. career chronology, projects, achievements, and professional network;
9. residence, relocation, travel, vacation, conference, and frequently visited-place chronology;
10. hobbies, passions, books/media, cuisine, sports teams, fandom, causes, communities, and recurring venues;
11. dated stated positions, affiliations, worldview themes, changing views, and contrary evidence;
12. partner, family, children/pets where relevant, and close-relationship context with validity intervals;
13. first/second-order platform and real-world association graph with observation windows and blind spots;
14. digital footprint, representative posts/images/stories, co-appearances, and source-health coverage;
15. communication and rapport profile;
16. behavioral observations, recurring expressed mood/theme, decision/negotiation style, counterexamples, and alternative explanations;
17. relationship history with the owner, meetings, shared activities, gifts/help, promises, and open threads;
18. public-activity/change log and time-bounded pattern-of-life summary;
19. discrepancy and contradiction register;
20. meeting/engagement preparation;
21. sources, provenance, confidence, analysis assumptions, and analyst locks;
22. collection gaps, refresh plan, revision history, rejected agent proposals, and superseded assessments.

The same canonical records produce four views: **full profile**, **two-page executive packet**, **meeting brief**, and **changes since prior packet**. Every analytical judgment states the question, time window, confidence, evidence for/against, assumptions, alternative hypotheses, information gaps, change indicators, expiry, and whether it is machine-drafted or user-reviewed.

Evidence labels are deliberately obvious: `[FACT]`, `[STATED]`, `[OBSERVED]`, `[USER NOTE]`, `[JUDGMENT]`, `[ALTERNATIVE]`, `[CONFLICT]`, `[UNKNOWN]`, and `[LOCKED]`. Keep source reliability, analytic confidence, and likelihood of a future event as separate concepts.

## Build Slices

1. **Schema and service foundation**
   - Create migrations, constraints, current-facts views, row versions, idempotency, audit events, health endpoint, and synthetic fixtures.
   - Configure SQLite safely on the Spark and prove consistent backup/restore before real imports.

2. **Notion seed and identity review**
   - Import the 43-row CSV, preserve raw rows, propose mappings, and build the duplicate/merge review.
   - Confirm five people, their verified identities, ring, cadence, and source allowlist.

3. **Person file and Obsidian projection**
   - CRUD through the API, exact search/FTS5, deterministic atomic Markdown render, manual-note separation, and Obsidian Base.
   - Add golden-file tests so renderer changes cannot silently drop fields or provenance.

4. **Interaction memory and open loops**
   - Meetings/calls/messages/shared activities, multiple participants, important dates, threads, commitments, and follow-ups.
   - Add quick text/voice field-note capture.

5. **Calendar-triggered meeting brief**
   - Incremental calendar sync, attendee identity matching, just-in-time refresh queue, one-screen brief, and post-meeting prompt.
   - Run brief-quality acceptance tests across at least ten meetings.

6. **Change Inbox and evidence ledger**
   - Immutable source capture, deterministic normalization/diff, candidate observations/facts, accept/edit/reject, and source freshness UI.
   - Prove wrong-person correction and temporal fact supersession.

7. **Full profile renderer and analyst overrides**
   - Career/education/location/travel episodes, entity graph, media annex, stated-position timeline, analytical assessments, contradictions, packet versions, and the twenty-two-section full profile.
   - Add full/two-page/meeting/change-report modes and prove that a manual correction survives regeneration.

8. **Cadence and daily situation report**
   - Neutral due states, pause/seasonal/archive controls, promise/date reminders, digest cap, and no relationship score.
   - Track notification dismissal and tune until the digest remains useful.

9. **WhatsApp export experiment**
   - One-to-one parser, locale/multiline/system-message fixtures, idempotent import, communication-style card, evidence, expiry, and draft-only reply assistance.

10. **One public-source adapter**
   - Choose the highest-value source, store raw responses, apply freshness budgets and jitter, surface health, and keep provider replacement possible.
   - Add the Windows Playwright worker only if exports/public APIs fail a measured need.

11. **Multimodal social graph and travel experiment**
    - Extract explicit tags/captions/place mentions and model-proposed activities/co-appearances from a bounded media set.
    - Validate travel-episode precision, relationship-edge false positives, story retention, and unknown-identity review before enabling automatic packet updates.

12. **Operational hardening**
    - Security audit, least-privilege tokens, encrypted rotations, monthly restore, deletion test, connector-failure drills, telemetry, and documentation.

### Battle-test matrix

| Scenario | Required evidence |
|---|---|
| Re-import same Notion/WhatsApp data | zero duplicate people, observations, interactions, or reminders |
| Similar names/changed handle | no automatic merge; review shows evidence and consequences |
| Two agents update one person | stale write conflicts; neither user correction nor accepted fact is lost |
| Job/title changes twice | historical facts remain queryable; current view is correct as of date |
| Source fails for 30 days | dashboard and brief show staleness; old data is not labelled recent |
| Meeting with three people | one interaction links all participants; each timeline receives it once |
| Ambiguous social post, meme, quote, or repost | remains an observation; endorsement is not invented |
| Throwback vacation posted today | event date remains approximate; post date is not converted to travel date |
| Two simultaneous roles or homes | both can coexist; contradiction logic does not force a false single answer |
| Same post mirrored across platforms | one independence group; not counted as corroboration twice |
| Recurring unlabelled face | anonymous cluster only until the user confirms identity |
| Behavioral pattern | counterexamples and at least one alternative explanation are surfaced |
| Birthday draft | no send without approval; copy does not equal confirmed send |
| Spark recovery | encrypted backup restores DB, blobs, search, and generated files |
| Delete one person | canonical, generated, derived, cached, and eligible raw data are accounted for |

## Drawbacks, Concerns, and Failure Modes

- **The tool can create performative intimacy.** Remembering facts must not replace curiosity, listening, shared time, or support. Evaluate whether briefs improve presence and follow-through, not whether someone was impressed.
- **Detailed analysis can look more certain than the evidence.** Every ideology, relationship, mental-state, and social-graph judgment needs a time window, confidence, source trail, counterevidence or alternatives, and expiry.
- **Identity collisions are damaging.** Never match on name alone. Require user verification for handles and ambiguous imports.
- **Social profiles are highlight reels.** Treat posts as dated observations, not reliable private-state facts.
- **Models polish uncertainty away.** Store observation and assertion separately; require evidence IDs and review before canonical facts.
- **An obscure fact can feel intrusive.** Flag facts whose source/context would plausibly surprise the person and omit them from ordinary conversation prompts.
- **Travel and residence are easy to confuse.** A publication time may lag the actual trip; a geotag may be decorative; repeated visits do not prove residence.
- **Photographs do not establish relationships.** Co-appearance and visual similarity are weak evidence unless captions/tags or the user establish identity and context.
- **Cadence can become guilt and gamification.** Use neutral states, intentional pause/archive, no streaks, and no universal decay score.
- **Generated slang can sound false.** Style cards guide drafts in the user's voice; they do not impersonate the contact and expire.
- **Personal social APIs are constrained.** Instagram does not provide a general friend feed, LinkedIn consumer access is narrow, X is pay-per-use, private profiles need fragile sessions, and exports are snapshots. Keep manual/core workflows valuable.
- **Browser sessions are high-value secrets.** Dedicated Windows profiles, no password transfer, allowlisted origins, and halt on reauthentication/CAPTCHA.
- **The system can become maintenance work.** Curate five people first, cap daily reviews, refresh before meetings, and archive freely.
- **A leak has a large blast radius.** Keep data outside Git/vault, restrict API tokens, encrypt storage/backups, minimize raw-retention, and test deletion.
- **SQLite can be misused.** Do not place it on a shared/synced filesystem or give every agent a connection. One local service owns mutations.
- **n8n retries can duplicate work.** Transport retries require application idempotency and source dedupe.
- **A polished brief can hide stale sources.** Every generated artifact includes connector health, observed date, and freshness.
- **Automatic celebration can be painfully wrong.** Bereavement, separation, changed dates, and wrong identities make human review essential.

## Clever Hacks and Simpler Alternative

- Deploy Monica or Bonds for one week and record exactly which workflows remain painful. Reuse its vocabulary rather than recreating ordinary contact management blindly.
- Start with five hand-curated people and ten meeting notes. Scaling a bad schema to 150 only hides the missing habit loop.
- Build the canonical service and Obsidian Base before a custom dashboard. This may be enough for months.
- Use upcoming calendar meetings to trigger deep refresh; do not poll every person daily.
- Parse LinkedIn notification emails as cheap job-change hints and fetch only after a relevant trigger.
- Maintain a private X List instead of reading 150 timelines independently.
- Hash/diff snapshots before running a model; most jobs should end after “no change.”
- Keep a per-source freshness budget and temporarily increase it around meetings or explicit life events.
- Use FTS5 and exact filters before embeddings. At 150 people, semantic search can remain a rebuildable cache.
- Create a three-button field note: `what changed`, `what I promised`, `next contact`. Richer notes are optional.
- For birthdays, generate a reminder and possible gesture several days early. A call, activity, voice note, or useful offer is usually better than a generic generated wish.
- Render a printable one-page “mission brief” PDF only after the Markdown brief is consistently useful; presentation should follow information quality.

## Success Measures

- All 43 current Notion rows are imported, explicitly merged, skipped, or quarantined; nothing silently disappears.
- At least 95% of surfaced external factual claims show a source and observation date.
- Every analytical judgment shows its time window, confidence, evidence for/against, assumptions or alternatives, expiry, and review state.
- Zero sensitive, ambiguous, or policy-disallowed machine inferences enter the canonical current dossier as confirmed facts; permitted deterministic first-party fields follow explicit per-predicate policy.
- Zero outbound messages are sent without explicit user approval.
- Person/handle matching errors are caught before dossier mutation.
- A meeting brief is useful and reviewable in under two minutes.
- Meaningful interaction notes can be recorded in under 90 seconds and usually within 24 hours.
- Open promises are surfaced and completed more reliably.
- The daily report stays below its configured cap and is not routinely dismissed.
- Source failures and stale data are visible in the dashboard and generated artifacts.
- Concurrent agent edits never overwrite user corrections.
- A user-locked correction survives every packet regeneration; contrary evidence is attached rather than silently replacing it.
- Career and travel counts are reproducible from reviewed temporal episodes, with uncertain boundaries visible.
- Partner/family/ideology/psychological hypotheses never appear as unlabeled confirmed facts.
- Every rendered substantive claim can reveal its record ID, exact evidence fragment or user note, source date, observation date, and current review state.
- Every packet version is reproducible from its template version, retrieval profile, `as_of` time, included record IDs, evidence IDs, and model/parser versions.
- Re-running any import or workflow is idempotent.
- Monthly restore tests recover database, blobs, and dossiers from encrypted backups.
- One person can be deleted completely, with a report covering canonical, derived, cached, and eligible raw data.
- The user's monthly assessment says the system improved listening, support, recall, shared activity, or follow-through—not merely message volume.

## Product Path

1. **Private memory core:** five curated people, interactions, open loops, Obsidian dossiers, and one meeting brief.
2. **The 43:** reconciled Notion import, calendar triggers, Change Inbox, cadence review, and reliable backup.
3. **The 150:** tiered source schedules, one or two proven adapters, WhatsApp style cards, daily situation report, and Dashboard Command Center sheet.
4. **Local relationship OS:** stable MCP/API shared with Event Networking Copilot, Pocket CRM, GiftShelf, and the DM Desk while Dunbar Dossier remains the authority for relationship history.
5. **Possible product:** configurable personal PRM with local/self-hosted and paid hosted modes only after the personal workflow has been dogfooded and recovery/security are proven.

Before open-sourcing or serving other users, run [[Scope Expansion Checklist]] and revisit platform terms, source rights, data minimization, notice/consent, authentication, access control, deletion/export, retention, encryption/key recovery, abuse prevention, accessibility, and jurisdiction-specific requirements. Keep this as a future gate; do not change the personal SQLite/Spark/Obsidian stack solely for hypothetical release concerns.

## Related

- [[Research - Dunbar Dossier and Personal Relationship Intelligence#1. Dunbar Dossier]]
- [[pocket-crm]]
- [[Event Networking Copilot]]
- [[Personal Voice Ghostwriter and DM Desk]]
- [[GiftShelf]]
- [[Dashboard Command Center]]
- [[Personal Signal Intelligence OS]]
- [[Project Similarity and Reuse Map]]
- [[Project Ideas Index]]
- [[Scope Expansion Checklist]]
