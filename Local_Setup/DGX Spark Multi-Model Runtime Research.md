# DGX Spark Multi-Model Runtime Research

_Primary-source review current on 2026-08-14._

## Bottom line

Nothing about the current observation proves that the 35B or 27B weights themselves occupy 120 GB. The large number is mainly a **serving allocation**: the current Qwen 27B vLLM profile tells one server instance that it may use 84% of the Spark's memory, and vLLM uses the space left after weights and runtime overhead for the KV cache. On a nominal 128 GB device, `0.84 × 128` is about 107.5 GB before other CUDA and shared-system allocations are considered. The current Qwen 35B profile similarly requests 72%, or about 92 GB.

The correct mental model is:

| State | Meaning |
|---|---|
| **Downloaded** | Weight files are stored on NVMe. They consume disk, not active model memory. |
| **Registered** | LiteLLM, Hermes, Open WebUI, or LM Studio has a name for a model or route. This does not prove that a server is running. |
| **Loaded** | A runtime has copied/mapped the weights and allocated working memory. |
| **Healthy** | The runtime has finished loading/compiling and its API answers. |
| **Selected** | A client sends its next request to that route. Selection does not start a stopped vLLM container. |

It is practical to keep **many models downloaded** on the Spark. It is not practical to keep the current full-context vLLM profiles for three or four large models loaded simultaneously. The simplest performance-first design is one large, healthy vLLM worker at a time, many stopped/downloaded profiles on disk, and one switch operation that starts the requested profile, waits for health, and only then changes the client-facing route. For the most convenient model-browser experience, Ollama or LM Studio's headless `llmster` can do just-in-time loading and idle eviction, but that convenience comes with different formats and usually a different performance path from the tuned vLLM profiles.

## Why the Spark says nearly 120 GB is in use

DGX Spark has **128 GB of LPDDR5X unified system memory**, not 128 GB of dedicated GPU VRAM plus separate host RAM. The CPU, GPU, operating system, filesystem cache, containers, model weights, activations, compiled graphs, and KV caches all draw from the same physical pool. NVIDIA specifies 273 GB/s memory bandwidth and describes support for models up to 200B parameters; “up to 200B” is a capacity statement, not a promise that several large servers can be resident together. [NVIDIA DGX Spark hardware overview](https://docs.nvidia.com/dgx/dgx-spark/hardware.html)

vLLM defines `--gpu-memory-utilization` as the per-instance fraction available to the model executor. When no explicit KV-cache byte limit is supplied, vLLM profiles the model and uses the remaining allowance to size its KV cache. Its documentation explicitly says that two vLLM instances must be assigned compatible fractions, such as 0.5 each; the fractions are per instance and are not coordinated automatically. [`gpu_memory_utilization` and `kv_cache_memory_bytes`](https://docs.vllm.ai/en/latest/api/vllm/config/)

The two local profiles currently request:

| Profile | Current limit | Approximate nominal allowance | Other important setting |
|---|---:|---:|---|
| `spark-fast` / Qwen 35B A3B | `0.72` | 92.2 GB | 131,072 context, eight sequences, FP8 KV cache |
| `qwen27-dflash` | `0.84` | 107.5 GB | 262,144 context, four sequences, BF16 KV cache, plus a 2B draft model |

NVIDIA's current Spark vLLM guide says exactly what the flags imply: larger maximum context reserves more memory for KV cache, while the utilization fraction covers both weights and KV cache. It also uses 131,072 tokens as a starting point rather than assuming every workload needs the model's advertised maximum. [NVIDIA Spark vLLM instructions](https://build.nvidia.com/spark/vllm/instructions)

Therefore, `nvidia-smi` showing roughly 120 GB while the 27B DFlash service runs is consistent with the service being configured as a near-exclusive server. It is not evidence that the quantized 27B weights alone are 120 GB.

## Why “35B at 4-bit equals about 17 GB” is incomplete

The arithmetic is a useful lower bound: 35 billion parameters multiplied by four bits is 17.5 billion bytes, about 16.3 GiB. It is not the memory budget of a running service.

The real checkpoint and runtime also include some combination of:

- tensors that are not stored at four bits, such as embeddings, normalization layers, scales, metadata, vision components, or output layers;
- an MTP or DFlash draft component;
- KV cache for every active request and token;
- temporary activations and workspaces;
- CUDA graphs and compiled kernels;
- allocator fragmentation and process overhead.

NVIDIA's Qwen 27B card is explicit that only weights and activations of linear operators inside transformer blocks are NVFP4; it reports an approximately 2.5× reduction versus the 16-bit checkpoint, not a universal 4× reduction for every byte. [NVIDIA Qwen3.6 27B NVFP4 model card](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4)

The exact current 35B checkpoint has 35B total parameters, about 3B active per generated token, an MTP module, a vision encoder, and a native 262,144-token context. Its repository is about **26.5 GB**, and its publisher says the NVFP4 checkpoint works on a **32 GB** GPU—not that every full-context server fits comfortably in 24 GB. [Unsloth Qwen3.6 35B A3B NVFP4 files](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-NVFP4/tree/main) and [model card](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-NVFP4)

For comparison, the official Ollama registry lists its ordinary Qwen 3.6 35B A3B package at 24 GB and a separately tagged NVFP4 package at 22 GB. Those are stored model packages, not the complete live memory requirement at 256K context. [Ollama Qwen3.6 tags](https://ollama.com/library/qwen3.6/tags)

## Why vLLM switching takes time

Each current vLLM container is a complete, single-model server. A switch currently does all of the following:

1. drains or kills the old server;
2. releases its large memory allocation;
3. starts a different container image and Python runtime;
4. reads tens of gigabytes of model shards from NVMe into unified memory;
5. constructs the model and draft model;
6. profiles available memory and allocates KV cache;
7. compiles kernels, captures CUDA graphs, and performs warm-up work;
8. finally opens the health and OpenAI-compatible endpoints.

NVIDIA warns that model loading can take several minutes and uses a 900-second health wait in its Spark guide. [NVIDIA Spark vLLM startup guidance](https://build.nvidia.com/spark/vllm/instructions)

vLLM separately documents cold and warm startup as including model loading, compilation, and cache operations. It can reuse compilation artifacts from `VLLM_CACHE_ROOT`; changing the model, flags, runtime build, environment, or GPU can invalidate those artifacts. [vLLM startup benchmark](https://docs.vllm.ai/en/latest/api/vllm/benchmarks/startup/) and [vLLM startup tuning](https://docs.vllm.ai/en/latest/configuration/optimization/)

There is also a local avoidable cost: the Qwen 35B Compose profile persists `/root/.cache/vllm`, while the current Qwen 27B Compose profile persists its Triton cache but not vLLM's normal compile-cache root. Removing and recreating that Qwen 27B container can therefore behave more like a cold vLLM start. This should be corrected when the switching workflow is implemented; it does not require redownloading the model.

## Can Hermes simply select either current entry?

Only when the selected backend is already healthy.

Hermes sees `spark-fast` and `qwen27-dflash` because LiteLLM has two statically registered model names. That list is a routing catalog, not a live GPU-residency display. With the current mutually exclusive container profiles:

- selecting the running entry works;
- selecting the stopped entry produces a connection error;
- selecting an entry does not invoke `docker compose up`;
- starting a different model should not redirect traffic until its health check succeeds.

This explains the earlier one-time LiteLLM HTTP 500: LiteLLM knew the model-group name, but its upstream was temporarily unreachable. A clean switch needs an orchestrator or script around the existing containers; a dropdown alone cannot make a stopped vLLM server appear instantly.

## Why use vLLM at all?

vLLM is not the model. It is the inference server chosen for the exact optimized checkpoint.

For these Spark profiles it provides:

- native or model-specific NVFP4 paths on Blackwell;
- continuous batching for several clients;
- large, explicitly managed KV caches;
- OpenAI-compatible serving;
- reasoning and tool-call parsers used by Hermes;
- MTP and DFlash speculative decoding;
- model-specific attention, MoE, and linear backends.

NVIDIA describes its Spark vLLM playbook as high-throughput serving with continuous batching and an OpenAI-compatible API, and directs special architectures such as Gemma 4 and Nemotron Omni to model-specific images or cards. [NVIDIA Spark vLLM playbook](https://build.nvidia.com/spark/vllm/instructions)

The Qwen 27B DFlash profile is especially tied to vLLM: the 2B DFlash card documents a target Qwen 27B server plus a separate DFlash speculative draft and currently references specific upstream framework support. [Qwen3.6 27B DFlash model card](https://huggingface.co/z-lab/Qwen3.6-27B-DFlash)

## Ollama: the easiest automatic shelf, with tradeoffs

Ollama is fully supported on DGX Spark. Its hardware page lists GB10 compute capability 12.1, its Linux installer supports ARM64, and NVIDIA publishes Spark playbooks that install Ollama and detect the Blackwell GPU. [Ollama hardware support](https://docs.ollama.com/gpu), [Ollama ARM64 installation](https://docs.ollama.com/linux), and [NVIDIA's Spark Ollama example](https://build.nvidia.com/spark/live-vlm-webui/instructions)

Ollama behaves much closer to the desired “download many, click one” experience:

- models remain stored on disk;
- a request loads the requested model;
- models stay loaded for five minutes by default;
- `keep_alive` can keep or immediately unload a model;
- if memory is insufficient for the next model, Ollama queues requests and unloads idle models to make room.

These are documented behaviors, including simultaneous model loading only when sufficient memory remains. [Ollama FAQ: model lifetime and concurrency](https://docs.ollama.com/faq)

The current official Ollama catalog includes Qwen 3.6 27B, Qwen 3.6 35B A3B, Gemma 4 26B A4B, Gemma 4 31B, and the multimodal Nemotron 3 Nano Omni as `nemotron3:33b`. [Qwen3.6 catalog](https://ollama.com/library/qwen3.6), [Gemma 4 catalog](https://ollama.com/library/gemma4), and [Nemotron 3 Nano Omni catalog](https://ollama.com/library/nemotron3)

Important limitations for this deployment:

- An Ollama tag is not automatically the same bytes, quantizer, chat template, or kernel path as the current Hugging Face/vLLM checkpoint.
- The exact Qwen 27B + separate DFlash profile is a vLLM/SGLang design, not the ordinary Ollama Qwen 27B package.
- Pulling a second Ollama version usually creates another model store rather than reusing the Hugging Face cache.
- Ollama makes lifecycle management simpler; it does not make a 20–30 GB model load instant.

Ollama is therefore a good **convenience-first alternative** for browsing and comparing standard catalog builds. It should not silently replace the tuned vLLM endpoint until Hermes tool calls, context behavior, quality, and throughput are compared on the exact Ollama tag.

## LM Studio and LM Link: the easiest Windows-controlled shelf

LM Studio's server-native `llmster` is also officially supported on DGX Spark. NVIDIA's playbook shows a headless Spark server, remote API access, and optional LM Link; the Spark appears in LM Studio on the laptop and remote models can be loaded with the desktop controls. [NVIDIA LM Studio on DGX Spark playbook](https://build.nvidia.com/spark/lm-studio/instructions)

LM Studio's current headless server supports:

- just-in-time loading when a request names a downloaded model;
- automatic unloading after an idle TTL;
- an option to keep only the last JIT-loaded model;
- native REST endpoints to list, download, load, and unload models;
- an OpenAI-compatible API;
- a headless Linux service.

[LM Studio headless/JIT documentation](https://lmstudio.ai/docs/developer/core/headless), [server settings](https://lmstudio.ai/docs/developer/core/server/settings), and [model-management REST API](https://lmstudio.ai/docs/developer/rest)

LM Link is the official way for the Windows LM Studio desktop to treat the Spark's `llmster` models as remote models. It is currently Preview and uses its own encrypted Tailscale-based link. [LM Studio Add a Device](https://lmstudio.ai/docs/lmlink/basics/add-device)

LM Studio Desktop should not be assumed to be a generic graphical client for the existing vLLM containers. Its documented remote-device workflow is LM Link to another LM Studio/`llmster` instance. A normal OpenAI-compatible client can call vLLM, but that is a different feature.

As with Ollama, LM Studio maintains `~/.lmstudio/models`, separate from the Hugging Face cache. Use it if Windows-controlled loading is the priority; do not install the same experimental shelf in LM Studio and Ollama unless duplicate disk use is intentional.

## Open WebUI is a frontend, not the model host

Open WebUI normally proxies requests to an upstream provider such as Ollama or an OpenAI-compatible API. It can connect to vLLM through LiteLLM, to Ollama, or to an LM Studio server; it does not remove the backend's load time or memory requirements. [Open WebUI direct-connection architecture](https://docs.openwebui.com/features/chat-conversations/direct-connections/) and [Open WebUI with LM Studio](https://docs.openwebui.com/alternatives/lm-studio/)

The bundled `open-webui:ollama` image is a special case because it includes an Ollama model host. Running that in addition to a host-level Ollama, LM Studio, and vLLM would create overlapping runtimes and stores. One Open WebUI instance should be the client of the deliberately chosen runtime or gateway.

## Can three or four models stay loaded?

Three different answers are often being mixed together:

1. **Stored on disk:** yes, limited by NVMe capacity.
2. **Visible in menus:** yes, a catalog can list stopped or JIT-loadable models.
3. **Resident and immediately ready:** not with the present high-context vLLM settings.

The approximate package sizes make the distinction clear:

| Candidate | Published identity or package fact | Operational implication |
|---|---|---|
| Current Qwen 35B A3B NVFP4 | 35B total / 3B active; about 26.5 GB of repository files | Weight/package size is not the current 92 GB vLLM allowance. |
| Qwen 27B NVFP4 + DFlash | About 21.9 GB target repository plus a 3.46 GB, 2B-parameter BF16 draft | The current 262K/BF16-KV profile is configured as a near-exclusive server. |
| Nemotron 3 Nano Omni NVFP4 | 31B total / ~3B active, 21 GB published precision size | Fits easily by itself; KV/media processing still need headroom. |
| Gemma 4 26B A4B | 25.2B total / 3.8B active; Ollama package is 18 GB | Better Spark resident candidate than dense 31B, but a separate runtime profile still adds cache and overhead. |
| Gemma 4 31B | 30.7B dense; Ollama package is 20 GB | File size fits; all dense weights are active during decode and it still needs working/KV memory. |

Nemotron's NVIDIA card supplies the strongest exact size statement: BF16 62 GB, FP8 33 GB, and NVFP4 21 GB, with 256K context and explicit Spark support. [NVIDIA Nemotron 3 Nano Omni NVFP4 model card](https://huggingface.co/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4)

Gemma 4 26B A4B is 25.2B total with 3.8B active and supports 256K context; NVIDIA's NVFP4 card currently documents vLLM and Gemma-specific reasoning/tool parsers. [NVIDIA Gemma 4 26B A4B NVFP4 model card](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)

Keeping two or three quantized weight sets resident might be technically possible only after shrinking contexts, sequences, and explicit KV allocations so the **sum** of weights, draft models, graphs, workspaces, KV caches, OS use, and safety headroom fits below the shared 128 GB. That is a benchmark experiment, not a reliable 24×7 baseline. It also makes the models contend for the same 273 GB/s memory bandwidth. The current 0.72 and 0.84 vLLM instances must not be run together.

The current high allocation is a configuration choice, not an unavoidable consequence of “35B.” NVIDIA's first-party Spark recipe for its own Qwen 35B NVFP4 checkpoint uses `--gpu-memory-utilization 0.4`, FP8 KV, four sequences, and 262K maximum context. That is not a drop-in prescription for the different Unsloth/Mia runtime, but it establishes that the present 0.72–0.84 values should be tuned to measured concurrency rather than treated as fixed model requirements. [NVIDIA Qwen3.6 35B A3B NVFP4 Spark recipe](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4)

## Recommended architecture

### Performance-first baseline — recommended for Hermes

```text
Desktop / Laptop / Telegram / Open WebUI
                    |
          Hermes + authenticated gateway
                    |
             LiteLLM / stable route
                    |
        one healthy large runtime at a time
          /          |             \
  Qwen 35 vLLM  Qwen 27 DFlash  Nemotron/Gemma vLLM
       active        stopped          stopped
                    |
        shared NVMe model shelf and persistent compile caches
```

Use these rules:

1. Keep `spark-fast` as the durable 24×7 route to the proven Qwen 35B profile.
2. Keep descriptive profile names such as `qwen27-dflash`, `nemotron-omni`, and `gemma4-26b-a4b` for inventory and testing.
3. Treat only one large vLLM profile as active unless a measured memory plan proves otherwise.
4. Add a single switch command that stops the old worker, waits for memory release, starts the requested worker, waits for `/health`, runs an identity/tool smoke test, and then changes the stable route.
5. Persist both the Hugging Face model cache and the runtime-specific vLLM/Triton compile caches.
6. Start everyday profiles at 64K or 128K context rather than 256K unless a real workload needs the maximum.
7. Display the active checkpoint separately from the stable route name so `spark-fast` never hides model identity.
8. Keep raw model ports private; remote clients should use the authenticated gateway over the existing private network.

This design makes switching **safe and understandable**. It cannot eliminate the physical model-load delay.

### Convenience-first alternative

If the main goal is manually browsing many models rather than maximum DFlash/MTP/vLLM performance, choose **one**, not both:

- **Ollama:** best simple headless API and automatic load/idle-evict behavior for Hermes/Open WebUI.
- **LM Studio `llmster` + LM Link:** best if the Windows LM Studio interface should browse and remotely load Spark models.

Configure JIT loading with “only keep the last model” or a short idle TTL. Download standard Qwen, Gemma, and Nemotron catalog builds there, but keep them as a separate evaluation lane. Do not run its large model at the same time as the current near-exclusive vLLM worker.

## Model order for the requested tests

1. Keep the current Qwen 35B A3B vLLM endpoint as the agent/tool baseline.
2. Finish the Qwen 27B DFlash test as a vLLM-specific speed/quality comparison; do not use its 262K/BF16-KV profile as a second permanent resident.
3. Test `nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4` on demand for document, image, audio, and video work.
4. Test `nvidia/Gemma-4-26B-A4B-NVFP4` before dense Gemma 4 31B because the 26B MoE activates about 3.8B parameters per token and is the more natural Spark throughput candidate.
5. Test Gemma 4 31B only as a dense quality comparison or through an Ollama/LM Studio convenience build.

The existing notes reference **Nemotron 3 Nano Omni**, not a model named “Nemotron 3.5.” This may be a mix-up with Qwen 3.5. Confirm the exact model ID before downloading anything.

## Primary sources

- [NVIDIA DGX Spark hardware overview](https://docs.nvidia.com/dgx/dgx-spark/hardware.html)
- [NVIDIA Serve LLMs with vLLM on Spark](https://build.nvidia.com/spark/vllm/instructions)
- [NVIDIA LM Studio on Spark](https://build.nvidia.com/spark/lm-studio/instructions)
- [NVIDIA Open WebUI with Ollama on Spark](https://build.nvidia.com/spark/open-webui)
- [vLLM memory configuration](https://docs.vllm.ai/en/latest/api/vllm/config/)
- [vLLM optimization and startup](https://docs.vllm.ai/en/latest/configuration/optimization/)
- [Ollama FAQ](https://docs.ollama.com/faq)
- [Ollama Qwen3.6 catalog](https://ollama.com/library/qwen3.6)
- [Ollama Gemma 4 catalog](https://ollama.com/library/gemma4)
- [Ollama Nemotron 3 Nano Omni catalog](https://ollama.com/library/nemotron3)
- [LM Studio headless server](https://lmstudio.ai/docs/developer/core/headless)
- [LM Studio LM Link device setup](https://lmstudio.ai/docs/lmlink/basics/add-device)
- [Open WebUI connection architecture](https://docs.openwebui.com/features/chat-conversations/direct-connections/)
- [Unsloth Qwen3.6 35B A3B NVFP4 card](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-NVFP4)
- [NVIDIA Qwen3.6 27B NVFP4 card](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4)
- [DFlash Qwen3.6 27B draft card](https://huggingface.co/z-lab/Qwen3.6-27B-DFlash)
- [NVIDIA Nemotron 3 Nano Omni NVFP4 card](https://huggingface.co/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4)
- [NVIDIA Gemma 4 26B A4B NVFP4 card](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)
- [NVIDIA Gemma 4 31B IT NVFP4 card](https://huggingface.co/nvidia/Gemma-4-31B-IT-NVFP4)

## Related notes

- [[DGX Spark Operations Setup Guide]]
- [[DGX Spark Model Installation And Switching Guide]]
- [[DGX Spark Aug 2026 Model Deployment Research]]
- [[DGX Spark ODS Playbook and Model Roadmap]]
- [[DGX Spark Current Models Report]]
