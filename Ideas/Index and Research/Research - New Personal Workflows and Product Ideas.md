---
type: research-dossier
created: 2026-08-14
scope: private-single-user-v0
source_quality: primary-sources-only
topics:
  - personal-workflows
  - local-first
  - product-research
  - automation
---

# Research - New Personal Workflows and Product Ideas

> **Scope decision:** research and recommendations assume a private, single-user first build. Public-release questions such as redistribution rights, licensing, marketplace obligations, platform review, and third-party consent belong in [[Scope Expansion Checklist]] and do not change the recommended local-first stacks below.

## Portfolio Consolidation

This dossier covers **eight self-contained builds**. X liked-post organization, short-form summarization, subscription hygiene, and the button-gated feed should remain separate projects because each has a useful standalone V0 and a different failure surface. They can still share capture adapters, a normalized content store, embeddings, and explicit preference events. The only intentional product merge here is Meet-in-the-Middle plus City Roast: the roast is a presentation layer over the same ranked location candidates.

The projects can share a small local platform: Python workers, SQLite, a local model endpoint, an append-only activity log, scheduled jobs, and a browser extension for capture. Shared infrastructure should not force shared release schedules or one mega-dashboard.

---

## 1. Moving Out Marketplace

### Refined product thesis

Build a **deadline-native local clearance sale**, not another generic classifieds site. A seller creates one move event with a move-out deadline, approximate pickup area, pickup windows, and a batch of photographed items. Every listing inherits the deadline and can move through `available -> offered -> reserved -> paid -> picked_up -> donated/expired`. Buyers browse a nearby moving event as a collection, bundle several items, make an offer or bid, and reserve a pickup slot. The distinctive value is liquidation certainty: price and fulfillment rules become more urgent as the move date approaches.

The concept combines mechanics that established products keep separate:

- [Facebook Marketplace](https://www.facebook.com/help/1713241952104830) provides community-local search and categories, while its [local transaction guidance](https://www.facebook.com/help/287743092672086/) distinguishes door pickup, drop-off, and public meetups.
- [eBay auctions](https://www.ebay.com/help/selling/listings/auction-format?id=4110) provide scheduled bidding and a highest-bidder close; eBay supports 1, 3, 5, 7, or 10-day auctions.
- [eBay local pickup](https://www.ebay.com/help/selling/posting-items/shipping-items?id=4181) demonstrates a useful handoff pattern: reveal only a coarse area before purchase, coordinate after checkout, and use a buyer pickup code as proof of handoff.
- [Razorpay Payment Links](https://razorpay.com/docs/payments/payment-links/apis/) can accept an amount with an expiry and callback without building checkout. A later multi-seller product can use [Razorpay Route](https://razorpay.com/docs/payments/route/?preferred-country=IN) to split incoming funds among linked accounts. [Stripe Connect](https://docs.stripe.com/connect/marketplace) is the analogous marketplace architecture where supported.

### Best private V0

Make the first version a **single-seller moving-sale microsite for your own inventory**. It needs no user accounts and no marketplace payout system:

1. Drop photos into an intake folder or take them in a mobile PWA.
2. Run local vision plus an editable form to suggest title, category, condition, dimensions, likely price band, and transport needs.
3. Publish a secret or shareable sale URL containing a map-radius rather than the exact address.
4. Let buyers submit offers or bids with a name and contact method.
5. Manually accept an offer; the system creates a reservation expiry, pickup window, and optional Razorpay payment link.
6. Confirm pickup with a six-digit code and keep a disposal queue for unsold items.

This version directly tests the core behavior - whether a single event, bundles, deadline pressure, and pickup coordination clear inventory faster - without first solving two-sided marketplace acquisition.

### Free-first/local-first implementation

- **UI:** Next.js or SvelteKit PWA with a seller console and public sale page. A plain server-rendered site is sufficient; native mobile is unnecessary for V0.
- **Data:** SQLite with Drizzle/Prisma. Store original photos on disk, WebP derivatives beside them, and immutable bid events rather than only the current price.
- **Map:** [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs) for the browser map. Use an approximate geohash or deliberately offset point publicly.
- **Geocoding:** the public Nominatim service is acceptable only for light, user-triggered use; its [usage policy](https://operations.osmfoundation.org/policies/nominatim/) forbids heavy use and requires caching. Self-host later or switch to Photon.
- **Payments:** manual UPI/cash first; Razorpay Payment Links next; Route/Connect only after multiple sellers exist.
- **Images:** `magick mogrify -auto-orient -resize '1600x1600>' -quality 82 -format webp *.jpg` gives an inexpensive batch optimization path. Run background removal or vision classification only where it materially saves listing time.

Minimal data entities are `sale_event`, `item`, `item_media`, `price_rule`, `offer_or_bid`, `reservation`, `pickup_window`, `payment_reference`, `handoff_code`, and `activity_event`. A bundle is an offer referencing multiple items, not a new duplicated listing.

### Clever product mechanics

- **Deadline price ladder:** seller defines reserve and floor. The site can suggest markdowns at D-7, D-3, and D-1, but the seller can freeze any item.
- **Bundle-first checkout:** show “also from this home” and let the buyer submit one pickup and one offer for multiple objects.
- **Vehicle-fit hints:** dimensions plus “fits in hatchback/sedan; two-person lift; stairs” are more useful than elaborate shipping estimation.
- **Donation fallback:** when the timer expires, export unsold items as a clean CSV/contact sheet instead of silently deleting them.
- **Moving adjacency:** rental/property discovery can appear as an optional sale-event card, but should not be part of the transaction model. Clearance inventory and real-estate listings have different data and workflows.

### Failure modes and test criteria

The major risk is liquidity: a polished auction is useless when only one nearby buyer sees it. Begin with shareable links to apartment groups, friends, and existing local communities. Auctions also fail on low-interest items, so every item should support fixed price, offer, free, and timed auction modes. Pickup no-shows can make the last day worse; use short reservation expiry, backup buyers, and visible pickup windows. Exact location should remain hidden until reservation because it is unnecessary for discovery.

Measure: median minutes to create a listing, percentage sold or rehomed before deadline, bundle rate, no-show rate, time from accepted offer to pickup, and seller-estimated effort saved. A successful personal V0 clears a real batch of at least 20 items and produces fewer coordination messages per item than posting them independently.

### Simpler alternative

Before building a public site, generate a **static sale catalog plus a Tally/Google Form and Razorpay links**. A small script can create item pages, a WhatsApp-friendly contact sheet, and a live status JSON. If this clears the inventory, the differentiator is the event workflow and distribution, not bidding infrastructure.

---

## 2. X Like-to-List Builder

### Refined product thesis

Turn an export of liked X posts into an explainable map of interests and people, then propose private X Lists such as `AI research`, `builders`, `India policy`, `design`, or `low-volume signal`. The important output is not only a topic cluster: it is a reviewable `author -> proposed lists -> supporting liked posts -> confidence` table. A creator can belong to several lists, and old likes should be time-decayed so a past fascination does not dominate the current taxonomy.

### What official APIs can and cannot do

- X officially allows downloading an account archive as a ZIP containing a snapshot of account information ([X archive help](https://help.x.com/en/managing-your-account/how-to-download-your-x-archive)). Use this as the **free bootstrap** instead of paying for historical API reads.
- The current X API exposes `GET /2/users/:id/liked_tweets`, List creation, and List membership; the official [rate-limit table](https://docs.x.com/x-api/fundamentals/rate-limits) lists the relevant endpoints, and [Add List member](https://docs.x.com/x-api/lists/add-list-member) documents the write call. The official [X API overview](https://docs.x.com/x-api/overview) describes the current pay-per-use access model, so write proposed list assignments to CSV first and make API execution optional.
- [`twitter-archive-parser`](https://github.com/timhutton/twitter-archive-parser) is an open-source shortcut for turning the official archive's JavaScript/JSON structures into Markdown/HTML and resolving archived entities. A purpose-built importer can instead parse `like.js`, batch-resolve post/author metadata where available, and preserve unresolved IDs.

### Best private V0

Import one archive, normalize likes and authors into SQLite, embed the liked text, cluster it, and render a local author review table. Export the accepted taxonomy as CSV first. If API access is enabled, create lists and add approved members through the official write endpoints. Measure assignment acceptance, unclustered authors, list usefulness after one week, and changes needed after time-decay. The simplest alternative is a notebook that outputs one CSV per proposed List.

Free-first stack: Python, `orjson`, Polars, sentence-transformers, SQLite/FTS5, HDBSCAN or agglomerative clustering, and a small Streamlit/React review UI. Store the evidence likes for every assignment so the model's category can be challenged.

---

## 3. Shortform Signal Digest

### Refined product thesis

Create a private **attention firewall** that periodically captures a bounded sample of short-form sources, extracts text/audio/visual signals, collapses reposts, and produces an end-of-day report organized as `new developments`, `useful explainers`, `opportunities/actions`, `repeated noise`, and `questions for me`. It should learn from explicit `useful / not for me / already knew / follow this topic` feedback.

### What official APIs can and cannot do

- [TikTok Display API](https://developers.tiktok.com/doc/display-api-overview/) provides a user's profile and their own recent/self-selected public videos. It is not an API for the personalized For You feed or saved collections. The [Content Posting API](https://developers.tiktok.com/products/content-posting-api/?from_seo_redirect=1) is for publishing, not feed reading.
- Because personalized feeds and saved collections are not uniformly exposed, the reliable personal fallback is **user-controlled browser capture**. Chrome content scripts can extract the currently rendered cards, while [Chrome extension storage](https://developer.chrome.com/docs/extensions/reference/api/storage) persists extension state. [Playwright authentication state](https://playwright.dev/docs/auth) can reuse a dedicated signed-in browser profile, but the state file contains impersonation-capable cookies and must stay local.

### Best private V0

Do not begin by autonomously scrolling every network hourly. Start with a browser-extension `Save to Digest` button, plus an optional “capture the ten visible cards” command for unsupported feeds. Add scheduled sampling only after the manual corpus proves that clustering and summarization are useful.

Each normalized item should preserve platform, native ID, author, URL, displayed text, media references, captured time, and raw snapshot hash. Derive transcript, summary, topics, entities, novelty score, evidence links, creator reliability notes, and preference score separately so raw capture can always be reprocessed.

The evening report should have five bounded sections: `new developments`, `useful explainers`, `opportunities/actions`, `repeated noise`, and `questions for me`. Selecting `useful`, `not for me`, `already knew`, or `follow this topic` becomes explicit preference data. Do not infer preference solely from dwell time; the whole purpose is to reduce compulsive viewing.

### Free-first/local-first stack and commands

- **Capture:** Manifest V3 Chrome extension plus per-site adapters; Playwright only for scheduled flows that cannot be captured interactively.
- **Video metadata/transcript:** [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) supports playlists, subtitle discovery, metadata JSON, and download archives. Examples:

```bash
yt-dlp --skip-download --write-auto-subs --sub-langs 'en.*,en' --sub-format vtt VIDEO_URL
yt-dlp --download-archive seen.txt --write-info-json --skip-download PLAYLIST_URL
```

- **Cross-site media:** [`gallery-dl`](https://github.com/mikf/gallery-dl) supports cookie-backed extractors and includes X likes, bookmarks, lists, and home-feed surfaces in its [supported-sites table](https://github.com/mikf/gallery-dl/blob/master/docs/supportedsites.md). Treat extractor breakage as expected, keep native URLs, and isolate each connector.
- **Processing:** Python, FastAPI, APScheduler, `trafilatura` for articles, faster-whisper or whisper.cpp for missing speech transcripts, local embeddings, and a small instruction model served through Ollama/llama.cpp.
- **Store/search:** SQLite with FTS5 for the first 100k items; move media-derived analytical tables to DuckDB only if batch queries warrant it.
- **Automation:** n8n can schedule ingestion and deliver a digest, but keep capture/parsing code in versioned Python modules because site adapters change more often than workflows.

### Preference model

Use a transparent score, not an opaque recommender: `source_priority + topic_interest + novelty + actionable_signal - repetition - predicted_time_cost`. Store each component. The report can ask a maximum of two context questions when a potential reply needs personal experience. Answers become dated “experience facts” with a source note, never automatically rewritten into a permanent biography.

### Failure modes and test criteria

Feed HTML, undocumented endpoints, and session flows change frequently. Platform connectors therefore need independent health checks and a visible `last successful sync`; a failed source must not block the digest. Short-form transcription is noisy, visual jokes can be lost in audio-only processing, and trend clustering can overstate ten recycled clips as ten independent signals. Use perceptual hashes, transcript similarity, and original-source linking to collapse reposts.

Measure: minutes of raw scrolling displaced, percentage of digest items marked useful, duplicate-collapse rate, missed-important-item audit, cleanup proposals accepted, and correction rate for summaries. The success criterion is not maximum engagement; it is a shorter report with higher useful-item density and deliberate openings.

### Simpler alternative

A browser extension that adds `save`, `hide creator`, and `daily digest` is more robust than a universal authenticated crawler. Only add scheduled browser scrolling after the manually captured corpus proves that the digest changes behavior.

---

## 4. Social Subscription Curator

Inventory followed/subscribed channels, categorize them, measure recent publishing activity, inspect the subjects of recent uploads/playlists, and prepare reversible `keep / occasional / archive / unsubscribe` batches. This is a hygiene tool, not a content summarizer: its success metric is a smaller, better source universe.

YouTube is the best official first connector. `subscriptions.list?mine=true` returns the authenticated user's subscriptions ([official reference](https://developers.google.com/youtube/v3/docs/subscriptions/list)); `subscriptions.delete` can unsubscribe but costs 50 quota units per call and requires write authorization ([official reference](https://developers.google.com/youtube/v3/docs/subscriptions/delete)). `playlistItems.list` retrieves items in a specified playlist at quota cost 1 ([official reference](https://developers.google.com/youtube/v3/docs/playlistItems/list)), while each channel resource exposes its uploads playlist. TikTok's Display API does not provide the followed-channel graph, so unsupported services need export/import or browser-assisted capture.

Private V0: sync YouTube subscriptions, fetch the latest 10-20 uploads per channel, derive last-active date, posting cadence, dominant topics, watched/saved overlap when locally available, and an explanation for each recommendation. Confirm changes one batch at a time and save an undo manifest containing subscription ID, channel ID, and timestamp. Free-first stack: Python Google API client, SQLite, local embeddings, and a review UI. `yt-dlp --flat-playlist --dump-single-json ':ytsubs' --cookies-from-browser chrome` is a useful unofficial inventory shortcut but the official API should execute changes.

Measure the proportion of recommendations accepted, incorrect “defunct” classifications, subscriptions restored, and whether the remaining feed has higher useful-item density. The simplest alternative is a quarterly CSV report with direct channel links and no write automation.

---

## 5. Deliberate Feed Gate

Build a cross-site consumption interface that reveals only one candidate at a time. Before exposing the media, show author/title, one-sentence synopsis, predicted time cost, selection reason, and buttons: `show`, `skip`, `save for digest`, and `open native`. A skip advances without playing the item. A “yes” can deep-link to the native app for like, comment, or share.

This is separate from Shortform Signal Digest because it is an interaction and habit-design experiment rather than an ingestion pipeline. It can consume the Digest's normalized items but should also work from a manually queued URL list. The browser-extension approach is technically feasible through Chrome content scripts and extension storage; a side-panel or local PWA is less brittle than trying to replace the DOM of every social site.

Use a transparent score: `source_priority + topic_interest + novelty + actionable_signal - repetition - predicted_time_cost`, and show the components. Store only explicit decisions and optional outcome feedback. If the platform exposes a dependable native “not interested” action, queue it separately; otherwise record the local skip. Like/comment/share should open a prepared draft or native UI because a local record cannot prove an external action succeeded.

Private V0: a local PWA reads 30 queued items, gates each one, and writes an event log. Compare raw-scroll minutes, items opened, skip regret, useful-item rate, and session stopping behavior with the ordinary feed. The clever simplest alternative is a browser extension that intercepts navigation to `/shorts`, `/reels`, or equivalent and redirects to the local queue unless a timed bypass is chosen.

---

## 6. Meet-in-the-Middle City Explorer

### Refined product thesis

Merge “meet me in the middle” and City Roast into a playful **fair meeting-place explorer**. It computes candidate districts or venues that minimize travel unfairness for several origins, then gives each candidate a useful profile and an optional comedic roast. The joke layer should sit on top of a defensible travel-time calculation, turning an otherwise utilitarian planner into something shareable.

A geometric midpoint is often a bad meeting point because roads, transit, rivers, and city boundaries distort travel. The scoring model should therefore minimize actual route time:

`score = mean_travel_time + fairness_weight * max_travel_time + spread_weight * standard_deviation - venue_quality_bonus`

Allow car, walking, cycling, and later transit profiles. Show why the winner was chosen and let users move the fairness slider rather than hiding the objective inside an LLM.

### Existing building blocks

- [OpenStreetMap](https://www.openstreetmap.org/about/api/) supplies community-maintained roads, trails, cafes, stations, and other mapped features.
- [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs) renders the interactive vector map without committing to a commercial map UI.
- [Photon](https://github.com/komoot/photon) is an open-source OSM geocoder with forward/reverse search, bounding-box and location bias, typo tolerance, multilingual fields, and self-hosting. Its public demo is fair-use only and can throttle extensive traffic.
- [OSRM](https://github.com/Project-OSRM/osrm-backend) is a high-performance OSM routing engine. Its Route service finds routes and its Table service calculates travel-time/distance matrices; the [HTTP documentation](https://github.com/Project-OSRM/osrm-backend/blob/master/docs/http.md) makes the matrix ideal for evaluating candidate venues against all participants.
- Overpass queries can retrieve nearby OSM POIs such as cafes, parks, pubs, museums, and stations. Use it for discovery, not routing.

### Best private V0

Build a shareable single-page tool:

1. Add two to five starting locations and choose a travel mode for each.
2. Geocode them and calculate a first centroid only to define a candidate search area.
3. Retrieve 30-100 candidate POIs/district centers around that area.
4. Use an OSRM table request to calculate every origin-to-candidate travel time.
5. Rank by mean, worst-case, spread, opening-hours availability, and venue-type preference.
6. Show the top three with route-time bars, map, useful description, and a clearly optional local-model roast.

OSRM's Table endpoint returns a duration matrix in seconds and distance matrix in meters. A local request can look like:

```bash
curl 'http://127.0.0.1:5000/table/v1/driving/LON1,LAT1;LON2,LAT2;CANDIDATE_LON,CANDIDATE_LAT?annotations=duration,distance'
```

For the first demo, use a hosted routing service sparingly or self-host one city/region in Docker using OSRM's official quick-start. Keep candidate and route responses cached by rounded coordinates.

### Data and stack

- **Frontend:** SvelteKit/Next.js with MapLibre, URL-serializable state, and a screenshot/share-card action.
- **Backend:** FastAPI or TypeScript; SQLite cache; Photon/Nominatim geocoding adapter; OSRM matrix adapter; Overpass POI adapter.
- **Roast generator:** local small instruction model receiving only factual location features such as travel imbalance, venue density, landmark mix, weather if supplied, and user-selected intensity. It should also produce a straight “sell” version from the same features.
- **Core entities:** `participant_origin`, `travel_profile`, `candidate_place`, `route_leg`, `venue_fact`, `score_breakdown`, `roast_variant`, `saved_plan`.

### Clever hacks and simpler alternatives

- Sample candidate points on travel-time isochrone intersections before fetching POIs; this avoids calculating every cafe in the city.
- For two people, minimize `max(t1, t2)` first, then rank venues near the equal-time contour. For groups, provide “fairest” and “lowest total time” as separate presets.
- Return a district when venue data is thin. The group can choose the specific cafe after accepting the area.
- A simple alternative is a client-only tool using one geocoder plus a hosted matrix API, with five pre-selected candidates. Do not self-host planet-scale Photon or OSRM for a personal prototype; a regional extract is enough.

### Drawbacks and success criteria

Routing quality depends on the profile and freshness of OSM data; straight-line midpoints are unsuitable fallbacks without being labeled. Public geocoders and demo routers are not batch backends. Transit routing needs timetable data and a different engine such as OpenTripPlanner, so omit it from V0 rather than treating driving time as transit.

Measure the maximum-minus-minimum travel-time gap, time to agree on a venue, percentage of plans where users pick a top-three result, and share-card use. A good test is ten real pairs/groups across the same city, comparing the tool's result with their manually chosen location.

---

## 7. Jobs Search and Apply Tool Upgrade

### Refined product thesis

Upgrade JobFinder into a **daily opportunity and preparation pipeline**, not an indiscriminate auto-apply bot. It should continuously watch a user-defined company universe and broader discovery sources; normalize/deduplicate postings; score fit with an auditable rubric; build an evidence-backed application packet; prepare outreach; and track the application through interview preparation and follow-up.

The key distinction is between **discovery automation** and **application judgment**. Discovery, deduplication, document generation, and reminders can be highly automated. The final role selection, truthful resume edits, application questions, and submission should be visible and reviewable because errors here directly waste opportunities.

### Source strategy based on primary feeds

Prioritize company ATS feeds and official career pages over scraping LinkedIn:

- [Greenhouse Job Board API](https://developer.greenhouse.io/job-board.html) exposes public GET endpoints for published jobs without authentication and can include full description, departments, and offices.
- [Lever Postings API](https://github.com/lever/postings-api) lists published jobs with team, department, location, commitment, workplace type, descriptions, salary when supplied, hosted URL, and apply URL. Its public API is designed for company job sites; it does not provide cross-company full-text search, so keep a list of target company site slugs.
- [Ashby public job postings API](https://developers.ashbyhq.com/docs/public-job-posting-api) returns currently published postings and can include compensation; each job includes the hosted job and apply URLs.
- Many employer pages expose `JobPosting` JSON-LD. Google's [JobPosting structured-data specification](https://developers.google.com/search/docs/appearance/structured-data/job-posting) defines fields such as identifier, dates, employment type, location, remote status, salary, and direct-apply state. A generic career-page adapter should inspect JSON-LD before parsing visible HTML.
- LinkedIn officially provides 24-hour/week/month filters, company, experience, employment type, Easy Apply, under-ten-applicants, and in-network filters ([filter documentation](https://www.linkedin.com/help/linkedin/answer/a507441/filter-and-sort-job-search-results?lang=en)). Official alerts can run daily or weekly ([job alerts](https://www.linkedin.com/help/linkedin/answer/a511279/job-alerts-on-linkedin?lang=en)), and search can switch from Jobs to job-related Posts for “we're hiring” discovery ([search help](https://www.linkedin.com/help/linkedin/answer/a511260/search-for-jobs-on-linkedin?lang=en-US)). Treat saved alert emails and manual browser searches as inputs; do not make undocumented LinkedIn scraping the system's foundation.

### Data model and fit scoring

Store an immutable normalized posting with source URL, source job ID, first/last seen, full raw snapshot hash, employer, title, level, locations, remote type, salary evidence, required skills, preferred skills, responsibilities, recruiter/hiring-manager leads, and expiration state. Deduplicate on source ID first, then normalized company/title/location plus semantic similarity.

Represent the user's career evidence in [JSON Resume](https://jsonresume.org/schema) plus a separate achievement bank. Each achievement should contain situation, action, measurable result, skills demonstrated, dates, and evidence links. A resume variant selects and reorders truthful evidence; it must never invent a skill simply because it appears in the job description.

Use a deterministic score before the LLM narrative:

| Component | Example weight | Notes |
|---|---:|---|
| Hard constraints | gate | Company, location/remote, work authorization, minimum salary, excluded role |
| Role and level | 25 | Title family plus scope, not title-string similarity alone |
| Required skill evidence | 30 | Score only achievements with evidence |
| Domain and product fit | 15 | Relevant markets, customers, or technical domain |
| Compensation and logistics | 10 | Unknown salary remains unknown, not zero |
| Recency and competition proxy | 10 | Newly seen role, under-ten-applicants only when shown |
| Network/outreach path | 10 | Actual connection or identified hiring post |

The much-advertised “95 ATS score” is not a portable standard across ATS products. Optimize for readable structure, exact truthful terminology, correct file parsing, and coverage of important requirements. Make the score explainable as **your rubric**, not a claim about a recruiter's hidden model. The same applies to any HackerRank-style hiring-agent score unless an official rubric is available for the exact employer assessment.

### Daily workflow

1. Poll target-company Greenhouse/Lever/Ashby feeds and saved career URLs; ingest new LinkedIn alert emails.
2. Deduplicate and expire disappeared jobs only after a confirmation fetch.
3. Apply hard constraints and produce a daily top-ten queue with a one-paragraph “why / why not.”
4. For accepted roles, generate a packet: evidence matrix, tailored one-page resume, optional cover note, likely screen questions, company/product brief, and outreach candidates.
5. Run document checks: PDF text extraction, contact/link validation, date consistency, page count, and unsupported-claim detection.
6. Open the official apply URL with the packet and a checklist. Record submission and schedule follow-up/prep.
7. Before interview events, export a structured interview-prep packet that a separate calendar or preparation workflow can consume.

### Free-first/local-first stack and commands

- **Collectors:** Python `httpx`, feed-specific adapters, BeautifulSoup/trafilatura for fallback, and JSON-LD extraction.
- **Scheduling:** APScheduler/Windows Task Scheduler or n8n. Poll company feeds every few hours; a daily digest is enough for the personal V0.
- **Data:** SQLite with FTS5 and immutable `job_snapshot` rows. Keep PDFs and generated packets in a predictable folder hierarchy.
- **Documents:** JSON Resume as canonical data, Jinja2/Typst or HTML-to-PDF templates, and `pdftotext` for the round-trip parse check.
- **Inference:** local model for extraction and drafting; deterministic validators for constraints, claims, and document parsing.
- **Browser:** Playwright can open forms and fill repeated fields using a dedicated profile, but every application should pause for review before submission.

Useful diagnostics:

```bash
pdftotext tailored-resume.pdf - | sed -n '1,160p'
curl -s 'https://boards-api.greenhouse.io/v1/boards/COMPANY/jobs?content=true'
curl -s 'https://api.lever.co/v0/postings/COMPANY?mode=json'
curl -s 'https://api.ashbyhq.com/posting-api/job-board/COMPANY?includeCompensation=true'
```

### Failure modes and evaluation

The biggest technical issues are stale postings, repost duplicates, title/level mismatch, missing salary, location ambiguity, dynamic application questions, and model-written achievements unsupported by the source resume. Keep provenance at field level and surface unknowns. Do not let a single high semantic-similarity score override hard constraints.

Measure discovery-to-review latency, percentage of daily recommendations accepted, duplicate/stale rate, time to create a verified packet, applications per interview, outreach reply rate, and interview conversion by source and score band. Run a weekly calibration: inspect high-scored rejects and low-scored roles you manually liked, then adjust rubric weights or extraction rules.

### Simpler alternative

Before browser automation, build a **company-watch CLI plus Kanban dossier generator**. Official ATS feeds populate a local board; selecting a job produces a folder containing the posting snapshot, evidence matrix, resume draft, prep notes, and application link. This captures most of the value and is dramatically easier to battle-test than universal auto-apply.

---

## 8. Quiz Master

### Refined product thesis

Keep Quiz Master and [[Quiz Poker]] as two self-contained systems connected by a versioned question-pack interface:

1. **Quiz Master** is the question foundry: it learns explicit framing patterns from the K-Circle yearbook corpus and turns ordinary topics into clue-rich, inferential questions.
2. **Quiz Poker** is the existing live game engine: it imports reviewed packs and handles rooms, confidence wagers, timing, scoring, and reconnect.

Quiz Master should not be “LLM writes trivia.” Its value is a deterministic, inspectable question-design grammar plus a corpus-backed evaluator. K-Circle's official site identifies it as an active Hyderabad quiz club founded in 1972, reports more than 2,600 quizzes, publishes a quiz template and weekly Quizmaster's Choice, and offers digital yearbooks ([K-Circle home](https://www.kcircle.com/Home), [yearbooks](https://www.kcircle.com/quizzes/buy-quiz-compilations-yearbook)). Those yearbooks are the target style corpus; the system should derive patterns from the supplied files rather than claim a universal definition of a “K-Circle question.”

### Reverse-engineering workflow

Create a human-auditable annotation set before model training:

- Extract each question, answer, quiz, quizmaster, date/year, theme, media, and explanation into structured JSON.
- Label the **answer class** (person/place/work/event/object/concept), **clue route** (etymology, biography, connection, visual, quote, chronology, transformation, wordplay), **inference depth**, **number of independent clue paths**, **reveal order**, **misdirection type**, **specificity**, **obscurity**, and **answerability without recall**.
- Mark sourceability, ambiguity, alternate answers, giveaway clues, accidental leaks, and required cultural context.
- Cluster repeated templates, then express each cluster as a deterministic recipe with positive and negative examples.

A useful initial framing grammar:

1. Pick a recognizable answer with at least two independently sourced hooks.
2. Choose one inference operation: connect, identify, sequence, transform, eliminate, or explain.
3. Lead with a surprising but non-unique clue; add a second clue from a different domain; finish before the giveaway becomes trivial.
4. Remove proper nouns or dates that collapse the search space too early.
5. Verify that every clue points to the same canonical answer and record accepted variants.
6. Test on multiple solvers; revise from answer distribution, not only the model's opinion.

Use a model to propose candidates and rewrites, but require deterministic checks and a curator decision before questions enter the playable bank.

### Research and fact sourcing

- The MediaWiki [Parse API](https://www.mediawiki.org/wiki/API%3AParsing_wikitext/en) can retrieve parsed page content, while the [Revisions API](https://www.mediawiki.org/wiki/API%3ARevisions/en) captures the exact page revision used. Preserve revision ID and retrieval date with every generated clue.
- [Wikidata Query Service](https://www.wikidata.org/wiki/Help%3AQueries) accepts SPARQL GET/POST queries and can return structured relationships as JSON, CSV, or TSV. It is useful for finding cross-domain connections, but text/fuzzy search and huge extracts are explicitly not its role.
- Primary references linked from the source pages should be stored alongside the clue. Wikipedia/Wikidata are candidate-discovery and relationship tools, not sufficient proof for every factual premise.

### Question-quality evaluator

Score questions on separate dimensions rather than one opaque number:

- **Correctness/sourceability:** every clue has a retrievable source and stable interpretation.
- **Uniqueness:** clue intersection leads to one answer or an explicit accepted set.
- **Inference value:** solver must connect clues rather than recall a single exposed fact.
- **Progressive reveal:** each sentence meaningfully narrows the space.
- **Fairness:** no arbitrary private association or spelling trick without signaling.
- **Novelty:** not semantically near an existing corpus question.
- **Brevity/readability:** comprehensible when read aloud once.
- **Delight:** the answer creates a satisfying re-interpretation of earlier clues.

Generate adversarial answers using retrieval and a separate critic model. Reject a question if a plausible alternate fits all clues. Maintain version history because editing one clue may invalidate prior play statistics.

### Quiz Poker integration boundary

Quiz Master exports a reviewed versioned JSON pack containing sources, accepted answers, explanations, difficulty, and adjudication notes. [[Quiz Poker]] owns its rules independently. A robust imported round can be:

1. Show category plus a deliberately non-revealing teaser.
2. Players ante or choose `fold / low / medium / high` confidence stakes from a finite stack.
3. Reveal the full question and accept a locked answer.
4. Optionally allow one raise after an additional clue, with a reduced payoff multiplier.
5. Reveal answer, explanation, sources, and alternate-answer ruling.
6. Settle deterministically from the immutable action log.

Quiz Master owns `question`, `question_version`, `source`, and `quiz_pack`; Quiz Poker owns `round`, `player`, `table`, `wager_action`, `answer_submission`, `ruling`, and `ledger_entry`. The pack interface keeps question quality and real-time game reliability independently testable.

### Existing open-source shortcuts and stack

- [Quiz Mate](https://github.com/david-04/quiz-mate) is a lightweight self-hosted browser quiz using Node.js and WebSockets, local JSON quiz files, QR-code joining, timers, answer statistics, and leaderboards. It is an excellent reference or throwaway host for validating question content before implementing Quiz Poker.
- [SIOnline](https://github.com/VladimirKhil/SIOnline) demonstrates a web/desktop trivia client and Tauri packaging.
- Wikimedia APIs and Wikidata supply candidate facts and relationships; local embeddings detect duplicates across the yearbook corpus.

Recommended stack: Python ingestion/analysis scripts; SQLite/DuckDB for the corpus; JSON Schema for questions; a React/Svelte host and player UI; Node/Fastify or FastAPI WebSockets; SQLite event log for personal/LAN games. Use Postgres/Redis only if simultaneous public rooms become real.

### Build sequence and evaluation

1. Import one year's 52 quizzes and manually verify extraction.
2. Annotate 200 representative questions and publish an internal pattern catalog.
3. Build candidate generation plus source capture; run blind human comparisons against held-out real questions.
4. Ship Question of the Day with answer/explanation feedback.
5. Reuse Quiz Mate or a minimal WebSocket room for ordinary live play.
6. Add Quiz Poker action/ledger rules with property-based tests for chip conservation and reconnection.

Track fact-error rate, ambiguous-answer rate, solver success distribution, median solve time, delight/fairness ratings, semantic duplicate rate, and human acceptance of generated drafts. Hold out an entire yearbook from pattern induction and evaluate whether reviewers can distinguish approved generated questions from real held-out questions for the right reasons - quality, not superficial mimicry.

### Simpler alternative

The highest-learning V0 is a **question-workbench CLI and Obsidian review queue**, not multiplayer poker. It imports the corpus, suggests pattern labels, creates sourced candidates, runs ambiguity checks, and exports approved questions as Quiz Mate JSON. Once the question foundry reliably produces good material, the Poker mode becomes a contained real-time game project rather than a content-quality distraction.

---

## Cross-Project Reuse Map

| Shared primitive | Projects using it |
|---|---|
| Browser capture and authenticated source adapters | X Like-to-List Builder; Shortform Signal Digest; Social Subscription Curator; Deliberate Feed Gate; Jobs Upgrade |
| Normalized creator/topic vocabulary | X Like-to-List Builder; Shortform Signal Digest; Social Subscription Curator |
| Explicit preference and review events | Shortform Signal Digest; Social Subscription Curator; Deliberate Feed Gate; Jobs Upgrade |
| Source bundle with dated claims | Quiz Master; Jobs/company preparation |
| Location, route, and map cache | Moving Out Marketplace; Meet-in-the-Middle City Explorer |
| Local event/action ledger | Moving Out Marketplace; Deliberate Feed Gate; Jobs stages; Quiz Poker mode |

## Recommended Build Order

1. Upgrade **Jobs Search and Apply Tool** using official ATS feeds; it has immediate personal utility and a clean, testable pipeline.
2. Build **X Like-to-List Builder** from an archive export; it is bounded, free-first, and produces the first reusable creator/topic taxonomy.
3. Build **Shortform Signal Digest** from manual capture before attempting scheduled authenticated crawling.
4. Use that item store to test **Deliberate Feed Gate**, while building **Social Subscription Curator** against the official YouTube API separately.
5. Run **Quiz Master** as a corpus-analysis workbench before adding its Quiz Poker live mode.
6. Test **Moving Out Marketplace** with one real sale event and a static catalog-first variant.
7. Build **Meet-in-the-Middle City Explorer** as the contained mapping project.

## Research Notes

- Findings were checked against first-party documentation, official project repositories, standards/API references, or the owning product's help center as of 2026-08-14.
- Product APIs, quotas, model requirements, and platform access can change. Each connector should store its documentation URL and last verification date beside its configuration.
- Scope-expansion reminder: before any public release or multi-user automation, review the relevant platform terms, redistribution/model licenses, payment/marketplace duties, safety claims, user-data handling, and consent requirements in [[Scope Expansion Checklist]]. These future checks do not alter the private V0 stack choices in this dossier.
