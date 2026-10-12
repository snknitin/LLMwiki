---
updated: 2026-09-28
status: research-ready; runtime-unverified
machine: Windows RTX PRO 5000 Blackwell workstation
---

# Qwen Image 2.1 base on the Windows workstation

## Goal and placement

Run the official Qwen Image 2.1 image generator/editor in an isolated ComfyUI installation on the Windows RTX PRO 5000 Blackwell (48,935 MiB VRAM). This is the shared prerequisite for the BFS body/head tutorials and the uncensored comparison. No image runtime, checkpoint, or LoRA has been installed or tested as part of writing this note. Keep workstation Ollama, ODS, LM Studio, Hermes, and Spark routes independent of this image lab. The local machine placement follows [[Local Setup Index]].

Qwen describes a 7B image transformer that handles text-to-image, image editing, transparency, and up to ten reference images. Its HF license is **Qwen Research**, so read the license before any commercial use. The Comfy-Org package is a ComfyUI repack of the official weights, with separate diffusion model, Qwen3-VL text encoder, and VAE; the 7B/14.23 GB denoiser figure does **not** include the encoder or VAE. [Qwen model card](https://huggingface.co/Qwen/Qwen-Image-2.1), [Comfy-Org package](https://huggingface.co/Comfy-Org/Qwen-Image-2.1)

## Choose one starting lane

| Lane | Files | Why/when |
|---|---|---|
| ComfyUI INT8 ConvRot baseline | `qwen_image_2.1_int8_convrot.safetensors` (7.26 GB), `qwen3vl_8b_int8_convrot.safetensors` (9.35 GB), `qwen_image_2.1_vae_bf16.safetensors` (676 MB) | Start here: matches the current official Comfy workflow defaults and leaves VRAM room for 2K edits and LoRAs. |
| ComfyUI BF16 quality comparison | `qwen_image_2.1_bf16.safetensors` (14.23 GB), `qwen3vl_8b_bf16.safetensors` (17.53 GB), same VAE | Try only after the first pass. Disk weights total about 32.4 GB; runtime activations and input images add memory, so 48 GB is not a guarantee for every 2K/multi-reference job. |
| Unsloth GGUF | One denoiser GGUF plus a compatible text encoder and VAE | Useful for lower VRAM, but the captured 6/12 GB claims are offload scenarios, not a measure of this workstation’s best path. This GGUF uses a different loader/runtime; do not mix it into the first ComfyUI baseline. |

File sizes and folder names are from the [Comfy-Org repository tree](https://huggingface.co/Comfy-Org/Qwen-Image-2.1/tree/main). The [Unsloth card](https://huggingface.co/unsloth/Qwen-Image-2.1-GGUF) explicitly says its GGUF is the denoiser only. A reply to the [captured Unsloth X post](https://x.com/UnslothAI/status/2102431304591761728?s=20) highlights that the encoder and VAE affect the advertised VRAM figure; other replies ask for quality comparisons and report mixed subjective results. Treat the “Nano Banana 2.0 parity” statement as the author’s claim, not an established benchmark for this machine.

Reply-level tips from that exact X thread: [Unsloth says](https://x.com/i/status/2102551183001100776) FP8/GGUF generation and editing run in Unsloth Desktop; this does not verify the ComfyUI lane. A [user reports](https://x.com/i/status/2102455516601753879) a Diffusers 0.40.0 version error requiring 0.41.0 for `QwenImage21Pipeline`, so use Qwen's current git-Diffusers instructions if choosing Python/Diffusers rather than ComfyUI. A [12 GB VRAM objection](https://x.com/i/status/2102776633778434446) points out encoder/VAE overhead. Another [reply asks for measured quality parity](https://x.com/i/status/2102772055389450590); a [negative quality report](https://x.com/i/status/2102754719194075228) is an anecdote without its prompt, settings, or outputs. These support the controlled local comparison above, not a quality verdict. A [missing `httpx` report](https://x.com/i/status/2102654015331078157) and a [Spark failure report](https://x.com/i/status/2102625146431569964) should be recorded with full errors if reproduced; neither changes the Windows ComfyUI setup.

## Step 1 — Establish an isolated ComfyUI installation

On the **Windows desktop**, inspect `nvidia-smi`, available disk space, and any existing ComfyUI installation. Use a separate portable ComfyUI directory for this lab if an existing installation has production workflows. Follow the [official Windows portable instructions](https://docs.comfy.org/installation/comfyui_portable_windows): the modern NVIDIA package is CUDA 13/Python 3.13, launches with `run_nvidia_gpu.bat`, and has an independent `python_embeded` environment. Do not add `--listen`; access the default loopback UI at `http://127.0.0.1:8188`.

```powershell
nvidia-smi
Get-PSDrive -PSProvider FileSystem | Select-Object Name,Free
```

**Pass:** ComfyUI starts, identifies the Blackwell GPU, and shows a loopback URL. If `TextEncodeQwenImage21` is missing, update that isolated ComfyUI to a build that supports Qwen Image 2.1 before downloading more weights. The official templates warn that Desktop/stable can trail newer model support. Do not force upgrades into an existing unrelated installation. [Comfy workflow templates](https://github.com/Comfy-Org/workflow_templates/tree/main/templates)

## Step 2 — Get exactly the three baseline files

Using the HF web file links, place **only one** precision choice for the diffusion model and encoder in the isolated installation:

```text
ComfyUI_windows_portable/ComfyUI/models/
  diffusion_models/qwen_image_2.1_int8_convrot.safetensors
  text_encoders/qwen3vl_8b_int8_convrot.safetensors
  vae/qwen_image_2.1_vae_bf16.safetensors
```

Direct files: [INT8 diffusion](https://huggingface.co/Comfy-Org/Qwen-Image-2.1/blob/main/diffusion_models/qwen_image_2.1_int8_convrot.safetensors), [INT8 encoder](https://huggingface.co/Comfy-Org/Qwen-Image-2.1/blob/main/text_encoders/qwen3vl_8b_int8_convrot.safetensors), [VAE](https://huggingface.co/Comfy-Org/Qwen-Image-2.1/blob/main/vae/qwen_image_2.1_vae_bf16.safetensors). Keep the exact filenames. Confirm sizes and SHA-256 locally; record the HF revision and hashes in the run log before evaluating. Prompt enhancer models are optional additional 9.47 GB files, **not** needed for the initial model test. The official T2I template currently references one; disable or bypass its prompt-enhancer input if you have not downloaded it.

## Step 3 — Baseline text-to-image and editing

Open the [official ComfyUI text-to-image workflow](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_t2i.json) and select the installed diffusion model, encoder, and VAE in its subgraph. It starts at 1024×1024, 25 steps, Euler/simple, CFG 1. Use a fixed seed and a prompt containing an exact short phrase, e.g. `A clean blue shop sign reading LOCAL IMAGE LAB, rainy street`. Save the result and log seconds/image and `nvidia-smi` peak VRAM. Then use the [official image-edit workflow](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_image_edit.json) with an image you own and a narrow color/object edit. The first image is the edit target; subsequent images are references, referred to as `<image1>`, `<image2>`, etc. The saved example image filenames must be replaced with your local images.

The official template says CFG 1 ignores the negative prompt, uses 25 steps as a starting point, and suggests 40–50 Euler steps for a quality pass. Keep the first run at 1024; advance to 2048 only after a stable 1024 run. For transparent output, use the [Qwen card’s explicit RGBA prompt pattern](https://huggingface.co/Qwen/Qwen-Image-2.1) and save PNG; visually inspect the alpha channel, not only the preview. Keep resolution in multiples of 32. [Official T2I template](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_t2i.json), [official edit template](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_image_edit.json)

## Step 4 — Compare precisions only if useful

After saving the INT8 baseline, swap **one component at a time**: BF16 diffusion first, then BF16 encoder. Run the same seed, prompts, step count, and input images. Compare exact lettering, source-image preservation, detail, latency, and peak VRAM. Do not infer output quality from the X post or a single appealing demo. If the BF16 lane runs out of memory, return to the INT8 lane; Qwen’s Diffusers card also documents CPU offload for that separate runtime. [Qwen model card](https://huggingface.co/Qwen/Qwen-Image-2.1)

## Record and stop gate

Record ComfyUI commit/version, PyTorch/CUDA versions, GPU driver, HF model revision, three file hashes, workflow URL/revision, seed, prompt, input provenance, resolution, sampler/steps/CFG, elapsed time, peak VRAM, output path, and any error. **Pass:** one fixed-seed T2I image, one single-image edit, and an inspected PNG alpha result. **Stop:** missing Qwen nodes, model-load mismatch, repeated OOM at 1024 with the INT8 lane, or a workflow silently using a missing prompt enhancer. Close ComfyUI and confirm VRAM returns to baseline when the lab ends.

## Social Capture source audit and next tutorials

Live Social Capture task `sc_acdf7e80cbebe89d` includes a MiniMax H3 item handled elsewhere. Its two exact Qwen-related URLs were checked on 2026-09-28:

| Captured source | Access/result |
|---|---|
| [Unsloth GGUF model card](https://huggingface.co/unsloth/Qwen-Image-2.1-GGUF) | Card says the GGUF is only the denoiser and names separate VAE and Qwen3-VL encoder. |
| [Unsloth X announcement](https://x.com/UnslothAI/status/2102431304591761728?s=20) | Direct `opencli twitter thread 2102431304591761728` returned the matching root ID and replies. Author advertises low-VRAM offload; selected reply findings are noted above. |

Primary setup references are the [official Qwen card](https://huggingface.co/Qwen/Qwen-Image-2.1) and [Comfy-Org model/workflows](https://huggingface.co/Comfy-Org/Qwen-Image-2.1). Continue with [[RTX PRO 5000 Qwen Image 2.1 BFS Body Swap Windows Tutorial]], [[RTX PRO 5000 Qwen Image 2.1 BFS Head Swap Windows Tutorial]], or [[RTX PRO 5000 Qwen Image 2.1 Uncensored Variant Windows Tutorial]] only after the base lane passes.
