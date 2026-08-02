---
title: DGX Spark Twitter Bookmarks Evidence Analysis
created: 2026-08-02
updated: 2026-08-02
source: local Twitter bookmark export
tags:
  - dgx-spark
  - local-ai
  - model-serving
  - hermes-agent
  - evidence-audit
status: reconstructed
---

# DGX Spark Twitter Bookmarks Evidence Analysis

## Purpose

This report reconstructs the research extracted from the local DGX Spark Twitter bookmark export. It is an evidence audit, not a claim that every social-media benchmark is reproducible.

Source folder:

`F:\Vaults\LLMWiki\Bookmarks\Twitter\DGX\Twitter-Exporter-Nitin_wysiwyg_Bookmark_Folder_DGX-2026-08-02_08-12-01`

The export contains 27 files: 25 individual bookmark notes, `MEDIA-REVIEW.md`, and one JSON extraction file. Local Markdown files were treated as the primary evidence. Performance claims were not promoted to facts merely because they appeared in more than one tweet.

## Evidence labels

| Label | Meaning in this report |
|---|---|
| **Verified lead** | A sufficiently specific model, repository, engine, feature, or configuration worth validating against its primary documentation. This label does **not** verify a reported benchmark. |
| **Hardware mismatch** | The claim was measured on hardware other than one DGX Spark, such as an RTX 4090, DGX Station, two Sparks, or four Sparks. |
| **Unverified benchmark** | A throughput, memory, context, quality, or concurrency number reported by a social post without a reproducible benchmark bundle in the export. |
| **Workflow signal** | A useful architecture, operations, security, or Hermes practice that should inform the setup even if it is not a performance benchmark. |

## Executive conclusion

The bookmarks support the following working plan:

1. **Use Qwen3.6-35B-A3B-NVFP4 as the normal single-Spark serving model.** It has the strongest bookmark evidence for a large context window, high concurrency, and a vLLM implementation that leaves substantially more unified memory available than the near-capacity models. The reported speeds are still unverified until reproduced locally.[^qwen-benchmark]
2. **Treat DeepSeek V4 Flash 0731 as an exclusive, queued “big model” lane.** It can fit only through aggressive quantization or a specialized Spark recipe, and its useful aggregate throughput comes with much slower per-stream generation. Do not keep it resident beside the normal ODS/Hermes stack.[^deepseek-fit][^deepseek-concurrency]
3. **Treat Step-3.7-Flash as experimental on one Spark.** The saved report places its Q4 weights around 108 GB and says an NVFP4 attempt wedged the machine. Even if it loads, it leaves too little headroom for context, speculative decoding, concurrent requests, ODS, or the desktop environment.[^big-moe-rule]
4. **Do not read Gemma bookmark speeds as Spark benchmarks.** The detailed Gemma 4 31B and 26B measurements were explicitly performed on one RTX 4090.[^gemma-4090]
5. **Do not read the Laguna “1K tokens/second” claim as a Spark benchmark.** That post explicitly names DGX Station and reports ten parallel agents; it is a different, much larger machine class.[^laguna-station]
6. **Give Hermes at least a 64K server-side context window.** This is a practical floor for the system prompt, tool schemas, conversation, and tool results—not a promise that every request should consume 64K.[^hermes-context]
7. **Keep substantial memory headroom and avoid repeated OOM experiments on the production Spark.** One report says an OOM can leave a Spark in a low-power state until it is fully shut down and power-cycled.[^low-power]

## Model evidence matrix

| Model or family | Bookmark signal | Classification | Single-Spark interpretation | Recommended role |
|---|---|---|---|---|
| **Qwen3.6-35B-A3B-NVFP4** | 95 tok/s single stream, 317 aggregate tok/s at eight sessions, 256K context, 24 concurrency, vLLM 0.26 | Verified lead + unverified benchmark | Best operational fit in this bookmark set; reproduce numbers before capacity planning | **Primary 24×7 Hermes and general agent endpoint** |
| **DeepSeek V4 Flash 0731** | 284B model; 3-bit/110 GB marketing claim; field report says IQ3_XXS around 104 GB was the quant that actually fit; another post reports 26.7 tok/s solo and 58.5 aggregate at 12 streams | Verified lead + unverified benchmark | Can fit, but consumes nearly the entire box and reduces per-session speed under concurrency | **Exclusive queued big-model profile** |
| **Step-3.7-Flash GGUF** | Q4 reported around 108 GB; NVFP4 reportedly failed to load and wedged the box; another list claims 30 tok/s and 256K multimodal context on two Sparks | Unverified benchmark + hardware mismatch | Too tight for a dependable shared service on one Spark | **Experimental only; never default** |
| **Laguna-S-2.1 NVFP4** | One-Spark post claims 67 GB and 35–45 tok/s with a drafter; a separate 1K tok/s claim is on DGX Station | Verified lead + unverified benchmark; 1K claim is hardware mismatch | Plausible coding-specialist candidate with useful memory headroom, but needs a reproducible single-Spark engine test | **On-demand coding specialist** |
| **Qwen3.5-122B-A10B-NVFP4** | Reported 74 GB and about 35 tok/s with MTP | Verified lead + unverified benchmark | Fits the “under 80 GB weights” rule and may be a strong alternative, but overlaps the Qwen3.6 role | **A/B challenger, not another permanent resident** |
| **Gemma 4 26B-A4B QAT GGUF** | 160 tok/s decode, 9,200 tok/s prefill, and 250K context | Hardware mismatch + unverified benchmark | The measurements are RTX 4090 results, not Spark results; model remains a promising lightweight llama.cpp worker | **Desktop RTX 5000 or secondary Spark experiment** |
| **Gemma 4 31B QAT GGUF** | 60–65 tok/s and 110K–140K contexts with QAT, MTP, and KV-cache quantization | Hardware mismatch + unverified benchmark | Measurements are RTX 4090 results; useful as a dense verifier or multimodal worker, especially on the RTX 5000 | **Desktop verifier/vision worker** |
| **Nemotron 3 Nano Omni** | Reported 30B/3B-active multimodal model, 33 GB Q8 footprint, 256K context, and high short-context throughput | Verified lead + unverified benchmark | A compelling specialized model for OCR, documents, audio, video, and classification; benchmark it on representative files | **Specialized multimodal/FDE endpoint** |

### Why Qwen3.6 is the primary recommendation

The saved Qwen3.6 post is the only single-Spark bookmark that simultaneously names the quantization format, serving engine/version, context window, and concurrency target. It reports vLLM 0.26, 256K context, and 24 concurrent slots.[^qwen-benchmark] A broader saved comparison also ranks Qwen3.6-35B NVFP4 as a one-Spark choice and contrasts it with models that require two or four Sparks.[^model-list]

The throughput figures must still be treated as test targets. “317 tok/s at eight sessions” is aggregate throughput, not the speed experienced by each user. Capacity acceptance should record:

- time to first token;
- decode tokens/second per stream;
- aggregate tokens/second;
- request latency at p50, p95, and p99;
- prompt length and output length;
- actual KV-cache memory;
- model/engine commit and all launch flags.

The reason to choose Qwen3.6 is therefore operational fit, not simply the largest advertised tokens-per-second number.

### DeepSeek V4 Flash: fit and concurrency are separate questions

Unsloth’s saved post says DeepSeek V4 Flash can run lossless 4-bit in 168 GB and 3-bit in 110 GB via Unsloth or llama.cpp.[^deepseek-fit] The embedded field report is more cautious: Q3_K_XL and Q3_K_M allegedly occupied about 128 GB and OOMed on a Spark with roughly 121 GB usable, while IQ3_XXS at about 104 GB was said to fit fully on the GPU.[^deepseek-fit]

A later single-Spark report provides a useful concurrency curve: aggregate throughput rose from 26.7 tok/s at one request to about 58.5 tok/s at eight to twelve requests, while per-stream generation fell from 26.7 to 5.2 tok/s at twelve streams.[^deepseek-concurrency] Another bookmark summarizes the same setup as roughly 1,000 tok/s prefill and 59 tok/s multi-agent serving.[^deepseek-prefill]

These are good experimental targets, but the correct operational conclusion is:

- load DeepSeek only after draining the primary endpoint;
- expose it through an alias rather than a new hard-coded URL;
- start with one stream and a bounded context;
- increase concurrency only after measuring per-stream latency;
- unload it after an idle TTL so Qwen3.6 can resume service.

### Step-3.7-Flash: the memory-headroom warning

The strongest useful signal is not its claimed quality or speed—it is the failure mode. A saved one-Spark field report recommends keeping model weights below roughly 80 GB so that 35–45 GB remain for KV cache and a speculative decoder. The same report places Step-3.7 Q4 at about 108 GB and says the NVFP4 build failed to load twice.[^big-moe-rule]

Another saved model list assigns Step-3.7 to **two** Sparks, with 256K context, image support, and an unverified 30 tok/s claim.[^model-list] These sources do not justify treating Step-3.7 IQ4_XS as a shared production model on one Spark. Test it only in an exclusive profile with conservative context and concurrency.

### Laguna: useful lead, misleading headline

A one-Spark report puts Laguna-S-2.1 NVFP4 around 67 GB and claims about 35 tok/s with a DFlash drafter, rising to 45 tok/s on sustained code.[^big-moe-rule] That is a useful candidate to reproduce.

The eye-catching separate claim—ten parallel agents, 256K context each, at roughly 1K tokens/second—explicitly says **DGX Station**, not DGX Spark.[^laguna-station] It must not appear in single-Spark capacity planning.

### Gemma: valuable model, wrong benchmark hardware

The detailed Gemma bookmark states that Gemma 4 31B QAT ran at 60 tok/s on a single RTX 4090 and documents llama.cpp configurations for MTP, a vision projector, and progressively quantized KV caches.[^gemma-4090] The quoted 26B-A4B section likewise names a single RTX 4090 and reports 9,200 tok/s prefill, 160 tok/s decode, and a 250K context ceiling.[^gemma-4090]

Those results are valuable for the RTX 5000 workstation and for learning which llama.cpp techniques to test on Spark. They are not Spark results. The safe inference is that Gemma 4 is a promising small/medium worker, especially for the workstation—not that a Spark will reproduce 4090 latency.

### Nemotron Omni: specialized rather than general-purpose

The Nemotron bookmark identifies a multimodal MoE use case: images, video, audio, OCR, documents, text, and code. It claims 30B total/3B active, a 33 GB Q8 footprint, 256K context, and 57–264 generation tok/s depending on depth.[^nemotron]

Treat the model identity and modality coverage as a verified lead, and every performance number as unverified. It is worth testing because the user’s planned FDE work includes document and multimodal pipelines—not because it should replace Qwen3.6 for ordinary Hermes chat.

## Context and memory economics

### Hermes context floor

The Hermes-specific bookmark explains a common failure: Ollama may choose a small context by default, after which an agent forgets instructions or repeats work. It says the Hermes system prompt and tool schemas alone can consume roughly 4K–8K tokens and recommends a minimum 64K server-side context.[^hermes-context]

The saved engine-specific settings are:

```bash
# Ollama
OLLAMA_CONTEXT_LENGTH=64000 ollama serve

# vLLM
--max-model-len 64000

# llama.cpp
llama-server -m model.gguf -c 64000
```

This establishes a **floor**, not a universal allocation. A server configured for 256K context multiplied by 24 concurrent requests can reserve or consume far more KV cache than a casual “256K model” label suggests. For Hermes:

- configure 64K as the minimum service profile;
- offer 128K/256K only through profiles with lower concurrency;
- use prefix caching when the engine/model combination supports it;
- keep `MEMORY.md` and `USER.md` concise because they are injected into every session.

The saved Hermes memory article says those two files are read at the start of every session, recommends keeping them small, and warns that bloated memory costs tokens and attention.[^hermes-memory]

## Engine signals from the bookmarks

| Engine | Evidence in export | Classification | Interpretation |
|---|---|---|---|
| **vLLM** | Qwen3.6 post names vLLM 0.26 and high concurrency; Hermes context post gives `--max-model-len 64000` | Verified lead + unverified benchmark | Best candidate for the persistent, concurrent OpenAI-compatible endpoint |
| **llama.cpp** | DeepSeek GGUF post and Gemma QAT/MTP configurations; Hermes context flag | Verified lead | Best for GGUF experiments, aggressive quantization, and models whose newest support lands here first |
| **SGLang** | sparkDash claims real-time tok/s monitoring for SGLang alongside vLLM and llama.cpp | Verified lead | A/B benchmark lane; do not add merely to have another engine |
| **Ollama** | Hermes context post warns its automatic context can be too small and provides an environment variable | Workflow signal | Convenient model exploration, but not the preferred concurrency router or automatic multi-profile control plane |
| **LM Studio** | Hermes post says the desktop path requests a 64K load by default | Workflow signal | Useful interactive desktop client, not the 24×7 Spark serving control plane |

The bookmarks do **not** establish that one engine wins for every model. They support a division of labor:

- vLLM for the normal concurrent service;
- llama.cpp for GGUF and tight-fit experiments;
- SGLang only when its implementation for a target model is demonstrably better;
- Ollama/LM Studio for convenience and manual evaluation, not production hot swapping.

sparkDash is a monitoring lead because the saved post says it can show real-time vLLM, llama.cpp, and SGLang throughput and can monitor multiple Sparks from a mobile-friendly UI.[^sparkdash] It should be evaluated alongside—rather than confused with—the ODS dashboard and Token Spy.

## Concurrency and automatic model switching

The bookmark evidence argues against trying to keep every large model resident. Model weights are only part of the memory requirement; KV cache, speculative decoding, CUDA graphs, engine overhead, ODS services, and the graphical desktop also consume unified memory.[^big-moe-rule][^deepseek-fit]

Use three logical aliases for clients such as Hermes:

| Stable alias | Normal target | Swap behavior |
|---|---|---|
| `spark-fast` | Qwen3.6-35B-A3B-NVFP4 on vLLM | Persistent; handles interactive Hermes and most scheduled jobs |
| `spark-big` | DeepSeek V4 Flash, Step-3.7, Laguna, or Qwen3.5-122B | Exclusive queue; exactly one heavy profile active |
| `spark-vision` | Nemotron Omni or an appropriate Gemma multimodal profile | On demand; can be delegated to the RTX 5000 when Spark is busy |

A safe swap controller should perform:

1. route new requests away from the profile being replaced;
2. drain in-flight requests with a deadline;
3. stop the old engine process or container;
4. verify that memory was actually released;
5. start and warm the requested profile;
6. run health, tokenizer, context, tool-calling, and model-identity checks;
7. atomically update the alias only after checks pass;
8. unload exclusive models after an idle TTL;
9. fall back to `spark-fast` after load failure or timeout.

Do not hot-swap an externally consumed production URL for every request. External projects should use a pinned model/version or a stable service tier; personal Hermes requests may use the dynamic aliases.

The DeepSeek concurrency curve is also a reminder that aggregate throughput and user experience are different metrics: 58.5 aggregate tok/s at twelve streams was reported alongside just 5.2 tok/s per stream.[^deepseek-concurrency]

## Hermes, remote access, and 24×7 operation

### Remote Desktop connection

The saved Hermes Desktop post describes a Remote-SSH-like mode: select a host already accessible through SSH, let the app start Hermes remotely and tunnel it back, and have chats, files, sessions, and the integrated terminal run on the remote machine. Hosts in `~/.ssh/config` appear in the app.[^hermes-remote]

This is a strong workflow signal for the Spark setup:

- Spark is the authoritative always-on Hermes runtime;
- desktop and laptop are clients;
- Tailscale provides private reachability, while SSH is the authenticated transport used by the desktop connection;
- the Spark-side Hermes working directory, memory files, skills, cron jobs, and agent state are authoritative;
- local desktop folders are available only when explicitly mounted/synced or when a separate local Hermes runtime is used.

The bookmark does not prove that every desktop setting edits the remote Spark configuration. Provider keys, bot tokens, MCP servers, skills, and profiles should be tested field by field. Configuration that lives only in the Windows app may remain client-local; configuration written by the remote Hermes instance belongs to Spark.

### Memory, skills, cron, and Obsidian

The saved workflow article says Hermes memory is based on `MEMORY.md` and `USER.md`, reusable processes can be captured with `/learn`, and skills can be scheduled with cron. It explicitly recommends a 24×7 host so scheduled work continues after a laptop closes, and mentions using an Obsidian vault as a larger knowledge system.[^hermes-memory]

Classify this as a workflow signal, not proof of automatic three-device synchronization. The robust layout is:

- keep the canonical Obsidian vault synchronized through the user’s existing vault sync mechanism;
- clone/sync only the knowledge folders needed by Spark;
- avoid simultaneous automated edits to the same note from several devices;
- use Git for versioned skills/config templates, not for live databases, secrets, runtime caches, or active session state;
- keep Hermes’s compact operational memory distinct from the full Obsidian knowledge base.

### Orchestration across Hermes, Codex, and Claude Code

One saved article describes Herdr as a persistent terminal multiplexer for multiple agent harnesses. It reports a background server/client split, reattachment over SSH, and an API that lets Hermes create panes, inspect other agents, send instructions, and summarize their status. It also describes converting successful workflows observed in Codex or Claude Code into Hermes skills and scheduling concise status reports with cron.[^herdr]

This is a useful orchestration pattern, with two constraints:

- consumer Claude/ChatGPT subscriptions are not automatically reusable as unattended API credentials in arbitrary orchestration tools;
- every child agent needs explicit filesystem, network, secret, and command boundaries.

Use Hermes as the scheduler/control-plane agent, but let each harness remain responsible for its own authentication and terms. Route tasks to local models for repeatable inference where quality is sufficient.

### Credential firewall and sandboxing

The saved Nous Research post describes Hermes egress setup for Docker sandboxes: real API keys remain outside the sandbox, workloads see stand-in tokens, and a local boundary proxy substitutes the actual key during allowed outbound requests.[^credential-firewall]

This is a high-value security workflow signal. Apply it to coding agents, scraped tools, and third-party skills:

- never mount the master secrets file into an agent container;
- allowlist destination hosts and APIs;
- give each tool a separate scoped credential;
- log secret-use metadata without logging the secret;
- revoke credentials without rebuilding the sandbox;
- require approval for new egress destinations.

### Buzz integration

The bookmark export contains a concrete Buzz/Hermes lead: a `hermes-in-buzz` skill intended to set up the Buzz CLI and authentication for a remote Hermes instance connecting to a local Buzz app through a gateway, plus a skill for correctly formatted media attachments.[^buzz-hermes]

Treat Buzz as an experimental collaboration surface, not the source of truth for Hermes configuration. The saved Buzz article says it uses signed events on a self-hosted relay, gives people and agents cryptographic identities, is model-agnostic, and currently has incomplete approval gates and future work around tighter agent scoping.[^buzz-principles] That makes it interesting for audit trails and multi-agent channels, but still early for unattended access to private repositories and secrets.

## Reliability warning: post-OOM low-power state

A saved Spark operator report says that after testing to OOM, the machine may remain at roughly 5–15 W and 650 MHz under load, making subsequent recipes look inexplicably slow. The reported recovery is a full shutdown, unplugging power for about a minute, and restarting.[^low-power]

Classification: **workflow signal + unverified hardware behavior**.

Operational response:

- record power, clocks, thermals, memory, and engine version with every benchmark;
- do not use the production Spark for repeated fit-to-OOM tests;
- set a conservative memory admission limit;
- monitor for abnormal clocks/power after engine crashes;
- if the condition appears, save diagnostics before power-cycling;
- keep benchmark results from before and after recovery separate.

## What the bookmarks do and do not prove

### They support

- Qwen3.6 as the normal concurrency-friendly Spark endpoint;
- a queued exclusive lane for near-capacity models;
- a 64K minimum Hermes context profile;
- vLLM as the normal service and llama.cpp as the GGUF experiment lane;
- explicit monitoring of per-stream and aggregate throughput;
- remote Hermes through SSH/Tailscale with Spark as the authoritative runtime;
- small Hermes memory files plus larger Obsidian retrieval;
- sandbox credential isolation;
- cron-based status digests and multi-harness orchestration.

### They do not prove

- that every advertised quant loads on the current Spark software stack;
- that a DGX Station or RTX 4090 result transfers to a DGX Spark;
- that maximum native context is practical under high concurrency;
- that prefill tokens/second predicts interactive decode latency;
- that aggregate tokens/second is the speed each user receives;
- that a desktop GUI automatically synchronizes every remote Hermes configuration field;
- that subscription logins can legally or technically substitute for API billing in unattended tools;
- that two heavy model servers can coexist safely merely because their weight files fit on disk.

## Reproduction checklist for each candidate

Before promoting any bookmark lead into the production model router, record:

- exact Hugging Face repository and revision;
- license and allowed use;
- exact quantization and file sizes;
- engine version/commit and container image digest;
- launch command and environment variables;
- cold-load time and warm-up behavior;
- memory before load, after load, at target context, and under concurrency;
- prompt-processing and decode throughput separately;
- single-stream and aggregate throughput at 1, 2, 4, 8, and target concurrency;
- time to first token and latency percentiles;
- context length actually exercised, not merely configured;
- structured output, tool-calling, and Hermes long-run behavior;
- recovery from cancellation, OOM, engine crash, and model swap;
- quality on a stable local task suite.

Only then should the alias be moved from `experimental` to `candidate`, and later to `production`.

## Source citations

[^qwen-benchmark]: `2026-07-29 - MiaAI_lab - qwen3.6-35b-nvfp4-on-your-nvidiaai-dgx-spark-has-b - 04458.md:L26-L41` — Qwen3.6, vLLM 0.26, 95 tok/s single, 317 aggregate at eight, 256K context, and 24 concurrency.

[^model-list]: `2026-06-27 - MiaAI_lab - what’s-the-best-model-you-can-run-on-your-nvidiaai - 82444.md:L30-L41` — one-, two-, and four-Spark model suggestions and claimed speeds/context.

[^big-moe-rule]: `2026-07-30 - sudoingX - if-you-own-a-single-dgx-spark-and-want-to-run-the - 40546.md:L26-L52` — under-80-GB rule; Laguna, Qwen3.5, and Step-3.7 fit/speed claims; Step-3.7 failure report.

[^deepseek-fit]: `2026-07-31 - UnslothAI - deepseek-v4-flash-0731-can-now-be-run-locally!-🐳 - 35596.md:L26-L40` and `L51-L63` — Unsloth memory claim, engine routes, and embedded single-Spark quant/OOM field report.

[^deepseek-concurrency]: `2026-08-01 - MiaAI_lab - rejoice-single-dgx-spark-owners!-💫 - 99312.md:L28-L53` — single-Spark DeepSeek quality claim and aggregate/per-stream concurrency curve.

[^deepseek-prefill]: `2026-08-01 - bleysg - ⚡-if-you-have-or-want-a-dgx-spark,-this-post-might - 69321.md:L26-L28` — 1,000 tok/s prefill and 59 tok/s multi-agent claim.

[^laguna-station]: `2026-07-25 - TheAhmadOsman - laguna-s-2.1-118b-a8b-on-dgx-station-using - 46473.md:L26-L35` — DGX Station, NVFP4/FP8 KV cache, ten agents, 256K each, and roughly 1K tok/s.

[^gemma-4090]: `2026-07-20 - analogalok - updated-gemma-4-31b-qat-(dense)-+-multi-token-pred - 63681.md:L26-L38`, `L44-L66`, and `L93-L128` — explicit RTX 4090 hardware, Gemma 4 31B/26B settings, memory, context, and throughput claims.

[^nemotron]: `2026-07-24 - sudoingX - anon,-if-youve-got-a-dgx-spark-and-you-do-any-docu - 17044.md:L26-L34` — Nemotron 3 Nano Omni modalities, footprint, context, and performance claims.

[^hermes-context]: `2026-07-24 - witcheer - hermes-wingtips-29-local-models-context-floor - 99763.md:L26-L40` — Hermes 64K context recommendation and Ollama/vLLM/llama.cpp settings.

[^sparkdash]: `2026-07-19 - MiaAI_lab - im-open-sourcing-sparkdash-⚡️ - 16876.md:L26-L40` — multi-Spark monitoring, engine tok/s support, and mobile-friendly UI claim.

[^hermes-remote]: `2026-07-22 - witcheer - for-anyone-that-likes-the-remote-ssh-feature-in-vs - 02837.md:L26-L30` and `L40-L48` — Hermes Desktop remote host, SSH tunnel, remote files/sessions/terminal, and DGX Spark commentary.

[^credential-firewall]: `2026-07-24 - NousResearch - new-in-hermes-agent-a-credential-firewall-for-dock - 06042.md:L26-L30` — stand-in sandbox tokens and boundary proxy claim.

[^hermes-memory]: `2026-07-27 - tomcrawshaw01 - the-difference-between-a-disposable-chatbot-and-an - 27555.md:L39-L77`, `L79-L105`, and `L117-L127` — memory files, skills, cron, 24×7 host, Obsidian, and verification advice.

[^herdr]: `2026-07-27 - tonbistudio - i-run-a-lot-of-agent-harnesses-at-once.-claude-cod - 47541.md:L27-L57`, `L69-L105`, and `L107-L115` — multi-harness persistence, Hermes orchestration, skill creation, and cron status reporting.

[^buzz-hermes]: `2026-07-30 - tonbistudio - so-ive-been-experimenting-more-with-using-hermes-a - 30113.md:L26-L32` — `hermes-in-buzz` and Buzz media-attachment skill descriptions.

[^buzz-principles]: `2026-07-22 - jack - why-we’re-buzzing - 50400.md:L27-L45` — signed events, self-hosted relay, identity, model-agnostic harnesses, current features, and early limitations.

[^low-power]: `2026-07-26 - MichaelHutu - to-all-the-new-nvidiaai-dgx-spark-users! - 66400.md:L30-L41` — reported post-OOM low-power state, symptoms, and power-cycle recovery.

Related: [[DGX Spark ODS Playbook and Model Roadmap]] | [[dgx-spark-current-models-report|DGX Spark Current Models Report]] | [[dgx-spark-playbook-roadmap-draft|DGX Spark Playbook Roadmap Draft]]
