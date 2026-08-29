# Research: Information and Learning Ideas

> **Current scope decision:** these are local, single-user prototypes using user-supplied inputs. Rights, redistribution, trademarks, and public-product licensing are recorded only as future reminders under [[Scope Expansion Checklist]] and do not change the recommended personal tech stacks.

**Research date:** 2026-07-27  
**Scope:** Primary-source review of eleven related ideas. Recommendations assume a personal, local-first prototype on a Windows workstation and/or DGX Spark, with a possible product phase later.

## Executive takeaways

The strongest shared product is not eleven independent apps. It is a local **Learning and Information Workbench** with reusable ingestion, source provenance, scheduling, document anchors, model routing, and feedback components. The first-party/open inputs—RSS, user-provided files, EPUB, PDFs, public course material, and local audio—are technically straightforward. Closed social feeds, other people's YouTube captions, proprietary e-reader annotations, and copyrighted coding-problem corpora are the recurring boundary.

A sensible shared architecture is:

1. **Inbox adapters:** FreshRSS, browser share/clip, local folders, Calibre/KOReader exports, arXiv URLs, microphone, and screenshots.
2. **Canonical objects:** source, excerpt, timestamp/page/location, content hash, license, confidence, and user feedback.
3. **Local processing:** Python workers, SQLite/DuckDB, local OCR/ASR/LLM inference, and deterministic transforms.
4. **Learning layer:** prerequisite graphs, exercises, retrieval practice, FSRS scheduling, and progress events.
5. **Interfaces:** Obsidian Markdown first; a local web UI only where interaction materially helps; browser extension or Tauri shell later.

The best near-term builds are Personal Signal Intelligence OS, Personal Study Curriculum, YouTube Learning Center, Half-Blood PDF as a sidecar-annotation system, Understand This Paper with a deliberately narrow scope, and EPUB Highlights Bridge. Bionic Reading Trainer and Visual Token Compiler are worthwhile experiments, but should be framed as measured personal tools rather than products with unverified performance claims.

---

## 1. Personal Signal Intelligence OS

### Project interpretation

A local “signal versus noise” system that combines followed sources and explicitly shared items, ranks them against personal goals, produces a daily Markdown briefing, and learns from keep/skip/correct feedback. A universal authenticated reader for WhatsApp, X, LinkedIn, TikTok, and every other network should not be the MVP promise.

### Closest building blocks and prior art

- FreshRSS is already a self-hosted feed aggregator with tags, a CLI, a Google Reader-compatible API, and resharing through HTML, RSS, and OPML. Its API can retrieve reading-list streams and modify subscriptions, which makes it an unusually good source-of-truth rather than merely a UI. [FreshRSS project](https://github.com/FreshRSS/FreshRSS), [Google Reader API implementation](https://freshrss.github.io/FreshRSS/en/developers/06_GoogleReader_API.html)
- FreshRSS's official extensions already include an **LLM Classification** extension that tags incoming articles through an OpenAI-compatible endpoint, plus keyword webhooks and reading-time helpers. This is prior art for putting classification near ingestion rather than building a second feed database immediately. [FreshRSS official extensions](https://github.com/FreshRSS/Extensions/)
- RSSHub is an AGPL-licensed, self-hostable feed generator with routes for many sites that do not expose convenient RSS. It is useful as a best-effort adapter, but its routes are integrations with moving third-party targets and therefore need monitoring. [RSSHub source repository](https://github.com/DIYgod/RSSHub)

### Verified platform/API facts

- X exposes a reverse-chronological home-timeline endpoint requiring user-context authentication; its documented window is the latest 3,200 posts or seven days. X currently uses pay-per-use pricing, and its reduced “Owned Reads” rate applies to the developer app owner's own data such as their posts, bookmarks, likes, followers, and followed lists—not a blanket free read of everyone else's content. [X timelines](https://docs.x.com/x-api/posts/timelines/introduction), [X pricing](https://docs.x.com/x-api/getting-started/pricing)
- LinkedIn's generally available permissions cover identity and writing on behalf of a member. Reading a member's posts through `r_member_social` is restricted to approved users, so a personal “read my entire LinkedIn feed” integration should not be assumed available. [LinkedIn API access](https://learn.microsoft.com/en-us/linkedin/shared/authentication/getting-access), [LinkedIn Posts API permissions](https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/posts-api)
- TikTok's Display API exposes an authorized user's profile and that user's recently uploaded public videos. It is not documented as a general “accounts I follow” or personalized feed API. [TikTok Display API](https://developers.tiktok.com/doc/display-api-overview/)

These facts make a universal social inbox primarily an access-policy problem, not a summarization problem.

### Strongest feasibility pointers

- The core digest works with only FreshRSS plus a manual “share to inbox” path. Each entry can be normalized to `{source, author, URL, published_at, body, media, captured_via, license/terms note}`.
- Ranking can start without an LLM: source priority, novelty, goal/tag overlap, age decay, reading time, and previous user actions form a transparent score. A local model can then create summaries and topic labels only for the top tranche.
- Human feedback can be very low-friction: **must read / useful later / noise / wrong topic**. This is more learnable than a vague thumbs-up because each action maps to a ranking feature.

### Drawbacks, concerns, and hidden costs

- Closed-platform APIs can add review delays, OAuth maintenance, changing scopes, and per-resource charges. Browser scraping or session-cookie automation creates account and terms risk and will be brittle.
- A summarizer can erase dissent, uncertainty, or the reason an item matters. The briefing needs source links, a short extract, and a “why selected” line, not summary prose alone.
- Social content can contain prompt injection. Treat ingested text as untrusted data, never as agent instructions.
- A feedback-trained filter can create a narrower bubble. Add a small, explicit “serendipity” quota and a “disconfirming view” lane.
- Republishing a private digest as a monetized newsletter is a separate copyright and privacy decision. Store provenance and generate original commentary rather than concatenating source text.

### Much simpler alternative

Use FreshRSS as the only automated source and add a browser/phone share target that appends URLs to `Signal Inbox.md`. A scheduled script produces `Daily Signal - YYYY-MM-DD.md` with five sections: act today, read, watch, archive, and deliberately skipped. This captures most of the value without authenticating any social network.

### Clever implementation hacks

- Score before summarizing so model cost scales with promising items, not total intake.
- Cache by canonical URL plus content hash. A model should never summarize the same unchanged item twice.
- Use pairwise feedback—“which of these two was more useful?”—occasionally. It gives cleaner ranking data than a 1–5 rating.
- Keep an “information debt” counter: if several high-signal items on one theme remain unread, propose a study session or a synthesized explainer instead of adding more links.
- Generate the digest from structured JSON, then render Markdown. This keeps future email, mobile, and dashboard outputs cheap.

### Recommended free-first stack

- **Ingestion:** FreshRSS, RSSHub where appropriate, browser share/bookmarklet, watched Markdown folder.
- **Backend:** Python 3.12, FastAPI only if a service is needed, APScheduler or Windows Task Scheduler, SQLite with FTS5.
- **Models:** local embeddings and a local instruction model through Ollama, llama.cpp, or vLLM; use rules for initial ranking.
- **Output:** Obsidian Markdown with stable source IDs and links.
- **Later UI:** SvelteKit or React/Vite local dashboard; PWA share target for mobile capture.

Pay for an API only when a specific source has proved valuable enough to cover its access cost. For X, measure the marginal number of genuinely useful items before buying read credits. Pay for a hosted model when the daily synthesis quality or multilingual coverage is materially better than the local route, while keeping ranking and storage local.

### Verdict

**Build now, but as an RSS-plus-explicit-capture intelligence layer. Skip the universal social-feed claim until each platform has an approved, durable integration.**

---

## 2. Personal Study Curriculum

### Project interpretation

A goal-driven curriculum compiler that turns “I want to learn X” into prerequisites, trusted resources, projects, retrieval practice, review scheduling, and weekly course correction. Its product value is the closed learning loop, not merely an AI-generated syllabus.

### Closest building blocks and prior art

- MIT OpenCourseWare offers free material from thousands of MIT courses, generally including a syllabus, instructional material, and activities. It offers neither enrollment nor credit, which makes it a strong resource layer but not a progress system. [MIT OCW about](https://ocw.mit.edu/about/), [MIT OCW learner guide](https://ocw.mit.edu/pages/get-started/)
- OpenStax publishes free, peer-reviewed, openly licensed textbooks. Its current help pages state that its books use CC BY-NC-SA, so adaptations for a commercial product need license review rather than an assumption that “open” means unrestricted commercial reuse. [OpenStax about](https://openstax.org/about), [OpenStax licensing help](https://help.openstax.org/s/topic/0TO6f0000003F84GAE/textbooks)
- Anki's FSRS scheduler can optimize parameters from a learner's own review history; the manual notes it requires substantial review data before personalization becomes meaningful. [Anki FSRS documentation](https://docs.ankiweb.net/deck-options)
- The open FSRS project provides implementations in TypeScript, Python, Rust, Go, Dart, Swift, and other languages, allowing the scheduler to be embedded without recreating spaced repetition. [Free Spaced Repetition Scheduler](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler)

### Verified content and integration facts

- MIT OCW encourages noncommercial remixing with attribution, but some course packs/readings are omitted because they are third-party copyrighted works. A curriculum builder must carry resource-level license metadata instead of assuming the course page's license covers every linked reading. [MIT OCW learner guide](https://ocw.mit.edu/pages/get-started/)
- Obsidian's official plugin API exposes the vault, workspace, and metadata cache, including headings, links, embeds, tags, and blocks. A personal prototype can therefore stay Markdown-native and still add commands and views later. [Obsidian API](https://github.com/obsidianmd/obsidian-api)

### Strongest feasibility pointers

- The deterministic part is tractable: a curriculum is a prerequisite DAG, a list of learning outcomes, resources, assessment rubrics, review items, and a calendar.
- Models are useful for decomposing goals and drafting exercises, but the user can approve the graph before any calendar is generated.
- Progress can be evidence-based: quiz results, code/tests, solved problems, explanation recordings, and completed artifacts. “Watched video” should not be treated as mastery.

### Drawbacks, concerns, and hidden costs

- Curriculum generation can create a beautiful but endless plan. The system needs a fixed weekly time budget and a hard “minimum viable syllabus.”
- LLM-generated prerequisites can be plausible but wrong, and generated quizzes can test trivia rather than the stated outcome.
- The user's review history is sensitive behavioral data. Keep it local by default and avoid sending full journals or weak-skill profiles to third parties.
- Licensing becomes material if course notes, figures, or questions are repackaged into a paid product.
- FSRS schedules memory items; it does not decide whether a complex skill has been mastered. Projects and transfer exercises need separate evaluation.

### Much simpler alternative

Create one Markdown template with: outcome, why it matters, prerequisites, one canonical course/textbook, one project, weekly hours, and a “prove I learned it” rubric. Export only atomic facts or prompts to Anki. Review the curriculum manually every Sunday.

### Clever implementation hacks

- Use a **prerequisite debt** rule: when the user fails two exercises for the same underlying concept, insert one remedial node instead of regenerating the whole curriculum.
- Keep one primary resource per node and at most two alternates. Choice overload is a learning bug.
- Require the model to label every proposed activity as acquire, retrieve, apply, explain, or assess; this reveals curricula made entirely of passive consumption.
- Add a “teach-back” capture: record a two-minute explanation, transcribe locally, and compare it to a rubric. Store gaps as review prompts, not as a generic score.
- Generate review cards only from user-confirmed notes or failed questions. This sharply reduces confident-but-wrong flashcards.

### Recommended free-first stack

- **Data and authoring:** Markdown/YAML in Obsidian, SQLite for events and review state.
- **Scheduler:** an FSRS library in Python or TypeScript.
- **Content catalog:** curated OCW/OpenStax links plus user-provided sources; no broad scraper in v1.
- **Logic:** Python for prerequisite and scheduling services; local LLM for decomposition and exercise drafts.
- **UI:** Dataview-style Markdown dashboards first; Obsidian plugin or local SvelteKit app only when graph editing becomes painful.

Use a paid model only for difficult curriculum design, high-quality critique, or multimodal assessment where a local model demonstrably fails. A hosted learning-content license or tutor service is justified only if it improves verified outcomes, not merely the polish of explanations.

### Verdict

**Build now. It is a strong personal system and a reusable core for several other ideas, but constrain it to one learning goal and one twelve-week loop before generalizing.**

---

## 3. YouTube Learning Center

### Project interpretation

A browser/mobile capture workflow for individual videos or playlists that produces timestamped structured notes, concept maps, quizzes, and a cross-video synthesis. It may optionally hand curated sources to NotebookLM for its native audio/video study artifacts.

### Closest building blocks and prior art

- NotebookLM already accepts public YouTube URLs with captions. Its help page states that it imports only the transcript, not the video imagery, and that captionless or newly uploaded videos can fail. Standard access currently supports up to 50 sources per notebook and 500,000 words per source. [NotebookLM source support](https://support.google.com/notebooklm/answer/16215270), [NotebookLM limits](https://support.google.com/notebooklm/answer/16269187)
- OpenAI Whisper is an MIT-licensed general-purpose speech-recognition model that supports multilingual transcription and runs locally with FFmpeg. [Whisper source and model documentation](https://github.com/openai/whisper/blob/main/README.md)
- `yt-dlp` supports playlist archives and chapter-based splitting, but it is an unofficial downloader whose extractors can break when sites change. It should be limited to content the user is permitted to download. [yt-dlp README](https://github.com/yt-dlp/yt-dlp/blob/master/README.md), [yt-dlp FAQ](https://github.com/yt-dlp/yt-dlp/wiki/FAQ)

### Verified YouTube/API facts

- `captions.list` returns caption-track metadata, not caption text. The official `captions.download` method requires authorization and permission to edit the video, and currently has a quota cost of 200 units. It is not a general transcript-download API for arbitrary public videos. [YouTube API reference](https://developers.google.com/youtube/v3/docs), [captions.download](https://developers.google.com/youtube/v3/docs/captions/download)
- NotebookLM's YouTube importer works only for public videos that have uploaded or auto-generated captions, imports transcript text only, and can reject videos uploaded within the previous 72 hours. [NotebookLM YouTube import behavior](https://support.google.com/notebooklm/answer/16215270)

### Strongest feasibility pointers

- Playlist metadata, ordering, titles, durations, and descriptions can be acquired separately from transcript text. The product can remain useful when a transcript is missing by clearly marking the item as “metadata only.”
- Hierarchical synthesis is straightforward: segment summaries with timestamp anchors → per-video concept maps → playlist-level synthesis → curriculum and retrieval questions.
- The DGX Spark is well suited to local ASR for user-owned or explicitly downloaded audio, making transcription cost predictable.

### Drawbacks, concerns, and hidden costs

- Arbitrary-public-video transcript acquisition is the largest platform risk. Do not build the product around an undocumented transcript endpoint.
- Auto-captions are often wrong for names, accents, code, formulas, and domain terminology. A confident downstream summary magnifies these errors.
- Long-context synthesis can omit minority topics even when the transcript fits in the model context. Coverage needs an explicit audit.
- Visual information—slides, demonstrations, charts, code changes—will be absent from a transcript-only pipeline.
- Downloading or redistributing video/audio can violate rights or platform terms. Retain URLs and derived personal notes; avoid storing media unless the user owns it or has permission.
- Generating an entire playlist in one premium-model call is expensive and hard to debug. Cache each stage.

### Much simpler alternative

For a single video, share the URL directly to NotebookLM and use a fixed prompt for structured notes. For a playlist, manually export the list of URLs, import captioned public videos within NotebookLM's source limit, and ask for a cited curriculum. Build software only for timestamped Markdown export, source tracking, and the local fallback path.

### Clever implementation hacks

- Store every claim with `{video_id, start_seconds, end_seconds, transcript_text}`. Make the timestamp clickable.
- Use a **coverage matrix**: rows are videos, columns are discovered concepts, and cells hold evidence spans. A playlist summary is not “done” until every video has either coverage or an explicit “no unique contribution” note.
- Run a cheap vocabulary pass first, then feed its glossary as an ASR correction prompt for later chunks.
- Sample frames only around slide changes or phrases like “as you can see,” rather than processing every frame.
- Use content hashes for transcript chunks and prompt/version IDs for outputs. Re-summarize only affected nodes.
- Produce three outputs from the same intermediate representation: five-minute brief, study chapter, and flashcard candidates.

### Recommended free-first stack

- **Capture:** browser extension or mobile share target writing URLs to a queue.
- **Metadata:** YouTube Data API for permitted metadata; user-provided transcript; NotebookLM handoff where suitable.
- **Local media path:** FFmpeg plus Whisper/faster-whisper for content the user may process.
- **Pipeline:** Python, FastAPI, Redis only if needed, SQLite/DuckDB, background workers, local LLM.
- **Output:** Markdown with timestamp links; Mermaid/Excalidraw concept maps only after the textual graph is verified.
- **UI:** Gradio or a small SvelteKit local app.

Use a paid long-context model only for the final cross-video synthesis after local chunking and coverage extraction. Use paid transcription when turnaround time matters more than local GPU time or when measured domain accuracy is better. NotebookLM's paid tiers are justified only when source/generation limits, sharing, or its media artifacts are repeatedly constraining real use.

### Verdict

**Build the learning pipeline and source provenance now. Do not ship a generalized video downloader or promise arbitrary public transcripts.**

---

## 4. Bionic Reading Trainer

### Project interpretation

A reader and training tool that can vary fixation bolding, width, spacing, font, pacing, and comprehension checks, then learn which presentation actually helps this user. “Bionic” formatting should be one experimental condition, not the unexamined product claim.

### Closest building blocks and prior art

- Mozilla Readability, the library used for Firefox Reader View, extracts article title, content, text, byline, language, and other metadata. Its documentation warns that output from untrusted pages still requires sanitization. [Mozilla Readability](https://github.com/mozilla/readability)
- Chrome Manifest V3 supports content scripts and runtime JavaScript/CSS injection with `activeTab` or host permissions, making a click-to-transform extension feasible without a server. [Chrome scripting API](https://developer.chrome.com/docs/extensions/reference/api/scripting), [Manifest V3](https://developer.chrome.com/docs/extensions/mv3/manifest)
- WCAG 2.2's text-spacing criterion is designed so users can override author spacing without losing readability or operability. Any trainer that modifies typography needs to preserve that user control and avoid clipping. [WCAG text spacing](https://www.w3.org/WAI/WCAG22/UNDERSTANDING/text-spacing.html)

### Verified evidence boundary

A 2025 eye-tracking study of typical adult readers found longer reading time with the bionic format, no paper-reading advantage, and no consistent basis to call the format good or bad for comprehension and memorization; the authors call for broader testing. This is sufficient reason not to market a speed or accessibility benefit as established. [Usability of Bionic Reading on Different Mediums](https://journals.sagepub.com/doi/10.1177/21582440251376158)

### Strongest feasibility pointers

- The formatting transform is computationally trivial and can run fully on-device.
- The differentiated feature is a personal crossover experiment: alternate plain and transformed passages at matched difficulty, collect reading time and comprehension, and recommend settings from the user's own data.
- A browser extension and an offline PWA can share nearly all transformation and experiment code.

### Drawbacks, concerns, and hidden costs

- Faster scrolling is not the same as comprehension. Always pair pace with delayed questions.
- DOM rewriting can break links, selection, screen-reader semantics, code, equations, bidirectional text, and languages where word segmentation is not space-delimited.
- “Designed for ADHD/dyslexia” is a medical/accessibility-adjacent claim and needs direct evaluation with those populations.
- Full-page host permissions are a trust and store-review cost. Prefer `activeTab`.
- Readability parsing can include unsafe HTML; Mozilla explicitly recommends sanitization and CSP defense in depth. [Mozilla Readability security guidance](https://github.com/mozilla/readability#security)

### Much simpler alternative

Make a bookmarklet or userscript that applies adjustable CSS and bolds the first portion of words in the selected article. Add a small comprehension timer locally. This can validate personal usefulness before building a mobile app.

### Clever implementation hacks

- Segment with Unicode-aware word/grapheme rules, never string-byte offsets.
- Exclude code, math, URLs, form controls, headings if desired, and elements with explicit language/direction rules.
- Randomize A/B passage order and hide the “bionic” label during tests to reduce expectation effects.
- Estimate reading difficulty before pairing passages; compare like with like.
- Optimize a personal utility function combining comprehension, delayed recall, eye comfort, and time—not words per minute alone.
- Preserve the original DOM and apply reversible wrapper spans so “reset page” is reliable.

### Recommended free-first stack

- TypeScript, Vite, Manifest V3, Mozilla Readability, DOMPurify, IndexedDB.
- PWA for pasted text/EPUB excerpts; no backend.
- Optional Web Speech API or local TTS later, but not required for the core experiment.

A paid service is rarely justified. Pay only for a high-quality cross-platform TTS voice or professionally designed accessibility study. Do not pay for an LLM to perform a deterministic typography transform.

### Verdict

**Build as a weekend personal experiment and reader utility. Skip a broad paid product unless measured individualization becomes the differentiator.**

---

## 5. Half-Blood PDF

### Project interpretation

A “used textbook from a brilliant tutor” experience: highlights, margin questions, handwritten-style notes, diagrams, and deep links layered on a PDF while preserving the original and its searchable text.

### Closest building blocks and prior art

- PyMuPDF can insert text/images, add highlight, ink, line, shape, file, and other PDF annotations, and work with search-derived quadrilaterals. Its coordinate model and rotated-page behavior are documented and need careful handling. [PyMuPDF Page API](https://pymupdf.readthedocs.io/en/latest/page.html), [annotation recipes](https://pymupdf.readthedocs.io/en/latest/recipes-annotations.html)
- PDF.js supplies a browser PDF renderer and viewer that can be used as the front-end foundation. Mozilla describes its viewer as a reasonable starting point but asks embedded products not to ship it unchanged. [PDF.js getting started](https://mozilla.github.io/pdf.js/getting_started/)
- Excalidraw is open source, exposes an embeddable editor, saves an open JSON scene format, and exports PNG/SVG. Its editable scene data can also be embedded in exported images. [Excalidraw repository](https://github.com/excalidraw/excalidraw), [Excalidraw export behavior](https://github.com/excalidraw/excalidraw/discussions/3778)
- OCRmyPDF adds a searchable text layer to scanned PDFs, which is preferable to treating every scanned page as an opaque image. [OCRmyPDF documentation](https://ocrmypdf.readthedocs.io/en/latest/)

### Strongest feasibility pointers

- A standard annotation layer is feasible without reconstructing the PDF. Highlights, ink, text notes, and links can be added at known page coordinates.
- Excalidraw diagrams can remain editable sidecars and be exported to SVG/PNG only for display or final flattening.
- The aesthetic “beaten-up book” treatment is a rendering theme. It should be optional and applied after semantic annotations exist.

### Drawbacks, concerns, and hidden costs

- PDF is a final-layout format. Extracted reading order, columns, footnotes, equations, and coordinates can be wrong; rotated pages add another transform.
- Scanned documents require OCR before text anchoring, and OCR errors can attach a correct note to the wrong passage.
- Re-rendering every page through HTML/Pandoc can change pagination, fonts, diagrams, accessibility, and links. It also creates much larger files if pages are rasterized.
- AI annotations can be wrong in a particularly persuasive “teacher's note” style. Each generated note needs a confidence/provenance marker and an easy reject/edit path.
- Malformed or hostile PDFs should be processed in an isolated worker. Never execute attachments, embedded JavaScript, or model-produced code as part of annotation.
- Commercial use must respect the rights in the source PDF. A transformed copy is not automatically redistributable.

### Much simpler alternative

Keep the original PDF immutable. Generate a sibling Markdown file containing page/quote anchors, questions, explanations, and linked Excalidraw diagrams. Open the PDF and sidecar next to each other in Obsidian. Export a flattened annotated copy only on request.

### Clever implementation hacks

- Use a **dual-anchor** for every note: page/quadrilateral plus normalized quoted text and nearby context. If coordinates fail after a new edition, text can attempt reattachment.
- Preserve the source SHA-256 and record the tool/model/prompt version for every annotation batch.
- Separate annotation types: source fact, explanation, question, correction, analogy, and diagram. Render them differently so AI interpretation is never mistaken for original content.
- Keep SVG/Excalidraw source beside the PDF and insert only a lightweight thumbnail with a deep link to the editable scene.
- Let the user request “annotate only where confusion is likely” rather than filling every margin. Sparse, high-value annotation is cheaper and more believable.
- Run OCR only on pages without usable text; do not OCR a born-digital document by default.

### Recommended free-first stack

- Python, PyMuPDF, OCRmyPDF/Tesseract for scans, FastAPI worker.
- PDF.js plus React/Vite or SvelteKit for the local viewer.
- Excalidraw component for editable diagrams.
- SQLite for annotation objects; JSON sidecars for portability.
- Local vision-language model for page understanding and local instruction model for note drafts.

Pay for Mathpix when mathematical OCR accuracy is the blocker; its API explicitly supports printed and handwritten STEM material from images, strokes, and PDFs. [Mathpix OCR API](https://docs.mathpix.com/) Pay for a hosted multimodal model only for difficult page-layout/diagram reasoning, and send cropped regions rather than entire private books where possible.

### Verdict

**Build a sidecar-first annotator. Skip full PDF regeneration and cosmetic distressing until anchors, provenance, and editing are trustworthy.**

---

## 6. Understand This Paper

### Project interpretation

Upload a paper or arXiv link and receive a source-grounded map of the argument, equation-by-equation explanations, symbol definitions, pseudocode, assumptions, figures, and optional interactive visualizations.

### Closest building blocks and prior art

- Meta's Nougat parses academic PDFs into a Markdown-like format with LaTeX math and tables. Its repository states that it works best on English scientific papers similar to arXiv/PMC material. The code is MIT-licensed, but the model weights are CC BY-NC, which is a commercial-product constraint. [Nougat repository](https://github.com/facebookresearch/nougat)
- Semantic Scholar's official Academic Graph API exposes paper, author, citation, reference, and embedding fields. Most endpoints are public but rate limited; API keys have separate limits. [Semantic Scholar API](https://api.semanticscholar.org/api-docs), [API access overview](https://www.semanticscholar.org/product/api)
- Mathpix recognizes printed and handwritten STEM content and outputs Mathpix Markdown; its current developer plan is usage-based and lists a one-time setup fee, so it is better as a precision fallback than the default personal pipeline. [Mathpix documentation](https://docs.mathpix.com/), [Mathpix API pricing](https://website.mathpix.com/pricing/api)
- PyMuPDF and OCRmyPDF cover born-digital extraction and scanned-page OCR respectively. [PyMuPDF text recipes](https://pymupdf.readthedocs.io/en/latest/recipes-text.html), [OCRmyPDF](https://ocrmypdf.readthedocs.io/en/latest/)

### Strongest feasibility pointers

- A useful product does not need to “understand all science.” It can reliably create a navigable paper object: sections, paragraphs, equations, figures, references, and source boxes.
- Equation explanation becomes safer when each equation has a symbol ledger linked to its surrounding definitions and earlier equations.
- Pseudocode can be explicitly marked as an interpretation and tied to the methods paragraphs from which it was derived.
- Citation-graph enrichment is separable from document explanation and can be cached across users.

### Drawbacks, concerns, and hidden costs

- Academic PDFs often lose semantic structure; even Nougat's own project notes language/domain limitations and occasional missing-page failures. [Nougat limitations](https://github.com/facebookresearch/nougat#faq)
- Equation OCR errors can silently change subscripts, signs, bounds, or Greek letters. A fluent explanation of the wrong equation is worse than an obvious parser error.
- Variable meanings are often distributed across prose, captions, appendices, and earlier sections. A local chunk-only prompt will miss them.
- Nougat's noncommercial model-weight license prevents simply carrying the personal prototype unchanged into a paid service. [Nougat licensing](https://github.com/facebookresearch/nougat#license)
- Arbitrary 3D visualization is not a generic capability. Only equations with a known mapping, domain, and safe numerical evaluation can be visualized honestly.
- Running paper-supplied or LLM-produced code is a sandboxing problem. Keep code generation separate from execution and use strict resource/network limits if execution is added.
- Medical, financial, or engineering conclusions need conspicuous “explanation, not validation” boundaries.

### Much simpler alternative

Support only arXiv-style English PDFs. Produce: one-page argument map, section summaries with page citations, equation cards with rendered LaTeX and variable definitions, and five comprehension questions. Omit 3D visualization and code execution.

### Clever implementation hacks

- Represent each equation as `{latex, page, bbox, preceding_definition_spans, symbol_table, assumptions, units, downstream_uses}`.
- Render extracted LaTeX back to an image and compare it visually with the source crop; route large mismatches for manual correction.
- Ask the user to click the exact equation or paragraph they do not understand. Region-specific explanation is more accurate and much cheaper than regenerating the paper.
- Generate two explanations: “literal walk-through” and “why it is here.” The latter forces connection to the paper's argument.
- Whitelist visualization templates—scalar function, vector field, probability distribution, optimization surface, graph, geometry—instead of asking a model to invent a renderer.
- Use retrieval over paragraph/equation objects, not arbitrary fixed-size text chunks.

### Recommended free-first stack

- PyMuPDF → Nougat fallback for personal/noncommercial use → OCRmyPDF for scans.
- Python/FastAPI, SQLite or DuckDB, local embeddings, local LLM.
- KaTeX/MathJax in a SvelteKit or React UI; Plotly or Three.js only for whitelisted visualization schemas.
- Semantic Scholar API for citation/reference enrichment.
- PDF.js source viewer with synchronized equation/paragraph cards.

Pay for Mathpix when equation/table extraction error rates are blocking the workflow. Pay for a strong hosted model for difficult explanations after sending only the necessary, de-identified spans. Before commercial launch, replace or separately license any noncommercial model weights.

### Verdict

**Build a narrow, source-grounded paper explainer. Skip universal 3D and automatic code execution; treat commercial model licensing as an early architecture decision.**

---

## 7. Language Learning Lab

### Project interpretation

A local-first vocabulary, sentence, listening, speaking, and pronunciation lab that ranks useful words/phrases, creates contextual practice, and visualizes where the learner's recording diverges from a target.

### Closest building blocks and prior art

- Mozilla Common Voice publishes community-created speech datasets across many locales. Current dataset listings identify the license per dataset; many scripted-speech releases are CC0, but size and coverage vary dramatically by language. [Common Voice datasets](https://commonvoice.mozilla.org/en/datasets)
- Tatoeba distributes sentence, translation-link, tag, transcription, and audio metadata dumps. It offers a CC0 sentence subset, while audio files carry per-recording licenses and recordings with an empty license may not be reused outside Tatoeba. [Tatoeba downloads](https://tatoeba.org/en/downloads)
- Montreal Forced Aligner is an open-source command-line utility built around Kaldi for aligning speech with transcripts using acoustic models and pronunciation dictionaries. [Montreal Forced Aligner](https://github.com/MontrealCorpusTools/Montreal-Forced-Aligner)
- eSpeak NG is an open-source synthesizer; its development documentation currently lists 127 languages and accents and exposes pronunciation rules/dictionaries. It is useful for phoneme generation and broad free coverage, though not a substitute for natural native audio. [eSpeak NG languages](https://github.com/espeak-ng/espeak-ng/blob/master/docs/languages.md), [pronunciation rules](https://github.com/espeak-ng/espeak-ng/blob/master/docs/dictionary.md)
- Browser `AnalyserNode` can expose frequency and time-domain audio data for visualizations. A waveform or spectrogram is technically easy; pedagogically meaningful pronunciation feedback is the harder layer. [Web Audio visualization guide](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API/Visualizations_with_Web_Audio_API)

### Strongest feasibility pointers

- Word/phrase scheduling, example-sentence selection, recording, playback, forced alignment, and minimal-pair drills are all feasible locally.
- Pronunciation feedback can start with duration, missing/extra segments, stress position, and phoneme-level alignment rather than a mystical single “accent score.”
- FSRS can schedule vocabulary and listening prompts; speaking tasks can use separate recent-error sampling.

### Drawbacks, concerns, and hidden costs

- Frequency lists answer “common in which corpus?” Spoken, written, regional, formal, and domain corpora produce different rankings.
- Community sentence and audio data require record-level license handling and quality filtering. Tatoeba's own downloads expose differing licenses, so flattening all entries into one commercial database is unsafe. [Tatoeba downloads](https://tatoeba.org/en/downloads)
- Speech datasets underrepresent some groups and languages; Mozilla explicitly identifies representation gaps as a motivation for Common Voice. Model accuracy and feedback fairness will therefore vary. [Why Common Voice](https://commonvoice.mozilla.org/en/about)
- A waveform resemblance score rewards timing and loudness without necessarily rewarding intelligibility. Use phonetic alignment and human-calibrated thresholds.
- “Get the accent right” can unintentionally penalize valid regional accents. Let the learner choose a target variety and distinguish intelligibility from imitation.
- Voice recordings are sensitive biometric-like data. Keep raw audio local, provide deletion, and upload only with explicit consent.

### Much simpler alternative

Choose one target language and one accent. Build 500 high-value phrases, native/reference audio, record-and-compare playback, cloze cards, and a daily ten-minute queue. Use existing Anki/FSRS for scheduling.

### Clever implementation hacks

- Capture the target variety in every item, for example `en-IN`, `en-US`, `fr-FR`, rather than a generic language code.
- Align at phoneme boundaries and let the learner tap a phoneme to hear target, self, and an exaggerated instructional version.
- Show **late/early, missing, substituted, stress mismatch** labels instead of a radar chart with no diagnostic meaning.
- Prefer minimal-pair contrasts based on the learner's recurring confusions.
- Use native corpus sentences as anchors and let the LLM vary the scenario while preserving the target grammar; label generated sentences and allow correction.
- Store per-item provenance and license so a personal collection can later be filtered to a commercially usable subset.

### Recommended free-first stack

- React/Vite PWA, Web Audio API, IndexedDB.
- Python/FastAPI for alignment, Montreal Forced Aligner, eSpeak NG, local Whisper for transcription checks.
- SQLite/DuckDB for phrase, license, and attempt metadata; an FSRS library for reviews.
- Tatoeba CC0 subset and appropriately licensed audio; Common Voice for model evaluation or selected examples where the dataset terms permit.

Pay for high-quality native TTS or ASR when a target language lacks usable free models or low latency is essential. Pay native teachers for evaluation data before paying to scale the app; a small, trusted pronunciation rubric is more valuable than a larger unvalidated model.

### Verdict

**Build one language-and-accent lab first. Skip “all languages” and universal accent scoring until datasets, licenses, and evaluation are solved per locale.**

---

## 8. LeetCode Pattern Curriculum

### Project interpretation

A personal curriculum organized by problem-solving patterns, using selected LeetCode links and legally reusable solution material, with explanation, hint ladders, tests, spaced review, and progress diagnostics.

### Closest building blocks and prior art

- Python's standard `ast` module exposes the abstract syntax tree and is sufficient for lightweight structural checks such as detecting recursion, loops, comprehensions, or particular call patterns. [Python `ast` documentation](https://docs.python.org/3/library/ast.html)
- Judge0 is a GPLv3 self-hostable, sandboxed code-execution system supporting many languages, time/memory limits, and multi-file programs. [Judge0 source](https://github.com/judge0/judge0)
- Piston is an MIT-licensed self-hosted code execution engine using Isolate and Docker with resource limits and network disabled by default. Its repository now states that its public API is no longer generally free and that authorization is limited to qualifying noncommercial, low-volume uses, so self-hosting is the realistic free path. [Piston source and access policy](https://github.com/engineer-man/piston)

### Verified content/platform boundary

LeetCode's Terms explicitly prohibit crawling, scraping, or spidering any part of the service. A curriculum should link to problem pages and store user-authored metadata/notes rather than mirror the problem corpus through an automated scraper. [LeetCode Terms of Service](https://leetcode.com/terms/)

GitHub repositories containing solutions are separate copyrighted works whose reuse depends on each repository's license. “Public on GitHub” is not by itself a license to copy, remix, or sell.

### Strongest feasibility pointers

- The valuable dataset can be authored rather than scraped: pattern, prerequisites, difficulty, invariants, common mistakes, link, and original explanation.
- For a personal Python-only build, the user's own code can run under local tests without operating a public untrusted-code service.
- The curriculum and FSRS layers can be shared with Personal Study Curriculum.

### Drawbacks, concerns, and hidden costs

- Mirroring statements, examples, editorials, or other people's solutions creates terms and copyright risk.
- A public code runner is security infrastructure, not a normal web feature. Containers alone are not an excuse to run arbitrary code without isolation, quotas, monitoring, and patching.
- Pattern labels can become answer leaks. The learning sequence should sometimes hide the pattern and require classification first.
- AST similarity is a weak plagiarism or understanding measure; different correct algorithms can look structurally similar and copied code can be obfuscated.
- LLM explanations can produce code that passes sample tests but fails edge cases. Curated property tests matter.
- Competitive-programming performance is not a complete proxy for software-engineering skill.

### Much simpler alternative

Create a Markdown curriculum of 40–60 links, grouped by ten patterns, with one original explanation and a local `pytest` file per pattern. Use Anki/FSRS to schedule “name the invariant,” “derive the recurrence,” and “choose the data structure” prompts.

### Clever implementation hacks

- Separate four tasks: recognize pattern, state invariant, implement, and adapt under a changed constraint.
- Give hints as a ladder—counterexample, invariant, data-structure clue, pseudocode—rather than one generated answer.
- Generate adversarial tests from the invariant and known failure modes, then freeze reviewed tests.
- Track the earliest hint used and time-to-correct, not only pass/fail.
- After a solved problem, generate a “near transfer” variant by changing one constraint; do not reuse LeetCode text.
- Use AST only to power explanation (“you used nested loops here”), never as the sole correctness judgment.

### Recommended free-first stack

- Markdown/YAML curriculum, Python, pytest/hypothesis, SQLite, FSRS.
- Local static or Vite/SvelteKit UI with Monaco only if browser editing is useful.
- For personal code, run in a dedicated local environment with timeouts. If shared with others, self-host Piston or Judge0 on an isolated Linux host and treat it as security-sensitive.
- Local LLM for hint drafts; reviewed template library for common patterns.

Paid services are unnecessary for the personal version. Pay for managed sandboxing only when accepting untrusted public submissions. A paid model is justified for explanation quality only after deterministic tests and curated solutions remain the authority.

### Verdict

**Build as an original, link-based personal curriculum. Skip scraping, mirroring, and a public code runner in v1.**

---

## 9. Handwriting to LaTeX

### Project interpretation

A system hotkey, desktop app, or mobile capture tool that converts an isolated handwritten or printed equation into LaTeX, renders a preview, exposes ambiguities, and copies corrected output.

### Closest building blocks and prior art

- `pix2tex`/LaTeX-OCR provides local image-to-LaTeX inference, clipboard/screenshot workflows, a GUI, and a local API. Its own documentation says it works best on smaller-resolution equation images and instructs users to double-check results. [LaTeX-OCR](https://github.com/lukas-blecher/LaTeX-OCR/blob/main/README.md)
- Microsoft's TrOCR is an end-to-end text recognition model with printed and handwritten checkpoints. It is useful for surrounding prose, but it is a text recognizer rather than a dedicated two-dimensional mathematical-expression parser. [TrOCR](https://github.com/microsoft/unilm/blob/master/trocr/README.md)
- CROHME provides benchmark data and InkML for online handwritten mathematical expressions, but the official data page restricts the material to research use without commercial use. Do not silently train a commercial feature on it. [CROHME data and terms](https://www.isical.ac.in/~crohme/CROHME_data.html)
- Mathpix supports printed and handwritten math from images and stroke data and returns Mathpix Markdown/LaTeX-related formats. [Mathpix OCR API](https://docs.mathpix.com/)

### Strongest feasibility pointers

- Isolated equation crops are a much easier and more useful target than full notebook-page understanding.
- A DGX/local GPU can run `pix2tex` with near-zero marginal cost.
- Rendering the output immediately through KaTeX/MathJax gives the user a visual correction loop.
- If the input is captured as pen strokes rather than a photo, stroke order and grouping provide useful information lost in raster OCR.

### Drawbacks, concerns, and hidden costs

- Math is two-dimensional: fraction bars, roots, matrices, superscripts, subscripts, alignment, and cases make segmentation the real problem.
- Handwriting ambiguities—`1/l`, `0/O`, `x/×`, `v/ν`, minus/fraction bar—cannot always be resolved from pixels alone.
- A syntactically valid LaTeX string can still represent the wrong equation.
- Full-page mixed text/math requires layout detection and separate recognizers, increasing latency and error modes.
- Training-data licenses are a product constraint; CROHME's official set is research-only. [CROHME data terms](https://www.isical.ac.in/~crohme/CROHME_data.html)
- A cloud API sees potentially private notes and exams.

### Much simpler alternative

Ship a system-tray hotkey: drag a rectangle around one equation, run `pix2tex`, display rendered LaTeX beside the crop, and copy on confirmation. No accounts, notebook manager, or page OCR.

### Clever implementation hacks

- Try several normalized resolutions and use agreement among predictions as a confidence signal; `pix2tex` itself notes sensitivity to input resolution. [LaTeX-OCR usage notes](https://github.com/lukas-blecher/LaTeX-OCR/blob/main/README.md)
- Return an n-best list only for ambiguous spans, not five full equations.
- Make rendered tokens clickable so selecting a wrong symbol highlights its source region.
- Run a LaTeX parser and dimensional/symbol sanity checks before presenting “high confidence.”
- If using a stylus app, retain InkML-like strokes and fall back to raster only for pasted images.
- Learn a private confusion map from user corrections without retraining the whole model.

### Recommended free-first stack

- Python, PyTorch, `pix2tex`, Pillow/OpenCV preprocessing.
- Tauri system tray or a small Qt app; global hotkey and clipboard integration.
- KaTeX/MathJax preview; SQLite correction history.
- Optional local vision model for a second opinion on low-confidence crops.

Pay for Mathpix when messy handwriting, matrices, mixed pages, or reliability make the local correction time unacceptable. Its pricing should be compared per corrected equation, not per API call. For a commercial product, audit every model and training-data license before launch.

### Verdict

**Build the isolated-equation hotkey now. Skip full-page handwriting transcription until the correction UX proves valuable.**

---

## 10. Visual Token Compiler

### Project interpretation

Working assumption: “a picture is worth a thousand tokens” means compiling structured text, tables, diagrams, or UI state into a dense image/SVG so a vision-language model can consume it with fewer billed tokens or better spatial understanding. If the intended idea is instead general image-to-prompt compression, the same benchmark-first conclusion applies.

### Closest building blocks and prior art

- Satori converts a subset of HTML/CSS/JSX to SVG in browsers, Node, and workers. It is useful for deterministic visual layouts, but its project documents unsupported CSS/typography features and does not guarantee a pixel-perfect browser match. [Satori](https://github.com/vercel/satori)
- Playwright can capture full pages, elements, or clipped regions to buffers/images, providing a reproducible renderer and test harness. [Playwright screenshots](https://playwright.dev/docs/screenshots)
- Gemini's official image documentation makes the core economic caveat explicit: images are tokenized, small images have a fixed token cost, larger images are tiled, and higher media resolution improves fine-text reading while increasing token use and latency. [Gemini image token calculation](https://ai.google.dev/gemini-api/docs/image-understanding), [Gemini token counting](https://ai.google.dev/gemini-api/docs/tokens)

### Strongest feasibility pointers

- A compiler that emits a visual artifact plus a machine-readable source map is straightforward.
- Tables, timelines, topology, and layout relationships may be easier for a multimodal model to interpret visually than after lossy textual serialization.
- The genuinely useful product is an **optimizer and benchmarker**: given content and a target model, compare plain text, structured text, SVG/raster, and hybrid encodings for cost and task accuracy.

### Drawbacks, concerns, and hidden costs

- An image is not inherently cheaper. Provider tiling/resolution policies can make dense fine text more expensive, and the policies vary by model.
- Smaller fonts and denser layout trade token count for OCR errors. A visually valid image can be semantically unreadable to the model.
- Screenshots lose searchable text, semantic structure, precise citations, copy/paste, and accessibility unless a sidecar is retained.
- Visual prompt injection or tiny hidden text can become hard for the user to audit.
- Model updates can invalidate the optimal layout. Do not hard-code one provider's tile math as a universal rule.
- Benchmark leakage is easy: if evaluation questions are generated from the same model that reads the image, apparent accuracy may be inflated.

### Much simpler alternative

First normalize content to concise Markdown/JSON, remove duplicated navigation and boilerplate, and call the provider's token-count endpoint. Use an image only when spatial relationships are the information, not as a blanket text-compression trick.

### Clever implementation hacks

- Emit a **dual payload**: visual canvas plus a compact text manifest listing entity IDs, reading order, and checksums.
- Tile content on semantic boundaries—table, diagram, card—not arbitrary pixel boundaries.
- Benchmark answer accuracy, citation accuracy, cost, latency, and failure rate across multiple font sizes and formats before choosing one.
- Use the target provider's current token-count API in the compiler loop. Refuse to claim savings without a measured baseline.
- Include OCR round-trip validation: render → OCR/read with a second model → compare to source.
- Preserve a source map from every visual box to original text so a model answer can be audited.
- Prefer SVG for deterministic generation and rasterize only to a model-supported MIME type at the edge.

### Recommended free-first stack

- TypeScript, Satori or browser HTML/CSS, Playwright, Sharp/resvg for raster output.
- Python evaluation harness, SQLite/DuckDB result store, local OCR/VLM for smoke tests.
- Provider adapters implementing `count_tokens`, upload, task run, and usage capture.
- A small static dashboard showing Pareto frontiers for cost versus accuracy.

The only necessary paid component is access to the actual target models being optimized. Pay for evaluation calls in a bounded benchmark set; do not build a subscription product until recurring savings exceed both inference and engineering costs.

### Verdict

**Prototype as a measurement and encoding lab. Skip any “one image always saves a thousand tokens” claim until model-specific benchmarks prove it.**

---

## 11. EPUB Highlights Bridge

### Project interpretation

A local adapter system that imports highlights, notes, and reading positions from user-owned EPUB workflows into stable Markdown/Obsidian notes, preserving book identity and deep links where the source reader permits them.

### Closest building blocks and prior art

- EPUB 3 is a ZIP-based package of structured XHTML/SVG and related resources, giving a bridge access to the actual text structure for DRM-free/user-owned files. [EPUB 3.3 specification](https://www.w3.org/TR/epub-33/)
- EPUB Canonical Fragment Identifiers define a standardized way to reference arbitrary content and ranges inside an EPUB. They are useful anchors, though actual reader support and vendor storage formats differ. [EPUB CFI 1.1](https://idpf.org/epub/linking/cfi/), [ISO description](https://www.iso.org/standard/63571.html)
- Calibre's viewer supports highlights with notes, a library-wide annotation browser, Content Server annotation synchronization, and location URLs that reopen a book at a position. [Calibre viewer manual](https://manual.calibre-ebook.com/viewer.html)
- KOReader supports many e-reader platforms and formats. Its user guide documents highlight export to text, HTML, JSON, or Markdown, which makes it a much cleaner initial adapter than reverse-engineering a proprietary cloud. [KOReader project](https://github.com/koreader/koreader), [KOReader user guide](https://koreader.rocks/koreader-user-guide.pdf)

### Verified Kindle boundary

Amazon's current help documentation describes syncing text highlights and annotations across Kindle surfaces, but this review did not find a first-party developer API for exporting personal-document annotations. Treat Kindle as a user-driven import boundary rather than promising automatic cloud extraction. [Kindle annotation sync help](https://digprjsurvey.amazon.com/csad/help/node/GDCAMDFMC2LZP6BR)

Amazon's DRM documentation also makes clear that DRM controls whether purchased books can be downloaded outside Kindle apps/devices. The bridge should not include DRM circumvention. [Amazon DRM help](https://kdp.amazon.com/en_US/help/topic/GDDXGH9VR22ACM8U)

### Strongest feasibility pointers

- Calibre and KOReader already provide exportable/local annotation paths. A high-value MVP can be a folder watcher and normalizer rather than a reader.
- For DRM-free EPUBs, the quoted text can be re-located in the book content and enriched with chapter hierarchy and surrounding context.
- Markdown output is naturally compatible with Obsidian and Git versioning.

### Drawbacks, concerns, and hidden costs

- CFI and vendor positions can drift when the EPUB file or edition changes.
- The same title may exist as different files, ISBNs, revisions, or conversions; filename/title matching alone will merge the wrong books.
- Annotation formats vary by reader, and some are undocumented internal databases that can change without notice.
- Notes may contain private journal-like material. Default to a local store and explicit exports.
- Duplicate highlights arise when syncing, reimporting, or reading on multiple devices.
- Content and annotation export rights differ from the right to redistribute the underlying book.

### Much simpler alternative

Use Calibre or KOReader's existing Markdown export and point it at an Obsidian inbox folder. Add a small script that applies a consistent frontmatter/template and moves processed files into one note per book.

### Clever implementation hacks

- Identify a book using a hierarchy: embedded identifier/ISBN → normalized title/author/edition → EPUB content hash. Never rely on filename alone.
- Store four anchors for each highlight: source-native position, CFI if available, exact quote hash, and surrounding-text context.
- Merge duplicates by normalized quote plus approximate location, but retain every source event for audit.
- Separate immutable import records from editable Markdown notes. A reimport should update the source block without overwriting user commentary.
- Generate deep links only for readers that document a stable scheme; otherwise link to the book and include chapter/reference text.
- Maintain an adapter capability matrix: import, export, notes, colors, positions, timestamps, and supported book formats.

### Recommended free-first stack

- Python, `zipfile`/XML parsing or EbookLib, SQLite, watchdog folder monitoring.
- Adapter inputs: Calibre annotation exports/database, KOReader Markdown/JSON exports, explicitly user-provided local files.
- Markdown renderer with stable block IDs and YAML frontmatter.
- Optional small Tauri tray app for import status and conflict resolution.

Pay only when a hosted synchronization connector genuinely saves repeated manual work and has an official, stable API. A Readwise-like paid product becomes justified by maintenance of many supported adapters, conflict handling, and reliable cloud/mobile sync—not by the Markdown transformation itself.

### Verdict

**Build Calibre and KOReader adapters now. Postpone automatic Kindle/cloud extraction unless Amazon exposes a suitable official interface or the user supplies an export file.**

---

## Recommended merge map and build order

### Shared products

1. **Learning and Information Workbench**
   - Personal Signal Intelligence OS
   - Personal Study Curriculum
   - YouTube Learning Center
   - Language Learning Lab
   - LeetCode Pattern Curriculum
   - EPUB Highlights Bridge

2. **Explainable Document Studio**
   - Half-Blood PDF
   - Understand This Paper
   - Handwriting to LaTeX

3. **Reading and Model-Input Experiments**
   - Bionic Reading Trainer
   - Visual Token Compiler

### Suggested implementation sequence

1. Establish canonical source/provenance objects, SQLite schema, content hashes, and Markdown rendering.
2. Build FreshRSS/manual-share ingestion and a daily signal note.
3. Add Personal Study Curriculum with FSRS and weekly reviews.
4. Add LongVid transcript/timestamp objects and playlist coverage reports.
5. Add EPUB highlight normalization.
6. Build the PDF viewer/sidecar annotation layer.
7. Add academic-equation objects and the handwriting hotkey.
8. Add specialized curricula for language and coding.
9. Run Bionic Reading and Visual Token Compiler as instrumented experiments rather than product dependencies.

### Architecture rule worth preserving

Every generated claim, note, flashcard, explanation, or summary should be able to answer:

- What source span produced this?
- Which model/rule and version produced it?
- What confidence or validation does it have?
- Has the user accepted, corrected, or rejected it?
- May this source/output be reused in a commercial product?

That provenance layer is the most reusable—and monetizable—technical asset across all eleven ideas.
