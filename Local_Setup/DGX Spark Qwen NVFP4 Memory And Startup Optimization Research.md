# DGX Spark Qwen NVFP4 Memory And Startup Optimization Research

_Primary-source review and live implementation verified on 2026-08-15._

## Bottom line

The original `spark-fast` profile reserved **58.52 GiB of KV cache** and exposed 4,838,587 KV tokens alongside 24.84 GiB of model memory. The implemented profile now uses an explicit **18 GiB FP8 KV pool**, a **262,144-token** ceiling, **five** maximum sequences, and an 8,192-token chunked-prefill budget while retaining the working custom image, backends, CUDA graphs, asynchronous scheduling, MTP, and tool parser.

The live vLLM 0.26.1.dev boot allocated **1,588,632 KV tokens** and reported **6.06 complete 262,144-token contexts**. That clears the requested five-full-context floor with roughly one additional full-context equivalent of margin. A real request containing 260,016 prompt tokens returned `OK.` in 139.326 seconds with zero preemptions, no waiting request, and no OOM.

The current custom image still applies `gpu_memory_utilization` to its startup free-memory preflight even when explicit KV bytes control cache sizing. Removing the proven 0.72 flag exposed the image's 0.92 default and failed before weight load because 111.27 GiB free was below its 111.95 GiB request. The final profile therefore retains `--gpu-memory-utilization 0.72` beside `--kv-cache-memory-bytes 18G`.

Simultaneous residency with LM Studio's Nemotron 3.5 Lightning `Q4_K_M` was subsequently **proven live**. With both idle-resident, `nvidia-smi` attributed about 48.2 GiB to Qwen and 24.1 GiB to LM Studio, Linux reported about 87 GiB used and 34 GiB available, and serial requests to both APIs completed without unloading or OOM. DGX Spark still has one 128 GB LPDDR5X pool shared by CPU and GPU, not separate host RAM and VRAM. It also has one 273 GB/s memory fabric, so successful residency does not imply that simultaneous heavy generation will preserve each model's independent throughput. [NVIDIA DGX Spark hardware overview](https://docs.nvidia.com/dgx/dgx-spark/hardware.html)

The verified posture is therefore:

1. Keep 262,144 context, an 18 GiB explicit KV pool, five maximum sequences, and 8,192 batched tokens.
2. Treat the 6.06 startup concurrency line and the 260,016-token request as the adoption evidence.
3. Keep the 0.72 preflight flag for this exact custom image; do not interpret it as the KV allocation after explicit bytes are set.
4. Keep exclusive lane switching as the default instead of assuming Qwen and LM Studio can generate concurrently at unchanged speed.
5. Re-run capacity, long-context, tool, and latency checks after any image, checkpoint, backend, MTP, or graph-setting change.

## Scope and model identity

The current NVIDIA-owned 35B/3B-active NVFP4 checkpoint that can be verified is [`nvidia/Qwen3.6-35B-A3B-NVFP4`](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4). NVIDIA's current Spark vLLM playbook names it as the agent-ready Qwen model for GB10. The model repository says its linear operators are quantized with NVIDIA Model Optimizer, supports vLLM on Blackwell, and has a native 262,144-token limit. [NVIDIA agent-ready vLLM models](https://build.nvidia.com/spark/vllm/agent-ready-models), [vLLM Qwen3.6 recipe](https://recipes.vllm.ai/Qwen/Qwen3.6-35B-A3B?features=tool_calling%2Creasoning&hardware=dgx_spark_gb10)

No NVIDIA-owned `Qwen3.5-35B-A3B-NVFP4` repository was verified during this review. If the deployed `MODEL_ID` is an Unsloth or another publisher's Qwen 3.5/3.6 conversion, the memory-control principles still apply, but the exact NVIDIA backend and speculative-decoding flags must not be assumed compatible. Confirm the actual image and model with `vllm serve --help` and the startup log before adopting version-sensitive flags.

The workspace guide currently documents this Qwen profile:

| Setting | Documented value |
|---|---:|
| Maximum model length | 262,144 |
| GPU memory utilization | 0.72 |
| Explicit KV cache | 18 GiB |
| Maximum sequences | 5 |
| Maximum batched tokens | 8,192 |
| KV cache | FP8 |
| Prefill/scheduling | Chunked prefill and asynchronous scheduling |
| Performance path | FlashInfer-family attention/linear paths and MTP |
| Persistent caches | Hugging Face model cache and `VLLM_CACHE_ROOT` |

The table now reflects the applied and verified profile. The following baseline records why it was changed.

### Historical Pre-Change Baseline

Read-only inspection before implementation supplied the following baseline:

| Observation | Live value |
|---|---:|
| vLLM build | 0.26.1.dev |
| Model weights | 24.84 GiB |
| KV-cache reservation | 58.52 GiB |
| KV-token capacity | 4,838,587 tokens |
| Maximum sequences | 8 |
| Weight-loading phase | 154 seconds |
| Engine initialization after weights | 48 seconds |
| API process/readiness phase | 32 seconds |
| Approximate total to ready | 234 seconds |
| Explicit KV flag | `--kv-cache-memory-bytes` supported |
| InstantTensor | Importable in the installed image |

This established that a much smaller explicit KV pool was viable and that weight loading, rather than KV profiling alone, dominated startup. The later 18 GiB implementation supersedes the preliminary 16 GiB estimate because five 262K contexts needed more alignment margin.

## What `gpu_memory_utilization` is actually doing

`--gpu-memory-utilization` is a budget for the **entire model executor**, not a KV-only percentage. When no explicit KV-cache byte count is given, vLLM loads the model, profiles non-KV allocations and peak activations, accounts for graph/runtime needs, and gives the remaining budget to its global KV pool. The setting is per vLLM instance and does not coordinate with LM Studio or another process. [vLLM engine arguments](https://docs.vllm.ai/en/latest/configuration/engine_args/#--gpu-memory-utilization), [vLLM GPU worker allocation source](https://docs.vllm.ai/en/latest/api/vllm/v1/worker/gpu_worker/)

On the nominal 128 GB Spark pool:

| Utilization | Nominal executor allowance | Meaning for co-residency |
|---:|---:|---|
| 0.72 | 92.2 GB | Leaves too little dependable room for a second approximately 25 GB model plus both runtimes and the OS. |
| 0.50 | 64.0 GB | Used by the current vLLM recipe site for the Spark variant, but not the exact NVIDIA model card recommendation. |
| 0.40 | 51.2 GB | Exact checkpoint's NVIDIA model card recommendation at 262K context, four sequences, and FP8 KV. |

The exact NVIDIA model card is the strongest baseline here: it uses 0.4 at the model's full 262,144-token ceiling. That establishes a useful control profile, but the deployed custom image still requires its proven 0.72 value for the startup admission check even though explicit bytes determine the actual KV size.

## `kv_cache_memory_bytes` versus utilization

Current vLLM exposes `--kv-cache-memory-bytes` for an explicit per-GPU KV allocation. When it is supplied, vLLM's documentation says it **ignores `gpu_memory_utilization`** for cache sizing. Weights, activations, CUDA graphs, workspaces, and process overhead are still additional allocations. An explicit cache therefore gives finer and more deterministic control, but it is not a whole-process memory cap. [vLLM KV-cache arguments](https://docs.vllm.ai/en/latest/configuration/engine_args/#--kv-cache-memory-bytes)

This distinction matters for startup. vLLM's startup guide says that feeding the logged KV value back on a later boot skips the memory-profiling measurement and CUDA-graph memory-estimation pass. It still has to read and load the weights, warm the model, compile or load applicable artifacts, allocate the fixed KV pool, and capture CUDA graphs. A too-small byte value caps concurrency or may fail the one-full-context admission check; a too-large value can fail allocation when LM Studio or another co-tenant is present. [vLLM faster-startup guidance](https://docs.vllm.ai/en/latest/configuration/optimization/#faster-startup)

The generic safe sequence is:

1. First boot with a source-backed auto-profiled envelope and no explicit KV byte value.
2. Capture these startup lines: model-weight memory, peak activation/non-Torch memory, CUDA-graph memory, available KV memory, `GPU KV cache size`, and maximum concurrency at the intended model length.
3. Prove one real near-maximum request completes without preemption or OOM.
4. Pin the exact logged KV allocation on a subsequent boot using the spelling accepted by the pinned image.
5. Re-profile whenever the model revision, vLLM image, backends, speculative configuration, compilation settings, or co-resident processes change.

The preliminary planning calculation used the old 58.52 GiB pool and predicted that 16 GiB would hold approximately:

```text
4,838,587 × (16 / 58.52) ≈ 1,323,000 KV tokens
1,323,000 / 262,144 ≈ 5.04 full-length contexts
```

That was too little operational margin for a five-context production target. The implemented 18 GiB pool replaced the estimate and produced 1,588,632 aligned tokens, or 6.06 complete 262K contexts, in the live engine.

The latest reference calls the engine argument `--kv-cache-memory-bytes`, while some current startup text shortens it to `--kv-cache-memory`. The deployed image's `vllm serve --help` is authoritative. Do not add both.

## Preserving 262,144 Context While Reducing Memory

`--max-model-len 262144` is the maximum prompt-plus-output length of one request. It does not mean vLLM allocates five independent full caches merely because `--max-num-seqs 5` is present. vLLM allocates one global KV pool, then reports how many full-length requests that pool can theoretically accommodate. The startup maximum-concurrency line is the relevant capacity check for this hybrid full/linear-attention architecture. [vLLM KV-cache capacity source](https://docs.vllm.ai/en/stable/api/vllm/v1/core/kv_cache_utils/)

The three scheduler controls have different jobs:

| Control | What it limits | Recommended starting value | Trade-off |
|---|---|---:|---|
| `max_model_len` | Tokens in one request | 262,144 | Preserve the requested full model ceiling. |
| `max_num_seqs` | Sequences processed in one iteration | 5 | Matches the requested five active contexts while keeping graph capture below the old eight-sequence profile. |
| `max_num_batched_tokens` | Tokens processed in one scheduler iteration | 8,192 | A 262K prefill is split across iterations by chunked prefill; the context limit remains 262K. |

vLLM documents that smaller batched-token budgets generally improve inter-token latency, while larger budgets improve time-to-first-token and prefill throughput. With chunked prefill enabled, a long prompt that does not fit in 8,192 tokens is automatically divided into chunks. Without chunked prefill, a batched-token budget below the maximum model length is invalid. [vLLM chunked-prefill tuning](https://docs.vllm.ai/en/latest/configuration/optimization/#performance-tuning-with-chunked-prefill), [vLLM scheduler arguments](https://docs.vllm.ai/en/latest/configuration/engine_args/#--max-num-batched-tokens)

For a mostly single-user Hermes workload, a later lower-sequence experiment may release a little graph/runtime headroom, but it would no longer satisfy the requested five-context scheduling target. Keep five unless a separate low-concurrency profile is intentionally introduced.

## What changes if the ceiling is restored to 262,144?

NVIDIA's official recipe already answers the capacity question for the exact checkpoint: it uses `--max-model-len 262144`, FP8 KV, utilization 0.4, four sequences, 8,192 batched tokens, chunked prefill, asynchronous scheduling, prefix caching, MTP with three speculative tokens, and `fastsafetensors`. In other words, 262K is not an unsupported stretch on Spark; it is the published model-card configuration. [NVIDIA Qwen3.6 NVFP4 Spark command](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4)

For the current custom/Unsloth image, keep the already proven attention, linear, MoE, reasoning-parser, and tool-parser choices during a context-only experiment. Do not copy NVIDIA's parser/backend block piecemeal into a different conversion merely because the memory flags are transferable.

### Does 18 GiB fit five 262K sessions?

Before implementation, linear scaling predicted about 1.49 million KV tokens in 18 GiB. The actual aligned allocation was better:

```text
1,588,632 / 262,144 = 6.06 full-length contexts
```

The pool therefore satisfies five maximum-length sessions without relying on the scheduler limit as a proxy. `max_num_seqs=5` allows five sequences to be scheduled, while the global cache retains approximately one full-context equivalent of alignment/operational margin.

### Performance effects

Raising `max_model_len` from 131,072 to 262,144 changes the **allowed ceiling**, not the length of every request. A 4K or 32K prompt still prefills and decodes at its actual length. With an explicit 18 GiB pool, the server reserves the same KV bytes regardless of how short an individual request is.

Requests that actually use the extra context do cost more:

| Metric | Expected 262K effect |
|---|---|
| Time to first token | A full 262K prefill has about twice as many input tokens as a full 131K prefill, so TTFT rises substantially. With an 8,192-token budget, the scheduler processes roughly 32 chunks rather than 16. |
| Inter-token latency / decode tok/s | Decode at a genuinely longer active context can slow because attention/state work and memory traffic grow with retained context. The exact hybrid-attention effect must be measured. |
| Short-prompt decode tok/s | The higher configured ceiling alone should not lower it materially; actual active context and batching matter. |
| Full-length concurrency | The measured 18 GiB pool holds 6.06 complete 262K contexts; the scheduler admits at most five sequences per iteration. |
| Aggregate throughput | Five simultaneous very-long sessions create more KV pressure and bandwidth work than five short sessions; capacity does not imply unchanged latency. |
| Prefix-cache benefit | Reused long prefixes can avoid repeated prefill work after the first request, but prefix caching does not make the initial 262K prefill free. |

Chunked prefill is what lets `max_num_batched_tokens=8192` coexist with a 262K request. vLLM schedules the long prefill across iterations and prioritizes decode work; increasing the token budget can improve TTFT at the cost of more peak work and potentially worse inter-token latency, while lowering it does the reverse. Keep 8,192 for the NVIDIA-aligned baseline before experimenting. [vLLM chunked-prefill tuning](https://docs.vllm.ai/en/latest/configuration/optimization/#performance-tuning-with-chunked-prefill)

### Applied 262K profile

```text
--max-model-len 262144
--gpu-memory-utilization 0.72
--kv-cache-memory-bytes 18G
--max-num-seqs 5
--max-num-batched-tokens 8192
--enable-chunked-prefill
--kv-cache-dtype fp8
```

The profile passed identity, forced structured tool call, 6.06 startup concurrency, a real 260,016-token request, and a post-restart Hermes request. The 260K request took 139.326 seconds end-to-end. A separate short 94-completion-token probe measured 57.06 end-to-end completion tokens/second, but it used a different prompt/output shape from the earlier 76.55 measurement and is not a controlled regression comparison.

## CUDA graphs: reduce the capture envelope, do not disable the fast path first

`--enforce-eager` disables CUDA graphs and always executes eager PyTorch. vLLM explicitly presents it as the fastest-starting option with lower steady-state decode performance. That conflicts with the requirement to preserve comparable serving performance, so it is useful as a diagnostic baseline, not as the production recommendation. [vLLM eager-mode argument](https://docs.vllm.ai/en/latest/configuration/engine_args/#--enforce-eager), [vLLM startup optimization](https://docs.vllm.ai/en/latest/configuration/optimization/#faster-startup)

Current vLLM can instead bound or explicitly list the captured graph sizes through compilation configuration. More/larger graph sizes add startup work and resident graph memory; smaller bounds reduce both but can introduce padding or eager fallback for shapes outside the captured set. The current automatic maximum depends on `max_num_seqs`, speculative tokens, and the token budget. Reducing sequences from 8 to 4 therefore narrows graph capture automatically. [vLLM compilation arguments](https://docs.vllm.ai/en/latest/configuration/engine_args/#compilationconfig), [vLLM CUDA-graph size selection](https://docs.vllm.ai/en/latest/api/vllm/config/vllm/)

Keep CUDA graphs enabled and let the five-sequence production profile infer its capture sizes. If logs show graph capture is a material boot or memory cost, test `--max-cudagraph-capture-size` at the inferred model-specific maximum rather than jumping directly to eager mode. NVIDIA's current Qwen recipe specifically advises reducing this bound if a CUDA-graph/Mamba-cache-size error occurs. [vLLM Qwen3.6 recipe troubleshooting](https://recipes.vllm.ai/Qwen/Qwen3.6-35B-A3B?features=tool_calling%2Creasoning&hardware=dgx_spark_gb10)

Version caution: current upstream vLLM supports `-cc.cudagraph_capture_sizes` and `-cc.max_cudagraph_capture_size`, while pinned or NVIDIA-custom images may expose different CLI spellings. Verify rather than copying a latest-doc flag into an older image.

## What can actually shorten startup

The cold-start path contains several distinct phases:

| Phase | Can persistence remove it? | Practical control |
|---|---|---|
| Download model shards | Yes, after the first download | Keep the Hugging Face cache mounted. |
| Read and construct weights | No | Keep the checkpoint on fast local NVMe; `fastsafetensors` can improve loading when supported. |
| Profile peak runtime memory | Yes, after a stable measured boot | Pin the logged KV-cache byte allocation. |
| Allocate the KV pool | No | A smaller validated pool allocates less, but it still must be created. |
| Compile/tune kernels | Partly | Persist `VLLM_CACHE_ROOT`; identical model/config/runtime/GPU can reuse artifacts. |
| Warm-up and CUDA-graph capture | No documented persistent graph object | Keep graph sizes bounded; every non-eager process start still captures graphs. |
| API health readiness | No | Do not route Hermes traffic until the health endpoint answers. |

vLLM stores `torch.compile` artifacts under `VLLM_CACHE_ROOT`, which defaults to `~/.cache/vllm`. Cache validity depends on the model/configuration, relevant environment, Torch build, vLLM code, and GPU. The documented Compose already mounts this cache, so keep that mount stable and separate from the Hugging Face model cache. [vLLM compile-cache persistence](https://docs.vllm.ai/en/latest/deployment/docker/#persist-the-compile-cache-across-containers), [vLLM `torch.compile` cache design](https://docs.vllm.ai/en/v0.19.1/design/torch_compile/)

Persisting the Hugging Face and compile caches does **not** keep a ready model resident after its process exits. It prevents re-download and may avoid recompilation, but tens of gigabytes of weights still have to be read and loaded. CUDA graph objects are not documented as reusable across process restarts.

The live timings show that weight loading is about 154 of 234 seconds, so it is the first startup phase worth A/B testing after the memory change. The installed image can import InstantTensor, and current vLLM documents `--load-format instanttensor` as a CUDA Safetensors loader using pipelined prefetching and direct I/O. Test it as a separate one-variable experiment against the currently validated loader, using identical model/cache state and at least three warm starts. Do not assume H200 benchmark speedups transfer to GB10 or to this ModelOpt checkpoint. [vLLM InstantTensor loader](https://docs.vllm.ai/en/v0.21.0/models/extensions/instanttensor/), [vLLM startup benchmark CLI](https://docs.vllm.ai/en/latest/cli/bench/startup/)

Current vLLM also exposes optimization levels from `-O0` through `-O3`: `-O0` starts fastest with no optimization; `-O1` uses faster compilation and piecewise graphs; `-O2` is the default, with additional compilation and full-plus-piecewise graphs. Changing from the current/default optimized path to `-O0` or eager mode should be considered a measured performance trade, not a free startup improvement. [vLLM optimization levels](https://docs.vllm.ai/en/latest/configuration/optimization/#optimization-levels)

## Sleep and offload on Spark unified memory

vLLM sleep mode has two relevant levels:

- Level 1 backs model weights up in CPU memory and discards the KV cache.
- Level 2 discards both model weights and the KV cache; waking requires weight reload before serving.

Online sleep endpoints require `VLLM_SERVER_DEV_MODE=1` plus `--enable-sleep-mode`, and vLLM warns that the development endpoints must not be exposed to users. [vLLM sleep mode](https://docs.vllm.ai/en/latest/features/sleep_mode/)

Level 1 is not a capacity solution for co-resident LM Studio on DGX Spark. The CPU backup and the GPU-visible allocation draw from the same physical 128 GB LPDDR5X pool. Level 1 can free CUDA allocator address space and discard KV, but the backed-up weights still occupy unified system memory. This is an inference from vLLM's documented CPU backup behavior and NVIDIA's unified-memory architecture. It may help an allocator-level workflow, but it does not create a second independent RAM pool.

Level 2 genuinely discards the weights and KV allocation, but that is no longer simultaneous residency and it pays the weight-reload cost. For a normal inference service, stopping the vLLM container is simpler and safer than exposing development sleep endpoints unless a private orchestrator has a measured reason to keep the process shell alive.

`--cpu-offload-gb` is also a performance trade, not extra physical Spark capacity. vLLM fetches offloaded parameters on every forward pass through Unified Virtual Addressing and requires a fast CPU-GPU path. On Spark, those bytes remain in the same LPDDR5X pool and add memory traffic to an already shared fabric. Similarly, KV offload changes placement and access behavior but does not manufacture more physical memory. Do not use weight or KV offload if the goal is comparable single-model speed unless a benchmark proves the trade acceptable. [vLLM weight-offload arguments](https://docs.vllm.ai/en/latest/configuration/engine_args/#--cpu-offload-gb), [vLLM KV-offload arguments](https://docs.vllm.ai/en/latest/configuration/engine_args/#--kv-offloading-size)

## Can Qwen vLLM and Nemotron LM Studio remain loaded together?

### Capacity answer

**Capacity is plausible with the implemented explicit 18 GiB KV pool, but simultaneous generation has not been adopted as the safe default.**

The capacity case is favorable but incomplete:

- Spark provides one 128 GB unified pool.
- NVIDIA's exact Qwen checkpoint is officially served at a nominal 51.2 GB executor envelope, even at 262K context.
- The implemented profile reduces the measured Qwen weight-plus-KV subtotal from 83.36 GiB to about **42.84 GiB** before activations, graphs, and process overhead.
- LM Studio's Nemotron 3.5 Lightning `Q4_K_M` artifact is roughly 24.5 GB before its context and runtime allocations. [LM Studio Nemotron 3.5 Lightning catalog](https://lmstudio.ai/models/nvidia/nemotron-3.5-lightning), [LM Studio Community GGUF repository](https://huggingface.co/lmstudio-community/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF)
- Live co-residency measured about 48.2 GiB of GPU allocation for Qwen and 24.1 GiB for LM Studio. Total Linux memory use was about 87 GiB with about 34 GiB still available after both APIs were exercised.

LM Studio provides the right preflight tool: `lms load --estimate-only <model-key> --context-length 131072 --gpu max` estimates GPU and total memory without loading the model and accounts for context length and Flash Attention. Run it on the Spark with the exact downloaded variant, and repeat at `--context-length 262144` if both engines must expose the higher ceiling. [LM Studio `lms load` reference](https://lmstudio.ai/docs/cli/local-models/load)

### Performance answer

**Do not promise comparable performance while both models generate simultaneously.** Capacity and bandwidth are separate constraints. Both engines share the same GB10 compute resources and the same 273 GB/s LPDDR5X fabric. Neither NVIDIA nor LM Studio publishes a first-party benchmark for this exact co-resident pair. A serial routing policy—both loaded, only one heavy request active at a time—has the best chance of preserving warm-switch convenience and near-single-model latency. Concurrent generation must be measured and should be expected to reduce throughput or increase latency.

LM Studio's JIT, idle TTL, and Auto-Evict can also provide safer model switching. JIT loads a model on first request; the default idle TTL for JIT-loaded models is 60 minutes; Auto-Evict keeps only the most recently JIT-loaded model. For deliberate co-residency, disable Auto-Evict only after the estimator and live memory tests pass. A manually loaded model can instead receive an explicit TTL. [LM Studio JIT headless behavior](https://lmstudio.ai/docs/developer/core/headless), [LM Studio TTL and Auto-Evict](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict)

## Applied configuration and remaining trials

Preserve the validated model ID, revision, network, caches, reasoning/tool parsers, and backends.

### Trial A: official auto-profiled control

Use this as the source-backed rollback/control profile:

```text
--max-model-len 131072
--gpu-memory-utilization 0.4
--max-num-seqs 4
--max-num-batched-tokens 8192
--enable-chunked-prefill
--kv-cache-dtype fp8
```

Keep asynchronous scheduling, the currently working attention/MoE/linear backend choices, and MTP during this first comparison so memory controls are the only major variable. If moving from a community conversion to NVIDIA's exact checkpoint and vLLM 0.24-or-newer recipe, use NVIDIA's full model-specific backend, parser, load-format, and MTP block as one separately benchmarked migration rather than mixing individual flags between the two profiles. [NVIDIA model-card Spark command](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4), [vLLM recipe](https://recipes.vllm.ai/Qwen/Qwen3.6-35B-A3B?features=tool_calling%2Creasoning&hardware=dgx_spark_gb10)

### Production profile

The installed profile is:

```text
--max-model-len 262144
--gpu-memory-utilization 0.72
--kv-cache-memory-bytes 18G
--max-num-seqs 5
--max-num-batched-tokens 8192
--enable-chunked-prefill
--kv-cache-dtype fp8
```

The direct KV saving versus the old 58.52 GiB reservation is 40.52 GiB. The 0.72 value remains only because this image uses it for startup admission; the 18 GiB value controls KV sizing.

### Trial C: weight-loader A/B

Only after Trial B passes identity, 131K, tool-use, and performance checks, compare the existing loader with:

```text
--load-format instanttensor
```

Keep every other flag and cache state identical. The installed import proves availability, not compatibility or a speedup for this exact checkpoint. If it fails or regresses, revert only the loader flag.

## Acceptance test before calling co-residency successful

Record results for both the current profile and the proposed profile:

| Test | Pass condition |
|---|---|
| Cold start | Health becomes ready; no OOM, cache-size, or graph-capture error. |
| Warm restart | Reuses compile cache; compare time to health against cold start. |
| 131K admission | Startup reports at least 1.0 full-length concurrency and a real long-context request completes. |
| Single-request decode | Tokens/second and p95 inter-token latency remain within the agreed tolerance of the current profile. |
| Long-prompt prefill | Measure time to first token with 8,192 versus 16,384 batched tokens. |
| Two-client load | No repeated preemption; decide whether four sequences are sufficient. |
| LM Studio estimate | Exact Nemotron Q4_K_M at 131K fits while leaving at least a deliberate OS/runtime safety margin. |
| Serial co-residency | Qwen then Nemotron then Qwen each answer without unloading or OOM. |
| Concurrent co-residency | Measure both; do not infer unchanged performance from successful allocation. |
| Identity/tool use | Each endpoint reports the intended model and completes Hermes tool calls correctly. |

vLLM warns that insufficient KV space causes preemption and recomputation, which harms latency. Its own mitigations include reducing maximum sequences or batched tokens, or increasing available KV memory. The goal is not the smallest cache that boots; it is the smallest cache that admits the required 131K workload without recurring preemption. [vLLM preemption guidance](https://docs.vllm.ai/en/latest/configuration/optimization/#preemption)

## Decision

Adopt five sequences and an 8,192-token chunked-prefill budget at 262,144 with the verified **18 GiB explicit KV pool**. Keep the image-specific 0.72 preflight value. Do not use eager mode, CPU offload, KV offload, or level-1 sleep as the primary solution. Persist both model and compile caches.

KV pinning saved 40.52 GiB of resident cache but did not eliminate the dominant weight-load phase: the verified cold configuration load used 147.17 seconds for model loading, while the later warm restart used 141.41 seconds. Engine initialization fell from 140.12 seconds on the first new compile to 36.75 seconds after compile artifacts were cached. InstantTensor remains an unperformed one-variable A/B trial.

If LM Studio's exact 131K estimate plus measured Qwen resident use retains a healthy system margin, keep both models resident but serialize heavy generation. If the margin is narrow or concurrent latency is unacceptable, use LM Studio TTL/Auto-Evict or an exclusive model lane instead of forcing two active inference engines into one shared 128 GB/273 GB/s device.

## Primary sources

- [NVIDIA Qwen3.6-35B-A3B-NVFP4 model card and Spark command](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4)
- [NVIDIA DGX Spark vLLM playbook](https://build.nvidia.com/spark/vllm/instructions)
- [NVIDIA agent-ready Spark recommendation](https://build.nvidia.com/spark/vllm/agent-ready-models)
- [vLLM Qwen3.6 DGX Spark recipe](https://recipes.vllm.ai/Qwen/Qwen3.6-35B-A3B?features=tool_calling%2Creasoning&hardware=dgx_spark_gb10)
- [NVIDIA DGX Spark hardware overview](https://docs.nvidia.com/dgx/dgx-spark/hardware.html)
- [vLLM engine arguments](https://docs.vllm.ai/en/latest/configuration/engine_args/)
- [vLLM optimization and startup tuning](https://docs.vllm.ai/en/latest/configuration/optimization/)
- [vLLM sleep mode](https://docs.vllm.ai/en/latest/features/sleep_mode/)
- [vLLM compile-cache persistence](https://docs.vllm.ai/en/latest/deployment/docker/#persist-the-compile-cache-across-containers)
- [vLLM InstantTensor loader](https://docs.vllm.ai/en/v0.21.0/models/extensions/instanttensor/)
- [vLLM startup benchmark](https://docs.vllm.ai/en/latest/cli/bench/startup/)
- [LM Studio model resource estimator](https://lmstudio.ai/docs/cli/local-models/load)
- [LM Studio JIT, TTL, and Auto-Evict](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict)
- [LM Studio Nemotron 3.5 Lightning catalog](https://lmstudio.ai/models/nvidia/nemotron-3.5-lightning)
