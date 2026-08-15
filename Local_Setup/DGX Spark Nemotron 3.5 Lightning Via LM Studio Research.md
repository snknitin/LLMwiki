# DGX Spark Nemotron 3.5 Lightning Via LM Studio Research

Checked: 2026-08-15

## Decision

**Yes, Nemotron 3.5 Lightning can run through LM Studio on the DGX Spark.** LM Studio officially supports the Spark's Linux ARM64 platform and CUDA 13 runtime, and its catalog now has an exact `nvidia/nemotron-3.5-lightning` entry backed by LM Studio's own GGUF conversions.

**Do not make this the primary Hermes or always-on deployment.** Keep the planned NVIDIA NVFP4 + DSpark vLLM recipe as the canonical Spark server. Use the LM Studio edition as a convenient LM Link lab copy for manual testing, comparisons, and desktop-controlled loading.

The two paths run different files and do not have the same acceleration features.

## What each path runs

| Path | Model files | Spark optimization | Best use |
| --- | --- | --- | --- |
| NVIDIA vLLM recipe | NVIDIA's original `NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4` safetensors plus the separate NVFP4 DSpark draft checkpoint | NVIDIA explicitly recommends DSpark speculative decoding for DGX Spark and low-concurrency interactive serving | Hermes, agents, LiteLLM, and a persistent OpenAI-compatible endpoint |
| Community SGLang Spark recipe | The same NVIDIA NVFP4 main and DSpark checkpoints in a Spark-aware SGLang container | Uses SGLang's DSpark implementation and Spark-specific memory settings | Benchmarking against vLLM after the canonical deployment works |
| LM Studio catalog | GGUF converted by the LM Studio team from NVIDIA's BF16 checkpoint | Runs through LM Studio's Spark-compatible `llama.cpp` CUDA 13 runtime; the catalog entry does not provide the separate DSpark draft model | LM Link, GUI experiments, quick load/unload, and comparing GGUF quantizations |

The official NVIDIA NVFP4 repository contains Transformers configuration and 52 `.safetensors` weight shards. It is not a GGUF repository, so LM Studio does not directly load that checkpoint as its normal local-model path. LM Studio instead points to `lmstudio-community/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF`.

## LM Studio files currently available

| Quantization | Download size | Recommendation |
| --- | ---: | --- |
| `Q4_K_M` | 22.83 GiB | Start here for the LM Studio lab copy |
| `Q6_K` | 31.21 GiB | Optional quality comparison |
| `Q8_0` | 31.28 GiB | Little storage advantage over Q6; not the first download |

LM Studio's page reports a 21 GB minimum-memory estimate. The Spark's 128 GB unified memory is sufficient, but the chosen context window, KV cache, and other running inference workers still consume the same shared memory pool.

## Exact prerequisites and limitations

- Use the Linux ARM64 LM Studio/`llmster` installation on the Spark. LM Studio's official Spark announcement says the Spark build uses a CUDA 13 `llama.cpp` runtime.
- Keep at least 30 GiB of free disk for the Q4 model plus download and runtime overhead.
- LM Studio stores this copy under its own model directory, `/home/snknitin/.lmstudio/models`. It cannot reuse the Hugging Face NVFP4 snapshot already stored for vLLM, so this is a deliberate duplicate model download.
- Start with `Q4_K_M`; do not download Q6 and Q8 until the Q4 comparison justifies the extra copies.
- Treat the 1-million-token model limit as a capability ceiling, not a default setting. Begin with 16K or 32K context and raise it only for a measured need because KV-cache memory and prompt-processing time increase with context.
- The LM Studio catalog path does not reproduce NVIDIA's documented NVFP4 + DSpark recipe. There is no DSpark companion GGUF listed in this catalog entry.
- Do not load the LM Studio GGUF while a large vLLM, SGLang, Ollama, or ODS model is resident on the Spark. Ports can coexist, but the models compete for the Spark's unified memory.
- Port `1234` is LM Studio's normal API port. The planned vLLM Nemotron service uses its own port, so keep the port names distinct rather than remapping LM Studio onto the model-server port.
- GGUF quality and speed must be benchmarked locally. The file is a quantized conversion from BF16, whereas the canonical deployment uses NVIDIA's published NVFP4 checkpoint and Spark-recommended speculative-decoding assistant.

## Safe first LM Studio trial

Only do this after stopping the currently loaded large Spark worker.

```bash
lms daemon up
lms get nvidia/nemotron-3.5-lightning@q4_k_m
lms ls
lms server start --port 1234
```

If `lms get` asks which file to use, select `Q4_K_M`. Confirm the server without loading a second inference stack:

```bash
curl http://127.0.0.1:1234/v1/models
```

From LM Studio Desktop, LM Link can then select the Spark and load this model remotely. When the test is finished, unload the model in LM Studio before restarting the canonical vLLM worker.

## Recommendation for this setup

1. Finish and verify the existing `DGX Spark Nemotron 3.5 Lightning Tutorial` first.
2. Register that vLLM endpoint behind the stable LiteLLM/Hermes alias for normal use.
3. Install the LM Studio `Q4_K_M` copy only if controlling the model through LM Link is worth approximately 23 GiB of duplicate storage.
4. Compare answer quality, time to first token, generation speed, memory use, long-context behavior, and tool calls using identical prompts.
5. Keep vLLM + DSpark unless the measured LM Studio workflow advantage outweighs its missing DSpark path.

## Primary sources

- [NVIDIA Nemotron 3.5 Lightning model and Spark deployment instructions](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4)
- [NVIDIA DSpark draft checkpoint](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DSpark)
- [NVIDIA Nemotron usage cookbooks](https://github.com/NVIDIA-NeMo/Nemotron/tree/main/usage-cookbook/Nemotron-3.5-Lightning)
- [LM Studio Nemotron 3.5 Lightning catalog entry](https://lmstudio.ai/models/nvidia/nemotron-3.5-lightning)
- [LM Studio team's Nemotron 3.5 Lightning GGUF files](https://huggingface.co/lmstudio-community/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF)
- [LM Studio DGX Spark support announcement](https://lmstudio.ai/blog/dgx-spark)
- [LM Studio Linux ARM64 system requirements](https://lmstudio.ai/docs/app/system-requirements)
- [LM Studio `lms get` documentation](https://lmstudio.ai/docs/cli/local-models/get)

## Related notes

- [[DGX Spark Nemotron 3.5 Lightning Tutorial]]
- [[DGX Spark LM Studio And LM Link Tutorial]]
- [[DGX Spark Model Installation And Switching Guide]]
- [[DGX Spark Multi-Model Runtime Research]]
