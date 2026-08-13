# Research — Spatial, Media, and Experimental Ideas

> **Current scope decision:** these are local, single-user prototypes using user-supplied inputs. Rights, redistribution, trademarks, and public-product licensing are recorded only as future reminders under [[Scope Expansion Checklist]] and do not change the recommended personal tech stacks.

_Research date: 27 July 2026. This is product and engineering research, not legal, financial, medical, aviation, or accessibility-professional advice. Platform policies and regulated-market access can change; re-check linked primary sources before a public release or real-world operation._

## Portfolio triage

| Idea | Recommended first build | Verdict |
|---|---|---|
| AR Scale Lens | A native phone app that places a known-length line or rectangle in AR, with optional two-point approximate measurement | **Build**, but never position it as survey-grade |
| Marionettist Utopia | A private fictional-character simulation in a local feed | **Skip the public bot farm; build the private simulator** |
| Live Chess Tutor | A local board against an engine with progressive hints | **Build only in a sandbox or post-game mode** |
| Ambient TV | A pseudo-live channel scheduler for personal Jellyfin media | **Build** |
| Finance Signals Dashboard | Personal watchlist, primary-source event feed, and transparent market observations | **Build and battle-test read-only over one month; skip auto-trading** |
| Drone Mission Mapper | Map editor plus PX4/ArduPilot simulation and mission export | **Build simulator-first; delay real flight control** |
| Field Pokédex | Camera identification shortlist enriched with taxonomy, range, and field notes | **Build** |
| Manga-to-Animatic Studio | Animatics from the user's own or licensed pages and characters | **Build the rights-clean tool; skip franchise adaptation** |
| Song Phrase Mosaic | Phrase montage from owned, CC-licensed, or purpose-recorded audio | **Build rights-clean only** |
| PhoneScan PDF | Local scanner with searchable PDF, dewarp, OCR, and privacy presets | **Build for learning/personal use; weak standalone product moat** |
| Adaptive Vision Glasses | Phone or clip-on electronic magnifier with zoom, contrast, OCR, and TTS | **Skip self-adjusting prescription claims; build the assistive magnifier** |
| Neural Fractal Visualizer | Audio-reactive deterministic shaders; add a small model only when it earns its keep | **Build** |
| Audio Watermark and Perception Lab | Disclosed watermark robustness and ABX perception tests | **Build the transparent lab; skip subliminal manipulation** |
| Yu-Gi-Oh RL Lab | Generic/open card-battler Gymnasium environment, optionally testing an open rules engine | **Skip the GBA ROM dependency** |
| Quiz Poker | Knowledge wagering with points, confidence, bluffing, and private rooms | **Build points-only first** |
| Taxonomy Cluster Explorer | Authoritative taxonomy tree with a separate similarity-clustering overlay | **Build** |

## Cross-cutting boundaries

- **Camera and location privacy:** AR, drones, field identification, scanning, and glasses should process frames locally by default, retain nothing unless the user taps Save, strip EXIF on export unless location is explicitly useful, and make camera activity obvious. India’s [Digital Personal Data Protection Act, 2023](https://www.meity.gov.in/static/uploads/2024/02/Digital-Personal-Data-Protection-Act-2023.pdf) applies to digital personal data processing, and its commencement notifications and implementing rules should be checked before release. Do not add face identification, person lookup, gait/voice identification, or inferred sensitive traits as “bonus” features. The EU’s official definitions make the boundary concrete: comparing faces, voice, gait, or other traits to a reference database for identity is [biometric identification](https://eur-lex.europa.eu/eli/reg/2024/1689/oj?locale=en), while GDPR treats identifying facial images as [biometric personal data](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32016R0679).
- **Local-first is a feature, not just a cost tactic:** raw camera frames, scanned papers, audio corpora, personal media libraries, and model prompts can stay on the workstation/DGX. Synchronize derived metadata or user-selected exports, not the source corpus.
- **Separate research from action:** prediction-market research should not hold keys or place orders; a drone planner should not arm an aircraft by default; a tutor should not attach to a live human chess game; an assistive magnifier should not diagnose or prescribe.
- **Rights ledger:** for every media asset, keep `source_url`, owner, license, permitted uses, attribution, and whether modification/commercial use is allowed. A file being downloadable is not evidence that it is licensed for a montage, model input, or product.

## 1. AR Scale Lens

**Verdict: Build.** The “say 91 cm and see it against the room” mode is easier and more reliable than inferring an unknown dimension from one ordinary photograph. Treat all camera-derived measurements as approximate.

### Verified constraints and useful components

- Apple ARKit exposes `sceneDepth` as distance from the rear camera to real-world areas, but only on supported LiDAR devices; the API also provides confidence information and requires a device-support check ([ARKit sceneDepth](https://developer.apple.com/documentation/arkit/arframe/scenedepth)).
- ARCore Depth combines depth-from-motion with available hardware sensors. Google says best results are roughly 0.5–5 m from the scene, requires device movement, and warns that low-texture surfaces such as white walls are imprecise ([ARCore Depth](https://developers.google.com/ar/develop/depth)). Its frame reference further notes that error grows with distance and depth images may be low resolution ([ARCore Frame](https://developers.google.com/ar/reference/java/com/google/ar/core/Frame)).
- Apple’s own Measure guidance says measurements are approximate and recommends well-defined objects about 0.5–3 m away ([Apple Measure guide](https://support.apple.com/pt-br/guide/iphone/-iphd8ac2cfea/ios)).
- A web prototype can use the [WebXR Hit Test specification](https://www.w3.org/TR/webxr-hit-test-1/), but native ARKit/ARCore gives better capability checks and depth access.

### Feasibility and failure modes

Anchoring a line of a known real-world length is high-feasibility. Two-tap measurement is medium-feasibility. Measuring from one saved 2D photo with no reference object or camera calibration is fundamentally underconstrained: many 3D scenes can produce the same image. Reflective glass, blank walls, moving subjects, poor light, drift, bad plane detection, and long distances produce confident-looking errors. “2,000 sq ft” also needs a shape assumption; an area cannot be represented by one line.

### Much simpler v0

Build a native iOS prototype in SwiftUI + RealityKit/ARKit, or Android in Kotlin + ARCore:

1. Choose a line, rectangle, human-height silhouette, or floor-area shape.
2. Enter a value and units.
3. Tap a surface to anchor it; drag or rotate it.
4. Show a persistent “visual guide, not a certified measurement” label.
5. Add two-tap approximate measurement only after the placement interaction feels good.

### Clever hacks

- Ask for one known dimension (A4 paper, credit card, floor tile) when the user imports a photo; this turns an impossible absolute-scale problem into a solvable projective estimate.
- Show confidence as a range and color, not fake decimal precision.
- For areas, offer canonical shapes: square, 2:1 rectangle, a room outline, or “same area as X tennis courts.”
- Freeze a good tracking frame before the user fine-tunes endpoints; this reduces endpoint jitter.

### Free-first stack and spend trigger

Use SwiftUI + RealityKit/ARKit first if a LiDAR iPhone/iPad is available; otherwise Kotlin + ARCore. Store sessions as small JSON anchor descriptions. A cross-platform Unity/AR Foundation version is justified only after both native prototypes validate demand. Buy LiDAR hardware when comparison testing shows depth materially improves the chosen use case; do not buy it merely to start.

## 2. Marionettist Utopia

**Verdict: Skip the public “bot farm.” Build a private, clearly fictional multi-agent world instead.**

### Verified constraints and useful components

- X prohibits artificial amplification, platform manipulation, deceptive identities, and misleading impersonation ([X Rules](https://help.x.com/en/rules-and-policies/x-rules)). Its automation rules prohibit duplicate automated accounts, substantially similar cross-account posts, automated likes, and bulk/aggressive following ([X automation rules](https://help.x.com/en/rules-and-policies/x-automation)).
- ActivityPub is a W3C Recommendation supporting actors, follows, posts, and federation, including bots and automated processes; it is suitable for a controlled social simulation or transparently labelled bots on a consenting server ([ActivityPub](https://www.w3.org/TR/activitypub/)).
- Copying named fictional characters, their art, or distinctive dialogue into public accounts adds IP risk. India’s Copyright Act defines adaptation broadly and grants owners exclusive rights to reproduce, adapt, and make films or recordings from protected works ([definitions](https://copyright.gov.in/Copyright_Act_1957/chapter_i.html), [exclusive rights](https://copyright.gov.in/Copyright_Act_1957/chapter_iii.html)).

### Feasibility and failure modes

A local feed populated by agents is straightforward. A public farm that follows, replies, or amplifies the user is deceptive manipulation, likely to violate platform rules, and can harm real people through harassment, brigading, misinformation, or accidental disclosure. LLM personas also converge into the same voice, forget facts, develop repetitive loops, and can make defamatory claims. “Based on fictional characters” creates both moderation and rights problems.

### Much simpler v0

Make a local web app called a “character town”:

- Five original personas with explicit AI labels, private memory, hobbies, relationships, and a daily clock.
- A simulated feed, group chat, and story events entirely inside the app.
- No external posting, following, liking, messaging, or account creation.
- An export button for a user-approved scene or summary, never unattended engagement.

### Clever hacks

- Store persona facts in small editable cards instead of asking an LLM to remember everything.
- Generate one shared “world event” and let each persona react from its own values; this produces diversity more cheaply than independent browsing agents.
- Give every claim a provenance tag: world fact, persona belief, joke, or generated fiction.
- Use original archetypes (“retired space mechanic”) rather than copyrighted names or likenesses.

### Free-first stack and spend trigger

Use a local Next.js or SvelteKit UI, SQLite, a cron-like event loop, and llama.cpp/Ollama-compatible local inference. Add an ActivityPub sandbox only if learning federation is itself the goal. Paid models are justified for higher-quality long-form dialogue, not for operating external accounts. If a public bot is ever tested, use one account, disclose that it is automated and fictional in the profile and posts, require human approval, and comply with that platform’s current API and automation policy.

## 3. Live Chess Tutor

**Verdict: Build a local tutor against the computer and a post-game tutor. Never provide engine help during a live game against a human.**

### Verified constraints and useful components

- Lichess prohibits engine, person, opening-book, or tablebase assistance while a game is ongoing, including browser extensions; it permits engines in games played through its Bot API but not to assist a human player ([Lichess Fair Play](https://lichess.org/page/fair-play)).
- Chess.com prohibits engines, software, bots, extensions, automated blunder checking, and outside advice during human games; games against computer bots are outside that rule ([Chess.com Fair Play](https://support.chess.com/en/articles/8568369-what-do-i-need-to-know-about-fair-play-on-chess-com)).
- [Stockfish](https://github.com/official-stockfish/Stockfish) is a strong GPLv3 UCI engine. Distribution requires satisfying its GPL source/license obligations.
- [chess.js](https://github.com/jhlywa/chess.js) provides move generation, validation, check/checkmate, and notation for a lightweight browser board; it is not an evaluation engine.

### Feasibility and failure modes

The engine part is easy; teaching is hard. Dumping the best move and centipawn score trains dependence, not calculation. At low depth the engine may miss tactics; at high depth it can be slow on mobile. LLM explanations can hallucinate lines or contradict the engine. A live overlay can accidentally activate on a human game and become a cheating tool.

### Much simpler v0

Create a local PWA where the user plays Stockfish:

1. The tutor first asks for candidate moves.
2. Hint 1 names the tactical theme or vulnerable square.
3. Hint 2 highlights two candidate pieces, not a destination.
4. Hint 3 shows a forcing line.
5. After the move, compare the user’s idea to the engine line in plain language.

Import a completed PGN for post-game lessons. Do not read browser tabs, screen pixels, or live platform game state.

### Clever hacks

- Derive explanations from engine principal variations plus board facts computed by code; let the LLM verbalize verified facts instead of inventing analysis.
- Match engine strength by time/node limit and deliberate error distribution, not by random bad moves.
- Track recurring motifs (hanging pieces, back-rank, missed forcing moves) and generate a personal lesson queue.
- Add a physical “training mode” banner and disable clipboard/screen integrations while a lesson is active.

### Free-first stack and spend trigger

Use TypeScript, chess.js, a board UI such as Chessground, and Stockfish compiled to WebAssembly/Web Worker. Store PGNs and motif stats in IndexedDB/SQLite. A paid model is justified only for richer explanations after the engine-verification layer is stable. No browser extension is needed for v0.

## 4. Ambient TV

**Verdict: Build personal-media-first. Treat subscription services as launch destinations, not streams to repackage.**

### Verified constraints and useful components

- Jellyfin is a free software media system for organizing and streaming a personal media collection ([Jellyfin introduction](https://jellyfin.org/docs/index.html)); it exposes plugins, metadata, remote control, playback, and segment features suitable for pseudo-live channels ([plugins](https://jellyfin.org/docs/general/server/plugins/), [media segments](https://jellyfin.org/docs/general/server/metadata/media-segments/)).
- The YouTube IFrame Player API can queue and control videos in the official embedded player, subject to minimum player dimensions and embed availability ([IFrame API](https://developers.google.com/youtube/iframe_api_reference)).
- YouTube forbids separating audio/video, modifying the player, background playback, and downloads outside supported experiences ([developer policy guide](https://developers.google.com/youtube/terms/developer-policies-guide)).
- Netflix accounts are for personal, non-commercial use and unauthorized public/commercial viewing violates its terms ([Netflix guidance](https://help.netflix.com/en/node/633853347904100)). There is no general consumer API that lets an aggregator control arbitrary Netflix episode playback.

### Feasibility and failure modes

Scheduling and EPG simulation over owned media is high-feasibility. A seamless “channel” spanning Netflix, YouTube, and other subscriptions is low-feasibility because each service controls authentication, DRM, embeds, autoplay, ads, and deep links. Resume state and episode availability can change. Random playback also becomes frustrating unless the scheduler understands duration, watched status, and tone.

### Much simpler v0

Run Jellyfin and build a local scheduler that creates 3–5 channels from personal media:

- “Comfort Comedy,” “Documentary Hour,” “Music Videos,” and “Random Pilot.”
- A deterministic schedule generated overnight.
- Opening the channel joins the currently airing item at the correct offset.
- An EPG grid and “restart episode” button.

For YouTube, use official embeds and user-created playlists in a separate channel type. For paid streaming, show “Open in service” rather than pretending the content is part of the same player.

### Clever hacks

- Seed the schedule by date so every device sees the same pseudo-live channel without a continuously running transcoder.
- Precompute commercial-like interstitials from owned bumpers, facts, and trailers.
- Use segment metadata to skip intros only when the client permits it.
- Add “serendipity controls”: familiarity, decade, episode length, and no-repeat window.

### Free-first stack and spend trigger

Use Jellyfin, its API, SQLite, a small Node/TypeScript service, and a TV-friendly PWA. An Android TV/Apple TV client is justified only after the schedule logic is delightful in a browser. Paid metadata services or transcoding hardware are justified when the personal library is large enough that matching, artwork, or simultaneous streams become the bottleneck.

## 5. Finance Signals Dashboard

**Verdict: Build urgently as a personal, read-only decision-support dashboard. It should explain what changed in a small watchlist and link to the evidence—not promise “moonshots,” issue buy/sell instructions, or place trades.**

The user chose a modular composition: [[Finance Signals Dashboard]] covers conventional watchlist and macro/company evidence, while [[Event Market Research Terminal]] keeps crypto and prediction-market research in a separate higher-risk module. Both may appear as tabs in [[Personal Finance Cockpit]] and share provenance/data-health primitives, but they keep separate sources, signals, evaluation, and action boundaries.

### Verified constraints and useful components

- For US-listed companies, the SEC’s `data.sec.gov` submissions and XBRL APIs are keyless, update close to dissemination time, and offer nightly bulk archives ([SEC EDGAR APIs](https://www.sec.gov/search-filings/edgar-application-programming-interfaces)). Automated clients must declare a user agent and stay within the SEC’s current maximum of 10 requests/second ([SEC developer FAQ](https://www.sec.gov/about/webmaster-frequently-asked-questions)).
- SEBI maintains a page of official NSE/BSE corporate-filing links for financial results, shareholding patterns, governance reports, voting results, and other disclosures ([SEBI corporate-filings directory](https://www.sebi.gov.in/curation/corporate_filings.html)). These are better evidence inputs than social-media summaries, although page structures and download workflows may still be awkward to automate.
- The RBI’s Database on Indian Economy is an official source for Indian macro and banking time series ([RBI DBIE](https://dbieold.rbi.org.in/DBIE/)). Prefer the official observation and release timestamp over a news article paraphrasing it.
- Polymarket’s Gamma, Data, and CLOB read endpoints can be used without trading authentication; authenticated order placement adds wallet/private-key and API-key layers ([authentication](https://docs.polymarket.com/api-reference/authentication), [fetching markets](https://docs.polymarket.com/market-data/fetching-markets)). Its current geographic restrictions prohibit VPN circumvention ([geographic restrictions](https://help.polymarket.com/en/articles/13364163-geographic-restrictions)).
- Kalshi’s official API supports market data and execution ([Kalshi API](https://docs.kalshi.com/welcome)). The CFTC warns that event contracts carry financial risk and require attention to settlement rules, liquidity, fees, eligibility, and the regulated entity involved ([CFTC prediction-market guide](https://www.cftc.gov/LearnandProtect/PredictionMarkets)).
- Data visible on an exchange website is not automatically free to scrape, store, transform, or republish. NSE’s official policy places restrictions on end-user usage, derived indices, and redistribution and relies on the relevant subscription agreement ([NSE Data Sharing & Usage Policy](https://www.nseindia.com/static/market-data/nse-data-policy)). CoinGecko likewise distinguishes personal/API use from commercial redistribution and offers separate commercial data licences ([CoinGecko terms](https://www.coingecko.com/en/terms), [data-licensing overview](https://www.coingecko.com/en/api/enterprise/data-license)).
- If this remains a private tool, “signals” can simply mean user-defined observations. Turning it into a public or paid recommendation product is a different regulatory project: SEBI states that holding oneself out as a research analyst generally requires registration unless an exemption applies, and public securities opinions carry disclosure duties ([SEBI Research Analysts Regulations announcement](https://www.sebi.gov.in/media/press-releases/nov-2014/commencement-of-sebi-research-analysts-regulations-2014_28475.html)).
- In India, the [Promotion and Regulation of Online Gaming Act, 2025](https://www.meity.gov.in/static/uploads/2025/10/8a7f103cefc68ed8aaa2ebc9a2ed7c13.pdf) prohibits offering, promoting, and facilitating online money games. Obtain qualified local advice before connecting an India-based product to event-market wagering or execution.

### Source and signal design

Use a source-reliability ladder and retain the original URL, retrieval time, and raw payload:

1. **Tier A—binding or first-party:** exchange/company filings, regulator releases, court/government publications, protocol governance votes, audited on-chain events.
2. **Tier B—direct operational evidence:** company investor-relations material, earnings-call transcript/audio, project release notes, repository tags, and status pages.
3. **Tier C—licensed aggregators:** price/volume/reference data whose latency and rights are recorded.
4. **Tier D—commentary:** reputable reporting and research used to discover Tier A/B evidence.
5. **Tier E—social chatter:** an untrusted lead only; never a sole trigger.

A signal card should say: **what changed, compared with what baseline, which source proves it, how stale the observation is, and what could falsify the interpretation**. Separate observations (“volume is 2.1× its 20-session median”) from hypotheses (“possibly event-driven”) and actions. The system should never silently turn an LLM narrative into a trading recommendation.

### Feasibility, drawbacks, and failure modes

A useful personal dashboard is feasible; a dependable profit engine is not a credible prototype objective. Likely failures include:

- Survivorship and hindsight bias from tuning thresholds on the same assets being evaluated.
- Adjusted/unadjusted price confusion, splits, token redenominations, time-zone mismatches, and comparing 24/7 crypto with exchange sessions.
- False alerts caused by illiquidity, stale quotes, data-vendor corrections, or after-hours observations.
- Treating prediction-market price as a calibrated probability despite spread, fees, thin liquidity, participant selection, and ambiguous resolution rules.
- Duplicate news, recycled social posts, manipulation, paid promotion, and LLM-generated causal stories not supported by the source.
- “Free API” assumptions that fail once data is cached, publicly displayed, redistributed, or used commercially.
- Credential and wallet compromise if a later version mixes research with execution.

The dashboard must therefore show provenance and staleness, preserve raw inputs, make thresholds inspectable, and keep execution in a separate codebase and threat model. It is research software, not investment advice.

### Month-one read-only personal beta

Keep the scope deliberately small: 15–30 symbols, one user, daily/end-of-session updates, no brokerage connection, no wallet, and no order button. The first seven days create a thin vertical slice; the remaining weeks are for daily use, data-quality failures, threshold calibration, replay, backup/restore, and regression tests.

**Day 1 — schema and manual baseline**

- Create `assets`, `observations`, `events`, `sources`, `signal_runs`, and `paper_theses` tables in DuckDB.
- Import the watchlist and a broker/vendor CSV export. Record symbol, venue, currency, time zone, and data licence/source for every series.

**Day 2 — reliable inputs**

- Add SEC filings for any US names and saved official SEBI/NSE/BSE filing links for Indian names.
- Add RBI macro releases relevant to the watchlist.
- Add one crypto reference API only if its current terms fit personal local caching.

**Day 3 — transparent signal rules**

- Implement deterministic rules: return versus 20-session volatility, volume versus rolling median, new filing/event, days to earnings/event, source freshness, and watchlist-relative movement.
- Store the threshold and input IDs with every emitted card. No opaque ML ranking yet.

**Day 4 — evidence inbox**

- Build a local Streamlit page with Watchlist, New Evidence, Signal Cards, and Data Health views.
- Every card deep-links to its first-party source and exposes the calculation.

**Day 5 — evidence context**

- Add relevant first-party filings, company notices, and macro release context.
- Keep Polymarket/crypto work in [[Event Market Research Terminal]] rather than coupling it to the urgent conventional-signals path.

**Day 6 — alert hygiene**

- Send a single daily digest through a local notification or email draft. Deduplicate by source/event hash, enforce quiet hours, and require a materiality threshold.
- Add stale-source, missing-session, corporate-action, and rate-limit warnings.

**Day 7 — begin replay and review**

- Replay the previous 60–90 days where data permits. Measure alert count, precision judged by the user, forward-return distributions without implying causation, and forecast Brier score.
- Delete obviously noisy rules. Continue the replay and daily feedback loop through the remainder of the month.

**Weeks 2–4 — battle testing**

- Run every market day, label cards useful/noisy/misleading, and record every corrected or stale source.
- Add fixtures for corporate actions, missing sessions, timezone boundaries, duplicated rows, revised data, and source outages.
- Test reproducible history rebuild, encrypted backup/restore, model-unavailable behavior, and a several-day feature freeze.
- Add no more than one new signal at a time, and require a formula test plus an observation plan.

**MVP acceptance test:** for each signal, the user can reach the primary evidence in one click, reproduce the calculation, see the timestamp/licence class, and dismiss or annotate it. The app can operate for a week without any secret capable of moving money.

### Clever hacks and simpler alternatives

- **Use broker-exported CSVs for prices first.** It avoids fragile scraping and most redistribution issues while proving whether the dashboard changes decisions.
- **Calendar beats prediction.** A deterministic upcoming-events view—earnings, filings, economic releases, unlocks, governance votes—may be more valuable than an AI score.
- Alert on **price move plus new Tier A/B evidence**, or probability change plus liquidity change; suppress movement with no corroborating event unless it crosses a larger threshold.
- Create a “resolution ambiguity” score for event markets and skip questions whose official rules permit materially different interpretations.
- Freeze the evidence set and market price when a thesis is recorded, preventing hindsight edits.
- Compare every complex signal against naive baselines such as buy-and-hold, volatility threshold, and market close. If it cannot beat a simple baseline in decision usefulness, remove it.
- Let the local model classify and summarize only after retrieval; force it to cite source spans and label unsupported causal explanations as hypotheses.
- The simplest useful alternative is an Obsidian daily note generated from official feeds plus a DuckDB script. Build the richer dashboard only if that digest is opened and acted on consistently.

### Free-first stack and spend trigger

Use Python with `httpx`, Pydantic, Polars, DuckDB/Parquet, APScheduler, and Streamlit for the initial vertical slice and month-long dogfooding. Add Plotly for inspectable charts and Great Expectations or lightweight Pydantic checks for source-schema drift. A small local model can classify filings and produce cited summaries; no DGX is needed for numeric rules. Use Git plus timestamped raw-data partitions so any alert can be replayed.

Spend first on **lawfully licensed, reliable market data**, not a larger model. A paid feed becomes justified when manual/broker exports or delayed sources cause missed decisions and its agreement explicitly permits the intended caching, display, derived analytics, and number of users. Paid news is justified only when latency and text-mining rights matter. Public deployment, recommendations, subscriptions, or execution should trigger a fresh legal/licensing review and a separate architecture; adding an API key must never silently turn this research dashboard into a trading bot.

## 6. Drone Mission Mapper

**Verdict: Build a mission designer and simulator. Real autonomous flight is a later hardware, safety, and regulatory phase.**

### Verified constraints and useful components

- India’s official Drone Rules and current DGCA/eGCA/Digital Sky material govern registration, certification, licensing, and airspace. The government’s airspace map defines green/yellow/red zones, notes that the map can change, and requires operators to check it before flight ([DGCA regulations portal](https://www.dgca.gov.in/digigov-portal/?page=civilAviationRequirementPDF), [Digital Sky](https://digitalsky.aai.aero/home), [official airspace-map release](https://www.pib.gov.in/newsite/PrintRelease.aspx?lang=2&reg=48&relid=225084)).
- PX4 supports Software-in-the-Loop and Hardware-in-the-Loop simulation and explicitly recommends simulation as a safe first step ([PX4 simulation](https://docs.px4.io/main/en/simulation/)).
- ArduPilot Mission Planner supports waypoint/fence/rally editing and SITL simulation ([Mission Planner](https://ardupilot.org/planner/), [simulation](https://ardupilot.org/planner/docs/mission-planner-simulation.html)).
- [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs) is an open-source TypeScript map renderer suitable for drawing routes and geofences.

### Feasibility and failure modes

Drawing a route and exporting a MAVLink-compatible mission is feasible. Safe flight execution is much harder: stale airspace data, GPS drift, wrong altitude reference, terrain, obstacles, battery/wind, lost link, compass interference, home-point errors, coordinate-system mistakes, and inappropriate automatic actions can crash an aircraft or injure someone. A vision model such as “locate anything” is not a safety-certified obstacle-avoidance system. Drone video can also capture people and private property.

### Much simpler v0

Build a planner that never arms hardware:

1. Draw waypoints, polygon survey grids, or orbit paths.
2. Validate distance, altitude, speed, estimated time, battery margin, and geofence.
3. Replay it in PX4 or ArduPilot SITL.
4. Inject wind, GPS loss, low battery, and link-loss scenarios.
5. Export a mission file only after the simulation checklist passes.

### Clever hacks

- Use geofences as hard constraints in the route solver, not a warning after generation.
- Record the exact airspace-map timestamp and operator acknowledgement with the mission.
- Use “shadow mode” on real hardware first: compare intended and observed telemetry while the human pilot remains in control.
- Require a separate physical confirmation for upload, and a second confirmation on the flight controller/ground station before arming.
- Blur faces/plates in saved footage by default and avoid biometric identification entirely.

### Free-first stack and spend trigger

Use MapLibre, a TypeScript PWA, GeoJSON, PX4/ArduPilot SITL, Gazebo, and MAVSDK/MAVLink only in simulation. Start with existing Mission Planner/QGroundControl export formats instead of writing a flight stack. Buy a small, legally operable drone and compatible flight controller only after repeated simulator tests, current DGCA compliance review, a safe field, pilot competence, and documented failsafes. Do not test autonomous routes over people, traffic, buildings, animals, or restricted airspace.

## 7. Field Pokédex

**Verdict: Build.** The winning product is an engaging field notebook that presents candidates and evidence, not a voice that confidently declares a species.

### Verified constraints and useful components

- iNaturalist’s API exposes taxon suggestions, search, observations, and taxonomy endpoints ([API v2](https://api.inaturalist.org/v2/docs/)). Its own guidance says image suggestions can fail because models learn typical iNaturalist photos and perform unevenly across species and locations ([computer-vision limitations](https://help.inaturalist.org/en/support/solutions/articles/151000170369-why-can-t-computer-vision-identify-my-photo-correctly-)).
- iNaturalist’s “Expected Nearby” signal uses geographic occurrence expectations to rerank visually similar candidates ([Expected Nearby](https://help.inaturalist.org/en/support/solutions/articles/151000170371-what-does-expected-nearby-mean-)).
- Locations of sensitive species may be obscured or private to reduce poaching and disturbance risk ([iNaturalist sensitive-species geoprivacy](https://help.inaturalist.org/en/support/solutions/articles/151000233080-how-does-inaturalist-protect-the-locations-of-sensitive-species-)).
- Pl@ntNet’s official API returns a ranked list of probable plant species, supports up to five images of the same individual, and exposes confidence scores ([Pl@ntNet identify API](https://my.plantnet.org/doc/api/identify)).
- GBIF provides stable Species and Occurrence APIs, although high-volume searches may be rate-limited and individual datasets retain their own licenses ([GBIF API](https://techdocs.gbif.org/en/openapi/)).

### Feasibility and failure modes

Plants, birds, insects, fungi, and animals require different image cues and taxonomic expertise. Juveniles, seasonal plumage, sexual dimorphism, hybrids, look-alikes, cultivated plants, partial views, and geographic rarity break generic classifiers. Wikipedia-style facts can be stale or uncited. Exact coordinates can expose a user’s home or a vulnerable species.

### Much simpler v0

Make a phone app that:

- Takes 1–3 guided photos (whole organism, diagnostic detail, habitat).
- Returns top five candidates with confidence, nearby-likelihood, diagnostic differences, and “not enough evidence.”
- Links to iNaturalist/GBIF records and asks the user to confirm only at a safe taxonomic rank.
- Saves a local field journal; sharing is opt-in with location precision controls.

### Clever hacks

- Use date, coarse location, habitat, size, and behavior as priors; this often beats a larger vision model.
- Ask one discriminating follow-up question (“leaf arrangement opposite or alternate?”) selected from differences among the top candidates.
- Let users collect “seen,” “photographed,” and “community-confirmed” badges separately.
- Speak in a fun original device voice, but never imitate a copyrighted character voice.

### Free-first stack and spend trigger

Use Expo/React Native or native Kotlin/Swift, a local SQLite journal, iNaturalist/Pl@ntNet for suggestions, and GBIF for taxonomy/range enrichment. Cache thumbnails and derived fields, respecting each image’s license and attribution. A local TFLite/ONNX model is justified for offline coarse classification; paid inference is justified only for difficult image reasoning after the candidate-and-evidence UX works.

## 8. Manga-to-Animatic Studio

**Verdict: Build for user-owned, commissioned, public-domain, or explicitly licensed material. Skip “generate next anime episodes” from commercial manga or mimic a current studio/series.**

### Verified constraints and useful components

- India’s Copyright Act defines adaptation to include rearrangement or alteration and grants owners exclusive rights to reproduce, adapt, communicate, and include artistic works in films ([definitions](https://copyright.gov.in/Copyright_Act_1957/chapter_i.html), [copyright rights](https://copyright.gov.in/Copyright_Act_1957/chapter_iii.html)).
- The U.S. Copyright Office likewise identifies motion-picture versions as derivative works and reserves the preparation of derivative works to the copyright owner ([17 U.S.C. §§101, 106](https://www.copyright.gov/title17/92chap1.html)).
- Blender Grease Pencil supports traditional 2D animation, cut-out animation, motion graphics, and storyboarding ([Blender manual](https://docs.blender.org/manual/en/latest/grease_pencil/introduction.html)).
- [OpenToonz](https://opentoonz.github.io/e/) is a free/open animation package. [ComfyUI](https://github.com/Comfy-Org/ComfyUI) can orchestrate image/video model workflows, but model licenses and training/input rights must be reviewed separately.

### Feasibility and failure modes

Panel segmentation, camera moves, parallax, mouth flaps, simple in-betweening, captions, and scratch audio are feasible. Long-form temporal consistency, exact character identity, hands, occlusion, fight choreography, and lip-sync remain expensive and error-prone. “Understand the current season’s style and generate upcoming episodes” is both technically brittle and a high-risk derivative-work product. Voice cloning adds consent and performer-rights problems.

### Much simpler v0

Build an animatic editor:

1. Import pages the user owns or has permission to adapt.
2. Detect panels and speech bubbles; require confirmation.
3. Place panels on a timeline with pan, zoom, parallax layers, transitions, captions, and temp TTS.
4. Export a low-frame-rate MP4 plus an editable project file.
5. Generate only missing backgrounds/poses for original characters with an asset rights ledger.

### Clever hacks

- Use 2.5D multiplane animation and camera motion before video generation; it is cheaper, editable, and more consistent.
- Turn every panel into a shot card with duration, camera move, dialogue, SFX, and provenance.
- Use image generation for small repair regions or transitional frames, not entire scenes.
- Lock character reference sheets and colors as structured assets rather than repeatedly prompting a model.

### Free-first stack and spend trigger

Use Python/OpenCV for panel extraction, a React timeline, FFmpeg for assembly, Blender Grease Pencil or OpenToonz for manual refinement, and local diffusion/video models through ComfyUI only on rights-clean assets. DGX hardware is justified for iterative local generation. Paid video APIs are justified for a few hero shots after the animatic is approved, not for exploratory full episodes.

## 9. Song Phrase Mosaic

**Verdict: Build only over owned, commissioned, public-domain, or appropriately Creative Commons-licensed recordings. A product that slices commercial songs into new sentences is not a safe default.**

### Verified constraints and useful components

- A musical composition and its sound recording are separate copyrighted works, potentially with different owners ([U.S. Copyright Office](https://www.copyright.gov/register/pa-sr.html)). A phrase mosaic may implicate both.
- India’s Copyright Act grants separate reproduction, adaptation, communication, and sound-recording rights ([Chapter III](https://copyright.gov.in/Copyright_Act_1957/chapter_iii.html)).
- YouTube’s API policy forbids separating or isolating audio, downloading outside supported experiences, and modifying audiovisual content ([YouTube policy guide](https://developers.google.com/youtube/terms/developer-policies-guide)).
- Spotify states that content may not be downloaded or stream-ripped through its API ([Spotify Web API policy note](https://developer.spotify.com/documentation/web-api/reference/get-an-audiobook)).
- Freesound provides Creative Commons audio and an API, but each sound’s license controls use; free API use is non-commercial unless separately licensed ([Freesound API terms](https://freesound.org/help/tos_api/)).

### Feasibility and failure modes

Transcription, forced alignment, indexing, and concatenation are technically feasible. Natural prosody is not: word-boundary clicks, different keys/tempos, background instruments, coarticulation, and missing words create a chaotic result. Very short clips can still be protected; there is no universal “under N seconds is free” rule. Lyrics are also protected text. A public searchable corpus of commercial stems or clips is a rights and storage liability.

### Much simpler v0

Create a “phrase mosaic recorder”:

- The user records or imports a rights-clean vocal corpus.
- Local speech-to-text generates word/phoneme timestamps.
- Type a phrase; the app assembles matching fragments.
- Add crossfades, loudness matching, tempo grouping, and an export license report.

An even safer alternative is a synthetic voice/music “ransom-note singer” generated from a consented voice or purpose-built sample pack.

### Clever hacks

- Index phonemes and syllables, not just words, so unseen phrases can be assembled.
- Choose fragments by neighboring phoneme fit, pitch, tempo, and noise floor.
- Preserve a provenance timeline down to each clip so attribution and deletion are possible.
- Offer an “all one recording session” mode; consistent room tone improves quality dramatically.

### Free-first stack and spend trigger

Use Whisper or another local ASR model, Montreal Forced Aligner/WhisperX-style alignment, librosa, FFmpeg, SQLite FTS, and a waveform editor in the browser. Start with the user’s own voice. Pay for licensed sample libraries or commissioned singers only when public/commercial distribution is planned; do not build around scraped streaming audio.

## 10. PhoneScan PDF

**Verdict: Build as a fast local utility and learning project. Differentiate with privacy, repair, organization, or downstream automation—not the act of scanning alone.**

### Verified constraints and useful components

- Google’s ML Kit Document Scanner supplies a scanning UI, gallery import, multi-page flow, JPEG/PDF results, and dynamically downloaded logic; it requires Android API 21+ and at least 1.7 GB RAM ([ML Kit scanner](https://developers.google.com/ml-kit/vision/doc-scanner/android)).
- Apple VisionKit’s `VNDocumentCameraViewController` provides page-by-page document capture and returns images suitable for PDF export ([VisionKit document camera](https://developer.apple.com/documentation/visionkit/vndocumentcameraviewcontroller)).
- [Tesseract 5](https://tesseract-ocr.github.io/tessdoc/) is Apache-2.0 OCR supporting many languages and scripts.
- [OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) creates searchable PDF/A, deskews/rotates, preserves image resolution when possible, optimizes images, and validates output.

### Feasibility and failure modes

Basic scanning is very feasible and already commoditized. Hard cases include curved book pages, glossy paper, shadows, fingers, handwriting, tables, mixed scripts, faint thermal receipts, huge image-only PDFs, wrong reading order, and OCR text that looks searchable but copies incorrectly. Uploading IDs, bills, tax documents, or medical records to a cloud OCR service creates unnecessary privacy risk.

### Much simpler v0

Use the platform document scanner, then add one excellent local workflow:

- automatic filename from OCR,
- inbox → review → searchable PDF/A,
- local folder/Obsidian export,
- receipt mode with merchant/date/total,
- or book mode with dewarp and two-page split.

### Clever hacks

- Keep the original page image alongside every enhancement so aggressive cleanup is reversible.
- Run fast OCR on-device for naming/search; queue higher-quality OCRmyPDF processing on the desktop.
- Add a “redaction burn-in verifier” that rasterizes the final PDF and confirms the hidden text is gone.
- Use blur/focus and glare scores to request recapture before the user leaves the page.

### Free-first stack and spend trigger

Use native Swift/VisionKit or Kotlin/ML Kit, then a local desktop service with OCRmyPDF/Tesseract for archival output. Flutter/React Native is reasonable for the shell, but native scanner views should do capture. Paid cloud OCR is justified for high-value structured forms or handwriting only after a local benchmark shows the gain and users explicitly consent to upload.

## 11. Adaptive Vision Glasses

**Verdict: Skip “self-adjusting prescription glasses” as a quick build. Build an electronic magnifier or clip-on camera/display aid with an optometrist and accessibility users.**

### Verified constraints and useful components

- The FDA classifies prescription spectacle lenses, magnifying spectacles, and related products as medical devices; even 510(k)-exempt categories remain subject to registration, quality-system, listing, and impact-resistance requirements ([FDA spectacle guidance](https://www.fda.gov/medical-devices/guidance-documents-medical-devices-and-radiation-emitting-products/sunglasses-spectacle-frames-spectacle-lens-and-magnifying-spectacles), [classification database](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfpcd/classification.cfm?life_sustain_support_flag=N&sortcolumn=regulationnumberdesc&start_search=721)).
- FDA focuses oversight on software that turns a general platform into a medical device or controls a body-worn medical device where malfunction poses patient risk ([device software examples](https://www.fda.gov/medical-devices/device-software-functions-including-mobile-medical-applications/examples-device-software-functions-fda-regulates)).
- A simpler consumer baseline already exists: Apple Magnifier supports zoom and visual filters for low vision ([Apple accessibility features](https://support.apple.com/en-us/111779)), and Android provides Magnifier/Lookout and camera-based scene descriptions ([Android accessibility overview](https://support.google.com/accessibility/android/answer/6006564)).
- Digital zoom eventually becomes crop-and-upscale and loses image quality ([AVFoundation zoom](https://developer.apple.com/documentation/avfoundation/avcapturedevice/videozoomfactor)).

### Feasibility and failure modes

Electronic zoom and contrast enhancement are feasible. Dynamically correcting myopia, hyperopia, astigmatism, accommodation, binocular alignment, and different prescriptions per eye is an optics/medical-device problem, not just autofocus. Latency, rolling shutter, display brightness, limited field of view, weight, heat, battery, nausea, vergence-accommodation conflict, image quality, and unsafe obstruction of peripheral vision can make a prototype actively harmful. Incorrect “clarity” may delay eye care.

### Much simpler v0

Build a phone or monocular clip-on low-vision aid:

- optical/digital zoom,
- autofocus lock,
- freeze frame,
- contrast/color modes,
- OCR + text-to-speech,
- large physical controls,
- a conspicuous camera indicator and privacy shutter.

Do not claim to measure a prescription, correct disease, diagnose vision, or make driving safe.

### Clever hacks

- Use OCR and layout reflow instead of extreme magnification for text.
- Switch between wide context and a zoomed inset rather than filling the whole display with a narrow field.
- Allow per-task profiles (reading label, whiteboard, face-to-face conversation) created with the user.
- Process outward-camera video on-device; do not identify faces or infer health/emotion. Save nothing by default.

### Free-first stack and spend trigger

Prototype the interaction with CameraX/AVFoundation and existing phone accessibility APIs. Next, test a phone-in-headset or monocular display with consenting users under professional guidance. Custom liquid lenses, eye tracking, stereo displays, or a wearable enclosure are justified only after a specific assistive task is validated, an optical engineer/optometrist is involved, and the regulatory path and safety testing are budgeted.

## 12. Neural Fractal Visualizer

**Verdict: Build. Start deterministic; a neural model is optional.**

### Verified constraints and useful components

- Web Audio’s `AnalyserNode` provides real-time time-domain and FFT frequency data; larger FFT sizes cost more compute ([Web Audio specification](https://www.w3.org/TR/webaudio-1.1/)).
- WebGPU exposes browser GPU rendering and compute, but remains a developing Candidate Recommendation with uneven runtime support ([WebGPU status](https://www.w3.org/TR/webgpu/all/)).
- ONNX Runtime Web supports WebAssembly broadly; its WebGPU backend has a narrower browser/platform matrix, while WebGL is in maintenance mode ([ONNX Runtime Web](https://onnxruntime.ai/docs/get-started/with-javascript/web.html)).
- WCAG’s flash criterion says content should not flash more than three times in one second unless under defined thresholds, because flashing can trigger seizures, migraines, dizziness, and nausea ([WCAG 2.3.1 explanation](https://www.w3.org/WAI/WCAG22/Understanding/three-flashes-or-below-threshold)).

### Feasibility and failure modes

Audio-reactive fractals, spectral shapes, sacred-geometry motifs, and Winamp-like presets are highly feasible with shaders. A neural network can map audio features to parameters, but it adds latency, nondeterminism, GPU compatibility issues, model load, and little value if it merely approximates beat/FFT rules. Runaway iteration counts, high-DPI canvases, and shader compilation can freeze low-end devices. Rapid luminance changes create accessibility risk.

### Much simpler v0

Build a desktop/browser visualizer with:

- Web Audio FFT, RMS, onset, and band energy.
- GLSL/WebGPU fractal shaders with 10 hand-authored presets.
- A patchable mapping matrix from audio features to shader parameters.
- preset recording and offline MP4 export.
- a reduced-motion/safe-flash mode enabled by default.

### Clever hacks

- Use slowly varying latent state (“mood”) plus fast onset pulses; raw FFT-to-pixel mapping is visually noisy.
- Hash the audio file and preset to make a reproducible visual performance.
- Train a tiny model only to interpolate between hand-designed parameter states or classify sections, not to render pixels.
- Render offline at fixed timestep for clean exports even if the live preview drops frames.

### Free-first stack and spend trigger

Use TypeScript, Web Audio, regl/Three.js or raw WebGL2, then WebGPU as an optional backend. Tauri is a good desktop wrapper; FFmpeg handles export. Use ONNX Runtime Web for a small section/embedding model only after profiling. DGX training is justified for generative preset discovery or audio embeddings, not for v0.

## 13. Audio Watermark and Perception Lab

**Verdict: Build a transparent watermark robustness/perception lab. Do not build covert persuasion or “subliminal” marketing.**

### Verified constraints and useful components

- [AudioSeal](https://github.com/facebookresearch/audioseal) is an MIT-licensed open implementation for localized AI-speech watermark embedding and detection, including a 16-bit message and streaming support.
- Google DeepMind says SynthID embeds inaudible watermarks in its generated audio and is designed to survive common edits, but its consumer integration/detector is not a general open watermark SDK ([SynthID](https://deepmind.google/models/synthid/)).
- C2PA specifies cryptographically signed provenance manifests and supports embedding manifest stores in some downloadable audio containers; provenance and signal watermarks are complementary, not interchangeable ([C2PA specifications](https://spec.c2pa.org/specifications/), [audio-container detail](https://spec.c2pa.org/specifications/specifications/2.0/specs/C2PA_Specification.html)).
- The FTC says embedding subliminal ads intended to affect consumer behavior would be deceptive, and notes that most experts do not find such methods effective ([FTC advertising FAQ](https://www.ftc.gov/business-guidance/resources/advertising-faqs-guide-small-business)). The FCC has historically described subliminal broadcast techniques as deceptive and contrary to the public interest ([FCC statement](https://transition.fcc.gov/Speeches/Tristani/Statements/2001/stgt123.html)).
- WHO’s safe-listening standard uses 80 dB for 40 hours/week as an adult reference exposure and recommends dose tracking and volume limiting ([WHO–ITU safe listening](https://www.who.int/publications/i/item/9789241515276)).

### Feasibility and failure modes

A watermark evaluation bench is feasible. A universal, imperceptible, unremovable watermark is not. Resampling, codec changes, time stretch, pitch shift, clipping, denoising, mixing, analog re-recording, cropping, and adversarial removal trade detection robustness against audible artifacts and false positives. Watermark detection is evidence about a specific scheme, not proof of who created a file. High-frequency or “inaudible” signals can interact with speakers, microphones, animals, and hearing differences; do not equate inaudible with safe.

### Much simpler v0

Build an offline lab for owned/generated speech:

1. Embed an AudioSeal watermark.
2. Apply a declared attack matrix with FFmpeg/SoX.
3. Measure detector true/false positives and payload recovery.
4. Run randomized, level-matched ABX listening tests.
5. Attach a C2PA/sidecar provenance record and compare what survives.

Never hide persuasive, political, commercial, or behavior-changing messages from the listener.

### Clever hacks

- Include unwatermarked “decoy” files in every detector evaluation to expose false positives.
- Calibrate loudness before ABX tests; louder is often perceived as better.
- Separate robustness, perceptual quality, payload capacity, and localization into four dashboards rather than one score.
- Use a signed sidecar hash as the boring baseline; it may solve provenance without altering audio.

### Free-first stack and spend trigger

Use Python, PyTorch, AudioSeal, FFmpeg/SoX, librosa, and a local Streamlit/Gradio experiment UI. Use only headphones/speakers at safe calibrated levels, and include a hard output limiter. DGX compute is justified for controlled attacks or training on rights-clean audio. Paid perceptual labs or professional listeners are justified before making commercial robustness or inaudibility claims.

## 14. Yu-Gi-Oh RL Lab

**Verdict: Do not base the project on a downloaded GBA ROM. Build a generic card-battler RL environment first; optionally evaluate an open rules engine after license and asset review.**

### Verified constraints and useful components

- U.S. preservation exemptions for obsolete video games are narrow: some apply to eligible libraries/archives/museums and restrict distribution and commercial advantage; they are not a blanket permission to download or redistribute ROMs ([37 CFR 201.40](https://www.copyright.gov/title37/201/37cfr201-40.html)). The Copyright Office’s software FAQ also limits archival copies to lawful owners and forbids selling backup copies separately ([digital-files FAQ](https://www.copyright.gov/help/faq/faq-digital.html)).
- Project Ignis EDOPro is an AGPLv3 open-source automated duel simulator powered by an OCG core, but its repository explicitly notes that Yu-Gi-Oh! is a Shueisha/Konami trademark and that dependencies/resources may have different licenses ([EDOPro](https://github.com/edo9300/edopro)).
- Gymnasium documents a standard custom-environment API and validation utilities, including `check_env` ([Gymnasium custom environment](https://gymnasium.farama.org/main/introduction/create_custom_env/)).

### Feasibility and failure modes

A GBA emulator wrapped as pixels/actions is possible but sample-inefficient, slow, partially observable, hard to debug, and entangled with ROM acquisition. Yu-Gi-Oh’s huge action space, long combos, hidden information, changing card pool, rule timing, and sparse reward make naive RL extremely difficult. An agent may learn simulator exploits or degenerate stalling rather than strategy. Packaging card art, text, database, ROM, or trademarks makes an open-source or paid product much riskier.

### Much simpler v0

Create a small original card game:

- 40–100 original/public-domain cards.
- Fully deterministic rules engine and serialized state.
- Gymnasium observations with legal-action masks.
- Scripted opponents, self-play, replay logs, and unit tests.
- PPO/DQN baseline only after random and heuristic baselines pass.

Then adapt the interface to an open duel engine for private experiments with user-supplied legally obtained data, without bundling proprietary assets.

### Clever hacks

- Start with deck-building or tactical subproblems rather than full duels.
- Use action masking and hierarchical actions (card → effect → target) to tame the action space.
- Reward verified intermediate objectives sparingly and report win rate against frozen opponents to catch reward hacking.
- Record every RNG seed and full state transition for deterministic replay.

### Free-first stack and spend trigger

Use Python, Gymnasium, PyTorch, Stable-Baselines3/RLlib, and a pure rules engine. The DGX is justified for parallel self-play after correctness tests, deterministic replays, and strong non-neural baselines exist. Avoid emulators/ROMs and do not distribute card imagery, text, or databases without permission.

## 15. Quiz Poker

**Verdict: Build a points-only party/learning game. Keep money, cash entry, and cash-equivalent prizes out of v0.**

### Verified constraints and useful components

- India’s 2025 online-gaming act prohibits offering and facilitating online money games and their promotion; a knowledge game with deposits or winnings can cross from an educational product into regulated/prohibited territory ([official Act](https://www.meity.gov.in/static/uploads/2025/10/8a7f103cefc68ed8aaa2ebc9a2ed7c13.pdf)).
- Supabase Realtime provides broadcast, presence, and database-change channels suitable for multiplayer game events, with private-channel authorization through Row Level Security ([Realtime](https://supabase.com/docs/guides/realtime), [Broadcast](https://supabase.com/docs/guides/realtime/broadcast)).

### Feasibility and failure modes

A host-controlled room for 4–20 players is straightforward. The design risk is more important than the networking: runaway leaders, players with no chips being unable to recover, collusion, answer leakage, ambiguous questions, latency advantage, host manipulation, and LLM-generated incorrect questions can ruin the game. “Poker” branding may imply gambling even if there is no chance card mechanic.

### Much simpler v0

Build a browser party game:

1. Host creates a room and chooses a verified question pack.
2. Players privately enter an answer and confidence wager from a points budget.
3. Reveal answers; correct players earn according to confidence and difficulty.
4. Include one optional bluff round where players submit plausible wrong answers.
5. No money, deposits, cash-out, purchasable chips, or transferable prizes.

### Clever hacks

- Normalize wagers by remaining stack so new and cautious players stay competitive.
- Give partial credit for ordered/numeric answers using predeclared tolerances.
- Commit answers by hash before reveal to make the event log auditable.
- Use team “insurance” tokens and comeback rounds instead of random rubber-banding.
- Require human-reviewed question packs; if AI drafts questions, store source, accepted answers, aliases, and adjudication notes.

### Free-first stack and spend trigger

Use a responsive TypeScript PWA, Supabase Realtime/Postgres on the free tier or self-hosted PartyKit/Socket.IO, and anonymous room codes. Store the authoritative timer and score on the server. Paid hosting is justified only when concurrent public rooms exceed free limits. Real-money mechanics require a separate legal and compliance decision and are a recommended skip.

## 16. Taxonomy Cluster Explorer

**Verdict: Build, but clearly separate curated biological taxonomy from similarity clusters generated by an algorithm.**

### Verified constraints and useful components

- Catalogue of Life offers current monthly/annual releases, partial taxon downloads, and a Base Release prioritized for expert-scrutinized accuracy; its Extended Release is more complete but may contain integration issues ([COL downloads](https://www.catalogueoflife.org/data/download), [COL metadata](https://www.catalogueoflife.org/data/metadata)).
- GBIF’s Species API works over ChecklistBank and the GBIF Taxonomic Backbone, including name matching, synonyms, parents, children, and multiple checklist usages ([GBIF Species API](https://techdocs.gbif.org/en/openapi/v1/species)).
- NCBI Taxonomy is a curated naming/classification framework for organisms represented in sequence databases, with stable TaxIds, synonyms, API/CLI access, and an approximately phylogenetic hierarchy whose focus is nomenclature/systematics ([NCBI Taxonomy](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/data-processing/taxonomy-processing/taxonomy/)).
- SciPy’s hierarchical `linkage` supports single, complete, average, Ward, and other linkage methods, with important metric constraints and O(n²) memory for common implementations ([SciPy linkage](https://docs.scipy.org/doc/scipy/reference/generated/scipy.cluster.hierarchy.linkage.html)).
- D3 can render nested hierarchical data interactively ([D3 hierarchy](https://d3js.org/d3-hierarchy/hierarchy)).

### Feasibility and failure modes

Exploring an authoritative tree is easy. Inferring “taxonomy” by agglomerative clustering of image or text embeddings is scientifically misleading: visual similarity, ecology, common-name language, and evolutionary relatedness are different distances. Linkage method and embedding choice radically change the dendrogram. Dense all-pairs clustering scales poorly, ties can produce unstable leaf order, and taxonomy sources disagree or update.

### Much simpler v0

Build two synchronized views:

- **Taxonomy view:** authoritative COL/GBIF/NCBI hierarchy with source, version, accepted name, synonyms, and rank.
- **Similarity view:** a clearly labelled experimental dendrogram based on selected features (image, morphology tags, habitat, or text embedding).

Clicking a species highlights its true ancestors and its nearest similarity neighbors so users can see where the two structures agree or diverge.

### Clever hacks

- Let the user switch distance metric/linkage and animate what changes; instability is a learning feature.
- Version the source dataset and preserve taxon IDs, not just names.
- Use coarse taxonomy as a connectivity constraint, then cluster only within a family/order for performance and interpretability.
- Add an “explain this merge” panel showing the features that contributed most, while warning that it is not a phylogenetic claim.

### Free-first stack and spend trigger

Use Python, Polars, SciPy/scikit-learn, DuckDB/Parquet, and D3 in a local web UI. Start with a few hundred taxa and precomputed features; no GPU is needed. DGX inference is justified for generating image/text embeddings across a large rights-clean corpus, not for the clustering itself. Paid biodiversity data is unnecessary until a specific commercial data license or expert-curated source is required.

## Recommended build order for this cluster

1. **Neural Fractal Visualizer** — fastest satisfying result, low external dependency, good GPU/web learning.
2. **PhoneScan PDF** — practical daily utility with a clear local-first workflow.
3. **Taxonomy Cluster Explorer** — strong data/visualization learning and feeds the Field Pokédex.
4. **Field Pokédex** — higher integration effort but a coherent mobile product.
5. **Ambient TV** — valuable if a Jellyfin library already exists.
6. **AR Scale Lens** — good native mobile/AR learning; requires device testing.
7. **Quiz Poker** — easy multiplayer product if there is a group to test with.
8. **Live Chess Tutor** — compelling, but the pedagogy layer deserves careful iteration.
9. **Audio Watermark Lab** — excellent DGX research project with a narrow responsible scope.
10. **Drone Mission Mapper (simulation only)** — worthwhile after the map/simulation toolchain is installed.
11. **Manga-to-Animatic** and **Song Phrase Mosaic** — only after a rights-clean asset corpus is ready.
12. **Adaptive Vision aid** — only with real accessibility users and professional guidance.
13. **Finance Signals Dashboard** — build and battle-test the read-only personal beta urgently; keep [[Event Market Research Terminal]] separate and paper-only.
14. **Yu-Gi-Oh RL concept** — pivot to an original card environment.
15. **Marionettist Utopia** — private simulation only; do not pursue a public follower farm.
