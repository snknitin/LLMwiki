---
updated: 2026-09-28
status: research-ready; runtime-unverified
machine: Windows RTX PRO 5000 Blackwell workstation
---

# Qwen Image 2.1 “uncensored” variants on Windows

## Resolve the name before downloading

The earlier Social Capture discussion points to [abenzerps/Qwen-Image-2.1-Uncensored-GGUF](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF), but there was **no dedicated uncensored item** in the live Social Capture task API on 2026-09-28. Supplemental X research also found [pottokao/Qwen-Image-2.1-Text-Encoder-Heretic-GGUF](https://huggingface.co/pottokao/Qwen-Image-2.1-Text-Encoder-Heretic-GGUF). These are different proposals:

| Candidate | Documented mechanism | First test on this 48 GB workstation |
|---|---|---|
| **abenzerps `UC` denoiser** | Card says GGUF quantizations of original upstream Qwen base weights and says its pipeline has no safety checker. It publishes separate `UC` denoisers and a 33.6 MB `uncensored-lora`, but does not explain whether the `UC` tensors are changed, whether that LoRA is merged, or how the card's two statements relate. | Compare one `UC` **INT8 ConvRot safetensors** file to the official Comfy-Org INT8 denoiser, with the **same official encoder/VAE/workflow**. This avoids adding GGUF loader differences to the first comparison. |
| **pottokao Heretic text encoder** | Author reports directional ablation of the Qwen3-VL text encoder and a 100/100 to 5/100 refusal drop on their own test. The image denoiser can remain the original Qwen Image 2.1. | Compare the author's FP8 Heretic encoder against the official encoder while keeping the official denoiser, VAE, and workflow fixed. The FP8 file uses stock ComfyUI `CLIPLoader`. |

Neither author's outcome claim establishes better normal image quality or behavior on your workstation. The abenzerps model card's absence-of-safety-checker claim is about packaging/pipeline; it is not proof of a trained or abliterated image model. HF LFS SHA-256 values for `UC-Q4_K_M.gguf` and the repo's `base` branch `Q4_K_M.gguf` differ, but GGUF header/metadata differences can change a file hash. **Tensor equality or LoRA merge status remains unverified** without a format-aware tensor comparison or maintainer explanation. [abenzerps model card](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF), [abenzerps file tree](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF/tree/main), [pottokao model card](https://huggingface.co/pottokao/Qwen-Image-2.1-Text-Encoder-Heretic-GGUF)

## Prerequisite

Complete [[RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial]] first and retain its fixed seeds, prompts, inputs, official encoder/VAE, ComfyUI version, and visual scores. Use an isolated local ComfyUI installation on the **Windows desktop**. Read the Qwen Research license for the image base and the respective derivative's license. Use benign, consented evaluation prompts and compare prompt adherence, editing fidelity, unwanted changes, and output quality. This is a model-behavior experiment; no image checkpoint or custom node was installed while writing this note. [Qwen base](https://huggingface.co/Qwen/Qwen-Image-2.1)

## Lane A — abenzerps `UC` safetensors

1. Download **only** [`qwen-image-2.1-UC-int8_convrot.safetensors`](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF/blob/main/qwen-image-2.1-UC-int8_convrot.safetensors) (the HF tree reports 7,256,796,840 bytes) to `ComfyUI/models/diffusion_models/`. Record repository revision and SHA-256. Its filename differs from the official `qwen_image_2.1_int8_convrot.safetensors`; preserve both names.
2. In the **same** official [text-to-image workflow](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_t2i.json), change only `UNETLoader` to the `UC` safetensors. Keep official `qwen3vl_8b_int8_convrot.safetensors` and `qwen_image_2.1_vae_bf16.safetensors`, fixed seed, prompt, steps, CFG, and resolution.
3. Run the same benign T2I and editing cases used in the base tutorial. If it loads and differs, record both outputs and avoid attributing the difference to “uncensoring” until tensor provenance is established. The separate [`qwen-image-2.1-uncensored-lora.safetensors`](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF/blob/main/qwen-image-2.1-uncensored-lora.safetensors) is another variable; the card does not document its recommended strength or whether it is already merged. Do **not** stack it in the first comparison. [abenzerps files/card](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF)

The repository also offers `UC` GGUFs, FP8, NVFP4 and MLX files. For GGUF only, the card directs use of [leejet/ComfyUI-GGUF](https://github.com/leejet/ComfyUI-GGUF), `Unet Loader (GGUF)`, and replacement of the stock `UNETLoader` in official workflows. Its suggested Q4_K_M denoiser is about 4.60 GB, **plus** a 9.35 or 17.53 GB encoder and 676 MB VAE. Do not infer total VRAM from the 4.60 GB file. The card mentions `--lowvram` when needed. Prefer the safetensors comparison first because it has fewer moving parts on this 48 GB machine. [abenzerps usage instructions](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF), [ComfyUI-GGUF repository](https://github.com/leejet/ComfyUI-GGUF)

## Lane B — Heretic encoder, separately

The [pottokao card](https://huggingface.co/pottokao/Qwen-Image-2.1-Text-Encoder-Heretic-GGUF) says the FP8 [`qwen3vl_8b_fp8_heretic.safetensors`](https://huggingface.co/pottokao/Qwen-Image-2.1-Text-Encoder-Heretic-GGUF/blob/main/qwen3vl_8b_fp8_heretic.safetensors) is about 9.34 GB and works with stock ComfyUI `CLIPLoader`, type `qwen_image`, feeding `TextEncodeQwenImage21`. Place it in `ComfyUI/models/text_encoders/`; compare to the official encoder while keeping the **official** diffusion model and VAE unchanged. Pin the file hash and version. The author reports that this path needs ComfyUI 0.36.0 or newer. Check the actual installed node before download.

The same repo's GGUF encoder needs a matching `mmproj-qwen3vl_8b_heretic-f16.gguf` vision tower and a [Qwen3-VL GGUF adapter node](https://github.com/pottokao-dotcom/ComfyUI-GGUF-Qwen3VL-TE) for image editing; a missing tower can cause `[1, 512, 12288]` normalization errors. This is unnecessary for the FP8-first comparison. The author's 25-step, CFG 1 advice is a source claim; test it against the official template rather than changing the baseline midway. [Heretic setup/format details](https://huggingface.co/pottokao/Qwen-Image-2.1-Text-Encoder-Heretic-GGUF)

## Controlled comparison and stop gate

Run A and B **one change at a time**, never A+B or BFS+modified checkpoint first. Use the same fixed seed, 1024-class dimensions, 25 steps, Euler/simple, CFG 1, official VAE, and at least three benign prompts covering exact text, photorealism, and single-image editing. Score readability, composition, edit fidelity, color/detail drift, elapsed time, and peak VRAM. If the intended research includes refusal behavior, define a small permitted prompt set and explicit pass criteria before running it; do not infer a general refusal rate from an anecdotal X image or the author's private benchmark. Only after individual lanes pass should combinations be considered. BFS LoRA compatibility with either derivative is **unverified**; test BFS against official Qwen first. [Official workflow](https://github.com/Comfy-Org/workflow_templates/blob/main/templates/image_qwen_image_2_1_t2i.json), [BFS guide](https://huggingface.co/Alissonerdx/BFS-Best-Face-Swap)

**Stop:** missing Qwen nodes, GGUF architecture/load errors, a Heretic GGUF vision-tower error, persistent OOM at baseline resolution, or a dramatic loss of benign image quality. Record model/encoder hashes, ComfyUI commit, input/output images, seed, prompt, steps/CFG, elapsed time, peak VRAM, and error text. Close ComfyUI after comparison and confirm VRAM release.

## X and repository audit

This is **supplemental research**, not an uncensored task already present in the live Social Capture queue.

| Source | Directly verified finding |
|---|---|
| [abenzerps model card](https://huggingface.co/abenzerps/Qwen-Image-2.1-Uncensored-GGUF) | Claims original upstream base weights/no built-in safety checker; provides separate `UC` files, ordinary `base` branch GGUFs, and a small LoRA. Does not document exact weight deltas. |
| [X post linking abenzerps](https://x.com/SD_Tutorial/status/2101962219106058364) | `opencli twitter thread 2101962219106058364` returned the matching root ID. [One reply](https://x.com/Greg_GL_87/status/2102020959943139589) also interprets “uncensored” as no safety checker/same weights, while [another](https://x.com/nagajew/status/2102050853817372762) quotes an earlier “fully uncensored version in development” notice; these are observations, not a technical build history. A [failure report](https://x.com/trykey013/status/2102277676908089473) gives no error details. |
| [Heretic announcement](https://x.com/Israfilv2/status/2102342696878670010) | Direct thread returned the matching root ID and links the pottokao text-encoder model; the 100→5 refusal claim belongs to that derivative, **not** the abenzerps denoiser. [Author reply](https://x.com/Israfilv2/status/2102423867868516529) advises clear, specific prompts; treat as anecdotal. |
| [pottokao model card](https://huggingface.co/pottokao/Qwen-Image-2.1-Text-Encoder-Heretic-GGUF) | Documents changed encoder, file choices, ComfyUI loader, separate GGUF vision tower, and author-reported ablation test. |

Related: [[RTX PRO 5000 Qwen Image 2.1 Base Windows Tutorial]], [[RTX PRO 5000 Qwen Image 2.1 BFS Body Swap Windows Tutorial]], [[RTX PRO 5000 Qwen Image 2.1 BFS Head Swap Windows Tutorial]].
