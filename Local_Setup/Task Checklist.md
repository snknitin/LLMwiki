---
title: Task Checklist
created: 2026-08-15
updated: 2026-09-24
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

## Current Codex project completion audit — 22 August 2026

Only work supported by the task record, live verification, or a dated evidence note is marked complete.

| Codex task | Verified completion reflected in this checklist | Still open; do not infer completion |
|---|---|---|
| `Verify NVIDIA Spark SSH access` | Beginner Spark operations runbook, standalone-Hermes ownership, and the foundation/Qwen deployment path that the canonical index later verified as complete. | Later backup, restore, failover, automation, retrieval, and evaluation sequences. |
| `Verify NVIDIA Spark SSH access (2)` | Workstation ODS/Ollama boundaries, both Gemma 4 models, Qwen 3.8 installation and remote routing, plus the supporting tutorials and research notes. | Qwen 3.8 promotion comparison and restart-by-restart resilience checks. |
| `Plan Spark LM Link routing` | Tailnet-only workstation Ollama route, Spark LM Studio/LM Link, named Hermes providers, dynamic discovery, Qwen/Omni memory optimization, and Omni 131K long-context verification. | Shared regression harness and future runtime/model A/B work. |
| `Create setup task checklist` | The source-mapped runbook and the laptop thin-client policy; the 2026-08-22 audit expanded its original 29-note map to the 36 other notes that existed then, and the source map below now includes the 2026-09-18 frontier-model set. | Operational boxes were not completed merely by creating the runbook. |
| `Install VoiceStudio portable` | VoiceStudio v0.5.0 at `D:\Apps\VoiceStudio`, portable data, CUDA diagnostics, TTS, Whisper transcription, Parakeet dictation, and blank-Capture-window recovery. | Optional unused-model cleanup and longer real-microphone/daily-use acceptance. |
| `Document DGX Spark restart state` | First-Spark physical power-cycle recovery, saved recovery snapshot, corrected Qwen-before-Lightning boot order, second Spark NVIDIA Sync access, initial thermal/no-throttling comparison, persistent QSFP networking, full NCCL validation, the complete dual-Spark Frontier tutorial set, and verified hot swapping. | A second controlled reboot of the corrected Qwen-before-Lightning order and UEFI Auto Boot remain separate Sequence 1 work. |
| `Connect Obsidian vaults to DGX Spark` | Official headless Sync replicas for `LLMWiki` and `Personal-Sync`, two enabled continuous user services, verified two-way file/hash propagation, and the active Windows `Personal-Sync` vault moved to `F:\Vaults\Personal-Sync`. | Retrieval evaluation, hard Hermes write confinement, a simultaneous-edit conflict test, and an independent `Personal-Sync` backup. |

## Current operational finish line

The immediate goal remains the **operational setup**, not every future model, framework, and portfolio lab.

### Must finish for the operational baseline

- [x] Sequence 0 — Reconfirm the baseline and ownership map.
- [ ] Sequence 1 — Backups, restart recovery, and failover are proven.
- [x] Sequence 2 — Laptop fallback is deliberately declined; the laptop uses the authoritative Spark Remote Gateway.
- [ ] Sequence 3A — Skill/plugin safety and intake controls are in place.
- [ ] Sequence 4 — One real coding workflow works through stable local aliases.
- [ ] Sequence 5 — One safe automation works and its failure path alerts correctly.
- [ ] Sequence 6 — Both Spark Obsidian replicas are live and bidirectional; remaining storage safeguards, hard write confinement, and retrieval evaluation must still pass.

### Stretch only after the operational baseline

- [ ] Sequence 3B — Complete one development-methodology bakeoff.
- [ ] Sequence 6B — Let scheduled agents write Markdown and collect simple like/dislike feedback through an HTML dashboard that updates those files.
- [ ] Sequence 7 — Establish the shared evaluation and observability harness.
- [ ] Sequence 8A — Test exactly one new workstation model; start with `qwen3-coder:30b` if coding is the immediate goal.
- [x] Sequence 8I — Qualify the exclusive dual-Spark frontier lane in the order Qwen NVFP4 → official FP8 → GLM → DeepSeek.

### Suggested remaining work blocks

| Work block | Scheduling | Sequence | Estimated hands-on time |
|---|---|---|---:|
| Block 1 | Primary | Remaining backups, restore test, corrected-order reboot, and failover | 1.5–3 h |
| Block 2 | Parallel | Skills/plugin intake repository and safety controls | 2–3 h |
| Block 3 | Parallel | Shared regression set plus one real coding workflow | 2–4 h |
| Block 4 | After Block 1 | First cron/n8n workflow and failure test | 2–3 h |
| Block 5 | After Personal-Sync backup | Finish Obsidian safeguards plus retrieval evaluation | 3–4 h plus indexing time |
| Block 6 | After agent output-folder restriction | Scheduled Markdown output plus a private HTML dashboard with like/dislike write-back | 3–6 h |
| Block 7 | After regression set | One optional model A/B or remaining cleanup | 1.5–3 h plus download time |

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
- [x] The second Spark is reachable as `SecondSpark` in NVIDIA Sync, passed the initial idle thermal/no-throttling comparison, and is now connected through the approved QSFP112 DAC with persistent manual Netplan and a passing full NCCL test. See [[DGX Spark Dual-Node Configuration And Operations Reference]].
- [x] `LLMWiki` and the local `Sync Remote` vault connected to remote `Personal-Sync` now have separate official headless replicas on `FirstSpark`; both continuous user services are enabled and active, and desktop-to-Spark plus Spark-to-desktop hash checks passed.
- [x] VoiceStudio v0.5.0 is installed portably at `D:\Apps\VoiceStudio`; CUDA diagnostics, generation, Whisper transcription, Parakeet dictation, and the blank `Capture` overlay recovery passed. See [[VoiceStudio Windows Portable Usage]] and [[VoiceStudio Risk Audit]].
- [x] The dual-DGX-Spark Frontier runbook, sparkDash, Qwen NVFP4/FP8, GLM, DeepSeek, and the fail-closed `spark-frontier` hot-swap routine are complete as of 2026-09-24. All four permanent aliases passed their tutorial and routed-switch gates, and `spark-fast` remains the verified rollback. See [[DGX Spark Dual-Node Community Frontier Models Runbook]], [[DGX Spark Frontier Model Qualification Results]], and [[DGX Spark Frontier Model Hot-Swap And Routing Guide]].
- [x] `aux-services stop|start|list|status|add|remove|edit` is installed on FirstSpark as the state-aware service/port catalog. Managed dashboards and sync services participate in bulk drain/restore; Hermes Gateway, Hermes Serve, LiteLLM, and the reasoning shim are protected named-control entries; Tailscale Serve, SSH, and the Frontier API are locked inventory entries. Hermes schedules remain Hermes-owned and excluded. See [[DGX Spark Additional Services Controller]].

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
**Time:** Replica rollout complete; allow 3–4 hours plus indexing for the remaining safeguards and retrieval evaluation
**Goal:** Hermes can safely read the two Spark vault replicas, any writes are narrowly confined, and retrieval quality is measured before broad trust.

### Read first, in order

1. [[personal-hermes-obsidian-multinode-design#Obsidian on the Spark]]
2. [[personal-hermes-obsidian-multinode-design#Safe agent-writing pattern]]
3. [[Always-On Hermes on DGX Spark#Obsidian on Spark]]
4. [[Spark Hermes Setup Runbook#Phase 5 — Obsidian + retrieval (2–3 h, plus an eval)]]
5. [[DGX Spark ODS Playbook and Model Roadmap#Models to install now]]
6. [[dgx-spark-current-models-report#Install and experiment matrix]]

### Replica checklist

- [x] Confirm the local `LLMWiki` vault is independently Git-backed before adding the Spark replica.
- [ ] Create and restore-test an independent dated backup for `Personal-Sync`; Google Drive mirroring the active vault folder does not count as an independent backup.
- [x] Install Node.js 22+ and official `obsidian-headless` on `FirstSpark`.
- [x] Create separate Spark replica directories at `/home/snknitin/vaults/LLMWiki` and `/home/snknitin/vaults/Personal-Sync`, outside `HERMES_HOME` and every other sync tool.
- [x] Complete protected initial pulls, then run each replica continuously under its own enabled user service.
- [x] Confirm no Git, Google Drive, Syncthing, Dropbox, or second headless client also syncs either **Spark** replica directory.
- [x] Move the active Windows `Personal-Sync` vault out of Google Drive to `F:\Vaults\Personal-Sync`; Obsidian currently registers the new path as open and the former Drive path as not open.
- [ ] After the new local vault reports fully synced, archive the former Google Drive copy as a dated backup or remove it from live Google Drive management; do not reopen both copies against the same remote vault.
- [ ] Give Hermes a dedicated OS identity or equivalent hard sandbox and prove it cannot write outside `Agent Inbox/Spark Hermes/`; the current shared `snknitin` identity is not a hard boundary.

### Verified replica evidence — 22 August 2026

- [x] `obsidian-sync-llmwiki.service` and `obsidian-sync-personal.service` are enabled and active with zero observed restarts.
- [x] The Spark replicas contain 2,069 files/416 MB for `LLMWiki` and 2,647 files/2.6 GB for `Personal-Sync` at verification time.
- [x] A desktop-created test note reached each Spark replica with the same SHA-256 hash.
- [x] A Spark-created inbox test note reached each desktop vault with the same SHA-256 hash.
- [x] Hermes Gateway, Hermes Serve, and the existing model services remained active during the sync rollout.

### Retrieval checklist

- [ ] Deploy `Qwen/Qwen3-Embedding-0.6B` and `Qwen/Qwen3-Reranker-0.6B` through the chosen TEI/separate-reranker path, or explicitly document a different one-owner design.
- [ ] Build a fixed evaluation set of about 20 real questions covering easy lookup, cross-note synthesis, dates, code/config facts, ambiguous terms, and “not in vault” negatives.
- [ ] Index a representative subset before indexing the entire vault.
- [ ] Measure retrieval recall, reranker benefit, citation correctness, latency, and failure cases.
- [ ] Spot-check at least five wrong or low-confidence retrievals and record why they failed.
- [ ] Increase embedding size from 0.6B only if the measured recall gain justifies extra memory.
- [ ] Index the full vault only after the evaluation threshold is accepted.

### Optional write path — do only after read-only success

- [x] Change only the two Spark replicas to bidirectional mode after their protected initial pulls.
- [x] Verify sequential desktop-to-Spark and Spark-to-desktop writes with matching SHA-256 hashes in both vaults.
- [ ] Restrict Hermes writes to `Agent Inbox/Spark Hermes/` with unique timestamp/task filenames using an enforceable filesystem/service boundary, not only a prompt convention.
- [ ] Test simultaneous desktop edit plus agent inbox write; confirm no shared canonical note is overwritten.
- [ ] Keep consolidation into canonical notes as a human or single serialized job.

### Completion gate

- [ ] **Done:** both continuous replicas survive restart, the `Personal-Sync` dual-sync risk is removed, Hermes reads them, the 20-question retrieval evaluation is recorded, and any write access is hard-confined to the inbox.

---

## Sequence 6B — Scheduled Markdown outputs and a two-way feedback dashboard

**Priority:** P1 after the Sequence 6 write-safety gates
**Time:** 3–6 hours for the narrow feedback MVP
**Goal:** Scheduled agents create ordinary Markdown files that sync into Obsidian, render as clean HTML, and receive simple user feedback that is written back into the same Markdown records.

### Read first

1. [[Markdown Backed Interactive Dashboard Research]]
2. [[personal-hermes-obsidian-multinode-design#Safe agent-writing pattern]]
3. [[Always-On Hermes on DGX Spark#Obsidian on Spark]]

### Minimal requested MVP

- [ ] Use `LLMWiki/Agent Inbox/Scheduled Jobs/` as the only MVP output root.
- [ ] Give each scheduled job its own subfolder and unique timestamped filename; create a new file per run rather than overwriting yesterday's output.
- [ ] Require each output note to contain an immutable `dashboard_id` plus `feedback: none`; allow only `none`, `like`, or `dislike`, with an optional short `feedback_note`.
- [ ] Build one dashboard service that watches this folder, converts Markdown to sanitized HTML, lists newest outputs first, and displays 👍/👎 controls.
- [ ] On a feedback click, update only `feedback`, `feedback_note`, and `feedback_updated_at` in that exact Markdown file; do not rewrite the agent's report body.
- [ ] Watch for Markdown changes delivered from desktop Obsidian and refresh the open HTML page so feedback remains two-way.
- [ ] Keep the dashboard otherwise stateless: no database, CMS, Git pull/merge automation, general-purpose editor, or second sync engine.
- [ ] Bind the viewer to Spark loopback and expose it only through authenticated Tailscale Serve, never Funnel or the public internet.
- [ ] Add one scheduled Hermes job, run it manually once, and verify its Markdown reaches the Spark folder, HTML view, and desktop Obsidian; then click feedback and verify the updated field returns to Obsidian.
- [ ] Add the remaining daily jobs only after the first job survives a Spark restart and a failed model call produces a visible error note/alert.

### Minimal MVP completion gate

- [ ] **Done:** an agent creates a timestamped Markdown report on schedule, the private HTML dashboard shows it, 👍/👎 updates only the allowed Markdown feedback fields, and both report and feedback appear in desktop Obsidian through Sync.

### Optional general editing — not required for the feedback MVP

- [ ] If editing from the browser becomes important later, first try Obsidian Bases and optionally Meta Bind for frontmatter-backed controls.
- [ ] Build a browser write API only if editing outside Obsidian remains a real requirement; then apply the schema, conflict, atomic-write, and acceptance gates below.

### Markdown data contract

- [ ] Reserve one managed subtree, initially `Dashboard/`, rather than exposing the whole vault to the dashboard writer.
- [ ] Use `Dashboard/Daily Notes/YYYY-MM-DD.md` for the daily journal and one file under `Dashboard/Items/YYYY/MM/` for every independently editable row/card.
- [ ] Define a small flat frontmatter schema: immutable `dashboard_id`, `dashboard_type`, `title`, `status`, optional `due`, `priority`, `source`, `created_at`, `updated_at`, and `tags`.
- [ ] Map a displayed completion checkbox to `status: done`; do not persist a second Boolean that can disagree with status, and keep the content revision as an HTTP hash rather than editable frontmatter.
- [ ] Keep free-form prose human-owned; let the dashboard update only validated properties and one explicitly delimited managed block.
- [ ] Preserve valid Obsidian YAML, wikilinks, line endings, UTF-8, and unknown frontmatter keys during every round trip.

### Browser write-back service — only if Bases is insufficient

- [ ] Run one small supervised service under a dedicated unprivileged account on `FirstSpark`; static HTML reads Markdown, while this service alone owns browser-originated writes.
- [ ] Bind it to loopback and publish it only through authenticated tailnet access; never expose the vault writer to the public internet.
- [ ] Parse and validate Markdown server-side, allowlist the managed subtree and fields, resolve real paths, and reject traversal, symlinks outside the subtree, oversized input, scripts, and unknown fields.
- [ ] Watch the managed subtree and push refresh events to the browser with Server-Sent Events or WebSockets so Obsidian/Spark edits appear without manual reload.
- [ ] Serialize writes per file, write to a staging directory outside the vault but on the same filesystem, flush it, and rename it into place so a crash cannot leave a half-written or sync-visible temporary note.
- [ ] Return a content hash/strong `ETag` on reads and require `If-Match` on writes; reject a stale browser update with HTTP `412` instead of overwriting a newer Obsidian or Sync edit.
- [ ] Debounce duplicate filesystem events, rescan after watcher errors/restarts, and do not assume a file-watcher event is complete or unique.
- [ ] Record an append-only audit entry outside the vault for each dashboard write without storing API keys, prompts, or private credentials there.

### Weekly Claude/Hermes review

- [ ] Give one supervised weekly timer sole ownership; do not create overlapping Hermes, cron, and n8n schedules for the same review.
- [ ] Read the previous seven daily notes plus referenced items, capture their source paths/hashes, and send only the intended fields to the selected Claude API or local Hermes route.
- [ ] Pin and record the prompt version, model/alias, input range, run ID, and failure status; keep any cloud API key outside Git and Obsidian.
- [ ] Write a new draft at `Dashboard/Weekly Reviews/YYYY-[W]WW - Weekly Review Draft.md`; never let the model overwrite daily source notes or silently mark tasks complete.
- [ ] Require human review before a weekly draft changes canonical projects, schedules, or long-lived knowledge.

### Acceptance tests

- [ ] Toggle a dashboard checkbox and confirm the expected Markdown property changes, syncs to desktop, and renders correctly in Obsidian.
- [ ] Edit the same property in desktop Obsidian and confirm the open dashboard refreshes to the new value without a server restart.
- [ ] Type text containing quotes, colons, Unicode, wikilinks, and multiple lines; confirm a lossless round trip or an explicit validation error.
- [ ] Attempt two writes from the same old version and prove the second receives a visible conflict instead of silent last-write-wins.
- [ ] Test Obsidian Sync delay, Spark restart, browser reconnect, watcher restart, network loss, invalid YAML, path traversal, and a failed weekly model call.
- [ ] Restore one changed dashboard note from Git/backup or Sync history and record the recovery time.

### Completion gate

- [ ] **Done:** the chosen UI edits only the managed Markdown contract, changes flow both ways within the accepted latency, stale writes cannot silently win, the weekly job produces a reviewable draft with provenance, and rollback is demonstrated.

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

### 8I — Dual-Spark community frontier lane, in order

> [!success] Completed 2026-09-24
> The full runbook, tutorial sequence, routed service checks, hot swaps, cold-route rejection, rank cleanup, and `spark-fast` restoration passed. The checked items below remain the execution record.

**Rule:** Qwen 3.8 Flash Next, GLM 5.3 Flash, and DeepSeek V4.1 are mutually exclusive hot-swap appliances. Every recipe claims one GB10 rank on each Spark, so none runs beside `spark-fast`, Spark LM Studio, or another frontier recipe. Downloaded weights may remain on disk; only one model lane may be resident.

**Read, in order:**

1. [[DGX Spark Dual-Node Community Frontier Models Runbook]] — common prerequisites, pinned sources, port/authentication, hot swap, acceptance, and rollback.
2. [[DGX Spark sparkDash Monitoring Tutorial]] — observer installation and security boundary.
3. [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] — NVFP4 baseline and official FP8 A/B.
4. [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] — experimental second recipe.
5. [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] — final high-risk recipe.
6. [[DGX Spark Frontier Model Qualification Results]] — measured local comparison, run timestamps, and missing gates.
7. [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] — permanent named aliases and the fail-closed cluster switch workflow.
8. [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]] — provenance, memory evidence, licenses, issue audit, and Aiden boundary.
9. [[DGX Spark Dual-Node Configuration And Operations Reference]] — authoritative hosts, addresses, interfaces, HCAs, and recovery.

#### Capacity and coexistence decision

| Lane | Published or observed per-node pressure | Checklist decision |
|---|---|---|
| Current `spark-fast` | About 40.2 GiB model allocation; roughly 50 GiB end-to-end after the 10 GiB KV/two-sequence profile | May leave SecondSpark free for a separately designed single-node lane, but must stop before any two-node recipe. |
| Optional Qwen 3.8 NVFP4 TP1 on SecondSpark | 71.75 GiB GPU weights, about 5.6 GiB non-weight overhead, a configurable 7–15 GiB KV cache, and a 26.82 GiB memory-mapped PLE in the community measurements | May coexist with `spark-fast` as an explicitly separate SecondSpark-only lane after its own load test. Stop it before starting any dual-node recipe. See the optional TP1 section in [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]. |
| Qwen NVFP4 | 101.61 GiB vLLM budget, 32.02 GiB KV, and only about 2.33–2.38 GiB published host-memory low-water | Exclusive; qualify with all nonessential services stopped. |
| Qwen official FP8 | Same two-node 0.835 budget, larger weights, and roughly 500K cache tokens; no complete published memory breakdown | Exclusive; measure independently rather than inheriting NVFP4 assumptions. |
| GLM EXL3 | About 103.44 GiB vLLM budget at GMU 0.85; published host headroom is narrow and long prefill is critical | Exclusive; experimental soak required. |
| DeepSeek EXL3 | About 99.5 GiB weights plus KV/runtime/OS; published low-water reaches about 2.1 GiB after a 601K prefill | Strictly exclusive; run last. |
| sparkDash | No intentional model/GPU allocation; actual host-RAM use is unpublished | Stop for each first boot and stress test, then re-add for a measured A/B. |

#### Readiness gate

- [x] Add SecondSpark to NVIDIA Sync with a unique alias; FirstSpark remains the sole production Hermes/LiteLLM/state owner.
- [x] Install the approved QSFP112 DAC, preserve manual `/etc/netplan/40-cx7.yaml`, verify both 200,000 Mb/s rails, and pass the official full two-node NCCL direct test at `21.7568 GB/s` average bus bandwidth with zero out-of-bounds values.
- [x] Add `snknitin` to SecondSpark's `docker` group, reconnect/reboot, and prove `docker ps` succeeds there without `sudo`.
- [x] Repair SecondSpark → FirstSpark management-IP ED25519 host-key trust by comparing fingerprints; never use a global `StrictHostKeyChecking=no` workaround.
- [x] Upgrade FirstSpark's NVIDIA Container Toolkit from `1.19.1` so both nodes report `1.20.0`, then re-prove Docker and GPU access.
- [x] Reconfirm `enp1s0f1np1`, `rocep1s0f1`, GID index `3`, `192.168.100.10/11`, bidirectional SSH, and remote Docker immediately before launch.
- [x] Confirm challenger port `8100` is free. Do not reuse upstream port `8888`, which is already owned by SearXNG.
- [x] Confirm enough disk for the selected weights on both nodes and record the repository commit, image digest, checkpoint/revision, and licenses.

#### Phase A — Install sparkDash as an observer

- [x] Follow [[DGX Spark sparkDash Monitoring Tutorial]] at the reviewed commit and bind only to `127.0.0.1:5555`.
- [x] Reach it from Windows through the SSH tunnel; do not expose it to the LAN.
- [x] Add both Sparks and verify monitoring, but leave shutdown, Hermes-update, and model-lifecycle controls unused.
- [x] Record `docker stats` and `MemAvailable`, then stop sparkDash before the first model start and each near-limit test.

#### Phase B — Establish the idle baseline

- [x] Stop `spark-fast`, Spark LM Studio, the full ODS stack, Hermes, sparkDash, and every other material GPU/host-memory consumer before first qualification.
- [x] Confirm no frontier container or worker rank remains on either node.
- [x] Record `nvidia-smi`, `free -h`, `MemAvailable`, disk, and Docker state on both nodes.
- [x] Keep the production rollback ready: the active repository's stop command followed by `spark-model use qwen35`.

#### Phase C — Qwen NVFP4, then official FP8

- [x] Follow [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] at commit `d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22`; change only cluster, port, SSH, and authentication values for the recipe-faithful NVFP4 baseline.
- [x] Verify both weight copies, start both ranks, and pass authenticated `/health`, `/v1/models`, deterministic chat, tools, vision, context ladder, concurrency, memory-low-water, clean stop, and `spark-fast` rollback.
- [x] Stage and test the repository's official FP8 path as a separate profile with its own memory and quality record.
- [x] Compare NVFP4 versus FP8 on identical prompts, context, throughput, stability, and post-warm-up headroom; choose a preferred default, while retaining a distinct route for every profile that independently passes.
- [x] Do not call either profile the “Aiden stack” until Aiden's exact public repository/image, tag and digest, launcher, patches, model revision, and settings exist.

#### Phase D — GLM after Qwen

- [x] Follow [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] at commit `ca8557665bffa6529758f2c330ba8fb44c1e801a` only after Qwen start/stop/rollback passes.
- [x] Run the pinned recipe-faithful baseline before any local tuning; record every deviation separately.
- [x] Pass identity, chat, tools, vision, staged context, concurrency, long-generation, memory, clean stop, and rollback checks.
- [x] Stop immediately on rank loss, CUDA/NCCL errors, host unresponsiveness, reset, corruption, or looping; treat current upstream failure reports as unresolved until this pair disproves them.

#### Phase E — DeepSeek last

- [x] Follow [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] at commit `8404ac7d389c418300d0bee960d52313247930e1` only after Qwen and GLM complete their required gates.
- [x] Verify the approximately 387 GiB source set, EXL3 split, Engram inputs, image digest, and selected NFS/replication path before GPU launch.
- [x] Preserve an untouched 600K pinned baseline. Prefer the separately named 131K/one-sequence/1 GiB-KV safety boot first, then restore and qualify 600K; keep cooperative-MoE and other optional overlays out of both.
- [x] After the 600K smoke, chat, tools, vision, and staged context pass, run the raw C1/C2 concurrency gate from DeepSeek Step 15a **before** starting LiteLLM/Hermes/sparkDash. Record C4 only as an optional four-client offered-load result with the two-sequence scheduler limit stated; a blank C column is not a measured zero.
- [x] Record matched head/worker memory low-water and kernel checks, then pass service-layering, soak, clean stop, and rollback before treating DeepSeek as an accepted hot-swap lane.
- [x] Reject the profile if either node approaches the documented few-GiB margin without repeatable recovery.

#### Named-alias registration and coexistence proof

- [x] Promote no recipe until its authenticated raw API on `192.168.0.101:8100` passes and its worker rank stops cleanly.
- [x] Follow [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] and register each accepted profile under its corresponding permanent alias: `qwen38-nvfp4`, `qwen38-fp8`, `glm53-flash`, or `deepseek41-flash`.
- [x] Start only LiteLLM and Hermes with the active validated profile, then repeat the same loaded-context test while recording both nodes' low-water.
- [x] Start sparkDash last and repeat the matched test. Keep it stopped if headroom or stability materially worsens.
- [x] Do not restore the rest of ODS beside an active frontier lane unless an additional matched test proves safe headroom. Coexistence is measured, not assumed.
- [x] Never rename or overwrite `spark-fast`; it remains the production rollback until repeated restart and regression evidence justifies a separate promotion decision.
- [x] Install the separate `spark-frontier` manager only after manual repository start, stop, cleanup, and rollback are stable; never run it concurrently with `spark-model`.
- [x] **Done:** one acceptance record per tried profile names the exact artifacts, deviations, memory low-water, tests, stop result, rollback result, and decision: promote, adapt-and-retest, or reject.

#### Deferred older candidates

These remain historical backlog and do not precede the community sequence above:

- [ ] Qwen 3.5 122B-A10B — consider only after the current Qwen 3.8 lane is decided.
- [ ] Poolside Laguna S 2.1 plus matching DFlash — test only after license, parser, and runtime review.
- [ ] Qwen3-Coder-Next — test an official/reputable GGUF or FP8 path only after the smaller coder benchmark justifies it.
- [ ] Step 3.7 Flash — run alone at conservative context through its required llama.cpp path.
- [ ] Ling 3.0 Flash — keep blocked until provenance, license, source, and digest are verified.

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

Use this map to decide what to read deeply and what to keep as reference. Updated on 2026-09-18, it covers the current Markdown notes in this folder without treating newly written instructions as completed execution.

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
- [[DGX Spark Dual-Node Configuration And Operations Reference]] — authoritative live identities, addresses, manual network ownership, NCCL proof, recovery steps, and distributed-model readiness gaps.
- [[DGX Spark Dual-Node Community Frontier Models Runbook]] — current command-first master procedure for the exclusive two-node challenger lane, acceptance, routing, and rollback.
- [[DGX Spark sparkDash Monitoring Tutorial]] — loopback-only two-node observer and benchmark guide.
- [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] — first frontier lane: NVFP4 baseline and official FP8 A/B.
- [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] — gated experimental second frontier lane.
- [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] — deferred final frontier lane with the tightest memory and staging constraints.
- [[DGX Spark Frontier Model Qualification Results]] — current eight-profile raw comparison and saved run timestamps.
- [[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]] — repeatable 131K and FirstSpark reference measurements.
- [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] — permanent LiteLLM/Hermes aliases and fail-closed switching across the validated frontier lanes.
- [[DGX Spark Second Node And Dual Spark Readiness Research 2026-08-20]] — historical pre-cable planning, approved cable choices, and dual-Spark model limits.
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

- [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]] — immutable repository/checkpoint audit, memory evidence, open issue and license review, and Aiden-stack reproducibility boundary.
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
- [[Markdown Backed Interactive Dashboard Research]] — primary-source feasibility study, option comparison, recommended Markdown data contract, safe live write-back design, and weekly Claude/Hermes workflow.

## Final completion definition

- [ ] The operational P0 sequences are complete with evidence.
- [ ] Backups and restore paths have been tested, not merely configured.
- [ ] Every production service, schedule, model route, database, and bot has one owner.
- [ ] The laptop, workstation, and Spark each have a documented role and failure behavior.
- [ ] New skills/plugins enter through the reviewed intake pipeline.
- [ ] Coding and one automation work through stable aliases.
- [ ] Both Spark vault replicas are safe, dashboard/agent writes are confined, and retrieval quality has been measured.
- [ ] Every new model is evaluated one at a time and either assigned a unique role or removed.
- [ ] Fine-tuning and FDE labs begin only after the operational foundation is stable.

## Related

- [[Local Setup Index]]
- [[DGX Spark Dual-Node Community Frontier Models Runbook]]
- [[Always-On Hermes on DGX Spark]]
- [[Spark Hermes Setup Runbook]]
- [[local-ai-tooling-catalog-and-rollout|Local AI Tooling Catalog and Rollout]]
- [[DGX Spark ODS Playbook and Model Roadmap]]
