# Research — Personal Systems and Product Ideas

> **Current scope decision:** these are local, single-user prototypes using user-supplied inputs. Rights, redistribution, trademarks, and public-product licensing are recorded only as future reminders under [[Scope Expansion Checklist]] and do not change the recommended personal tech stacks.

> Researched 2026-07-27. This pass covers **21 concepts**: the original 19 plus the later-requested Language Learning and Jobs Search/Apply concepts. “Free” below means no mandatory hosted service at personal scale; it does not mean zero hardware, electricity, domain, app-store, compliance, or maintenance cost.

## Executive recommendation

Do not build 19 separate back ends. Build one local-first **Personal OS** and expose different views:

1. **Capture and state:** Paper Logbook + Measure Life.
2. **Plans and action:** Goal-to-Calendar + NPC Mode.
3. **Agent layer:** Jarvis/Alfred + Motto Agent Council.
4. **Optional companion layer:** Angel/Demon + Parallel Presence.
5. **Publishing and opportunity layer:** Creator Content Engine + Side-Hustle Radar + Personal Library Website.
6. **Money module:** Net Worth Command Center + a narrow, manual-first Paisa Vasool.
7. **Body module:** a non-diagnostic Feedback Mirror + Physio Atlas, fed by Measure Life.
8. **Learning and career layer:** Language Learning + Jobs Search/Apply, sharing the same evidence, review, and scheduling primitives.

Keep GiftShelf payments, event face recognition, universal cross-app extraction, and medical diagnosis outside the first shared platform. Those features introduce liabilities disproportionate to their personal utility.

### A reusable free-first spine

- **UI:** TypeScript + Vite + React or Svelte; install it as a PWA first. A PWA can cache its shell, work offline, and become installable, but OS integrations still vary by browser ([Google’s PWA course](https://web.dev/learn/pwa/welcome)).
- **Local data:** SQLite for desktop/server data; IndexedDB/Dexie in a pure browser build. IndexedDB is designed for substantial structured offline data, while the browser storage model distinguishes best-effort and persistent storage ([IndexedDB specification](https://w3c.github.io/IndexedDB/), [WHATWG Storage Standard](https://storage.spec.whatwg.org/)). Always provide Markdown/JSON/CSV export.
- **Desktop/mobile shell:** Tauri for a small desktop wrapper; Capacitor when camera, notifications, Health Connect, or app-store packaging justify a native shell. Do not wrap the PWA merely to say “app.”
- **Automation:** Python + FastAPI + APScheduler for transparent code; self-hosted n8n when a connector already exists. n8n’s source-available Sustainable Use License is suitable for internal workflows, but it is not an unrestricted basis for reselling a hosted n8n-like product ([n8n license](https://docs.n8n.io/sustainable-use-license/)).
- **Analytics:** DuckDB + Polars for local files and event history; Observable Plot/ECharts for dashboards.
- **Inference:** Ollama for the quickest personal prototype; `llama.cpp` when you want explicit quantization, schema-constrained JSON, and an OpenAI-compatible local server ([llama.cpp server](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)). Move to vLLM on the DGX Spark only when concurrent users or batching—not novelty—demands it.
- **Agent safety:** read-only tools by default; previews for writes; separate “propose” and “execute” steps; append-only audit records; least-privilege OAuth. OAuth’s current best practice requires authorization code + PKCE for public clients and recommends privilege restriction ([RFC 9700](https://datatracker.ietf.org/doc/html/rfc9700)).
- **Sync:** start with one device plus encrypted backups. Add a simple private sync endpoint before a CRDT. Adopt a CRDT only when concurrent offline edits are real; Automerge provides a compact sync protocol but adds data-model and debugging complexity ([Automerge](https://github.com/automerge/automerge)).

### Portfolio triage

| Build band | Ideas |
|---|---|
| **Urgent personal-use build** | Paper Logbook; Goal-to-Calendar; Net Worth Command Center; Paisa Vasool; Language Learning; Jobs Search/Apply |
| **Build next** | Measure Life; Creator Content Engine; Side-Hustle Radar; Personal Library Website; Motto Agent Council |
| **Build as a narrow module** | NPC Mode; Jarvis and Alfred; Parallel Presence; Physio Atlas; Playo Elo |
| **Reframe before building** | Angel and Demon; Feedback Mirror; Any App Widget Maker |
| **Hold/skip current form** | GiftShelf pooled payments; Event Networking Copilot based on face-to-LinkedIn matching |

---

## 1. Paper Logbook

**Verdict: BUILD NOW.** This is a high-utility personal product and a good place to learn offline-first UI, templates, pen input, exports, and later sync.

### Closest building blocks and prior art

- [Excalidraw](https://github.com/excalidraw/excalidraw) is an MIT-licensed, embeddable hand-drawn canvas and demonstrates an open JSON drawing format.
- Web Pointer Events unify mouse, touch, and pen and can expose pressure, tilt, contact geometry, and pointer type ([W3C Pointer Events](https://www.w3.org/TR/pointerevents/)).
- Apple’s PencilKit provides low-latency Pencil/finger capture and serializable `PKDrawing` strokes, but only in Apple-native apps ([PencilKit](https://developer.apple.com/documentation/pencilkit)).
- A PWA plus IndexedDB provides the least expensive cross-platform base. Automerge is a later option for multi-device concurrent edits, not an MVP requirement.

### Feasibility and best product cut

Build a monthly notebook made from reusable blocks: habit checkbox, rating scale, counter, short text, long journal, ink canvas, photo, and computed streak. A template is immutable after instantiation; each month stores a snapshot of its template version. That avoids old pages changing when the user edits next month’s layout.

The hard part is not CRUD. It is making ink, keyboard, touch, page zoom, and template editing coexist without accidental gestures. A web canvas can feel good, but PencilKit-level latency and palm rejection are not guaranteed cross-platform. Treat “paper-like” as a visual/design goal in the PWA and reserve a native iPad client for a later handwriting-heavy version.

### Drawbacks, concerns, and hidden costs

- Browser storage may be evicted; an offline-only journal without exports/backups can lose irreplaceable data.
- Raw pen paths can reveal motor patterns; the Pointer Events specification explicitly notes the privacy implications of pressure, angle, and geometry. Do not collect stable device identifiers or telemetry for ink.
- CRDT synchronization increases payload size, migration complexity, and conflict-debugging work.
- Endless customization can become the product instead of journaling. A template marketplace also creates moderation, copyright, and support work.

### Simpler alternative and clever hacks

Start as a **daily Markdown generator with a form**, not a general notebook engine: template YAML defines fields, and each submission writes one readable Markdown file plus optional SVG ink. Add a printable monthly PDF so the product remains useful even if the app disappears.

Clever shortcuts:

- Store ink as vector strokes and generate a flattened preview lazily.
- Add a “duplicate yesterday, clear checkboxes” action.
- Let every field optionally write a front-matter key so Obsidian/DataView can query it.
- Include one-tap “minimum viable day” templates instead of rewarding only perfect streaks.

### Free-first stack and paid trigger

Vite + React/Svelte, Pointer Events, Dexie/IndexedDB, service worker, local Markdown/JSON export, and optional Excalidraw embedding. Use Capacitor only when native sharing, reliable reminders, or Apple Pencil quality becomes central. Pay for hosted encrypted sync only after the user actively uses at least two devices or loses confidence in manual backup.

---

## 2. NPC Mode Personal Coach

**Verdict: BUILD AS A VIEW OVER THE PERSONAL OS, NOT AS A SEPARATE AGENT.** The useful core is plan-vs-actual reflection; the risky gimmick is an AI-generated “ideal self” that can shame, manipulate, or fabricate.

### Closest building blocks and prior art

- [Habitica](https://github.com/HabitRPG/habitica) is open-source prior art for converting habits and tasks into RPG feedback.
- Google Calendar and Google Tasks already expose supported read/write APIs ([Calendar usage limits](https://developers.google.com/workspace/calendar/api/guides/quota), [Tasks API](https://developers.google.com/workspace/tasks/reference/rest)).
- Reuse the Goal-to-Calendar scheduler in §3. The NPC layer should never have a second task truth.

### Feasibility and best product cut

The MVP needs no avatar generation. Show two timelines:

- **Planned path:** what the user said mattered and what was scheduled.
- **Observed path:** completed, postponed, delegated, automated, or consciously dropped.

At check-in, ask for one reason code rather than guessing psychology. The coach may suggest a smaller next action, surface a blocked prerequisite, or offer to run a pre-approved automation. It must label inferred statements as hypotheses.

### Drawbacks, concerns, and hidden costs

- A normative “ideal self” can create guilt spirals, especially when the model does not know fatigue, illness, caregiving, or changing priorities.
- Avatar/body comparison can drift into appearance scoring and sensitive health inference.
- Calendar access exposes locations, relationships, routines, and future absence from home.
- Agentic task completion creates real-world risk: a prompt-injected email or webpage could cause an assistant to schedule, send, buy, or delete.
- Daily LLM calls add latency and make the product feel needy. The value should survive with the model switched off.

### Simpler alternative and clever hacks

Build “**Ghost Run**”: a deterministic projection that asks, “If I complete the next 25-minute block, where does today land?” No synthetic image and no invented personality. Use XP only for behaviors under the user’s control—starting, asking for help, rescheduling honestly—not outcome perfection.

Clever hacks:

- Generate the ideal timeline from constraints, then let the LLM explain it; do not let the LLM be the scheduler.
- Decay stale goals automatically into a review inbox instead of nagging forever.
- Give the “ideal self” uncertainty bars and a “life happened” override.
- Store every automation as a proposal with preview, scope, and undo information.

### Free-first stack and paid trigger

Use the shared PWA, SQLite event log, Calendar/Tasks connectors, OR-Tools scheduler, and a local 7–14B instruct model via Ollama/llama.cpp. Optional local image generation is entertainment, not core functionality. Pay for a stronger model only when local coaching repeatedly fails on long-context goal decomposition—not for routine reminders.

---

## 3. Goal-to-Calendar Planner

**Verdict: BUILD NOW.** This is one of the clearest, safest, and most reusable projects in the portfolio.

### Closest building blocks and platform facts

- Google Tasks supports creating, moving, patching, listing, and completing tasks through an official REST API ([Tasks API](https://developers.google.com/workspace/tasks/reference/rest)).
- Google Calendar exposes supported event operations and push notifications. As of the research date, standard usage is no-additional-cost under published thresholds, with per-minute and daily limits and planned charging beyond a daily threshold later in 2026 ([Calendar quotas](https://developers.google.com/workspace/calendar/api/guides/quota)).
- Google OR-Tools CP-SAT is a free, open-source constraint solver intended for scheduling and assignment problems ([OR-Tools](https://developers.google.com/optimization), [scheduling example](https://developers.google.com/optimization/scheduling/employee_scheduling)).
- Calendar interoperability is complicated by recurrence, exceptions, time zones, and `VTODO`; the relevant standards are [iCalendar RFC 5545](https://datatracker.ietf.org/doc/html/rfc5545) and [CalDAV RFC 4791](https://datatracker.ietf.org/doc/html/rfc4791).

### Feasibility and best product cut

Separate three jobs:

1. An LLM converts an outcome into candidate milestones and small tasks.
2. Deterministic validation checks that each task has a duration, definition of done, prerequisite, energy level, and deadline.
3. A constraint solver assigns task blocks around fixed events, working hours, buffers, energy preferences, and maximum daily load.

Only write tentative blocks to a dedicated calendar after a diff preview. When a block is missed, reschedule the dependency graph—never duplicate the task.

### Drawbacks, concerns, and hidden costs

- “SMART” text can be syntactically perfect but strategically useless.
- Duration estimates are systematically optimistic. The app needs personal calibration, not generic estimates.
- Recurring events, travel time, split shifts, all-day events, and daylight-saving transitions create edge cases.
- Bidirectional sync needs stable external IDs and idempotency; otherwise each run creates duplicates.
- Public OAuth apps require consent-screen and verification work. Personal/test mode is much easier than a multi-user product.
- Automatic filling of every free minute destroys slack and makes the scheduler oppressive.

### Simpler alternative and clever hacks

First version: accept one goal, generate at most five next actions, and place only the **next two** as tentative blocks. A weekly replanner is usually more valuable than continuous autonomous rearrangement.

Clever hacks:

- Learn an estimate multiplier by task class: `actual / estimated`.
- Reserve 20–30% of usable time as unallocated slack.
- Model “minimum useful session” and “ideal session” durations, allowing 15-minute fallback blocks.
- Put generated blocks in a separate color/calendar so the user can hide or delete the whole plan safely.
- Explain every scheduling choice (“placed after lunch because low-energy/admin”) and expose the violated constraint when no solution exists.

### Free-first stack and paid trigger

Python + FastAPI, OR-Tools, SQLite, Google Calendar/Tasks OAuth, and a simple PWA. Use ICS/CalDAV as the provider-neutral path later. A local model is sufficient for task decomposition; scheduling is deterministic. Pay only when shipping to external users creates OAuth review/support demands or when a managed background worker is needed for reliable push-driven replanning.

---

## 4. Jarvis and Alfred

**Verdict: MERGE INTO ONE ASSISTANT WITH TWO OPERATING MODES.** “Jarvis” can be the proactive analyst; “Alfred” the conservative concierge. Two separate memory stores and permission systems would double risk without adding capability.

### Closest building blocks and platform facts

- Home Assistant’s Assist pipeline already defines the speech-to-text → conversation → intent → text-to-speech stages of a local voice assistant ([Assist pipelines](https://developers.home-assistant.io/docs/voice/pipelines/)).
- Model Context Protocol standardizes tool/resource access. Its HTTP authorization profile builds on OAuth and scope minimization ([MCP authorization](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization)).
- Ollama exposes tool calling for supported local models ([Ollama tool support](https://ollama.com/blog/tool-support)); `llama.cpp` adds schema-constrained output and compatible local endpoints.
- RFC 9700 requires modern OAuth defenses and recommends least privilege and sender-constrained access where appropriate.

### Feasibility and best product cut

Build an **approval-centered command center**, not an always-listening omnipotent agent:

- Read-only morning brief: calendar, tasks, selected feeds, balances already imported locally.
- Proposal inbox: drafts, suggested blocks, file moves, or automation runs.
- Explicit execute button for reversible low-risk actions.
- Separate confirmation for communications, money, deletion, account changes, or anything affecting another person.

Use one identity/memory system with mode-specific tone. Personality must never change permissions.

### Drawbacks, concerns, and hidden costs

- A broadly connected assistant becomes a single point of compromise.
- Stored refresh tokens, microphone history, email, files, and calendar collectively reveal more than any one integration.
- Tool descriptions and retrieved content can contain prompt injection.
- “Proactive” means a background scheduler, retries, deduplication, observability, and quiet hours—not merely another system prompt.
- Voice wake-word quality, streaming STT/TTS latency, microphone hardware, and room acoustics are their own product.
- Self-hosted n8n is convenient but brings upgrades, credentials, backups, and a source-available license boundary.

### Simpler alternative and clever hacks

Start with a keyboard-driven **daily brief + command palette**. Add voice after ten commands are stable and useful.

Clever hacks:

- Every tool has `read`, `propose`, and `commit` variants; the model never receives `commit` until the UI approval.
- Use allow-listed typed arguments instead of arbitrary shell commands.
- Treat web/email content as untrusted data and strip instructions before it reaches the planner.
- Require a fresh, action-specific confirmation token for sensitive commits.
- Keep “Alfred” as the policy gate that may reject “Jarvis” proposals, but implement both as deterministic policy plus one model—not two free-running agents.

### Free-first stack and paid trigger

Python/FastAPI, SQLite audit log, APScheduler, Home Assistant Assist for local voice, MCP adapters, and Ollama/llama.cpp. Add n8n only for connectors that would otherwise take days. Pay for cloud STT/LLM only after measuring that local latency or accuracy blocks a frequently used command; pay for managed secrets/queues when serving users other than yourself.

---

## 5. Angel and Demon Companion

**Verdict: REFRAME AND PROTOTYPE LOCALLY.** Make it a transparent two-perspective reflection tool, not a manipulative moral authority or substitute relationship.

### Closest building blocks and prior art

- [SillyTavern](https://github.com/SillyTavern/SillyTavern) is mature local-first prior art for personas, group chats, lore, TTS, image backends, and multiple local/cloud model APIs.
- Its group-chat/character-card approach shows that most of the perceived product is prompt, memory selection, voice, and presentation rather than a novel model.
- The FTC has opened a formal inquiry into companion chatbots, specifically their effects on children/teens and how companies measure and mitigate harm ([FTC inquiry](https://www.ftc.gov/news-events/news/press-releases/2025/09/ftc-launches-inquiry-ai-chatbots-acting-companions)).
- The EU AI Act prohibits certain manipulative/deceptive techniques that materially distort behavior and cause or are likely to cause significant harm, with extra concern for exploited vulnerabilities ([Regulation (EU) 2024/1689, Article 5](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng)).

### Feasibility and best product cut

Use one factual memory and produce two bounded interpretations:

- **Angel:** values, long-term consequences, compassion.
- **Demon:** temptation, short-term reward, adversarial counterargument.
- **User:** chooses; the app records the choice and later outcome without declaring virtue points as truth.

This is feasible entirely locally. Custom voices and images are optional skins. For a public product, use original characters and voices for which you have rights.

### Drawbacks, concerns, and hidden costs

- The app can intensify self-criticism, dependency, compulsive checking, or delusional framing.
- “Understands your virtues and vices” invites sensitive profiling.
- Anime/show characters and cloned actor voices can implicate copyright, trademark, publicity, and platform rules. The Copyright Office distinguishes an unprotected general character idea/name from protectable original expression; imitating a richly delineated character is not made safe by calling it a persona ([Copyright Office Compendium, ch. 300](https://www.copyright.gov/comp3/chap300/chap300-draft-3-15-19.pdf)).
- Long-term memory can preserve intimate disclosures indefinitely and surface them in the wrong context.
- Safety escalation, age assurance, crisis behavior, and moderation become essential if released publicly.

### Simpler alternative and clever hacks

Build **Two Chairs**: no pet, avatar, relationship language, pushy notifications, or autonomous messages. The user supplies a decision; the system produces the strongest case for and against it, a values check, and a reversible experiment.

Clever hacks:

- Make memory opt-in per fact with visible expiry.
- Add “do not persuade” and “never contact first” switches.
- Generate both perspectives from the same evidence packet, then use a deterministic rubric to check unsupported claims.
- Let the user write the characters’ constitutions; version and diff them.

### Free-first stack and paid trigger

Svelte/React chat UI, SQLite, local embeddings only if retrieval is needed, Ollama/llama.cpp, Piper/Kokoro-class local TTS, and user-supplied/original art. A paid model is justified only when measured adherence to the two constitutions remains poor; paid voices/images are justified only with clear commercial rights. Do not launch to minors in the first product.

---

## 6. Parallel Presence Companions

**Verdict: BUILD THE HUMAN CO-FOCUS PRODUCT FIRST; MERGE AI COMPANIONS WITH §5 LATER.**

### Closest building blocks and platform facts

- WebRTC is the browser standard for real-time media and data, but real deployments still need signaling and NAT traversal through ICE/STUN/TURN ([W3C WebRTC](https://www.w3.org/TR/webrtc/)).
- Jitsi Meet is open source, supports common browsers/mobile, offers SDK/API integration, and can be self-hosted. Its own documentation warns that a reliable HTTPS/certificate setup is non-trivial, especially for phones ([Jitsi overview](https://jitsi.github.io/handbook/), [self-hosting guide](https://jitsi.github.io/handbook/docs/devops-guide/)).
- Matrix is an open federated messaging and VoIP-signaling specification with optional end-to-end encryption and device-level key management ([Matrix specification](https://spec.matrix.org/latest/)).
- SillyTavern already demonstrates local group chat with multiple personas.

### Feasibility and best product cut

Human presence MVP:

1. create a 25/50-minute room;
2. state a task and camera/mic preference;
3. show quiet presence plus start/mid/end check-ins;
4. store only session metadata, not audio/video.

Embed or deep-link Jitsi instead of building WebRTC infrastructure. Add asynchronous “working now” presence before matchmaking. AI presence can be a local ambient coach with no claim of being human.

### Drawbacks, concerns, and hidden costs

- Reliable global video needs TURN bandwidth, regional infrastructure, abuse reporting, moderation, and support.
- Random matching adds harassment, sexual content, minors, identity, and recording-consent risks.
- Recording is unnecessary and vastly increases privacy and storage exposure.
- Fictional-character friends repeat the IP and emotional-dependency concerns from §5.
- Push notifications and background execution vary on mobile; a web-only companion cannot promise timely proactive check-ins.

### Simpler alternative and clever hacks

Start with **Bring Your Own Buddy**: share a room link with a known person. If nobody joins, fall back to a prerecorded neutral workspace or local AI check-ins.

Clever hacks:

- Presence can be a heartbeat/status dot, not video.
- Exchange only task label, focus state, and timer events through WebRTC data channels.
- Offer “camera blurred / hands only / no audio” defaults.
- Use calendar overlap to propose recurring buddy sessions.
- Measure return rate and completed sessions before investing in social discovery.

### Free-first stack and paid trigger

PWA + Jitsi iframe/API for personal use, SQLite/Supabase only for room metadata, and Matrix only if persistent messaging becomes core. Pay for managed Jitsi/LiveKit/TURN when unknown users or mobile reliability appear; that is also the point where moderation and trust-and-safety staffing become a product cost.

---

## 7. Measure Life

**Verdict: BUILD NOW, BUT CALL RESULTS ASSOCIATIONS OR EXPERIMENTS—NOT CAUSES.** This should be the common event and outcomes layer for several other ideas.

### Closest building blocks and platform facts

- [ActivityWatch](https://github.com/ActivityWatch/activitywatch) is open-source prior art for local, privacy-oriented activity tracking and bucketed event data.
- Android Health Connect stores structured health/fitness data on-device and requires granular permissions; Android apps normally get only a limited history window unless they request additional history access ([Health Connect](https://developer.android.com/health-and-fitness/health-connect), [reading history](https://developer.android.com/health-and-fitness/health-connect/read-data)).
- Apple HealthKit also uses per-type consent; Apple forbids using HealthKit data for advertising or selling it to data brokers and requires a privacy policy ([HealthKit privacy](https://developer.apple.com/documentation/healthkit/protecting-user-privacy)).
- A published counterfactual framework for self-tracked N-of-1 time series emphasizes autocorrelation, trends, carryover, and assumptions that must be critically assessed before causal interpretation ([Daza, *Causal Analysis of Self-tracked Time Series Data*](https://pmc.ncbi.nlm.nih.gov/articles/PMC6087468/)).

### Feasibility and best product cut

Let the user define:

- **inputs:** food, caffeine, medicine, activity, environment, social exposure;
- **outcomes:** mood, energy, pain, focus, sleep quality;
- **context:** time, location category, weekday, menstrual cycle if voluntarily entered;
- **hypothesis:** expected direction, lag window, and minimum useful difference.

The first dashboard should show completion, distributions, and lagged associations. The experiment mode can randomize safe, low-risk choices such as morning walk vs no walk; it should not randomize medication or treatment.

### Drawbacks, concerns, and hidden costs

- Confounding, reverse causality, multiple comparisons, missing-not-at-random entries, and novelty effects can produce persuasive nonsense.
- Repeated prompts cause fatigue and biased logging.
- Health data is highly sensitive; combining location, sleep, mood, and food makes re-identification easy.
- Apple and Google integrations require native code, privacy disclosures, permissions, and app-review work.
- Claims about diagnosing, preventing, or treating disease can move software outside “general wellness.” FDA’s 2026 guidance distinguishes low-risk healthy-lifestyle functions from disease-related claims ([FDA general wellness guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices)).

### Simpler alternative and clever hacks

Start with one 10-second evening check-in and one behavior toggle. After two weeks, plot raw days and uncertainty; do not generate conclusions when data completeness is poor.

Clever hacks:

- Schedule prompts at randomly jittered times to reduce routine-answer bias.
- Pre-register a hypothesis before showing a correlation.
- Require a minimum number of exposed/unexposed days and hold out recent data for confirmation.
- Show “what would change my mind?” and likely confounders beside every insight.
- Export a tidy CSV with a data dictionary so analysis is reproducible outside the app.

### Free-first stack and paid trigger

PWA + IndexedDB for manual logging; Python/FastAPI + SQLite/DuckDB + Polars for analysis; Observable Plot/ECharts for timelines; optional local LLM only to turn findings into plain language. Add Health Connect/HealthKit via Capacitor/native modules after daily manual use proves value. Pay for encrypted cross-device sync only after multi-device capture is a persistent need, and never monetize through health-targeted advertising.

---

## 8. Feedback Mirror

**Verdict: REFRAME. BUILD A CONSISTENT SELFIE/Routine JOURNAL; SKIP AUTOMATED SLEEP OR SKIN DIAGNOSIS.**

### Closest building blocks and platform facts

- MediaPipe Face Landmarker can detect face landmarks and facial-expression-related blendshape scores on device; it is a geometry building block, not a dermatology or sleep diagnostic ([Google AI Edge Face Landmarker](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker)).
- Browser camera capture requires explicit permission and a secure context ([W3C Media Capture and Streams](https://www.w3.org/TR/mediacapture-streams/)).
- Illinois BIPA, one example of biometric regulation, expressly includes scans of face geometry in its biometric-identifier definition ([Illinois Public Act 103-0769](https://ilga.gov/Legislation/publicacts/view/103-0769)).
- Patient-specific diagnostic outputs can fall within medical-device oversight; FDA distinguishes general logging/education from predictive or diagnostic software functions ([FDA clinical decision support guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/clinical-decision-support-software), [SaMD overview](https://www.fda.gov/medical-devices/digital-health-center-excellence/software-medical-device-samd)).

### Feasibility and safe product cut

A phone or mirror-mounted camera can reliably help with **capture consistency**: face alignment, approximate distance, lighting warnings, blur detection, timestamp, and side-by-side comparison. It can ask the user to rate sleep, hydration, irritation, or perceived skin condition and correlate those self-reports with routines in Measure Life.

It cannot infer last night’s sleep quality from one morning image with clinically defensible accuracy. “Looks tired” is a subjective appearance judgment, not a sleep measurement. Skin disease classification from consumer cameras requires representative labeled data, prospective validation, calibration, and clinical governance. Historical smartphone melanoma apps showed highly variable sensitivity, with three of four tested apps misclassifying at least 30% of melanomas as unconcerning ([diagnostic accuracy study](https://pmc.ncbi.nlm.nih.gov/articles/PMC4019431/)).

### Drawbacks, concerns, and hidden costs

- Faces plus daily timestamps create biometric and health-adjacent data. A breach is more consequential than losing a habit log.
- Illumination, white balance, focal length, makeup, camera processing, and angle dominate subtle visual changes.
- Performance can vary across demographic groups. The primary Gender Shades audit found intersectional accuracy disparities in commercial face-analysis systems ([paper](https://proceedings.mlr.press/v81/buolamwini18a/buolamwini18a.pdf)); dermatology AI can also preserve gaps even when overall accuracy improves ([Nature Medicine study](https://www.nature.com/articles/s41591-023-02728-3)).
- Appearance scores can worsen body image or create false reassurance.
- Public release needs consent/retention/deletion design and jurisdiction-specific biometric review before collection—not after.

### Simpler alternative and clever hacks

Build **Mirror Journal**:

- guide the user into the same pose, distance, room, and diffuse light;
- compute only image-quality and alignment metrics;
- show an unscored weekly contact sheet;
- keep user-entered tags such as “itchy,” “dry,” or “poor sleep” separate from image-derived facts;
- let the user export selected images for a clinician.

Clever hacks:

- Print a small neutral color/size reference card and include it in frame for rough lighting/scale normalization.
- Crop and encrypt locally; discard raw video frames immediately.
- Use face landmarks only ephemerally and store neither a face embedding nor identity template.
- Trigger a generic “consider professional evaluation” message from user-reported red flags, never a model’s diagnosis.

### Free-first stack and paid trigger

Capacitor/native camera shell, MediaPipe on device, encrypted app storage, SQLite metadata, and integration with Measure Life. No cloud inference in v1. Pay only for a clinician-reviewed telehealth workflow or for validated, licensed medical models after deciding to take on medical-device and biometric compliance. A generic multimodal LLM is not that upgrade.

---

## 9. Physio Atlas

**Verdict: BUILD A PERSONAL EXERCISE LIBRARY AND ADHERENCE TRACKER; HOLD FORM SCORING AND TREATMENT RECOMMENDATIONS.**

### Closest building blocks and platform facts

- MediaPipe Pose Landmarker provides on-device body landmarks and is suitable for visual overlays and coarse repetition/movement features ([Pose Landmarker API](https://ai.google.dev/edge/api/mediapipe/python/mp/tasks/vision/PoseLandmarker)).
- FDA’s policy generally treats simple organization, education, and low-risk wellness differently from diagnosis/treatment software, but patient-specific treatment directives can be regulated ([general wellness guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices), [mobile medical-app policy](https://www.fda.gov/medical-devices/digital-health-center-excellence/device-software-functions-including-mobile-medical-applications)).
- YouTube’s policies prohibit API clients from downloading, caching, separating, or offering offline copies of audiovisual content without approval; embedded playback must preserve the standard experience ([YouTube developer-policy guide](https://developers.google.com/youtube/terms/developer-policies-guide)).

### Feasibility and best product cut

Create a body map as a navigation aid—not as a diagnosis engine. Each exercise record stores:

- user/therapist-supplied reason;
- body region, equipment, side, regressions/progressions;
- dosage prescribed by the user’s clinician;
- contraindication notes copied verbatim from that plan;
- source link or user-owned clip;
- completion, pain-before, pain-after, and next-day response.

The app can remind, count time/reps, and produce a report for the physiotherapist. It should not choose an exercise because the user tapped a painful muscle.

### Drawbacks, concerns, and hidden costs

- Pain location does not uniquely identify pathology; a “muscle wiki” interaction can imply a false diagnosis.
- 2D pose landmarks cannot see load, joint rotation, depth, pain, surgical restrictions, or compensations reliably.
- “Correct form” varies by injury, mobility, clinician intent, camera angle, and exercise variant.
- Downloading Shorts/Reels/TikToks introduces terms and copyright risk. Instagram does not offer a general public “read all my saved posts” API suitable for this product.
- Exercise videos, descriptions, and anatomical art require licenses and versioned clinical review.
- A user following an unsafe recommendation can be harmed, so disclaimers are not a substitute for product boundaries.

### Simpler alternative and clever hacks

Build **Therapist Card Deck**: the user or therapist creates a plan by pasting links and recording dosage. The body atlas merely filters a personal library. A weekly PDF shows adherence and symptom response.

Clever hacks:

- Store source URL, thumbnail where permitted, timestamps, and personal notes; embed rather than download.
- Let the user trim **their own** recording into a private demonstration clip.
- For pose, show landmarks as a recording/framing aid first. Do not output pass/fail.
- Record “stop reasons” and next-day flare-ups; those are often more useful to a therapist than gamified streaks.
- Add an emergency/red-flag education page sourced and reviewed separately, with no automated triage.

### Free-first stack and paid trigger

PWA/Capacitor, SVG anatomical map, SQLite, local files for user-owned media, YouTube embeds, and optional on-device MediaPipe. Integrate Measure Life for pain/response time series. Pay for licensed exercise content and clinician review before selling; pay for validated motion analysis only if a defined clinical use case and evidence plan exist.

---

## 10. Creator Content Engine

**Verdict: BUILD NOW AS A HUMAN-IN-THE-LOOP CONTENT PIPELINE. DO NOT BUILD FOLLOWER AUTOMATION.**

### Closest building blocks and platform facts

- n8n Community Edition can orchestrate internal workflows; its Sustainable Use License matters if the workflow itself becomes a commercial service ([license](https://docs.n8n.io/sustainable-use-license/)).
- WordPress has an official JSON REST API and `POST /wp/v2/posts` can create drafts, scheduled posts, or published posts ([Posts endpoint](https://developer.wordpress.org/rest-api/reference/posts/)).
- YouTube Data API operations have quotas whose costs and allocations can change, so a product must consult the current quota calculator and revision history rather than hard-code assumptions ([quota calculator](https://developers.google.com/youtube/v3/determine_quota_cost), [revision history](https://developers.google.com/youtube/v3/revision_history)).
- X requires official API use, explicit informed consent for actions, preview of what will be posted, bot disclosure where applicable, and prohibits bulk/aggressive actions and substantially identical cross-account posts ([X Developer Policy](https://docs.x.com/developer-terms/policy), [restricted uses](https://docs.x.com/developer-terms/restricted-use-cases)).
- YouTube also prohibits downloading audiovisual content through an API client and imposes display/playback/aggregation rules ([YouTube policies](https://developers.google.com/youtube/terms/developer-policies)).

### Feasibility and best product cut

Build a content supply chain:

1. capture owned notes, RSS items, transcripts you are authorized to use, and research links;
2. extract claims with source URLs and quote limits;
3. cluster into durable themes;
4. create a “content brief” with audience, promise, evidence, counterpoint, and call to action;
5. draft platform-specific variants;
6. require human edit/approval;
7. publish or schedule through supported APIs;
8. import performance data only for your own accounts and record what changed.

The durable asset is the source-backed brief and canonical article, not a pile of generated tweets.

### Drawbacks, concerns, and hidden costs

- Automatic content quickly becomes generic, repetitive, factually wrong, or off-brand.
- Republishing summaries, images, clips, and transcripts can violate copyright or platform terms even if generated by an LLM.
- X access, pricing, rules, and rate limits are platform dependencies; non-API browser automation risks account enforcement.
- Public OAuth apps, token security, deletion compliance, and user support are real product work.
- YouTube upload, thumbnails, captions, analytics, and copyright checks are separate workflows.
- A/B testing can optimize shallow engagement and damage the long-term voice the tool is meant to build.

### Simpler alternative and clever hacks

Start with **one weekly evidence-backed essay → five manually approved derivatives**. Output Markdown and a review queue; paste manually into platforms until publishing is the actual bottleneck.

Clever hacks:

- Maintain a “claim ledger” containing claim, source, date checked, and reuse rights.
- Save the user’s edit diff and learn style rules from accepted changes rather than asking a model to impersonate a vague “human tone.”
- Penalize duplicate semantic content across the last 30 posts.
- Generate three hooks but only one full draft, saving tokens and review time.
- Use an evergreen/topic-decay score so the engine resurfaces durable ideas instead of chasing every trend.
- Keep analytics experiments small and pre-declared (“question hook vs observation hook”), with no automated follower/engagement actions.

### Free-first stack and paid trigger

FreshRSS + n8n/Python, SQLite, local embeddings, Markdown/Obsidian, a local model for clustering and first drafts, and WordPress REST for drafts. Use official X/YouTube APIs only after manual posting proves a cadence. Pay for proprietary models when factual/style evaluations beat the local model enough to save editing time; pay for API plans only when publishing/analytics throughput—not follower growth fantasy—justifies them.

---

## 11. Side-Hustle Radar

**Verdict: BUILD NOW AS AN EVIDENCE RADAR, NOT AN “AI BUSINESS IDEA” GENERATOR.**

### Closest building blocks and platform facts

- Reddit’s Data API terms govern API data, require compliance with developer/user terms, and require a privacy policy describing collection, use, storage, and disclosure for an app ([Reddit Data API Terms](https://redditinc.com/policies/data-api-terms)).
- Hacker News publishes an official near-real-time Firebase API; it exposes stories, comments, jobs, and rankings and currently documents no rate limit, while warning that its data model is intentionally low-level ([official HN API](https://github.com/HackerNews/API)).
- Google provides an official Google Trends BigQuery dataset containing anonymized, indexed, normalized, aggregated top and rising queries, but it is a constrained dataset—not a general unsupported scraping API ([Trends BigQuery dataset](https://support.google.com/trends/answer/12764470)).
- RSS feeds, public issue trackers, app reviews exported by their owners, and manually supplied communities are safer starting inputs than broad scraping.

### Feasibility and best product cut

Track **problem evidence**, not “side-hustle” claims:

- repeated complaint/job-to-be-done;
- who experiences it;
- frequency and recency;
- existing workaround;
- stated willingness to pay or time currently spent;
- reachable distribution channel;
- legal/platform dependency;
- smallest validation experiment.

The model clusters and labels evidence; the user decides whether a cluster is an opportunity. Each opportunity card links back to verbatim source posts within allowed quotation/storage rules.

### Drawbacks, concerns, and hidden costs

- Social chatter overrepresents vocal communities and can be astroturfed.
- Popular complaints may have no budget, impossible distribution, or entrenched competitors.
- Reddit and other platform licensing/access can change; bulk archival and model training may require separate permission.
- Inferring sensitive traits or targeting vulnerable users is unethical and can breach platform policies.
- LLM novelty scores are unstable and favor well-worded noise.
- A dashboard can become procrastination disguised as market research.

### Simpler alternative and clever hacks

Start with **three subreddits/feeds + HN Ask/Show + one weekly digest**. Require the user to interview or message three potential users before an idea can move from “signal” to “validated.”

Clever hacks:

- Use a “pain × frequency × spend × reachability ÷ dependency” rubric with evidence confidence.
- Deduplicate by semantic cluster but preserve dissenting comments.
- Track workaround verbs: “I manually…,” “spreadsheet,” “copy/paste,” “every week,” and “would pay.”
- Compare a problem’s growth against its own baseline, not raw mention volume.
- Add a kill criterion and a 48-hour validation task to every card.
- Feed successful/failed experiments back into ranking; do not train only on clicks.

### Free-first stack and paid trigger

Python collectors, SQLite/DuckDB, FreshRSS, official HN and permitted Reddit access, sentence-transformer embeddings on the DGX, BERTopic/HDBSCAN or simple nearest-neighbor clustering, and a static weekly Markdown report. Pay for a licensed social-data provider only after a validated business depends on broader coverage; pay for an LLM only for high-value synthesis after local clustering has reduced the corpus.

---

## 12. Net Worth Command Center

**Verdict: BUILD MANUAL-FIRST FOR PERSONAL USE. PRODUCTIZE ONLY AS TRACKING/EDUCATION UNLESS YOU ARE PREPARED FOR FINANCIAL REGULATION AND DATA SECURITY.**

### Closest building blocks and platform facts

- [Actual Budget](https://github.com/actualbudget/actual) and [Firefly III](https://github.com/firefly-iii/firefly-iii) are open-source prior art for local/self-hosted personal finance and transaction categorization.
- India’s Account Aggregator framework is regulated: an AA is an RBI-regulated NBFC that retrieves, consolidates, organizes, and presents customer financial information under a consent artefact; financial information is not the AA’s property and cannot be used arbitrarily ([RBI NBFC-AA Master Direction](https://systemhealth.rbi.org.in/Scripts/BS_ViewMasDirections.aspx_id%3D10598%281%29.html), [AA technical specifications](https://rbi.org.in/Scripts/NotificationUser.aspx?Id=11729&Mode=0)).
- India’s official All India Debt and Investment Survey contains household asset/liability statistics, but its survey date and definitions matter; the 2019 round covered 116,461 sampled households and measured assets as of 2018-06-30 ([MoSPI press note](https://mospi.gov.in/sites/default/files/press_release/press_note-AIDIS-240821.pdf), [report](https://www.mospi.gov.in/sites/default/files/publication_reports/Report_no588-AIDIS-77R-SeptFinal_0.pdf)).
- Personalized investment advice for consideration is regulated in India; SEBI’s current Investment Adviser regulations and guidance require registration/obligations for covered activity ([SEBI regulations](https://www.sebi.gov.in/legal/regulations/dec-2024/securities-and-exchange-board-of-india-investment-advisers-regulations-2013-last-amended-on-december-16-2024-_90151.html)).

### Feasibility and best product cut

Build a balance-sheet ledger:

- assets/liabilities with owner, institution, currency, valuation source/date, liquidity, and confidence;
- snapshots rather than overwritten current values;
- import adapters for CSV/OFX plus manual valuation;
- allocation, cash runway, debt schedule, concentration, and goal progress;
- reconciliation that explains changes as contributions, withdrawals, price movement, FX, or corrections.

“Total compensation” should be a separate employment dashboard; unvested equity should be scenario-valued, not silently added to liquid net worth.

### Drawbacks, concerns, and hidden costs

- Financial credentials and statements are high-value breach targets. Never screen-scrape bank logins or ask users to forward passwords.
- Account Aggregator access is not “a free bank API”; a consumer product needs an eligible/contracted ecosystem role and compliance.
- Asset prices, private company equity, real estate, tax liabilities, and vested/unvested compensation have different valuation uncertainty.
- A percentile leaderboard can be misleading because survey year, unit (individual vs household), geography, age, urban/rural status, and asset definitions differ.
- “Find a mentor among similar wealthy people” creates privacy, fraud, solicitation, and suitability concerns.
- Recommendations on securities, allocation, or personalized financial planning can cross into regulated advice. Calling it “AI analysis” does not change the substance.

### Simpler alternative and clever hacks

Start as an encrypted **quarterly snapshot notebook**. Import statements/CSVs locally, reconcile to the previous snapshot, and produce a one-page report. Do not connect live institutions until the workflow survives a year.

Clever hacks:

- Give every number `as_of`, source, currency, and confidence.
- Separate **known**, **estimated**, and **excluded** totals.
- Show stale-value warnings rather than pretending the dashboard is live.
- Store cost basis and tax lots separately from market value.
- Benchmark only against a named, dated dataset and show a range, never a definitive “you are top X%.”
- Use scenario sliders for equity/real estate rather than one false-precision valuation.

### Free-first stack and paid trigger

Fork/configure Actual Budget or use Python + SQLite/DuckDB + a local dashboard; encrypt disks/backups; ingest CSV/OFX; use scheduled price retrieval only from licensed sources. Pay for Account Aggregator connectivity after a secure manual product has repeat usage and the legal role/contracts are clear. Hire financial/regulatory counsel before charging for personalized recommendations or mentor matching.

---

## 13. Paisa Vasool Subscriptions

**Verdict: BUILD A MANUAL/RECEIPT-ASSISTED MODULE INSIDE THE MONEY PRODUCT. DO NOT PROMISE UNIVERSAL DETECTION OR ONE-CLICK CANCELLATION.**

### Closest building blocks and platform facts

- Apple’s App Store Server API lets a developer inspect subscriptions **for that developer’s app**, not every subscription in a user’s Apple account ([App Store Server API](https://developer.apple.com/documentation/appstoreserverapi), [Get All Subscription Statuses](https://developer.apple.com/documentation/appstoreserverapi/get-all-subscription-statuses)).
- Likewise, Google Play’s Publisher API exposes purchase state for the calling developer’s package/purchase tokens, not a consumer-wide list of unrelated subscriptions ([Google Play subscriptions resource](https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2)).
- Gmail read access uses restricted OAuth scopes; a public app using server-side restricted-scope data can require verification and a security assessment ([Gmail scopes](https://developers.google.com/workspace/gmail/api/auth/scopes)).
- Google Play directs users to its own subscription center and warns that uninstalling an app does not cancel its subscription ([Google Play cancellation help](https://support.google.com/googleplay/answer/7018481)).

### Feasibility and best product cut

Maintain a subscription registry with merchant, plan, amount, cadence, payment account, renewal date, cancellation URL, expected usage/value, and evidence source. Import candidates from:

- user-approved bank CSV/AA transaction stream;
- forwarded receipts or a local mailbox export;
- App Store/Play receipts the user explicitly shares;
- manual entry.

The app proposes recurring-merchant clusters and asks the user to confirm. “Paisa vasool” should mean a user-defined value check—usage, outcomes, or replacement cost—not a model’s opaque score.

### Drawbacks, concerns, and hidden costs

- Transaction names are noisy; annual plans, installments, utilities, rent, and family transfers can look recurring.
- No cross-platform API provides a universal subscription inventory.
- Cancellation flows vary by merchant, geography, commitment term, app store, and payment method; automated browser cancellation is brittle and risky.
- Reading a whole mailbox to find a few receipts is disproportionate, and public Gmail verification can be expensive and slow.
- The app may expose intimate purchases or shared-family services.
- Incorrectly flagging a critical service as unused can cause loss of data, insurance, connectivity, or business access.

### Simpler alternative and clever hacks

Build **Renewal Calendar**: the user forwards a receipt to a dedicated local parser or drops a PDF/email file. The app extracts a draft record, schedules a review seven days before renewal, and deep-links to the official cancellation page.

Clever hacks:

- Detect recurrence from amount/date tolerance but require two or three occurrences and user confirmation.
- Store a screenshot/PDF of cancellation confirmation and final service date.
- Ask “Would you buy this again today?” monthly; it is a better value signal than guessed usage.
- Divide annual cost by user-entered meaningful uses, but show both annual cash outlay and per-use figure.
- Add a “downgrade/pause/share legitimately” option before cancellation.

### Free-first stack and paid trigger

Integrate into the Net Worth stack: local CSV parser, SQLite, receipt extraction with OCR/local model, and calendar reminders. Avoid Gmail OAuth in a public MVP. Pay for Account Aggregator data only when manual imports are the limiting factor; pay for merchant cancellation partners only after coverage and liability are contractually clear.

---

## 14. GiftShelf

**Verdict: BUILD THE WISHLIST AND RESERVATION PRODUCT; SKIP CUSTODY, POOLED PAYMENTS, AND “TAX-FREE DONATION” CLAIMS.**

### Closest building blocks and platform facts

- Razorpay Route can split incoming payments among linked accounts, but linked accounts require bank details and verification; it is a marketplace/payout product, not a free personal “pool” primitive ([Razorpay linked accounts](https://razorpay.com/docs/payments/route/linked-account/), [transfers](https://razorpay.com/docs/payments/route/transfer-funds-to-linked-accounts/)).
- Stripe Connect’s separate-charges-and-transfers flow makes the platform responsible for fees, refunds, and chargebacks. Its current supported-region list for that flow does not include India ([Stripe separate charges and transfers](https://docs.stripe.com/connect/separate-charges-and-transfers), [refund and dispute responsibilities](https://docs.stripe.com/connect/marketplace/tasks/refunds-disputes)).
- A hosted payment link can collect a payment, but it does not solve escrow, conditional release, multiple contributor accounting, refund allocation, or marketplace onboarding.

### Feasibility and best product cut

The valuable first product is a private, shareable gift registry:

- canonical item with title, image, merchant URL, expected price, variant, priority, and occasion;
- “I will get this” reservation that can be anonymous to the recipient but visible to other invited contributors;
- optional quantity, alternatives, second-hand acceptance, and “ask me first” status;
- direct checkout at the merchant or a direct payment link owned by the recipient;
- contribution **pledges**, not money held by the app.

This solves duplicate gifts and makes intent legible without becoming a payment intermediary. It can later support verified merchants or regulated payment partners, but only as a separate business phase.

### Drawbacks, concerns, and hidden costs

- Holding money or deciding when it is released introduces KYC, AML, merchant-of-record, refund, dispute, reconciliation, dormant-balance, fraud, and possibly escrow/regulatory obligations.
- In a split-payment model, the platform can remain liable when a connected recipient has already received money and a payer disputes the charge.
- “Not taxable donation” is unsafe positioning. Tax treatment depends on jurisdiction, relationship, amount, occasion, and whether the transfer is genuinely a gift; the software cannot manufacture the legal character of a payment.
- Product links rot, prices change, variants sell out, and scraped merchant pages often prohibit or resist automated extraction.
- Public wishlists can reveal address, family relationships, pregnancy, health needs, children, wealth, travel, and when a home may be vacant.
- Showing who contributed and how much can create social pressure. Anonymous pledges need abuse controls.

### Simpler alternative and clever hacks

Ship **GiftShelf Lite**: paste a URL, let the user correct extracted metadata, share with a secret link, and let invitees reserve or pledge. Checkout stays on the merchant’s site.

Clever hacks:

- Generate a “buying brief” containing the exact variant, delivery deadline, acceptable substitutes, and recipient-safe shipping instructions.
- Use a three-state reservation: available, tentatively claimed, purchased. Auto-expire tentative claims.
- Hide contributor identity and amount from the recipient until the occasion, while showing only aggregate progress.
- Allow a cash-equivalent item to link directly to the recipient’s own approved payment page; never route it through the GiftShelf account.
- Keep address out of the shared page. Reveal it only after an invitee confirms purchase, or use the merchant’s gift-address facility.

### Free-first stack and paid trigger

Use a small PWA with TypeScript, SQLite/Postgres, signed share tokens, metadata extraction on paste, and object storage only for user-uploaded images. Static or server-rendered public pages are sufficient. Add authentication only for list owners; invitees can use expiring capability links. Pay for transactional email and managed storage when sharing grows. Add integrated payments only after choosing a supported country, processor program, legal entity, refund policy, and counsel-reviewed funds flow.

---

## 15. Personal Library Website

**Verdict: BUILD NOW. IT IS A LOW-RISK, HIGH-LEARNING STATIC PRODUCT AND A NATURAL BLOG SURFACE.**

### Closest building blocks and platform facts

- Open Library exposes search, work/edition, author, subject, cover, list, and public reading-log APIs. It asks developers to cache results, identifies default and identified request limits as one and three requests per second, and explicitly says its API should not be the high-traffic backend for a commercial service ([Open Library APIs and usage guidelines](https://openlibrary.org/developers/api)).
- Google Books provides volume search and metadata; public-data requests use an API key or OAuth token, while private bookshelf data requires OAuth ([Google Books API](https://developers.google.com/books/docs/v1/using)).
- Goodreads no longer presents a generally usable public developer API at its old API page. Treat an exported CSV as an import format, not Goodreads as a runtime dependency.

### Feasibility and best product cut

Keep a canonical local catalog keyed primarily by ISBN plus work/edition identifiers. Generate a public site with:

- read, reading, paused, and want-to-read shelves;
- ratings, short notes, highlighted themes, dates, and source links;
- reading-year pages and topic trails;
- “books that changed my mind,” pairings, and curated learning paths;
- optional private fields for purchase location, lending, and full notes.

The public website should be generated from a versioned data file, not query book APIs on every page view. Book APIs enrich records at import time; the user remains the source of truth.

### Drawbacks, concerns, and hidden costs

- A “book” and an “edition” are different entities. ISBNs may be missing, duplicated, region-specific, or attached to bundles.
- Cover availability and quality vary, and cover/artwork reuse has licensing and attribution implications.
- Ratings imported from different services do not share the same meaning.
- Public reading history can disclose religion, politics, health, sexuality, employment plans, or family issues.
- Depending on a nonprofit API as the production database ignores its usage policy and creates fragility.
- LLM-generated summaries risk both hallucination and substituting for the user’s own voice.

### Simpler alternative and clever hacks

Start with one `library.csv` or JSON file and an Astro template. Enrich only missing ISBN metadata and cache the response.

Clever hacks:

- Store `work_id` and `edition_id` separately so a later edition change does not split the intellectual work.
- Generate a QR code for each physical shelf or book that opens the corresponding note.
- Make “write one sentence” the default review; promote it into a longer blog post only when the user adds evidence and examples.
- Create automatic “on this date I read…” resurfacing from completion dates.
- Export a human-readable Markdown file per book as the durable backup, even if SQLite is the working store.

### Free-first stack and paid trigger

Use Astro or Eleventy, TypeScript, SQLite/DuckDB for import cleanup, Markdown for authored notes, and a scheduled static build. Cache Open Library/Google Books records by identifier. Deploy on a free static host or serve locally. Pay for a domain first; add search hosting, image optimization, or a CMS only when the public catalog is large enough to justify it.

---

## 16. Event Networking Copilot

**Verdict: HOLD THE FACE-TO-LINKEDIN VERSION. BUILD AN OPT-IN ROSTER, AGENDA, AND MEMORY COPILOT INSTEAD.**

### Closest building blocks and platform facts

- Meta now describes a Wearables Device Access Toolkit for third-party applications on its AI glasses. Hardware access makes camera/audio interactions possible; it does not grant a directory of people or permission to identify bystanders ([Meta Wearables Device Access Toolkit announcement](https://about.fb.com/news/2026/05/meta-ai-wearables-changing-the-game-for-disabled-people/)).
- LinkedIn explicitly prohibits third-party crawlers, bots, plugins, and extensions that scrape, modify, or automate activity on LinkedIn, with account restriction as a possible consequence ([LinkedIn prohibited software](https://www.linkedin.com/help/linkedin/answer/a1341387), [LinkedIn crawling terms](https://www.linkedin.com/legal/crawling-terms)).
- Face matching can create regulated biometric identifiers. Illinois’s BIPA, for example, covers face geometry and requires a public retention policy and informed written release before a private entity collects biometric identifiers ([Illinois BIPA text](https://www.ilga.gov/Legislation/ILCS/Articles?ActID=3004&ChapterID=57&Print=True)).

### Feasibility and safe product cut

Build around information the user is entitled to possess:

- import the event agenda, speaker list, exhibitor list, and an organizer-provided attendee roster;
- let the user identify goals, people, sessions, and questions before the event;
- search bios locally by topic and rank **why** a conversation may be useful;
- scan an opt-in QR badge or NFC/vCard after an introduction;
- capture a short private voice note, then produce a follow-up draft and reminder.

The glasses can act as a hands-free capture/display surface. Identity should come from explicit exchange or the user selecting a roster entry, not silent face recognition.

### Drawbacks, concerns, and hidden costs

- False face matches are reputationally dangerous in a live interaction and can expose an unrelated person’s employment or personal history.
- Event attendees have not consented merely because they entered a venue. Camera recording rules differ by venue and jurisdiction.
- LinkedIn scraping or overlay automation risks account restriction and an unstable product.
- A networking rank can reproduce biased prestige signals and steer the user away from valuable but less visible people.
- Glasses have battery, heat, latency, connectivity, display, and SDK-distribution constraints. The impressive demo may be less useful than a phone.
- Contact notes can contain confidential commercial information and must not be uploaded by default.

### Simpler alternative and clever hacks

Build an **Event Brief + Tap-to-Remember** phone app. Before the event it produces a one-page target list; during the event it opens from a lock-screen shortcut; afterward it queues follow-ups.

Clever hacks:

- Put a personal QR code on the user’s own badge that opens a minimal profile and preferred follow-up channel.
- Use a four-field capture: name, where met, promise made, follow-up date.
- Geofence only the event window to surface the capture button; do not continuously record.
- Compare captured commitments with sent follow-ups and show “promises kept,” not a vanity contact count.
- Let an organizer issue consented attendee IDs that resolve to profiles, avoiding biometric identity entirely.

### Free-first stack and paid trigger

Use a mobile-first PWA/Capacitor app, SQLite, local embeddings over imported bios, QR/NFC scanning, calendar reminders, and optional local transcription. Start phone-only. Pay for glasses-specific development only after the capture workflow is already valuable and the target SDK/distribution terms are confirmed. Do not commercialize facial identification without specialist privacy counsel, explicit enrollment/consent, deletion controls, and jurisdiction-by-jurisdiction review.

---

## 17. Playo Elo Sports Network

**Verdict: BUILD A SINGLE-SPORT, SINGLE-COMMUNITY PILOT. DO NOT START AS A GENERAL SPORTS SOCIAL NETWORK.**

### Closest building blocks and prior art

- Glicko/Glicko-2 add rating uncertainty and are in the public domain, making them a better default than plain Elo for infrequent amateur play ([Glicko official site](https://www.glicko.net/glicko.html)).
- Microsoft’s TrueSkill models both mean skill and uncertainty and supports multiplayer/team outcomes, but the classic method updates from final standings and has assumptions that need calibration for each game mode ([TrueSkill overview](https://www.microsoft.com/en-us/research/project/trueskill-ranking-system/)).
- OpenStreetMap data can support venue discovery, but the public tile service is capacity-limited and has a usage policy; it is not a free production tile CDN for an expanding consumer app ([OSM tile usage policy](https://operations.osmfoundation.org/policies/tiles/)).

### Feasibility and best product cut

Choose one repeat-play community—for example badminton doubles at two nearby venues—and support:

- player profile and availability;
- game creation and invitations;
- result submission confirmed by an opponent;
- sport/mode-specific rating with visible uncertainty;
- balanced match suggestions;
- venue notes and simple attendance reliability.

Do not combine skill, punctuality, sportsmanship, and popularity into one score. Skill rating should be sport- and format-specific; behavior concerns require a separate private moderation process.

### Drawbacks, concerns, and hidden costs

- A rating is only meaningful inside a connected pool of players under consistent rules. Cross-city and cross-format comparisons can be nonsense.
- New players, mixed doubles, rotating teams, injuries, handicaps, incomplete games, and substitute players complicate updates.
- Self-reported outcomes invite collusion, duplicate accounts, score disputes, and intimidation.
- Public rankings can make casual sport less welcoming and can facilitate harassment or exclusion.
- The difficult business problem is local liquidity: enough suitable players at the same place and time—not the rating algorithm.
- Venue booking, payments, refunds, no-shows, safety, and moderation quickly dominate engineering.

### Simpler alternative and clever hacks

Start as a private **club ladder** with invite codes and organizer moderation.

Clever hacks:

- Display a rating interval or confidence badge, not a falsely precise integer.
- Suggest matches by predicted closeness plus schedule/location fit; do not optimize solely for rating.
- Require both sides to confirm a result, then freeze the update until a dispute is resolved.
- Add provisional ratings and decay uncertainty upward after inactivity rather than punishing absence.
- Track “reliability” only from observable attendance events and keep it private to organizers.

### Free-first stack and paid trigger

Use a responsive PWA, TypeScript, Postgres/Supabase or SQLite for one club, a tested Glicko-2 implementation, and direct map links before hosting maps. Notifications can begin as calendar files and email. Pay for SMS/WhatsApp, managed maps, moderation tooling, and payment processing only after one community has repeat weekly liquidity. A DGX is unnecessary.

---

## 18. Any App Widget Maker

**Verdict: REFRAME AS A CONSENTED DATA-ADAPTER + WIDGET STUDIO. A UNIVERSAL “TURN ANY APP INTO A WIDGET” PRODUCT IS NOT REALISTIC.**

### Closest building blocks and platform facts

- Android home-screen widgets are constrained at-a-glance views; supported gestures and UI elements are limited, and the platform offers native RemoteViews or Jetpack Glance rather than arbitrary embedded apps ([Android app widgets overview](https://developer.android.com/develop/ui/views/appwidgets/overview)).
- Apple WidgetKit uses timelines and system-controlled rendering; a widget is an extension of an app, not a continuously running mini-browser ([Apple WidgetKit](https://developer.apple.com/documentation/widgetkit)).
- Windows widgets likewise require a packaged or web widget provider and platform-specific registration ([Windows widget providers](https://learn.microsoft.com/en-us/windows/apps/develop/widgets/widget-providers)).
- A Chrome extension may extract a page on demand with `activeTab`, but persistent or broad injection needs scripting and host permissions ([Chrome scripting API](https://developer.chrome.com/docs/extensions/reference/api/scripting)).

### Feasibility and best product cut

Build a widget studio around sources the user deliberately provides:

- RSS/Atom feed;
- JSON endpoint or webhook;
- iCalendar;
- local Markdown/CSV/SQLite query;
- a one-click browser capture recipe for a page the user is viewing;
- native connectors to the user’s own Personal OS modules.

The studio maps fields to a small set of safe widget templates: number, status, list, image, countdown, progress, and quick action. Generate separate Android, desktop, browser-new-tab, or web outputs from one schema.

### Drawbacks, concerns, and hidden costs

- Mobile operating systems do not allow one app to inspect arbitrary data inside every other app.
- DOM scraping breaks whenever a site changes markup, localizes text, adds anti-bot controls, or moves content behind a login.
- Broad extension permissions are alarming and high-risk: a compromised extension can see sensitive page content.
- Continuous refresh drains battery and violates the event/timeline model of several widget platforms.
- Repackaging third-party data can violate terms, copyright, privacy, or API attribution rules.
- “Quick actions” are especially limited: a widget cannot safely invoke arbitrary private app functions without an exposed deep link, intent, shortcut, or API.

### Simpler alternative and clever hacks

First build a **Personal OS glance board** and one Android widget that shows selected cards from it.

Clever hacks:

- Define a tiny `WidgetCard` JSON schema and make every personal project publish into it.
- Use share-sheet capture or `activeTab` only when the user clicks, rather than background scraping.
- Prefer deep links and official shortcuts for actions; fall back to opening the source app at the right screen.
- Add a “staleness” timestamp to every card so cached data never masquerades as live.
- Compile the same schema into a Windows tray panel, browser new-tab page, and Android widget before tackling iOS.

### Free-first stack and paid trigger

Use a TypeScript schema/compiler, a PWA dashboard, an Android client in Kotlin + Jetpack Glance, and a minimal Manifest V3 extension using `activeTab`. Store secrets in OS keychains, never in the widget payload. Add iOS WidgetKit only after the shared schema is stable. Pay for hosted sync and connector infrastructure when multiple devices or customers need reliable refresh; charge for curated, supported connectors rather than promising arbitrary-app compatibility.

---

## 19. Motto Agent Council

**Verdict: BUILD NOW AS A SMALL DECISION WORKBENCH OR CODEX SKILL, NOT AS AN AUTONOMOUS MULTI-AGENT COMPANY.**

### Closest building blocks and prior art

- LangGraph supports hierarchical supervisors, tool handoffs, memory, and human-in-the-loop, but its own supervisor repository now recommends the simpler tool-calling supervisor pattern for most use cases because it gives better context control ([LangGraph supervisor](https://github.com/langchain-ai/langgraph-supervisor-py)).
- Ollama exposes a local HTTP API and tool-capable chat models; `llama.cpp` can provide a local OpenAI-compatible server and constrained JSON, so a council does not require paid inference ([Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md), [llama.cpp server](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)).
- If tools are later exposed over MCP, authorization is OAuth-based for HTTP transports and should be treated as a security boundary, not a convenience toggle ([MCP authorization](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization)).

### Feasibility and best product cut

Represent each motto or decision philosophy as a short, inspectable card:

- question it asks;
- evidence it values;
- predictable blind spots;
- hard constraints;
- output schema.

For a decision, run the same evidence packet through several cards independently, then have a deterministic reducer display agreements, conflicts, missing evidence, reversible experiments, and a proposed choice. The user approves the final decision. Most councils can use one model with multiple role prompts; different model providers are useful for diversity tests, not required for the product.

### Drawbacks, concerns, and hidden costs

- Several agents using the same model and context are correlated, not independent expert witnesses.
- More agents multiply tokens, latency, tool calls, and opportunities for prompt injection without guaranteeing a better decision.
- Role-play can produce confident theater: a “CFO,” “doctor,” or “lawyer” persona has no professional duty or verified expertise.
- A synthesizer can erase dissent. Showing only its final paragraph defeats the reason to have a council.
- If every agent can execute tools, duplicate emails, calendar events, purchases, or file edits become likely.
- Long-term memory can fossilize old assumptions and leak sensitive context across decisions.

### Simpler alternative and clever hacks

Start with a **single-call council compiler**: one prompt produces separate named analyses in a strict JSON schema, followed by a non-LLM comparison table.

Clever hacks:

- Require every recommendation to cite an item in the supplied evidence packet or label itself a hypothesis.
- Add a “what would change my mind?” field to each council member.
- Include one adversarial role and one simplifier role; five near-identical optimists add little.
- Hide other members’ outputs during the first pass to reduce anchoring.
- Run a cheap local model for critique and a stronger paid model only for ambiguous synthesis.
- Score decisions later against outcomes; retire motto cards that add verbosity but no predictive value.

### Free-first stack and paid trigger

Use Python, Pydantic/JSON Schema, SQLite, a simple web UI, and Ollama/llama.cpp. A plain state machine is preferable to an agent framework until branching, retries, and resumable tool calls are real requirements. Keep tools read-only; action proposals go into Jarvis/Alfred’s approval queue. Pay for proprietary models only when a blind evaluation on saved decisions shows a meaningful lift over the local baseline.

---

## 20. Language Learning and Pronunciation Coach

**Verdict: URGENT PERSONAL-USE BUILD. MERGE THE COMMON-WORDS AND PRONUNCIATION IDEAS, BUT BUILD VOCABULARY + SHADOWING BEFORE “ACCENT SCORING.”**

### Closest building blocks and prior art

- Anki’s current scheduler supports FSRS, which estimates memory stability/difficulty and schedules reviews toward a chosen retention target ([Anki FSRS documentation](https://docs.ankiweb.net/deck-options.html#fsrs)).
- Tatoeba offers downloadable sentence/translation pairs and records licenses and attribution for audio; that makes it useful seed material only when each record’s license is preserved ([Tatoeba downloads](https://tatoeba.org/en/downloads)).
- Whisper is an MIT-licensed multilingual speech-recognition model with substantial accuracy and hardware tradeoffs across model sizes. It transcribes words; it is not, by itself, a validated pronunciation assessor ([Whisper repository and model table](https://github.com/openai/whisper)).
- Montreal Forced Aligner aligns known text to audio at word/phone boundaries using language-specific acoustic models and pronunciation dictionaries; Praat provides low-level phonetic inspection. These are closer to the proposed timing/phoneme graph than generic ASR ([Montreal Forced Aligner](https://montreal-forced-aligner.readthedocs.io/en/latest/), [Praat](https://www.fon.hum.uva.nl/praat/)).

### Feasibility and best product cut

Build one daily loop:

1. Pick a situation—café, interview, taxi, meeting, family conversation.
2. Learn 10–20 high-value words/chunks with meaning, register, example, audio, and common contrast.
3. Review them with FSRS.
4. Shadow one short reference recording.
5. Record the learner, align the expected text, and show playback plus timing, omitted/added words, pauses, pitch contour, and a small number of target phoneme contrasts.
6. Save one real sentence the learner expects to use soon.

The learning unit should be the **phrase/chunk**, not an isolated frequency-ranked word. Frequency helps prioritize, but situational usefulness, learner goals, and known-language contrasts should influence the queue.

### Drawbacks, concerns, and hidden costs

- “Correct accent” is not a binary target. Dialects are legitimate, and scoring systems can penalize identity rather than intelligibility.
- ASR acceptance is a poor proxy for human comprehension: a model can recognize a heavily accented word or fail on a valid pronunciation.
- Phoneme-level feedback needs a reliable transcript, pronunciation dictionary, acoustic model, and language/dialect target. Coverage will vary sharply by language.
- Pitch, formant, and “radar” graphics can look scientific while providing little actionable instruction.
- Microphone recordings reveal identity, health, location, and background conversation. Default to local processing and easy deletion.
- LLM-generated dialogues can be unnatural, culturally wrong, above level, or factually misleading. Native-speaker validation becomes a content cost.
- Open sentence/audio corpora use mixed licenses; attribution must travel with exported lessons.

### Simpler alternative and clever hacks

Build **Phrase Inbox + Shadowing Recorder** first. The browser extension sends selected text to a lesson inbox; the app reads it aloud, records the learner, transcribes locally, and schedules the phrase.

Clever hacks:

- Ask the learner to choose a target dialect/voice and state that feedback measures similarity to that reference, not personal worth.
- Give one correction per attempt. A ranked list of ten acoustic deviations is demotivating.
- Use minimal-pair gates for sounds the learner actually confuses, rather than scoring every phoneme.
- Alternate record/playback with waveform hiding; listening to one’s own recording often teaches more than a synthetic score.
- Have the model generate dialogues only from approved vocabulary and then run a separate level/coverage check.
- Let the user tag a phrase “needed this week”; urgency can temporarily override frequency.
- Store a “human understood me?” outcome from real conversations to calibrate whether automatic feedback matters.

### Free-first stack and paid trigger

Use a PWA/Capacitor client, TypeScript, SQLite/IndexedDB, FSRS, Web Audio/MediaRecorder, and a small local Python speech service. Run Whisper on the workstation/DGX for transcription; add MFA/Praat-derived features only for one well-supported target language. Use system TTS or an open local voice first, and preserve corpus attribution in the data model. Pay for high-quality neural voices or a commercial pronunciation API only after the vocabulary/shadowing loop produces sustained daily use; validate paid scores against native-speaker judgments before trusting them.

---

## 21. Jobs Search and Apply Tool

**Verdict: URGENT PERSONAL-USE BUILD AS A SEARCH, EVIDENCE, TAILORING, AND APPLICATION COPILOT. SKIP MASS AUTO-APPLY AND LOGGED-IN JOB-SITE AUTOMATION.**

### Closest building blocks and platform/API facts

- Greenhouse’s Job Board API exposes published jobs through unauthenticated GET endpoints, but application submission requires the employer’s Job Board API key. It also exposes job-specific questions and compliance/consent fields, so a generic form cannot assume a fixed schema ([Greenhouse Job Board API](https://developers.greenhouse.io/job-board.html)).
- Lever’s public Postings API can list and submit to one company’s published postings, but it is designed for that company’s career site: it has CORS/domain constraints, does not provide full-text search across open jobs, and does not expose every custom question ([Lever Postings API](https://github.com/lever/postings-api)).
- USAJOBS offers a key-authenticated, read-only search API intended for lightweight job announcement consumption; this is a genuine aggregator source but only for US federal opportunities ([USAJOBS API](https://developer.usajobs.gov/api-reference/), [search endpoint](https://developer.usajobs.gov/api-reference/get-api-search)).
- LinkedIn prohibits browser extensions and bots that scrape, modify, or automate activity on its site, and says automated activity can result in restriction ([LinkedIn prohibited software](https://www.linkedin.com/help/linkedin/answer/a1341387), [automated activity](https://www.linkedin.com/help/linkedin/answer/a1340567/automated-activity-on-linkedin)).
- JSON Resume provides an open, structured schema for a canonical resume record; use it as the facts database from which role-specific documents are rendered ([JSON Resume schema](https://jsonresume.org/schema)).

### Feasibility and best product cut

Build a pipeline with an explicit human gate:

1. Capture a job URL through share sheet, bookmarklet, manual paste, RSS/email alert, or an approved public API.
2. Save the original description, retrieval date, source, company, location, compensation, and application URL.
3. Extract requirements into **must have**, **nice to have**, responsibilities, domain vocabulary, evidence requested, and application questions.
4. Match each requirement against a canonical evidence bank of real projects, achievements, skills, dates, and links.
5. Classify each item as supported, partial, missing, or unclear.
6. Select and reorder truthful resume bullets; draft a short cover note and question answers with source links back to the evidence.
7. Run deterministic checks for dates, numbers, unsupported claims, duplicated bullets, contact details, and PDF text extraction.
8. Open the official application page for manual review and submission.
9. Track submitted version, status, follow-up date, contact, and outcome.

This is technically feasible and valuable without defeating job-site safeguards. The differentiator is the evidence ledger and learning loop, not clicking “Apply” thousands of times.

### ATS, tailoring, and truthfulness rules

- Maintain one canonical facts record. Generated resumes may select, shorten, and emphasize facts, but must never invent a skill, employer, date, title, credential, clearance, work authorization, salary, or metric.
- Every generated bullet should carry an internal provenance pointer to a fact/project note. Block export when a number or named technology lacks provenance.
- Render a simple one-column, selectable-text PDF and also retain DOCX/plain text when requested. Test by extracting text back from the PDF; visual beauty is secondary to accurate parsing.
- Do not treat keyword count as an “ATS score.” Show requirement coverage and evidence quality instead.
- The tool may suggest a learning plan for genuine gaps; it must not silently convert “learning” into “experienced.”
- Demographic, disability, veteran, criminal-history, salary, and work-authorization questions must be answered by the user. Do not infer them.

### Drawbacks, concerns, and hidden costs

- Most large job networks do not offer a public job-seeker API that supports arbitrary discovery plus automated application. Scraping and UI automation are brittle and can violate terms or trigger account restrictions.
- Application schemas vary by employer and may include legal attestations, location questions, file upload, CAPTCHA, and explicit data-retention consent.
- Job descriptions change or disappear. Save the exact version used for tailoring and interview prep.
- Resumes, compensation, addresses, phone numbers, work history, IDs, and application answers form a high-value identity profile.
- LLM tailoring can introduce plausible but false claims. Even a minor changed number can damage credibility.
- Mass auto-apply creates low-quality applications, prevents thoughtful employer research, and makes it hard to learn which positioning works.
- Paid aggregation data can be expensive and contractually limited; “free APIs” often cover only the employer operating that ATS.
- Measuring success only by number submitted rewards spam. Optimize for qualified applications, replies, interviews, and useful feedback.

### Simpler alternative and clever hacks

The smallest useful version is a **Job Link Inbox**:

- paste/share a link;
- choose keep, reject, or investigate;
- extract five requirements;
- show the three strongest matching evidence items and the top two real gaps;
- schedule the next action;
- open the original application page.

Clever hacks:

- Fingerprint normalized company/title/location/description to detect duplicate agency reposts.
- Use a “30-second reject rule” before expensive model analysis: wrong location, compensation, seniority, work authorization, or role family.
- Generate a role-specific “proof pack” containing project links, screenshots, metrics, and interview stories, not just a resume.
- Compare the submitted resume with interview/reply outcomes and learn which **truthful** evidence performs by role family.
- Create application batches by context—three deeply tailored roles in one domain—rather than spraying unrelated jobs.
- Draft follow-ups but require the user to choose the recipient and send.
- Add a stale-job warning based on publish/update date and require opening the official posting before spending time.

### Free-first stack and paid trigger

Use a local PWA or Tauri app, TypeScript, SQLite/DuckDB, a tiny Manifest V3 capture extension using `activeTab`, and Python/FastAPI for extraction. Keep the canonical resume in JSON Resume plus Markdown evidence files; render with Typst, Pandoc, or a controlled HTML-to-PDF template. Run a local model for classification/drafting and deterministic validators afterward. Do not use Playwright against logged-in job networks in the product. Pay for a stronger model only for final tailoring after a job passes filters; pay for licensed job data only when public feeds, company career pages, and user-supplied links are demonstrably limiting recall.

---

## Recommended build sequence and stop rules

The urgent personal-use sequence should optimize shared infrastructure:

1. **Paper Logbook** establishes capture, templates, daily records, export, and offline data.
2. **Goal-to-Calendar** adds tasks, constraints, previews, and reversible calendar writes.
3. **Jobs Search/Apply** reuses capture, evidence records, review queues, and calendar follow-ups.
4. **Language Learning** reuses daily queues, spaced scheduling, media capture, and local inference.
5. **Net Worth + Paisa Vasool** add financial import and reconciliation only after encrypted backup/export is tested.

Build early vertical slices, then dogfood and harden them through [[First Month Build Program]]. Continue only when a tool saves time or earns repeated use; otherwise preserve its portable data/export format and retire the UI. Introduce hosted accounts, multi-user sync, payment flows, medical claims, biometric identity, or autonomous writes only when the personal workflow is proven and the new risk has an explicit owner, budget, consent model, and rollback path.
