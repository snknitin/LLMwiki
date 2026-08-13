---
type: research-dossier
source: hermes-hackathon
status: active
scope_expansion: "[[Scope Expansion Checklist]]"
---
# Research - Hermes Batch B

This dossier evaluates the 31 assigned Hermes ideas as local, single-user prototypes. The recurring recommendation is to prove the transformation with imported files, reviewable drafts, and a small SQLite-backed workflow before adding live messaging, marketplace data, or public publishing. Links below are first-party documentation, standards, or source repositories.

## 1. Daily Parent Check-In

A useful V0 is a scheduled prompt, a short recorded or typed reply, and an evening digest for the adult child—not an autonomous welfare or medical monitor. [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api) can eventually carry the conversation, but its business setup and [message templates](https://developers.facebook.com/docs/whatsapp/business-management-api/message-templates) make Telegram or a local simulated inbox faster for validation. [Whisper](https://github.com/openai/whisper) provides local multilingual transcription and [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) is an optional voice layer. Store consent, preferred times, summaries, and explicit “needs attention” rules; escalate no-response to the child without claiming an emergency.

## 2. Deal Desk Agency

The smallest valuable system converts notes plus a price book into a reviewable scope, quote, risk memo, negotiation responses, and handoff checklist. [Stripe Quotes](https://docs.stripe.com/api/quotes) shows a clean quote-to-invoice lifecycle; [HubSpot’s quote object](https://developers.hubspot.com/docs/api-reference/legacy/crm/objects/quotes/guide) demonstrates associations between deals, line items, templates, and quotes; [PandaDoc document details](https://developers.pandadoc.com/reference/document-details) exposes recipients, pricing tables, totals, status, and approvals. V0 should generate Markdown/PDF and a Gmail draft, keep pricing deterministic, and flag assumptions rather than letting the model invent commercial terms.

## 3. Dies at User 50

The credible version is an authorized synthetic-user and load-test harness, not an unrestricted “attack any URL” tool. [k6](https://grafana.com/docs/k6/latest/) supplies virtual users and scenarios, while [thresholds](https://grafana.com/docs/k6/latest/using-k6/thresholds/) turn latency and error budgets into pass/fail results. [Playwright](https://playwright.dev/docs/intro) adds browser journeys and [Locust](https://docs.locust.io/en/stable/) is a Python-native alternative. Require localhost or a verified allowlist, ramp concurrency gradually, cap traffic, and include an immediate kill switch. The “death certificate” is a report generated from measured failure evidence, not a vanity score.

## 4. Event Ops Agency

Event operations are mostly structured coordination: venue readiness, speakers, run-of-show, attendee messages, sponsors, and recap. [pretalx](https://docs.pretalx.org/) already covers submissions, speakers, scheduling, and an API; its [schedule model](https://docs.pretalx.org/user/schedule/) includes room and speaker availability plus release versions, and its [outbox](https://docs.pretalx.org/user/emails/) keeps most organizer messages reviewable before sending. V0 should import a CSV and a one-page event brief, produce linked checklists and draft communications, and expose owners, deadlines, and blockers. Avoid recreating ticketing or calendar software.

## 5. Flex Card Forge

Public-profile data can become a shareable card if every statistic is traceable and rarity is defined against an explicit cohort. Use [GitHub’s REST API](https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api), [Strava’s API](https://developers.strava.com/docs/reference/), and the [Chess.com Published Data API](https://www.chess.com/news/view/published-data-api) as optional adapters; respect GitHub’s [rate limits](https://docs.github.com/en/rest/rate-limit/rate-limit) and OAuth where required. [Satori](https://github.com/vercel/satori) can render deterministic SVG cards. Cache normalized metrics, show source/as-of labels, and say “insufficient cohort data” instead of fabricating a percentile.

## 6. Instant Date Me Page

The prototype should interview its owner, create a one-page profile, and let a visitor ask an AI wingman questions only from approved facts. [Astro](https://docs.astro.build/) keeps the page static-first, [Ollama](https://github.com/ollama/ollama) supports local inference, and [MediaRecorder](https://www.w3.org/TR/mediastream-recording/) enables an optional browser voice interview. A source-card editor and “I don’t know” response are more important than voice polish. The page must avoid inferring intimate traits, exposing private data, or impersonating the owner.

## 7. Instant Quote Machine

Photo-based instant pricing is unreliable unless anchored to a business-owned price book. The correct V0 asks five scoping questions, accepts photos, applies deterministic minimums and modifiers, and returns a range with assumptions plus a callback request. [Stripe Quotes](https://docs.stripe.com/api/quotes) can later formalize accepted estimates, [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) keep outbound messages reviewable, and [rembg](https://github.com/danielgatis/rembg) can isolate photographed objects when useful. The lead is valuable even when confidence is too low to quote.

## 8. Internet Twin Quiz

A defensible twin is a quiz generated from user-selected, public source cards—not a scrape of someone’s entire identity. [GitHub REST](https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api) provides repositories and activity, the [Spotify profile flow](https://developer.spotify.com/documentation/web-api/howtos/web-app-profile) requires permission, and [Strava’s API](https://developers.strava.com/docs/reference/) is another opt-in source. Normalize claims with provenance, let the owner edit or remove every question, and include uncertainty. The fastest V0 accepts pasted facts or exported JSON before building OAuth adapters.

## 9. Invoice Chaser Agent

The useful loop is invoice import → due-state calculation → tone-controlled draft → logged follow-up → promised-payment tracking. [Stripe Invoices](https://docs.stripe.com/api/invoices) provides a reference lifecycle, [Gmail’s send/draft guide](https://developers.google.com/workspace/gmail/api/guides/sending) supports draft-first outreach, and [WhatsApp message templates](https://developers.facebook.com/docs/whatsapp/business-management-api/message-templates) describe the later messaging path. V0 should never send automatically, should stop on dispute or payment, and should surface aging and cash-at-risk rather than merely generate prose.

## 10. Knowledge Base Agency

This is a repeatable ingestion and evaluation service: parse supplied documents, create structured chunks, answer with citations, and package a maintainable bot. [Docling](https://github.com/docling-project/docling) handles PDFs, layouts, OCR, and tables; [Qdrant](https://github.com/qdrant/qdrant) supports hybrid and multivector retrieval when SQLite FTS is insufficient; [Whisper](https://github.com/openai/whisper) transcribes supplied recordings. Start with local files and a citation test set. A useful acceptance gate is whether the system abstains when no source supports an answer.

## 11. Landing Page Conversion Agency

An evidence-led audit combines deterministic checks, copy heuristics, and a preview—not invented conversion uplift. [Lighthouse](https://developer.chrome.com/docs/lighthouse/overview) measures performance, accessibility, and SEO; [axe-core](https://github.com/dequelabs/axe-core) adds accessibility rules; [Playwright](https://playwright.dev/docs/intro) captures page states and validates the generated preview. V0 should accept a user-owned URL or HTML export, retain screenshots and audit evidence, propose one prioritized test plan, and distinguish observations from hypotheses.

## 12. LinkedIn Lead List plus First Lines

LinkedIn explicitly prohibits many forms of [automated activity](https://www.linkedin.com/help/linkedin/answer/a1340567/automated-activity-on-linkedin), so a local product should not scrape or automate LinkedIn. Instead, accept a user-provided CSV, research first-party company sites, extract [Schema.org Organization](https://schema.org/Organization) metadata, and create claim-cited first-line drafts. [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) can stage outreach without auto-sending. Quality comes from ICP fit, freshness, and evidence—not list size.

## 13. Meeting Notes to Invoice

The core transformation is notes → billable candidates → human-approved time/quantity → invoice draft → follow-up draft. [Google Meet’s API](https://developers.google.com/workspace/meet/api/guides/overview) can later expose recordings and transcripts; its [artifact guide](https://developers.google.com/workspace/meet/api/guides/artifacts) notes transcript-entry retention limits, so V0 should accept pasted or exported notes. [Stripe Invoices](https://docs.stripe.com/api/invoices) models draft/finalize/send states. Never infer hours or rates without explicit project rules.

## 14. Mock Interview Gauntlet

Build a 20-minute state machine that uses a job description and resume to choose competencies, ask follow-ups, record answers, and produce replay-linked feedback. [O*NET Web Services](https://services.onetcenter.org/) can ground occupation skills, [MediaRecorder](https://www.w3.org/TR/mediastream-recording/) records in-browser audio, and [Whisper](https://github.com/openai/whisper) transcribes locally. Score against visible rubrics and evidence from the answer; do not pretend to predict hiring outcomes. Text-first mode is a simpler baseline for evaluating the adaptive logic.

## 15. Murder Mystery Game Master

This is best treated as a deterministic game engine with generated flavor. [Telegram’s Bot API](https://core.telegram.org/bots/api) supports group messages and private role delivery, [Discord interactions](https://docs.discord.com/developers/platform/interactions) provide commands, buttons, and modals, and [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) can voice fictional suspects. The database must own roles, clues, timers, votes, and reveal conditions; the model may narrate but cannot rewrite state. V0 can run in one local browser with private player screens.

## 16. My Agent Posts About Me

The promising version is a private observation journal with optional, reviewed publishing. [ActivityWatch](https://github.com/ActivityWatch/activitywatch) is a local source for explicitly enabled activity summaries, [Mastodon’s statuses API](https://docs.joinmastodon.org/methods/statuses/) supports visibility and scheduling, and [Bluesky’s post guide](https://docs.bsky.app/docs/tutorials/creating-a-post) documents another publishing target. Create drafts from a narrow allowlist, show the supporting observations, suppress sensitive categories, and require approval. “Daily” should be a maximum cadence, not a pressure to post.

## 17. Overnight Newsroom

Reliable newsroom automation begins with an allowlisted feed desk, snapshotting, deduplication, claim/source matrices, and human approval. [Atom RFC 4287](https://datatracker.ietf.org/doc/html/rfc4287) defines a standard feed format, [GDELT DOC 2.0](https://blog.gdeltproject.org/gdelt-doc-2-0-api-debuts/) is a first-party discovery API, and [Telegram’s Bot API](https://core.telegram.org/bots/api) provides a publishing channel. [FFmpeg](https://www.ffmpeg.org/documentation.html) can assemble audio/video after the text bulletin passes review. The system should abstain on single-source or contradictory claims and preserve snapshots for every sentence.

## 18. Paid Ad Account Audit

Start with exported CSVs because account OAuth and platform-specific schemas obscure the actual product question. [Google Ads reporting](https://developers.google.com/google-ads/api/docs/reporting/overview) uses GAQL and Search/SearchStream for metrics, while [Meta Insights](https://developers.facebook.com/docs/marketing-api/insights) is the corresponding first-party reporting surface. [DuckDB](https://duckdb.org/docs/stable/) is ideal for local columnar analysis. Separate deterministic waste flags and metric definitions from creative hypotheses; never claim causation from descriptive account data.

## 19. Petty Court

The safe and useful concept is playful, consent-based mediation—not legal adjudication. A structured interview engine such as [docassemble](https://docassemble.org/docs.html) can collect each party’s claims and evidence, [MediaRecorder](https://www.w3.org/TR/mediastream-recording/) can capture voluntary spoken statements, and [FFmpeg](https://www.ffmpeg.org/documentation.html) can produce a private shareable verdict clip. Require both parties to opt in, keep default visibility private, label the ruling entertainment, and avoid public “precedent” or accusations about real people.

## 20. Pitch Deck Brutality Score

The product should convert a deck into slide evidence, score it against a transparent rubric, and generate an investor-style memo with citations to slide numbers. [PyMuPDF](https://github.com/pymupdf/PyMuPDF) extracts PDF text and images, [LibreOffice headless conversion](https://help.libreoffice.org/latest/en-US/text/shared/guide/start_parameters.html) normalizes PPTX to PDF, and [PptxGenJS](https://github.com/gitbrent/PptxGenJS) can create a shareable scorecard deck. “Brutal” is a tone option; unsupported market or traction claims must be called missing evidence, not fact-checked by guesswork.

## 21. Portfolio Duel

Use the duel as a structured peer review across explicit categories: clarity, evidence, shipped work, code health, accessibility, and next challenge. [GitHub REST](https://docs.github.com/en/rest/using-the-rest-api/getting-started-with-the-rest-api) supplies repository metadata, [Lighthouse](https://developer.chrome.com/docs/lighthouse/overview) audits portfolio pages, and [Playwright](https://playwright.dev/docs/intro) captures evidence. Show raw measures and rubric weights, allow ties and missing-data states, and make the generated challenge more useful than the winner badge.

## 22. Price My Room

Vision can inventory a room, but valuation must remain a user-correctable range based on traceable comparables. [SAM 2](https://github.com/facebookresearch/sam2) assists object segmentation, [rembg](https://github.com/danielgatis/rembg) creates cleaner item crops, and the [eBay Browse API](https://developer.ebay.com/api-docs/buy/api-browse.html) can search listings where approved access exists. Its [Buy API requirements](https://developer.ebay.com/api-docs/buy/buy-requirements.html) make pasted comparable links or exports the dependable V0. Live asking prices are not sold prices; show region, condition, date, and uncertainty.

## 23. Product Shot Studio

The quickest valuable pipeline is crop → background removal → color/edge cleanup → template placement → optional generative scene → seller approval. [rembg](https://github.com/danielgatis/rembg) covers local background removal, [SAM 2](https://github.com/facebookresearch/sam2) supports promptable segmentation, and [ComfyUI](https://github.com/comfy-org/comfyui) provides a local node-graph workflow for generated scenes. Check marketplace-specific guidance such as [Google Merchant image rules](https://support.google.com/merchants/answer/6324350). Preserve the real product geometry and keep the main listing image separate from promotional creatives.

## 24. Rabbit Hole Speedrun

The game loop is a source-backed graph walk: start topic, choose a surprising edge, reveal a fact and citation, then continue toward a depth goal. [MediaWiki REST](https://www.mediawiki.org/wiki/API_REST_API/en) retrieves pages and search results, [Wikidata query help](https://www.wikidata.org/wiki/Help:Queries) supplies structured relationships, and [OpenAlex](https://docs.openalex.org/) expands into scholarly works. Save the exact path and sources so a run is replayable. Constrain the model to select and explain retrieved edges rather than invent connective trivia.

## 25. Red Tape Navigator

This should be a versioned checklist compiler over official Indian portals, not an auto-submission agent. [Passport Seva’s application guide](https://www.passportindia.gov.in/psp/Apply), its [fee calculator](https://www.passportindia.gov.in/psp/FeeCalculator), [Parivahan](https://parivahan.gov.in/), [Protean PAN services](https://www.protean-tinpan.com/services/pan/pan-index.html), and [data.gov.in](https://data.gov.in/about) are starting sources. Store page snapshots, retrieval dates, jurisdiction, and “verify on official portal” links. Never cache a fee or document rule without an as-of date, and do not collect more identity data than needed to form a checklist.

## 26. Renewal Guard

Email and receipt ingestion is more broadly useful than direct store subscription APIs, which generally expose transactions for the developer’s own apps. [Gmail’s scopes](https://developers.google.com/workspace/gmail/api/auth/scopes) explain the permissions trade-off, [Tesseract](https://github.com/tesseract-ocr/tesseract) handles local receipt OCR, while [Apple’s App Store Server API](https://developer.apple.com/documentation/appstoreserverapi) and [Google Play subscriptionsv2](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2) clarify the limited app-developer path. V0 should parse forwarded receipts into reviewable renewal/warranty records and reminders, with confidence and original-document links.

## 27. Scam Radar

Scam assessment must expose evidence and unknowns rather than pronounce a gig “safe.” [Google Safe Browsing](https://developers.google.com/safe-browsing) checks URL threat lists for non-commercial prototypes, [VirusTotal’s official Python client](https://virustotal.github.io/vt-py/) can inspect URL or hash intelligence, and [RDAP’s standard](https://datatracker.ietf.org/doc/html/rfc9082) supplies domain-registration data via the [IANA bootstrap](https://www.iana.org/assignments/rdap-dns/rdap-dns.xhtml). Never upload private contracts by default. For Indian users, link the official [National Cyber Crime Reporting Portal](https://www.cybercrime.gov.in/) and preserve evidence timestamps.

## 28. Shaadi RSVP Desk

The underlying product is a household-aware RSVP state machine, not a chatbot. [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api) and its [message templates](https://developers.facebook.com/docs/whatsapp/business-management-api/message-templates) are the eventual delivery layer; [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) or a simulated inbox is faster for V0. Model households, invite limits, plus-ones, meal choices, language, reply history, opt-out, and human takeover. Deduplication and correction screens matter more than natural-language flourish.

## 29. Shopify Product Page Optimizer

The optimizer should extract a supplied product page, identify missing evidence and structure, and generate editable title, bullets, FAQ, trust blocks, image briefs, and SEO fields. [Shopify’s Product object](https://shopify.dev/docs/api/admin-graphql/latest/objects/Product) and [products query](https://shopify.dev/docs/api/admin-graphql/latest/queries/products) define the native data surface; [Google Merchant’s product data specification](https://support.google.com/merchants/answer/14779112) and [image rules](https://support.google.com/merchants/answer/6324350) are useful compliance references. Begin with a pasted URL/HTML or CSV export, and never invent reviews, certifications, scarcity, or product claims.

## 30. Situationship: The Trailer

The entertaining prototype imports a user-provided conversation, redacts names, identifies a few narrative beats, and renders a 40-second private trailer for review. [Whisper](https://github.com/openai/whisper) can transcribe optional voice notes, [Remotion](https://github.com/remotion-dev/remotion) renders deterministic React compositions, and [FFmpeg](https://www.ffmpeg.org/documentation.html) handles media assembly. Keep processing local by default, avoid cloning real voices, require the uploader to select quotes, and do not expose or contact the other person.

## 31. Sponsorship Sales Agency

A strong local agency system turns event inventory and an ideal sponsor profile into a researched account list, evidence-backed pitches, deliverable bundles, pricing options, and draft follow-ups. [HubSpot CRM](https://developers.hubspot.com/docs/api-reference/latest/crm/understanding-the-crm) models companies, contacts, deals, and activities; [PandaDoc](https://developers.pandadoc.com/reference/document-details) can later package proposals; [Gmail drafts](https://developers.google.com/workspace/gmail/api/guides/sending) keeps outreach under review. V0 should use first-party company pages, enforce sponsor-capacity limits, and measure qualified replies rather than mass-send volume.

## Cross-cutting conclusions

- A shared local foundation—TypeScript or Python, SQLite, filesystem object storage, an Ollama-compatible model endpoint, and explicit review queues—covers most V0s.
- Imported CSV/JSON/PDF/HTML is usually the fastest truthful prototype. Live APIs belong in later adapters after the workflow proves useful.
- Generated content must retain provenance: source URL/file, retrieval time, extracted evidence, transformation version, and human decision.
- Messaging and publishing ideas should default to drafts; sensitive or high-impact ideas need consent, redaction, correction, and deletion controls.
- Any public, multi-user, monetized, or externally integrated version should pass [[Scope Expansion Checklist]] without retroactively bloating the local-first stack.
