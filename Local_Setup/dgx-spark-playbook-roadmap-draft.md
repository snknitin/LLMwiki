---
title: DGX Spark Playbook Roadmap Draft
date: 2026-08-02
status: reconstructed-research-input
scope: live NVIDIA DGX Spark catalog and local ODS checkout
---

# DGX Spark playbook inventory and ODS roadmap

This is the supporting playbook inventory used by [[DGX Spark ODS Playbook and Model Roadmap]]. It covers the **44 unique cards visible in the live [NVIDIA DGX Spark playbook catalog](https://build.nvidia.com/spark)** on 2026-08-02. The broader [`NVIDIA/dgx-spark-playbooks`](https://github.com/NVIDIA/dgx-spark-playbooks) repository contains extra folders: a standalone Ollama recipe that is not a current live card, a Brev registration utility, and a duplicate/legacy Reachy folder. Those are not additional live playbooks.

## ODS interpretation

Do not install all 44 as permanent host services. They are a mixture of:

1. one-time device/network foundations;
2. competing or complementary inference runtimes;
3. fine-tuning and optimization labs;
4. reference applications;
5. agent-stack alternatives;
6. hardware/domain electives.

The local ODS checkout already supplies a core llama.cpp OpenAI-compatible server, Open WebUI, the ODS dashboard, and its API. Its extension library includes Hermes/`hermes-proxy`, Tailscale, ComfyUI, Ollama, n8n, Qdrant, TEI embeddings, Whisper, Kokoro, Langfuse, and other optional services. ODS documents vLLM as a recipe, but it is not currently a first-class ODS extension. SGLang, TensorRT-LLM, NIM, NeMo, Unsloth, LLaMA Factory, and Model Optimizer remain separate learning/deployment lanes.

"ODS contains it" does not prove that it is enabled on this Spark. Inspect the live host:

```bash
ods status
ods list
docker ps --format 'table {{.Names}}\t{{.Ports}}\t{{.Status}}'
```

## Direct overlap: configure rather than duplicate

| NVIDIA playbook | ODS state | Correct action |
|---|---|---|
| Run models with llama.cpp | ODS core `llama-server` | Benchmark/upgrade the managed path. Use a separate pinned build only for an architecture or draft head not supported by the ODS build. |
| Open WebUI with Ollama | Open WebUI is ODS core; Ollama is optional | Retain one WebUI database. Enable Ollama only if its lifecycle/API is needed; do not duplicate the UI and caches. |
| Run Hermes Agent with Local Models | Hermes and `hermes-proxy` are ODS services | Configure the authoritative Hermes profile/gateway. Do not create a second memory database, bot, schedules, or home directory. |
| Set up Tailscale | Tailscale is an ODS/host optional path | Configure and verify the existing host/network ownership and ACLs. |
| Comfy UI | Optional ODS service | Enable/configure it and share one model/output cache. |
| OpenClaw | Deprecated optional ODS service; migration favors Hermes | Skip unless comparing in an isolated workspace. |
| CLI Coding Agent / Vibe Coding | ODS can provide OpenCode/Ollama-compatible endpoints | Reuse the selected endpoint; treat these as UX labs, not model-stack installers. |
| RAG / Multi-Agent / VLM applications | ODS can provide LiteLLM, Qdrant, TEI, n8n, Langfuse and model endpoints | Run the app as a portfolio lab while reusing stable services where its design permits. |

NVIDIA **DGX Dashboard** is not the ODS Dashboard. Keep both: NVIDIA covers system/firmware/Jupyter functions; ODS covers its service plane.

## Recommended learning order

### Phase 0: safe remote appliance

1. Local Network Access
2. Tailscale
3. DGX Dashboard
4. VS Code remote development
5. ODS inventory, ports, caches, disk, memory, health, restart policies, secrets, backups
6. CUDA-X Data Science as the bridge from staff data science

### Phase 1: inference engineering

1. Benchmark the existing ODS llama.cpp path.
2. Complete vLLM and deploy Qwen3.6 NVFP4.
3. Register it behind ODS LiteLLM with stable aliases.
4. A/B SGLang using the same checkpoint, quant, context, prompt set, and concurrency.
5. Learn TensorRT-LLM, then NIM.
6. Learn NVFP4 quantization and speculative decoding after a baseline exists.
7. Use the Nemotron playbook for NVIDIA ecosystem familiarity.

### Phase 2: SLM and fine-tuning

Recommended pedagogical order for this career pivot:

1. PyTorch fine-tuning to understand PEFT/SFT fundamentals.
2. Unsloth for rapid LoRA/QLoRA iteration.
3. LLaMA Factory for repeatable datasets, templates, and configuration.
4. NeMo for the enterprise/NVIDIA recipe ecosystem.
5. Quantize the same result with NVFP4 and deploy it through the same API/evaluation harness.

Use one base model, dataset split, task, LoRA target, evaluator, and deployment test across frameworks. The portfolio artifact is the reproducible comparison—not four unrelated notebooks.

### Phase 3: FDE case studies

1. RAG Application in AI Workbench
2. Text to Knowledge Graph
3. Multi-Agent Chatbot
4. Multi-modal Inference
5. Video Search and Summarization as the capstone

Turn at least two into production-shaped case studies with requirements, architecture, evaluation data, p95 latency, memory behavior, observability, security boundaries, failure handling, and rollback.

### Phase 4: agent security

- Keep Hermes authoritative.
- Learn OpenShell in a clean isolated workspace.
- Evaluate NemoClaw and its example agents only after Hermes is stable.
- Treat OpenClaw as an isolated comparison, not another permanent agent with the same files, tokens, and secrets.

### Phase 5: electives and deferrals

- Advanced performance: Optimized JAX and cuTile after inference/training baselines.
- Multimodal: FLUX DreamBooth, ComfyUI, Live VLM WebUI.
- Domain: finance or single-cell only if useful for a target role.
- Robotics: Isaac/Reachy only if targeting physical AI and owning the required hardware.
- Multi-Spark topology: defer until multiple DGX Sparks actually exist; the RTX workstation is not a second Spark for these recipes.

## Complete live-catalog inventory

| # | Official playbook | Type | ODS judgment | Recommended timing |
|---:|---|---|---|---|
| 1 | [Set Up Local Network Access](https://build.nvidia.com/spark/connect-to-your-spark) | Onboarding foundation | Required outside ODS | First |
| 2 | [Open WebUI with Ollama](https://build.nvidia.com/spark/open-webui) | UI/runtime smoke test | **Direct overlap**: Open WebUI core, Ollama optional | Configure existing services in Phase 1 |
| 3 | [Single-cell RNA Sequencing](https://build.nvidia.com/spark/single-cell) | Data-science vertical | No direct overlap | Optional life-sciences case study |
| 4 | [Portfolio Optimization](https://build.nvidia.com/spark/portfolio-optimization) | Data-science vertical | No direct overlap | Optional finance case study |
| 5 | [CUDA-X Data Science](https://build.nvidia.com/spark/cuda-x-data-science) | DS foundation | Distinct, isolate environment | Early |
| 6 | [Text to Knowledge Graph](https://build.nvidia.com/spark/txt2kg) | FDE application | Shared model/API layer possible | Phase 3 after RAG |
| 7 | [Optimized JAX](https://build.nvidia.com/spark/jax) | Performance lab | Distinct | Advanced elective |
| 8 | [DGX Dashboard](https://build.nvidia.com/spark/dgx-dashboard) | System foundation | Complements ODS Dashboard | Phase 0 |
| 9 | [RAG Application in AI Workbench](https://build.nvidia.com/spark/rag-ai-workbench) | FDE application | Reuse ODS endpoints/vector layer if practical | First Phase 3 case study |
| 10 | [Set up Tailscale](https://build.nvidia.com/spark/tailscale) | Network foundation | ODS/host optional overlap | Phase 0; configure one owner |
| 11 | [VS Code](https://build.nvidia.com/spark/vscode) | Development foundation | Complements ODS | Phase 0 |
| 12 | [Connect Three Sparks in a Ring](https://build.nvidia.com/spark/connect-three-sparks) | Multi-node | Not applicable now | Defer |
| 13 | [Connect Multiple Sparks through a Switch](https://build.nvidia.com/spark/multi-sparks-through-switch) | Multi-node | Not applicable now | Defer |
| 14 | [FLUX.1 DreamBooth LoRA](https://build.nvidia.com/spark/flux-finetuning) | Vision fine-tuning | Training distinct; caches may be shared | Optional after text SLM pipeline |
| 15 | [LLaMA Factory](https://build.nvidia.com/spark/llama-factory) | SLM fine-tuning | New lane | Phase 2 |
| 16 | [Fine-tune with NeMo](https://build.nvidia.com/spark/nemo-fine-tune) | Enterprise/NVIDIA fine-tuning | New lane | Phase 2 after simpler frameworks |
| 17 | [Fine-tune with PyTorch](https://build.nvidia.com/spark/pytorch-fine-tune) | Fundamental fine-tuning | New lane | First conceptual training lab |
| 18 | [Unsloth](https://build.nvidia.com/spark/unsloth) | Fast LoRA/QLoRA | New lane | Early Phase 2 |
| 19 | [Run NemoClaw with a Local LLM](https://build.nvidia.com/spark/nemoclaw) | Sandboxed agent alternative | Competes with persistent-agent role | Optional, isolated after Hermes |
| 20 | [Set Up Example NemoClaw Agents](https://build.nvidia.com/spark/nemoclaw-applications) | Agent demonstrations | Alternative stack; requires healthy NemoClaw | Only after base NemoClaw |
| 21 | [Run Hermes Agent with Local Models](https://build.nvidia.com/spark/hermes-agent) | Persistent agent | **Direct overlap** with intended ODS/Hermes | Validate/configure after vLLM |
| 22 | [cuTile Kernels](https://build.nvidia.com/spark/cutile-kernels) | GPU engineering | Distinct | Advanced elective |
| 23 | [CLI Coding Agent](https://build.nvidia.com/spark/cli-coding-agent) | Developer UX | Shared Ollama/OpenAI endpoint | Optional after serving basics |
| 24 | [Live VLM WebUI](https://build.nvidia.com/spark/live-vlm-webui) | Multimodal application | Reuse endpoint if compatible | Phase 3/5 |
| 25 | [Isaac Sim and Isaac Lab](https://build.nvidia.com/spark/isaac) | Physical AI | Distinct and hardware-specific | Skip unless targeting robotics |
| 26 | [Vibe Coding in VS Code](https://build.nvidia.com/spark/vibe-coding) | Developer UX | Shared Ollama/OpenAI endpoint | Optional |
| 27 | [Multi-Agent Chatbot](https://build.nvidia.com/spark/multi-agent-chatbot) | FDE application | Shared endpoints possible; demo can consume almost all memory | Phase 3, ephemeral |
| 28 | [Connect Two Sparks](https://build.nvidia.com/spark/connect-two-sparks) | Multi-node | Not applicable to Spark + RTX workstation | Defer |
| 29 | [NCCL for Multiple Sparks](https://build.nvidia.com/spark/nccl) | Multi-node | Requires multiple Sparks/topology first | Defer |
| 30 | [Video Search and Summarization Agent](https://build.nvidia.com/spark/vss) | FDE capstone | Distinct app, reuse operational patterns | Phase 3 capstone |
| 31 | [Spark and Reachy Photo Booth](https://build.nvidia.com/spark/reachy-photo-booth) | Robotics/multimodal demo | Shared inference/image layer only | Skip without Reachy hardware |
| 32 | [Secure Long-Running Agents with OpenShell](https://build.nvidia.com/spark/openshell) | Agent-security lab | ODS does not replace sandboxing | Isolated security lab |
| 33 | [OpenClaw](https://build.nvidia.com/spark/openclaw) | Persistent-agent alternative | ODS marks its path deprecated in favor of Hermes | Optional isolated comparison |
| 34 | [Speculative Decoding](https://build.nvidia.com/spark/speculative-decoding) | Inference optimization | Distinct benchmark/job | After a TRT-LLM baseline |
| 35 | [Run models with llama.cpp](https://build.nvidia.com/spark/llama-cpp) | GGUF inference | **Core ODS overlap** | Validate/benchmark existing service |
| 36 | [Nemotron Model Family](https://build.nvidia.com/spark/nemotron) | Model-family lab | Shared engine layer | After serving fundamentals |
| 37 | [SGLang](https://build.nvidia.com/spark/sglang) | Inference runtime | New ODS lane | A/B after vLLM |
| 38 | [TensorRT-LLM](https://build.nvidia.com/spark/trt-llm) | NVIDIA inference runtime | New ODS lane | After vLLM/SGLang |
| 39 | [NVFP4 Quantization](https://build.nvidia.com/spark/nvfp4-quantization) | Model optimization | Distinct job; publish artifacts to serving layer | After fine-tuning/vLLM |
| 40 | [Multi-modal Inference](https://build.nvidia.com/spark/multi-modal-inference) | Multimodal lab | Shared model/app services possible | Phase 3/5, ephemeral |
| 41 | [NIM on Spark](https://build.nvidia.com/spark/nim-llm) | Packaged NVIDIA inference | New ODS lane | After vLLM/TRT basics |
| 42 | [LM Studio](https://build.nvidia.com/spark/lm-studio) | GUI/headless model manager | Alternative runtime/UI | Optional comparison, not critical 24x7 owner |
| 43 | [vLLM](https://build.nvidia.com/spark/vllm) | Core throughput runtime | Documented ODS recipe, not first-class service | Primary serious serving lab |
| 44 | [ComfyUI](https://build.nvidia.com/spark/comfy-ui) | Image workflow UI | Optional ODS overlap | Configure existing cache/service if used |

## What should remain 24x7

- ODS control plane and selected managed services.
- Tailscale, monitoring, auth, health checks, and narrowly scoped production endpoints.
- One general router/API layer such as LiteLLM.
- One primary model server for the allocated memory budget.
- One authoritative Hermes gateway/profile.
- Optional small automation and retrieval tiers.

## What should normally be ephemeral

- Fine-tuning and quantization jobs.
- Benchmark containers and experimental runtimes.
- Multi-agent, RAG, VSS, VLM, finance, and biology demos.
- NemoClaw/OpenClaw experiments while Hermes remains authoritative.
- Jupyter/Workbench projects not actively used.

## Completion criteria

The roadmap is complete when it produces:

1. a versioned host/service/port/model-cache inventory;
2. an identical-workload vLLM versus SGLang benchmark;
3. a dataset-validation → baseline → LoRA/SFT → evaluation → quantization → deployment pipeline;
4. two end-to-end FDE case studies with observability, security, and failure handling;
5. a decision record explaining every 24x7 service and why alternatives remain ephemeral.

Related: [[DGX Spark ODS Playbook and Model Roadmap]] | [[dgx-spark-current-models-report|DGX Spark Current Models Report]]
