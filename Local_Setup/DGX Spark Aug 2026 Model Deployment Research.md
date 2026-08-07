---
title: DGX Spark Aug 2026 Model Deployment Research
created: 2026-08-07
updated: 2026-08-07
status: current-research
tags:
  - dgx-spark
  - inference
  - vllm
  - sglang
  - hermes
  - model-deployment
---

# DGX Spark Aug 2026 Model Deployment Research

## Scope and evidence standard

This note evaluates the named NVIDIA playbooks, four single-Spark community deployments, and the requested model families for one 128 GB DGX Spark. It answers four practical questions: what can actually be launched, what must be pinned or patched, what is appropriate for Hermes-style tool use, and what should run continuously versus only when requested.

Evidence labels used below:

- **NVIDIA-validated on Spark** means NVIDIA publishes a Spark-specific command or playbook for the exact model/runtime combination.
- **Model-vendor recipe** means the model owner publishes the command, but it may target datacenter GPUs or a different topology.
- **Community single-Spark result** means a third party reports a run on physical DGX Spark. It is useful operational evidence, not an independent benchmark or an NVIDIA support statement.
- **Inference** means a recommendation derived from memory pressure, runtime flags, security exposure, or missing evidence.

The central finding is that `nvidia/Qwen3.6-35B-A3B-NVFP4` remains the best-supported **first-party control**, but it should not currently be the default for a large-tool Hermes deployment. A specific [open NVIDIA playbook issue filed July 21, 2026](https://github.com/NVIDIA/dgx-spark-playbooks/issues/89) reports a same-box quant bisect in which the NVIDIA ModelOpt checkpoint produced malformed tool calls and `unsloth/Qwen3.6-35B-A3B-NVFP4` passed. The provisional always-on choice is therefore the Unsloth checkpoint with the MiaAI GB10 runtime, pinned and hardened, only after local acceptance tests. The other candidates remain on-demand profiles.

## Recommended operating set

| Role | Model/profile | One-Spark evidence | Hermes/tools | Recommended lifecycle |
|---|---|---|---|---|
| Default agent endpoint | `unsloth/Qwen3.6-35B-A3B-NVFP4` with the MiaAI GB10 B12X runtime | Community physical-Spark profile; current image and model must be digest/revision pinned | `qwen3_coder`; reported 5/5 in the same-box large-tool quant bisect | **Provisional 24x7 default** after hardening and local 5/5 tool tests |
| First-party Qwen control | `nvidia/Qwen3.6-35B-A3B-NVFP4` with NVIDIA's Spark vLLM recipe | NVIDIA Spark playbook; official model-card Spark command | Exact endpoint in NVIDIA's June Hermes playbook, but affected by open issue #89's reported large-tool failure | On demand until the issue is resolved or the local Hermes tool surface passes |
| Dense Qwen control | `nvidia/Qwen3.6-27B-NVFP4` using the official ModelOpt profile | Official 21.9 GB NVIDIA checkpoint and one-GPU command | Qwen3 reasoning/tool protocol; not the exact Hermes-validated profile | On demand; prefer this clean control over the Mia nightly profile |
| Multimodal specialist | `nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4` | Official model card explicitly supports DGX Spark | Model card enables `qwen3_coder`; not validated by the Hermes playbook | On demand; consider 24x7 only if multimodal work is the primary workload |
| Lightweight multimodal alternative | `nvidia/Gemma-4-26B-A4B-NVFP4` | Listed in NVIDIA's Spark vLLM support material | Gemma supports function calling, but no exact Hermes validation was found | On demand; possible secondary service after local tool tests |
| Dense quality comparison | `nvidia/Gemma-4-31B-IT-NVFP4` | Spark-specific Gemma runtime exists; its quantized card is tested on H100, not Spark | Function-calling capable; no exact Hermes validation | On demand |
| Coding/agent alternative | `poolside/Laguna-S-2.1-NVFP4` plus DFlash draft | Poolside publishes an explicit DGX Spark recipe | First-party `poolside_v1` reasoning and tool parsers | On demand; possible alternate always-on model after license and Hermes validation |
| Large MoE experiment | `nvidia/Qwen3.5-122B-A10B-NVFP4` | Model-vendor TP1 recipe, but no exact one-Spark validation found; files are about 83.5 GB | `qwen3_coder` tool parser | Experimental/on demand only |
| Very large experiment | StepFun 3.7 Flash | Official NVFP4 server recipes require TP4; single-Spark path is a very tight llama.cpp quantized build | `step3p5` parsers exist in first-party server recipe | On demand only; do not use the TP4 NVFP4 command on one Spark |
| Community dense + DFlash profile | MiaAI Qwen3.6 27B NVFP4/DFlash | Community physical-Spark claim; privileged nightly container | `qwen3_coder` plus custom template | On demand only |
| Community Ling profile | Ling 3.0 Flash INT4/SGLang | Community wrapper; authoritative public model card/source could not be verified | No clear tool-parser evidence in the reviewed launch profile | Do not make persistent; provenance gate first |
| Community DeepSeek derivative | 0xSero DeepSeek V4 Flash SparkInfer | Reproducible community physical-Spark result using a pruned 3-bpw derivative | Strict JSON tested by author, but not Hermes validated | On demand/experimental only |

## The baseline to standardize

### First-party control: NVIDIA Qwen3.6 35B A3B

The strongest first-party chain is unusually complete:

1. NVIDIA publishes the [Qwen3.6 35B A3B NVFP4 model card](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4), describing a 35B-total/3B-active multimodal MoE with a 262,144-token context and an Apache-2.0 license.
2. NVIDIA publishes an [agent-ready DGX Spark vLLM playbook](https://build.nvidia.com/spark/vllm/agent-ready-qwen35b) for that checkpoint.
3. NVIDIA's [Hermes Agent Spark playbook](https://build.nvidia.com/spark/hermes-agent/instructions) points Hermes at this exact local model ID and endpoint.

That chain establishes first-party support, but it predates the July issue #89 report. The report holds the vLLM build, template, parser, flags, request, and Spark constant while changing only the quant: NVIDIA ModelOpt scored 0/5, Qwen FP8 5/5, and Unsloth dynamic NVFP4 5/5 on the failing large-tool case. This is still an open community-submitted issue rather than an NVIDIA-confirmed root cause, so the NVIDIA profile remains the control while the Unsloth profile is the provisional operational default.

The approximately 23.5 GB checkpoint's model card Spark launch profile is:

```bash
vllm serve nvidia/Qwen3.6-35B-A3B-NVFP4 \
  --host 0.0.0.0 --port 8000 \
  --tensor-parallel-size 1 \
  --trust-remote-code \
  --kv-cache-dtype fp8 \
  --attention-backend flashinfer \
  --moe-backend marlin \
  --gpu-memory-utilization 0.4 \
  --max-model-len 262144 \
  --max-num-seqs 4 \
  --max-num-batched-tokens 8192 \
  --enable-chunked-prefill \
  --async-scheduling \
  --enable-prefix-caching \
  --speculative-config '{"method":"mtp","num_speculative_tokens":3,"moe_backend":"triton"}' \
  --load-format fastsafetensors \
  --reasoning-parser qwen3 \
  --tool-call-parser qwen3_xml \
  --enable-auto-tool-choice
```

Hermes is then configured as documented:

```bash
hermes config set model.provider custom
hermes config set model.base_url http://localhost:8000/v1
hermes config set model.default nvidia/Qwen3.6-35B-A3B-NVFP4
```

NVIDIA's Hermes instructions identify Hermes Agent v0.18.0 and upstream commit `676236bb`, and allow the context window to be detected automatically. This validates compatibility, not arbitrary exposure: the vLLM listener should be changed to `127.0.0.1` or restricted by the host firewall if only local Hermes uses it.

The checkpoint itself is mixed, not universally FP4. NVIDIA says only eligible MoE linear operators were quantized and reports about 3.06x model-memory reduction; the repository still contains BF16, FP8, and packed quantized tensors. That distinction matters when interpreting runtime-backend claims.

### Container and cache policy for the baseline

The Spark playbook uses a vLLM OpenAI container and the usual host Hugging Face cache mount. For a durable service, replace a mutable `latest` image with a tested version or digest and mount only the cache/config paths the service needs:

```text
host model cache:  ~/.cache/huggingface
container cache:   /root/.cache/huggingface
API endpoint:      127.0.0.1:8000
service identity:  dedicated container, not an interactive root shell
```

Do not copy `HF_TOKEN` into an image. Pass it at runtime, preferably from a permissions-restricted environment file or secret store. Record the exact model revision beside the image digest.

## Exact community deployment profiles

### 0xSero DeepSeek V4 Flash 0731 SparkInfer

Repository: [0xSero/deepseek-v4-flash-0731-spark-sparkinfer](https://github.com/0xSero/deepseek-v4-flash-0731-spark-sparkinfer)  
Derived checkpoint: [0xSero/deepseek-v4-flash-0731-spark](https://huggingface.co/0xSero/deepseek-v4-flash-0731-spark)  
Upstream checkpoint: [deepseek-ai/DeepSeek-V4-Flash](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash)

This is the best-pinned of the reviewed community projects, but it is also the most specialized. The compose file uses:

```text
image digest: ghcr.io/0xsero/deepseek-v4-flash-0731-spark-sparkinfer@sha256:2e077489a83a0360952828051fe7f7a32c1801e5ce8436d85f7267583d614ff4
base image:   nvcr.io/nvidia/vllm:26.02-py3
vLLM commit:  30038602b71395f481ef4a6edfe4fcf8551d9c15
SparkInfer:   272a84bd97ce791a1e92d1f3a0da3dd5f3c6565f
model rev:    22f28d32b9b29b4352eaa380ff8c2c170b2847ab
data:         ./data
build cache:  ./cache
endpoint:     localhost:8000
```

The project starts with `docker compose up -d`. Its first run requires at least 250 GB free disk, with 300 GB recommended by the author, because it downloads roughly 107 GB, coalesces a TP4 checkpoint to TP1, and builds a separate speculative draft. The runtime is GB10/SM121-specific, uses a 3.0 GB K64 draft with fixed K5 verification, supports at most four scheduled sequences, and exposes a configured 262,144-token context.

This is not the official 284B/13B-active model in its published precision. The derivative prunes 40 of 256 experts, retains 216, and converts the target to a roughly 3.0-bpw EXL3/Trellis representation. The official [DeepSeek V4 Flash card](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash) describes a 1M-context, MIT-licensed checkpoint with FP4 experts and mostly FP8 remaining parameters. Quality and throughput results for the derivative therefore cannot be attributed to the unmodified upstream model.

No official one-Spark-sized DeepSeek V4 Flash checkpoint was found. NVIDIA's [DeepSeek V4 Flash NVFP4](https://huggingface.co/nvidia/DeepSeek-V4-Flash-NVFP4) is about 168 GB, while DeepSeek's own [DeepSeek V4 Flash DSpark](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash-DSpark) is about 167 GB. Despite the latter name, either exceeds Spark's 128 GB unified memory before runtime/KV overhead. The 0xSero pruning and lower-bit conversion is therefore essential to its fit, not merely an optional speed optimization.

The implementation also corrects a potentially misleading name: its `nvfp4_ds_mla` control path uses a 584-byte padded FP8 sparse-MLA KV record. The true 432-byte NVFP4 record was disabled because it corrupted full-model text. This project should not be cited as proof that all KV work is native NVFP4.

The author reports five 512-output-token, concurrency-one coding trials with thinking disabled: 34.30 tok/s minimum, 38.12 median, and 39.49 mean. One trial missed the project's stated 35 tok/s steady-state gate. The repository also reports extensive functional checks, including strict JSON, long-context fact recovery, checksum validation, and post-capture KV allocation. These are valuable community reproducibility claims, but not independent or vendor benchmarks.

**Disposition:** on demand. Preserve the digest and commits, review all remote code, and retain its isolated `data` and `cache` directories. Its disk footprint, custom kernels, pruned target, and nonstandard build path make it a poor first always-on endpoint.

### MiaAI Unsloth Qwen3.6 35B NVFP4

Repository: [MiaAI-Lab/Unsloth-Qwen3.6-35b-NVFP4-DGX-Spark](https://github.com/MiaAI-Lab/Unsloth-Qwen3.6-35b-NVFP4-DGX-Spark)  
Launch script: [start.sh](https://raw.githubusercontent.com/MiaAI-Lab/Unsloth-Qwen3.6-35b-NVFP4-DGX-Spark/main/start.sh)  
Checkpoint: [unsloth/Qwen3.6-35B-A3B-NVFP4](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-NVFP4)

The script uses `ghcr.io/miaai-lab/mia-vllm-gb10-linear-b12x:latest`, derived from `ghcr.io/timothystewart6/vllm-gb10:latest`. It patches mixed-checkpoint handling so unsupported/non-NVFP4 linear layers fall back to automatic selection while FlashInfer B12X handles eligible NVFP4 linears. The reported base stack contains FlashInfer 0.6.14 and a vLLM build around 0.26, but neither container is digest-pinned.

The exact operational shape is:

```text
host cache:      <repository>/.cache/huggingface
container cache: /root/.cache/huggingface
port:            8888 through host networking
architecture:    CUTE_DSL_ARCH=sm_121a
KV cache:        FP8
context:         262,144
max sequences:   24
batched tokens:  32,768
GPU utilization: 0.80
speculation:     MTP, 2 tokens, Triton draft backend
tools:           qwen3_coder + automatic tool choice
```

The script also enables FlashInfer attention, B12X linear dispatch, chunked prefill, async scheduling, Qwen3 reasoning, thinking preservation, and up to four images per request. It mounts the entire working directory at `/workspace`, runs with host networking/IPC, grants `IPC_LOCK`, allows unlimited memlock, and permits media from `*` domains. Those settings materially enlarge the trust boundary.

The author reports 95.1 tok/s at concurrency one with 103 ms TTFT and 317 tok/s aggregate at concurrency eight, with about 500 output tokens. The Unsloth card publishes other much larger throughput figures under different hardware/concurrency conditions. They are not contradictory measurements of the same experiment: model revision, harness, prompt, output length, B200 versus GB10, concurrency, and metric aggregation differ.

**Disposition:** on-demand A/B profile. Rebuild the patch into an owned image, pin the base and final digests, replace the full-workspace mount with read-only narrow mounts, remove wildcard media domains, and run the Hermes tool test suite before promotion. The fact that NVIDIA's official checkpoint recipe uses Marlin while this one uses patched B12X is not proof that one backend is universally faster; they are different mixed checkpoints and runtime builds.

### MiaAI Qwen3.6 27B NVFP4 with DFlash

Repository: [MiaAI-Lab/Qwen3.6-27B-NVFP4-DFlash-DGX-Spark](https://github.com/MiaAI-Lab/Qwen3.6-27B-NVFP4-DFlash-DGX-Spark)  
Launch script: [start.sh](https://raw.githubusercontent.com/MiaAI-Lab/Qwen3.6-27B-NVFP4-DFlash-DGX-Spark/main/start.sh)  
Checkpoint: [nvidia/Qwen3.6-27B-NVFP4](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4)

The current script is the source of truth where it differs from the README. It runs the mutable `vllm/vllm-openai:nightly-aarch64` image and pulls it on start. It mounts repository-local Hugging Face and Triton caches, the complete workspace, and a custom chat template. It also uses `--privileged`, host networking, host IPC, and a root container.

Key current flags are:

```text
quantization:    compressed-tensors
attention:       flash_attn
KV cache:        BF16
context:         262,144
max sequences:   4
batched tokens:  8,192
GPU utilization: 0.84
draft:           z-lab/Qwen3.6-27B-DFlash, 10 speculative tokens
tools:           qwen3_coder with custom chat_template.jinja
endpoint:        port 8888
```

The README mentions `modelopt`, but the actual script passes `compressed-tensors`. The README also describes a language-model-only mode while the current script instead passes `--skip-mm-profiling`. These should be treated as documentation drift and locked down before repeatable use. The use of a MoE backend flag for an official dense 27B model is another reason to verify the effective engine configuration from startup logs rather than infer it from the script.

The author reports, with 256 output tokens, 45.6 tok/s and 133 ms TTFT at concurrency one, and 102.4 tok/s aggregate/29.8 per stream at concurrency four. A separate single-run context ladder reports about 993–1,083 prefill tok/s from roughly 1.8K to 56.7K prompt tokens, while decode falls from 45.3 to 26.6 tok/s. These are community results and not directly comparable to the Mia 35B run because the output length, KV precision, speculation method, runtime image, model architecture, and harness differ.

**Disposition:** on demand only. A privileged, mutable nightly image with a full workspace mount is not suitable for a continuous personal agent service. Remove `--privileged`, pin a digest, narrow mounts, vendor the template, and record its hash before considering a persistent deployment.

### MiaAI Ling 3.0 Flash SGLang

Repository: [MiaAI-Lab/Ling-3.0-Flash-SGLang-DGX-Spark](https://github.com/MiaAI-Lab/Ling-3.0-Flash-SGLang-DGX-Spark)

The wrapper targets `inclusionAI/Ling-3.0-flash-int4` using `ghcr.io/miaai-lab/ling-3.0-flash-sglang-dgx-spark:ling_v3_support`, with `lmsysorg/sglang:dev-Ling-3.0-flash` as an alternative. Both are mutable tags. The wrapper says the upstream InclusionAI Ling SGLang repository is private or unavailable, which prevents an independent source build from the referenced code. A stable, authoritative public model card and license for the exact target could not be verified during this review; that is a deployment blocker, not a minor documentation omission.

The reviewed defaults are port 8888, 262,144-token context, FP8 E4M3 KV, memory fraction 0.75, six running requests, mamba cache 32, and a host Hugging Face cache at `~/.cache/huggingface`. The live profile described by the repository changes memory fraction to 0.70, mamba cache to 16, enables one NEXTN token, and applies a 100 GB Docker memory cap. Host networking/IPC, all GPUs, and 32 GB shared memory are used.

The author reports 37 tok/s at concurrency one and 76 tok/s aggregate at concurrency six, but the published table does not provide a sufficient common prompt/output/sample specification for comparison with the Qwen or DeepSeek runs. TTFT rises to about 4.99 seconds at concurrency six. The launch evidence reviewed exposes a Ling reasoning parser but no clear, first-party tool-call parser suitable for Hermes.

**Disposition:** provenance hold. Do not install it as an always-on service until the exact checkpoint revision, license, upstream runtime source, image digest, and tool-call protocol can all be verified. If it is tested, use an isolated on-demand profile with no host secrets.

## First-party candidate profiles

### Qwen3.6 27B NVFP4 clean control

The [official NVIDIA Qwen3.6 27B NVFP4 card](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4) is a roughly 21.9 GB ModelOpt checkpoint of Qwen's dense 27B multimodal model. It documents `--quantization modelopt`, a 262,144-token maximum, and Qwen3 reasoning; the upstream Qwen deployment guidance uses the Qwen tool-call protocol. Its Apache-2.0 license and first-party checkpoint make it the correct dense control before introducing Mia's custom template, DFlash draft, privileged nightly image, or BF16 KV choice.

Run it on demand at a deliberately smaller initial context and concurrency, record actual unified-memory use, and then add one feature at a time. This isolates whether any speed or quality change comes from the model, quantization, KV precision, speculative draft, parser/template, or container patch.

### Nemotron 3 Nano Omni 30B A3B Reasoning NVFP4

The [official NVIDIA card](https://huggingface.co/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4) describes a roughly 31B-total/3B-active multimodal model with a 256K context, English-only output, JSON/tool calling, and the NVIDIA Open Model Agreement. It lists BF16 at about 62 GB, FP8 at 33 GB, and NVFP4 at 21 GB, and explicitly includes DGX Spark support.

Its documented Spark-oriented vLLM profile uses `vllm/vllm-openai:v0.20.0`, installs `vllm[audio]`, mounts local weights read-only, and serves a 131,072-token working context with eight sequences, 32,768 batched tokens, FP4 checkpoint weights, prefix caching, the `nemotron_v3` reasoning parser, and `qwen3_coder` tool parser. Because `pip install vllm[audio]` on every launch is mutable and network-dependent, a persistent deployment should build and pin a derived image once.

This is the strongest on-demand multimodal specialist. It is structurally compatible with OpenAI tool calls, but the reviewed NVIDIA Hermes playbook validates Qwen3.6 35B, not Nemotron Omni. Audio/video parsing, local-media access, and `--allowed-local-media-path=/` should be narrowed before a long-lived agent can invoke it.

### Gemma 4 26B A4B and 31B IT

Google's cards describe [Gemma 4 26B A4B IT](https://huggingface.co/google/gemma-4-26B-A4B-it) as a 25.2B-total/3.8B-active multimodal MoE and [Gemma 4 31B IT](https://huggingface.co/google/gemma-4-31B-it) as a 30.7B dense multimodal model. Both have 256K context, native function calling, configurable thinking, and Apache-2.0 licensing.

NVIDIA publishes ModelOpt checkpoints for [Gemma 4 26B A4B NVFP4](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4) at about 18.8 GB and [Gemma 4 31B IT NVFP4](https://huggingface.co/nvidia/Gemma-4-31B-IT-NVFP4) at about 32.7 GB. NVIDIA's [general Spark vLLM instructions](https://build.nvidia.com/spark/vllm/instructions) route Gemma 4 through the custom `vllm/vllm-openai:gemma4-cu130` image. The NVIDIA model profile uses `--tool-call-parser gemma4`, `--reasoning-parser gemma4`, and automatic tool choice; it also invokes remote code, so pin and inspect the revision. The quantized 31B model card itself uses datacenter-style test settings and does not establish a tuned Spark concurrency/performance profile.

The 26B A4B variant is the better secondary candidate because its active parameter count and weight footprint leave much more room for KV cache and co-resident services. Neither variant should displace Qwen35 as the default until its exact Gemma tool-call template is tested end to end through Hermes.

### Qwen3.5 122B A10B NVFP4

The official [Qwen3.5 122B A10B card](https://huggingface.co/Qwen/Qwen3.5-122B-A10B) describes a 122B-total/10B-active multimodal MoE with 262K native context and Apache-2.0 licensing. NVIDIA's [NVFP4 conversion](https://huggingface.co/nvidia/Qwen3.5-122B-A10B-NVFP4) is about 83.5 GB and documents a TP1 vLLM command using `nvcr.io/nvidia/vllm:26.04-py3`, ModelOpt FP4, FP8 KV, Qwen3 reasoning, and `qwen3_coder` tool parsing.

That is not enough evidence for a comfortable one-Spark service. An 83.5 GB checkpoint leaves limited unified-memory headroom for vLLM, CUDA graphs, multimodal components, KV cache, Hermes, and the desktop stack. The card's validation hardware is B200 rather than one DGX Spark. Treat it as a low-concurrency, short-context experiment and collect actual peak UMA before increasing context. It is not a 24x7 candidate.

### Poolside Laguna S 2.1 NVFP4

Poolside's [Laguna-S-2.1](https://huggingface.co/poolside/Laguna-S-2.1) card describes an approximately 118B-total/8.5B-active coding and agent model with a recommended 256K context, training to 1M context, and the `poolside_v1` reasoning/tool protocol. Its license is OpenMDW 1.1 plus an acceptable-use policy, not Apache-2.0. The [NVFP4 checkpoint](https://huggingface.co/poolside/Laguna-S-2.1-NVFP4) is about 71.9 GB.

Poolside publishes an explicit DGX Spark recipe for vLLM 0.25 with a small DFlash draft, `CUTE_DSL_ARCH=sm_121a`, 262,144 context, up to 32 sequences, 0.85 GPU utilization, and automatic tool choice through `poolside_v1`. The card warns not to force `flashinfer_b12x` on vLLM 0.25.1 because that opt-in path is broken or slower there; automatic backend selection uses the supported SM121 path. It also reports 12.6 tok/s for an Ollama Q4_K_M build on Spark. That number is vendor-reported and represents a different quantizer/runtime from the NVFP4+DFlash server.

This is a credible agent-quality comparison to Qwen, but the 72 GB footprint, custom code, high advertised sequence count, and non-Apache license deserve a staged on-demand rollout. Start with `max-num-seqs=1` or `2`, capture peak UMA, and test multi-turn tools before attempting the vendor maximum.

### StepFun 3.7 Flash

The first-party [Step-3.7-Flash repository](https://github.com/stepfun-ai/Step-3.7-Flash) and [NVFP4 model card](https://huggingface.co/stepfun-ai/Step-3.7-Flash-NVFP4) describe an approximately 198B-total/11B-active multimodal agent model with a 256K context. The official vLLM image is `vllm/vllm-openai:stepfun37`, and the documented NVFP4 server recipe uses tensor parallelism 4, expert parallelism, an 8,192-token working context, ModelOpt quantization, FP8 KV, MTP, and the `step3p5` reasoning/tool parsers. The SGLang NVFP4 recipe similarly uses TP4/EP4.

Those commands are not single-Spark recipes. The first-party [Step 3.7 GGUF repository](https://huggingface.co/stepfun-ai/Step-3.7-Flash-GGUF) lists Q4_K_S at about 112 GB, IQ4_XS at 105 GB, Q3_K_L at 103 GB, Q3_K_M at 94 GB, and IQ3_XXS at 76 GB, plus an approximately 4 GB vision projector and runtime overhead. It requires StepFun's `step3.7` llama.cpp branch. Q4 leaves almost no operational margin on a 128 GB Spark; Q3_K_M or IQ3_XXS is more realistic but represents a different quantization/quality point from the TP4 NVFP4 server.

**Disposition:** on-demand, text-first llama.cpp experiment only. Stop other heavy services, begin at a short context, omit the projector unless vision is required, and monitor host UMA. Do not reinterpret a TP4 NVFP4 recipe as proof that its server checkpoint fits one Spark. The first-party model is Apache-2.0, but its custom model code and runtime branch still require revision pinning and review.

## NVIDIA vLLM, SGLang, and Hermes playbooks

NVIDIA's [general vLLM Spark playbook](https://build.nvidia.com/spark/vllm/instructions) is the appropriate base for supported vLLM image/model combinations; the Qwen agent-ready sub-playbook is more authoritative for the default Hermes endpoint. The general recipe should be hardened by adding an explicit Hugging Face cache mount, immutable image reference, exact model revision, localhost binding, restart policy, and health check.

NVIDIA's [SGLang Spark playbook](https://build.nvidia.com/spark/sglang/instructions) uses `lmsysorg/sglang:latest-cu130`, normally on port 30000, and provides a generic launch pattern plus a supported-model matrix. NVFP4 models require the appropriate ModelOpt FP4 quantization flag. This playbook is useful as a clean SGLang baseline, but it does not validate the Mia Ling wrapper, its private upstream dependency, or its tool-call behavior. Pin the SGLang image and persist the Hugging Face cache before using it for repeated model trials.

The [Hermes Agent Spark playbook](https://build.nvidia.com/spark/hermes-agent/instructions) should be treated as the integration contract. A candidate is not “Hermes-ready” merely because it can emit JSON. It must pass:

- OpenAI-compatible tool schema ingestion;
- one and multiple tool calls in a turn;
- parallel calls if the parser advertises them;
- correct assistant/tool role round trips;
- preservation or suppression of reasoning as configured;
- recovery after tool errors and malformed arguments;
- long-running gateway restarts without losing the model endpoint;
- no unauthorized local-media, shell, network, or filesystem access.

## NVFP4 on GB10: resolve the apparent contradiction

NVIDIA states that GB10 supports NVFP4 and has published [Spark software/model optimization results](https://developer.nvidia.com/blog/new-software-and-model-optimizations-supercharge-nvidia-dgx-spark/). That hardware capability is real. It does not imply every layer of every “NVFP4” checkpoint executes a native FP4 kernel on every runtime.

Three separate questions must be recorded:

1. **Checkpoint format:** which tensors are stored in NVFP4, FP8, BF16, or another packed format?
2. **Kernel path:** does this particular runtime/build use B12X, Marlin, CUTLASS, dequantization, or a fallback for each layer type?
3. **Platform stability:** is that kernel path validated on GB10/SM121 with the chosen CUDA-graph mode?

The distinction is visible in the reviewed sources. NVIDIA's Qwen35 Spark command deliberately uses `--moe-backend marlin`; Mia's Unsloth profile patches B12X to fall back for unsupported layer types; 0xSero's named MLA path uses an FP8 record rather than true NVFP4 KV. NVIDIA's [NIM LLM release notes](https://docs.nvidia.com/nim/large-language-models/2.0.1/about-nim-llm/release-notes.html) also warn that NVFP4 MoE models on GB10 can encounter a misaligned-address crash during full CUDA graph capture and give `VLLM_USE_FLASHINFER_MOE_FP4=0` as a workaround, while noting dense models are unaffected.

Therefore, log the effective backend at startup and verify output correctness under the exact CUDA-graph/concurrency profile. Do not label a service “native NVFP4 end to end” based on its repository name.

## Benchmark evidence and comparability

| Profile | Published result | Conditions disclosed | Evidence class | Comparable conclusion |
|---|---|---|---|---|
| 0xSero DeepSeek derivative | 38.12 median, 39.49 mean tok/s | Physical Spark, C1, five coding trials, 512 outputs, thinking off | Community | Reproducible within that derivative only |
| Mia Qwen3.6 35B | 95.1 tok/s C1; 317 aggregate C8 | Physical Spark claim, about 500 outputs; patched B12X/MTP2 | Community | Do not compare with B200/128-concurrency Unsloth tables |
| Mia Qwen3.6 27B | 45.6 tok/s C1; 102.4 aggregate C4 | 256 outputs; BF16 KV; DFlash10; separate single-run context ladder | Community | Not an apples-to-apples 35B comparison |
| Mia Ling 3.0 Flash | 37 tok/s C1; 76 aggregate C6 | Runtime profile stated; prompt/output/sample detail incomplete | Community | Directional only |
| Laguna Ollama quant | 12.6 tok/s | Poolside Spark claim for Q4_K_M/Ollama | Model vendor | Says nothing about NVFP4+DFlash vLLM throughput |
| NVIDIA/Google quality tables | Model-specific accuracy scores | Often different precisions, datacenter GPUs, or internal harnesses | Model vendor | Compare model quality only when task/harness match; never infer Spark speed |

The local acceptance benchmark should pin image digest and model revision, then record:

- exact quantizer, effective attention/MoE/linear backend, and speculative draft;
- prompt tokens, output tokens, thinking setting, sampling parameters, and stop rules;
- cold and warm prefix-cache runs;
- C1, C2, and C4 per-stream and aggregate decode throughput;
- TTFT p50/p95, prefill throughput, peak host UMA, and cache allocation;
- short, 32K, 64K, 128K, and advertised-max context ladders;
- error rate, tool-call validity, restart recovery, and thermal steady state;
- at least five repeated runs, reporting median and range rather than the best run.

Only results from this controlled harness should drive which model becomes the persistent default.

## Security, license, and supply-chain gates

| Candidate | License/provenance issue | Runtime trust issue | Required gate |
|---|---|---|---|
| NVIDIA/Unsloth Qwen | Apache-2.0 | `--trust-remote-code`; mutable images in community recipe | Pin model revision and image digest; review remote code |
| DeepSeek V4 derivative | Upstream/derivative state MIT, but derivative quality differs | Highly custom kernels and conversion; remote code | Verify hashes and commits; isolate service/cache |
| Nemotron Omni | NVIDIA Open Model Agreement | Multimodal extras and broad local-media flag | Review agreement; build pinned audio image; narrow media path |
| Google/NVIDIA Gemma | Apache-2.0 | Custom Gemma4 CUDA 13 image | Pin image/model and validate parser/template |
| Poolside Laguna | OpenMDW 1.1 plus AUP | Custom code; large on-device footprint | License review, revision pin, Hermes conformance |
| StepFun | Check exact model-card terms before deployment | Custom model code/image or near-capacity llama.cpp build | License record, isolate, short-context memory test |
| Ling wrapper | Exact public model card/license not verified | Mutable community image; upstream runtime unavailable | **Block** until provenance, license, source, and digest are verified |

No 24x7 profile should use `--privileged`, mount the whole working directory read-write, allow unrestricted media domains, or expose an unauthenticated OpenAI-compatible port on the LAN. `--trust-remote-code` is executable code permission, not a harmless model-loading switch. Image tags such as `latest`, `nightly`, and `dev-*` must be resolved to a digest for every benchmark and deployment record.

## Promotion gates and lifecycle

### Keep running continuously

- Hermes gateway as a managed user service, with only intended user/channel IDs allowed.
- One locally bound `unsloth/Qwen3.6-35B-A3B-NVFP4` endpoint using the pinned MiaAI GB10 image, after the 5/5 tool-call, restart, and memory gates pass.
- Docker itself and only the minimum monitoring needed to detect model/service failure.

### Start only when requested

- Nemotron Omni, either Gemma 4 variant, Laguna, Qwen3.5 122B, StepFun, and all four community profiles.
- Any build/conversion container, model download, long-context stress test, or speculative-draft preparation.
- ODS workloads that materially compete for unified memory with a large model server.

### Promote an alternate model to 24x7 only when all gates pass

1. Exact checkpoint revision, image digest, license, parser, and chat template are recorded.
2. No privilege escalation, full-workspace mount, wildcard media access, or unintended LAN listener remains.
3. Cold boot, health check, graceful stop, crash restart, and host reboot recovery all pass.
4. C1/C2/C4 benchmark, peak UMA, and 8-hour thermal soak are within limits.
5. Hermes single, sequential, parallel, malformed, and failed-tool scenarios pass.
6. Long-context tests produce correct output without CUDA misalignment or silent corruption.
7. The incumbent Qwen profile remains available as the rollback target.

## Bottom line

Use the Unsloth Qwen3.6 35B A3B checkpoint with the pinned, narrowed MiaAI GB10 runtime as the provisional Hermes service, and retain NVIDIA's Qwen3.6 35B A3B recipe as the first-party control. This choice is driven by the newer same-box large-tool report, not by the community throughput number; local acceptance tests remain mandatory. Build a small library of pinned on-demand profiles around it: Nemotron Omni for multimodal work, Gemma 26B as the lightweight alternative, Laguna as the agent/coding challenger, and DeepSeek as an isolated experiment. Keep Qwen3.5 122B and StepFun in the memory-stress tier, and hold Ling until its provenance is independently verifiable.

The main optimization is operational reproducibility rather than another global `.bashrc` flag: immutable images, exact model revisions, isolated per-profile service configurations, shared runtime-native model caches, a common benchmark contract, local-only endpoints, and one recorded launch profile per model. That makes performance claims auditable and prevents one model's patches, templates, or mutable container from contaminating another.

Related: [[DGX Spark Operations Setup Guide]] | [[Local Setup Index]]
