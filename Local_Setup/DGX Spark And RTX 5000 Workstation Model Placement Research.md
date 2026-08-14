# DGX Spark And RTX 5000 Workstation Model Placement Research

**Verified:** 14 August 2026  
**Scope:** One 128 GB DGX Spark, one Windows ODS workstation with a claimed 48 GB RTX 5000, Hermes Gateway/Serve on Spark, and Open WebUI plus SearXNG on the workstation.

## Recommendation in one paragraph

Keep **Hermes Gateway, Hermes Serve, the authoritative LiteLLM router, and the working Qwen vLLM profiles on DGX Spark**. Keep **Open WebUI and SearXNG on the workstation**. Add a current native Windows Ollama instance to the workstation as the simple, on-demand model shelf for Open WebUI and project tools. Use LM Studio there for interactive comparison, GGUF experiments, and LM Link—not as a second permanent copy of every Ollama model. The workstation should specialize in dense 27–31B inference, small-model development, and LoRA/QLoRA experiments; Spark should specialize in persistent agents, the Linux-only optimized recipes, full multimodal services, long contexts, and models whose working set exceeds 48 GB.

This deliberately removes Hermes from ODS ownership. ODS is the UI/search layer; Hermes and the canonical routing layer live on Spark.

## First verify which RTX 5000 this actually is

“RTX 5000” names two materially different workstation cards:

| GPU | Architecture | Memory | Memory bandwidth | Compute capability |
|---|---|---:|---:|---:|
| **RTX PRO 5000 Blackwell** | Blackwell | 48 GB GDDR7 ECC | 1,344 GB/s | 12.0 |
| **RTX 5000 Ada Generation** | Ada | 32 GB GDDR6 ECC | not the 48 GB card | 8.9 |

The claimed 48 GB capacity strongly suggests the **RTX PRO 5000 Blackwell**, but do not design the runtime from the shortened marketing name. NVIDIA’s [RTX PRO 5000 datasheet](https://www.nvidia.com/content/dam/en-zz/Solutions/design-visualization/quadro-product-literature/workstation-datasheet-blackwell-rtx-pro-5000-gtc25-spring-nvidia-3658700.pdf) specifies 48 GB and 1,344 GB/s; NVIDIA’s [RTX 5000 Ada product page](https://www.nvidia.com/en-us/products/workstations/rtx-5000/) specifies 32 GB. NVIDIA’s [MIG hardware table](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/supported-gpus.html) identifies RTX PRO 5000 Blackwell as GB202, compute capability 12.0, and 48 GB.

Run this in **Windows PowerShell on the workstation**, not on Spark:

```powershell
nvidia-smi --query-gpu=name,memory.total,compute_cap,driver_version --format=csv
nvidia-smi -q | Select-String 'Product Name|Product Architecture|Total'
```

NVIDIA documents `--query-gpu` and the product-name/frame-buffer fields in the [`nvidia-smi` reference](https://docs.nvidia.com/deploy/nvidia-smi/index.html), and its [CUDA guide](https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/compute-capabilities.html) specifically documents `nvidia-smi --query-gpu=name,compute_cap`.

If the result says **RTX 5000 Ada** or about **32 GB**, downgrade every workstation recommendation below by one tier. The 31B, Muse, and 30B QLoRA recommendations then become much tighter or CPU-offloaded experiments.

## Why the two machines should have different jobs

The RTX PRO 5000 has only 48 GB of dedicated VRAM but about **4.9 times** Spark’s raw memory bandwidth. Spark has 128 GB of coherent unified memory but 273 GB/s bandwidth. This means the RTX card is normally the better low-latency home for a quantized dense model that fits fully in VRAM, while Spark is the better capacity home for large working sets, large KV caches, and Linux/ARM recipes. Sources: [RTX PRO 5000 datasheet](https://www.nvidia.com/content/dam/en-zz/Solutions/design-visualization/quadro-product-literature/workstation-datasheet-blackwell-rtx-pro-5000-gtc25-spring-nvidia-3658700.pdf) and [DGX Spark hardware overview](https://docs.nvidia.com/dgx/dgx-spark/hardware.html).

This is a hardware-based placement rule, not a guarantee of tokens per second. Kernel quality, model architecture, quantization, context length, and speculative decoding can reverse an individual benchmark. Measure each candidate with the same prompts and context settings before migrating a working service.

## Ownership architecture

| Component | Owner | Purpose |
|---|---|---|
| Hermes Gateway and Hermes Serve | **Spark** | One synchronized, persistent agent home for desktop, laptop, and bot clients |
| LiteLLM | **Spark, one authoritative instance** | Stable aliases and routing to Spark plus optional workstation endpoints |
| Qwen vLLM services | **Spark** | Existing persistent Hermes/general-agent services |
| ODS Open WebUI | **Workstation** | Human-facing UI for both Spark and workstation models |
| ODS SearXNG | **Workstation** | Search backend for Open WebUI; it is not an inference runtime |
| Ollama | **Workstation** | Simple local API and on-demand quantized model shelf |
| LM Studio | **Workstation primarily** | Interactive evaluation, JIT-loaded GGUF models, LM Link, project experiments |
| Training environment | **Workstation WSL2/Linux container** | LoRA/QLoRA, evaluation, datasets, and project checkpoints |

Do not re-enable the ODS Hermes module. Do not create another authoritative Hermes home on Windows. Do not run both an ODS LiteLLM and a Spark LiteLLM as competing routers.

## Placement matrix for the current model list

| Model | Recommended home | Runtime | Decision |
|---|---|---|---|
| Qwen 3.6 35B-A3B NVFP4 (`spark-fast`) | **Spark; keep** | Existing vLLM profile | It is already the working Hermes endpoint. It is 35B total/3B active, supports tools and multimodal input, and NVIDIA’s checkpoint prefers Linux vLLM on Blackwell/Hopper. Duplicating it in Ollama adds storage and creates two versions with different templates/quantization. [Model card](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4) |
| Qwen 3.6 27B DFlash | **Spark for now; benchmark migration later** | Existing vLLM + DFlash | The dense 27B target could be faster on the high-bandwidth RTX card and its ~22 GB NVFP4 target fits 48 GB, but it already works on Spark. Do not duplicate it now. If a controlled benchmark proves a large gain, migrate the alias to an x86 Linux/WSL vLLM profile. [NVIDIA model card](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4) and [DFlash model card](https://huggingface.co/z-lab/Qwen3.6-27B-DFlash) |
| **Gemma 4 31B** | **Workstation first** | Ollama `gemma4:31b` or one LM Studio GGUF | This dense 30.7B model is the clearest use of the RTX card’s bandwidth: coding, multilingual work, reasoning, project A/B tests, and a quality comparison against Spark Qwen. Ollama’s current package is about 20 GB, leaving room for a moderate context and runtime state in 48 GB. [Ollama Gemma 4 catalog](https://ollama.com/library/gemma4) and [NVIDIA NVFP4 card](https://huggingface.co/nvidia/Gemma-4-31B-IT-NVFP4) |
| **Gemma 4 26B-A4B** | **Workstation convenience model**; Spark only for exact NVFP4/vLLM testing | Ollama `gemma4:26b` | The Ollama model is about 18 GB; its 25.2B/3.8B-active MoE is a fast creative-writing, translation, vision, and batch summarization worker. Store it beside 31B but load only one large model at a time. [Ollama catalog](https://ollama.com/library/gemma4) and [NVIDIA model card](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4) |
| **Nemotron 3 Nano Omni** | **Spark on demand** | Official vLLM 0.20 profile | Keep the full video/audio/image/text specialist on Spark. NVIDIA documents a 21 GB NVFP4 checkpoint, but media preprocessing, KV cache, and audio/video dependencies expand the working set. The Ollama `nemotron3:33b` package is 28 GB and its catalog currently advertises text/image, not the complete audio/video service. [NVIDIA card](https://huggingface.co/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4) and [Ollama catalog](https://ollama.com/library/nemotron3) |
| **Nemotron 3.5 Lightning 30B-A3B** | **Workstation on-demand challenger** | Ollama/GGUF first; WSL2 vLLM only when reproducibility matters | Its sparse ~3B-active architecture and 23.45 GiB NVFP4 target make it a strong low-latency coding/reasoning/tool-call experiment on 48 GB. Keep it out of the permanent Hermes path until local tool tests pass. NVIDIA also provides an exact Spark vLLM/DSpark recipe, so Spark remains the reference implementation. [NVIDIA card](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4) and [Build recipe](https://build.nvidia.com/nvidia/nemotron-3.5-lightning-30b-a3b) |
| **Muse Glimmer 30B** | **Workstation experiment in 4-bit GGUF**; Spark for the full vLLM/DFlash reference | Latest LM Studio/llama.cpp after compatibility check | The original BF16 repository is about 55.5 GiB and does not fit entirely in 48 GB. Meta’s card describes sub-20 GB 4-bit variants; use one of those for creative/project evaluation. Do not substitute a third-party NVFP4 checkpoint without labeling and evaluating it. Muse support is very new, so pin the runtime and first test without the DFlash assistant. [Meta model card](https://huggingface.co/meta-models/Muse-Glimmer-30B) and [official vLLM recipe](https://github.com/vllm-project/recipes/blob/main/models/meta-models/Muse-Glimmer-30B.yaml) |
| **Qwen 3.8 27B — day-zero release** | **Stage on Spark after stable quantized support; workstation GGUF later** | Do not deploy the BF16 checkpoint blindly | The official 27B checkpoint appeared on 14 August 2026 with dense 27B weights, multimodal input, and 262K context. Its roughly 55.6 GB BF16 repository does not fit entirely in 48 GB VRAM. Wait for a publisher/reputable 4-bit checkpoint and a stable runtime; compare that quant on the workstation, while Spark is the capacity-safe reference. [Official Qwen checkpoint](https://huggingface.co/Qwen/Qwen3.8-27B) |

### The practical workstation shortlist

Download only these initially:

1. `gemma4:31b` — the workstation’s main dense quality/coding/multilingual challenger.
2. `gemma4:26b` — faster MoE creative, translation, vision, and summarization worker.
3. `nemotron-3.5-lightning` — only after the installed Ollama version and tag are confirmed; treat it as an agent/tool benchmark.
4. One small training/development model, preferably `gemma4:12b` (Ollama currently lists it at about 7.6 GB) or NVIDIA’s 4B Nemotron base—not another copy of the Spark Qwen. [Ollama Gemma catalog](https://ollama.com/library/gemma4)

Models may all remain **on disk**, but plan for **one 26–31B model loaded in VRAM at a time**. Ollama’s default keep-alive is five minutes and `ollama stop MODEL` unloads a model; parallel requests multiply context-memory demand. [Ollama FAQ](https://docs.ollama.com/faq)

## Ollama versus LM Studio on the workstation

### Ollama: service of record for ODS

Use the native Windows Ollama installation as the stable local API because Ollama officially supports Windows and serves at `http://localhost:11434`. Set `OLLAMA_MODELS` to a large, explicit SSD directory before downloading. The official default is `%USERPROFILE%\.ollama\models`. [Ollama Windows documentation](https://docs.ollama.com/windows)

Open WebUI runs in Docker, so its local Ollama connection should use:

```text
http://host.docker.internal:11434
```

Open WebUI documents this exact host-to-container pattern and supports multiple Ollama instances. [Open WebUI Ollama connection guide](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-ollama/)

### LM Studio: lab and remote-human-access layer

Use LM Studio for:

- browsing GGUF quantizations and inspecting memory estimates;
- temporary A/B comparisons and project-specific model presets;
- Muse and other very new llama.cpp-compatible models;
- LM Link access from the laptop or another desktop.

LM Studio supports JIT loading, `--estimate-only`, TTL unloading, and an OpenAI-compatible local server. [Model loading documentation](https://lmstudio.ai/docs/cli/local-models/load) and [headless/JIT documentation](https://lmstudio.ai/docs/developer/core/headless)

LM Link is appropriate for interactive use across the user’s machines. It creates a separate encrypted Tailscale-based network and exposes linked models to the local LM Studio API at `localhost:1234`; it does not replace the existing personal tailnet. [LM Link FAQ](https://lmstudio.ai/docs/lmlink/basics/faq)

Do not download the same 20 GB model once through Ollama and again through LM Studio by default. Assign each model an owner. If a standalone GGUF already exists, LM Studio’s `lms import --hard-link` or `--symbolic-link` can avoid a second file where the filesystem supports it. [LM Studio import documentation](https://lmstudio.ai/docs/cli/local-models/import)

## Open WebUI and SearXNG without ODS/Hermes coupling

Configure the workstation Open WebUI with two normal model sources:

1. **Spark LiteLLM** as an OpenAI-compatible provider, with a visible prefix such as `spark/`.
2. **Workstation Ollama** as the local provider, with a visible prefix such as `local/`.

Optionally enable LM Studio at `http://host.docker.internal:1234/v1` only during lab sessions and prefix it `lab/`. Open WebUI supports provider prefixes specifically to disambiguate duplicate model names. [OpenAI-compatible connection guide](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-openai-compatible/)

SearXNG stays entirely inside the ODS UI/search layer. Open WebUI’s documented Docker URL is normally `http://searxng:8080/search?q=<query>` when both containers share a network, and JSON output must be enabled. [Open WebUI SearXNG guide](https://docs.openwebui.com/features/chat-conversations/web-search/providers/searxng/)

If Hermes also needs a workstation-only model, register the workstation endpoint in **Spark LiteLLM** under an explicit alias such as `ws-gemma31`. Reach it through the existing private tailnet, not a public port. Tailscale MagicDNS gives each device a stable private name, and tailnet access rules can be restricted by device and port. [MagicDNS](https://tailscale.com/docs/features/magicdns) and [Tailscale access-control editor](https://tailscale.com/kb/1587/visual-editor-reference)

Because the workstation may reboot, sleep, or be occupied by training, general workstation routes should fall back to `spark-fast`. Specialist routes such as Omni audio/video should fail explicitly rather than silently falling back to a text-only model.

## Realistic fine-tuning scope on 48 GB

Do **not** fine-tune the NVIDIA NVFP4 inference checkpoint merely because it fits for inference. For normal LoRA/QLoRA, begin from the publisher’s base or instruction checkpoint supported by Transformers/Unsloth, load the frozen base in NF4/4-bit, train adapters, evaluate them, and then export or quantize the accepted result for serving.

Hugging Face PEFT explains that LoRA freezes base weights and trains small low-rank matrices. Its QLoRA guidance uses a 4-bit frozen base plus adapters and notes that 65B QLoRA can be made to fit a single 48 GB GPU in a favorable supported setup. This establishes possibility, not a promise for every new MoE, hybrid-attention, multimodal, or Mamba architecture. [PEFT LoRA guide](https://huggingface.co/docs/peft/main/en/package_reference/lora) and [PEFT quantization guide](https://huggingface.co/docs/peft/main/developer_guides/quantization)

Use these conservative starting tiers on this workstation:

| Training type | Recommended scope on 48 GB | Guidance |
|---|---|---|
| Full fine-tuning | **1–3B first** | Full training keeps weights, gradients, optimizer states, and activations. Do not start full fine-tuning with a 26–35B model. |
| BF16/FP16 LoRA | **4–12B first** | Good for learning the workflow and creating reliable project adapters. |
| 4-bit QLoRA | **7–14B comfortable; 27–35B experimental** | A 27–35B job may fit with batch 1, gradient accumulation/checkpointing, and short 2K–4K sequences, but architecture support and activations decide success. Do not promise 32K/256K training context. |
| Multimodal LoRA | **small model first** | Vision/audio encoders and media batches add memory. Do not begin with Nemotron Omni or Muse. |

For an additional framework-specific check, Unsloth’s current published minima are 8.5 GB/33 GB for 14B QLoRA/16-bit LoRA, 22 GB/64 GB for 27B, 26 GB/76 GB for 32B, and 30 GB/96 GB for 40B. This supports 27–32B **4-bit QLoRA** as possible on 48 GB, while ruling out their ordinary 16-bit LoRA path; sequence length, architecture, and activation memory can still cause an otherwise nominal fit to fail. [Unsloth hardware requirements](https://unsloth.ai/docs/get-started/beginner-start-here/unsloth-requirements)

PEFT’s memory guide warns that parameter-efficient training is not automatically memory-efficient and recommends reducing model size, batch size, or sequence length first. [PEFT memory-efficient training](https://huggingface.co/docs/peft/main/developer_guides/memory_efficient_training)

Run training in WSL2 Ubuntu or a Linux GPU container. vLLM itself runs fully only on Linux and does not support Windows natively; its official guidance points Windows users to WSL. NVIDIA supports CUDA and Docker workloads under WSL2 but documents limitations around unified/managed memory and pinned system memory. [vLLM GPU installation](https://docs.vllm.ai/en/stable/getting_started/installation/gpu/) and [NVIDIA CUDA on WSL guide](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)

Before every training job:

1. Stop/unload Ollama and LM Studio models on the workstation.
2. Confirm free VRAM with `nvidia-smi`.
3. Leave Hermes and `spark-fast` running on Spark so normal agent work continues.
4. Train one adapter, save checkpoints outside ODS application data, and run a base-versus-adapter evaluation.
5. Only after acceptance, create a separate quantized serving artifact and register a new LiteLLM alias.

## Final placement decision

- **Spark:** Hermes, one canonical LiteLLM, persistent Qwen 35B, existing Qwen 27 DFlash until benchmarked, Nemotron Omni on demand, and reference vLLM/DFlash profiles.
- **RTX PRO 5000 workstation:** Open WebUI, SearXNG, native Ollama, Gemma 4 31B, Gemma 4 26B, Nemotron 3.5 Lightning experiments, Muse 4-bit experiments, and small/medium LoRA or QLoRA work.
- **LM Studio/LM Link:** human-facing remote access and temporary GGUF evaluation; not another copy of the entire Spark catalog.
- **Do not duplicate now:** either Qwen already working on Spark.

The first useful workstation deployment is therefore **Ollama + Gemma 4 31B**, connected directly to the existing ODS Open WebUI. That adds a genuinely different dense model and uses the workstation’s strongest hardware advantage without disturbing Hermes.
