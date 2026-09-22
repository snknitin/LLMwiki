---
updated: 2026-09-22
status: active
---

# Local Setup Index

> [!summary] Active architecture
> **DGX Spark** owns standalone Hermes Gateway, Hermes Serve, the authoritative Hermes state, LiteLLM, and the working Qwen services. **The RTX PRO 5000 Blackwell workstation** owns ODS Open WebUI, SearXNG, native Ollama, project models, evaluation, and fine-tuning. ODS does not own another Hermes installation.

This is the canonical progress and navigation page. If an older note suggests a different machine placement or execution order, follow this page.

## Current confirmed state

| Area | Confirmed state |
|---|---|
| Spark hardware | Two DGX Sparks with 128 GB unified memory each. `FirstSpark` owns the production stack and `SecondSpark` is the worker/experiment node. One approved QSFP112 DAC is installed; persistent manual CX-7 Netplan, two 200,000 Mb/s rails, bidirectional private-network ping, and the official full NCCL direct test are verified. `Avg bus bandwidth` was 21.7568 GB/s with zero out-of-bounds values. A real distributed-model workload remains pending. See [[DGX Spark Dual-Node Configuration And Operations Reference]]. |
| Workstation GPU | **NVIDIA RTX PRO 5000 Blackwell**, 48,935 MiB, compute capability 12.0, driver 596.59 |
| Spark foundation | Bash configuration, external secrets, cache/service folders, registries, and status commands completed |
| Spark inference | Four explicit switchable lanes are installed and lifecycle-tested: `qwen35`, `qwen27-dflash`, `nemotron3-omni`, and `nemotron35-lightning`. `qwen35` remains the resident default, and LM Studio Nemotron 3.5 Lightning is deliberately warm beside it. |
| Dual-Spark frontier lane | Eight saved raw comparison runs now cover FirstSpark-only `spark-fast`, Qwen NVFP4/FP8, GLM DFlash/MTP/500K, and DeepSeek 131K/600K. All eight have passing chat, tool, vision, context, and C1/C2/C4 receipts; Qwen NVFP4 also has a passing C8 receipt. DeepSeek 131K is an adapted one-sequence profile, so its C2/C4 clients queue. Service coexistence, routed requests, soak, and restart/rollback gates remain separate as of 2026-09-22. No frontier lane is accepted for permanent LiteLLM/Hermes hot swapping merely from raw receipts. The frontier models are **exclusive two-node lanes**, not additional resident models. See [[DGX Spark Frontier Model Qualification Results]], [[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]], and [[DGX Spark Dual-Node Community Frontier Models Runbook]]. |
| Hermes | Standalone Hermes Gateway and Hermes Serve run on Spark; the ODS Hermes module is not needed |
| Routing | FirstSpark ODS was retired on 2026-09-22. Standalone LiteLLM uses the previously deployed v1.81.3 image digest, `$HOME/ai/services/litellm`, `spark-model-net`, and loopback port `4000`. The existing `spark-fast`, `qwen27-dflash`, and `nemotron3-omni` aliases and Hermes master key were preserved; the unused ODS `llama-server` default/wildcard aliases were removed. A real `spark-fast` request through LiteLLM and a Hermes one-shot request passed. The former ODS install and data are in a restricted rollback archive under `$HOME/backups/ods-to-standalone-litellm/20260922-142725/`; workstation ODS is separate. |
| Networking | Tailscale remains installed on the first Spark, workstation, and laptop. NVIDIA Sync reaches both nodes. FirstSpark (`192.168.0.101`) and SecondSpark (`192.168.0.100`) are direct ConnectX-7 peers on `192.168.100.10/11` and `192.168.101.10/11`. Manual `/etc/netplan/40-cx7.yaml` is authoritative; NVIDIA Sync Cluster Assistant has not created `99-nvidia-sync-cluster.yaml`. |
| Workstation ODS | ODS is installed; Dashboard is at `localhost:3001` and Open WebUI is at `localhost:3000`. The supported image update completed on 2026-08-15; ODS still reports 2.5.3 and pins Open WebUI 0.7.2. DeepSeek 70B was stopped and removed; the optional ODS llama-server is stopped and reserved at host port `11436`. |
| Ollama | Native Ollama 0.32.13 uses port `11434`, stores models at `D:\LocalLLama\models\ollama`, and is configured for 128K context and one resident model. **Expose Ollama to the network** is off again and Ollama itself listens only on `127.0.0.1`; Tailscale Serve owns tailnet-only HTTPS `8443`, and the Spark provider supplies Ollama's required loopback `Host` header. Both Gemma 4 models passed local and Spark-remote Hermes tool calls at a reported runtime context of `131072`; selecting 31B after 26B proved automatic one-model eviction. Both were unloaded afterward. |
| LM Studio | LM Studio Desktop and LM Link are connected to Spark device `spark-07a8`. Spark LM Studio is loopback-only on `127.0.0.1:1234`; the 24.52 GB `nvidia/nemotron-3.5-lightning` Q4_K_M model is loaded persistently at 65,536 context beside Qwen. LM Studio reports a 22.83 GiB allocation, while `nvidia-smi` shows about 24.1 GiB for `llama-server`; raw API, structured tool-call, Spark Hermes, Windows LM Link, Windows local-Hermes, and live co-residency tests passed. |
| Additional models | Qwen 27 is optimized to a 44 GiB FP8 KV pool with native MTP-3, using about 71.3 GiB instead of 103.2 GiB and holding 4.74 full 262K contexts. Nemotron 3 Nano Omni is optimized to a 12 GiB KV pool and a verified 131,072-token ceiling, using about 43 GiB instead of 90.6 GiB; text, tools, a 70,025-token prompt, image, audio-path, and video tests passed. Nemotron 3.5 Lightning is verified through Spark LM Studio. Muse remains untested. |
| Recovery | A pre-migration `FirstSpark` physical power cycle recovered the former ODS stack and the other services. Standalone LiteLLM has `restart: unless-stopped` and passed live health and request checks, but a post-migration controlled reboot is still needed to prove the new boot path. The Qwen/Lightning boot-order race also still needs that reboot proof. |
| VoiceStudio | VoiceStudio v0.5.0 is installed portably at `D:\Apps\VoiceStudio`; portable storage, CUDA diagnostics, generation, Whisper transcription, Parakeet dictation, and blank-Capture-window recovery were verified. |
| Obsidian replicas | `FirstSpark` has separate official headless replicas at `/home/snknitin/vaults/LLMWiki` and `/home/snknitin/vaults/Personal-Sync`. Both bidirectional services are enabled and active, and sequential writes passed in both directions with matching SHA-256 hashes. The active Windows `Personal-Sync` vault is now `F:\Vaults\Personal-Sync`; Obsidian registers it as open and the former Google Drive copy as not open. Retrieval and hard Hermes write confinement remain open. |

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
- [x] Keep all Spark Hermes context pins aligned with the live Qwen ceiling: `model.context_length`, the model-lane declaration, and `custom_providers.spark-fast.models.spark-fast.context_length` resolve to `262144`. The 2026-09-18 low-residency profile preserves that ceiling while limiting scheduling to two sequences and reserving 10 GiB of explicit KV cache.
- [x] The earlier SSH-key path was superseded by the authenticated Remote Gateway design.
- [x] ODS Hermes Auth Proxy was evaluated and deliberately excluded from ownership of the primary Hermes home.

### Second Qwen profile and switching

- [x] [[DGX Spark Model Installation And Switching Guide]] Steps 16–21: baseline checks, safe stop/start, Qwen 27B DFlash preparation, raw API test, LiteLLM route, Hermes test, and return to the known-good Qwen 35B profile.
- [x] Hermes has shown both `spark-fast` and `qwen27-dflash` in its model list.
- [x] The one-large-model rule and the difference between **downloaded**, **listed**, and **resident** are understood.

### Recovery, second Spark, and workstation voice

- [x] [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20]] records the first Spark's physical power-cycle recovery and the corrected Qwen-before-Lightning boot order.
- [x] `SecondSpark` is connected through NVIDIA Sync and passed the initial idle thermal/no-throttling comparison; its future compute-only role does not duplicate the first Spark's Hermes state.
- [x] [[VoiceStudio Windows Portable Usage]] records the verified portable VoiceStudio v0.5.0 installation and first-use tests at `D:\Apps\VoiceStudio`.

The follow-up controlled reboot, UEFI Auto Boot confirmation, and first real dual-Spark workload validation remain open in [[Task Checklist]]. QSFP networking and NCCL are complete; use [[DGX Spark Dual-Node Configuration And Operations Reference]] rather than repeating setup.

### Obsidian headless replicas

- [x] Official `obsidian-headless` is installed under Node.js 22+ on `FirstSpark`.
- [x] `LLMWiki` and remote `Personal-Sync` completed protected initial pulls into separate directories.
- [x] `obsidian-sync-llmwiki.service` and `obsidian-sync-personal.service` are enabled, active, bidirectional, and configured with merge conflict handling.
- [x] Desktop-to-Spark and Spark-to-desktop inbox notes reached both replicas with matching SHA-256 hashes.
- [x] The existing Hermes/model services remained active during rollout.

Do not repeat the login or setup. The remaining backup, old-copy retirement, hard write-confinement, restart, simultaneous-conflict, retrieval, and dashboard gates are in [[Task Checklist#Sequence 6 — Obsidian headless replica and measured retrieval]] and [[Task Checklist#Sequence 6B — Scheduled Markdown outputs and a two-way feedback dashboard]].

Use only these completed-guide sections now:

- [[DGX Spark Operations Setup Guide#Safe stop and rollback commands|Operations rollback commands]]
- [[DGX Spark Model Installation And Switching Guide#Step 23 — Daily model operations|Daily Qwen operations]]
- [[DGX Spark Model Installation And Switching Guide#Step 22 — Rules for every additional model|Rules for additional models]]

### Architecture and research completed

- [x] [[DGX Spark Multi-Model Runtime Research]] — explains why the 120 GB reading was runtime/KV allocation rather than checkpoint size.
- [ ] [[DGX Spark Qwen NVFP4 Memory And Startup Optimization Research]] — the former 18 GiB/5-sequence profile remains historically verified at 262K. On 2026-09-18 the stopped service was changed to a 10 GiB KV pool, two scheduled sequences, and the same 262K ceiling; static configuration validation passed, but startup capacity and request validation remain pending.
- [x] [[DGX Spark Additional Models And Convenience Runtimes Research]] — verifies the current Gemma, Nemotron, Muse, Ollama, and LM Studio paths.
- [x] [[DGX Spark And RTX 5000 Workstation Model Placement Research]] — establishes the final Spark/workstation division and confirms why dense 27–31B models belong on the RTX workstation first.
- [x] [[ODS Workstation Ollama Integration Research]] — verifies the live ODS Dashboard, Open WebUI connections, model stores, Ollama state, and safe update boundary.
- [x] RTX PRO 5000 Blackwell identity verified from `nvidia-smi`; the Ada/32 GB contingency no longer applies.

## Resume here — exact order from today

### 0. Finish Obsidian safeguards, then prove the Markdown dashboard

Read:

1. [[Markdown Backed Interactive Dashboard Research]]
2. [[Task Checklist#Sequence 6 — Obsidian headless replica and measured retrieval]]
3. [[Task Checklist#Sequence 6B — Scheduled Markdown outputs and a two-way feedback dashboard]]

Do:

- [x] Keep the two existing headless services; do not run either vault setup again.
- [x] Move the active Windows `Personal-Sync` vault out of Google Drive to `F:\Vaults\Personal-Sync`; keep the former Drive copy closed while the new copy finishes verification.
- [ ] Give `Personal-Sync` an independent dated backup and restore-test one disposable note.
- [ ] Enforce a real `Agent Inbox/Spark Hermes/` write boundary before giving Hermes or a dashboard broad production write access.
- [ ] Build the narrow `LLMWiki` dashboard MVP: render scheduled Markdown reports and let 👍/👎 update only `feedback`, `feedback_note`, and `feedback_updated_at` in each source note.
- [ ] Prove dashboard feedback reaches desktop Obsidian and a desktop property edit refreshes the open dashboard.
- [ ] Complete stale-write, simultaneous-edit, restart, sync-delay, path-boundary, and rollback tests before calling the browser path production-ready.

**Done when:** the simple Obsidian-native proof is accepted or a browser MVP safely writes only the managed Markdown subtree, and no dual-sync or silent-overwrite path remains.

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

### 2. Correct the workstation ODS and Ollama boundaries

Follow this beginner runbook first:

1. [[RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial]] — this is the active replacement for Steps 2–4.

Use this research note only when you want the diagnostic evidence behind the corrections:

1. [[ODS Workstation Ollama Integration Research]]

Current status and remaining actions:

- [x] Native Windows Ollama 0.32.13 is already installed.
- [x] Authenticated ODS Open WebUI uses native Ollama at `http://host.docker.internal:11434`; ODS's own host-facing llama-server was moved to `11436`.
- [x] Workstation Open WebUI does not contain Spark LiteLLM aliases; workstation ODS and Spark ODS remain separate.
- [x] Ollama Desktop stores models at `D:\LocalLLama\models\ollama`.
- [x] Ollama Desktop is configured for 128K context.
- [x] **Expose Ollama to the network** was used for the initial connector test and is now turned back off; Ollama itself listens only on workstation loopback.
- [x] Load one large Gemma once and confirm `ollama ps` reports `131072` in the `CONTEXT` column.
- [x] Disable the old broad Windows Ollama firewall allowances from an Administrator session. The replacement tailnet-only Tailscale Serve route is working and **Expose Ollama to the network** is off, but the inherited firewall rules could not be disabled without elevation.
- [x] The small `gemma3:4b` connector test was downloaded and appeared in ODS Open WebUI.
- [x] The duplicate saved Ollama connection was removed; one `http://host.docker.internal:11434` entry remains and every Ollama model appears once.
- [x] Keep SearXNG as the workstation ODS search service; the existing `ods-searxng` container remains healthy on workstation loopback.
- [x] Do not enable ODS Hermes; standalone Spark Hermes remains authoritative and no ODS Hermes container is running.

> [!warning] Do not follow the Spark Ollama tutorial now
> [[DGX Spark Ollama And ODS Tutorial]] installs an Ollama sidecar on Spark. It remains a reference/rollback alternative, but it is **not the active plan**. The active Ollama runtime is native Windows Ollama on the workstation.

**Done when:** the Ollama Desktop path/context persist after restart, `gemma3:4b` appears in workstation Open WebUI, the ODS and Ollama model stores remain separate, and no Spark alias is assumed in this workstation UI.

### 3. Add workstation models one at a time

Continue in [[RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial]]:

- Part 3 downloads, runs, tests, compares, and switches the two Gemmas plus Qwen 3.8 27B through native Ollama while using ODS Open WebUI as the chat front end.
- These models belong to `D:\LocalLLama\models\ollama`; do not duplicate them in the ODS GGUF store or LM Studio merely to complete the step.

Use [[DGX Spark And RTX 5000 Workstation Model Placement Research#The practical workstation shortlist]] as the broader model-placement reference.

Install and test in this order:

1. **Gemma 4 31B** — first local dense quality/coding/multilingual verifier.
2. **Gemma 4 26B-A4B** — faster creative-writing, translation, summarization, and vision worker.
3. **Qwen 3.8 27B** — general chat/coding/reasoning/vision/tools candidate through the existing dynamic Ollama provider.
4. **One 7–14B training model** — only when beginning the fine-tuning workflow.

Nemotron 3.5 Lightning has moved to the Spark LM Studio plan in Step 4. Do not add a second Ollama copy on the workstation.

Completed for the two Gemmas:

- [x] `gemma4:31b-it-qat` and `gemma4:26b-a4b-it-qat` were pulled into the Ollama store.
- [x] Their exact tags and sizes were recorded: 18 GB and 15 GB respectively under Ollama 0.32.13.
- [x] Both were selected and tested through workstation Open WebUI at `localhost:3000`.
- [x] Both passed the direct comparison prompt, ran entirely on the GPU at the original 16K test context, and were unloaded afterward.
- [x] Repeat one short loaded-model check at the new 128K server setting before telling Hermes that the effective context is 128K. Both large Gemmas also passed one Hermes terminal-tool call and reported `131072` in `ollama ps`.
- [x] Compare the same prompts against `spark-fast` separately in Hermes Desktop.

Completed for Qwen 3.8 27B:

- [x] `qwen3.8:27b` was downloaded once into the native Ollama store; its interrupted first transfer resumed and passed SHA-256 verification.
- [x] It passed local text, structured-tool, vision-path, ODS Open WebUI, Spark Tailscale, and Spark Hermes tests.
- [x] It ran 100% on the RTX PRO 5000 at context `262144`, used about 37,890 MiB, and was unloaded afterward without deleting it.
- [x] The existing `desktop-ollama` provider was retained in both Hermes gateways; only verified Qwen metadata was added. The Spark default remains `spark-fast`.

Do **not** download workstation copies of the two Qwen 3.6 models already working on Spark. Qwen 3.8 is the deliberate workstation Ollama candidate; keep Spark as the capacity/reference path until a controlled comparison justifies promotion.

### 4. Make Spark LM Studio the Nemotron 3.5 Lightning shelf and connect both Hermes gateways

This step deliberately supersedes the older plan to run Nemotron 3.5 Lightning as another vLLM service. For this rollout, **LM Studio/llmster on the Spark owns one `Q4_K_M` copy of NVIDIA Nemotron 3.5 Lightning**, and LM Link makes that same Spark-hosted model available in workstation/laptop LM Studio. Do not create a separate Nemotron vLLM container or download a workstation duplicate.

Read and reconcile before executing:

1. [[DGX Spark Nemotron 3.5 Lightning Via LM Studio Research]]
2. [[Hermes LM Link And Workstation Model Routing Research]]
3. [[DGX Spark LM Studio And LM Link Tutorial]]
4. [[Always-On Hermes on DGX Spark#What is shared across devices]]

#### Target endpoint map

| Hermes surface | Named provider | Endpoint used by that Hermes profile | Models |
|---|---|---|---|
| Spark Remote Gateway, including Telegram and Discord | `desktop-ollama` | Tailnet-only HTTPS URL from Tailscale Serve, ending in `/v1` | Workstation Ollama Gemma and Qwen shelf |
| Spark Remote Gateway, including Telegram and Discord | `spark-lmstudio` | `http://127.0.0.1:1234/v1` | Spark LM Studio Nemotron 3.5 Lightning |
| Windows Local Gateway | `desktop-ollama` | `http://127.0.0.1:11434/v1` | The same workstation Ollama Gemmas and Qwen |
| Windows Local Gateway | `spark-lmstudio` | `http://127.0.0.1:1234/v1` through the workstation LM Link connector | The same Spark-hosted LM Studio model |
| Laptop using Spark Remote Gateway | both providers above | No additional model endpoint configuration; the laptop reads the Spark Hermes profile | The same dynamic Ollama and Spark LM Studio shelves |
| Laptop Local Gateway, optional fallback | `desktop-ollama` plus `spark-lmstudio` | One-time tailnet-only provider URLs, or laptop LM Link for Spark LM Studio | The same shelves after live discovery |

The model lists do not merge automatically between gateways. Configure the named providers once in the authoritative Spark Hermes profile and once in the Windows local Hermes profile. Telegram and Discord remain owned by the Spark Gateway; selecting a workstation model changes only the inference endpoint and does not move bot state, skills, sessions, or schedules to Windows.

#### 4A — Secure and verify workstation Ollama as an optional Spark upstream

- [x] Confirm Ollama listens on port `11434` and answers through the workstation Tailscale address.
- [x] Confirm the two large Gemma 4 tags advertise `tools`; keep `gemma3:4b` as chat/vision only because it does not advertise tool support.
- [x] Replace broad network exposure with a Tailscale Serve HTTPS proxy to loopback Ollama, then turn **Expose Ollama to the network** back off. The working tailnet-only URL uses HTTPS `8443`; the Spark provider supplies `Host: localhost:11434` because Ollama rejects the forwarded tailnet hostname.
- [x] Restrict the Tailscale grant to the Spark identity; never use Tailscale Funnel for Ollama.
- [x] Remove or disable the broad Windows Ollama Private/Public firewall allowances after the tailnet-only route works.
- [x] From the Spark, verify `GET /v1/models` against the tailnet-only HTTPS endpoint.
- [x] Add a named `desktop-ollama` provider to the Spark Hermes profile and declare each model's effective context as `131072` only after the loaded-model check passes. The Windows profile has the matching friendly provider as well.
- [x] Run one Spark-remote Hermes terminal-tool call through each large Gemma and prove the workstation automatically evicts 26B when 31B is selected. Refresh the long-running Gateway/Desktop picker after the endpoint rollout is complete.
- [x] Configure `spark-fast` as the fallback when the workstation is asleep, busy, or unreachable. The live Spark profile contains the validated fallback chain; an intentional outage/failover request has not been sent through the bots.

#### 4B — Put Nemotron 3.5 Lightning in LM Studio on the Spark

- [x] Confirm the Spark has no competing large model resident before loading the LM Studio model. Qwen was idle-drained and removed with its exact Compose `down` command; available memory rose from about 14 GiB to 112 GiB before the LM Studio load.
- [x] Download only `nvidia/nemotron-3.5-lightning@q4_k_m` into the Spark LM Studio model store. The indexed file is 24.52 GB and no partial download remains.
- [x] Start the Spark LM Studio API on `127.0.0.1:1234`; LM Link removes the need to bind it to `0.0.0.0`.
- [x] Enable JIT loading and Auto-Evict for normal catalog behavior. The initial profile used a 3,600-second idle TTL; on 2026-08-15 Nemotron was deliberately reloaded without a TTL so it stays warm beside Qwen until explicitly unloaded, the LM Studio daemon restarts, or an exclusive `spark-model use` transition unloads it.
- [x] Verify Nemotron through the Spark API, then through workstation LM Studio over LM Link. Both returned the exact requested test response, and the raw Spark API produced a structured function call.
- [x] Add a named `spark-lmstudio` provider to both profiles: Spark resolves it directly to Spark loopback, while Windows resolves it through LM Link on Windows loopback.
- [x] Verify the same Spark-hosted model from Telegram and Discord without creating another Hermes home. Remote Gateway and Windows Local Gateway Hermes tool calls already passed; both bot adapters are connected, but no representational test message has been sent without the user's confirmation.

> [!success] Extensible Spark model manager is live
> Use `spark-model list`, `spark-model status`, and `spark-model use <lane>`. The verified lanes are `qwen35`, `qwen27-dflash`, `nemotron3-omni`, and `nemotron35-lightning`. `spark-model use lmstudio:<model-key>` dynamically loads any future model installed in the Spark LM Studio catalog. Compose-backed vLLM, SGLang, and llama.cpp services can be added through `~/.config/spark-model/lanes.d` without changing the manager. It drains requests, stops the active lane, waits for memory, and waits for the target API; selecting a name in Hermes alone does not manage Spark container residency.

Workstation Ollama remains the workstation model service of record. Spark LM Studio becomes the on-demand Spark GGUF shelf. ODS keeps Open WebUI/SearXNG plus its stopped optional runtime. Do not duplicate the same 20–30 GB model across these stores without a deliberate benchmark reason.

> [!success] Remote Desktop And Bot Catalog Verified
> The Spark gateway's live picker payload contains `desktop-ollama` with all four installed Ollama models and `spark-lmstudio` with the downloaded Nemotron model. Telegram and Discord use this same picker and accept `/model --refresh`; the refresh clears Hermes's provider cache and re-fetches each live `/v1/models` endpoint. The Windows Local Gateway has the same two discovery-enabled providers. No per-model provider edit is required after a download, although a verified `context_length` entry is still recommended before relying on a new model at long context.

- [x] Verify Spark Remote Gateway/Desktop dynamic provider discovery.
- [x] Verify the exact Telegram/Discord model-picker payload without sending an external bot message.
- [x] Verify Windows Local Gateway provider discovery against desktop Ollama and Spark LM Link.
- [ ] Run `sudo tailscale set --operator=snknitin` once on Spark, then expose Spark loopback LM Studio on tailnet-only HTTPS `8443` for an optional laptop Local Gateway.
- [ ] Add the two stable provider URLs once to the laptop Local Gateway if that independent fallback is desired. This is unnecessary when the laptop uses the recommended Spark Remote Gateway.

### 5. Add the first genuinely specialized Spark model

Follow:

1. [[DGX Spark Nemotron 3 Nano Omni Tutorial]]

This is the best next Spark addition because it adds image, audio, video, OCR, and document capability rather than duplicating a workstation-sized text model.

- [x] Download the checkpoint and build the pinned audio-enabled local image.
- [x] Stop the resident Qwen before loading Omni through `spark-model use nemotron3-omni`.
- [x] Test raw text, structured tools, a 70,025-token prompt, image, audio-path, and short video. All serving-path tests passed; only real-world audio-quality evaluation remains optional.
- [x] Confirm its existing LiteLLM alias after the raw service passed.
- [x] Restore `spark-fast` after the comparison.

> [!success] Current resume point
> Omni memory optimization, 131K context validation, and multimodal-path acceptance are complete. Its 12 GiB KV profile accepted 70,025 prompt tokens above the former 65K ceiling and passed text, tools, image, audio-path, and short-video requests. Qwen 35 and LM Studio Lightning were restored afterward. Use a real speech/music sample later for perceptual audio-quality evaluation; the synthetic tone was accepted but misclassified.

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

- [x] Confirm the official Ollama tag and publisher: `qwen3.8:27b`, 27.3B parameters, Q4_K_M, approximately 18 GB, requiring Ollama 0.32.12 or newer.
- [x] Stable workstation-sized runtime support exists in the official Ollama library; use the single workstation copy rather than duplicating it in ODS or LM Studio.
- [x] Download and test `qwen3.8:27b` on the RTX PRO 5000 through native Ollama, ODS Open WebUI, and the existing `desktop-ollama` Spark Hermes provider.
- [x] Keep Spark as the capacity/reference path; `spark-fast` remains the current Hermes default.
- [ ] Do not replace `spark-fast` until identical chat, coding, vision, reasoning, and tool evaluations pass.

See [[Qwen 3.8 27B Ollama Remote Access Research]] for official model facts, security boundaries, and the end-to-end verification checklist.

### 9. Qualify the community dual-Spark frontier lane

This is the active two-node model track requested on 2026-09-18. It is separate from the workstation-sized Qwen 3.8 27B lane above and may proceed once its own readiness gate passes.

Read, in order:

1. [[DGX Spark Dual-Node Community Frontier Models Runbook]] — cluster-wide prerequisites, common lifecycle, memory/coexistence matrix, acceptance record, and rollback.
2. [[DGX Spark sparkDash Monitoring Tutorial]] — install the observer on loopback without granting it model or power ownership.
3. [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] — prove NVFP4 first, then run the official FP8 A/B.
4. [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] — experimental follow-on after Qwen passes start, stop, and rollback.
5. [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] — final, highest-risk recipe after every earlier gate passes.
6. [[DGX Spark Frontier Model Qualification Results]] — eight timestamped raw `spark-fast`, Qwen, GLM, and DeepSeek comparison rows, including remaining measurement limits.
7. [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] — permanent LiteLLM/Hermes names and the one-resident-backend switch workflow, only after acceptance gates.
8. [[FirstSpark Standalone LiteLLM Operations]] — current FirstSpark router files, commands, migration proof, and rollback archive.
9. [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]] — source, checkpoint, issue, license, and Aiden-stack evidence.

Execute in this exact order:

1. Clear Docker, reverse-SSH, toolkit-parity, interface/HCA/GID, and free-disk prerequisites.
2. Install sparkDash loopback-only, then stop it before the first model qualification run.
3. Drain `spark-fast`, Spark LM Studio, standalone LiteLLM, Hermes, and every other GPU or material host-memory consumer; record both nodes' idle baseline.
4. Prove Qwen NVFP4 directly on authenticated port `8100`, including loaded-context memory low-water, clean stop, and `spark-fast` rollback.
5. Prove the repository's official FP8 path as a separate A/B; do not label it the Aiden stack without Aiden's missing public image, launcher, digest, and settings.
6. Prove GLM only after Qwen; preserve its pinned recipe for the first baseline and treat current failure reports as stop conditions.
7. Prove DeepSeek last; its approximately 387 GiB staging footprint and few-GiB memory margin make it the strictest lane.
8. Register every validated profile under its distinct named alias: `qwen38-nvfp4`, `qwen38-fp8`, `glm53-flash`, and `deepseek41-flash`. Select one resident backend at a time; re-add LiteLLM/Hermes, then sparkDash, one layer at a time and repeat the same load before declaring coexistence safe.

The resource rule is absolute: Qwen, GLM, and DeepSeek each occupy both GB10 devices and cannot run beside `spark-fast`, Spark LM Studio, or one another. A separate single-node model on SecondSpark may coexist with `spark-fast` only as a different, explicitly designed lane—not while any two-node frontier recipe is active.

## File map — what each note is for

### Active execution notes

- [[DGX Spark Dual-Node Community Frontier Models Runbook]] — command-first master procedure for prerequisites, pinned source staging, two-node hot swaps, acceptance, routing, and rollback.
- [[DGX Spark sparkDash Monitoring Tutorial]] — loopback-only monitoring and benchmarking companion; observer only, never the model lifecycle or power owner.
- [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] — first model lane: recipe-faithful NVFP4 baseline followed by the official FP8 A/B.
- [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] — second, experimental model lane with long-prefill and soak gates.
- [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] — final high-risk model lane with source staging, Engram, strict memory, and service-layering gates.
- [[DGX Spark Frontier Model Qualification Results]] — current eight-profile raw comparison, run timestamps, and explicit unmeasured cells.
- [[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]] — reproducible user-run steps behind the fresh 131K DeepSeek and FirstSpark `spark-fast` receipts.
- [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] — registers every accepted named alias and installs the fail-closed two-node switch manager while preserving `spark-fast`.
- [[DGX Spark Dual-Node Configuration And Operations Reference]] — authoritative live dual-node identities, address plan, persistent network ownership, NCCL build and result, safety procedure, Cluster Assistant decision, and distributed-model next steps.
- [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20]] — live first-Spark service/model snapshot, automatic restart ownership, reboot verification, and safe UPS move checklist.
- [[DGX Spark Automatic Power Recovery Research]] — official NVIDIA evidence for `Auto Boot` after AC power returns and the UEFI setting path.
- [[DGX Spark Second Node And Dual Spark Readiness Research 2026-08-20]] — historical pre-cable planning, approved cable research, and two-Spark model limits; superseded for current operations by the dual-node reference.
- [[DGX Spark Operations Setup Guide]] — completed foundation; use only for service verification and rollback.
- [[DGX Spark Model Installation And Switching Guide]] — completed Qwen installation; use for daily switching rules.
- [[DGX Spark And RTX 5000 Workstation Model Placement Research]] — high-level machine ownership, model placement, and fine-tuning decisions; use the live ODS research below for current workstation-runtime details.
- [[ODS Workstation Ollama Integration Research]] — live workstation ODS/Ollama evidence and corrected ownership boundaries.
- [[Qwen 3.8 27B Ollama Remote Access Research]] — official Ollama package facts and the workstation-to-ODS-to-Spark-Hermes remote-access path.
- [[VoiceStudio Windows Portable Usage]] — verified portable install, usage, settings, backup, and blank-Capture-window recovery.
- [[VoiceStudio Risk Audit]] — risk inventory, acceptance checks, and boundaries between VoiceStudio and Handy.
- [[RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial]] — active GUI-first beginner runbook for incomplete Steps 2–4.
- [[RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial]] — superseded; retained only for history.
- [[DGX Spark Nemotron 3 Nano Omni Tutorial]] — completed specialist Spark lane; use for rebuild, rollback, and optional real-world media-quality testing.
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

- [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]] — immutable repository/model audit, published memory evidence, open failure modes, licenses, and the boundary around the unreproducible Aiden-specific claim.
- [[Markdown Backed Interactive Dashboard Research]] — compares Obsidian Bases, SilverBullet, Git-backed CMSs, static generators, and a purpose-built live Markdown writer; includes the recommended schema, concurrency controls, and weekly Claude/Hermes workflow.
- [[DGX Spark Multi-Model Runtime Research]]
- [[DGX Spark Additional Models And Convenience Runtimes Research]]
- [[DGX Spark Aug 2026 Model Deployment Research]]
- [[dgx-spark-current-models-report|DGX Spark Current Models Report]]
- [[dgx-spark-playbook-roadmap-draft|DGX Spark Playbook Roadmap Draft]]
- [[dgx-spark-twitter-bookmarks-analysis|DGX Spark Twitter Bookmarks Analysis]]
- [[local-ai-architecture-research|Local AI Architecture Research]]

## Canonical decisions

1. Standalone Hermes on Spark is authoritative; ODS Hermes stays disabled.
2. Spark LiteLLM remains the canonical router for stable always-hot Spark aliases. Hermes named custom providers are the explicit exception for the on-demand workstation Ollama and Spark LM Studio shelves; workstation ODS Open WebUI remains separate.
3. Native workstation Ollama owns the canonical workstation model shelf on port `11434`. It may serve the authoritative Spark Hermes profile as a health-checked optional upstream over Tailscale; Telegram and Discord remain on the Spark Gateway. Workstation ODS owns Open WebUI and SearXNG; its optional separate GGUF runtime uses host port `11436` and stays stopped unless deliberately needed.
4. The RTX PRO 5000 Blackwell is the preferred home for dense 27–31B inference, evaluation, project work, and LoRA/QLoRA.
5. Spark owns the working Qwens, persistent agents, specialist/full multimodal services, long contexts, and models that exceed 48 GB.
6. Stable aliases hide checkpoint names and ports from Hermes and clients.
7. Several models may remain downloaded, but keep only one large model resident per GPU/runtime lane.
8. Ollama, LM Studio, and Hugging Face/vLLM use separate native stores; do not duplicate every model across all three. Nemotron 3.5 Lightning is the deliberate LM Studio-on-Spark model for Step 4 and is not also deployed as vLLM in this rollout.
9. Workstation inference drains before training; Spark remains the fallback during the GPU lease.
10. New Qwen releases enter through a separate test profile and evaluation gate, never by overwriting `spark-fast` on release day.
11. Markdown is the source of truth for the daily dashboard. The first UI is a narrow HTML report viewer whose only mutations are like/dislike feedback fields in agent-generated notes.
12. One authenticated `FirstSpark` service owns those limited writes inside the dedicated scheduled-output subtree, uses optimistic concurrency and atomic serialized writes, and reaches clients only over the tailnet.
13. A static generator may publish or preview Markdown but is not the write-back owner. The weekly Claude/Hermes run writes a new review draft with provenance and never overwrites its daily sources.
14. Qwen 3.8 Flash Next, GLM 5.3 Flash, and DeepSeek V4.1 are one exclusive two-node frontier lane: hot-swap them in the order NVFP4 → official FP8 → GLM → DeepSeek, and restore `spark-fast` between qualifications.
15. Port `8100` and the distinct `qwen38-nvfp4`, `qwen38-fp8`, `glm53-flash`, and `deepseek41-flash` aliases isolate the mutually exclusive lane from SearXNG on `8888` and from `spark-fast`. Registration does not imply simultaneous residency; each alias is promoted only after measured headroom with LiteLLM/Hermes and, optionally, sparkDash.
