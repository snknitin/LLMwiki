---
type: research-dossier
source: hermes-hackathon
date: 2026-07-27
scope: 17 easy and 14 medium prototype ideas
status: complete
tags:
  - research
  - prototype-specs
  - hermes
---

# Research - Hermes Batch A

This dossier supports the local-first prototype specs in `easy/` and the selected `medium/` batch. Research favored official documentation, standards, and source repositories. Recommendations assume one owner, local data, manual approval before external actions, and the fastest useful prototype. Commercial licensing, permissions, and multi-user concerns are deferred to each idea’s Product Path rather than allowed to distort the personal V0.

## 1. AI Founder Archetype Quiz

This is a highly feasible static product: deterministic weighted questions create reliable results, while a local model is optional presentation polish. The durable asset is a reusable “diagnostic engine” with question schemas, scoring tests, and result-card templates. The main risk is false psychological authority, so results should be framed as reflection/entertainment and include a practical challenge.

Primary building blocks: [XState](https://github.com/statelyai/xstate) for quiz state, [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs) for schema-bound prose, and [Satori](https://github.com/vercel/satori) with [resvg-js](https://github.com/thx/resvg-js) for share cards.

## 2. Am I Underpaid

The arithmetic is easy; defensible cohorts are hard. The 2025 Stack Overflow survey reports a large compensation sample, but it cannot support every role/city/employment combination. The product should always show year, sample size, range, and selection-bias caveats, suppress tiny cohorts, and pair benchmarks with a personally actionable sustainable-rate calculator.

Primary sources: [2025 Stack Overflow work/compensation results](https://survey.stackoverflow.co/2025/work), [survey methodology](https://survey.stackoverflow.co/2025/methodology/), and PostgreSQL [window functions](https://www.postgresql.org/docs/17/functions-window.html) for a later server-side percentile implementation.

## 3. Brainrot Rehab

A screenshot/manual check-in is much simpler and more portable than native device telemetry. Android usage data needs special user access, while Apple activity reporting operates inside a constrained entitlement/sandbox model. The V0 should compare the user only with their own baseline, treat the “stage” as optional comedy, and select interventions from a safe curated deck.

Primary sources: [Tesseract.js](https://github.com/naptha/tesseract.js), [Telegram Bot API](https://core.telegram.org/bots/api), Android [`UsageStatsManager`](https://developer.android.com/reference/android/app/usage/UsageStatsManager.html), and Apple [`DeviceActivityReport`](https://developer.apple.com/documentation/deviceactivity/deviceactivityreport).

## 4. Cold Email Rewrite Desk

This is a straightforward structured transformation, but lead sourcing, consent, and deliverability are separate and harder products. Start with user-supplied relevance evidence and manual copy, make every personalization claim traceable, and never auto-send. Gmail draft creation is the safest first integration because it preserves review.

Primary sources: [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs), [Gmail Drafts API](https://developers.google.com/workspace/gmail/api/guides/drafts), the FTC [CAN-SPAM guide](https://www.ftc.gov/business-guidance/resources/can-spam-act-compliance-guide-business), and Gmail [sender guidelines](https://support.google.com/a/answer/14229414).

## 5. Fine Print Rage Meter

The valuable product is evidence-linked issue spotting, not a magic legal score. A paste-first V0 eliminates scraping/security complexity. It should show exact clause text, implications, uncertainty, and topics not assessed. URL ingestion later requires robust SSRF controls and may reuse existing ToS;DR reviews.

Primary sources: [Mozilla Readability](https://github.com/mozilla/readability), [Playwright Page API](https://playwright.dev/docs/api/class-page), [ToS;DR data/API](https://tosdr.github.io/tosdr.org/api.html), and OWASP’s [SSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html).

## 6. Founder Investor Update Writer

All finance calculations should remain deterministic and auditable; the model narrates approved values only. A versioned metric dictionary prevents month-to-month definition drift. SQLite, Chart.js, and Markdown export are enough for a useful private tool before email or data connectors.

Primary building blocks: [SQLite](https://www.sqlite.org/about.html), [Chart.js](https://github.com/chartjs/Chart.js), [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs), and [Gmail Drafts API](https://developers.google.com/workspace/gmail/api/guides/drafts).

## 7. Google Review Reply Desk

Google provides an official review/reply API, but access requires OAuth, verified locations, and project approval. Therefore paste-and-copy is the correct first build. Public replies should be short, professional, privacy-safe, and separate from the private recovery action; severe allegations should trigger escalation rather than generated concessions.

Primary sources: Google Business Profile [review data guide](https://developers.google.com/my-business/content/review-data), [`reviews.updateReply`](https://developers.google.com/my-business/reference/rest/v4/accounts.locations.reviews/updateReply), and Google’s [review-reply guidance](https://support.google.com/business/answer/3474050).

## 8. Haggle Score

A rule engine must own price, concessions, patience, terminal states, and scoring. A local model can perform the character and classify requests into legal actions, but cannot be the economic authority. This prevents prompt injection from changing the deal and makes runs reproducible.

Primary building blocks: [XState](https://github.com/statelyai/xstate), [Ollama tool calling](https://docs.ollama.com/capabilities/tool-calling), and [Satori](https://github.com/vercel/satori) with [resvg-js](https://github.com/thx/resvg-js).

## 9. Latte into Lambo

Historical calculation is simple once the date, currency, price, contribution, and non-trading-day rules are fixed. The risk is financial FOMO and misleading “performance” because fees, spreads, taxes, dividends, and human behavior are omitted. A BTC-only, price-only, monthly prototype with a full audit table is the cleanest V0.

Primary sources: CoinGecko [market chart range endpoint](https://docs.coingecko.com/reference/coins-id-market-chart-range) and [Demo pricing](https://www.coingecko.com/en/api/pricing), plus [Alpha Vantage documentation](https://www.alphavantage.co/documentation/) for a later equity adapter.

## 10. Market Mood Cards

Price moves and contemporaneous headlines do not establish causation. The card should say “what moved + recent sourced headlines + one thing to watch,” with feed timestamps and unavailable states. GDELT offers frequently updated news discovery; price calculations remain deterministic.

Primary sources: [GDELT data](https://www.gdeltproject.org/data.html), [GDELT DOC 2.0 API](https://blog.gdeltproject.org/gdelt-doc-2-0-api-debuts/), [Alpha Vantage](https://www.alphavantage.co/documentation/), [APScheduler](https://github.com/agronholm/apscheduler), and [Telegram Bot API](https://core.telegram.org/bots/api).

## 11. Meet in the Middle

Fairness should use travel times, not a geographic midpoint. OSRM’s table service supplies duration matrices for road profiles, enabling minimax or minimum-total-time ranking. Use approximate neighborhoods/stations, expiring sessions, and a curated venue list first. Telegram is easier than attempting unsupported WhatsApp group automation.

Primary sources: [OSRM Table service](https://project-osrm.org/docs/v5.24.0/api/), the public [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/), [Telegram Bot API](https://core.telegram.org/bots/api), and Google [Places Nearby Search](https://developers.google.com/maps/documentation/places/web-service/nearby-search) for a later paid venue layer.

## 12. NPC Mode

The viable product is a finite low-stakes choice game, not general “obey the AI.” A user-approved action deck, visible veto/stop, quiet hours, and private recap define the safety boundary. Telegram plus a scheduler completes the loop; a model adds flavor but not authority.

Primary building blocks: [Telegram Bot API](https://core.telegram.org/bots/api), [XState](https://github.com/statelyai/xstate), [APScheduler](https://github.com/agronholm/apscheduler), and [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs).

## 13. Pocket CRM

This is best built as structured capture plus confirmation. Telegram is a low-friction personal channel; SQLite and APScheduler cover storage/reminders. Natural-language dates must be previewed in exact local time, and the database should keep extracted CRM facts instead of complete private conversations.

Primary building blocks: [SQLite](https://www.sqlite.org/about.html), [APScheduler](https://github.com/agronholm/apscheduler), [Telegram Bot API](https://core.telegram.org/bots/api), and [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs).

## 14. Real Estate Listing Optimizer

The core is a locked fact schema, not free-form copy generation. Schema.org supplies reusable property/offer types, and ExifTool prevents accidental photo-location disclosure. Deterministic copy should precede an optional tone pass; unsupported amenities, distances, approvals, views, and urgency must be blocked.

Primary sources: Schema.org [`House`](https://schema.org/House) and [`Offer`](https://schema.org/Offer), [ExifTool](https://exiftool.org/), and India’s [Guidelines for Prevention of Misleading Advertisements](https://consumeraffairs.nic.in/sites/default/files/CCPA_Notification.pdf).

## 15. Roast My Landing Page

The strongest version combines deterministic audits with memorable writing. Each roast line should point to screenshot, metric, copy, or accessibility evidence and end in a fix. Screenshot-plus-copy input validates demand before URL fetching; later URL support must prevent SSRF and record audit conditions.

Primary building blocks: [Playwright](https://playwright.dev/docs/api/class-page), [Lighthouse](https://github.com/GoogleChrome/lighthouse), [axe-core](https://github.com/dequelabs/axe-core), and [Satori](https://github.com/vercel/satori).

## 16. Startup Idea Dating Profile

This is a small viral formatter whose serious value comes from requiring customer, pain, current alternative, and distribution before generation. Results should separate playful “toxic trait” language from evidence gaps and finish with one time-boxed validation experiment.

Primary building blocks: [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs), [XState](https://github.com/statelyai/xstate), [Satori](https://github.com/vercel/satori), and [resvg-js](https://github.com/thx/resvg-js).

## 17. X Profile Autopsy

Manual import of one’s own bio/posts is the best free-first path because official X reads are pay-per-use and third-party scoring adds consent/harassment risk. Metrics should be code-calculated and disclose sample windows; the model names themes and drafts ideas from representative, user-owned posts.

Primary sources: X [user lookup](https://docs.x.com/x-api/users/lookup/quickstart/user-lookup), X [user posts](https://docs.x.com/x-api/users/get-posts), X [API pricing](https://docs.x.com/x-api/getting-started/pricing), and [Ollama structured outputs](https://docs.ollama.com/capabilities/structured-outputs).

## 18. AI Event Matchmaker

Five structured questions plus a balanced, explainable ranking are enough for a small-event prototype. Match offer-to-need complementarity, not only semantic similarity, and cap how often one attendee is recommended. Consent controls, expiry, and source-backed reasons matter more than a sophisticated learned recommender.

Primary building blocks: [pretix](https://github.com/pretix/pretix) and its [orders API](https://docs.pretix.eu/dev/api/resources/orders.html), [Sentence Transformers](https://github.com/UKPLab/sentence-transformers), and [vCard RFC 6350](https://datatracker.ietf.org/doc/rfc6350/).

## 19. B2B Competitor Battlecard

The defensible asset is a structured evidence library with capture time, quote fragment, and approval state. Monitor only allowlisted official pages/feeds, distinguish vendor claims from verified capability, and allow “unknown.” A one-off battlecard can share its capture/evidence layer with the recurring intelligence project.

Primary building blocks: [changedetection.io](https://github.com/dgtlmoon/changedetection.io), [Playwright](https://playwright.dev/docs/intro), GitHub [Releases API](https://docs.github.com/en/rest/releases), and [Common Crawl Index](https://index.commoncrawl.org/).

## 20. Birthday Anthem Maker

A spoken or rhythmically delivered radio jingle over a cleared/fixed music bed is a much easier and often better first product than convincing generated singing. Lyrics should reference a validated fact checklist, pronunciation needs explicit handling, and the sender must preview before sharing.

Primary building blocks: [AudioCraft/MusicGen](https://github.com/facebookresearch/audiocraft), [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) and [Voice Design](https://elevenlabs.io/docs/eleven-creative/voices/voice-design/), [Piper](https://github.com/OHF-Voice/piper1-gpl), and [FFmpeg filters](https://ffmpeg.org/ffmpeg-filters.html).

## 21. Build in Public Autoposter

Commits are evidence, not a story. The tool should cluster mechanical activity, ask why it mattered, scan for secrets/private identifiers, and generate a draft with source references. Manual copy or an approval-gated Mastodon publisher avoids forced daily spam and unstable platform API costs.

Primary sources: GitHub [commits REST API](https://docs.github.com/en/rest/commits), GitHub [webhook push payloads](https://docs.github.com/en/webhooks/webhook-events-and-payloads), Mastodon [statuses API](https://docs.joinmastodon.org/methods/statuses/), and X [API pricing](https://docs.x.com/x-api/getting-started/pricing).

## 22. City Roast Map

The map should roast amenities and observable local habits—not demographics, protected groups, crime, or individual residents. OpenStreetMap completeness varies, so normalized values need coverage/provenance. A curated static city pack proves the humor before public submissions or live data.

Primary building blocks: [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/), [Overpass QL](https://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide), [Wikidata Query Service](https://www.wikidata.org/wiki/Help:Query), and the [Nominatim usage policy](https://operations.osmfoundation.org/policies/nominatim/).

## 23. Clicky for Hinge

The safe scope is a private drafting assistant using user-provided context, not Hinge access or automation. OCR must be confirmed because swapped speakers produce disastrous output. Delete screenshots by default, offer distinct strategies, and include “send nothing/move on” when appropriate.

Primary building blocks: [Tesseract OCR](https://github.com/tesseract-ocr/tesseract), [ML Kit Text Recognition v2](https://developers.google.com/ml-kit/vision/text-recognition/v2), the PWA [`share_target` manifest member](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Manifest/Reference/share_target), and [Ollama chat API](https://docs.ollama.com/api/chat).

## 24. Commentary Box

Manual event timestamps plus user descriptions produce a reliable weekend prototype; full video understanding does not. Generate duration-constrained lines per marker, synthesize per segment, duck original audio, and retry only failed segments. FFmpeg is the core production engine; Remotion is optional visual polish.

Primary building blocks: [FFmpeg filters](https://ffmpeg.org/ffmpeg-filters.html), [Whisper](https://github.com/openai/whisper), [Remotion](https://www.remotion.dev/docs), [Piper](https://github.com/OHF-Voice/piper1-gpl), and [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech).

## 25. Community Ops Agency

This should be a suggestion/approval desk, not an autonomous moderator. The useful first deliverables are unanswered-question queue, weekly digest, onboarding checklist, ICS calendar, and evidence-linked moderation suggestions. Imports are safer than immediate platform write permissions.

Primary sources: [Discord API](https://docs.discord.com/developers/reference), [Discourse API](https://docs.discourse.org/), [Matrix Client-Server API](https://spec.matrix.org/latest/client-server-api/), and [n8n](https://github.com/n8n-io/n8n).

## 26. Commute Copilot

Feed availability and freshness are the go/no-go constraints. GTFS Realtime supplies standardized delay/cancellation data, but stale data must degrade explicitly to schedule-only or unavailable. One saved route and preselected fallbacks avoid running a general multimodal router until necessary.

Primary sources: GTFS Realtime [Trip Updates](https://gtfs.org/documentation/realtime/feed-entities/trip-updates/), GTFS [Realtime Best Practices](https://gtfs.org/documentation/realtime/realtime-best-practices/), [OpenTripPlanner](https://github.com/opentripplanner/OpenTripPlanner), and [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/).

## 27. Compatibility Duet

The result should be symmetric and framed as a conversation starter, not a “soulmate score.” Both participants consent independently, raw answers remain private by default, the joint card unlocks only after completion, and either side can delete. Deterministic dimensions avoid model overinterpretation.

Primary building blocks: the public-domain [International Personality Item Pool](https://ipip.ori.org/), [JSON Schema](https://json-schema.org/specification), [Web Cryptography API](https://www.w3.org/TR/WebCryptoAPI/), and [Convex realtime](https://docs.convex.dev/realtime) for a later hosted completion signal.

## 28. Competitive Intelligence Agency

This is a recurring evidence time series, not merely a report generator. Snapshot allowlisted official sources, normalize layout noise, classify meaningful changes, and separate observed changes from analyst hypotheses. The same evidence records can refresh battlecards and expose stale claims.

Primary building blocks: [changedetection.io](https://github.com/dgtlmoon/changedetection.io), [Playwright](https://playwright.dev/docs/intro), GitHub [Releases API](https://docs.github.com/en/rest/releases), and [Common Crawl Index](https://index.commoncrawl.org/).

## 29. Contract Red Flag Memo

This is high-stakes issue spotting and must preserve page/quote provenance, parsing/OCR confidence, checklist coverage, and an explicit “not assessed” section. Contract effects depend on definitions, exhibits, law, and context; the safest output is a reviewed memo plus questions for counsel rather than an enforceability verdict.

Primary building blocks: [PyMuPDF](https://pymupdf.readthedocs.io/en/latest/the-basics.html), [OCRmyPDF](https://ocrmypdf.readthedocs.io/en/latest/), [Docling](https://github.com/docling-project/docling), and [CUAD](https://github.com/TheAtticusProject/cuad/).

## 30. Course Notes to Quiz Product

Source-linked practice and correction are more valuable than high-volume generation. Every accepted card/question should cite a source chunk, ambiguous distractors must enter a review queue, and unsupported questions should be rejected. Export to Anki/Moodle before rebuilding mature cross-device scheduling.

Primary building blocks: Anki [FSRS documentation](https://docs.ankiweb.net/deck-options.html), [AnkiConnect](https://github.com/FooSoft/anki-connect), Moodle [GIFT format](https://docs.moodle.org/en/GIFT_format), and [1EdTech QTI](https://www.1edtech.org/standards/qti/index).

## 31. Customer Support Agency

The best first product analyzes a user-provided, de-identified ticket export and produces an issue taxonomy, policy-grounded macros, escalation tree, FAQ candidates, and quality rubric. It should rank frequency, effort, and risk separately, avoid sentiment-only prioritization, and validate on a holdout set before any live connector.

Primary sources: [Chatwoot](https://github.com/chatwoot/chatwoot), Zendesk [Tickets API](https://developer.zendesk.com/api-reference/ticketing/tickets/tickets/), Intercom [Conversations API](https://developers.intercom.com/docs/references/2.10/rest-api/api.intercom.io/conversations), and Help Scout [List Conversations API](https://developer.helpscout.com/mailbox-api/endpoints/conversations/list/).

## Consolidation Opportunities

The 31 ideas can be learned and shipped faster as reusable engines:

1. **Viral diagnostic/card engine:** AI Founder Archetype Quiz, Startup Idea Dating Profile, Haggle Score, Roast My Landing Page, X Profile Autopsy, Compatibility Duet.
2. **Evidence-bound writing desk:** Cold Email Rewrite Desk, Google Review Reply Desk, Founder Investor Update Writer, Real Estate Listing Optimizer, B2B Competitor Battlecard, Contract Red Flag Memo.
3. **Bot + scheduler + private state:** Brainrot Rehab, NPC Mode, Pocket CRM, Meet in the Middle, Build in Public Autoposter, Commute Copilot.
4. **Source-backed analysis pipeline:** Market Mood Cards, Competitive Intelligence Agency, Customer Support Agency, Community Ops Agency, Course Notes to Quiz Product.
5. **Media renderer:** Birthday Anthem Maker and Commentary Box.

Build one excellent core per family. Most subsequent “products” become schemas, rules, prompts, adapters, and templates rather than new architectures.
