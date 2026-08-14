# DGX Spark Additional Model Tutorials Index

_Prepared for the current Spark state on 2026-08-14._

This note is the starting page for the next model installations. It assumes you have already completed the Qwen 35B and Qwen 27B tutorials in [[DGX Spark Model Installation And Switching Guide]].

> [!important] What your status output means
> `vllm-spark-fast` is currently the only running large-model container. The Spark has about **20 GiB available memory** while it runs and about **3.2 TiB free disk space**. You may download another model while Qwen 35B remains running, but you must stop Qwen 35B before loading a model with vLLM, SGLang, Ollama, or LM Studio. An empty Ollama or LM Studio server may remain running.

## Files in this tutorial set

Follow them in this order:

1. [[DGX Spark Gemma 4 Models Tutorial]]
   - Installs the Spark-verified NVIDIA 26B-A4B checkpoint and the separate experimental 31B checkpoint as stopped-by-default vLLM profiles.
2. [[DGX Spark Nemotron 3 Nano Omni Tutorial]]
   - Installs NVIDIA's multimodal Nemotron 3 Nano Omni vLLM profile.
3. [[DGX Spark Nemotron 3.5 Lightning Tutorial]]
   - Installs NVIDIA's official vLLM 0.27.1 plus DSpark assistant; keeps the MiaAI/SGLang recipe as an advanced appendix.
4. [[DGX Spark Muse Glimmer 30B Readiness Tutorial]]
   - Records the new Muse model and prevents an unsafe day-one install while its local runtimes stabilize.
5. [[DGX Spark Ollama And ODS Tutorial]]
   - Adds one Ollama sidecar to the existing ODS network without creating another Open WebUI.
6. [[DGX Spark LM Studio And LM Link Tutorial]]
   - Finishes the already-installed `llmster` setup and links the Spark to LM Studio on Windows.

The source review is in [[DGX Spark Additional Models And Convenience Runtimes Research]].

## Which runtime owns which copy

| Runtime | Storage on the Spark | Use |
|---|---|---|
| Hugging Face + vLLM/SGLang | `~/.cache/huggingface` | Tuned Gemma, Nemotron, and Qwen performance profiles |
| Ollama | `~/.local/share/ollama` | Simple ODS/Open WebUI model shelf |
| LM Studio | `~/.lmstudio/models` | Remote graphical loading through LM Link |

These stores use different packaging. Do not download the same large model into all three merely because all three applications list it.

## The one-large-model rule

At any moment, keep only one of these loaded:

- a vLLM model;
- the Nemotron 3.5 SGLang container;
- a large Ollama model;
- a large LM Studio model.

Small embedding models are a separate case, but always verify memory with:

```bash
free -h
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
nvidia-smi
```

## Recommended testing order

| Order | Profile | Why |
|---:|---|---|
| 1 | `gemma4-26b-a4b` | Best Gemma throughput candidate because it is MoE |
| 2 | `nemotron35-lightning` | Official one-Spark vLLM recipe with DSpark speculative decoding |
| 3 | `nemotron3-omni` | Official image, audio, video, OCR, and document path |
| 4 | `gemma4-31b` | Experimental dense quality comparison; not yet marked Spark-verified |
| 5 | Muse Glimmer 30B | Hold until the local path is verified after its very recent release |

Do not make every profile restart automatically. A model earns 24/7 status only after raw API, LiteLLM, Hermes text, and Hermes tool tests succeed.

## What to do when Qwen 3.8 is released

Do not replace `spark-fast` on release day. Use this intake sequence:

1. Confirm the official publisher and exact model ID.
2. Read the license and model card.
3. Confirm that the checkpoint is downloadable and that its runtime supports GB10/SM121.
4. Choose one initial format: Hugging Face/vLLM for tuned serving, Ollama for convenience, or LM Studio for GUI testing.
5. Give it a new service folder, container name, port, and descriptive model alias.
6. Download it without deleting Qwen 35B or Qwen 27B.
7. Stop the active large model before the first load.
8. Test the raw endpoint, LiteLLM, Hermes chat, and tool calls.
9. Compare quality and speed with the existing Qwen profiles.
10. Change the stable default only after the comparison passes.

This keeps Qwen 3.8 easy to add without damaging the currently working installation.

## Primary references

- [NVIDIA DGX Spark playbooks](https://build.nvidia.com/spark)
- [NVIDIA vLLM on Spark](https://build.nvidia.com/spark/vllm/instructions)
- [NVIDIA Nemotron on Spark](https://build.nvidia.com/spark/nemotron)
- [NVIDIA LM Studio on Spark](https://build.nvidia.com/spark/lm-studio/instructions)
- [Ollama hardware support](https://docs.ollama.com/gpu)

Related: [[DGX Spark Model Installation And Switching Guide]] | [[DGX Spark Multi-Model Runtime Research]] | [[Local Setup Index]]
