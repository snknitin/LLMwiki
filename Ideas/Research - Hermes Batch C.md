# Research — Hermes Batch C

This dossier turns the assigned Hermes Buildathon prompts into evidence-backed, local-first prototype directions. The common recommendation is to prove the decision loop with one user and synthetic or explicitly supplied data before adding multi-tenant hosting, external sending, public publishing, regulated claims, or autonomous irreversible actions. Official documentation and source repositories are linked directly so each project spec can inherit a practical shortcut rather than reimplementing commodity infrastructure.

## 1. 27 Clicks to Cancel

Cancellation automation is technically feasible but brittle: account state, CAPTCHAs, retention offers, phone/chat handoffs, and ambiguous final confirmations defeat pure DOM scripts. [Playwright](https://playwright.dev/docs/intro) supplies deterministic browser control, traces, screenshots, and storage-state reuse; [Browser Use](https://github.com/browser-use/browser-use) is a useful agentic fallback, not a reason to remove confirmation gates. Email subscriptions should prefer the standardized HTTPS `List-Unsubscribe-Post` flow defined by [RFC 8058](https://datatracker.ietf.org/doc/html/rfc8058). The FTC is again reviewing negative-option regulation in 2026, so a “Wall of Shame” must report captured facts and timestamps rather than declaring illegality ([FTC Negative Option Rule page](https://www.ftc.gov/legal-library/browse/rules/negative-option-rule)).

Best V0: run against a local mock cancellation maze, generate an annotated click receipt, and stop immediately before the final destructive action. A real personal run should require the owner to approve the exact service, loss of benefits, effective date, fees, and evidence snapshot.

## 2. AI Implementation Agency

The differentiated product is an evidence-backed opportunity map, not another workflow runner. [n8n](https://docs.n8n.io/hosting/), [Activepieces](https://www.activepieces.com/docs/install/overview), and [Dify](https://github.com/langgenius/dify) already cover self-hosted integrations and agent/workflow prototyping; adapt one after the audit shows a real repeated workflow. Dify’s repository also documents license conditions around multi-tenant use, a future-product reminder rather than a local-stack blocker ([Dify license](https://github.com/langgenius/dify/blob/main/LICENSE)).

Best V0: ingest five sanitized SOPs or interview notes, map frequency × minutes × error cost × automation risk, and output five ranked proposals with a human-approved one-workflow prototype. Treat ROI as a range with stated assumptions and measure the manual baseline before claiming savings.

## 3. AI Roast Battle Room

Real-time rooms are commodity infrastructure: [Cloudflare Durable Objects WebSockets](https://developers.cloudflare.com/durable-objects/best-practices/websockets/) can coordinate a room, while [Convex](https://docs.convex.dev/realtime) offers reactive state. [ElevenLabs TTS](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) can add performance, but free outputs and commercial use have plan-specific terms. The hard product work is consent, tone, moderation, rate limits, and preventing personal harassment.

Best V0: a private room with two fictional products, text-only turns, a bounded “roast rubric,” report/block controls, and no public ranking. The judge should reward specificity and useful critique, not cruelty; human-submitted products require an owner-attestation checkbox and a pre-publication review.

## 4. Brag Notary

A cryptographic receipt can prove that a claim and evidence bundle existed unchanged at a time; it cannot prove the claim is true. [OpenTimestamps](https://opentimestamps.org/) anchors hashes to Bitcoin, [Sigstore Rekor](https://docs.sigstore.dev/logging/overview/) provides an append-only signature-transparency log, and [C2PA Content Credentials](https://spec.c2pa.org/specifications/) standardize media provenance. C2PA explicitly distinguishes tamper-evident provenance from truth judgments ([explainer](https://spec.c2pa.org/specifications/specifications/2.2/explainer/Explainer.html)).

Best V0: hash a local evidence manifest, create a signed verification report with `verified`, `partially supported`, or `insufficient evidence`, and display which atomic checks passed. Avoid the legally loaded word “notarized” in the UI; “evidence receipt” or “timestamped claim” is more accurate.

## 5. Clinic Missed-Call Follow-Up Bot

[Twilio Voice status callbacks](https://www.twilio.com/docs/voice/api/call-resource) distinguish terminal states including `busy`, `failed`, and `no-answer`; this is enough to trigger a queue without transcribing calls. WhatsApp’s supported route is the [Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/) with approved templates outside the customer-service window. Health/contact data requires consent, least-privilege access, retention limits, and jurisdiction-specific review; India’s official [DPDP Rules 2025 page](https://www.meity.gov.in/documents/act-and-policies/digital-personal-data-protection-rules-2025-gDOxUjMtQWa) is the current primary policy anchor.

Best V0: simulate missed-call webhooks, draft—not send—one approved neutral callback message, and let a receptionist resolve, defer, or suppress it. Do not include diagnosis, treatment, or sensitive context in lock-screen-visible messages.

## 6. Compliance Autopilot

Compliance dates change, extensions occur, and applicability depends on entity facts. Official source anchors include the [MCA portal](https://www.mca.gov.in/), [GST Portal GSTR-1 guidance](https://tutorial.gst.gov.in/userguide/returns/GSTR_1.htm), and the [Income Tax e-Filing tax calendar](https://www.incometax.gov.in/iec/foportal/). In 2026 the transition to the Income Tax Act, 2025 makes hard-coded TDS assumptions especially dangerous; the department’s [TDS compliance guidance](https://www.incometax.gov.in/iec/foportal/help/all-topics/e-filing-services/tds-compliance) shows date-dependent transition rules.

Best V0: a fact questionnaire plus a manually curated rule pack for one private limited company, with source URL, jurisdiction, effective date, applicability explanation, owner, and “confirmed by CA/CS” state on every obligation. Draft checklists and calendar entries; never file, sign, or guarantee compliance.

## 7. Data Room Concierge

[Docling](https://github.com/docling-project/docling), [Unstructured](https://github.com/Unstructured-IO/unstructured), and [OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) already convert common office/scanned formats into searchable structure. A local [Qdrant](https://qdrant.tech/documentation/quickstart/) or SQLite FTS index can support cited retrieval. Document OCR, tables, version ambiguity, and confidential-data leakage are the failure modes; a generated answer must quote its exact page/file source and abstain when support is absent.

Best V0: ten synthetic diligence documents, a deterministic index/missing-document checklist, and read-only Q&A with page citations. Use expiring preview links and per-document access labels only after the local demo works.

## 8. Edge Desk

Polymarket separates public market-data access from authenticated trading; its official docs cover [market fetching](https://docs.polymarket.com/market-data/fetching-markets), [authentication](https://docs.polymarket.com/api-reference/authentication), and [geographic restrictions](https://help.polymarket.com/en/articles/13364163-geographic-restrictions). [Kalshi’s API](https://docs.kalshi.com/welcome) is another product reference. Market price is not ground truth: spread, liquidity, fees, participant bias, resolution ambiguity, and data latency must be visible.

Best V0: five watched questions, snapshots of bid/ask/volume/rules, a primary-source evidence notebook, manual probability forecasts, and Brier-score review. No wallet, private key, trading credential, order endpoint, “edge” guarantee, or VPN circumvention.

## 9. Finance Ops Agency

[InvoicePlane](https://github.com/InvoicePlane/InvoicePlane) handles self-hosted invoices/clients/payments, [Firefly III](https://github.com/firefly-iii/firefly-iii) provides rules and financial reporting, and [Actual Budget](https://github.com/actualbudget/actual) is a local-first ledger/budget reference. These are shortcuts or comparison baselines; the agency layer should focus on exceptions, evidence, and a monthly close packet.

Best V0: CSV invoice and bank-export imports, receivable aging, vendor due dates, reimbursement checklist, cash runway, and a reconciled monthly memo. Preserve source rows and confidence; never invent ledger entries or mark a payment collected without matching evidence.

## 10. Inbox Zero Mercenary

The [Gmail API](https://developers.google.com/workspace/gmail/api/guides) exposes drafts, labels, filters, and mailbox change notifications. `messages.batchModify` can alter up to 1,000 message IDs ([reference](https://developers.google.com/workspace/gmail/api/reference/rest/v1/users.messages/batchModify)), which is powerful enough to demand previews and rollback labels. Standards-based unsubscribes should use [RFC 8058](https://datatracker.ietf.org/doc/html/rfc8058) only after explicit approval.

Best V0: read-only classification of 200 exported/synthetic messages, a proposed action queue, and draft replies. In a live mailbox, apply a reversible `AI-Proposed-*` label first; require per-batch approval for archive/unsubscribe and per-message approval for replies. Never send automatically.

## 11. Maintainer Desk

GitHub Apps support least-privilege repository permissions, and GitHub documents the exact [permissions required for API endpoints](https://docs.github.com/en/rest/authentication/permissions-required-for-github-apps). [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners) and branch protection keep humans accountable. Reproduction is more valuable than speculative diagnosis; run untrusted issue code in disposable, network-restricted containers.

Best V0: one repo, read-only issue ingestion, label/reproduction suggestions, draft responses, and a patch branch that never posts until a maintainer approves. Measure accepted labels, successful reproductions, and reviewer edits—not number of generated comments.

## 12. Microsite Factory

[Astro](https://docs.astro.build/) can generate static account pages, [Cloudflare Pages Direct Upload](https://developers.cloudflare.com/pages/get-started/direct-upload/) can deploy prebuilt assets with Wrangler, and [Playwright](https://playwright.dev/docs/test-snapshots) plus [axe-core](https://github.com/dequelabs/axe-core) can gate screenshots and accessibility. Personalized assertions must come from cited public/company material; fabricated familiarity damages trust.

Best V0: three fictional accounts, one approved content schema, local static builds, screenshot diffs, link checks, and preview URLs only. One shared template with data files is preferable to twenty independent codebases.

## 13. On-Call Autopilot

[OpenTelemetry](https://opentelemetry.io/docs/) standardizes traces, metrics, and logs; [Grafana Loki/LogQL](https://grafana.com/docs/loki/latest/query/) and local `logcli --stdin` support bounded evidence collection. Automated patching and redeployment are high-blast-radius actions. A good assistant constructs a timeline, names evidence and uncertainty, proposes reversible remediation, and verifies against explicit health checks.

Best V0: replay a synthetic broken deployment, query a frozen log bundle, produce ranked hypotheses with trace/log links, patch a disposable worktree, run tests, and open a local diff. No production credentials and no deploy action; voice narration is optional polish.

## 14. Podcast Clips Agency

[whisper.cpp](https://github.com/ggml-org/whisper.cpp) supplies local transcription, [FFmpeg](https://ffmpeg.org/ffmpeg-filters.html) handles cutting/cropping/captions, and the [YouTube `videos.insert` API](https://developers.google.com/youtube/v3/docs/videos/insert) is an official upload route with OAuth, quotas, and audit restrictions for public uploads from unverified projects. Social platforms impose distinct upload and rights rules; auto-publishing is not a hackathon default.

Best V0: one user-owned episode, transcript with timecodes, ten scored candidate moments, three rendered 9:16 previews, captions, and an approval manifest. Export files and copy; do not post.

## 15. PR Factory

Git’s [worktree command](https://git-scm.com/docs/git-worktree.html) supports multiple isolated checkouts, while GitHub Apps and the [Checks API permissions](https://docs.github.com/en/rest/authentication/permissions-required-for-github-apps) provide a controlled PR integration. Static/dynamic tests are judges, not LLM preference. Untrusted repositories can execute code during install or tests, so workers need disposable sandboxes, no ambient credentials, and constrained network/CPU/time.

Best V0: one fixture issue, two worktrees, deterministic tests, a scored comparison, and one local winning patch plus decision log. A human authorizes any branch push or PR creation.

## 16. Recruiting Agency

[Greenhouse Harvest API](https://developers.greenhouse.io/harvest) is a legitimate ATS integration and requires an `On-Behalf-Of` identity for audited writes. [O*NET Web Services](https://services.onetcenter.org/) can ground job skills. Avoid scraping LinkedIn or inferring protected traits; candidate sourcing and screening should be job-related, explainable, and human reviewed.

Best V0: rewrite one synthetic JD, define a structured rubric before viewing candidates, score five fictional profiles with evidence spans, and produce outreach/interview-plan drafts. Do not auto-reject, rank on proxies, or send outreach.

## 17. Sales Development Agency

[HubSpot CRM imports](https://developers.hubspot.com/docs/api/crm/imports) and object APIs provide supported handoff paths; [Hunter’s API](https://hunter.io/api-documentation/v2) is an enrichment reference with explicit confidence fields. A compliant product also needs suppression lists, lawful basis, jurisdiction-aware outreach, identity/provenance, and rate controls.

Best V0: ten fictional accounts, a cited ICP fit table, contact-data provenance, one three-step sequence, a call script, and CSV import preview. No enrichment scraping or send button; treat every generated fact as unverified until its source is attached.

## 18. Security Review Agency

[Gitleaks](https://github.com/gitleaks/gitleaks) scans git history and directories for secrets, [Semgrep](https://semgrep.dev/docs/getting-started/) covers static patterns, [Trivy](https://trivy.dev/latest/docs/) scans repositories/images/configuration, [OSV-Scanner](https://google.github.io/osv-scanner/usage/) maps dependencies to authoritative vulnerability advisories, and [CodeQL](https://docs.github.com/en/code-security/concepts/code-scanning/codeql/codeql-code-scanning) supports deeper code queries. Scanner output is evidence, not a vulnerability verdict.

Best V0: a deliberately vulnerable fixture repo, normalized SARIF/JSON findings, deduplication, reachable/exploitable evidence, severity plus confidence, and remediation patches for two known issues. Never scan a repo without authorization or execute its build scripts on the host.

## 19. SEO Agency Crew

[Google Search Console API](https://developers.google.com/webmaster-tools/v1/api_reference_index) supplies query/page performance for verified properties; [PageSpeed Insights API](https://developers.google.com/speed/docs/insights/v5/get-started) and [Lighthouse](https://github.com/GoogleChrome/lighthouse) cover technical quality. Google’s [Indexing API](https://developers.google.com/search/apis/indexing-api/v3/using-api) is limited to job-posting or livestream pages, so general “instant indexing” automation is invalid. Search spam and undisclosed Reddit seeding are unacceptable shortcuts.

Best V0: audit one owned site, create a pillar/cluster plan from real Search Console gaps, draft one useful article, improve internal links/schema/performance, and leave publishing/outreach as reviewed drafts.

## 20. Tiny Game from Any Tweet

Tweet retrieval is a dependency trap; start with pasted text or an official embed/export. [Phaser](https://docs.phaser.io/) is a mature web-first 2D engine, and [Cloudflare Pages](https://developers.cloudflare.com/pages/) can host static builds. The product should map text into a small library of tested mechanics instead of asking an LLM to invent arbitrary executable code.

Best V0: one text prompt, one of three templates, deterministic JSON game parameters, a playable local build, screenshot test, and a shareable static export. Treat source text and media as untrusted and never execute model-produced JavaScript without schema validation.

## 21. User Research Agency

[Formbricks](https://github.com/formbricks/formbricks) and [LimeSurvey](https://github.com/LimeSurvey/LimeSurvey) already provide self-hostable survey/recruitment forms. Local speech-to-text can use [whisper.cpp](https://github.com/ggml-org/whisper.cpp). The essential constraints are informed consent, withdrawal, recording disclosure, purpose limitation, fair incentives, and quote traceability. Synthetic interviews may test software but must never masquerade as real findings.

Best V0: a synthetic study with five scripted respondents, a consent gate, structured interview guide, transcript/timecode capture, coded evidence table, contradictions, and a report where every quote opens the source segment.

## 22. Winback Agency

Supported inputs should come from a customer’s CRM/commerce exports or official APIs such as [Shopify Admin GraphQL](https://shopify.dev/docs/api/admin-graphql) and approved channels such as [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/). Unsubscribes, opt-outs, prior consent, frequency caps, and suppressions override campaign optimization.

Best V0: synthetic lapsed-customer CSV, transparent recency/frequency/value segments, three approved offers, email/WhatsApp drafts, reply-intent routing, and a paper conversion dashboard. No live sends or automatic discounts.

## 23. Startup Graveyard

Primary registries provide facts, not causes of death: [SEC EDGAR APIs](https://www.sec.gov/search-filings/edgar-application-programming-interfaces) provide US public-company filings and the [Companies House API](https://developer.company-information.service.gov.uk/) provides live UK company records. Website history can be investigated through the [Internet Archive APIs](https://archive.org/developers/). Funding databases such as Crunchbase are valuable product references but have access/licensing constraints ([Crunchbase data documentation](https://data.crunchbase.com/docs)).

Best V0: five known companies with dated evidence cards. Separate `observed facts`, `reported explanations`, and `analyst hypothesis`; never convert disappearance, dissolution, or a stale website into a confident failure cause.

## 24. Support FAQ Builder

[Zendesk ticket APIs](https://developer.zendesk.com/api-reference/ticketing/tickets/tickets/) and [Help Center APIs](https://developer.zendesk.com/api-reference/help_center/help-center-api/introduction/) are supported sources/targets; [Docusaurus](https://docusaurus.io/docs) is a simple static help-center output. Clustering ticket text is easy; redaction, representative sampling, answer ownership, freshness, and escalation boundaries determine quality.

Best V0: 100 synthetic/sanitized tickets, PII redaction, issue clusters with source examples, ten draft FAQ entries, five macros, and escalation rules. Each answer needs an owner, evidence set, last-reviewed date, and unresolved/exception cases.

## 25. Tax Packet Autopilot

The [Gmail API](https://developers.google.com/workspace/gmail/api/guides) can retrieve message attachments with scoped OAuth; [OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) and [Tesseract](https://tesseract-ocr.github.io/) keep extraction local. India’s official [e-invoice schema](https://einvoice6.gst.gov.in/content/notified-e-invoice-schema/) defines GSTIN, document, seller, buyer, and tax fields. Extraction confidence is insufficient for tax treatment.

Best V0: a local folder of synthetic invoices/receipts, hash-based deduplication, schema extraction with page evidence, month/vendor/category review, missing-period checklist, and a CA-ready ZIP plus reconciliation CSV. Never send client chasers or file a return.

## 26. Therapist Intake Desk

[HL7 FHIR Questionnaire](https://hl7.org/fhir/questionnaire.html) and `QuestionnaireResponse` provide a structured exchange model; [Formbricks](https://github.com/formbricks/formbricks) can supply a self-hosted intake UI. HHS warns that telehealth technology creates privacy/security risks ([guidance](https://www.hhs.gov/hipaa/for-professionals/privacy/guidance/telehealth-privacy-security/index.html)); India’s [DPDP Rules 2025](https://www.meity.gov.in/documents/act-and-policies/digital-personal-data-protection-rules-2025-gDOxUjMtQWa) are a local policy anchor.

Best V0: clinician-authored questions, explicit consent, a structured response, and an editable draft summary. Do not diagnose, infer a risk score, replace emergency services, or let an LLM decide urgency; explicit crisis answers should show clinician-configured emergency instructions and stop conversational generation.

## 27. Website in a WhatsApp

The supported messaging foundation is [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/) or, for a zero-approval hackathon route, the [Telegram Bot API](https://core.telegram.org/bots). [Astro](https://docs.astro.build/) can generate a static site, and [Cloudflare Pages Direct Upload](https://developers.cloudflare.com/pages/get-started/direct-upload/) can publish a prebuilt folder through Wrangler.

Best V0: use Telegram or a local chat simulator, collect a fixed business schema plus owned images/voice notes, generate a preview, run link/accessibility checks, and require “publish” confirmation. Future WhatsApp onboarding, templates, domains, and media retention are separate integration work.

## 28. Wedding Gallery Concierge

[Immich](https://github.com/immich-app/immich) already provides self-hosted object/face/CLIP search, while [OpenCLIP](https://github.com/mlfoundations/open_clip) can create text-image embeddings for a custom local index. Face recognition over a wedding guest population creates biometric/privacy risk and misidentification harm; semantic captions, time clusters, photographer tags, and opt-in selfie matching are safer stages.

Best V0: 500 consented/demo photos, local thumbnails and embeddings, natural-language retrieval, contact sheets, and expiring local share pages. Preserve originals, never train on the gallery, and do not enable named-face search without explicit subject/event policy.

## 29. WhatsApp Catalog Bot for Small Stores

[WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/) is the supported messaging path; Meta’s [catalog/product messages](https://developers.facebook.com/docs/whatsapp/cloud-api/guides/send-messages#interactive-messages) can provide native interaction where the account is configured. [Google Sheets API](https://developers.google.com/sheets/api) or a CSV is enough for V0 inventory. A chat answer must never invent price, stock, variant, delivery time, or payment status.

Best V0: local chat simulator + a 30-item catalog CSV, deterministic filtering, cart capture, stock timestamp, and an order-review link. Human confirmation finalizes the order; use a payment link rather than handling card data.

## 30. WhatsApp Sticker Pack Generator

The official [WhatsApp sticker sample repository](https://github.com/WhatsApp/stickers) specifies pack requirements including WebP, 512×512 assets, size limits, pack counts, tray icon, emoji tags, and accessibility labels. [Telegram sticker APIs](https://core.telegram.org/api/stickers) offer a bot-accessible alternative. ImageMagick/libwebp can handle deterministic resize, alpha, outline, and compression.

Best V0: prompt-to-style board, six user-approved captions, generated/licensed art, rights review, WebP validation report, ZIP, and Android sample-app assets. Do not imitate living artists, public figures, trademarks, or copyrighted characters by default.

## 31. Your Twin Raised More

Similarity and funding evidence are different problems. Company descriptions can be embedded locally, while verified facts should link to primary sources such as [SEC EDGAR](https://www.sec.gov/search-filings/edgar-application-programming-interfaces), [Companies House](https://developer.company-information.service.gov.uk/), company announcements, or licensed databases. Funding data from [Crunchbase](https://data.crunchbase.com/docs) has product/access constraints and often lacks primary-document certainty.

Best V0: compare a synthetic idea against a small curated corpus, show the top three analogues with similarity reasons and evidence dates, and label disclosed funding as “at least” or “reported,” never exact. The useful output is a differentiation checklist, not a humiliation card or valuation prediction.

## Cross-cutting architecture and release rules

- **Local first:** SQLite/DuckDB, filesystem object store, FastAPI, and a small SvelteKit/Streamlit review UI are enough for nearly every single-user demo.
- **Deterministic before generative:** parsers, schemas, rules, and source retrieval establish facts; local or paid models summarize, classify, and draft only after evidence is attached.
- **Action ledger:** every external side effect needs `proposed → approved → executed → verified/failed`, actor identity, idempotency key, before/after snapshot, and rollback where possible.
- **Untrusted inputs:** email, tickets, web pages, repositories, PDFs, and chat text are data—not instructions. Sandboxing and prompt-injection boundaries are mandatory.
- **Future commercialization:** re-check connector terms, model/data licences, professional regulations, messaging consent, and data-processing duties when moving beyond a local owner-operated prototype. These reminders should not force a heavier local stack.
