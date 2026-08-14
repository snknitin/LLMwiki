# DGX Spark Additional Models And Convenience Runtimes Research

> Research snapshot: 2026-08-14  
> Purpose: primary-source evidence for the next beginner tutorials. This is not itself the copy-paste installation runbook.  
> Existing setup assumed: [[DGX Spark Operations Setup Guide]] through Step 13 and the first two model tests in [[DGX Spark Model Installation And Switching Guide]].

## Scope and current machine state

This note verifies:

- `nvidia/Gemma-4-26B-A4B-NVFP4`
- `nvidia/Gemma-4-31B-IT-NVFP4`
- `nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4`
- `nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4`
- the MiaAI-Lab Nemotron 3.5 Lightning DGX Spark recipe
- `meta-models/Muse-Glimmer-30B`
- Ollama on ARM64 / DGX Spark, including storage and API behavior
- ODS, LiteLLM, and Open WebUI connectivity
- LM Studio headless mode, LM Link, and just-in-time model loading

The machine state reported immediately before this research was:

```text
vllm-spark-fast: running and healthy on 127.0.0.1:8000
Ollama: not installed
LM Studio CLI: installed at /home/snknitin/.lmstudio/bin/lms
LM Studio CLI commit: 71bd99c
RAM: 121 GiB total, 100 GiB used, about 20 GiB available
Swap: 4.1 GiB used
Home filesystem: about 3.2 TiB free
```

The immediate operational consequence is simple: **stop the current large Qwen/vLLM worker and confirm memory has been released before starting any model below.** Downloading a model can happen while another model is running, but loading a second large model into unified memory should not.

## Executive decisions

| Candidate | One DGX Spark? | Primary runtime | Tutorial decision |
|---|---:|---|---|
| Gemma 4 26B A4B NVFP4 | Yes, officially verified | vLLM | Write a normal separate tutorial; best next low-risk Gemma test. |
| Gemma 4 31B IT NVFP4 | Likely fits, but the current official recipe does not mark Spark verified | vLLM | Write an **experimental** tutorial with conservative context and concurrency. Do not describe it as NVIDIA-validated on Spark. |
| Nemotron 3 Nano Omni 30B A3B Reasoning NVFP4 | Yes, official Spark command exists | vLLM 0.20.0 | Write a separate multimodal tutorial because audio packages and media-path security differ from text-only models. |
| Nemotron 3.5 Lightning 30B A3B NVFP4 | Yes, officially validated | vLLM 0.27.1 | Make the official vLLM recipe the main tutorial. Put the MiaAI-Lab SGLang recipe in an optional advanced appendix. |
| Muse Glimmer 30B | Yes; public checkpoint and official vLLM Spark recipe exist | vLLM pre-release Muse image | It is **not NIM-only**, but give it a separate advanced tutorial and mark the image/tooling as pre-release until a working digest is recorded. |
| Ollama | Yes | Current native ARM64 Ollama service | Install as a convenience runtime on a non-conflicting port. Do not use the old ODS Ollama extension for new 2026 model tags. |
| LM Studio / llmster | Already installed | LM Studio headless daemon plus LM Link | Do not reinstall. Configure Link and JIT loading; keep it a separate runtime and model store. |

## The architecture these tutorials should preserve

The model files used by vLLM, Ollama, and LM Studio are not one interchangeable library:

| Runtime | Native store | What other components should consume |
|---|---|---|
| vLLM / Hugging Face | `~/.cache/huggingface` | OpenAI-compatible API |
| Ollama | `/usr/share/ollama/.ollama/models` by default for the system service, or the directory set by `OLLAMA_MODELS` | Ollama HTTP API |
| LM Studio | `~/.lmstudio/models` | LM Studio OpenAI-compatible API or LM Link |

ODS, LiteLLM, Hermes, and Open WebUI should talk to these runtimes through HTTP APIs. They do not need direct access to the model files. Copying, hard-linking, or symlinking files between the three native stores is not recommended because their manifests, quantizations, and layouts differ.

For the first round of testing, retain the single-large-worker policy already established in [[DGX Spark Multi-Model Runtime Research]]:

1. Download while the currently selected worker is running if disk and network allow it.
2. Drain active requests.
3. Stop the current large worker.
4. Confirm memory recovery with `free -h` and confirm no unexpected inference container is running.
5. Start and warm the next worker.
6. Verify `/v1/models`, a short chat response, reasoning behavior, and tool-call behavior.
7. Only then point a stable LiteLLM alias at it.

This is why several model profiles can be *installed and visible* while only one is loaded into the Spark's 128 GB unified memory.

## Verified model identities and download sizes

These are current repository identities, not friendly aliases. Pin the repository revision in the eventual tutorial after the first successful test.

| Model | Public/gated | Reported repository storage | Current revision observed |
|---|---|---:|---|
| `nvidia/Gemma-4-26B-A4B-NVFP4` | Public, ungated | 17.53 GiB | `a19cfe00be84568a6867111c9a68c9c44fdcffe6` |
| `nvidia/Gemma-4-31B-IT-NVFP4` | Public, ungated | 30.42 GiB | `4135a98a9b728a548947683219633b25682223ac` |
| `nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4` | Public, ungated | 20.89 GiB | `dc5f0b0bfddf8b6e0f5891475be9af05b80126fe` |
| `nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4` | Public, ungated | 23.45 GiB | `6dbbd757ea75a8ece6e0702872e3ae53f9987728` |
| `nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DSpark` | Public, ungated | 1.26 GiB | `d10c6ff40d6e69d1f92e407e027de3eafdb77645` |
| `meta-models/Muse-Glimmer-30B` | Public, ungated | 55.49 GiB | `a4e59da52a7bc87ae7251dd5545c0dd437c44b68` |
| `meta-models/Muse-Glimmer-30B-assistant` | Public, ungated | 4.76 GiB | `e8192f3a8f617f74be2ce220360c89ef4789f39f` |

Repository storage is not the same as loaded memory. Context length, KV cache, CUDA graphs, runtime workspaces, multimodal inputs, and speculative decoding add memory above the checkpoint size. Sources: the current [Hugging Face model API for Gemma 26B](https://huggingface.co/api/models/nvidia/Gemma-4-26B-A4B-NVFP4), [Gemma 31B](https://huggingface.co/api/models/nvidia/Gemma-4-31B-IT-NVFP4), [Nemotron Omni](https://huggingface.co/api/models/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4), [Nemotron 3.5 Lightning](https://huggingface.co/api/models/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4), [its DSpark draft](https://huggingface.co/api/models/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DSpark), [Muse Glimmer](https://huggingface.co/api/models/meta-models/Muse-Glimmer-30B), and [Muse assistant](https://huggingface.co/api/models/meta-models/Muse-Glimmer-30B-assistant).

## Gemma 4 26B A4B NVFP4

### Verified facts

The NVIDIA model card identifies this as a 25.2B-parameter mixture-of-experts model with about 3.8B active parameters, 256K context, text and image input, Blackwell support, and tensor parallel size 1. Its license is Apache 2.0. The card's minimum serve command is:

```bash
vllm serve nvidia/Gemma-4-26B-A4B-NVFP4 \
  --tool-call-parser gemma4 \
  --reasoning-parser gemma4 \
  --enable-auto-tool-choice \
  --trust-remote-code
```

Source: [NVIDIA Gemma 4 26B A4B NVFP4 model card](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4).

The maintained vLLM recipe explicitly lists **DGX Spark / GB10** as verified. Its Spark-specific `nvidia_nvfp4` configuration uses:

```text
image: vllm/vllm-openai:gemma4-0505-cu130
model: nvidia/Gemma-4-26B-A4B-NVFP4
VLLM_USE_V2_MODEL_RUNNER=1
gpu-memory-utilization: 0.8
max-num-seqs: 8
load-format: fastsafetensors
enable-prefix-caching
enable-auto-tool-choice
tool-call-parser: gemma4
reasoning-parser: gemma4
max-num-batched-tokens: 8192
```

Source: [official vLLM Gemma 4 26B recipe](https://github.com/vllm-project/recipes/blob/main/models/Google/gemma-4-26B-A4B-it.yaml).

### Tutorial recommendation

Use the recipe image and arguments above, but give this worker a unique container name, service folder, served-model alias, and host port. Join the existing ODS Docker network only after the standalone health test passes. Start with the official 0.8 memory utilization rather than raising it.

This is the best next Gemma test because the exact NVIDIA checkpoint and DGX Spark combination are officially represented in the current vLLM recipe.

## Gemma 4 31B IT NVFP4

### What is verified and what is not

The NVIDIA model card identifies a 30.7B dense multimodal model with 256K context. It documents vLLM with ModelOpt quantization, but its shown command is an eight-GPU data-center example:

```bash
vllm serve /models/gemma-4-31b-it-nvfp4 \
  --quantization modelopt \
  --tensor-parallel-size 8
```

That is **not** a single-DGX-Spark recipe. Source: [NVIDIA Gemma 4 31B IT NVFP4 model card](https://huggingface.co/nvidia/Gemma-4-31B-IT-NVFP4).

The maintained vLLM recipe includes `nvidia/Gemma-4-31B-IT-NVFP4`, one-GPU tensor parallelism, and a 19 GB minimum profile. However, its verified-hardware matrix currently does not list DGX Spark / GB10 for the 31B model. Source: [official vLLM Gemma 4 31B recipe](https://github.com/vllm-project/recipes/blob/main/models/Google/gemma-4-31B-it.yaml).

The checkpoint size makes a one-Spark experiment plausible, but **fit is an inference from size and the one-GPU recipe, not an official Spark validation**. The eventual tutorial should begin conservatively: 64K context, memory utilization around 0.80, and one to four sequences. Increase only after the model has passed load, prompt, image, tool, and memory-pressure tests.

### Tutorial recommendation

Write this as an experimental separate profile. Do not copy the `--tensor-parallel-size 8` example. Use tensor parallel size 1 on a single Spark. Record the exact container image digest and benchmark results after the first successful run.

## Nemotron 3 Nano Omni 30B A3B Reasoning NVFP4

### Verified facts

The official card describes a hybrid Mamba2/Transformer MoE with about 31B total and 3B active parameters. It supports text, image, audio, and video input, 256K context, reasoning, JSON, and tool calling. Output is English. The model is licensed under the NVIDIA Open Model License Agreement. Source: [NVIDIA Nemotron 3 Nano Omni model card](https://huggingface.co/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4).

The current official Spark recipe requires vLLM `0.20.0`, CUDA 13, and the `vllm[audio]` extra. Its published container pattern is:

```bash
WEIGHTS=/path/to/nemotron-3-nano-omni-weights

docker run --rm -it \
  --gpus all \
  --ipc=host \
  -p 8000:8000 \
  --shm-size=16g \
  --name vllm-nemotron-omni \
  -v "${WEIGHTS}:/model:ro" \
  --entrypoint /bin/bash \
  vllm/vllm-openai:v0.20.0 -c \
  "pip install 'vllm[audio]' && vllm serve /model \
  --served-model-name=nemotron_3_nano_omni \
  --max-num-seqs 8 \
  --max-model-len 131072 \
  --port 8000 \
  --trust-remote-code \
  --gpu-memory-utilization 0.8 \
  --limit-mm-per-prompt '{\"video\": 1, \"image\": 1, \"audio\": 1}' \
  --media-io-kwargs '{\"video\": {\"fps\": 2, \"num_frames\": 256}}' \
  --allowed-local-media-path=/ \
  --enable-prefix-caching \
  --max-num-batched-tokens 32768 \
  --reasoning-parser nemotron_v3 \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder"
```

The card says to lower maximum context to 32768 and memory utilization to 0.70 if the Spark is under memory pressure.

### Tutorial cautions

- Do not add `pip install` to every container startup indefinitely. For a persistent deployment, build and pin a tiny derived image containing the audio extra, then record its digest.
- The official `--allowed-local-media-path=/` permits the server to read any host path visible inside the container. A safer adaptation is to create a dedicated media directory, mount it read-only at `/media`, and set `--allowed-local-media-path=/media`. Test that adaptation because it is intentionally narrower than the published command.
- Use a unique host port and bind it to `127.0.0.1` unless ODS must reach it through a Docker network.
- Because this is multimodal, the tutorial needs separate smoke tests for text, one image, one short audio clip, and one short video. A text-only health check is insufficient.

## Nemotron 3.5 Lightning 30B A3B NVFP4

### Prefer the official current recipe

NVIDIA now publishes an exact one-DGX-Spark recipe for `nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4`, including its companion DSpark draft checkpoint. The card identifies 30B total / about 3B active parameters and a 1M-token context claim. It validates a single DGX Spark and currently specifies vLLM `v0.27.1`. Source: [NVIDIA Nemotron 3.5 Lightning model card](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4) and [NVIDIA Build recipe](https://build.nvidia.com/nvidia/nemotron-3.5-lightning-30b-a3b).

The current official vLLM command is:

```bash
export MODEL_CKPT=nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4
export DSPARK_CKPT=nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DSpark

vllm serve --model "$MODEL_CKPT" \
  --moe-backend marlin \
  --kv-cache-dtype fp8 \
  --enable-prefix-caching \
  --gpu-memory-utilization 0.91 \
  --speculative_config.num_speculative_tokens 3 \
  --mamba-backend flashinfer \
  --mamba-cache-mode align \
  --reasoning-parser nemotron_v3 \
  --speculative_config.model "$DSPARK_CKPT" \
  --tool-call-parser qwen3_coder \
  --enable-auto-tool-choice
```

The tutorial should containerize this with `vllm/vllm-openai:v0.27.1`, use the existing Hugging Face cache, and assign a unique served-model name and port. The published 0.91 memory utilization is aggressive; only use it when the previous large worker is fully stopped and memory recovery has been verified.

The card also documents:

- Ollama `v0.32.9`: `ollama run nemotron-3.5-lightning`
- GGUF: `ggml-org/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF`
- llama.cpp via `llama-server -hf ... --port 8000`

The Hugging Face card states the OpenMDW 1.1 license. The eventual tutorial should link that license and avoid substituting a different NVIDIA license label from Build-page UI metadata.

### How the MiaAI-Lab recipe differs

Community source: [MiaAI-Lab Nemotron 3.5 Lightning DGX Spark repository](https://github.com/MiaAI-Lab/Nemotron3.5-Lightning-DGX-Spark-RTX-5090-6000-PRO).

Its beginner entry point is:

```bash
git clone https://github.com/MiaAI-Lab/Nemotron3.5-Lightning-DGX-Spark-RTX-5090-6000-PRO.git
cd Nemotron3.5-Lightning-DGX-Spark-RTX-5090-6000-PRO
chmod +x start.sh
./start.sh
```

It also offers `./start.sh --download-only`. The current script uses:

```text
main checkpoint: nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4
draft checkpoint: nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DSpark
image: lmsysorg/sglang:dev-nemotron3-5-lightning
container: nemotron-3.5-lightning-dspark
default port: 8888
default host: 0.0.0.0
Hugging Face cache: ~/.cache/huggingface
memory fraction: 0.78
speculative algorithm: DSpark, block size 3
reasoning parser: nemotron_3
tool parser: qwen3_coder
```

Important differences from the controlled ODS/vLLM profiles:

- It uses SGLang, not vLLM.
- It pulls a mutable `dev` image instead of a versioned release image.
- It uses host networking and exposes the endpoint on all interfaces by default.
- Starting it removes and recreates any existing container with the same name.
- It does not automatically join the ODS Docker network.

Therefore, the community recipe belongs in an **optional advanced appendix**, not as the default beginner path. If it is tested, clone it under `~/src`, record the Git commit, run download-only first, inspect the script, resolve and pin the image digest, stop the current worker, and restrict access to loopback or Tailscale. Do not run an unreviewed `start.sh` as the permanent 24/7 service.

## Muse Glimmer 30B

### It is locally runnable and not NIM-only

The NVIDIA Build catalog lists `meta/muse-glimmer-30b`, 30B parameters, 131K context, text and image input, a downloadable model, a free hosted endpoint, and the NIM image `nvcr.io/nim/meta/muse-glimmer:latest`. Source: [NVIDIA Build Muse Glimmer page](https://build.nvidia.com/meta/muse-glimmer-30b).

The original Meta checkpoint `meta-models/Muse-Glimmer-30B` is public, ungated, and Apache 2.0. Its model card describes local/offline use and 4-bit variants below 20 GB. Source: [Meta Muse Glimmer 30B model card](https://huggingface.co/meta-models/Muse-Glimmer-30B).

The maintained vLLM recipe explicitly lists DGX Spark / GB10 as verified with one GPU and tensor parallel size 1. It uses:

```text
image: vllm/vllm-openai:muse-glimmer
tool-call-parser: muse_glimmer
reasoning-parser: muse_glimmer
generation-config: auto
```

A minimal form of the recipe is:

```bash
vllm serve /model \
  --served-model-name muse-glimmer \
  --tensor-parallel-size 1 \
  --enable-auto-tool-choice \
  --tool-call-parser muse_glimmer \
  --reasoning-parser muse_glimmer \
  --generation-config auto
```

The optional DFlash assistant is `meta-models/Muse-Glimmer-30B-assistant`:

```text
--speculative-config '{"method":"dflash","model":"meta-models/Muse-Glimmer-30B-assistant","num_speculative_tokens":15}'
```

Source: [official vLLM Muse Glimmer recipe](https://github.com/vllm-project/recipes/blob/main/models/meta-models/Muse-Glimmer-30B.yaml).

### Why it still needs a separate advanced tutorial

The vLLM recipe currently describes its Muse support and image as unreleased or coming soon. The `muse-glimmer` image tag is less stable than a normal numbered release, so the first working image digest must be recorded before calling the profile reproducible. Muse's tool calls use its own XML/ATEM format; using a Qwen or Hermes parser would be incorrect.

The recipe's smaller NVFP4 option is currently the third-party checkpoint `Inferact/Muse-Glimmer-30B-NVFP4-W4A4`, not a Meta-owned quantization. Do not silently replace the original checkpoint with it. If that variant is used, label its provenance and verify its license and outputs independently.

Decision: create a separate Muse tutorial, but mark it **advanced / pre-release**. Test the base model without DFlash first, then add the assistant only after ordinary completions, reasoning, and tool calls pass. NIM is an alternative container, not the only way to run the model locally.

## Ollama on DGX Spark

### Installation and hardware support

Ollama's official Linux installer is:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

The explicit ARM64 archive route is:

```bash
curl -fsSL https://ollama.com/download/ollama-linux-arm64.tar.zst | sudo tar x -C /usr
```

The official documentation also gives a systemd service definition for persistent headless operation. Sources: [Ollama Linux installation](https://docs.ollama.com/linux) and [Ollama GPU support](https://docs.ollama.com/gpu). The GPU table includes DGX Spark GB10 compute capability 12.1.

For a beginner tutorial, use the official installer, verify the architecture with `uname -m`, and inspect the generated service before adding overrides. Do not pipe an installer into `sudo` without first opening the official script or at least confirming the URL and HTTPS certificate.

### Storage, binding, and load behavior

Official defaults and controls:

- The Linux system service stores models at `/usr/share/ollama/.ollama/models` by default.
- `OLLAMA_MODELS` changes the store. The service user must own or have read/write access to it.
- The API listens on `127.0.0.1:11434` by default.
- `OLLAMA_HOST` changes the address and port.
- A model normally stays loaded for five minutes after use. API `keep_alive` changes that, and `ollama stop MODEL` unloads it.
- Multiple models remain loaded only when memory permits; otherwise requests wait and models are unloaded/reloaded.

Source: [Ollama FAQ](https://docs.ollama.com/faq).

This setup has an important port conflict: ODS already uses port `11434` for its own llama-server in the local plan. The new Ollama tutorial should therefore place current Ollama on a different loopback port, such as `127.0.0.1:11435`, unless a fresh inspection proves 11434 is free.

If the chosen model store is under `~/ai/stores`, do not make the service follow a home-directory symlink blindly. Set `OLLAMA_MODELS` to the real absolute directory and grant only the `ollama` service user ownership of that directory. Back up or inspect before changing ownership; never run a recursive `chown` against all of `$HOME`.

### Models currently relevant to this machine

Current official Ollama library tags include:

- `gemma4:26b-a4b-it-qat` - about 16 GB
- `gemma4:31b-it-qat` - about 19 GB
- `nemotron3:33b` - about 28 GB; the present tag listing advertises text and image, so do not promise full audio/video support through Ollama
- `nemotron-3.5-lightning` - documented by NVIDIA for Ollama `v0.32.9`

Sources: [Ollama Gemma 4 tags](https://ollama.com/library/gemma4/tags), [Ollama Nemotron 3 tags](https://ollama.com/library/nemotron3/tags), and the [NVIDIA Nemotron 3.5 card](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4).

Do not download every quantization. Choose one tag, record `ollama show MODEL`, and test it. A 16-28 GB checkpoint still consumes additional unified memory for context and runtime state.

### ODS and Open WebUI integration

The current public ODS repository has an Ollama extension, but its compose file pins `ollama/ollama:0.5.7` and an 8 GB memory limit, exposes host port 7804, and stores data in the extension directory. That image is far older than the `0.32.9` version documented for Nemotron 3.5 Lightning. Sources: [ODS Ollama compose file](https://github.com/Osmantic/ODS/blob/main/ods/extensions/library/services/ollama/compose.yaml) and [ODS Ollama extension README](https://github.com/Osmantic/ODS/blob/main/ods/extensions/library/services/ollama/README.md).

Therefore:

- Do **not** use that old extension as the primary new Ollama runtime unless the installed ODS checkout has been updated and verified.
- Prefer a current native Ollama system service on a non-conflicting port, or a separately pinned current Ollama container.
- Before writing final commands, inspect the user's installed ODS version; the GitHub `main` branch may not match the machine.

Open WebUI's official documentation says a container connects to host Ollama through `http://host.docker.internal:11434`. For this setup's proposed custom port, the equivalent is `http://host.docker.internal:11435`, provided the ODS compose stack defines a host-gateway mapping and Ollama is listening on a host address reachable from Docker. Source: [Open WebUI - connect to Ollama](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-ollama/).

Do not install NVIDIA's bundled Open WebUI playbook on top of ODS: it would create a second UI and another data volume. Use the existing ODS Open WebUI and add a connection.

LiteLLM's provider name should be `ollama_chat/<exact-tag>` for chat models, with the current Ollama API base. Source: [LiteLLM Ollama provider documentation](https://docs.litellm.ai/docs/providers/ollama). Keep the Ollama tag visible in the internal model name, then expose a friendly stable alias separately.

### Network safety

Ollama does not add API authentication by default. For the first test, bind it to loopback. If ODS containers need the endpoint, expose only the minimum reachable host address and restrict access with the host firewall or Tailscale policy. Do not bind `0.0.0.0` to the LAN merely to make a Docker connection work.

## LM Studio, llmster, and LM Link

### Do not reinstall

`lms` already works on the Spark and reports a valid CLI commit. The next tutorial should begin with verification, not installation:

```bash
command -v lms
lms --version
lms ls
```

The NVIDIA DGX Spark playbook's basic local-server form is:

```bash
lms server start --bind 0.0.0.0 --port 1234
```

It also demonstrates:

```bash
lms get nvidia/nemotron-3-nano-omni
lms ls
lms load nvidia/nemotron-3-nano-omni
```

Source: [NVIDIA DGX Spark LM Studio playbook](https://build.nvidia.com/spark/lm-studio/instructions).

For this user's multi-device setup, LM Link is safer and easier than exposing `0.0.0.0:1234` to the LAN.

### Headless LM Link

On the Spark:

```bash
lms daemon up
lms login
lms link enable
```

Then enable LM Link in the desktop/laptop LM Studio application while signed into the same account. The Spark appears as a remote device and its downloaded models appear in the model loader. Source: [LM Link - add a device](https://lmstudio.ai/docs/lmlink/basics/add-device) and [LM Studio headless mode](https://lmstudio.ai/docs/developer/core/headless).

LM Link uses its own private device mesh. It can coexist with Tailscale; it does not replace Tailscale for SSH, ODS, Hermes, or other services.

### JIT loading behavior

LM Studio's headless server supports just-in-time loading. A request to a downloaded model can load it automatically. Current documented defaults are:

- JIT loading enabled
- 60-minute TTL for a JIT-loaded model
- auto-evict enabled, so at most one JIT-loaded model stays resident
- a model loaded manually with `lms load` has no TTL unless `--ttl` is supplied

Source: [LM Studio TTL and auto-evict documentation](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict).

This behavior is well suited to trying many GGUF models on one Spark: they can all remain downloaded and visible, while only the selected model occupies unified memory. Switching is not instantaneous because the old weights must be evicted and the new weights read from disk.

LM Studio models remain in `~/.lmstudio/models`. They are separate from Hugging Face/vLLM and Ollama stores. ODS or Open WebUI can use the LM Studio OpenAI-compatible API, but they cannot treat LM Studio's store as a vLLM or Ollama store.

### LM Studio network safety

Use LM Link for desktop/laptop access whenever possible. If a raw API endpoint is needed, first bind to loopback and test locally. Only then bind to the Spark's Tailscale address or a carefully firewalled interface. A bare `0.0.0.0:1234` endpoint should not be treated as authenticated.

## Required checks before the tutorials give copy-paste commands

Run these read-only checks on the Spark first:

```bash
uname -m
docker version --format '{{.Server.Version}}'
docker network ls
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
ss -lntp | grep -E ':(4000|7804|8000|8001|8888|11434|11435|1234)\b' || true
free -h
df -hT "$HOME"
systemctl status ollama --no-pager 2>/dev/null || true
systemctl --user status lmstudio --no-pager 2>/dev/null || true
lms status 2>/dev/null || true
```

Beginner interpretation:

- `LISTEN` means a port is already in use; do not reuse it.
- An active model container means its memory may still be allocated.
- `free -h` should show the expected memory recovery after the old worker stops.
- A missing Ollama service is expected before installation.
- An `lms` status error may mean the daemon is not running, not that LM Studio must be reinstalled.

## Unverified or deliberately deferred items

The tutorials must label these instead of guessing:

1. **Gemma 4 31B NVFP4 on one Spark:** plausible and supported by a one-GPU recipe, but not currently marked DGX Spark verified in the official recipe.
2. **Exact vLLM Muse image digest:** the official recipe uses `vllm/vllm-openai:muse-glimmer` and says support is forthcoming. Resolve and record a working digest at installation time.
3. **Muse third-party NVFP4 quality:** `Inferact/Muse-Glimmer-30B-NVFP4-W4A4` is not the original Meta repository. It needs independent license and quality validation.
4. **Installed ODS external-provider feature set:** inspect the actual checkout and version on the Spark. Do not assume GitHub `main` matches the installation.
5. **Host access from the ODS Docker network:** verify `host.docker.internal` or the configured host-gateway route on this Linux Docker installation before publishing the Ollama API base.
6. **Full Omni modalities in Ollama:** the current Ollama Nemotron tag page lists text/image for the available tag. Use vLLM for the first verified audio/video Omni deployment.
7. **LM Studio service persistence:** determine whether this installation already has a user service for `lms daemon`; do not create a duplicate service.

## Recommended tutorial order

1. Gemma 4 26B A4B NVFP4 with the officially verified vLLM Spark recipe.
2. Nemotron 3.5 Lightning with official vLLM 0.27.1 and the DSpark draft.
3. Nemotron 3 Nano Omni with a pinned derived vLLM 0.20.0 audio image and a restricted media mount.
4. Gemma 4 31B as an experimental conservative profile.
5. Muse Glimmer as an advanced/pre-release profile after resolving the image digest.
6. Current Ollama native ARM64 service on a non-conflicting loopback port, then add only selected convenience tags.
7. LM Link and JIT loading using the already installed `lms` CLI.
8. MiaAI-Lab Nemotron 3.5 SGLang route only as a benchmark/advanced alternative.

This order separates well-supported Spark recipes from experimental integrations and avoids downloading duplicate quantizations before a runtime has proved useful.

## Primary sources

### Models and recipes

- [NVIDIA Gemma 4 26B A4B NVFP4](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)
- [vLLM Gemma 4 26B recipe](https://github.com/vllm-project/recipes/blob/main/models/Google/gemma-4-26B-A4B-it.yaml)
- [NVIDIA Gemma 4 31B IT NVFP4](https://huggingface.co/nvidia/Gemma-4-31B-IT-NVFP4)
- [vLLM Gemma 4 31B recipe](https://github.com/vllm-project/recipes/blob/main/models/Google/gemma-4-31B-it.yaml)
- [NVIDIA Nemotron 3 Nano Omni](https://huggingface.co/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4)
- [NVIDIA Nemotron 3.5 Lightning](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4)
- [NVIDIA Build Nemotron 3.5 Lightning](https://build.nvidia.com/nvidia/nemotron-3.5-lightning-30b-a3b)
- [MiaAI-Lab Nemotron 3.5 Lightning Spark recipe](https://github.com/MiaAI-Lab/Nemotron3.5-Lightning-DGX-Spark-RTX-5090-6000-PRO)
- [Meta Muse Glimmer 30B](https://huggingface.co/meta-models/Muse-Glimmer-30B)
- [NVIDIA Build Muse Glimmer](https://build.nvidia.com/meta/muse-glimmer-30b)
- [vLLM Muse Glimmer recipe](https://github.com/vllm-project/recipes/blob/main/models/meta-models/Muse-Glimmer-30B.yaml)

### Convenience runtimes and integration

- [Ollama Linux installation](https://docs.ollama.com/linux)
- [Ollama GPU support](https://docs.ollama.com/gpu)
- [Ollama FAQ](https://docs.ollama.com/faq)
- [LiteLLM Ollama provider](https://docs.litellm.ai/docs/providers/ollama)
- [Open WebUI - connect to Ollama](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-ollama/)
- [ODS Ollama compose file](https://github.com/Osmantic/ODS/blob/main/ods/extensions/library/services/ollama/compose.yaml)
- [ODS Ollama extension README](https://github.com/Osmantic/ODS/blob/main/ods/extensions/library/services/ollama/README.md)
- [NVIDIA DGX Spark LM Studio playbook](https://build.nvidia.com/spark/lm-studio/instructions)
- [LM Link - add a device](https://lmstudio.ai/docs/lmlink/basics/add-device)
- [LM Studio headless mode](https://lmstudio.ai/docs/developer/core/headless)
- [LM Studio TTL and auto-evict](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict)

