---
updated: 2026-08-14
status: active
---

# Local Setup Index

> [!summary] Active architecture
> **DGX Spark** owns standalone Hermes Gateway, Hermes Serve, the authoritative Hermes state, LiteLLM, and the working Qwen services. **The RTX PRO 5000 Blackwell workstation** owns ODS Open WebUI, SearXNG, native Ollama, project models, evaluation, and fine-tuning. ODS does not own another Hermes installation.

This is the canonical progress and navigation page. If an older note suggests a different machine placement or execution order, follow this page.

## Current confirmed state

| Area | Confirmed state |
|---|---|
| Spark hardware | One DGX Spark with 128 GB unified memory |
| Workstation GPU | **NVIDIA RTX PRO 5000 Blackwell**, 48,935 MiB, compute capability 12.0, driver 596.59 |
| Spark foundation | Bash configuration, external secrets, cache/service folders, registries, and status commands completed |
| Spark inference | Qwen 3.6 35B-A3B and Qwen 3.6 27B DFlash profiles installed and tested; only one large model is loaded at a time |
| Hermes | Standalone Hermes Gateway and Hermes Serve run on Spark; the ODS Hermes module is not needed |
| Routing | Spark LiteLLM exposes the working Qwen routes to Hermes |
| Networking | Tailscale is installed on Spark, workstation, and laptop; NVIDIA Sync access exists |
| Workstation ODS | ODS is installed; Open WebUI and SearXNG are the intended retained modules |
| Ollama | Not yet installed/configured as the workstation model shelf |
| LM Studio | CLI exists on Spark; large-model/LM Link workflow is not yet completed |
| Additional models | Nemotron 3 Nano Omni is downloaded/prepared and its pinned audio-enabled image was built; it has not yet been started or tested. Gemma, Nemotron 3.5, and Muse remain untested. |

## Done — do not repeat these sections

### Spark foundation

- [x] [[DGX Spark Operations Setup Guide]] Steps 1–6: state capture, safe `.bashrc` cleanup, folder layout, external secrets, registries, and status helpers.
- [x] Hugging Face, NIM, service, source, cache, and run-output locations established.
- [x] Secrets kept outside `.bashrc`; blank values shown in notes were redactions, not missing real credentials.

### First Spark model and routing

- [x] [[DGX Spark Operations Setup Guide]] Steps 7–10: Qwen 3.6 35B-A3B NVFP4 prepared, served, tested, and added to LiteLLM as `spark-fast`.
- [x] The initial LiteLLM connection-error behavior was identified as a stopped/not-ready backend problem rather than a model identity problem.
- [x] `vllm-spark-fast` was confirmed healthy in the reported baseline.

### Standalone Hermes on Spark

- [x] [[DGX Spark Operations Setup Guide]] Steps 11–15 are operationally complete: current host-native Hermes, persistent Gateway, persistent Serve, authenticated Remote Gateway, and 24×7 service ownership on Spark.
- [x] Hermes Desktop successfully received an answer through the `spark-fast` custom provider.
- [x] The earlier SSH-key path was superseded by the authenticated Remote Gateway design.
- [x] ODS Hermes Auth Proxy was evaluated and deliberately excluded from ownership of the primary Hermes home.

### Second Qwen profile and switching

- [x] [[DGX Spark Model Installation And Switching Guide]] Steps 16–21: baseline checks, safe stop/start, Qwen 27B DFlash preparation, raw API test, LiteLLM route, Hermes test, and return to the known-good Qwen 35B profile.
- [x] Hermes has shown both `spark-fast` and `qwen27-dflash` in its model list.
- [x] The one-large-model rule and the difference between **downloaded**, **listed**, and **resident** are understood.

Use only these completed-guide sections now:

- [[DGX Spark Operations Setup Guide#Safe stop and rollback commands|Operations rollback commands]]
- [[DGX Spark Model Installation And Switching Guide#Step 23 — Daily model operations|Daily Qwen operations]]
- [[DGX Spark Model Installation And Switching Guide#Step 22 — Rules for every additional model|Rules for additional models]]

### Architecture and research completed

- [x] [[DGX Spark Multi-Model Runtime Research]] — explains why the 120 GB reading was runtime/KV allocation rather than checkpoint size.
- [x] [[DGX Spark Additional Models And Convenience Runtimes Research]] — verifies the current Gemma, Nemotron, Muse, Ollama, and LM Studio paths.
- [x] [[DGX Spark And RTX 5000 Workstation Model Placement Research]] — establishes the final Spark/workstation division and confirms why dense 27–31B models belong on the RTX workstation first.
- [x] RTX PRO 5000 Blackwell identity verified from `nvidia-smi`; the Ada/32 GB contingency no longer applies.

## Resume here — exact order from today

### 1. Finish the remaining remote-client checks

Read:

1. [[Always-On Hermes on DGX Spark#What is shared across devices]]
2. [[Always-On Hermes on DGX Spark#Daily phone interface]]
3. [[Always-On Hermes on DGX Spark#Rollout]]

Do:

- [x] Confirm the laptop Hermes Desktop connects to the same authenticated Spark Remote Gateway.
- [x] Confirm one chat started on the laptop appears in the shared Spark-backed Hermes state as expected.
- [x] Verify the Telegram bot only if Telegram is still part of the desired 24×7 interface.
- [x] Verify a normal chat and one tool call from each device before adding more runtimes.

**Done when:** desktop and laptop can both use the Spark Hermes backend without creating separate authoritative profiles. Telegram is either verified or deliberately deferred.

### 2. Make workstation Ollama the ODS model shelf

Follow this beginner runbook first:

1. [[RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial]] — complete Parts 1–4 for native Windows Ollama, the SSD model directories, and the ODS Open WebUI connection.

Use these research sections only when you want the reasoning behind the choices:

1. [[DGX Spark And RTX 5000 Workstation Model Placement Research#Ownership architecture]]
2. [[DGX Spark And RTX 5000 Workstation Model Placement Research#Ollama versus LM Studio on the workstation]]
3. [[DGX Spark And RTX 5000 Workstation Model Placement Research#Open WebUI and SearXNG without ODS/Hermes coupling]]

Then:

- [ ] Install current native Windows Ollama on the workstation.
- [ ] Set one explicit large SSD model directory before pulling large models.
- [ ] Connect workstation Open WebUI to local Ollama at `http://host.docker.internal:11434`.
- [ ] Add Spark LiteLLM to Open WebUI as a separate OpenAI-compatible connection with a visible `spark/` prefix.
- [ ] Keep SearXNG as the workstation ODS search service.
- [ ] Do not enable ODS Hermes.

> [!warning] Do not follow the Spark Ollama tutorial now
> [[DGX Spark Ollama And ODS Tutorial]] installs an Ollama sidecar on Spark. It remains a reference/rollback alternative, but it is **not the active plan** now that the 48 GB Blackwell workstation has been confirmed. The active plan is native workstation Ollama.

**Done when:** workstation Open WebUI lists both `local/` Ollama models and `spark/` LiteLLM models without duplicating Hermes.

### 3. Add workstation models one at a time

Continue in [[RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial]]:

- Parts 5–7 install, test, compare, and unload the two Gemmas one at a time.
- The tutorial names the exact current Ollama tags and tells you whether each action happens in workstation PowerShell or Open WebUI.

Use [[DGX Spark And RTX 5000 Workstation Model Placement Research#The practical workstation shortlist]] as the broader model-placement reference.

Install and test in this order:

1. **Gemma 4 31B** — first local dense quality/coding/multilingual verifier.
2. **Gemma 4 26B-A4B** — faster creative-writing, translation, summarization, and vision worker.
3. **Nemotron 3.5 Lightning** — optional coding/reasoning/tool challenger after its current Ollama tag and tool behavior are verified.
4. **One 7–14B training model** — only when beginning the fine-tuning workflow.

For every model:

- [ ] Pull one exact tag.
- [ ] Record the tag, size, context, and runtime version.
- [ ] Test it directly through Ollama.
- [ ] Test it through workstation Open WebUI.
- [ ] Compare it with the same prompts against `spark-fast`.
- [ ] Unload it before loading another large workstation model.

Do **not** download workstation copies of the two Qwen models already working on Spark unless a controlled latency benchmark later justifies the duplicate.

### 4. Configure LM Studio and LM Link only as the lab layer

Continue with Parts 8–17 in:

1. [[RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial]]

For architecture background, read [[DGX Spark And RTX 5000 Workstation Model Placement Research#LM Studio: lab and remote-human-access layer]].

Use LM Studio for:

- [ ] temporary GGUF comparisons;
- [ ] memory estimates before loading;
- [ ] Muse and other very new llama.cpp-compatible models;
- [ ] LM Link access from the laptop;
- [ ] project-specific presets that do not belong in permanent Ollama service.

Do not download the same 20–30 GB model into both Ollama and LM Studio by default. Ollama is the ODS service of record; LM Studio is the experiment bench.

> [!note] Older Spark-specific LM Studio tutorial
> [[DGX Spark LM Studio And LM Link Tutorial]] remains a reference for the already-installed Spark CLI. It is not the active Step 4 tutorial. Use the combined RTX PRO 5000 workstation tutorial above for this rollout.

### 5. Add the first genuinely specialized Spark model

Follow:

1. [[DGX Spark Nemotron 3 Nano Omni Tutorial]]

This is the best next Spark addition because it adds image, audio, video, OCR, and document capability rather than duplicating a workstation-sized text model.

- [x] Download the checkpoint and build the pinned audio-enabled local image.
- [x] Stop the resident Qwen before loading Omni.
- [x] Test raw text first, then image, audio, and short video separately.
- [x] Add its LiteLLM alias only after the raw service passes.
- [x] Restore `spark-fast` after the comparison unless Omni earns a scheduled specialist role.

> [!success] Current resume point
> Your output proves that preparation completed: Docker exported and named `local/vllm-nemotron3-omni:v0.20.0`, the exact model revision was recorded, and the script printed `Prepared: nemotron3-omni`. The BuildKit `InvalidDefaultArgInFrom` line was a warning, not a failed build. Do **not** repeat the download. Resume at **Step 4 — Stop the currently loaded large model** in [[DGX Spark Nemotron 3 Nano Omni Tutorial]].

### 6. Treat the remaining Spark model tutorials as optional comparisons

Use this order only after workstation Ollama and Spark Omni work:

1. [[DGX Spark Nemotron 3.5 Lightning Tutorial]] — official Spark vLLM/DSpark reference against the workstation version.
2. [[DGX Spark Gemma 4 Models Tutorial]] — Spark-specific benchmark only; the workstation is now the preferred first home for both Gemmas.
3. [[DGX Spark Muse Glimmer 30B Readiness Tutorial]] — advanced/pre-release gate; base model before DFlash.

[[DGX Spark Additional Model Tutorials Index]] remains a catalog of the tutorial files, but the execution order on this page supersedes its older all-on-Spark testing order.

### 7. Begin fine-tuning only after workstation inference is stable

Read:

1. [[DGX Spark And RTX 5000 Workstation Model Placement Research#Realistic fine-tuning scope on 48 GB]]
2. [[DGX Spark ODS Playbook and Model Roadmap#Phase 2 - Fine-tuning and SLM engineering]]

Proceed in this order:

1. One 7–14B base/instruction model with LoRA or QLoRA.
2. One fixed dataset with train/validation/test separation.
3. Base-versus-adapter evaluation.
4. Export a separate serving artifact.
5. Quantize only the accepted result.
6. Register it under a new LiteLLM alias without overwriting the base model.

Before training, unload workstation Ollama and LM Studio models. Normal Hermes work should continue through `spark-fast` while the workstation GPU is leased to training.

### 8. Hold Qwen 3.8 behind a release gate

- [ ] Confirm the exact official checkpoint and license.
- [ ] Wait for stable, reputable quantization and runtime support.
- [ ] Test a workstation-sized quant on the RTX PRO 5000 first when appropriate.
- [ ] Keep Spark as the capacity/reference path.
- [ ] Do not replace `spark-fast` until identical chat, coding, vision, reasoning, and tool evaluations pass.

## File map — what each note is for

### Active execution notes

- [[DGX Spark Operations Setup Guide]] — completed foundation; use only for service verification and rollback.
- [[DGX Spark Model Installation And Switching Guide]] — completed Qwen installation; use for daily switching rules.
- [[DGX Spark And RTX 5000 Workstation Model Placement Research]] — current machine ownership, workstation Ollama, model placement, and fine-tuning decisions.
- [[RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial]] — active beginner runbook for incomplete Steps 2–4: native Windows Ollama, Open WebUI, the two workstation Gemmas, LM Studio, and LM Link.
- [[DGX Spark Nemotron 3 Nano Omni Tutorial]] — next specialist Spark installation.
- [[DGX Spark LM Studio And LM Link Tutorial]] — older Spark-CLI reference; not the active workstation rollout.

### Optional model tutorials

- [[DGX Spark Gemma 4 Models Tutorial]]
- [[DGX Spark Nemotron 3.5 Lightning Tutorial]]
- [[DGX Spark Muse Glimmer 30B Readiness Tutorial]]
- [[DGX Spark Additional Model Tutorials Index]]

### Architecture and operating policy

- [[Always-On Hermes on DGX Spark]] — canonical Hermes ownership, remote clients, messaging, routing, and rollout.
- [[personal-hermes-obsidian-multinode-design|Personal Hermes, Obsidian, and Multi-Node Inference Design]] — detailed cross-machine state and routing boundaries.
- [[local-ai-tooling-catalog-and-rollout|Local AI Tooling Catalog and Rollout]] — tools, services, security boundaries, and longer rollout.
- [[DGX Spark ODS Playbook and Model Roadmap]] — learning and engineering roadmap after the operational stack is stable.
- [[Spark Hermes Setup Runbook]] — historical ordered rollout; Phases 0–2 are substantially complete, while later automation/retrieval/exploration phases remain a backlog.

### Supporting research — read when making a decision, not as sequential tutorials

- [[DGX Spark Multi-Model Runtime Research]]
- [[DGX Spark Additional Models And Convenience Runtimes Research]]
- [[DGX Spark Aug 2026 Model Deployment Research]]
- [[dgx-spark-current-models-report|DGX Spark Current Models Report]]
- [[dgx-spark-playbook-roadmap-draft|DGX Spark Playbook Roadmap Draft]]
- [[dgx-spark-twitter-bookmarks-analysis|DGX Spark Twitter Bookmarks Analysis]]
- [[local-ai-architecture-research|Local AI Architecture Research]]

## Canonical decisions

1. Standalone Hermes on Spark is authoritative; ODS Hermes stays disabled.
2. Spark LiteLLM is the only canonical router and the main point of ODS coupling.
3. Workstation ODS owns Open WebUI and SearXNG; native workstation Ollama owns the simple local model shelf.
4. The RTX PRO 5000 Blackwell is the preferred home for dense 27–31B inference, evaluation, project work, and LoRA/QLoRA.
5. Spark owns the working Qwens, persistent agents, specialist/full multimodal services, long contexts, and models that exceed 48 GB.
6. Stable aliases hide checkpoint names and ports from Hermes and clients.
7. Several models may remain downloaded, but keep only one large model resident per GPU/runtime lane.
8. Ollama, LM Studio, and Hugging Face/vLLM use separate native stores; do not duplicate every model across all three.
9. Workstation inference drains before training; Spark remains the fallback during the GPU lease.
10. New Qwen releases enter through a separate test profile and evaluation gate, never by overwriting `spark-fast` on release day.
