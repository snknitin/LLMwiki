---
updated: 2026-10-12
status: decision-ready-not-deployed
tags: [qwen, dgx-spark, hermes, llama-cpp, lm-studio]
---

# Qwen 3.8 27B Spark Serving Options

> [!important] Final user choice
> The user selected **native llama.cpp, Unsloth UD-Q5_K_XL, and a four-session target**, with LM Studio disabled and Windows/Fresh Brief unchanged. Follow [[Qwen 3.8 27B Native Spark Setup Tutorial]] for the installation and its current verified status. The Q4 recommendation below is retained as the earlier comparison, not the selected model. Actual Q5 metadata now confirms an embedded MTP head, so a separate draft download is unnecessary.

## Recommendation

Run a dedicated, pinned **native llama.cpp service on FirstSpark**, with a fresh Unsloth Qwen3.8-27B GGUF download. Replace Nemotron's resident role, retain its files for rollback, and keep the existing vLLM `spark-fast` service. Hermes coding requests use a new explicit Spark provider; Windows clients reach the same service privately. **Fresh Brief continues using Windows Ollama unchanged.**

This is the recommendation for the user's revised scope, not a deployed result. LM Studio remains a good alternative if its Windows chat UI and LM Link are a priority. The model source, quantization, serving program and client are separate choices: downloading Unsloth does not require LM Studio, and both runtimes can read compatible GGUF files.

## Options and tradeoffs

| Option | Benefits for this setup | Costs and limits | Recommendation |
|---|---|---|---|
| Native llama.cpp on FirstSpark, replacing warm Nemotron | Direct speculative-decoding controls; explicit service settings/logs; independent of desktop GUI; private OpenAI-compatible API for Hermes and Windows | A service and private Windows route to maintain; no native LM Link discovery/control; newest features still need qualification | **Preferred for Hermes coding now that LM Link is optional** |
| FirstSpark LM Studio with Unsloth Qwen replacing warm Nemotron | Reuses installed service; convenient Windows remote model selection through LM Link; parallel inference supported | Installed wrapper exposes fewer speculative controls than the underlying binary; some context/KV settings require SDK configuration | Best if LM Studio desktop integration is the main priority |
| Dedicated Qwen3.8-27B vLLM service | Candidate for sustained multi-user throughput and larger concurrency | New model/backend qualification; separate memory reservation; may require replacing or resizing an existing lane; no established speed advantage here | Revisit only if measured llama.cpp throughput is inadequate |
| Ollama on FirstSpark | Familiar commands and native Ollama API | Another runtime; less reason to preserve its API when Fresh Brief stays on Windows; no demonstrated speed advantage | Viable, but weaker fit than the first two |

Simply starting Qwen alongside resident Nemotron is not the intended configuration. Nor does deleting Nemotron's files free GPU memory: **unloading its worker** does that. Its boot preload and automatic reload path must also be changed so it cannot return unexpectedly during Qwen operation. Preserve the model files until the replacement passes qualification.

## Model choice

Use [Unsloth's Qwen3.8-27B repository](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF). It is a quantized distribution of Qwen's model, rather than a separate base-model family. Its popularity is useful ecosystem evidence, not proof of superior coding accuracy on this machine.

**Proposed first candidate: UD-Q4_K_XL**, balancing weight precision with two large contexts and the existing vLLM worker. UD-Q5_K_XL is the higher-precision comparison if measured headroom permits; it is not automatically the better operating choice. Retain UD-Q4_K_M as the smaller fallback before considering any reduction in the requested context. Do not use tiny quants merely to quote a higher tokens/second figure.

Pinned Hub metadata inspected on 12 October 2026, revision `4ca720788d1e01f1bff70c033e0d0028fd02e502`:

| File | Bytes | SHA-256 |
|---|---:|---|
| `Qwen3.8-27B-UD-Q4_K_XL.gguf` | 17559178144 | `3f227079003add2511437e5b1e94812e363385225bf6a9b47b0054a72bc8b01e` |
| `Qwen3.8-27B-UD-Q4_K_M.gguf` | 16464440224 | `322e194ff79741c7baa497c240f677f54b201b0efab44ca8e50f122b39123482` |
| `Qwen3.8-27B-UD-Q5_K_XL.gguf` | 20876938144 | `8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276` |
| `MTP/mtp-Qwen3.8-27B-Q4_0.gguf` | 1369590656 | `50d9ce5a6da381bbcfb31061cf73df94a90e6faf8efeddee379a9cb8f1501c6e` |

Source: [Hub file metadata](https://huggingface.co/api/models/unsloth/Qwen3.8-27B-GGUF?blobs=true). Download only the chosen target and required companion files directly on FirstSpark. Do not download every quant. Pin the revision, hash-check the completed files and use a resumable downloader. A projector is only needed for image input; text coding does not require loading it.

The separate MTP file is a candidate companion from the same repository. Presence in the repository does not establish compatibility with the installed LM Studio wrapper; native llama.cpp must also verify matching architecture/tokenizer and successful loading. Do not substitute the ggml-org tweet command's draft file blindly.

## Context and memory

Keep **262,144 tokens per request and two simultaneous generations** as the qualification target. Input, history, tool output, reasoning and final answer must fit within each request's context. Two open conversations are not proof that two nearly full contexts were processed simultaneously. Any extra generation, including an agent's subagent request, uses the same capacity and may queue.

Current inspected FirstSpark state:

- Visible unified memory: approximately 121.7 GiB, with about 26–27 GiB available while both existing model workers are resident.
- Existing vLLM allocation: 48,818 MiB, about 47.7 GiB.
- Nemotron LM Studio allocation: 30,633 MiB, about 29.9 GiB; configured at 1M context and **one** active prediction.
- The Spark Dash reading around 77.6 GiB was the **sum of both workers**, not vLLM alone.

Unloading Nemotron is expected to make roughly 56 GiB available, but measure the actual result. UD-Q4_K_XL weights are approximately 16.4 GiB on disk. Full-attention Q8 KV for two 262K slots is roughly 17 GiB, before recurrent-state checkpoints, compute buffers, draft state and runtime overhead. File size is not total resident memory. This is a plausible configuration, not yet a proven fit with comfortable headroom.

For fixed, separate native llama.cpp slots, the candidate is aggregate context **524,288**, parallel **2**, unified KV disabled, Q8 K/V cache and Flash Attention. Inspect the pinned binary's help and runtime slot report before relying on these semantics. Each slot must report 262,144; this is not an attempt to extend each session beyond native context. In the inspected LM Studio wrapper the equivalent SDK load uses context262144, maxParallelPredictions2 and useUnifiedKvCache=false; the wrapper performs the aggregate multiplication.

Aim for at least 20 GiB available under combined representative load, no ongoing swap-out or new OOM events, and no sustained thermal throttling. This is a conservative local operating target, not a manufacturer guarantee. If the target fails, first investigate checkpoints/buffers, draft overhead and a smaller quant. Do not silently cut context to 64K or alter `spark-fast` to claim success. More simultaneous long sessions may require a deliberate reallocation of existing services.

## What the two tweets and replies establish

Read using the agent-reach workflow through the existing signed-in OpenCLI browser connection. Retrieved 33 rows for the DFlash conversation and 40 for the MTP conversation, including author continuations and accessible nested replies; inspected benchmark and diagram images. The reader follows up to five pagination pages. This is coverage of accessible replies, not a claim to have recovered hidden/deleted replies or every deeper branch.

| Source | Useful finding | Consequence here |
|---|---|---|
| [Author's MTP post](https://x.com/ggerganov/status/2088312667253391546) and [Spark command](https://x.com/ggerganov/status/2088340681701925253) | Native serving with MTP is explicitly demonstrated; the author's recipe uses ggml-org target/draft assets | Native llama.cpp is a credible deployment route, but the one-line example is not a two-slot 262K production configuration |
| [Author's DFlash post](https://x.com/ggerganov/status/2107462737211056421) | Recommends a newer llama.cpp release with DFlash and draft maximum7 | Test it as an accelerator, not a reliability or speed guarantee |
| [Reply reporting MTP faster](https://x.com/rudiservo/status/2107595452606812422) and [another slowdown report](https://x.com/pa_schembri/status/2107465756309107009) | Community results contradict a universal DFlash speedup | Compare no speculation, MTP2/MTP3 and DFlash7 on the same Spark workload |
| [Prompt-lookup benchmark](https://x.com/chirag/status/2103202217813745771) | Image reports gains on copying-heavy code, mixed results elsewhere; hardware is NVIDIA L4 | Consider prompt lookup only after basic serving works; do not transplant those gains to Spark |
| [Intel benchmark reply](https://x.com/Danmoreng/status/2107558191500501183) | Different hardware/backends/cache settings produce very different results | Cannot use that image to predict Spark throughput |

The CPU/model-copy diagrams in another reply are proposals, not a measured recipe for this dense model on Spark. Multi-GPU and multimodal questions in replies are not proof of supported combinations. Check exact source IDs in the archived retrieval if a display name changes.

MTP and DFlash seek faster decoding by verifying proposed tokens; they do not make the target model intrinsically smarter. Preserve the correct model chat template and tool handling, adequate output room and reasoning history where supported. Do not impose a short global thinking or turn limit as a speed trick. Pin versions after comparing coding success, tool correctness, time to first token and whole-task completion time—not just decode tokens/second. [llama.cpp server capabilities and flags](https://raw.githubusercontent.com/ggml-org/llama.cpp/master/tools/server/README.md).

## Planned deployment and acceptance

1. Choose native llama.cpp or LM Studio. Download the pinned Unsloth candidate directly on FirstSpark, with one canonical copy and verified hashes. No Windows model transfer is required.
2. Back up startup/routing settings, wait for the relevant model worker to be idle, replace Nemotron residency and prevent its automatic return. Preserve `spark-fast` and existing model files.
3. Start Qwen on a verified free loopback port. Native service uses a pinned ARM64 CUDA build under a user service, explicit logs, controlled restart behavior and startup validation. Bind no unauthenticated public/LAN endpoint.
4. Test plain completion, streaming, tool call/result, cancellation and reconnect. Compare the accelerators with the same prompts. Choose the measured winner rather than enabling every feature together.
5. Test two overlapping short requests, then two approximately 240K actual input-token requests and representative coding goals while `spark-fast` is active. Record usage, per-request context, both results, latency, available memory, swap deltas and thermal state. Short concurrent prompts alone do not qualify 2×262K.
6. Qualify two isolated real Hermes sessions with no fallback. Then add a distinct named provider to production Hermes; retain each Gemma once in the desktop Ollama catalog and remove desktop Qwen from that catalog only. This does not delete Ollama weights or change Fresh Brief. Review saved Hermes sessions so they do not retain the old desktop route.
7. Verify Windows access through a private SSH/Tailscale route and a compatible client or the native web UI. Native llama.cpp is not automatically an LM Link model. For the LM Studio alternative, set FirstSpark as the preferred LM Link device and verify the actual model route. [LM Link routing](https://lmstudio.ai/docs/developer/core/lmlink).
8. Verify service restart, schedule a controlled reboot and perform a representative soak. Observe Windows GPU activity during Hermes inference and validate that requests cannot fall back silently to desktop Ollama.

Model residency removes reload latency, not prompt processing or shared GPU contention. A 24/7 service is an operational configuration, not a promise of no heat, queues or failures. Fresh Brief's scheduled Ollama requests can still burden Windows; this scope removes the **Hermes** source of desktop inference only.

## Actual state and rollback

- No new Spark Qwen service is deployed; Nemotron remains resident and idle, context1048576/parallel1. Hermes Gateway remains active.
- The earlier Windows weight transfer was interrupted at the user's direction. Approximately15GiB remains in `/home/snknitin/.lmstudio/models/local/Qwen3.8-27B-Ollama/Qwen3.8-27B-Q4_K_M.gguf.incoming`. This incomplete file cannot be reused as an Unsloth download; it has not been loaded. Windows source files remain intact. Retained pending deliberate cleanup.
- Fresh Brief's proposed adapter changes were reverted to the exact pre-task state, preserving pre-existing changes. No running container, saved setting or service was changed. Original tests pass.
- Existing LM Studio-specific helpers remain alternatives, not a native installer. The short/long API probes can take an explicit base URL. The isolated Hermes helper currently targets the LM Studio provider and needs adaptation if native is selected. No live inference qualification has run.
- Rollback is to the backed-up Nemotron service/routing, with its model files retained. Do not delete rollback assets before qualification.

Related: [[Qwen Spark Migration Evidence 2026-10-12]], [[Qwen 3.8 27B Spark LM Studio Migration Tutorial]], [[Local Setup Index]], [[Task Checklist]].
