---
title: DGX Spark Current Models Report
date: 2026-08-02
status: reconstructed-research-input
scope: single NVIDIA DGX Spark with 128 GB unified memory
---

# DGX Spark: current model and serving report

Research cut-off: **2026-08-02 (Asia/Calcutta)**. This is the supporting model report used to build [[DGX Spark ODS Playbook and Model Roadmap]]. It prioritizes official model cards and engine documentation, then reproducible single-Spark reports. Hosted-provider speeds, RTX 4090/5090/6000 results, DGX Station results, multi-Spark totals, prefill throughput, and aggregate throughput are not treated as single-request decode performance on one Spark.

## Executive recommendation

Do not download every model into Ollama, LM Studio, vLLM, and SGLang. Store one canonical copy of each checkpoint and choose its engine by format and workload.

1. **Default Hermes and agent model:** `nvidia/Qwen3.6-35B-A3B-NVFP4` in vLLM.
2. **Small resident automation tier:** `Qwen/Qwen3.5-4B`, preferably a trusted Q4 GGUF in ODS llama.cpp or the optional Ollama extension.
3. **Resident retrieval tier:** `Qwen/Qwen3-Embedding-0.6B` and `Qwen/Qwen3-Reranker-0.6B` in separate embedding/reranking services.
4. **Multimodal alternative:** `nvidia/Gemma-4-26B-A4B-NVFP4` in vLLM, loaded on demand.
5. **Large evaluator:** `nvidia/Qwen3.5-122B-A10B-NVFP4` in a mutually exclusive vLLM profile.
6. **Agentic-coding experiment:** `poolside/Laguna-S-2.1-NVFP4` plus its matching DFlash draft in vLLM 0.25.1+.
7. **Capacity experiment:** `stepfun-ai/Step-3.7-Flash-GGUF` IQ4_XS in StepFun's llama.cpp branch, run alone.
8. **Experimental last:** DeepSeek V4 Flash 0731 using an aggressively quantized community single-Spark path.

Dense Qwen3.6-27B and Gemma 4 31B are normally better comparison models for the RTX 5000 48 GB workstation. Spark's advantage is capacity, native Blackwell NVFP4, sparse MoE execution, prompt processing, and batching—not HBM-class dense-model decode. NVIDIA specifies 128 GB shared LPDDR5X memory with 273 GB/s bandwidth and support for models up to roughly 200B parameters. See the [DGX Spark User Guide](https://docs.nvidia.com/dgx/dgx-spark/dgx-spark.pdf).

## Install and experiment matrix

| Decision | Exact model | Role | Engine | Single-Spark judgment |
|---|---|---|---|---|
| **Install first** | [`nvidia/Qwen3.6-35B-A3B-NVFP4`](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4) | Hermes, coding, tools, normal chat, concurrent internal projects | **vLLM** | 35B total/3B active, Apache-2.0, native 262K. NVIDIA supplies a Spark-specific profile. Current reproducible reports are roughly 82-104 output tok/s single-stream under different profiles; aggregate results are not directly comparable. Start at 64K-128K and four sequences. |
| **Keep resident** | [`Qwen/Qwen3.5-4B`](https://huggingface.co/Qwen/Qwen3.5-4B), using a trusted Q4 GGUF if served by llama.cpp | Cron triage, extraction, classification, short summaries, fallback | **ODS llama.cpp** or Ollama | Use 16K-32K and strict schemas. This prevents routine hourly work from consuming the main model. Do not grant a small model unrestricted autonomous shell access. |
| **Keep resident** | [`Qwen/Qwen3-Embedding-0.6B`](https://huggingface.co/Qwen/Qwen3-Embedding-0.6B) + [`Qwen/Qwen3-Reranker-0.6B`](https://huggingface.co/Qwen/Qwen3-Reranker-0.6B) | Obsidian, code, and project retrieval | **TEI** plus a separate reranker | Both support 32K input and Apache-2.0. Evaluate retrieval on the actual corpus before spending memory on the 4B embedding/reranker variants. |
| **Install on demand** | [`nvidia/Gemma-4-26B-A4B-NVFP4`](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4) | Multimodal reasoning, images, documents | **vLLM** | About 25.2B total/3.8B active and roughly 16.5 GB reported weights. Community Spark profiles span about 23-52 tok/s; NVIDIA's card measurements use other hardware. Start at 64K and four sequences; current card support is TP=1. |
| **Install on demand** | [`nvidia/Qwen3.5-122B-A10B-NVFP4`](https://huggingface.co/nvidia/Qwen3.5-122B-A10B-NVFP4) | Difficult reasoning, evaluator, quality comparison | **vLLM** | Roughly 65-75 GB, 122B total/10B active. Community recipes report about 28-35 tok/s normally and up to 51-52 in a specifically patched profile. Run alone and treat the upper figure as a tuned ceiling. |
| **High-value experiment** | [`poolside/Laguna-S-2.1-NVFP4`](https://huggingface.co/poolside/Laguna-S-2.1-NVFP4) + DFlash | Long-horizon agentic coding | **vLLM 0.25.1+** | 118B total/8B active, 1M trained context, around 73 GB for main plus draft. Official Spark recipe reports roughly 15 tok/s prose and 22-24 code, with better aggregate throughput at two requests. Poolside currently warns that NVFP4 in SGLang can produce corrupt/NaN output. |
| **Run-alone experiment** | [`stepfun-ai/Step-3.7-Flash-GGUF`](https://huggingface.co/stepfun-ai/Step-3.7-Flash-GGUF), `Step-3.7-flash-IQ4_XS.gguf` | Very large private multimodal/agent model | StepFun **llama.cpp branch** | Approximately 105 GB weights, 4 GB projector, and about 7 GB runtime overhead. Official Spark results fall from about 23.85 tok/s at an empty prompt to 19.6 at 32K, 16.13 at 64K, and 8.61 at 262K. Start at 32K and one sequence. |
| **Experimental last** | [`deepseek-ai/DeepSeek-V4-Flash-0731`](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-0731) | New frontier coding/reasoning experiment | Community Q2 GGUF/llama.cpp or pinned DS4-on-Spark evaluation | Official repository describes about 304B parameters including DSpark components, and its vLLM example targets a 4xGB300 node. A one-Spark Q2 build is around 90 GiB. Current reports often land near 15 tok/s; a tightly pinned DS4 community recipe reports higher. Aggressive Q2 can reduce reasoning and tool-call reliability. |
| **Workstation first** | [`nvidia/Qwen3.6-27B-NVFP4`](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4) | Dense quality challenger | vLLM if evaluated | All 27B parameters are active. Current Spark results are far slower than Qwen3.6-35B-A3B, whose sparse decode activates about 3B. Use the 48 GB RTX workstation unless a Spark-specific test is required. |
| **Workstation first** | [`google/gemma-4-31B-it`](https://huggingface.co/google/gemma-4-31B-it) or a trusted QAT GGUF | Dense verifier, vision comparison | llama.cpp/Ollama | It fits at Q4/NVFP4, but dense decode is bandwidth-bound. Bookmark speeds around 60-160 tok/s were RTX 4090 results, not Spark results. |

## Why the 35B MoE is faster than the 27B dense model

Model file size is not the same as decode cost. Qwen3.6-35B-A3B activates about 3B parameters per generated token; Qwen3.6-27B activates essentially all 27B. Single-stream autoregressive decode repeatedly reads active weights, so the GB10's 273 GB/s shared-memory bandwidth becomes the limiting resource for dense models. Native NVFP4 MoE kernels and MTP speculative decoding make the nominally larger sparse model substantially faster.

The same logic favors Gemma 4 26B-A4B over dense Gemma 4 31B for Spark serving.

## Engine decisions

### vLLM

Use vLLM as the production default for NVIDIA NVFP4/FP8 checkpoints and concurrent OpenAI-compatible traffic. It provides continuous batching, prefix caching, chunked prefill, tool parsers, FP8 KV cache, and an API that Hermes/LiteLLM can consume. Pin a container or environment per validated profile; Laguna's requirements must not be allowed to break the Qwen production environment.

### SGLang

Use SGLang as a controlled A/B candidate for a specific model, quantization, context, and concurrency tuple. It is not automatically faster on GB10. Do not use Laguna NVFP4 with SGLang while Poolside's official card warns of corrupt/NaN output; FP8 is a different path.

### ODS llama.cpp

Use the existing ODS llama.cpp service for small GGUF automation models. Use a separate pinned/model-specific build when a very new architecture requires it, such as StepFun's current Step-3.7 branch. Loading a checkpoint is not proof that the runtime correctly implements its multimodal projector, draft head, template, or tools.

### Ollama and LM Studio

Ollama is convenient for small GGUF lifecycle management and compatibility testing. LM Studio is useful as an interactive catalog, client, and benchmark surface. Neither should own the critical 24x7 externally consumed Spark endpoint. Avoid duplicate model caches across all engines.

### TensorRT-LLM and NIM

Learn them after establishing a vLLM baseline. They are useful NVIDIA deployment skills and may win for a fixed optimized profile, but they are not prerequisites for downloading a checkpoint and should not be operated merely to collect runtimes.

## Safe download order

Use one canonical Hugging Face model root on the large NVMe volume:

```bash
hf download nvidia/Qwen3.6-35B-A3B-NVFP4 --local-dir /srv/models/hf/qwen3.6-35b-a3b-nvfp4
hf download nvidia/Gemma-4-26B-A4B-NVFP4 --local-dir /srv/models/hf/gemma4-26b-a4b-nvfp4
hf download nvidia/Qwen3.5-122B-A10B-NVFP4 --local-dir /srv/models/hf/qwen3.5-122b-a10b-nvfp4
hf download Qwen/Qwen3-Embedding-0.6B --local-dir /srv/models/hf/qwen3-embedding-0.6b
hf download Qwen/Qwen3-Reranker-0.6B --local-dir /srv/models/hf/qwen3-reranker-0.6b
```

Recommended sequence:

1. Serve Qwen3.6-35B-A3B using NVIDIA's current Spark-specific vLLM profile.
2. Test text, images, multi-turn reasoning, tool schemas, structured output, concurrency 1/2/4/8, and 8K/32K/64K prompts.
3. Connect only that stable endpoint to ODS LiteLLM and Hermes for several days.
4. Add the small automation model and 0.6B retrieval services with explicit memory limits.
5. Validate Gemma 4 26B and Qwen3.5-122B as mutually exclusive on-demand profiles.
6. Add Laguna in a separately pinned vLLM environment; plan for a long first JIT/cold start.
7. Try Step-3.7 only during a maintenance window with other large inference stopped.
8. Try DeepSeek V4 Flash last and promote it only after exact tool, code-edit, context, and stability evals.

## Context and concurrency profiles

Advertised context is a model capability, not a guarantee that full context and high concurrency coexist in 128 GB.

| Profile | Suggested context | Initial sequences | Workload |
|---|---:|---:|---|
| `interactive` | 64K | 4-8 | Hermes desktop, coding, tools, ordinary RAG |
| `batch` | 32K-64K | 8-32 only after testing | Cron extraction, summaries, classifications |
| `long` | 128K-262K | 1-2 | Repository/document analysis, scheduled |
| `huge-experimental` | 262K-1M only after proving fit | 1 | Laguna/DeepSeek research, never the default route |

Measure p50/p95 time to first token, inter-token latency, prompt throughput, single-stream decode, aggregate decode, peak shared memory, cold start, failures, tool-call accuracy, and output quality.

## Automatic routing is not instant hot-swap

One Spark does not have enough independent memory pools to keep every large profile warm. vLLM sleep level 1 does not create another 128 GB pool: Spark CPU and GPU use the same physical unified memory. Use level-2 discard or terminate the process when the exclusive lane must genuinely release memory.

Operate:

- one always-on default large model (`spark-fast`);
- one small resident automation tier;
- optional resident retrieval services;
- one queue/drain/load state machine for mutually exclusive large profiles (`spark-big`);
- stable aliases in LiteLLM/Hermes rather than raw ports/checkpoint names;
- readiness, identity, structured-output, and tool-call tests before an alias changes;
- idempotency and retry policy for scheduled jobs;
- fixed/versioned external-user endpoints that do not swap mid-session.

If simultaneous no-interruption access to two large models is required, keep the second model on the RTX workstation, use a hosted overflow endpoint, or add another inference node.

## Claims not to reuse as Spark facts

- Hosted API throughput is not local throughput.
- Prefill throughput is not decode throughput.
- Aggregate throughput is not per-user throughput.
- RTX 4090/5090/6000, DGX Station, B200, and GB300 results are not one GB10 result.
- A model fitting in nominal 128 GB does not mean it fits beside the OS, ODS, KV cache, graph capture, draft model, JIT, and concurrent traffic.
- A two-day-old quant that loads is not automatically production-ready.
- Maximum context is not a reasonable default request allowance.

## Sources

- [NVIDIA DGX Spark playbooks](https://build.nvidia.com/spark)
- [NVIDIA Qwen3.6-35B-A3B-NVFP4](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4)
- [NVIDIA Gemma-4-26B-A4B-NVFP4](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)
- [NVIDIA Qwen3.5-122B-A10B-NVFP4](https://huggingface.co/nvidia/Qwen3.5-122B-A10B-NVFP4)
- [Poolside Laguna S 2.1 NVFP4](https://huggingface.co/poolside/Laguna-S-2.1-NVFP4)
- [StepFun Step-3.7-Flash GGUF](https://huggingface.co/stepfun-ai/Step-3.7-Flash-GGUF)
- [DeepSeek V4 Flash 0731](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-0731)
- [SparkBench](https://sparkbench.dev/)
- [vLLM sleep mode](https://docs.vllm.ai/en/v0.10.2/features/sleep_mode.html)
- [NVIDIA DGX Spark forum](https://forums.developer.nvidia.com/c/accelerated-computing/dgx-spark-gb10/742)

Related: [[DGX Spark ODS Playbook and Model Roadmap]] | [[dgx-spark-twitter-bookmarks-analysis|DGX Spark Twitter Bookmarks Analysis]]
