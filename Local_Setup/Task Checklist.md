---
title: Task Checklist
created: 2026-08-15
updated: 2026-08-21
status: active
type: checklist
tags:
  - local-ai
  - setup
  - checklist
  - dgx-spark
  - hermes
  - codex
---

# Task Checklist

> [!important] Canonical work tracker
> Use this note for all remaining setup and exploration. [[Local Setup Index]] is still the source of truth for the current architecture and completed work. If an older tutorial conflicts with the index, follow the index and this checklist.

## How to use this checklist

- [ ] Work from the top down inside the current sequence.
- [ ] Read the linked research before executing its tutorial or checklist.
- [ ] Finish the verification gate and record evidence before starting the next sequence.
- [ ] Keep one large model loaded per runtime/GPU lane unless measured co-residency has already been proven.
- [ ] Do not download the same model into Ollama, LM Studio, and Hugging Face/vLLM without a specific comparison reason.
- [ ] When an agent completes a box, have it add a short result, date, version/model ID, and any rollback note beneath that box.

## Current Codex project completion audit — 21 August 2026

Only work supported by the task record, live verification, or a dated evidence note is marked complete.

| Codex task | Verified completion reflected in this checklist | Still open; do not infer completion |
|---|---|---|
| `Verify NVIDIA Spark SSH access` | Beginner Spark operations runbook, standalone-Hermes ownership, and the foundation/Qwen deployment path that the canonical index later verified as complete. | Later backup, restore, failover, automation, retrieval, and evaluation sequences. |
| `Verify NVIDIA Spark SSH access (2)` | Workstation ODS/Ollama boundaries, both Gemma 4 models, Qwen 3.8 installation and remote routing, plus the supporting tutorials and research notes. | Qwen 3.8 promotion comparison and restart-by-restart resilience checks. |
| `Plan Spark LM Link routing` | Tailnet-only workstation Ollama route, Spark LM Studio/LM Link, named Hermes providers, dynamic discovery, Qwen/Omni memory optimization, and Omni 131K long-context verification. | Shared regression harness and future runtime/model A/B work. |
| `Create setup task checklist` | The source-mapped runbook and the laptop thin-client policy; this audit expands its original 29-note map to all 35 other current notes. | Operational boxes were not completed merely by creating the runbook. |
| `Install VoiceStudio portable` | VoiceStudio v0.5.0 at `D:\Apps\VoiceStudio`, portable data, CUDA diagnostics, TTS, Whisper transcription, Parakeet dictation, and blank-Capture-window recovery. | Optional unused-model cleanup and longer real-microphone/daily-use acceptance. |
| `Document DGX Spark restart state` | First-Spark physical power-cycle recovery, saved recovery snapshot, corrected Qwen-before-Lightning boot order, second Spark NVIDIA Sync access, and initial thermal/no-throttling comparison. | A second controlled reboot of the corrected order, UEFI Auto Boot, QSFP clustering, NCCL, and dual-Spark DeepSeek validation. |

## Current operational finish line

The immediate goal remains the **operational setup**, not every future model, framework, and portfolio lab.

### Must finish for the operational baseline

- [x] Sequence 0 — Reconfirm the baseline and ownership map.
- [ ] Sequence 1 — Backups, restart recovery, and failover are proven.
- [x] Sequence 2 — Laptop fallback is deliberately declined; the laptop uses the authoritative Spark Remote Gateway.
- [ ] Sequence 3A — Skill/plugin safety and intake controls are in place.
- [ ] Sequence 4 — One real coding workflow works through stable local aliases.
- [ ] Sequence 5 — One safe automation works and its failure path alerts correctly.
- [ ] Sequence 6 — The Spark has a pull-only Obsidian replica and retrieval is evaluated before broad indexing.

### Stretch only after the operational baseline

- [ ] Sequence 3B — Complete one development-methodology bakeoff.
- [ ] Sequence 7 — Establish the shared evaluation and observability harness.
- [ ] Sequence 8A — Test exactly one new workstation model; start with `qwen3-coder:30b` if coding is the immediate goal.

### Suggested remaining work blocks

| Work block | Scheduling | Sequence | Estimated hands-on time |
|---|---|---|---:|
| Block 1 | Primary | Remaining backups, restore test, corrected-order reboot, and failover | 1.5–3 h |
| Block 2 | Parallel | Skills/plugin intake repository and safety controls | 2–3 h |
| Block 3 | Parallel | Shared regression set plus one real coding workflow | 2–4 h |
| Block 4 | After Block 1 | First cron/n8n workflow and failure test | 2–3 h |
| Block 5 | After vault backup | Obsidian headless replica plus retrieval evaluation | 3–4 h plus indexing time |
| Block 6 | After regression set | One optional model A/B or remaining cleanup | 1.5–3 h plus download time |

## Already complete — do not repeat

- [x] Spark foundation, secrets, folders, registries, status helpers, and the Qwen 35 service are complete. See [[DGX Spark Operations Setup Guide]].
- [x] Qwen 35 and Qwen 27 lanes, safe switching, LiteLLM routes, and Hermes tests are complete. See [[DGX Spark Model Installation And Switching Guide]].
- [x] Standalone Hermes Gateway and Hermes Serve on Spark are authoritative and reachable from desktop and laptop. See [[Always-On Hermes on DGX Spark]].
- [x] Workstation native Ollama, ODS Open WebUI, SearXNG, model directories, 128K context, and tailnet-only upstream access are complete. See [[ODS Workstation Ollama Integration Research]].
- [x] `gemma4:31b-it-qat` and `gemma4:26b-a4b-it-qat` are downloaded, GPU-tested, tool-tested, and unloaded on the workstation.
- [x] Spark LM Studio, LM Link, Nemotron 3.5 Lightning `Q4_K_M`, named Hermes providers, and dynamic provider discovery are complete. See [[Hermes LM Link And Workstation Model Routing Research]].
- [x] Nemotron 3 Nano Omni text, tool, long-context, image, audio-path, and video serving tests are complete. See [[DGX Spark Nemotron 3 Nano Omni Tutorial]].
- [x] Qwen 35, Qwen 27, and Omni KV allocations are optimized and verified. See [[DGX Spark Qwen NVFP4 Memory And Startup Optimization Research]] and [[DGX Spark Multi-Model Runtime Research]].
- [x] `qwen3.8:27b` is installed once in workstation Ollama, verified through ODS, private Tailscale Serve, and Spark Hermes, and left unloaded while `spark-fast` remains default. See [[Qwen 3.8 27B Ollama Remote Access Research]].
- [x] The laptop is a tested Spark Remote Gateway thin client with no second authoritative Hermes profile and no duplicate workstation-model downloads.
- [x] The first Spark completed a physical power cycle and recovered its stack; the exposed Qwen/Lightning boot-order race was corrected and documented. A later controlled reboot of the corrected order remains in Sequence 1. See [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20]].
- [x] The second Spark is reachable as `SecondSpark` in NVIDIA Sync and passed the initial idle thermal/no-throttling comparison. Clustering waits for the approved QSFP112 DAC and the Sequence 8I readiness gate. See [[DGX Spark Second Node And Dual Spark Readiness Research 2026-08-20]].
- [x] VoiceStudio v0.5.0 is installed portably at `D:\Apps\VoiceStudio`; CUDA diagnostics, generation, Whisper transcription, Parakeet dictation, and the blank `Capture` overlay recovery passed. See [[VoiceStudio Windows Portable Usage]] and [[VoiceStudio Risk Audit]].

---

## Sequence 0 — Reconfirm the baseline and ownership map

**Priority:** Operational P0  
**Time:** 30–45 minutes  
**Goal:** start from the live state, not an older tutorial assumption.

### Read first, in order

1. [[Local Setup Index#Current confirmed state]]
2. [[Local Setup Index#Canonical decisions]]
3. [[DGX Spark Multi-Model Runtime Research#Bottom line]]
4. [[DGX Spark And RTX 5000 Workstation Model Placement Research#Final placement decision]]

### Checklist

- [x] Confirm Spark still reports the intended `qwen35` resident/default lane and the other switchable lanes.
- [x] Confirm Spark LM Studio still shows Nemotron 3.5 Lightning only once and on Spark storage.
- [x] Confirm workstation Ollama still listens only on loopback and Tailscale Serve still owns tailnet HTTPS `8443`.
- [x] Confirm workstation ODS Open WebUI and SearXNG are healthy and ODS Hermes remains disabled.
- [x] Confirm no duplicate Ollama, LM Studio, Hermes, LiteLLM, Open WebUI, or scheduler owns the same port/state.
- [x] Record current versions for Hermes, ODS, Ollama, LM Studio, vLLM image, GPU driver, and each active model revision here or in the canonical fleet manifest.
- [x] Record free disk and free memory on Spark and workstation before further downloads.

### Completion gate

- [x] **Done:** every active service has one owner, one port, one data directory, one route name, and one rollback target.

---

## Sequence 1 — Backups, restart recovery, and failover

**Priority:** Operational P0  
**Time:** 1.5–2 hours  
**Goal:** prove the setup survives failure before adding more tools or models.

### Read first, in order

1. [[Always-On Hermes on DGX Spark#24×7 service shape]]
2. [[personal-hermes-obsidian-multinode-design#Hermes state and profile ownership]]
3. [[personal-hermes-obsidian-multinode-design#Suggested rollout]]
4. [[DGX Spark Operations Setup Guide#Safe stop and rollback commands]]
5. [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20#Controlled reboot test]]
6. [[Spark Hermes Setup Runbook#Phase 4 — Automation (half a day, then grows)]]

### Checklist

- [ ] Run a database-aware `hermes backup` of the authoritative Spark profile and store it outside the vault as a protected secret-bearing artifact.
- [ ] Export a sanitized Hermes profile/config separately so it can be inspected without credentials.
- [ ] Back up Spark LiteLLM configuration, custom-provider configuration, model-manager lane definitions, and service definitions.
- [ ] Back up workstation ODS configuration/data through the supported ODS path; keep model weights reconstructable from the model manifest.
- [ ] Designate exactly one Obsidian replica as the independent backup source; confirm Sync itself is not being treated as backup.
- [ ] Test Hermes restore into a disposable profile/home without replacing the live profile.
- [x] Complete one physical FirstSpark power-cycle recovery and verify Docker/ODS, Qwen `spark-fast`, LiteLLM, Hermes services, LM Studio/LM Link, Tailscale, SSH, and OpenCode return; correct the discovered Qwen-before-Lightning boot-order race. Evidence: [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20#Controlled reboot test]].
- [ ] Run one later controlled reboot and prove the corrected Qwen-before-Lightning order, bot connections, and model picker all return without manual repair.
- [ ] Stop the Qwen backend intentionally and verify a request fails over or alerts according to the documented policy rather than hanging or choosing an unrelated model.
- [ ] Put the workstation to sleep or stop workstation Ollama and verify `desktop-ollama` becomes unavailable while `spark-fast` remains usable.
- [ ] Resume the workstation and verify dynamic model discovery recovers without creating duplicate providers.
- [ ] Verify an active session can resume after the restart without copying `state.db` between devices.

### Evidence to record

- [ ] Backup date, size, storage path, and restore-test result recorded.
- [ ] Restart recovery time and any manual intervention recorded.
- [ ] Failover result, user-visible error/alert, and fallback model identity recorded.

### Completion gate

- [ ] **Done:** one backup has been restored safely, Spark returns after reboot, and loss of either the Qwen worker or workstation produces the intended fallback/alert.

---

## Sequence 2 — Decide the laptop’s independent fallback

**Priority:** Operational P0 decision; implementation optional  
**Time:** 10 minutes to decline, 45–90 minutes to implement  
**Goal:** avoid accidental duplicate profiles while still supporting offline/travel use if needed.

### Read first, in order

1. [[Local Setup Index#4. Make Spark LM Studio the Nemotron 3.5 Lightning shelf and connect both Hermes gateways]]
2. [[Always-On Hermes on DGX Spark#What is shared across devices]]
3. [[Hermes LM Link And Workstation Model Routing Research#Recommended topology]]
4. [[local-ai-architecture-research#Gaming laptop: thin client with graceful offline mode]]

### Decision gate — choose one

- [x] **Chosen:** keep the laptop as a Spark Remote Gateway client only; no duplicate provider configuration is needed.
- [ ] **Optional fallback:** create a clearly named laptop-local Hermes profile with no production bot tokens or schedules.

### Only if the optional fallback is chosen

- [ ] On Spark, run `sudo tailscale set --operator=snknitin` once.
- [ ] Expose Spark loopback LM Studio through tailnet-only HTTPS `8443`; do not use Funnel.
- [ ] Add the stable Spark LM Studio and workstation Ollama provider URLs once to the laptop-local profile.
- [ ] Install one small offline model only, preferably a Qwen 3.5 4B-class GGUF in laptop LM Studio; do not copy the full model shelf.
- [ ] Test laptop-local chat, one safe tool call, remote-model loss, and offline-model selection.
- [ ] Confirm the laptop-local profile has no Telegram/Discord credentials and no production cron jobs.

### Completion gate

- [x] **Done:** the laptop Remote Gateway, shared Spark-backed state, chat, and tool path were tested; there is no second authoritative Hermes state or duplicated model shelf.

---

## Sequence 3 — Skills, plugins, and tool governance

### Sequence 3A — Put safety and intake controls in place

**Priority:** Operational P0  
**Time:** 1–2 hours  
**Goal:** make every future skill/plugin installation reviewable and reversible.

#### Read first, in order

1. [[local-ai-tooling-catalog-and-rollout#Installation model]]
2. [[local-ai-tooling-catalog-and-rollout#NVIDIA SkillSpector]]
3. [[local-ai-tooling-catalog-and-rollout#DCG — Destructive Command Guard]]
4. [[local-ai-tooling-catalog-and-rollout#What syncs, and what is installed separately]]
5. [[personal-hermes-obsidian-multinode-design#Skills and configuration]]
6. [[local-ai-tooling-catalog-and-rollout#Stage 0 — inventory and pinning]]

#### Checklist

- [ ] Create a private canonical `ai-fleet` or equivalent skills/config repository with no secrets.
- [ ] Add a manifest schema for tool/skill name, source URL, pinned commit/release, license, target harness/device, permissions, secrets, update method, tests, and removal procedure.
- [ ] Install and test **DCG / Destructive Command Guard** separately in each supported harness on laptop, workstation, and Spark.
- [ ] Install **NVIDIA SkillSpector** once as the central pre-install/CI scanner.
- [ ] Make the intake path mandatory: discover → pin → SkillSpector → manual script/hook/license review → disposable test → promote → deploy.
- [ ] Confirm experimental skills cannot write into the canonical reviewed directory automatically.
- [ ] Confirm secrets, `.env`, OAuth sessions, browser cookies, live databases, and machine-specific credentials are excluded from the repo.
- [ ] Add a documented removal/rollback check for every promoted tool or skill.

#### Completion gate

- [ ] **Done:** one harmless sample skill has moved through the full intake pipeline and has been removed/reinstalled from the pinned source successfully.

### Sequence 3B — Choose one development methodology

**Priority:** Optional P1  
**Time:** 2–4 hours  
**Goal:** choose one default methodology from evidence instead of installing several overlapping global packs.

#### Read first, in order

1. [[local-ai-tooling-catalog-and-rollout#Skills, plugins, and development methodologies]]
2. [[local-ai-tooling-catalog-and-rollout#Addy Osmani Agent Skills / “7 steps of SDLC”]]
3. [[local-ai-tooling-catalog-and-rollout#gstack by Garry Tan]]
4. [[local-ai-tooling-catalog-and-rollout#Compound Engineering]]
5. [[local-ai-tooling-catalog-and-rollout#Superpowers]]

#### Controlled bakeoff

- [ ] Create one small disposable repository and one fixed task/evaluation sheet.
- [ ] Trial **Addy Osmani Agent Skills** first as the recommended balanced baseline.
- [ ] Trial **gstack** only after removing/isolating the Addy workflow.
- [ ] Trial **Compound Engineering** only after removing/isolating gstack.
- [ ] Trial the **Superpowers plugin** only after removing/isolating the previous pack.
- [ ] Record completion quality, corrections, tool use, token use, file churn, time, and workflow friction for each.
- [ ] Promote exactly one default methodology to the canonical repo; keep others project-local or uninstalled.
- [ ] Add `/teach`, `/prototype`, and `/grill-me` only where they add a distinct workflow; do not duplicate an already installed equivalent.

#### Completion gate

- [ ] **Done:** one methodology is selected, pinned, deployed to the intended harnesses, and the other global candidates are absent.

### Sequence 3C — Exercise the useful skills already available

**Priority:** P1  
**Goal:** learn what is already installed before adding more plugins.

- [ ] Use `research` plus browser control on one primary-source research question and save the result in a dedicated learning workspace.
- [ ] Use `prototype` on one disposable design question; confirm the result is not treated as production code.
- [ ] Use `tdd` on one small feature from failing test to passing implementation.
- [ ] Use `code-review` on one real branch and resolve its highest-priority finding.
- [ ] Use `diagnosing-bugs` on one reproducible failure without mixing diagnosis and implementation.
- [ ] Use the GitHub skills for one issue/PR/CI workflow.
- [ ] Use Hugging Face CLI/model or dataset skills on one pinned download/evaluation task.
- [ ] Use the document, PDF, spreadsheet, and presentation skills on one small artifact each only if those formats are part of current work.
- [ ] Use the Remotion skill only inside a real video project after confirming the license boundary.
- [ ] Use Vercel/Supabase/Next.js skills only inside a project that actually uses that stack.

### Sequence 3D — Recommended plugin shortlist

**Priority:** P1/P2; install only after Sequence 3A  
**Rule:** each plugin gets its own acceptance test and removal test.

- [ ] **Superpowers:** evaluate only as the methodology candidate in Sequence 3B.
- [ ] **Codex Security:** evaluate on a disposable repository; compare findings with the existing code-review/security workflow.
- [ ] **Zotero:** install if academic-paper capture and citation management will become a real workflow.
- [ ] **Sentry:** install when the first production-shaped FDE app needs error/trace evidence.
- [ ] **Figma or Canva:** choose one for design handoff; do not install both until distinct needs are demonstrated.
- [ ] **Linear or Asana:** choose one only if Obsidian plus GitHub issues no longer provide enough project tracking.
- [ ] **Cloudflare:** add only for an app that needs Cloudflare deployment, DNS, Workers, or security; Vercel is already available for Vercel projects.
- [ ] **Slack or Teams:** add only when a real team workspace becomes an automation target.
- [ ] **Stripe, HubSpot, Apollo, Airtable, Monday.com, Outlook, SharePoint, Box, Replit, Wix, Lovable, Base44, HeyGen, HyperFrames, and Semrush:** leave uninstalled until a named project has acceptance criteria requiring them.

---

## Sequence 4 — Make local-model coding a daily workflow

**Priority:** Operational P0  
**Time:** 1.5–2 hours  
**Goal:** finish one real coding task through stable aliases from both workstation and laptop.

### Read first, in order

1. [[Spark Hermes Setup Runbook#Phase 3 — Coding on local models (2–3 h)]]
2. [[Always-On Hermes on DGX Spark#Model routing]]
3. [[local-ai-architecture-research#Suggested rollout order]]
4. [[DGX Spark And RTX 5000 Workstation Model Placement Research#The practical workstation shortlist]]

### Checklist

- [ ] Choose one coding client path first: Codex/Hermes, Continue, Cline, or Cursor; do not configure every client simultaneously.
- [ ] Point the chosen client at a stable logical alias, not raw model port `8000`, `11434`, or `1234`.
- [ ] Run one small real repository task from the workstation through `spark-fast`.
- [ ] Run the same task class from the laptop through the Spark Remote Gateway.
- [ ] Test completion, streamed output, structured JSON, one tool call, a multi-file edit, cancellation, and a deliberately invalid tool call.
- [ ] Compare the same fixed task with the cloud/Codex path; record accuracy, corrections, latency, and privacy/cost tradeoff.
- [ ] If a workstation `code` route is created, configure explicit fallback to `spark-fast` when the workstation sleeps.
- [ ] Keep subscriptions unchanged for two weeks while recording which tasks local models handle fully.

### Completion gate

- [ ] **Done:** one real coding task succeeds from each device, raw ports are hidden, and workstation loss falls back or fails explicitly according to policy.

---

## Sequence 5 — Add one safe automation and prove failure behavior

**Priority:** Operational P0  
**Time:** 2–3 hours  
**Goal:** one useful scheduled job, one production owner, and no silent side effects.

### Read first, in order

1. [[Spark Hermes Setup Runbook#Phase 4 — Automation (half a day, then grows)]]
2. [[Always-On Hermes on DGX Spark#Daily phone interface]]
3. [[personal-hermes-obsidian-multinode-design#Concurrency and failure rules]]
4. [[local-ai-tooling-catalog-and-rollout#Stage 3 — central services by trust boundary]]

### Checklist

- [ ] Create one morning-brief Hermes cron job on Spark using a pinned route, timeout, budget, and delivery target.
- [ ] Use a cheap/small route for routine extraction if the small route is actually healthy; otherwise use `spark-fast` explicitly rather than an unverified alias.
- [ ] If n8n is needed, enable the existing ODS n8n extension on Spark and keep workstation n8n development-only.
- [ ] Give every job one production owner and disable any duplicate schedule elsewhere.
- [ ] Add idempotency keys/durable locks to anything with side effects.
- [ ] Send consequential actions to `#approvals`; route failures to `#automation-alerts`.
- [ ] Test a normal run, duplicate trigger, model timeout, Qwen outage, Spark reboot, workstation sleep, and delivery failure.
- [ ] Verify the job never silently sends private data to a cloud fallback.

### Completion gate

- [ ] **Done:** the job runs once, does not duplicate its side effect, alerts on failure, and returns after reboot.

---

## Sequence 6 — Obsidian headless replica and measured retrieval

**Priority:** Operational P0  
**Time:** 3–4 hours plus indexing  
**Goal:** Hermes can read the vault from Spark without creating sync conflicts, and retrieval quality is measured before broad trust.

### Read first, in order

1. [[personal-hermes-obsidian-multinode-design#Obsidian on the Spark]]
2. [[personal-hermes-obsidian-multinode-design#Safe agent-writing pattern]]
3. [[Always-On Hermes on DGX Spark#Obsidian on Spark]]
4. [[Spark Hermes Setup Runbook#Phase 5 — Obsidian + retrieval (2–3 h, plus an eval)]]
5. [[DGX Spark ODS Playbook and Model Roadmap#Models to install now]]
6. [[dgx-spark-current-models-report#Install and experiment matrix]]

### Replica checklist

- [ ] Back up the vault independently before adding another replica.
- [ ] Install Node.js 22+ and official `obsidian-headless` on Spark.
- [ ] Create a new Spark replica directory outside `HERMES_HOME` and outside every other sync tool.
- [ ] Start the Spark replica in `pull-only` mode and run continuous sync as one supervised service.
- [ ] Give Hermes read-only access to the replica; verify it cannot write outside an explicitly granted path.
- [ ] Confirm no desktop Obsidian Sync, Git, Syncthing, Dropbox, or second headless client is also syncing that same Spark folder.

### Retrieval checklist

- [ ] Deploy `Qwen/Qwen3-Embedding-0.6B` and `Qwen/Qwen3-Reranker-0.6B` through the chosen TEI/separate-reranker path, or explicitly document a different one-owner design.
- [ ] Build a fixed evaluation set of about 20 real questions covering easy lookup, cross-note synthesis, dates, code/config facts, ambiguous terms, and “not in vault” negatives.
- [ ] Index a representative subset before indexing the entire vault.
- [ ] Measure retrieval recall, reranker benefit, citation correctness, latency, and failure cases.
- [ ] Spot-check at least five wrong or low-confidence retrievals and record why they failed.
- [ ] Increase embedding size from 0.6B only if the measured recall gain justifies extra memory.
- [ ] Index the full vault only after the evaluation threshold is accepted.

### Optional write path — do only after read-only success

- [ ] Change only the Spark replica to bidirectional after deliberate conflict testing.
- [ ] Restrict Hermes writes to `Agent Inbox/Spark Hermes/` with unique timestamp/task filenames.
- [ ] Test simultaneous desktop edit plus agent inbox write; confirm no shared canonical note is overwritten.
- [ ] Keep consolidation into canonical notes as a human or single serialized job.

### Completion gate

- [ ] **Done:** pull-only sync is stable, Hermes reads the replica, the 20-question retrieval evaluation is recorded, and any write access is confined to the inbox.

---

## Sequence 7 — Shared evaluation, observability, and runtime A/B

**Priority:** P1 after the operational core  
**Goal:** every new model/runtime is judged with the same evidence.

### Read first, in order

1. [[DGX Spark ODS Playbook and Model Roadmap#Phase 1 - Serving and inference engineering]]
2. [[DGX Spark Aug 2026 Model Deployment Research#Promotion gates and lifecycle]]
3. [[DGX Spark Qwen NVFP4 Memory And Startup Optimization Research#Acceptance test before calling co-residency successful]]
4. [[DGX Spark Multi-Model Runtime Research#Recommended architecture]]
5. [[dgx-spark-twitter-bookmarks-analysis#Reproduction checklist for each candidate]]

### Checklist

- [ ] Create one versioned regression set for chat, coding, vision, tools, malformed tools, structured JSON, long context, cancellation, and refusal/safety behavior.
- [ ] Record model revision, quantization, runtime image/digest, flags, context, concurrency, hardware, and prompt-set version for every run.
- [ ] Record quality, tool validity, p50/p95 TTFT, inter-token latency, prompt/decode throughput, peak memory, cold start, warm start, cache reuse, and failures.
- [ ] Benchmark the stopped ODS llama.cpp path once if it remains a possible runtime; do not make it resident merely to collect a number.
- [ ] A/B vLLM versus SGLang with the same checkpoint, quantization, prompts, context, and concurrency.
- [ ] Add Langfuse/Token Spy or Sentry only when it has a clear owner, retention policy, and acceptance test.
- [ ] Run an eight-hour soak only for a candidate being considered for 24×7 promotion.
- [ ] Keep `spark-fast` as rollback until the challenger passes every required gate.

### Completion gate

- [ ] **Done:** one reproducible report compares two runtimes/models under identical conditions and another person/agent can rerun it from the pinned manifest.

---

## Sequence 8 — Models to explore without duplicating the existing shelf

**Priority:** P1/P2  
**Rule:** download one candidate at a time, complete its whole test sequence, then decide keep/remove before starting the next.

### Read before any new model

1. [[DGX Spark Multi-Model Runtime Research#Model order for the requested tests]]
2. [[DGX Spark Model Installation And Switching Guide#Step 22 — Rules for every additional model]]
3. [[DGX Spark Additional Models And Convenience Runtimes Research#Required checks before the tutorials give copy-paste commands]]
4. [[DGX Spark And RTX 5000 Workstation Model Placement Research#Placement matrix for the current model list]]
5. [[DGX Spark ODS Playbook and Model Roadmap#Safe installation pattern]]

### Intake gate for every model

- [ ] Confirm official publisher, exact model ID/tag, revision, license, runtime support, quantization, download size, and unique role.
- [ ] Confirm the model is not already stored in another runtime unless this is a deliberate format/runtime A/B.
- [ ] Record expected disk, loaded memory, context, tool/vision support, endpoint, alias, and rollback model.
- [ ] Download while existing services are healthy, but stop/unload the competing large worker before first load.
- [ ] Test raw API/model identity, normal chat, structured tool call, target specialty, long context, memory, and unload/reload.
- [ ] Test through Hermes only after the raw endpoint passes.
- [ ] Compare against the current baseline using the shared evaluation set.
- [ ] Decide and record: keep downloaded, promote to named lane, defer, or remove.

### Existing baseline tally

- [x] Qwen 3.6 35B-A3B — Spark `spark-fast` baseline.
- [x] Qwen 3.6 27B lane — Spark comparison lane.
- [x] Nemotron 3 Nano Omni — Spark multimodal specialist.
- [x] Nemotron 3.5 Lightning `Q4_K_M` — Spark LM Studio shelf.
- [x] Gemma 4 31B — workstation Ollama dense verifier.
- [x] Gemma 4 26B-A4B — workstation Ollama MoE worker.
- [x] Gemma 3 4B — small connector/vision test.

### 8A — First missing workstation model: Qwen3-Coder 30B

**Why:** adds a dedicated agentic-coding model rather than another general chat model.  
**Runtime/home:** workstation native Ollama.  
**Official catalog:** [Ollama `qwen3-coder`](https://ollama.com/library/qwen3-coder).

- [ ] Pull only `qwen3-coder:30b` into `D:\LocalLLama\models\ollama`.
- [ ] Verify the exact size, context, `tools` capability, GPU residency, and one-model eviction.
- [ ] Test repository navigation, multi-file edit, failing-test repair, structured tool use, and recovery from one tool error.
- [ ] Compare identical tasks against Gemma 4 31B and `spark-fast`.
- [ ] Unload it after testing and keep it only if it wins a real coding role.
- [ ] **Done:** a fixed coding report identifies which tasks route to `qwen3-coder`, Gemma, or `spark-fast`.

### 8B — Independent reasoning/tool baseline: gpt-oss 20B

**Why:** gives an Apache-2.0 OpenAI open-weight baseline with a different architecture/training lineage.  
**Runtime/home:** workstation native Ollama.  
**Official catalog:** [Ollama `gpt-oss:20b`](https://ollama.com/library/gpt-oss:20b).

- [ ] Pull `gpt-oss:20b` only after Sequence 8A is complete.
- [ ] Verify exact size, 128K runtime context, tools, structured outputs, and GPU residency.
- [ ] Compare reasoning, agent tool calls, coding repair, and latency with Qwen3-Coder and `spark-fast`.
- [ ] Test low/medium/high reasoning controls if exposed by the chosen client.
- [ ] Unload after testing; retain only if it wins a distinct role.
- [ ] **Done:** keep/remove decision and route role are recorded.

### 8C — Coding plus vision challenger: Devstral Small 2 24B

**Why:** dedicated software-engineering tool use with vision input.  
**Runtime/home:** workstation LM Studio lab; do not duplicate it in Ollama.  
**Official catalog:** [LM Studio `mistralai/devstral-small-2-2512`](https://lmstudio.ai/models/mistralai/devstral-small-2-2512).

- [ ] Update the LM Studio runtime only through the supported updater and record the runtime version.
- [ ] Download one recommended GGUF quantization to the LM Studio model directory.
- [ ] Estimate at the selected context before loading.
- [ ] Test codebase exploration, multi-file editing, tools, screenshot/mockup understanding, and unload/TTL.
- [ ] Compare with `qwen3-coder:30b`; keep only if its vision or software-engineering behavior is materially better.
- [ ] **Done:** keep/remove decision and lab preset are recorded.

### 8D — Lightweight visual/OCR comparison: Qwen3-VL 8B

**Why:** a small text/image/tool model for screenshots, UI understanding, and multilingual OCR without loading Omni.  
**Runtime/home:** workstation Ollama; laptop only if measured memory is acceptable.  
**Official catalog:** [Ollama `qwen3-vl`](https://ollama.com/library/qwen3-vl).

- [ ] Pull `qwen3-vl:8b`, not 30B/32B, for the first lightweight test.
- [ ] Test screenshots, UI element identification, English plus one multilingual OCR page, a chart, and a tool call.
- [ ] Compare image/OCR accuracy with Gemma 4 and Spark Omni on identical files.
- [ ] Unload after testing and keep only if fast lightweight vision is a real gap.
- [ ] **Done:** the visual-routing rule is recorded.

### 8E — Document OCR specialist: olmOCR 2 7B

**Why:** adds a focused academic/technical-document OCR path instead of asking a general VLM to parse every document.  
**Runtime/home:** workstation LM Studio lab.  
**Official catalog:** [LM Studio `allenai/olmocr-2-7b-1025`](https://lmstudio.ai/models/allenai/olmocr-2-7b-1025).

- [ ] Download one GGUF quantization only after confirming the toolkit/prompt metadata requirements.
- [ ] Test real academic PDFs, technical documentation, tables, equations, and one poor scan.
- [ ] Compare Markdown structure and citations with Qwen3-VL, Gemma 4, and Omni.
- [ ] Keep it only if the specialized pipeline wins on the real corpus.
- [ ] **Done:** OCR benchmark and keep/remove decision are recorded.

### 8F — Quick Ollama embedding prototype, only if TEI is not yet ready

**Why:** `qwen3-embedding:0.6b` is a simple Ollama RAG prototype, but it does not replace the planned separate reranker.  
**Official catalog:** [Ollama `qwen3-embedding`](https://ollama.com/library/qwen3-embedding).

- [ ] Decide whether this is a temporary prototype or an unnecessary duplicate of the TEI 0.6B embedding service.
- [ ] If justified, pull only `qwen3-embedding:0.6b` and run the same 20-question retrieval evaluation.
- [ ] Do not pull 4B or 8B until the 0.6B evaluation establishes a recall gap.
- [ ] **Done:** choose Ollama prototype or TEI production path; do not maintain both without evidence.

### 8G — Muse Glimmer 30B creative experiment

**Why:** genuinely different creative/multimodal behavior; runtime support is newer and riskier.  
**Read:** [[DGX Spark Muse Glimmer 30B Readiness Tutorial]] and [[DGX Spark Additional Models And Convenience Runtimes Research#Muse Glimmer 30B]].

- [ ] Resolve the current official model/runtime image and pin its digest before loading.
- [ ] Start with the base model and no DFlash assistant.
- [ ] Prefer one workstation LM Studio 4-bit experiment first; use Spark only for the full reference path.
- [ ] Test text identity, creative prompt set, one image, tools if supported, memory, and rollback.
- [ ] Add the DFlash assistant only after a clean baseline.
- [ ] **Done:** compatibility, quality, and keep/remove decision are recorded.

### 8H — Qwen 3.8 release gate

**Read:** [[Local Setup Index#8. Hold Qwen 3.8 behind a release gate]] and [[DGX Spark Additional Model Tutorials Index#What to do when Qwen 3.8 is released]].

- [x] Confirm the official Ollama package: `qwen3.8:27b`, 27.3B, Q4_K_M, approximately 18 GB, published through the official Ollama library.
- [x] Confirm runtime support: the manifest requires Ollama 0.32.12 and the workstation runs 0.32.13.
- [x] Finish and verify the workstation Ollama download without deleting or duplicating any current model.
- [x] Verify local chat, structured tools, vision path, effective 256K context, ODS Open WebUI, Tailscale Serve, and Spark Hermes discovery.
- [ ] Compare chat, coding, vision, reasoning, tools, long context, and latency with Qwen 3.6.
- [x] Keep Spark as capacity/reference path; leave `spark-fast` as the current default.
- [ ] Change `spark-fast` only after the full regression suite and rollback test pass.
- [ ] **Done:** promotion or rejection decision is evidence-backed; release-day novelty is not the reason.

### 8I — Spark capacity and engine experiments, in order

**Read:** [[DGX Spark ODS Playbook and Model Roadmap#Install later or benchmark experimentally]], [[DGX Spark Aug 2026 Model Deployment Research#Recommended operating set]], and [[dgx-spark-current-models-report#Install and experiment matrix]].

#### Two-Spark readiness gate

- [x] Add the second Spark to NVIDIA Sync with a unique hostname/alias and keep the first Spark as the sole Hermes/routing owner.
- [x] Compare both Sparks at idle and confirm the second Spark shows no current thermal throttling; retain the temporary 2200 MHz cap only as a reversible workload precaution, not as a memory limit.
- [ ] Confirm both Sparks have matching intended OS/driver/firmware levels and compatible numeric UID/GID before shared-file or cluster work.
- [ ] Install one NVIDIA-approved QSFP112 400G DAC between the matching ConnectX-7 ports; do not attempt distributed sharding over Wi-Fi or ordinary LAN.
- [ ] Use NVIDIA Sync Cluster Assistant, require the link test to exceed NVIDIA's 184 Gbit/s validation floor, and pass NCCL tests.
- [ ] Prove one NVIDIA-validated two-node workload before attempting the experimental dual-Spark DeepSeek profile.

- [ ] Qwen 3.5 122B-A10B — create an exclusive, pinned, isolated lane and test first.
- [ ] Poolside Laguna S 2.1 plus matching DFlash — test only after license, parser, and runtime review.
- [ ] Qwen3-Coder-Next — test an official/reputable GGUF or FP8 path only after the smaller coder benchmark justifies it.
- [ ] Step 3.7 Flash — run alone at conservative context through its required llama.cpp path.
- [ ] DeepSeek V4 Flash — isolated final experiment; never infer one-Spark behavior from multi-GPU results.
- [ ] Ling 3.0 Flash — keep blocked until provenance, license, source, and digest are verified.
- [ ] **Done:** every experiment has its own pinned lane, acceptance record, rollback, and no impact on `spark-fast`.

---

## Sequence 9 — Fine-tuning and SLM engineering

**Priority:** P1 after inference/retrieval stability  
**Goal:** one reproducible adapter pipeline, not four unrelated tutorials.

### Read first, in order

1. [[DGX Spark And RTX 5000 Workstation Model Placement Research#Realistic fine-tuning scope on 48 GB]]
2. [[DGX Spark ODS Playbook and Model Roadmap#Phase 2 - Fine-tuning and SLM engineering]]
3. [[Spark Hermes Setup Runbook#Phase 6 — Exploration lanes (ongoing — this order)]]

### Checklist

- [ ] Choose one 7–14B base/instruction model with confirmed Transformers/Unsloth support; do not train an NVFP4 inference checkpoint.
- [ ] Define one real task and fixed dataset with train/validation/test separation.
- [ ] Define the base-model evaluation before training.
- [ ] Unload workstation Ollama/LM Studio models and verify free VRAM before each training run.
- [ ] Run the fundamental PyTorch/PEFT LoRA path first.
- [ ] Repeat the same controlled task with Unsloth.
- [ ] Repeat with LLaMA Factory.
- [ ] Repeat with NeMo only after the simpler paths are understood.
- [ ] Compare quality, training time, peak memory, reproducibility, and operational complexity.
- [ ] Select one adapter, compare base versus adapter, and reject it if the evaluation does not improve.
- [ ] Export a separate serving artifact; never overwrite the base model.
- [ ] Quantize only the accepted artifact.
- [ ] Register it under a new LiteLLM alias and run the full regression suite.
- [ ] Keep normal Hermes work on `spark-fast` while the workstation GPU is leased to training.

### Completion gate

- [ ] **Done:** dataset, configs, adapter, evaluation, serving artifact, route, rollback, and reproduction instructions are all versioned.

---

## Sequence 10 — Tools and application lanes to explore later

**Priority:** P2; install only for a named application  
**Primary catalog:** [[local-ai-tooling-catalog-and-rollout]]

### Browser, research, and publishing

- [ ] **Browser Use:** deploy on the workstation with a dedicated browser profile, allowlists, and separate read-only versus side-effecting workflows. Read [[local-ai-tooling-catalog-and-rollout#Browser Use and the “50 ms latency loop”]].
- [ ] **Firecrawl or Crawl4AI:** benchmark the same site set and choose one; do not deploy both by default. Read [[local-ai-tooling-catalog-and-rollout#Firecrawl]] and [[local-ai-tooling-catalog-and-rollout#Crawl4AI]].
- [ ] **Last30Days plus ScrapeCreators:** use for trend discovery only after API cost, terms, and credential handling are accepted. Read [[local-ai-tooling-catalog-and-rollout#Last30Days and ScrapeCreators]].
- [ ] **NotebookLM MCP:** keep unofficial automation isolated with its own Google browser profile; do not call it Google-supported. Read [[local-ai-tooling-catalog-and-rollout#NotebookLM MCP / open-source NotebookLM alternative]].
- [ ] **Buffer MCP:** create drafts by default and require human approval for publishing. Read [[local-ai-tooling-catalog-and-rollout#Buffer publisher]].
- [ ] Resolve the exact intended **Paper MCP**, **plain-writing skill**, and **Frontend Slides** URL before installing anything. Read [[local-ai-tooling-catalog-and-rollout#Unresolved names requiring URLs]].

### Agent management, memory, and workflow

- [ ] **Paperclip versus Multica:** evaluate the same small workload; deploy neither in production unless it solves work management not already covered by Hermes/ODS/n8n. Read [[local-ai-tooling-catalog-and-rollout#Paperclip]] and [[local-ai-tooling-catalog-and-rollout#Multica]].
- [ ] **Mem0 versus Honcho:** evaluate only when an application needs programmable shared memory; Hermes memory plus Obsidian remains the default. Read [[local-ai-tooling-catalog-and-rollout#Mem0]] and [[local-ai-tooling-catalog-and-rollout#Honcho and the DGX Spark]].
- [ ] **Langflow:** use for visual AI-flow prototypes, not as a second production scheduler beside n8n. Read [[local-ai-tooling-catalog-and-rollout#Langflow]].
- [ ] **CrewAI:** use only inside a specific Python multi-agent application. Do not use AutoGen for a new project. Read [[local-ai-tooling-catalog-and-rollout#CrewAI]] and [[local-ai-tooling-catalog-and-rollout#AutoGen]].
- [ ] **Composio:** add only if many SaaS integrations justify another hosted auth boundary. Read [[local-ai-tooling-catalog-and-rollout#Composio]].
- [ ] **Daytona:** add only for untrusted/high-risk code execution that needs stronger isolation than local containers. Read [[local-ai-tooling-catalog-and-rollout#Daytona]].

### RAG, OCR, voice, creative, and deployment

- [ ] **RAGFlow:** deploy on the x86 workstation only for a document-heavy product with measured requirements; compare with existing ODS/Qdrant first. Read [[local-ai-tooling-catalog-and-rollout#RAGFlow]].
- [ ] **Unlimited-OCR:** test one pinned container on workstation or Spark and route it as `ocr-doc`; compare with olmOCR/Qwen3-VL/Omni first. Read [[local-ai-tooling-catalog-and-rollout#“Baidu/Baidy UnlimitedOCR”]].
- [ ] **Voicebox:** evaluate on workstation with consent, privacy, storage, and private-network controls. Read [[local-ai-tooling-catalog-and-rollout#Voicebox]].
- [ ] **Remotion:** create one project-local deterministic video and confirm its license applies. Read [[local-ai-tooling-catalog-and-rollout#Remotion]].
- [ ] **Higgsfield:** evaluate only as a paid hosted creative tool; do not assume a consumer plan provides API entitlement. Read [[local-ai-tooling-catalog-and-rollout#Higgsfield]].
- [ ] **here.now:** use only for disposable non-secret previews; use Vercel for maintained applications. Read [[local-ai-tooling-catalog-and-rollout#here.now]].
- [ ] Choose Astro for content/static work or Next.js for interactive apps; add Convex only intentionally. Read [[local-ai-tooling-catalog-and-rollout#Next.js, Astro, Convex, and Vercel]].

### FDE portfolio sequence

Read [[DGX Spark ODS Playbook and Model Roadmap#Phase 3 - FDE portfolio applications]].

- [ ] Complete RAG Application in AI Workbench.
- [ ] Complete Text to Knowledge Graph.
- [ ] Complete Multi-Agent Chatbot.
- [ ] Complete Multi-modal Inference.
- [ ] Complete Video Search and Summarization as the capstone.
- [ ] Choose two projects and add requirements, architecture, evaluation data, latency/memory, observability, security, failure recovery, rollback, and a demo.
- [ ] **Done:** two case studies are production-shaped and reproducible, not just screenshots of completed playbooks.

---

## Sequence 11 — Monthly maintenance

**Priority:** recurring  
**Read:** [[local-ai-tooling-catalog-and-rollout#Stage 6 — scheduled review]]

- [ ] Update pinned tools/models in staging, never directly on the production Spark.
- [ ] Run service health, model identity, tool-call, long-context, and failover smoke tests.
- [ ] Test Hermes, ODS, and vault backup restoration.
- [ ] Review licenses, pricing, plugin permissions, and dependency advisories.
- [ ] Remove duplicate skills, unused plugins, stale model copies, and abandoned runtime environments.
- [ ] Rotate integration tokens and confirm secrets remain outside Git/Obsidian.
- [ ] Verify no two services own the same schedule, bot identity, writable database, or model alias.
- [ ] Recheck disk, cache growth, model revisions, container digests, and rollback artifacts.
- [ ] Review whether any workstation-dependent production route needs to move to Spark.

---

## Complete source map — all existing notes accounted for

Use this map to decide what to read deeply and what to keep as reference. As of 2026-08-21 it covers all 35 other Markdown notes currently in this folder.

### Canonical/current operating notes

- [[Local Setup Index]] — current truth, completed state, exact resume point, and canonical decisions.
- [[Always-On Hermes on DGX Spark]] — Hermes ownership, clients, messaging, routing, Obsidian, and 24×7 service policy.
- [[Spark Hermes Setup Runbook]] — completed early phases plus the remaining coding, automation, retrieval, and exploration sequence.
- [[DGX Spark ODS Playbook and Model Roadmap]] — serving, fine-tuning, FDE, security, model, and runtime learning roadmap.
- [[personal-hermes-obsidian-multinode-design|Personal Hermes, Obsidian, and Multi-Node Inference Design]] — state ownership, sync, backups, routing, and failure rules.
- [[local-ai-tooling-catalog-and-rollout|Local AI Tooling Catalog and Rollout]] — tools, skills, plugins, services, security boundaries, and staged rollout.
- [[DGX Spark And RTX 5000 Workstation Model Placement Research]] — machine ownership, model placement, and fine-tuning scope; use the warning at the top to avoid stale assumptions.
- [[ODS Workstation Ollama Integration Research]] — verified workstation ODS/Ollama state and correct model-store boundaries.
- [[Hermes LM Link And Workstation Model Routing Research]] — verified current Ollama, LM Link, provider discovery, and cross-gateway routing.
- [[DGX Spark Nemotron 3.5 Lightning Via LM Studio Research]] — chosen Nemotron 3.5 Lightning LM Studio path and quantization evidence.
- [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20]] — verified first-Spark physical recovery, service ownership, corrected boot order, and the remaining reboot gate.
- [[DGX Spark Second Node And Dual Spark Readiness Research 2026-08-20]] — second-node role, approved cable choices, cluster validation, and dual-Spark limits.
- [[VoiceStudio Windows Portable Usage]] — verified portable VoiceStudio state, first-use workflow, settings, backup, and recovery guidance.

### Completed setup/tutorial references

- [[DGX Spark Operations Setup Guide]] — foundation and Hermes setup are complete; use for status, rollback, and service recovery.
- [[DGX Spark Model Installation And Switching Guide]] — Qwen installations are complete; use Step 22/23 for additional-model rules and daily operations.
- [[DGX Spark Nemotron 3 Nano Omni Tutorial]] — completed specialist lane; use for rebuild/rollback and future media-quality tests.
- [[DGX Spark LM Studio And LM Link Tutorial]] — older Spark CLI reference; the live LM Link/Nemotron rollout is already complete.
- [[RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial]] — current beginner workstation guide; Ollama/Gemma portions are complete, while a separate workstation LM Studio lab remains optional.
- [[Qwen 3.8 27B Ollama Remote Access Research]] — completed single-copy workstation installation and ODS/Tailscale/Spark-Hermes route; promotion evaluation remains open.

### Optional model tutorials — not the active default path

- [[DGX Spark Additional Model Tutorials Index]] — catalog only; [[Local Setup Index]] supersedes its older all-on-Spark order.
- [[DGX Spark Gemma 4 Models Tutorial]] — optional Spark-specific Gemma benchmark; workstation Ollama Gemmas are already complete.
- [[DGX Spark Nemotron 3.5 Lightning Tutorial]] — vLLM/DSpark reference only; LM Studio on Spark is the chosen deployment.
- [[DGX Spark Muse Glimmer 30B Readiness Tutorial]] — advanced/pre-release gate; still genuinely untested.
- [[DGX Spark Ollama And ODS Tutorial]] — reference/rollback alternative only; native workstation Ollama is the active plan.
- [[RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial]] — superseded historical lab tutorial; do not use its unchecked boxes as current truth.

### Supporting research — read for decisions, not as linear setup

- [[DGX Spark Multi-Model Runtime Research]] — downloaded/registered/loaded/healthy/selected distinctions and memory-aware switching.
- [[DGX Spark Qwen NVFP4 Memory And Startup Optimization Research]] — verified Qwen KV, long-context, startup, and co-residency results.
- [[DGX Spark Additional Models And Convenience Runtimes Research]] — primary-source model/runtime identities, caveats, and deferred items.
- [[DGX Spark Aug 2026 Model Deployment Research]] — hardened profiles, security gates, lifecycle, and candidate model evidence.
- [[dgx-spark-current-models-report|DGX Spark Current Models Report]] — model/engine matrix and safe experiment order.
- [[dgx-spark-playbook-roadmap-draft|DGX Spark Playbook Roadmap Draft]] — historical draft supporting the consolidated roadmap.
- [[dgx-spark-twitter-bookmarks-analysis|DGX Spark Twitter Bookmarks Analysis]] — social leads, evidence quality, and claims that require local reproduction.
- [[local-ai-architecture-research|Local AI Architecture Research]] — subscription/API boundaries, runtime choices, device roles, and canonical configuration design.
- [[DGX Spark Automatic Power Recovery Research]] — official power-return evidence and the still-unverified live UEFI Auto Boot setting.
- [[VoiceStudio Risk Audit]] — completed risk inventory and acceptance boundaries for VoiceStudio, including the known blank Capture overlay.

## Final completion definition

- [ ] The operational P0 sequences are complete with evidence.
- [ ] Backups and restore paths have been tested, not merely configured.
- [ ] Every production service, schedule, model route, database, and bot has one owner.
- [ ] The laptop, workstation, and Spark each have a documented role and failure behavior.
- [ ] New skills/plugins enter through the reviewed intake pipeline.
- [ ] Coding and one automation work through stable aliases.
- [ ] The Spark vault replica is safe and retrieval quality has been measured.
- [ ] Every new model is evaluated one at a time and either assigned a unique role or removed.
- [ ] Fine-tuning and FDE labs begin only after the operational foundation is stable.

## Related

- [[Local Setup Index]]
- [[Always-On Hermes on DGX Spark]]
- [[Spark Hermes Setup Runbook]]
- [[local-ai-tooling-catalog-and-rollout|Local AI Tooling Catalog and Rollout]]
- [[DGX Spark ODS Playbook and Model Roadmap]]
