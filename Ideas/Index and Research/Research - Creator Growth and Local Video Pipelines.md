---
title: Research - Creator Growth and Local Video Pipelines
type: research-dossier
status: researched
as_of: 2026-08-14
scope: personal-local-v0
source_policy: primary-sources-only
tags:
  - creator-tools
  - growth
  - social-media
  - video-generation
  - local-ai
  - rtx
---

# Research - Creator Growth and Local Video Pipelines

> [!summary]
> This dossier deliberately keeps seven project ideas self-contained. They may reuse the same content library, experiment ledger, approval queue, and media-processing workers, but they should not become one giant application. The only intentional idea merge is the Personal Voice Ghostwriter with the DM Desk because both depend on the same voice model, relationship context, and reply-review loop.

> [!important]
> The recommendations describe a personal, local-first V0. Rights, licensing, platform-policy, consent, and multi-user governance should be revisited before open-sourcing, selling, publishing at scale, processing other people's private data, or enabling unattended outreach. That future review should not force a different V0 stack today. Platform API availability and anti-automation controls are still noted where they determine whether a proposed implementation can technically work.

## 1. Meta Ad Creative Studio

### Refined problem statement

Build a local creative workbench that turns a product brief into an evidence-linked set of Meta ad concepts, variants, and exportable creative packs. Its job is not to claim that an LLM knows which advertisement will win. Its job is to make a disciplined creative-testing loop cheap: state a hypothesis, derive intentionally different concepts, produce the assets, record what changed, export them in placement-ready forms, and join actual results back to the originating hypothesis.

This should remain separate from the Demand Generation Workbench. The ad studio operates at the creative-unit level; the demand workbench decides which market and message deserve experiments.

### What Meta's own tooling already does

Meta already supplies substantial creative automation through [Advantage+ creative](https://www.facebook.com/business/ads/meta-advantage-plus/creative): text variations, automatic image expansion and backgrounds, animation from static images, music, and placement adaptation. Meta's [ad creative guidance](https://www.facebook.com/business/ads/ad-creative) and [performance guidance](https://www.facebook.com/business/ads/performance-marketing) both emphasize diversified creative and learning through delivery. Its [photo-ad guidance](https://www.facebook.com/business/ads/photo-ad-format) recommends a clear focal point, high-resolution imagery, and experimentation with different visuals.

Those features are a reason not to rebuild generic resizing, minor copy mutation, or automatic placement crops as the core value. The useful local layer is upstream and downstream of Ads Manager:

- upstream: product evidence, concept diversity, hooks, scripts, storyboards, brand memory, and a traceable hypothesis matrix;
- downstream: asset QA, naming, export bundles, UTM conventions, and outcome analysis by creative concept rather than by filename alone.

Meta maintains an official [Python Business SDK](https://github.com/facebook/facebook-python-business-sdk) for the Marketing API. It supports ad-account, campaign, ad-set, ad, and creative operations, including batched requests, but production use requires the relevant Meta application setup and permissions such as `ads_management`. The API is therefore an optional scale adapter, not a prerequisite for the personal V0.

### Claude/design tooling: useful role and hard boundary

Anthropic's official [frontend-design skill](https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md) is a useful design-process reference: choose a context-specific visual direction, deliberate type, color and composition, and avoid interchangeable “AI-looking” design. Use Claude or another strong model to produce a structured art-direction brief and to critique whether variants are genuinely distinct. Do not use an LLM's confidence or aesthetic commentary as a proxy for ad performance.

A productive creative record is:

```yaml
creative_id: meta-2026-08-001
product: example-tool
audience: "researchers drowning in long videos"
problem: "useful facts are buried in hours of footage"
promise: "turn a video into a navigable learning artifact"
proof:
  - "chapter-level citations"
  - "answers link back to timestamps"
hypothesis: "showing evidence navigation will outperform generic AI-summary claims"
concept: "the missing table of contents"
hook: "This 90-minute video should have been searchable."
format: vertical-demo
placement: reels
cta: "Join the private beta"
changed_variable: hook
source_assets:
  - product-demo-03.mp4
status: drafted
```

One variant should change one declared variable whenever practical. If the hook, audience, footage, offer, music, and CTA all change at once, a result cannot teach the system much.

### Higgsfield: borrow for hosted production, do not mistake it for local inference

Higgsfield exposes a Windows-compatible [CLI and MCP integration](https://higgsfield.ai/cli) that can be called from Claude Code, Claude Cowork, and other agent environments. Its [official CLI repository](https://github.com/higgsfield-ai/cli) shows authentication, asynchronous generation, polling, and access to its hosted model catalog, including marketing-oriented templates and third-party video models. The [model catalog](https://github.com/higgsfield-ai/cli/blob/main/MODELS.md) is a useful source for the exact operations available at a given time.

The architectural boundary is important: installing the Higgsfield CLI locally does **not** run Higgsfield, Kling, Veo, Hailuo, or its other catalog models on the RTX GPU. Jobs run on Higgsfield's servers, consume hosted credits, and return media asynchronously. Treat Higgsfield as a swappable hosted render adapter alongside local ComfyUI workers. Persist the prompt, selected model/version label, request parameters, request and completion timestamps, cost/credit metadata where available, and returned asset. Hosted model behavior can change without a local commit hash.

### Recommended build-vs-borrow split

| Capability | Build locally | Borrow |
|---|---:|---|
| Product evidence and approved-claim library | Yes | Markdown/Obsidian files as source material |
| Creative hypothesis matrix and lineage | Yes | SQLite |
| Concept generation and critique | Thin orchestration only | Local or paid LLM behind one adapter |
| Static visual composition | Templates and brand tokens | HTML/CSS + Playwright screenshot, SVG, or a design tool |
| Hosted generative video | No | Higgsfield CLI/API-style adapter |
| Local generative video | No model implementation | ComfyUI workflows from section 7 |
| Placement resize and encode | No custom codec work | FFmpeg; Meta's own placement adaptation where suitable |
| Campaign publishing | Later adapter | Manual Ads Manager first; official Meta Marketing API later |
| Experiment analysis | Yes, concept-aware joins | CSV/API exports from Meta |

### Personal V0

1. Store products, audiences, claims, evidence, offers, and brand tokens as Markdown/YAML.
2. Generate a matrix of three audiences × three concepts × three hooks, but require the user to select a small test slate.
3. Produce a storyboard, primary text, headline, CTA, source-assets list, and one clear `changed_variable` for every variant.
4. Render static cards and simple product-demo videos locally. Make Higgsfield and the local video lab optional renderer interfaces rather than dependencies.
5. Export a folder per test with media, copy, a contact sheet, manifest, and recommended Ads Manager fields.
6. Import Meta result CSVs and report performance by hypothesis, concept, hook, placement, and spend. Preserve uncertainty when sample sizes are small.

### Drawbacks, concerns, and clever simplifications

- Generating dozens of near-duplicates creates the appearance of testing without meaningful creative diversity. Cluster concepts by visual mechanism and value proposition before rendering.
- Meta's own optimization may transform or combine assets. Record which automated creative features were enabled, otherwise results cannot be attributed cleanly.
- Do not fine-tune a design model first. A small curated swipe file with annotations such as `why_it_works`, `visual_mechanism`, and `claim_type` supplies more immediate leverage.
- The simplest useful version can stop at a well-structured creative brief, a storyboard/contact sheet, and an export bundle. Manual assembly in the user's preferred editor is acceptable until rendering is the bottleneck.
- Use the Local Video Generation Evaluation Lab only to select renderers. Do not embed model-installation logic inside this application.

### Scope-expansion reminder

Before public or commercial release, add a review of ad-platform terms, claim substantiation, generated-media disclosure requirements, asset/music/font rights, customer data handling, and approval/audit controls. Keep those as expansion gates rather than changing the personal V0 stack.

## 2. Personal Voice Ghostwriter and DM Desk

### Refined problem statement

Build a private writing and relationship desk that drafts X and LinkedIn posts in the user's actual voice and helps triage, contextualize, and draft replies to direct messages. This is the one justified two-idea merge: both need the same source corpus, voice fingerprint, people/context memory, claim provenance, and human approval queue.

The product should ground drafts in what the user has written, saved, built, learned, or explicitly believes. It should not imitate voice by asking a model to be “witty and insightful.” A useful voice model is an inspectable set of examples and constraints.

### Source-base ingestion from Notion and Obsidian

The [Notion block-children endpoint](https://developers.notion.com/reference/get-block-children) returns a page's child blocks; nested blocks must be fetched recursively. Notion's [page-content guide](https://developers.notion.com/guides/data-apis/working-with-page-content) explains how pages and blocks compose the content tree. An integration needs read access to the pages being ingested.

Obsidian notes are already local Markdown. A personal V0 can read the files directly, avoiding a plugin entirely. If live in-app integration later matters, Obsidian's official [Vault API](https://docs.obsidian.md/Plugins/Vault) exposes file enumeration and read/write operations to plugins.

Normalize both sources into provenance-preserving chunks:

```yaml
source_id: obsidian://Ideas/LongVid Learning Studio.md#Why-now
source_type: obsidian
document_title: LongVid Learning Studio
heading_path:
  - Why now
updated_at: 2026-08-12T17:40:00+05:30
text: "..."
tags:
  - project
  - learning
```

Use heading-aware chunks rather than arbitrary token windows. Keep stable IDs and content hashes so unchanged material is not re-embedded. SQLite with FTS5 is enough for exact retrieval; add a local vector index only if semantic recall measurably improves. Retrieve by topic, recency, source type, and rhetorical use, then require every factual or personal claim in a draft to point to one or more source IDs.

### A voice fingerprint that can be inspected

Create a curated set of accepted posts, long-form notes, messages, and deliberately rejected examples. Derive a voice card containing:

- sentence-length distribution and paragraph rhythm;
- preferred openings, transitions, punctuation, and calls to action;
- words and claims the user commonly uses;
- phrases, tones, and engagement bait to avoid;
- stance patterns: when the user qualifies, challenges, teaches, jokes, or tells a story;
- platform-specific differences between X, LinkedIn, and private messages;
- annotated examples with `why_this_sounds_like_me` and `why_this_does_not`.

At generation time, retrieve a small number of topically relevant source passages and stylistically relevant accepted examples separately. This prevents a semantically relevant but stylistically unusual note from dominating the voice. Store every edit between draft and accepted version; an edit-diff summarizer can propose voice-card changes, but the user approves them.

### Platform reality: supported APIs are asymmetric

The [X API overview](https://docs.x.com/x-api/overview) exposes posts, direct messages, lists, likes, and other resources under pay-per-use access. X provides a [liked-posts endpoint](https://docs.x.com/x-api/posts/likes/introduction), owned-list member management through the [Lists API](https://docs.x.com/x-api/lists/list-members/quickstart/manage-list-members), and real-time posts, mentions, follows, and DM events through [Account Activity](https://docs.x.com/x-api/account-activity/introduction). Account Activity uses [webhooks](https://docs.x.com/x-api/webhooks/introduction), which require a public HTTPS endpoint, CRC handling, signature verification, and retry-safe processing. That infrastructure is disproportionate for the first personal version.

LinkedIn's official [Posts API](https://learn.microsoft.com/en-us/linkedin/marketing/community-management/shares/posts-api) supports creating posts with permissions such as `w_member_social`, while reading member social content has more restricted access. LinkedIn's [API-access documentation](https://learn.microsoft.com/en-us/linkedin/shared/authentication/getting-access) makes clear that many programs and permissions require explicit approval. LinkedIn also states in its [automated-activity guidance](https://www.linkedin.com/help/linkedin/answer/a1340567/automated-activity-on-linkedin) that third-party software should not scrape or automate the website outside supported mechanisms.

Therefore the robust V0 is a **draft-and-review desk**, not an unattended browser bot:

- import source/context through supported APIs, notification emails, exported data, or user copy/paste;
- draft posts and replies locally;
- show relevant prior interactions, claims, and voice examples;
- copy the approved text to the clipboard or publish only through an authorized official endpoint;
- record what was actually sent only after user confirmation.

This still saves the valuable work—context gathering, synthesis, prioritization, and writing—without tying the application to fragile DOM automation.

### DM workbench design

Represent a conversation as messages plus a compact relationship card:

```yaml
person_id: x:12345
display_name: Example Person
relationship: peer-builder
topics:
  - local-ai
  - video-learning
last_interaction: 2026-08-13
open_loops:
  - "send the benchmark note"
promises_made:
  - "share build once V0 is stable"
do_not_forget:
  - "prefers technical detail"
```

The triage queue can label `reply-now`, `follow-up`, `reference-needed`, `opportunity`, `no-action`, and `possible-spam`. Labels are suggestions, not irreversible automation. For each reply show: the incoming message, the relevant thread, retrieved person notes, any promised follow-up, the draft, uncertainty flags, and why the draft was proposed. A “shorter,” “warmer,” “more direct,” and “answer only” control is more useful than dozens of tone presets.

### Recommended build-vs-borrow split

| Capability | Build locally | Borrow |
|---|---:|---|
| Markdown and Notion normalization | Yes | Notion API; direct Obsidian Markdown access |
| Search | Thin index | SQLite FTS5; optional local embeddings |
| Voice card, edit-diff learning, provenance | Yes | LLM for extraction and drafting |
| Inbox/DM source | Adapter only | X official API where affordable; manual/import fallback |
| LinkedIn publishing | Approval adapter only | Official Posts API if the account receives access |
| LinkedIn DM automation/scraping | No | Keep manual unless an official supported capability exists |
| UI | Yes | Local web application or Tauri shell |

### Personal V0

1. Curate 30–100 good writing samples and 10–20 negative examples.
2. Index selected Obsidian folders and explicitly shared Notion pages; store stable provenance.
3. Implement three post workflows: “turn note into post,” “react to a saved idea,” and “continue an existing series.”
4. Implement a manual DM intake box and relationship card before any API integration.
5. Add draft → edit → approve → sent feedback capture. Measure edit distance, unsupported-claim rate, and time saved rather than likes alone.
6. Add X read/publish adapters only if the pay-per-use cost and webhook complexity are justified. Keep clipboard/export as a first-class path.

### Drawbacks, concerns, and clever simplifications

- A large undifferentiated archive often worsens voice. Curated, annotated exemplars beat “embed the whole vault.”
- Retrieval can accidentally mix tentative notes with settled beliefs. Add `status: draft|belief|published|deprecated` and filter by task.
- Engagement optimization can flatten a distinctive voice into platform clichés. Score voice match, source support, novelty against recent posts, and user edit effort before engagement.
- Do not fine-tune first. Retrieval plus a small voice card is reversible, inspectable, and rapidly improves from edit diffs.
- A daily “three drafts and five DM recommendations” brief may outperform a real-time autonomous agent because it preserves context and reduces interruption.

### Scope-expansion reminder

Before multi-user, public, or commercial release, revisit permissioning for private messages and source notes, identity and impersonation controls, retention/deletion, platform terms, export rights, and disclosure/approval expectations. These are future product gates, not reasons to change the local Markdown/SQLite architecture.

## 3. Conversion List Builder

### Refined problem statement

Build a local evidence desk for assembling lists of people or organizations, recording why each might need a product, and learning which observable signals correlate with genuine conversion. The system should help answer “who should I talk to, why now, what do they need, and what evidence supports that belief?” It should not fabricate personal facts or hide a probabilistic guess behind a precise-looking score.

Keep this separate from the DM Desk. The Conversion List Builder produces a ranked research queue and conversion hypotheses; the DM Desk manages actual conversations.

### Start with a falsifiable conversion hypothesis

Every list should be linked to a hypothesis such as:

> Independent educators who publish videos longer than 30 minutes at least twice a month and sell a paid course are more likely than general creators to test a citation-grounded video-learning product, because their audience already pays for structured learning.

Represent the hypothesis as audience, trigger, problem, proposed value, disconfirming evidence, target action, and measurement window. Then define signals before collecting leads.

```yaml
hypothesis_id: longvid-educators-01
target_action: accepted-private-beta
window_days: 30
signals:
  - key: long_video_frequency
    direction: positive
    weight: 3
    expiry_days: 45
  - key: paid_learning_offer
    direction: positive
    weight: 4
    expiry_days: 180
  - key: recently_launched_competing_workflow
    direction: negative
    weight: 2
    expiry_days: 90
```

### Score evidence, not personality

A useful initial score is a transparent ruleset:

`priority = fit + observable_need + timing + reachable_path + prior_interest - contradiction - staleness`

Each component should display its source, observation date, confidence, and expiry. Missing evidence remains missing; an LLM should not infer company budget, purchase intent, or urgency from writing style. Let the LLM extract candidate evidence from supplied material and draft a rationale, but compute the score deterministically.

Store outcome stages such as `unreviewed`, `qualified`, `contacted`, `replied`, `problem-confirmed`, `trial`, `paid`, `not-now`, and `disconfirmed`. After enough observations, inspect conversion rates by signal and combination. Do not fit a sophisticated model to a tiny personal dataset. With fewer than hundreds of meaningful outcomes, simple cohorts and uncertainty intervals are easier to trust.

### Existing products and reusable primitives

[listmonk](https://github.com/knadh/listmonk) is a self-hosted newsletter and mailing-list manager backed by PostgreSQL. It is suitable for consented lists, segmentation, campaigns, and email operations once the research queue becomes an owned mailing list. It is not a lead-research or fit-scoring system, so keep the evidence ledger outside it and synchronize only approved contacts and segments.

[GrowthBook](https://docs.growthbook.io/) is open source and self-hostable; its experiment and metric model is useful when testing onboarding, offers, or messages against product outcomes. Its [repository](https://github.com/growthbook/growthbook) documents a local Docker deployment. Use it for actual controlled product experiments, not as a substitute for the list-builder's research record.

The X API provides official [list-member management](https://docs.x.com/x-api/lists/list-members/quickstart/manage-list-members) and [liked-post retrieval](https://docs.x.com/x-api/posts/likes/introduction), which can support user-selected watchlists and interest evidence. Access is pay-per-use and should be cached locally. LinkedIn access constraints described in section 2 mean the V0 should not assume arbitrary profile scraping or automated outreach.

### Recommended build-vs-borrow split

| Capability | Build locally | Borrow |
|---|---:|---|
| Hypothesis definitions and evidence ledger | Yes | YAML + SQLite |
| Deterministic scoring and explanations | Yes | SQL/rules |
| Evidence extraction from supplied pages/notes | Thin orchestration | LLM with citations to provided text |
| Lists and newsletter delivery | No | listmonk when needed |
| Product experiments | No experiment engine | GrowthBook or existing product analytics |
| Social-list synchronization | Adapter only | Official platform APIs |
| CRM | Avoid initially | SQLite; export CSV to a CRM later |

### Personal V0

1. Pick one product and one narrow audience hypothesis.
2. Define 5–8 observable signals, two contradiction signals, expiry periods, and one target outcome.
3. Build a 50-person evidence-backed queue manually or from user-supplied URLs/exports.
4. Review the top 10; record whether the problem is real before drafting any message.
5. Export a small outreach/research batch to the DM Desk, then join outcomes back.
6. After 30–50 conversations, remove signals that do not distinguish outcomes and rewrite the hypothesis.

### Drawbacks, concerns, and clever simplifications

- A score can turn weak evidence into unjustified confidence. Always show the score decomposition and “what would change this ranking.”
- Stale timing signals are worse than no signals. Decay or expire them automatically.
- A giant all-purpose database encourages collection without learning. One hypothesis and one target action per board keeps the feedback loop interpretable.
- “Who can pay?” is often less observable than “who has the problem now?” Prioritize pain and timing first; learn willingness-to-pay in conversations or product tests.
- A sortable Markdown/CSV table plus explicit evidence may be sufficient before building a web UI.

### Scope-expansion reminder

Before release or team use, revisit data-source terms, personal-data minimization, correction/deletion, outreach and email requirements, access controls, audit logs, and suppression lists. Keep the local schema provenance-ready now so the expansion review does not require a data rewrite.

## 4. Demand Generation Workbench

### Refined problem statement

Build a laboratory for discovering and testing demand for a specific product—not a content machine that declares demand after publishing. The workbench turns uncertain market beliefs into low-cost experiments, records observable behavior, and decides whether to double down, revise the audience/problem/offer, or stop.

It consumes evidence from conversations and product usage. It may hand creative briefs to the Meta Ad Creative Studio, lead hypotheses to the Conversion List Builder, and launch assets to the Auto-GTM Engine, but it owns its own experiment ledger and decision rules.

### The experiment object

```yaml
experiment_id: demand-longvid-004
product: longvid-learning-studio
hypothesis: "research students will exchange email for a cited sample notebook"
audience: postgraduate-researchers
channel: targeted-community-post
offer: free-cited-video-notebook
asset_ids:
  - landing-004
success_event: sample_requested
guardrail_events:
  - bounced_immediately
minimum_evidence:
  visitors: 100
  conversations: 10
decision_rule:
  continue_if: "request_rate >= 0.12 and at least 3 interviews confirm recurring pain"
  revise_if: "click_rate high but request_rate low"
  stop_if: "no problem-confirming conversations after 20 qualified visits"
status: planned
```

The counts are example planning values, not universal benchmarks. The key is to write the decision rule before seeing the result.

### Borrow the experiment plumbing

[GrowthBook](https://docs.growthbook.io/) can be self-hosted, reads metrics from an existing data source, exposes generated SQL, and supports feature flags and experiments. Its [open-source repository](https://github.com/growthbook/growthbook) documents local deployment. Use it when the experiment truly has randomized variants and reliable exposure/outcome events.

For earlier demand tests—interviews, manually shared prototypes, concierge workflows, landing pages, preorders, or waitlists—a small local ledger is clearer than pretending every activity is an A/B test. [listmonk](https://github.com/knadh/listmonk) can manage an owned email list; the Auto-GTM Engine can build assets; a lightweight analytics store can record `view`, `cta`, `signup`, `activated`, and `paid` events.

### Demand experiments worth supporting

- **Problem interview:** test whether a recurring painful workflow exists, without pitching the full solution first.
- **Concierge delivery:** manually produce the desired outcome and observe what inputs, quality bar, and turnaround actually matter.
- **Sample artifact:** offer a concrete output—report, clip, dashboard snapshot, plan—rather than a vague waitlist promise.
- **Fake-door inside a personal tool:** show the proposed action, explain that it is being tested when selected, and collect intent plus context.
- **Price/packaging conversation:** test what outcome people value and how they currently pay or improvise; avoid treating survey price answers as transactions.
- **Targeted landing page:** one audience, one problem, one promised outcome, one proof mechanism, one action.
- **Time-to-value experiment:** compare onboarding paths using activation, not vanity signups.

### Evidence hierarchy

Treat signals differently:

1. repeated use or payment;
2. completed high-friction action such as importing data or booking a session;
3. direct problem confirmation with concrete current workaround;
4. qualified signup or sample request;
5. click;
6. like, impression, or model-generated enthusiasm.

Do not sum these as equivalent points. The dashboard should retain an evidence type and show the highest-quality evidence supporting each conclusion.

### Recommended build-vs-borrow split

| Capability | Build locally | Borrow |
|---|---:|---|
| Hypothesis, decision, and learning ledger | Yes | Markdown/YAML + SQLite |
| Randomization/feature flags | No | GrowthBook when needed |
| Mailing-list operations | No | listmonk |
| Workflow orchestration | Thin workflows | Self-hosted [n8n](https://github.com/n8n-io/n8n) or small scripts |
| Landing-page generation | Reusable template only | Existing static-site stack |
| Analytics dashboard | Small custom view | SQL charts; PostHog/GrowthBook later if already used |
| Research synthesis | Yes, evidence-linked | LLM only over recorded observations |

### Personal V0

1. Choose one active project and write three competing problem hypotheses.
2. Define one two-week experiment for each, including a success event and stop/revise rule.
3. Create the minimum asset and instrument only the events that affect the decision.
4. Record interview excerpts and product events under the same hypothesis ID.
5. End every experiment with `continue`, `revise`, or `stop`, plus a short evidence statement and the next falsifiable belief.
6. Publish conclusions only after separating observation from interpretation.

### Drawbacks, concerns, and clever simplifications

- Automation can increase output while delaying the uncomfortable task of talking to qualified users. Make conversations a first-class experiment type.
- Small samples create false certainty. Display raw denominators and intervals; permit “insufficient evidence” as a result.
- A landing-page conversion can validate copy, not the entire product. Record precisely which claim was tested.
- Reuse the smallest possible landing-page template. Visual redesign between every test creates unnecessary variables.
- A weekly Markdown decision log may be the highest-value dashboard until experiments become numerous.

### Scope-expansion reminder

Before public/commercial operation, revisit analytics and email consent, claims and pricing presentation, experiment exposure, personal-data handling, and channel terms. These later checks should wrap the same evidence-ledger design rather than replace it.

## 5. Auto-GTM Engine

### Refined problem statement

Build a reusable release-to-market workflow for every tool, site, skill, plugin, and service the user creates. It should turn product truth—what changed, who it helps, how it works, and what proof exists—into a launch pack and a sustained, reviewable content queue. “Automatic” should mean information is gathered and variants are prepared automatically; unsupported claims and multi-channel posting should still pass through an approval gate.

This project is an infrastructure product. It does not decide market demand, author ad experiments, manage relationship DMs, or render every video model itself. It accepts structured inputs from those projects.

### The GTM manifest is the durable core

Place a versioned file such as `go-to-market.yaml` beside every artifact:

```yaml
artifact:
  name: Paper Logbook
  type: desktop-app
  repository: local-or-github-url
  current_version: 0.4.0
audiences:
  - id: research-student
    job: "keep an auditable trail from papers to decisions"
problems:
  - "notes lose the evidence path back to the paper"
promises:
  - statement: "capture claims with page-level provenance"
    proof_ids:
      - demo-provenance-01
features:
  - id: page-citation
    user_outcome: "reopen the exact supporting passage"
    demo_asset: demos/page-citation.mp4
objections:
  - objection: "I already use Zotero and Obsidian"
    answer: "the tool connects the reading action to a structured decision log"
cta:
  primary: join-private-beta
channels:
  - x
  - linkedin
  - blog
  - email
```

The manifest prevents a release agent from inventing positioning from a diff. A Git diff says what code changed; the manifest and proof library say why it matters.

### Trigger and workflow design

GitHub's official [Releases API](https://docs.github.com/en/rest/releases) can list releases, create them, generate release-note content, and manage release assets. Use releases or explicit local version tags as triggers. Do not publish daily solely because the clock fired; require an inventory of approved evergreen topics, proof clips, tutorials, use cases, objections, and changelog items.

[n8n](https://github.com/n8n-io/n8n) is self-hostable and supports visual workflows plus code and human approval steps. Its workflows can be exported as JSON, making it practical as a local orchestration layer. A code-only alternative is a Python/TypeScript worker plus Windows Task Scheduler. Prefer n8n when seeing and replaying the workflow is valuable; prefer code when the pipeline is small and needs tests/version control more than a canvas.

[listmonk](https://github.com/knadh/listmonk) can run the email-list and newsletter step. Use official, authorized platform APIs for posting where available. Preserve a manual export/copy path because X access is pay-per-use and LinkedIn permissions can be restricted.

### Content derivation graph

One approved release fact can become multiple assets without pretending each is a separate idea:

```text
release fact + proof
  -> changelog entry
  -> documentation update
  -> 30-second demo script
  -> short product video
  -> X post
  -> LinkedIn explanation
  -> email paragraph
  -> landing-page update
  -> FAQ/objection answer
```

Every output retains `artifact_id`, `release_id`, `source_fact_ids`, `proof_ids`, audience, channel, status, and final published URL. Deduplicate against recent outputs by semantic topic and hook. Use the Personal Voice Ghostwriter for founder-voice transformation, not a generic GTM prompt embedded here.

### Approval states

Use explicit states: `generated → claim-checked → asset-checked → approved → scheduled/exported → published-confirmed → measured`. If a platform call fails, retry idempotently with the same content ID. Never assume a queued post was published; store the platform response and verify the resulting URL when possible.

### Recommended build-vs-borrow split

| Capability | Build locally | Borrow |
|---|---:|---|
| GTM manifest schema and validators | Yes | JSON Schema or Pydantic/Zod |
| Release/change ingestion | Adapter only | Git/GitHub Releases API |
| Workflow scheduling and retries | Thin integration | n8n or task scheduler |
| Email lists | No | listmonk |
| Voice transformation | No duplicate model | Personal Voice Ghostwriter |
| Ad concepts | No | Meta Ad Creative Studio |
| Short-video extraction/generation | No | Longform-to-Shorts or local/hosted render adapters |
| Platform publishing | Adapter only | Supported official APIs; export otherwise |
| Truth/proof validation | Yes | deterministic source checks plus human approval |

### Personal V0

1. Define and validate the manifest for one shipped tool.
2. On a local tag or explicit command, collect the manifest, changelog, screenshots, demo clips, and README diff.
3. Generate a launch bundle: release notes, one tutorial outline, three posts, one email, one short-video script, and a landing-page patch suggestion.
4. Run claim checks: every capability claim must map to a feature/proof ID, and unverified superlatives are flagged.
5. Review in one queue, then export to channel folders. Add publishing APIs one at a time only after export is reliable.
6. Track published URLs and a small set of outcome events; feed market learning to the Demand Generation Workbench.

### Drawbacks, concerns, and clever simplifications

- Daily posting can become repetitive. Build a proof inventory and a topic cooldown, not an infinite paraphraser.
- Pull requests often contain internal details with no user value. Require a `user_outcome` field before producing marketing content.
- Channel-specific outputs should transform the idea, not truncate one master paragraph.
- A single Markdown launch pack generated on demand is a valid first release; scheduling and direct posting are later conveniences.
- Make all renderer and publisher adapters optional. The engine should still complete if it can only export files.

### Scope-expansion reminder

Before operating for users or customers, add per-workspace secrets and permissions, customer approval policies, marketing/email compliance, asset rights, platform-specific disclosures, deletion/export, and audit history. Keep the manifest and approval-state schema stable across that expansion.

## 6. Longform-to-Shorts Studio

### Refined problem statement

Build a local editing assistant that turns a long local video into multiple candidate short clips with accurate transcripts, intentional boundaries, vertical reframing, editable captions, and a transparent reason each segment was selected. It should reduce the search and rough-cut burden while leaving the final creative decision to the editor.

Do not make generative video a dependency. The core is deterministic media analysis and editing; generated inserts or B-roll can be requested from section 7 only as optional assets.

### Borrow the media primitives

- [FFmpeg's filter documentation](https://ffmpeg.org/ffmpeg-filters.html) covers deterministic operations including crop detection, silence detection, scaling, subtitles, loudness processing, and encoding.
- [WhisperX](https://github.com/m-bain/whisperX) adds word-level timestamps and speaker diarization to transcription, which makes sentence- and speaker-aware clip boundaries possible.
- [PySceneDetect](https://github.com/Breakthrough/PySceneDetect/blob/main/website/pages/cli.md) detects scene cuts and can split video around visual transitions.
- [Auto-Editor](https://github.com/WyattBlue/auto-editor) can automatically remove or rearrange low-loudness or low-motion sections and export timelines or clip sequences for editors including Premiere, Resolve, Shotcut, and Kdenlive.

These projects solve the expensive, error-prone media mechanics. Build the semantic segmenter, candidate ranking, provenance, review UX, and house style; do not build a decoder, speech recognizer, scene detector, or timeline format from scratch.

### Candidate generation pipeline

1. Probe the source with `ffprobe`; record codecs, duration, streams, frame rate, orientation, and audio layout.
2. Extract normalized mono speech audio for transcription while preserving the original stream for the final render.
3. Run WhisperX and retain word timestamps, sentence spans, confidence, and speaker labels.
4. Run PySceneDetect and FFmpeg silence detection. Treat those outputs as possible boundaries, not mandatory cuts.
5. Construct semantic windows, usually 20–90 seconds, that contain a hook/context/payoff or claim/evidence/conclusion arc.
6. Reject windows that start with unresolved pronouns, depend on missing setup, end mid-thought, contain long dead air, or duplicate another candidate.
7. Rank candidates using an explicit rubric; show the contributing evidence.
8. Track the active speaker/face or use a safe center crop. Allow keyframe correction.
9. Render a low-resolution proxy with editable captions. After approval, render the final vertical/horizontal variants from the source.

### Candidate rubric

Use distinct components instead of an opaque “virality score”:

- standalone comprehensibility;
- hook strength in the opening seconds;
- information or emotional payoff;
- specificity and quotability;
- visual continuity and reframing feasibility;
- clean entry and exit boundaries;
- novelty relative to other selected clips;
- alignment with a named audience and CTA;
- confidence and flags, including transcript uncertainty or sensitive context.

A model can propose scores and explanations, but deterministic checks should enforce duration, overlap, transcript completeness, and safe boundaries. Let the user reweight the rubric by project: a tutorial clip and a comedic clip need different selection logic.

### Output manifest and non-destructive editing

Never overwrite the source. Save a sidecar project:

```yaml
source_hash: sha256:...
source_path: videos/interview-07.mp4
transcript_model: whisperx-model-and-version
candidates:
  - clip_id: interview-07-c03
    in: 00:18:42.250
    out: 00:19:31.800
    speakers:
      - SPEAKER_01
    rationale:
      standalone: 4
      payoff: 5
      visual_feasibility: 3
    crop_keyframes: crops/interview-07-c03.json
    caption_style: bold-safe-v2
    status: approved
```

Export captions as SRT/VTT plus the final burned-caption version. Preserve EDL/XML or an Auto-Editor-compatible timeline when the user wants to finish in a desktop editor.

### Recommended build-vs-borrow split

| Capability | Build locally | Borrow |
|---|---:|---|
| Probe, transcode, filters, final render | No | FFmpeg/ffprobe |
| Transcription/alignment/diarization | No | WhisperX |
| Scene cuts | No | PySceneDetect |
| Silence/motion rough cuts and NLE export | No | Auto-Editor |
| Semantic windows and ranking | Yes | LLM plus deterministic rules |
| Reframing review and crop keyframes | Yes | MediaPipe/vision tracker optional; FFmpeg render |
| Captions | Style and correction UI | Transcript timings + ASS/SRT/FFmpeg |
| Generative inserts | No | Optional local-video or Higgsfield adapter |

### Personal V0

1. Support local MP4/MKV/MOV input and produce transcript, scenes, and ten candidate time ranges.
2. Build a simple transcript-first review UI with source preview, reason-for-selection, editable in/out points, and reject/approve.
3. Add one robust 9:16 crop mode and two caption styles.
4. Export proxies, finals, SRT/VTT, the manifest, and a contact sheet.
5. Compare model candidates against clips the user manually chose. Track accepted-candidate rate and edit time saved.
6. Add speaker tracking and timeline export only after the transcript-first loop is reliable.

### Drawbacks, concerns, and clever simplifications

- Transcript-only ranking misses physical comedy, demonstrations, facial reactions, and visually meaningful pauses. Add visual features after establishing a transcript baseline.
- Face auto-cropping can jump or frame the wrong speaker. Smooth crop paths, limit movement speed, and allow manual keyframes.
- Word-level alignment can be wrong around music, crosstalk, names, or code. Make transcript correction easy before final captions.
- The simplest first result can be a chaptered list of recommended timestamps and reasons, opened in the user's existing editor. Automated rendering is secondary.
- Avoid downloading videos inside this project unless the user explicitly supplies a source URL and the ingestion boundary is intended. Treat source acquisition as a replaceable adapter; local files are the durable core.

### Scope-expansion reminder

Before distribution or a hosted product, revisit source-media rights, participant consent, biometric/face processing, caption attribution, retention, music and font licensing, platform format/disclosure rules, and multi-user storage isolation. Preserve source provenance now so later review is possible without changing the editing stack.

## 7. Local Video Generation Evaluation Lab

### Refined problem statement

Build a reproducible local laboratory for answering a practical question: **which video-generation configuration produces an acceptable clip for a particular job, on a particular RTX machine, at an acceptable latency and cost?** It is not another prompt gallery and not a universal leaderboard. It records exact model/runtime configuration, runs a fixed task suite, captures resource use, supports blind pairwise review, and produces a Pareto view of quality, acceptance rate, latency, VRAM, and hosted cost.

### First correction: MiniMax H3, Hailuo, and Higgsfield are different deployment classes

MiniMax announced [H3](https://www.minimax.io/blog/minimax-h3) as an audio-video model capable of short clips with native stereo audio. The current official [MiniMax H3 model card](https://huggingface.co/MiniMaxAI/MiniMax-H3) publishes the **H3-Base** weights for local use:

- `H3-Base-FL2VA` supports text-to-video and first/last-frame-to-video;
- `H3-Base-Ref2VA` supports reference images, video clips, and audio clips;
- output is 4–15 seconds at 24 fps, with a default short edge of 768;
- the base transformer is 33B dense, while roughly 13B AdaLN-related parameters can be cached rather than loaded for inference;
- Diffusers, ComfyUI, SGLang, and vLLM integrations are listed.

The complete MiniMax product also uses `H3-Context-IR` and `H3-Regenerate-2K`. Those components are not part of the initial open local release; the official full workflow can call hosted MiniMax APIs for instruction rewriting and 2K regeneration. Local H3-Base should therefore be evaluated as the open model actually running on the RTX machine, not credited with a hosted preprocessing/upscaling stage unless the experiment explicitly enables and labels it.

MiniMax's official [Hailuo video API guide](https://platform.minimax.io/docs/guides/video-generation) and [text-to-video reference](https://platform.minimax.io/docs/api-reference/video-generation-t2v) expose Hailuo 2.3 and Hailuo 02 as asynchronous hosted services. Their documented interface supports model-specific 6- or 10-second outputs and resolution choices, but no official downloadable Hailuo 2.3/02 weights are provided there. Hailuo is a hosted comparison control, not a local RTX candidate.

Likewise, the [Higgsfield CLI](https://github.com/higgsfield-ai/cli) runs locally but submits asynchronous jobs to Higgsfield's hosted services. It can invoke Hailuo and other catalog models, but it does not turn them into local inference. Log Higgsfield model labels, request date, queue time, generation time, download time, and credits/cost separately from local GPU runs.

### Local and hosted candidate matrix

The numbers below are the maintainers' documented configurations as of 2026-08-14. They are not cross-model benchmarks: prompts, frames, resolution, steps, attention backends, host RAM, offload, and software versions differ. “Not published” is preferable to inventing a consumer-GPU estimate.

| Model/configuration | Actually local? | Officially documented memory or file size | Officially documented RTX runtime | Integration/support | Lab role |
|---|---|---|---|---|---|
| MiniMax H3-Base FL2VA/Ref2VA | Yes, open base weights | Comfy repacks: pruned FP8/INT8 diffusion 21 GB; NVFP4/AWQ text encoder 15.7 GB; video/audio VAEs about 5.8 GB. These are component/download sizes, **not peak VRAM**. | No official consumer-RTX wall-time or minimum-VRAM table published in the model card/Comfy guide | Official model card lists Diffusers, ComfyUI, SGLang, vLLM; native ComfyUI 0.30+ guide | High-priority experimental candidate for native audio and reference control; profile locally before making hardware claims |
| MiniMax Hailuo 2.3 / 02 | No, hosted API | N/A locally | Provider-managed; async API, no local RTX runtime | MiniMax API; also accessible through hosted aggregators | Hosted quality/cost/latency control only |
| Higgsfield catalog | No, hosted orchestration | N/A locally | Provider-managed; async jobs | Official CLI/MCP plus web platform | Hosted creative workflow control; not a model-runtime baseline |
| HunyuanVideo original | Yes | 45 GB documented for 544×960×129 frames; 60 GB for 720×1280×129; official tests used 80 GB GPUs | No consumer RTX figure in original card | [Model card](https://huggingface.co/tencent/HunyuanVideo), Diffusers, [ComfyUI workflows](https://comfyanonymous.github.io/ComfyUI_examples/hunyuan_video/) | Full-precision reference; impractical default for ordinary RTX cards |
| HunyuanVideo-1.5 480p distilled | Yes | Minimum 14 GB with offloading | Official repo reports 8/12-step 480p I2V on RTX 4090 in under 75 seconds | [Official repository](https://github.com/Tencent-Hunyuan/HunyuanVideo-1.5), Diffusers, ComfyUI | Best-documented first local baseline for a 16–24 GB RTX system |
| Wan2.1 T2V-1.3B | Yes | 8.19 GB VRAM documented | About 4 minutes for 5 seconds of 480p on RTX 4090, without quantization | [Official repository](https://github.com/Wan-Video/Wan2.1), Diffusers/Comfy ecosystem | Low-memory baseline; useful for validating harness behavior |
| Wan2.2 TI2V-5B | Yes | Official single-GPU command targets at least 24 GB with offload | No comparable official 4090 wall-time in the repository table used here | [Official repository](https://github.com/Wan-Video/Wan2.2), native [ComfyUI examples](https://comfyanonymous.github.io/ComfyUI_examples/wan22/) | Strong 24 GB 720p candidate |
| LTX-Video (earlier generation) | Yes | Diffusers quantized/offloaded example uses about 10 GB VRAM | No official consumer RTX wall-time in the cited pipeline page | [Model card](https://huggingface.co/Lightricks/LTX-Video), [Diffusers](https://huggingface.co/docs/diffusers/api/pipelines/ltx_video), [ComfyUI](https://comfyanonymous.github.io/ComfyUI_examples/ltxv/) | Fast/low-memory regression and iteration baseline |
| LTX-2 family | Yes | Official model files include approximately 20 GB FP4, 27.1 GB FP8, and 43.3 GB BF16 variants; file size is not peak VRAM | No clean official consumer-RTX inference table in the cited model/pipeline docs | [Model card](https://huggingface.co/Lightricks/LTX-2), [Diffusers LTX-2](https://huggingface.co/docs/diffusers/main/api/pipelines/ltx2), official [repository](https://github.com/Lightricks/LTX-2) | Audio-video stretch candidate; begin on larger-memory hardware and measure |
| CogVideoX-2B/5B | Yes | Older official Diffusers table: 2B FP16 12.5 GB/INT8 7.8 GB; 5B BF16 20.7 GB/INT8 11.4 GB. Current 5B quantized example is around 16 GB. | No comparable current consumer RTX figure in the cited docs | [Model card](https://huggingface.co/zai-org/CogVideoX-5b), [Diffusers pipeline](https://huggingface.co/docs/diffusers/main/api/pipelines/cogvideox), [older memory table](https://huggingface.co/docs/diffusers/v0.34.0/training/cogvideox) | Mature low-memory regression baseline, not presumed quality winner |
| FramePack | Yes | Maintainer states support for RTX 30/40/50 series with at least 6 GB GPU memory | Maintainer reports RTX 4090 around 2.5 sec/frame, or 1.5 sec/frame with TeaCache; the same repository shows that TeaCache can worsen results | [Official repository and desktop app](https://github.com/lllyasviel/framepack) | Low-VRAM and long-horizon I2V baseline; benchmark TeaCache as a different quality configuration, and remember that per-frame speed still means long jobs for long clips |

### H3's practical local stack

ComfyUI's official [MiniMax H3 tutorial](https://docs.comfy.org/tutorials/video/minimax/minimax-h3) documents native workflows in ComfyUI 0.30 and later for T2V, I2V, first/last-frame, and reference-to-video. Its preview configuration uses a pruned INT8 diffusion model and NVFP4/AWQ Qwen3-VL text encoder, plus separate video and audio VAEs. The [Comfy diffusion-model directory](https://huggingface.co/Comfy-Org/MiniMax-H3/tree/main/diffusion_models), [text-encoder directory](https://huggingface.co/Comfy-Org/MiniMax-H3/tree/main/text_encoders), and [VAE directory](https://huggingface.co/Comfy-Org/MiniMax-H3/tree/main/vae) expose the exact variant sizes.

Important implications:

- The practical preview download for one task family is roughly 42.5 GB before workflow extras: 21 GB diffusion + 15.7 GB text encoder + about 5.8 GB VAEs. That total does not establish that a 24 GB GPU can hold all components simultaneously; Comfy's dynamic loading and offload behavior determine peak VRAM and RAM.
- FL2VA and Ref2VA use different diffusion weights, so both task families roughly double the diffusion-model disk footprint if installed together.
- The initial open release uses full attention. MiniMax says sparse attention is planned; do not benchmark an unreleased optimization.
- ComfyUI says Sage Attention can approximately double generation speed with minimal quality loss. Benchmark it as a separate configuration and verify output quality rather than treating it as a free constant.
- Use the official [H3 prompt-writing guide](https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_base_en.md), which structures the integrated visual description, soundscape, music, shots, timing, and dialogue. Prompt normalization is necessary for fair comparison with models that do not support native audio.

### Quantization and offload are experimental variables

Diffusers' [memory-optimization guide](https://huggingface.co/docs/diffusers/optimization/memory) documents model CPU offload, group offload, and disk offload; more aggressive offload saves accelerator memory but can severely increase latency. Its [quantization overview](https://huggingface.co/docs/diffusers/v0.32.1/en/quantization/overview) explains that reduced precision saves memory and can affect performance and output.

Therefore `H3 pruned INT8 + NVFP4 + Sage Attention + group offload` is not the same benchmark subject as `H3 BF16 + standard attention`. Record precision, quantizer, attention backend, compilation, offload mode, and VAE tiling as part of the model identity. Compare quality and latency separately; never publish only the most favorable number from different configurations.

### Evaluation suite

Use 24–40 fixed cases with versioned input assets. Include at least:

- single-human anatomy and motion;
- two-person interaction and occlusion;
- object manipulation and basic physics;
- small product detail and logo/text rendering;
- slow, fast, and compound camera movement;
- first/last-frame adherence;
- character/identity reference preservation;
- style and scene reference preservation;
- multi-shot narrative continuity;
- dialogue, lip synchronization, sound effects, ambience, and stereo placement for audio-video models;
- a 9:16 product demonstration/ad case;
- a creator talking-head/B-roll case;
- negative prompts or difficult constraints where supported.

Use at least three seeds per configuration for serious comparisons. A single attractive or broken generation is not representative. Keep one literal prompt and, where necessary, one model-specific prompt produced from the same structured scene specification. Report those as different conditions so prompt engineering does not masquerade as base-model quality.

### Run manifest and harness

Every run should be immutable and reproducible:

```yaml
run_id: 2026-08-14_h3-fl2va_int8_seed42_case07
task_case: product-pour-07
runner: comfyui
workflow_hash: sha256:...
model:
  id: minimax-h3-fl2va-pruned-int8
  source_revision: exact-hf-revision
components:
  text_encoder: qwen3-vl-32b-nvfp4-awq
  video_vae: exact-file-and-hash
  audio_vae: exact-file-and-hash
runtime:
  os: windows
  gpu: exact-gpu
  vram_gb: 24
  driver: exact-version
  cuda: exact-version
  pytorch: exact-version
  attention: sage
  offload: group
generation:
  width: 1344
  height: 768
  frames: 125
  fps: 24
  steps: 20
  guidance: 6.0
  seed: 42
measurements:
  cold_start_seconds: null
  generation_seconds: null
  decode_seconds: null
  peak_vram_mb: null
  peak_ram_mb: null
  success: null
output_sha256: null
```

Build runners as adapters that produce this same manifest. A ComfyUI adapter can submit workflow JSON and poll history/output endpoints; a Diffusers runner can emit the manifest directly; hosted adapters can record queue, generation, transfer, and credit/cost fields while leaving local VRAM null.

### Quality and latency scoring

Blind pairwise human review should be the primary decision method. Randomize filenames and hide model/configuration. For each task, rate:

- prompt and constraint adherence;
- temporal and subject consistency;
- motion quality and physical plausibility;
- anatomy and object integrity;
- camera adherence;
- identity/reference preservation;
- rendered text/logo fidelity when required;
- audio quality, semantic correctness, lip sync, and A/V synchronization when present;
- artifact severity;
- editability and whether the output is usable for the intended project.

Use automatic metrics as diagnostics, not a replacement for creator judgement. The official [VBench repository](https://github.com/Vchitect/VBench) supplies standardized prompt sets and dimensions including subject/background consistency, flicker, motion smoothness, dynamic degree, imaging/aesthetic quality, human action, object relations, style, and overall consistency. VBench 2.0 adds harder reasoning, physics, human motion, and composition dimensions. Run a small relevant subset after the basic harness works; its own CUDA/model dependencies can be substantial.

Also run deterministic media checks with `ffprobe`: actual duration, dimensions, frame rate, dropped/corrupt frames, audio stream presence, sample rate, and A/V duration drift. Do not reward a model for being fast if it silently produced fewer frames or a lower resolution.

For latency, exclude one explicit warm-up from the warm median but keep cold-start separately. Record P50 and P95 across repeated runs, failures/retries, generation versus decode/postprocess time, peak VRAM/RAM, and output bytes. For hosted services record queue and download separately. Prefer decision metrics such as:

- time to first acceptable clip;
- accepted clips per GPU-hour;
- accepted-clip rate across seeds;
- hosted cost per accepted clip;
- manual edit minutes to usable output;
- local disk footprint and setup/recovery burden.

### Recommended build order by hardware class

1. **Harness sanity:** Wan2.1 1.3B, LTX-Video, or quantized CogVideoX. These establish that manifests, monitoring, media validation, and review work before large downloads.
2. **16 GB class:** HunyuanVideo-1.5 480p distilled is the strongest first candidate with an official 14 GB offloaded minimum and a documented RTX 4090 runtime. LTX-Video provides a lower-memory speed baseline. Treat H3 as an experiment, not a promised fit, because MiniMax has not published a consumer peak-VRAM table.
3. **24 GB class:** add Wan2.2 TI2V-5B and empirically test the H3 preview configuration with system RAM/offload monitoring. Keep FL2VA and Ref2VA as separate installs/runs.
4. **32 GB and larger:** add LTX-2 and less aggressive H3 quantization/offload configurations. Do not transfer the LTX-2 trainer's memory requirement to inference; measure the exact inference build.
5. **Low-VRAM/long output:** add FramePack as an I2V/long-horizon baseline, while reporting its per-frame wall time honestly.
6. **Hosted controls:** run the same scene intent through MiniMax Hailuo and a selected Higgsfield workflow. Label provider model names and test dates because hosted weights and routing are opaque.
7. **DGX Spark later:** add it as a different hardware runner, not as if its timings were comparable to an RTX desktop. Architecture, kernels, memory topology, and software support belong in the run manifest.

### Recommended build-vs-borrow split

| Capability | Build locally | Borrow |
|---|---:|---|
| Model inference implementations | No | Official weights, Diffusers, ComfyUI workflows |
| Cross-run manifest and provenance | Yes | SQLite/Parquet + JSON/YAML sidecars |
| Job queue and worker isolation | Yes, thin | ComfyUI API or per-model Python environments |
| GPU/RAM/latency telemetry | Thin wrapper | NVIDIA tooling, Python system metrics, process timers |
| Media validation | No custom codec work | FFmpeg/ffprobe |
| Standard automatic benchmark | No | VBench relevant subset |
| Creator-task prompt/reference suite | Yes | Versioned local assets |
| Pairwise review and Pareto dashboard | Yes | Small local web UI |
| Hosted generation | Adapter only | MiniMax/Higgsfield provider interfaces |

### Drawbacks, concerns, and clever simplifications

- Model file size, peak VRAM, and total system RAM are different quantities. The dashboard must never substitute one for another.
- ComfyUI workflows can change defaults while retaining a familiar filename. Hash workflow JSON and every model component.
- “Runs on 8 GB” may mean extreme CPU offload and unusable latency. Always report wall time and peak system RAM beside VRAM.
- Quantized models may change temporal stability, audio quality, or instruction adherence even when a still frame looks similar. Keep video and audio pairwise review.
- Hosted models are moving targets. Retest controls periodically and label the date; do not compare a 2026 hosted result to a frozen local model without noting drift.
- FramePack's maintainer explicitly demonstrates that TeaCache can produce a worse result for some runs. Keep cached and uncached outputs separate even when the speed gain is attractive.
- Do not install every candidate at once. Start with one low-memory runner, one documented 16/24 GB quality candidate, and one hosted control. The harness should earn the disk downloads.
- A first V0 can be a CLI that writes manifests and a static HTML pairwise-review page. A full dashboard is unnecessary until enough runs exist.

### Scope-expansion reminder

Before publishing benchmarks, redistributing outputs/models, open-sourcing packaged workflows, or offering generation as a service, revisit model and dataset licenses, model-specific acceptable-use terms, generated-media disclosures, reference-person consent, benchmark asset rights, and hosted-provider terms. Retain exact model revisions, prompt/reference provenance, and configuration hashes now so that later review is factual and does not require changing the local evaluation stack.

### Related notes

- [[Meta Ad Creative Studio]]
- [[Personal Voice Ghostwriter and DM Desk]]
- [[Conversion List Builder]]
- [[Demand Generation Workbench]]
- [[Auto-GTM Engine]]
- [[Longform-to-Shorts Studio]]
- [[Local Video Generation Evaluation Lab]]
- [[Creator Content Engine]]
- [[Scope Expansion Checklist]]
