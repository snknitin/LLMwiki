---
type: research-note
status: active
created: 2026-08-25
scope: dunbar-dossier-and-personal-relationship-intelligence
tags:
  - research
  - personal-crm
  - relationship-intelligence
  - dunbar-number
  - social-memory
  - meeting-briefing
  - local-first
  - n8n
  - obsidian
  - sqlite
---

# Research - Dunbar Dossier and Personal Relationship Intelligence

This dossier examines the science, product precedents, source constraints, workflow architecture, storage model, and failure modes behind a private system for remembering the people who matter. The proposed product uses an intelligence-file visual language, but its operating category is **Personal Relationship Management (PRM)** or **Personal Relationship Intelligence**: it should help the owner remember shared history, keep promises, prepare for meetings, and invest attention deliberately. It should not reward collecting the maximum possible information about people.

The user's private Notion page `150 - Dunbar's Number` was inspected on 2026-08-25. Its current database contains 43 people and visibly includes a name field, a chat/cadence-like indicator, and relationship-category tags. The connected Notion API required reauthentication, so this research does not reproduce names or pretend that an automated migration has occurred. The build should accept a one-time Notion CSV/API import, preserve the complete raw row for reconciliation, and let the user confirm identity and ring placement before any record becomes canonical.

## 1. Dunbar Dossier

### Executive finding

The strongest product definition is:

> **A local-first personal relationship memory and briefing system for an intentionally bounded network.**

The useful unit is not merely a scraped biography. It is a versioned **Biographic Intelligence File** containing source-backed life chronology, public-media evidence, associations, analytical assessments, and the owner's private relationship memory: how the relationship began, shared activities, interaction history, important dates, open promises, conversation threads, and communication preferences. Before a meeting, the system turns the same file into a two-minute brief; after a meeting, it records what mattered and what the owner promised to do.

The product should automate four things—**memory, provenance, preparation, and reminders**—while leaving curiosity, judgment, emotional effort, and communication to the human. Automatic outbound messages are not part of the personal V0.

The best architecture is a hybrid:

1. one SQLite database on the always-on DGX Spark is the canonical operational store;
2. a small private API/MCP service is the only writer;
3. n8n schedules connectors and agent jobs but never becomes the database;
4. raw imports and source captures are immutable evidence outside Git and Obsidian;
5. generated Markdown files provide readable, linkable Obsidian dossiers and briefings;
6. authenticated social-browser capture, where needed, runs in a dedicated Windows profile rather than on Spark;
7. every machine-acquired change first becomes an observation or candidate fact with source, date, and confidence.

At 43–150 active people, PostgreSQL, a graph database, and a vector database add more operation than value. SQLite is sufficient if all writers call one host-local service rather than opening the file over a network share.

### Product terminology and the intelligence aesthetic

Use **Personal Relationship Intelligence** in the product description and **Personal Relationship Management** when comparing it with Monica, Dex, Clay, and Covve. The UI can use evocative names without encoding people as operational targets:

| UI term | Meaning |
|---|---|
| Dossier / Person File | the reviewed, current projection for one person |
| The 150 | the active attention roster and its Dunbar layers |
| Situation Report | the daily relationship digest |
| Briefing | a meeting-specific, time-bounded preparation artifact |
| Change Inbox | unreviewed machine observations and proposed changes |
| Field Note | a user-authored interaction or memory |
| Open Loop | a promise, follow-up, question, or possible act of support |

Keep internal objects humane and precise: `Person`, `Identity`, `Relationship`, `Interaction`, `ImportantDate`, `Commitment`, `ConversationThread`, `CommunicationPreference`, `SourceCapture`, `Observation`, `FactAssertion`, `MeetingBrief`, `Cadence`, and `DunbarLayer`. “Target Intelligence Package,” “asset,” and “watchlist” can inspire the graphic language, but should not be database vocabulary.

The visual treatment can use IBM Plex Mono or another legible monospaced face, manila-folder tabs, paper textures, typewritten headings, stamped states, redactions for deliberately hidden fields, and marginal source notes. The aesthetic becomes functional when every claim is visibly stamped `CONFIRMED`, `OBSERVED`, `INFERRED`, `STALE`, or `REVIEW NEEDED`.

### The professional artifact is a biographic intelligence package

A **Target Intelligence Package (TIP)** is a real military term, but it is usually the wrong label for this person file. Army special-operations doctrine describes a TIP as a mission-planning product about a target and its operational area, including geography, routes, threats, installations, and imagery ([Army FM 34-36](https://irp.fas.org/doddir/army/fm34-36/ch2.htm), [ADRP 3-05](https://irp.fas.org/doddir/army/adrp3_05.pdf)). It is not merely a detailed biography.

Person-centric precedents are closer:

- the CIA has used **Biographic Intelligence** and **Biographic Profile** as formal labels ([CIA Biographic Intelligence memorandum](https://www.cia.gov/readingroom/document/cia-rdp78-05597a000300080059-2), [The Biographic Profile](https://www.cia.gov/readingroom/document/cia-rdp80-01826r000800030025-8));
- declassified CIA work describes open-literature review, biographies, media profiles, reporting, and debriefings of people with significant personal contact when developing personality studies ([CIA personality-profile paper](https://www.cia.gov/readingroom/docs/1979-06-01b.pdf));
- Army guidance describes a **HUMINT Support Package** using pattern-of-life analysis, first- and second-order associations, familial relations, residence, travel, and employment history; a **Biometric Target Intelligence Package** is a shorter one- or two-page product for a single person of interest ([ATP 2-22.82](https://irp.fas.org/doddir/army/atp2-22-82.pdf)).

Use a precise hierarchy: **Dunbar Dossier** is the product; **Personal Biographic Intelligence and Relationship Memory System** is its technical descriptor; **Biographic Intelligence File** is the canonical accumulated record; **Biographic Intelligence Profile** is the current full synthesis; **Relationship Brief** is the meeting extract; and **Dossier Packet / Biographic Intelligence Briefing Packet (BIBP)** is the complete export. These are descriptive product terms rather than a claim that the application implements a government standard.

### Biographic Intelligence Briefing Packet structure

Each packet is a versioned `as_of` report, not one endlessly rewritten biography. Recommended sections:

1. **Cover and handling panel** — display/preferred name, aliases, stable person ID, representative photographs, packet date/version, active Dunbar layer, source freshness, and a private handling label.
2. **Executive summary and key judgments** — current role/base, why this person matters to the owner, most important recent changes, relationship posture, significant uncertainties, and three to five concise analytical judgments.
3. **Identity and distinguishing data** — verified handles, contact channels, languages, pronunciation, public identifiers, alternate spellings, and identity-resolution evidence.
4. **Biographical chronology** — date/place of birth if explicitly known, education, qualifications, career stints, promotions, projects, organizations, gaps, and duration calculations with uncertain boundaries shown as ranges.
5. **Residence, location, and travel chronology** — stated home/base, previous residences, relocations, trips, vacations, conferences, and frequently visited places. Keep `event_time`, `published_at`, and `observed_at` separate; a post date is not automatically a travel date.
6. **Interests and affinities** — hobbies, creative/technical interests, books/media, cuisine, causes, teams/sports, communities, recurring venues, and passions, separated into explicit self-description and behavior-derived affinity.
7. **Views, affiliations, and worldview** — direct quotations or paraphrased self-stated positions, recurring issue preferences, organizations/groups publicly affiliated with, changes over time, contrary evidence, and an explicit ban on converting one like/follow into a stable ideology label.
8. **Family and close relationships** — explicitly established family ties, partner/relationship context, children/pets where relevant, what relatives/partners do when sourced, important dates, and relationship validity intervals. A co-appearance alone remains a hypothesis.
9. **Association and social graph** — first- and second-order connections; family, friend, colleague, classmate, teammate, community, and online-interaction edges; strongest recent interaction clusters; co-appearance and co-location evidence; and which connections are user-confirmed.
10. **Digital footprint and media annex** — profile inventory, representative images, tagged/captioned co-appearances, posts/stories/captures, recurring content themes, and source coverage/health by platform.
11. **Communication and behavioral assessment** — preferred channels, formality, language/code-switching, response style, recurring expressed moods/themes, decision or negotiation style where evidence supports it, and hypotheses with alternatives. Do not present clinical diagnoses.
12. **Relationship history with the owner** — how/where they met, shared contexts, meetings, conversations, activities, gifts/help, important events, promises, unresolved threads, and last meaningful contact.
13. **Recent developments and pattern of life** — changes since the prior packet, routine locations/activities at an appropriate granularity, recurring public schedules, and notable deviations, always bounded by source availability and time window.
14. **Meeting briefing** — purpose, last contact, safe conversation threads, promises, possible support, topics to handle carefully, relevant people likely to be present, and questions/information gaps.
15. **Contradictions, gaps, and collection requirements** — conflicting dates/claims, low-confidence identity links, missing career periods, uncertain relationship labels, sources that would resolve a question, and indicators that would change an assessment.
16. **Source and analysis annex** — claim-to-source ledger, capture dates, source reliability, evidence quality, model/parser versions, key assumptions, alternative hypotheses, and analyst overrides.

The packet generator should offer a full dossier, a two-page executive packet, a meeting-specific brief, and a “changes since last version” comparison from the same canonical records.

Use `PERSONAL // PRIVATE // LOCAL-ONLY` as the handling banner. A stylistic `DD-201-0042` internal record number is acceptable if documentation says it is a Dunbar identifier. Do not use authentic government seals or real classification-control markings. The theatrical surface should look polished; the evidence labels underneath it must remain exact.

### Verified Notion seed snapshot

The connected `150 - Dunbar's Number` page contains an inline **Intentional Relationship Aid** database and a linked **Chats with people example** database. A live schema and aggregate query on 2026-08-25 found:

| Seed field | Coverage |
|---|---:|
| People | 43 |
| `LastContacted`, `Contact Freq`, `Location`, `Relationship` | 43 each |
| `Organization` | 34 |
| `Industry` | 31 |
| Linked chat relation | 9 people |
| Dated, person-linked chat records | 3 |

Cadence is already a real product concept: 17 bi-monthly, 16 monthly, four bi-weekly, three quarterly, two semesterly, and one weekly. Preserve the current `Relationship` and `Industry` multi-selects as imported vocabulary rather than mapping them destructively. Preserve the current “Contact Every?” and “Chat?” formulas as migration documentation, but recompute due state in the service from cadence and last-contact dates. The import report must account for every source page URL without exposing names in build logs.

### Analytic tradecraft for inferred opinions and psychological patterns

The requested analysis includes recurring mental/psychological states, ideology, opinions, affiliations, and relationship hypotheses. These are useful only if the document preserves the difference between evidence and judgment. Follow the core ideas in [ODNI Intelligence Community Directive 203](https://www.dni.gov/files/documents/ICD/ICD-203.pdf): distinguish underlying information from assumptions and judgments, explain uncertainty, identify causes of uncertainty, show indicators that would change a judgment, and consider plausible alternatives. The CIA's [Structured Analytic Techniques primer](https://www.cia.gov/resources/csi/static/Tradecraft-Primer-apr09.pdf) provides practical patterns such as key-assumption checks and analysis of competing hypotheses.

Every analytical assessment should contain:

```yaml
question: What is being assessed?
time_window: Which period does the judgment cover?
judgment: Concise answer in calibrated language
analytic_confidence: high | moderate | low
likelihood: optional, expressed separately from confidence
evidence_for: [observation_ids]
evidence_against: [observation_ids]
key_assumptions: []
alternative_hypotheses: []
information_gaps: []
indicators_that_would_change_judgment: []
generated_at:
expires_at:
analyst_status: machine_draft | user_reviewed | user_corrected
```

Use precise labels:

- **Stated position:** directly expressed by the person, with source/date/context.
- **Observed behavior:** posting, attending, joining, donating, wearing, traveling, or interacting, without an identity conclusion.
- **Behavior-derived affinity:** repeated multi-source pattern suggesting interest or alignment.
- **Analytical hypothesis:** a reasoned but uncertain interpretation with alternatives.
- **Clinical/diagnostic conclusion:** outside the product; replace with time-bounded descriptions such as “posts contained recurrent frustration language during this period.”

An ideology, partner, mental state, or family relationship should never become an unlabeled profile fact from a single post, like, photograph, follow, or model classification. The system may automatically refresh the analysis section, but the packet must keep its hypothesis label and source trail.

### What Dunbar research supports—and what it does not

Research commonly finds hierarchically inclusive social layers around 5, 15, 50, and 150, often described as the **support clique**, **sympathy group**, **affinity group**, and **active network**. The layers differ in emotional closeness, contact frequency, and time investment ([Hill and Dunbar, 2003](https://pubmed.ncbi.nlm.nih.gov/26189988/), [Zhou et al., 2005](https://pmc.ncbi.nlm.nih.gov/articles/PMC1634986/)). A later phylogenetic reanalysis found confidence intervals too wide to defend one universal number from primate brain size alone ([Lindenfors, Wartel, and Lind, 2021](https://royalsocietypublishing.org/doi/10.1098/rsbl.2021.0158)).

Therefore:

- use 150 as the owner's chosen **attention budget**, not a scientific commandment;
- permit fewer than 150 active people and an unlimited archived/acquaintance pool;
- keep ring assignment manual, with explainable suggestions only;
- never silently promote or demote a relationship based on message counts;
- separate family, friendship, professional, neighborhood, and community contexts;
- distinguish desired cadence from observed frequency.

Suggested relationship-review cadences are editable prompts rather than rules:

| Layer | Conventional label | Useful default review cadence |
|---|---|---|
| Inner 5 | Support clique | Weekly |
| Next 10 / 15 total | Sympathy group | Monthly |
| Next 35 / 50 total | Affinity group | Every six months |
| Next 100 / 150 total | Active network | Annually |

Do not convert these into a red “relationship-decay score.” Longitudinal research suggests friendship decline is associated with reduced communication and shared activity, while kin ties may be more resilient, but the samples and life transitions do not support a universal decay formula ([Roberts and Dunbar, 2011](https://ora.ox.ac.uk/objects/uuid%3A0a8fe8a0-ee1a-47de-b70f-06da958af4a5), [Roberts and Dunbar, 2015](https://link.springer.com/article/10.1007/s12110-015-9242-7)). Use neutral states: `on track`, `due soon`, `due`, `paused`, `seasonal`, `reconnect later`, `archived`, or `no cadence`.

### Relationship quality is not profile completeness

Large-scale communication research shows that people have limited communication time and distribute it unevenly across a small number of ties; larger networks tend to add weaker relationships rather than proportionally more time ([Miritello et al., 2013](https://doi.org/10.1016/j.socnet.2013.01.003)). Individuals also show persistent “social signatures”—characteristic allocations of attention across stronger and weaker ties—even when specific people change ([Saramäki et al., 2014](https://pmc.ncbi.nlm.nih.gov/articles/PMC3903242/)).

Hall's friendship-development studies associated closeness with time spent together, especially voluntary leisure and meaningful everyday talk. The reported 40–60, 80–100, and 200+ hour ranges are sample-derived estimates, not thresholds to gamify ([Hall, 2019](https://journals.sagepub.com/doi/10.1177/0265407518761225)). Friendship-maintenance research emphasizes positivity, supportiveness, openness, and interaction ([Oswald, Clark, and Kelly, 2004](https://doi.org/10.1521/jscp.23.3.413.35460)). Intimacy is closely associated with reciprocal disclosure and perceived responsiveness—feeling understood, accepted, validated, and cared for—rather than factual recall alone ([Laurenceau, Barrett, and Pietromonaco, 1998](https://pubmed.ncbi.nlm.nih.gov/9599440/)).

Product implication: the main pulse should foreground last meaningful interaction, last shared activity, open promises, an upcoming opportunity to spend time, and whether the user wants to maintain, deepen, pause, or archive the relationship. Number of posts scraped, trivia remembered, contact-card completeness, and messages generated are not success measures.

Follow-up questions can signal responsiveness, but counting questions is not equivalent to listening ([Huang et al., 2017](https://pubmed.ncbi.nlm.nih.gov/28447835/), [Kluger and Malloy, 2019](https://pubmed.ncbi.nlm.nih.gov/31714108/)). A briefing should therefore offer two or three conversational threads, not an interrogation script.

### Existing products and open-source precedents

| Product | What it proves | What Dunbar Dossier should add or avoid |
|---|---|---|
| [Monica](https://github.com/monicahq/monica) | Open-source PRM with contacts, relationships, reminders, birthdays, notes, activities, tasks, documents, and diary | Best information-architecture reference; add provenance, candidate-fact review, temporal assertions, agent access, and generated briefs |
| [Bonds](https://github.com/naiba/bonds) | Modern Monica-inspired Go/React PRM with reminders, full-text search, data-isolated vaults, CardDAV/CalDAV, API tokens, and an MCP endpoint | Strongest agent-access precedent; do not inherit more surface area than the personal V0 needs |
| [Dex](https://getdex.com/) | Commercial personal CRM joining LinkedIn, email, calendar, contacts, reminders, and keep-in-touch context | Closest ingestion/meeting-context benchmark; avoid making opaque enrichment the canonical truth |
| [Clay Reconnect](https://library.clay.earth/hc/en-us/articles/6817306147355-Reconnect) | Interaction-aware reconnect reminders that move when new contact is detected | Borrow cadence UX; avoid a mysterious relationship-strength score |
| [Covve](https://covve.com/personal-crm) | Post-call notes, follow-up reminders, contact news, and relationship analytics | Borrow low-friction note capture and pre-call context |
| [Twenty](https://github.com/twentyhq/twenty) | Self-hosted CRM objects, views, workflows, agents, and APIs | Too heavy and sales-oriented for 150 people; useful only as an operations reference |
| [EspoCRM](https://docs.espocrm.com/) | Mature calls, meetings, tasks, jobs, webhooks, APIs, and optimistic concurrency | Operational reference, not a suitable personal information architecture |

The differentiator is not “a CRM with a dark theme.” It is an intentionally bounded relationship roster, evidence-backed observations, preserved interaction history, review-before-write automation, Obsidian-readable projections, and meeting briefs designed to improve presence and follow-through rather than outbound volume.

### Why this should remain separate from nearby ideas

`pocket-crm` captures contacts, commercial opportunities, and next actions from shorthand. Dunbar Dossier owns the long-term personal relationship record and active 150. They can share stable person identifiers, reminders, and an API, but they have different daily jobs and success measures.

[[Event Networking Copilot]] can hand a reviewed new contact and event note into Dunbar Dossier after an encounter. [[Personal Voice Ghostwriter and DM Desk]] may read an approved communication-style card and open loops, but should not own person truth. [[GiftShelf]] may consume confirmed interests and dates to suggest a thoughtful gift. [[Dashboard Command Center]] can display the Dunbar web dashboard as a registered sheet without absorbing its data or jobs.

### Source feasibility and acquisition order

The product should use a tiered acquisition ladder:

1. user-entered facts, field notes, and meeting notes;
2. first-party exports and official read-only APIs;
3. notification email, calendar, and contact triggers;
4. public-profile snapshots through a replaceable provider such as ScrapeCreators;
5. a narrowly allowlisted authenticated Playwright capture worker for just-in-time gaps;
6. manual capture when none of the above is reliable.

| Source | Recommended path | Useful data | Operational reality |
|---|---|---|---|
| Current Notion roster | CSV export first; API after reconnection | Names, category/ring inputs, user-entered notes | Snapshot import; preserve every original row and reconcile visibly |
| Google Contacts | [People API](https://developers.google.com/people/v1/contacts) with read-only OAuth and sync tokens | Identity, email, phone, birthday, organization, photo | Maintain cursors; a missing field is not automatically a deletion |
| Google Calendar | [Incremental sync](https://developers.google.com/workspace/calendar/api/guides/sync) | Meetings, attendees, timing, notes | Ideal trigger for just-in-time attendee refresh and briefing |
| Microsoft contacts/calendar | [Contact delta](https://learn.microsoft.com/en-us/graph/api/contact-delta?view=graph-rest-1.0) and [event delta](https://learn.microsoft.com/en-us/graph/delta-query-events) | Equivalent Outlook data | Keep delta state per collection/range |
| LinkedIn seed | First-party [connection export](https://www.linkedin.com/help/linkedin/answer/a566336/export-connections-from-linkedin) and account archive | First-degree connection snapshot, public URLs, employer/title, connection date, messages where included | Better seed than attempting a general consumer API |
| LinkedIn refresh | Public profile provider; authenticated page only before a meeting | Public profile and recent visible changes | LinkedIn's open permissions do not expose arbitrary connection timelines, and most permissions require approval ([official access guide](https://learn.microsoft.com/en-us/linkedin/shared/authentication/getting-access)) |
| Instagram | Public-profile adapter where useful | Public biography, professional/public posts | Meta's official API cannot generally access consumer accounts; the Facebook Login variant cannot access consumer profiles ([Meta's official Postman collection](https://www.postman.com/meta/instagram/documentation/6yqw8pt/instagram-api)) |
| X | Official user timelines or a private X List | Stable post IDs, times, text, profile changes | X uses pay-per-use billing; cache and budget requests ([API overview](https://docs.x.com/x-api/overview), [usage and billing](https://docs.x.com/x-api/fundamentals/post-cap)) |
| WhatsApp | User-created per-chat export imported from a watch folder | Historical messages, attachments, user/contact language patterns | Treat as a snapshot; WhatsApp Business Cloud is not a reader for personal chat history ([official export help](https://faq.whatsapp.com/1180414079177245/)) |
| Notification email | Gmail/IMAP/Outlook | Job-change, birthday, event, and message triggers | Sparse but cheap; fetch a profile only after a relevant trigger |
| ScrapeCreators | HTTP adapter through n8n or the API service | Public Instagram, LinkedIn, X, and other profile/post endpoints | Useful one-provider shortcut, but public-only and upstream-dependent; keep replaceable ([API docs](https://docs.scrapecreators.com/)) |
| Apify | Fallback Actor | Unsupported public sources, structured dataset, schedules, webhooks | Actor quality and cost vary; never use its dataset as the dossier database ([schedules](https://docs.apify.com/actors/running/schedules), [datasets](https://docs.apify.com/storage/dataset)) |

The public-source adapter should normalize provider output and record whether the response was cached. ScrapeCreators' documentation currently exposes profile and post endpoints across Instagram, LinkedIn, and X, a REST API, n8n integration, and response caching. That is convenient, not durable platform access. Do not couple facts or UI fields to its response shape.

### Authenticated browser capture

Browser automation is a fallback, not the ingestion backbone. Use [Playwright authentication-state guidance](https://playwright.dev/docs/auth) and a separate persistent profile per platform. Do not attach automation to the everyday Chrome profile. Authentication state can impersonate the user and must never enter Git, Obsidian, prompts, n8n execution payloads, or the Spark.

Recommended boundary:

- first login is interactive and headful on Windows;
- n8n sends only `person_id`, allowlisted platform, canonical profile URL, and capture mode;
- the worker returns visible text, canonical URL, captured time, content hash, optional evidence screenshot, and health state;
- the worker stops on CAPTCHA, verification challenge, unexpected origin, or reauthentication;
- no likes, follows, comments, messages, or arbitrary browser instructions;
- one job per platform at a time, with low and jittered frequency;
- the API surface is `capture_profile(person_id, source)`, not general remote browser control.

Chrome's remote-debugging changes reinforce the use of a dedicated non-default data directory ([Chrome developers blog](https://developer.chrome.com/blog/remote-debugging-port)).

### Scheduling and n8n

n8n is a good visual orchestrator, but a poor source of truth. Use its [Schedule Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/) and HTTP Request node to enqueue work through the private Dunbar API. Keep credentials in n8n's encrypted credential store, mount only a dedicated import directory, prune large execution payloads, back up the instance encryption key separately, and run its [security audit](https://docs.n8n.io/hosting/securing/security-audit/) after adding community/custom nodes.

Do not create 150 cron jobs. Run one dispatcher every 10–15 minutes and select due `source_subscription` records by `next_due_at`, source health, freshness budget, and person layer. Apply jitter and per-platform concurrency limits.

Source-refresh cadence and relationship-review cadence are separate. An initial source budget might be:

- inner 5: public signals daily or every few days; deeper refresh before contact;
- next 10: every 2–3 days;
- next 35: weekly;
- remaining 100: every 2–4 weeks;
- anyone in an upcoming meeting: immediate just-in-time refresh;
- intentionally dormant person: contacts/calendar only.

This is a ceiling, not a target. Meeting-triggered deep refresh and notification-email triggers are likely more useful than continuously scanning all 150.

Recommended workflows:

1. contacts synchronizer;
2. calendar watcher and attendee matcher;
3. due-source dispatcher;
4. Windows capture-worker queue;
5. WhatsApp/export import watcher;
6. deterministic normalizer and snapshot diff;
7. candidate-fact extractor;
8. change-inbox review;
9. dossier/briefing renderer;
10. one concise daily relationship digest;
11. outbound draft queue with explicit approval and confirmed-send logging.

### Storage comparison

| Option | Correct role | Why it is not the canonical V0 store |
|---|---|---|
| Obsidian Markdown | Generated dossiers, briefings, manual reading, wikilinks, Bases views | Several agents can overwrite one another; weak constraints, temporal queries, dedupe, and provenance |
| SQLite | Canonical operational store | Chosen; keep it local to one service host and serialize mutations through an API |
| PostgreSQL | Later multi-service/multi-writer store | Excellent but unnecessary operations for 150 people when one Spark service can own writes |
| DuckDB | Read-only analytics/notebook experiments | Not intended as this multi-process transactional system ([concurrency](https://duckdb.org/docs/stable/connect/concurrency)) |
| JSON/YAML files | Configuration, fixtures, imports, exports | Whole-file rewrites and no cross-file transactions |
| Neo4j/graph database | Later multi-hop graph research | An SQL edge table is enough for this scale; adds a server, backup/auth surface, and query language |
| Full event sourcing | Large, carefully versioned domain systems | Replay/projection/versioning complexity is disproportionate |
| Vector database | Optional semantic retrieval cache | Names, dates, handles, identity, and current facts need deterministic relational queries |

SQLite provides transactions, foreign keys, JSON functions, and FTS5 in one portable file. WAL supports concurrent readers and one writer, but all direct clients must be on the same host ([WAL](https://www.sqlite.org/wal.html), [FTS5](https://www.sqlite.org/fts5.html), [JSON functions](https://www.sqlite.org/json1.html)). Because the service may use multiple connections, verify a current SQLite build containing the documented 2026 WAL-reset fix—3.51.3 or an officially patched 3.50.7/3.44.6 build—rather than assuming the operating-system package is adequate.

Obsidian stores notes as local Markdown with YAML properties, and Bases can create local database-like views from them ([storage](https://obsidian.md/help/Files%2Band%2Bfolders/How%2BObsidian%2Bstores%2Bdata), [Properties](https://obsidian.md/help/Editing%2Band%2Bformatting/Properties), [Bases](https://obsidian.md/help/bases)). This makes it an excellent presentation layer. Mark projections `generated: true`; accept edits through the dashboard/API or keep separately owned manual-note files so regeneration never destroys prose.

### Recommended deployment and folders

Live private data must stay outside both the Git repository and the synced vault:

```text
/home/snknitin/.local/share/dunbar-dossier/
├── dunbar.sqlite
├── blobs/sha256/<content-hash>
├── captures/YYYY/MM/<source>/<capture-id>.json
├── imports/
├── exports/jscontact/
├── exports/vcard/
└── backups/<timestamp>.sqlite.enc

/home/snknitin/.config/dunbar-dossier/
└── config.toml

<Obsidian vault>/Dunbar Dossier/
├── People/P-<stable-id>--display-name.md
├── Manual Notes/P-<stable-id>.md
├── Briefings/
├── Meetings/
└── Dunbar Dossier.base
```

The service and SQLite file live on the Spark's local filesystem. Never place a live WAL database in Obsidian Sync, Git, SMB, NVIDIA Sync, or another replicated folder. Windows, n8n, dashboards, and agents use the private Tailscale API; they do not open the file.

### Canonical data model

#### Roster and identity

`people` stores a stable ULID/UUID, display/preferred name, status, merge redirect, row version, and timestamps. `roster_memberships` stores active interval, `inner-5 | close-15 | active-50 | dunbar-150`, desired cadence, priority, and manual rank. Keeping membership separate means someone can leave the active 150 without losing history.

`external_identities` stores platform, normalized identifier, canonical URL, user-verification state, and last check, with `UNIQUE(platform, normalized_identifier)`. Aliases and transactional person merges preserve old IDs as redirects so historical observations remain resolvable.

#### Captures, observations, and facts

`source_captures` stores source URI/external ID, published/fetched time, hash, raw blob path, ingestion run, parser version, and uniqueness keys. `observations` stores the linked person/capture, typed text or JSON, dedupe key, review state, evidence quality, confidence, agent, and timestamp.

Keep four times distinct:

- `source_published_at`: when the source appeared;
- `observed_at` / `fetched_at`: when the system saw it;
- `valid_from` / `valid_to`: when a derived fact is believed to apply;
- `recorded_at`: when it entered the database.

`fact_assertions` is versioned and append-oriented. A new assertion supersedes or closes the old assertion; it never edits history in place. A `current_facts` view exposes accepted, non-superseded values. Every assertion is labelled as one of `user_recorded_fact`, `contact_shared_fact`, `public_observation`, `machine_inference`, or `unverified_candidate`.

A missing field in a new snapshot means “not observed,” not “false.” Social posts remain observations unless they make an explicit statement or the user confirms the interpretation. No LLM runs if the normalized snapshot hash is unchanged.

#### Interactions, meetings, and open loops

`interactions` records meeting/call/message/shared-activity/manual-note events with start/end, channel, title, summary, optional detail, source, creator, and version. `interaction_participants` permits a dinner or meeting to include several people without duplicating the event. `important_dates`, `conversation_threads`, `commitments`, and `followups` preserve source, status, recurrence, due time, and linked interaction.

#### Communication-style cards

Do not turn style analysis into timeless personality truth. `communication_profiles` should be channel-specific, versioned, expiring guidance with sample count, model/prompt version, confidence, and supporting evidence links. Appropriate features include preferred language, code-switching, formality, typical length, emoji tolerance, channel preference, and examples of the user's own messages that were received well. Do not diagnose motives from response delays or imitate the contact's private voice.

#### Operations and audit

Maintain `ingestion_runs`, `agent_runs`, `source_subscriptions`, `workflow_bindings`, `idempotency_keys`, `audit_events`, and `dossier_snapshots`. Every mutation records actor, reason, correlation/run ID, affected record, and before/after JSON or patch. Use integer row versions and `UPDATE ... WHERE id=? AND version=?`; a stale agent gets a conflict instead of overwriting a newer edit. n8n retries include stable idempotency keys.

#### Expanded biographic chronology, graph, and media model

Keep generic assertions, but add explicit operational tables so common packet questions are deterministic rather than buried in prose:

- `organizations`, `places`, `groups`, `topics`, `sports_teams`, and `external_people` represent packet entities with aliases and canonical source references;
- `life_episodes` represents employment, education, residence, relocation, trip, vacation, conference, project, membership, hobby, fandom, and public relationship episodes with start/end bounds, organization/place/entity links, role, temporal precision, and supporting assertions;
- `relationship_edges` represents partner, family, friend, colleague, classmate, teammate, community, follows, mentions, comments, messages, co-appearance, and co-location with valid interval, online/offline channel, direction, strength evidence, and review state;
- `media_items` stores source/capture, blob hash, canonical URL, OCR/caption, published/captured/observed times, geolocation claims, parser/model version, and retention class;
- `media_appearances` links known or unresolved people/entities to an item, records whether identity came from an explicit tag/caption, user confirmation, or model proposal, and never silently identifies an unknown face;
- `topic_signals` stores dated self-stated or behavior-derived interest/opinion evidence with polarity/context rather than a timeless ideology label;
- `analytic_assessments` stores the question, time window, judgment, confidence, evidence for/against, assumptions, alternatives, gaps, change indicators, expiry, and analyst status;
- `contradiction_sets` groups incompatible assertions while preserving each source;
- `analyst_overrides` locks a user correction, suppresses a bad source/link, splits/merges an identity, redacts a field from a packet, or adds an annotation. Overrides are separate from generated content and outrank future agent proposals;
- `packet_versions` stores `as_of`, packet type, generator/model versions, section hashes, source coverage, and linked snapshot so a change report is reproducible;
- `information_requirements` records missing questions, priority, possible source, and resolved state.

Career duration is calculated from episode boundaries; travel counts come from distinct reviewed trip episodes, not raw post counts; “most interacted with” is computed separately for comments/mentions/messages/co-appearances and for user-recorded in-person events. Do not collapse unlike evidence into one social-strength number.

#### Evidence spans, temporal precision, and identity resolution

Every domain row should inherit from an immutable `records` superclass that keeps record type, person, review state, semantic certainty, source reliability, information directness, extraction confidence, identity-match confidence, sensitivity, actor/run, creation time, and supersession pointer. Approximate time belongs in `temporal_extents` with earliest/latest start and end plus `day | month | year | approximate | unknown` precision. This preserves “sometime in 2022” without inventing `2022-01-01`.

`source_captures` hold the immutable page/post/chat/media object. `evidence_spans` point to exact text quotes/positions, JSON pointers, CSS/XPath selectors, audio/video timecodes, OCR spans, or image bounding boxes. `record_evidence` declares whether a span supports, refutes, or contextualizes a record and whether it is primary, corroborating, or derivative. This follows the concepts in [W3C PROV-O](https://www.w3.org/TR/prov-o/) and the [W3C Web Annotation Data Model](https://www.w3.org/TR/annotation-model/). Store a content hash plus prefix/suffix context so moved or edited sources can be detected and, where possible, re-anchored.

Use a shared `entities` registry for people, organizations, institutions, places, topics, communities, events, works, products, and teams, with aliases and namespace identifiers. Identity resolution starts from user-confirmed handles. Ambiguous cross-platform matches and person merges remain candidates. SQLite recursive CTEs can traverse the 150-person graph without Neo4j.

#### Retrieval scopes and reproducible packets

Do not give every agent the complete file. Enforce retrieval profiles in API/SQL code before data leaves the service:

| Profile | Permitted view |
|---|---|
| `ingestion_agent` | minimal verified identity context; append captures/evidence only |
| `curation_agent` | candidates, accepted records, provenance, contradictions; no credential secrets |
| `full_private_analyst` | complete private evidence and analysis for explicit owner-directed work |
| `meeting_brief` | accepted relevant/current facts, generalized location, visible uncertainty |
| `conversation_assist` | preferred name, safe interests, last interaction, confirmed milestones, approved rapport guidance |
| `message_drafter` | an even smaller allowlist; no raw chats, exact location, family speculation, or social-graph analysis |
| `dashboard_summary` | current high-level facts and freshness indicators |

Exact addresses, raw private correspondence, intimate details, and face embeddings must not enter a generally accessible vector index. If semantic search is added, embed already-redacted text or keep separate indexes per scope.

`packet_templates`, `packet_section_definitions`, `packet_runs`, `packet_section_outputs`, `packet_record_memberships`, and `packet_snapshots` record the template/query/prompt version, retrieval profile, `as_of` time, records/evidence used, rendered Markdown, and content hash. A packet is therefore reproducible and every paragraph can lead back to evidence instead of asking a model to improvise directly from raw media.

### Agent access and mutation protocol

The safest “agent editable” design does not give agents raw filesystem or SQL write access. Expose narrow operations:

```text
search_people(query)
get_person_brief(person_id, as_of)
append_observation(person_id, evidence, idempotency_key)
record_interaction(participants, occurred_at, note)
propose_fact(person_id, predicate, value, provenance)
accept_or_reject_fact(assertion_id)
get_people_due_for_contact(before)
merge_people(loser_id, survivor_id, expected_versions)
render_dossier(person_id)
```

Ingestion agents receive append-only capture/observation rights. Briefing agents receive read access to accepted facts plus meeting-relevant observations. Only the owner/curator can accept a candidate fact, merge identities, delete a person, expose a sensitive field, or confirm that a message was sent.

The write flow is:

```text
export/API/browser capture
        ↓
immutable source capture
        ↓
normalized observation candidate
        ↓
identity match and snapshot diff
        ↓
fact proposal with evidence
        ↓
owner review
        ↓
accepted temporal assertion
        ↓
deterministic dossier and briefing render
```

This is append-only evidence plus current projections, not full event sourcing. It preserves corrections and provenance without requiring replayable business events for every edit.

#### Automatic update tiers

The owner wants the main packet to update automatically. Use an explicit policy rather than making every update wait for manual data entry:

| Tier | What agents may do automatically | Packet treatment |
|---|---|---|
| 0 — captured evidence | save source item, metadata, explicit tags/captions, hashes, OCR/transcript, and deterministic counts | appears in source/media annex immediately |
| 1 — deterministic derived record | close/open a source cursor, normalize a verified handle, calculate duration, cluster posts into a proposed trip, update interaction aggregate | appears as an observed/derived record with source and parser version |
| 2 — corroborated biographic assertion | propose or refresh role, employer, education, base, interest, fandom, trip, or explicit affiliation supported by clear self-statement or multiple sources | may appear automatically in the packet as `CORROBORATED` according to owner policy; remains reversible and temporal |
| 3 — sensitive or interpretive assessment | partner/family relation, ideology, recurring emotional state, psychological pattern, inferred home, untagged-person identity, or strong social tie | may refresh automatically only inside the `ANALYTICAL HYPOTHESIS` section with confidence, alternatives, expiry, and evidence; canonical fact requires user confirmation |
| 4 — consequential action | merge/split identity, delete, reveal redacted field, alter a manual override, or send a message | explicit owner action required |

The dashboard should allow the owner to set the promotion policy per predicate. For example, an explicit LinkedIn employment change can be auto-promoted, while relationship status always remains review-only. Manual edits create an `analyst_override` and a new accepted assertion; regeneration never overwrites them.

#### Multimodal enrichment methods

- **Career and education:** extract dated role/organization/degree announcements, profile chronology, resume-like pages, and repeated work references; represent unknown months as intervals rather than invented dates.
- **Residence and base:** prioritize explicit bios and self-statements. Infer “frequently present in” separately from “based in.” Never treat one vacation cluster as residence.
- **Travel/vacation:** cluster geotags, explicit place names, captions, story highlights, and co-temporal media into a proposed trip episode. Record possible event-date range and publication lag. Count reviewed trip episodes and distinct places with a visible confidence threshold.
- **Hobbies, passions, teams, and fandom:** score repeated self-authored statements, participation, event attendance, purchases/merchandise, and diverse source types over time. Separate curiosity, casual engagement, and durable affinity.
- **Views and ideology:** build issue-specific stated-position timelines. Likes/follows can support a weak affinity hypothesis but cannot alone establish an ideology or group membership. Preserve reversals and changing views.
- **Family/partner context:** prioritize explicit relationship terms, tagged announcements, anniversary/wedding context, and user knowledge. Repeated co-appearance is supporting evidence, not legal/romantic status.
- **Social graph:** generate typed edges from explicit relation tags, mutual mentions/comments, message participation, co-appearance, co-location, and user-recorded meetings. Show online and in-person evidence separately and make the time window visible.
- **Psychological/behavioral patterns:** analyze time-bounded self-expression, topic shifts, language/affect signals, routines, and communication style. Generate multiple plausible explanations and describe behavior; do not diagnose.
- **Images and stories:** prefer explicit tags, captions, OCR, and user-confirmed identities. A vision model may propose people/places/activities, but unknown-face identity matching remains unresolved until confirmed.

The concrete media pipeline is: exact/perceptual dedupe; EXIF/XMP/IPTC metadata; FFmpeg scene-change keyframes and bounded samples; faster-whisper ASR; PaddleOCR/Tesseract; atomic structured VLM extraction; cross-modal reconciliation; candidate creation; contradiction/counterexample retrieval; then deterministic packet rendering. [IPTC Photo Metadata](https://www.iptc.org/std/photometadata/documentation/userguide/) explicitly distinguishes the location where media was created from the location shown—an important rule for travel inference. Treat raw posts, comments, captions, QR codes, and OCR as untrusted prompt-injection input; extractor calls receive schemas but no tools.

For locations, use a ladder: explicit location tag or first-person statement; OCR signage plus compatible place lookup; several agreeing visual cues; single landmark prediction; free-form VLM guess. The last two remain review-only. Detect “throwback,” “last summer,” and anniversary reposts before using publication time. Cache geocoding and respect the public [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/) or use a local gazetteer.

Face work begins with anonymous clusters. A user-labelled contact sheet can propagate a confirmed identity; co-appearance alone never establishes partner, family, or friendship. Use a multiplex graph rather than one friendship score, and keep celebrity/poster/television detections from contaminating the graph.

### Meeting brief design

A brief should fit on one screen and take under two minutes to review:

1. meeting/date/location and why the meeting exists;
2. one-sentence relationship context and last meaningful interaction;
3. changes since the last meeting, each linked to a source and date;
4. two or three open conversational threads;
5. promises the user made and follow-ups due;
6. a possible way to help, introduce, celebrate, or spend time;
7. important dates or topics to handle carefully;
8. source freshness and any ambiguity.

After the meeting, prompt for a 30–90 second voice/text field note: what mattered, what the person chose to share, promises made, next action, and whether another meeting is desired. Do not ask the user to grade how “impressive” they appeared. Ask whether the tool improved recall, listening, presence, support, and follow-through.

### WhatsApp import and communication guidance

Each exported one-to-one chat should be hashed, stored immutably, and parsed idempotently with locale-aware timestamps, multiline messages, system events, and attachment references. Separate raw chat, normalized messages, candidate memories, derived statistics, and the compact agent-facing style card. Group chats require stricter speaker attribution; a statement about a third person is not that person's fact.

Potential features:

- language/code-switching distribution;
- preferred forms of address and recurring shared expressions;
- typical message and paragraph length;
- emoji and voice-note patterns;
- directness, elaboration, humor markers, and formality;
- topics that previously led to engaged replies;
- channel and broad response-time preferences, without interpreting latency as personality;
- examples of the user's own messages that worked well.

AI-suggested replies can affect emotional language and perceived cooperation, but people may evaluate a partner less positively when they suspect algorithmic replies, and suggestions can homogenize communication ([Hohenstein et al., 2023](https://www.nature.com/articles/s41598-023-30938-9)). Generate drafts in the user's voice, show relevant evidence, and require edit/send approval.

### Backup, recovery, and deletion

Use host/volume encryption plus encrypted application backups; use [SQLCipher](https://www.zetetic.net/sqlcipher/) if database-level encryption is required. SQLCipher does not protect photos/raw captures, so those still need encrypted storage.

Create nightly consistent snapshots with SQLite's [Online Backup API](https://www.sqlite.org/backup.html) or [`VACUUM INTO`](https://www.sqlite.org/lang_vacuum.html#vacuuminto), not a blind copy of a live WAL database. Encrypt and hash the result, keep daily/weekly/monthly rotations, run `PRAGMA integrity_check`, and perform a monthly restore test. A “delete person” operation must remove or tombstone canonical rows, generated dossiers, derived summaries, cached embeddings, and eligible raw source material, then produce an auditable deletion report.

For contact interchange, [JSContact RFC 9553](https://datatracker.ietf.org/doc/html/rfc9553) is the best structured JSON projection, while [vCard 4.0](https://datatracker.ietf.org/doc/html/rfc6350) is the most interoperable contact export. vCard cannot represent dossier provenance, meetings, confidence, or temporal assertions. CardDAV may later sync a narrow contact projection; it should not become canonical.

### Principal failure modes

1. **Performative intimacy:** factual recall replaces curiosity, shared time, listening, or support.
2. **Identity collision:** a common name or changed handle attaches an update to the wrong person.
3. **Hallucinated biography:** a model upgrades an ambiguous observation into a confident fact.
4. **Highlight-reel distortion:** social media is treated as a reliable account of private life.
5. **Unexpected knowledge:** an obscure public post produces an intrusive conversational reference.
6. **Relationship gamification:** red scores and streaks turn friends into neglected sales leads.
7. **Automation accident:** a wrong-person, obsolete-date, bereavement, divorce, or other changed context reaches an outbound message.
8. **Authenticity loss:** generated slang or emotional messages stop sounding like the user.
9. **Sensitive inference:** weak evidence is used to infer health, sexuality, religion, politics, finances, relationship status, pregnancy, or mental state.
10. **One-sided closeness assumption:** frequency is mistaken for mutual closeness or a desire for contact.
11. **Source staleness:** a polished briefing hides that a connector has failed for months.
12. **Security blast radius:** a leak exposes the user's notes and information about up to 150 other people.
13. **Write races:** an agent or renderer silently overwrites a correction.
14. **Maintenance burden:** curating 150 profiles becomes another job and the app is abandoned.

Mitigations that directly improve the personal product include user-confirmed identities, allowlisted sources, a change inbox, source/freshness labels, sensitive-field retrieval rules, optimistic concurrency, draft-only messaging, daily-digest caps, meeting-triggered refresh, and one-click pause/archive/delete.

### Clever shortcuts and simpler alternatives

- Run Monica or Bonds for a week before building. Their gaps will reveal whether the novel value is evidence review, Dunbar layers, meeting briefings, or simply better capture habits.
- V0 can be a SQLite API plus generated Obsidian files and one Obsidian Base—no custom dashboard yet.
- Seed the 43-person Notion table by CSV and manually curate five inner-circle files before importing everyone.
- Prove value with contacts, calendar, meetings, and field notes before any live social connector.
- Trigger deep refresh from an upcoming meeting rather than polling all accounts daily.
- Use LinkedIn notification emails as job-change hints; fetch only after a relevant message.
- Use a private X List to consolidate public activity into fewer official API calls.
- Diff normalized snapshots before invoking a model.
- Store `freshness_budget` per source: a birthday does not need daily re-fetching.
- Use deterministic FTS5 and exact filters before embeddings; brute-force local cosine search is enough if semantic retrieval is later measured useful.
- Generate birthday/anniversary reminders and drafts several days early; never auto-send in V0.

### Battle-test and evaluation plan

Use five carefully curated people before scaling to 43 and then 150. For each build slice, use synthetic identities for automated tests and the user's real data only for private acceptance tests.

| Test | Pass condition |
|---|---|
| Notion migration | all 43 rows import or are explicitly quarantined; no silent merges; raw values remain recoverable |
| Identity resolution | same handle cannot attach to two people; ambiguous matches require review |
| Idempotency | rerunning the same import/capture produces no duplicate observation or reminder |
| Temporal correction | a superseded job/title remains historical and the current view is correct as of a chosen date |
| Concurrent edit | stale agent update receives a version conflict and does not overwrite user changes |
| Meeting brief | owner reviews it in under two minutes; every surfaced external claim shows source and date |
| Source failure | stale/failed connector is visible; brief does not present old data as current |
| Message workflow | no draft is sent without explicit approval; copied draft is not marked sent automatically |
| Backup/restore | a clean Spark instance restores database, blobs, and projections from an encrypted snapshot |
| Deletion | one person and all eligible derived material can be removed with an audit report |
| Human outcome | open promises are completed more reliably and briefings improve presence/recall without increasing generic outreach |

### Recommended V0 boundary

Build only:

- Notion CSV/API seed import and review;
- active 150 roster with manual rings;
- identities/aliases and transactional merge;
- interactions, meeting notes, important dates, commitments, and follow-ups;
- immutable captures, candidate observations, accepted/versioned facts, and audit history;
- exact search plus FTS5;
- private API/MCP for agents and n8n;
- generated Obsidian dossiers, daily digest, and meeting briefs;
- calendar-triggered briefing;
- WhatsApp export import for one conversation;
- encrypted consistent backups and restore test;
- at most one public-source adapter after the manual core proves useful.

Defer CardDAV, native mobile apps, a graph database, vector search, full automated browser monitoring, message sending, and multi-user product features until usage shows a concrete need.

### Scope-expansion reminder

The personal stack should not be redesigned around a hypothetical release. Before open-sourcing or offering this to other users, revisit platform terms, source rights, data minimization, notice/consent, deletion/export, authentication, access control, encryption/key recovery, retention, abuse prevention, auditability, accessibility, and jurisdiction-specific privacy obligations. These are a future product gate, not a reason to replace the recommended local-first stack now.

### Primary references

- [Hill and Dunbar: Social network size in humans](https://pubmed.ncbi.nlm.nih.gov/26189988/)
- [Zhou et al.: Discrete hierarchical organization of social group sizes](https://pmc.ncbi.nlm.nih.gov/articles/PMC1634986/)
- [Lindenfors et al.: Dunbar's number deconstructed](https://royalsocietypublishing.org/doi/10.1098/rsbl.2021.0158)
- [Miritello et al.: Time as a limited resource](https://doi.org/10.1016/j.socnet.2013.01.003)
- [Saramäki et al.: Persistence of social signatures](https://pmc.ncbi.nlm.nih.gov/articles/PMC3903242/)
- [Hall: How many hours does it take to make a friend?](https://journals.sagepub.com/doi/10.1177/0265407518761225)
- [Laurenceau et al.: Intimacy as an interpersonal process](https://pubmed.ncbi.nlm.nih.gov/9599440/)
- [Hohenstein et al.: AI-mediated communication](https://www.nature.com/articles/s41598-023-30938-9)
- [Monica personal relationship manager](https://github.com/monicahq/monica)
- [Bonds personal relationship manager](https://github.com/naiba/bonds)
- [SQLite WAL](https://www.sqlite.org/wal.html), [FTS5](https://www.sqlite.org/fts5.html), and [backup API](https://www.sqlite.org/backup.html)
- [Obsidian storage](https://obsidian.md/help/Files%2Band%2Bfolders/How%2BObsidian%2Bstores%2Bdata) and [Bases](https://obsidian.md/help/bases)
- [n8n Schedule Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/) and [security audit](https://docs.n8n.io/hosting/securing/security-audit/)
- [LinkedIn API access](https://learn.microsoft.com/en-us/linkedin/shared/authentication/getting-access)
- [Meta Instagram API](https://www.postman.com/meta/instagram/documentation/6yqw8pt/instagram-api)
- [X API usage and billing](https://docs.x.com/x-api/fundamentals/post-cap)
- [ScrapeCreators API](https://docs.scrapecreators.com/)
- [Playwright authentication](https://playwright.dev/docs/auth)
- [JSContact RFC 9553](https://datatracker.ietf.org/doc/html/rfc9553), [vCard RFC 6350](https://datatracker.ietf.org/doc/html/rfc6350), and [CardDAV RFC 6352](https://datatracker.ietf.org/doc/html/rfc6352)
- [ODNI ICD 203 analytic standards](https://www.dni.gov/files/documents/ICD/ICD-203.pdf) and [ICD 206 sourcing requirements](https://www.dni.gov/files/documents/ICD/ICD-206.pdf)
- [W3C PROV-O](https://www.w3.org/TR/prov-o/) and [Web Annotation Data Model](https://www.w3.org/TR/annotation-model/)
- [Schema.org Role](https://schema.org/Role) and [IPTC Photo Metadata](https://www.iptc.org/std/photometadata/documentation/userguide/)
- [OpenStreetMap Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/)

## Related

- [[Dunbar Dossier]]
- [[pocket-crm]]
- [[Event Networking Copilot]]
- [[Personal Voice Ghostwriter and DM Desk]]
- [[GiftShelf]]
- [[Dashboard Command Center]]
- [[Project Similarity and Reuse Map]]
- [[Project Ideas Index]]
- [[Scope Expansion Checklist]]
