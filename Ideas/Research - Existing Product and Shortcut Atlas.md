---
type: research-note
status: active
created: 2026-07-27
scope: all project specs
tags:
  - research
  - prior-art
  - open-source
  - shortcuts
---

# Research - Existing Product and Shortcut Atlas

This note collects reusable products, APIs, open-source components, and command-line shortcuts that recur across the personal project portfolio and the Hermes hackathon ideas. Each project spec still names its closest alternatives; this atlas explains which parts are worth borrowing and which parts should remain custom.

## 1. The Reusable Engines Hiding Under the Ideas

### Ingestion and research engine

Use this for [[LongVid Learning Studio]], [[Personal Signal Intelligence OS]], [[Understand This Paper]], news briefings, competitor research, knowledge-base work, and content repurposing.

- [FreshRSS](https://github.com/FreshRSS/FreshRSS) and [RSSHub](https://github.com/DIYgod/RSSHub) cover feeds before a custom scraper is justified.
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) handles media metadata, caption files, and permitted local downloads.
- [Mozilla Readability](https://github.com/mozilla/readability) extracts article text from ordinary pages; [Playwright](https://playwright.dev/) is the heavier fallback for rendered sites.
- [Whisper](https://github.com/openai/whisper) and [faster-whisper](https://github.com/SYSTRAN/faster-whisper) provide a local transcription path.
- [Docling](https://github.com/docling-project/docling), [PyMuPDF](https://github.com/pymupdf/PyMuPDF), and [OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) cover born-digital and scanned documents.
- [DuckDB](https://duckdb.org/docs/stable/) or SQLite can store normalized items and provenance without operating a database server.

The custom value should be the personal ranking model, durable provenance, workflow, and output format—not another general-purpose downloader.

### Structured writing desk

Use this for email rewriting, investor updates, review replies, listings, applications, support answers, and social drafts.

- Use model [structured outputs in Ollama](https://docs.ollama.com/capabilities/structured-outputs) or an equivalent provider schema, validated with Zod or Pydantic.
- Keep facts and calculations in ordinary code. Give the model validated fields and ask it to narrate them.
- Export to clipboard, Markdown, or an official draft API first. For example, the [Gmail Drafts API](https://developers.google.com/workspace/gmail/api/guides/drafts) preserves review before sending.
- Store the source facts and the final approved edit together so future evaluations can compare model output with what the user actually accepted.

The shortcut is to build one schema-driven editor with per-project templates instead of a separate application for every writing task.

### Bot, scheduler, and approval engine

Use this for personal CRM, reminders, daily check-ins, briefings, planner workflows, and lightweight agents.

- [Telegram Bot API](https://core.telegram.org/bots/api) is generally the fastest personal bot channel.
- [APScheduler](https://github.com/agronholm/apscheduler), Windows Task Scheduler, or `systemd` timers cover local schedules before a workflow platform is needed.
- [n8n](https://github.com/n8n-io/n8n) is valuable when the workflow is mostly integrations and human approval nodes.
- [XState](https://github.com/statelyai/xstate) makes multi-step conversations and approval states explicit rather than leaving them inside prompts.
- SQLite is enough for jobs, reminders, run logs, and retry state on one machine.

Treat every consequential action as `proposed -> reviewed -> executed -> verified`. This state machine is reusable across calendar edits, mail drafts, posts, applications, cancellations, trades, and device control.

### Local ledger and reconciliation engine

Use this for [[Net Worth Command Center]], [[Paisa Vasool Subscriptions]], finance operations, invoices, and tax packets.

- [Actual Budget](https://github.com/actualbudget/actual) and [Firefly III](https://github.com/firefly-iii/firefly-iii) are complete self-hosted references.
- [Beancount](https://github.com/beancount/beancount) and [hledger](https://hledger.org/) demonstrate durable plain-text double-entry accounting.
- [DuckDB](https://duckdb.org/) is excellent for querying many CSV and Parquet exports without importing them into a server.
- Build one adapter per institution/export, retain the original file hash, and reconcile totals before any dashboard metric is trusted.

The highest-value custom layer is not the chart. It is the adapter test suite, duplicate detection, account mapping, reconciliation report, and correction workflow.

### Browser evidence worker

Use this for landing-page audits, job capture, form assistance, competitor monitoring, and site diagnostics.

- [Playwright](https://playwright.dev/) provides deterministic navigation, screenshots, accessibility trees, and browser contexts.
- [Lighthouse](https://github.com/GoogleChrome/lighthouse) and [axe-core](https://github.com/dequelabs/axe-core) replace model guesses with measurable evidence.
- [Mozilla Readability](https://github.com/mozilla/readability) is a cheap first pass for content extraction.
- Browser extensions should use [Manifest V3](https://developer.chrome.com/docs/extensions/develop/migrate/what-is-mv3) and the smallest possible host permissions.

For arbitrary URLs, isolate the worker and reject localhost, private IP ranges, unusual schemes, and uncontrolled redirects. The first version can often accept pasted text or an uploaded screenshot and avoid URL-fetching risk entirely.

### Share-card and report engine

Use this for quizzes, roast tools, market cards, progress summaries, and social-ready outputs.

- [Satori](https://github.com/vercel/satori) renders HTML/CSS-like JSX to SVG.
- [resvg-js](https://github.com/thx/resvg-js) converts those SVGs to PNG.
- [Chart.js](https://github.com/chartjs/Chart.js) is sufficient for small interactive charts; [Observable Plot](https://github.com/observablehq/plot) is strong for concise exploratory graphics.
- Keep the canonical output as structured JSON plus HTML/Markdown. The image is a derived artifact that can always be regenerated.

## 2. How YouTube Summaries Usually Work

There is no single universal public transcript API for every YouTube video. Products commonly combine several paths and hide that routing behind one URL box.

### Path A: use captions already attached to the video

[NotebookLM’s YouTube documentation](https://support.google.com/notebooklm/answer/16215270) says that it imports the transcript of a public YouTube video with captions and does not import the video itself. A local implementation can follow the same transcript-first strategy:

```powershell
yt-dlp --write-auto-subs --write-subs --skip-download --sub-format vtt "VIDEO_URL"
```

Normalize the VTT into timestamped segments, retain caption provenance and language, then summarize segments hierarchically. This is fast and cheap, but it misses information that appears only on screen.

### Path B: transcribe the audio

When a usable caption track is unavailable, extract audio and run local speech recognition:

```powershell
yt-dlp -x --audio-format m4a "VIDEO_URL"
faster-whisper "downloaded-audio.m4a" --model large-v3 --output_format json
```

The exact faster-whisper invocation depends on the installed wrapper; its Python API is usually the more dependable production interface. Add voice-activity detection and preserve word/segment timestamps. This path costs compute and can mishandle names, code, formulas, and multilingual speech.

### Path C: send the video to a multimodal model

The [Gemini API video-understanding documentation](https://ai.google.dev/gemini-api/docs/video-understanding) supports public YouTube URLs as video input. This lets Gemini reason about both audio and sampled frames without LongVid first building its own transcript pipeline. It is the fastest hosted prototype and a useful quality benchmark, but it introduces provider limits, changing price/availability, and weaker local provenance.

### Path D: upload a media file to a research product

[Perplexity’s file-upload documentation](https://www.perplexity.ai/help-center/en/articles/10354807-file-uploads) describes transcription of uploaded audio and video files; it also says visual scenes are not indexed. Its public documentation does not establish a stable arbitrary-YouTube-URL transcript API. Treat any convenient URL behavior in a consumer interface as product behavior, not as an integration contract.

### What the official YouTube API does and does not solve

The [YouTube Data API](https://developers.google.com/youtube/v3/docs) is the correct source for titles, channels, durations, playlists, thumbnails, and other metadata. The [`captions.download` endpoint](https://developers.google.com/youtube/v3/docs/captions/download) requires authorization with permission to edit the video, so it is not a universal transcript endpoint for third-party public videos.

### Recommended LongVid router

1. Fetch official metadata.
2. Try user-provided or retrievable caption tracks.
3. If missing or poor, ask permission to extract audio and run faster-whisper locally.
4. For videos where slides, diagrams, or demonstrations matter, sample scene-change frames with FFmpeg and run multimodal analysis.
5. Optionally send the public URL to Gemini as a benchmark or paid fast path.
6. Store which route produced every segment and expose a one-click correction workflow.

Useful inspection commands:

```powershell
yt-dlp --list-subs "VIDEO_URL"
yt-dlp --dump-single-json --skip-download "VIDEO_URL"
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "FILE"
ffmpeg -i "FILE" -vf "select='gt(scene,0.30)',showinfo" -vsync vfr "frames/%05d.jpg"
```

## 3. Free-First Stack Selection Rules

1. Prefer a local file or SQLite database until concurrent writers or remote access are real requirements.
2. Prefer a deterministic parser, calculator, search index, state machine, or rules engine wherever correctness can be expressed in code.
3. Use a local model for private bulk work; route only measured failure cases to a paid model behind the same adapter.
4. Prefer an official API for consequential writes. Use browser automation for read-only capture or explicit user-assisted flows, not as an invisible long-term contract.
5. Start with manual import/export when OAuth or platform approval would dominate the first prototype.
6. Record provenance, model/version, prompt/template version, and user corrections from the first usable build.
7. Build the smallest end-to-end loop that the owner will use repeatedly; postpone accounts, billing, teams, and generalized configuration.

## 4. Common Drawbacks and Cheap Defenses

| Failure mode | Cheap first defense |
|---|---|
| Model invents facts or numbers | Generate only from validated fields; show source evidence beside the draft |
| Scraper breaks | Support paste/upload/manual export as a stable fallback |
| Free API is too limited | Cache aggressively, use a bundled sample dataset, and make the adapter replaceable |
| Automation takes the wrong action | Proposal queue, preview, explicit confirmation, and post-action verification |
| Dashboard quietly contains stale data | Show source timestamp, adapter health, last successful sync, and reconciliation status |
| Personal data leaks to a provider | Local-first processing, field-level redaction, and an explicit provider-routing indicator |
| Viral score looks authoritative | Display method, evidence, cohort size, uncertainty, and “for entertainment” where appropriate |
| Prototype becomes 86 separate codebases | Consolidate into reusable engines with project-specific schemas, prompts, rules, and views |

## 5. Future Scope Reminder

These recommendations assume private, local, single-user experiments with user-supplied or user-authorized inputs. Before open-sourcing, hosting, monetizing, redistributing assets/data/models, or operating for other people, run [[Scope Expansion Checklist]]. That later review may change access methods, product policy, or release packaging; it should not distort the best stack for the current personal prototype.

## Related

- [[Project Ideas Index]]
- [[First Month Build Program]]
- [[Research - Information and Learning Ideas]]
- [[Research - Personal Systems and Product Ideas]]
- [[Research - Spatial Media and Experimental Ideas]]
- [[Scope Expansion Checklist]]
