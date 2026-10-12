# MiniMax H3 Windows Video Exploration Tutorial

> [!info] Research and execution status — 2026-09-28
> Source and reply audit completed; no model was downloaded or run. This is a workstation experiment for the RTX PRO 5000 Blackwell (48,935 MiB VRAM), not a measured performance claim. Keep the existing Ollama, LM Studio, ODS, Hermes, and Spark routes untouched.

## What to test

MiniMax's released **H3 Base** has two distinct weights: **FL2VA** for text/first/last frame to audio-video and **Ref2VA** for multimodal references. The official local release is 768p; the enhanced prompt and 2K regeneration stages use MiniMax's API. **H3 Max** is the fast hosted variant described by MiniMax Design as post-trained by fal. The viral livestream does not publish a local H3 Max checkpoint or a reproducible RTX 5000 recipe. Test local H3 Base and community adapters; record H3 Max as hosted-only until actual downloadable weights and a license appear. [MiniMax open release](https://www.minimax.io/news/minimax-h3-open-source), [official model card](https://huggingface.co/MiniMaxAI/MiniMax-H3), [H3 Max product page](https://design.minimax.io/tools/minimax-h3-max), [livestream post](https://x.com/rehan_shei/status/2093528415576211819).

| Asset | Role and size on disk | First-trial decision |
|---|---|---|
| [Comfy-Org FL2VA pruned INT8](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors) | 20.97 GB; T2V/I2V transformer | Use first |
| [Qwen3VL H3 NVFP4 AWQ encoder](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors) | 15.69 GB | Use first; confirm Blackwell compatibility in the actual ComfyUI build |
| [INT8 video VAE](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/vae/minimax_h3_video_vae_int8_convrot.safetensors), [FP32 audio VAE](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/vae/minimax_h3_audio_vae_fp32.safetensors) | 2.81 GB + 0.61 GB | Start with matching template; if INT8 video VAE fails, test the 5.21 GB FP16 VAE |
| [FL2VA BF16](https://huggingface.co/Comfy-Org/MiniMax-H3/blob/main/diffusion_models/minimax_h3_fl2va_bf16.safetensors) | 66.28 GB, before encoder and VAEs | Not a one-GPU 48 GB baseline |
| [Ref2VA family](https://huggingface.co/Comfy-Org/MiniMax-H3) | Separate reference transformer | Download only for reference-image/voice experiments |

The four first-trial files total about **40.1 GB on disk**. File size is not peak VRAM: layers, activations, frame length, audio, and allocator overhead also matter. ComfyUI's supported starting point is **version 0.30.0+**, with Template Library → Video → MiniMax H3; use a separate ComfyUI installation or a clean portable copy. [Official ComfyUI overview](https://docs.comfy.org/tutorials/video/minimax/minimax-h3), [file manifest](https://huggingface.co/Comfy-Org/MiniMax-H3/tree/main).

## Preparation on the Windows workstation

1. In **PowerShell**, record `nvidia-smi`, free VRAM, driver, free disk space, and the currently running GPU processes. For a fair trial, unload only models you explicitly own; leave persistent services configured as they are.
2. Make an isolated ComfyUI installation from the [official Windows instructions](https://docs.comfy.org/installation/desktop/windows) or a separate portable copy. Confirm the local ComfyUI version is at least 0.30.0 and that the stock MiniMax H3 T2V template opens without missing nodes. Do not update an existing production ComfyUI in place.
3. Install the current `hf` CLI in that experiment's Python environment if absent. The CLI replaces `huggingface-cli`; use `hf download --dry-run` first. Choose a model directory with at least **65 GB free** for the first assets and outputs. The commands below target an isolated ComfyUI root you choose, rather than any live model store. [Hugging Face CLI](https://huggingface.co/docs/huggingface_hub/guides/cli).

```powershell
$h3Root = 'D:\AI-Lab\ComfyUI-H3'
$h3Models = Join-Path $h3Root 'ComfyUI\models'
$h3Revision = 'bf92c4091e333e69b8ca1998e0a669f15cb0832b'
hf download Comfy-Org/MiniMax-H3 --revision $h3Revision --include 'diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors' 'text_encoders/qwen3vl_32b_minimax_h3_nvfp4_awq.safetensors' 'vae/minimax_h3_video_vae_int8_convrot.safetensors' 'vae/minimax_h3_audio_vae_fp32.safetensors' --local-dir $h3Models --dry-run
```

After inspecting the preview and available disk, repeat without `--dry-run`. Verify all four expected files and hash/check size against the [pinned Hub revision](https://huggingface.co/Comfy-Org/MiniMax-H3/tree/bf92c4091e333e69b8ca1998e0a669f15cb0832b). If your ComfyUI package uses `ComfyUI/models` at a different depth, set `$h3Models` to that actual folder. Model loader names can change between templates: select these exact weights in the workflow dropdowns and fail early if a loader rejects them.

## First controlled render

1. Open **Template Library → Video → MiniMax H3 Text to Video**. The template's FL2VA model is the right task family. Select the downloaded pruned INT8 transformer, NVFP4 encoder, audio VAE, and video VAE. For a short smoke test, choose a fast preview canvas, one 4–5 second duration, one simple character/scene, and the template's default 20 sampling steps. H3 frame counts snap to `17k+5` at 24 fps; record the actual frames chosen by the node. [Native workflow guide](https://docs.comfy.org/tutorials/video/minimax/minimax-h3-native).
2. Example prompt: `A stationary wide shot of one person walking across a quiet train platform at dusk. Subtle camera sway, natural footsteps and ambient station sound. No music. One continuous shot.` Save prompt, seed, dimensions, frame count, steps, and output MP4. Listen for audio as well as watching motion.
3. Record cold load time, generation time, peak `nvidia-smi` VRAM, system RAM, output duration, whether audio is synchronized, and any offload/OOM. Repeat once warm. Then try first-frame I2V with a licensed test image. Only after those pass, fetch a separate Ref2VA weight for references.
4. For full quality, ComfyUI identifies **1344×768** as the native 16:9 768p canvas. Use `0.98` megapixels or explicit dimensions; a nominal `1.0` megapixel setting rounds to 1376×768 and exceeds H3's area cap. Increase resolution and duration one at a time. [ComfyUI overview](https://docs.comfy.org/tutorials/video/minimax/minimax-h3).

## Social capture tips, tested against the sources

| Source | What the post/replies actually establish | Practical use |
|---|---|---|
| [TomW demo](https://x.com/Tomw852/status/2102593811503271963), [model/LoRA reply](https://x.com/Tomw852/status/2102594851216687527), [timing reply](https://x.com/Tomw852/status/2102731112610996350), [prompt reply](https://x.com/Tomw852/status/2102594985522499850) | The creator reports 15 seconds on a 12 GB RTX 5070 in ComfyUI, taking roughly **7–8 minutes**. The demo uses [DaSiWa Hybrid v2 INT8](https://civitai.com/models/2877206?modelVersionId=3314675), [drbaph Turbo V4 Step 600](https://huggingface.co/drbaph/MiniMax-H3-Turbo-Lora-ComfyUI), and [fal Realism People](https://huggingface.co/fal/MiniMax-H3-Realism-People-LoRA), with two labelled picture references and a shot-by-shot audio prompt. This is a community stack, not stock H3 performance. | Reproduce only after the stock baseline; pin each component. Use the original prompt's **structure** (reference roles, timed shots, audio cues) with your own images, rather than confusing the sample with a generic T2V prompt. |
| [ComfyUI VAE announcement](https://x.com/ComfyUI/status/2102499304724381707) | ComfyUI reports encode up to 2.2× and decode 1.4–2.7× faster on NVIDIA; one 1344×768, 129-frame round trip fell from 24.3s to 12.7s. This is **VAE encode/decode**, not total generation. A [reply](https://x.com/kriGetaa/status/2102619209088049266) points to [Kijai's INT8 video VAE](https://huggingface.co/Kijai/MiniMax-H3-experimental/blob/main/minimax_h3_video_vae_int8_convrot.safetensors). | Measure end-to-end time and VAE time separately; compare INT8 and FP16 decode quality on the same latent when feasible. |
| [H3 Max livestream](https://x.com/rehan_shei/status/2093528415576211819) | Post claims video faster than playback in a Twitch stream. In the inspected thread, no weights, local GPU specification, settings, or generation recipe are supplied. MiniMax's [H3 Max page](https://design.minimax.io/tools/minimax-h3-max) presents it as a fast service. | Do not project hosted H3 Max speed onto local H3 Base. |

The **DaSiWa Hybrid v2** Civitai version offers a roughly 20.97 GB INT8 file and a roughly 12.54 GB INT4 file; these are alternative files, not both needed. Civitai calls it compatible with REF2VA and FL2VA. That does not prove the creator's exact workflow will import into current stock ComfyUI. Preserve the creator's version ID and the chosen file hash when trialing it. [Civitai version](https://civitai.com/models/2877206?modelVersionId=3314675).

The [drbaph repository](https://huggingface.co/drbaph/MiniMax-H3-Turbo-Lora-ComfyUI) contains many Turbo variants, including `minimax_h3_turbo_v4_step600_ema_pruned_comfyui.safetensors`. Its card warns that bad audio may come from the sampler/sigma schedule or mismatched FL2VA versus Ref2VA adapter. Treat Turbo quality/speed claims as specific to its documented sampler and base pairing. The [fal Realism People card](https://huggingface.co/fal/MiniMax-H3-Realism-People-LoRA) says to add trigger `r34l1sm` and start at LoRA strength 1.0 (0.6–0.8 for less effect); its single 131 MB file covers T2V/I2V/R2V. Add each LoRA alone first, then both, with identical seed and prompt.

## Handheld Shaky Cam LoRA (capture `sc_24747b719124dc16`)

The [captured X post](https://x.com/SD_Tutorial/status/2103763712356356167) links to [neph1's H3 LoRA mirror](https://huggingface.co/neph1/minimax_h3_handheld_shaky_camera). The [Civitai model-level description](https://civitai.com/api/v1/models/2592748) supplies otherwise missing tips: high-noise application, showcase strength around **1.7** (not identified as H3-specific), and the warning that writing “camera” can add a camera object to the scene. Download, checksum, prompt, and same-seed comparison instructions are in [[MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial]].

## Optional, separate real-time chat experiment

The [new X capture](https://x.com/uzuki425/status/2104115350614995055) points to [Realtime_Conversation_Video](https://github.com/animede/Realtime_Conversation_Video), a **separate LTX-2.5** conversation stack, not an H3 integration. Its client depends on a renderer, TTS, movie gateway, and audio-input LLM. The author's replies put the latency challenge in the first speech/video chunks. The detailed WSL2 workstation feasibility sequence, loopback startup command, memory caveats, and reply audit are in [[Realtime Conversation Video Windows Feasibility Tutorial]].

Another live capture groups H3 Max with [OpenMontage](https://github.com/calesthio/OpenMontage) and a [viral X description](https://x.com/huoshan007/status/2092463295194104276). OpenMontage is an **agentic editing/production system**, not an H3 checkpoint or adapter. Its own [README](https://github.com/calesthio/OpenMontage#readme) describes 12 pipelines, 100+ tools, 700+ skill/knowledge files, stock-footage assembly, and examples using hosted Veo, Kling, and voice services; it does not establish a fully local H3 path. The X thread's [consistency reply](https://x.com/seerlooperzh/status/2095158403048013923) suggests testing character continuity across shots. If later evaluated, give OpenMontage an independent task: inspect provider configuration, require an explicit local-only route if that is the objective, and feed it already-rendered H3 clips to judge editing/continuity. No OpenMontage installation is part of the H3 experiment.

## Pass, stop, and record

- **Pass:** one stock short H3 render with synchronized sound; one repeat with measured VRAM/time; one controlled comparison for each selected LoRA.
- **Stop:** missing native nodes, quantized loader mismatch, OOM, broken audio, 2K/API dependency in what should be a local run, or output quality below the saved baseline. Log exact error and component hashes before changing anything.
- **Decision:** keep only models/adapters that improve a chosen use case at acceptable latency and quality. Record `ComfyUI version`, model revision/file hashes, prompts, seeds, resolution, frames, steps/scheduler, adapters and strengths, peak VRAM/RAM, cold/warm time, and qualitative failures.

## Capture/source audit

Live capture `sc_acdf7e80cbebe89d` contained the TomW H3 5070 demonstration and ComfyUI VAE post; `sc_4348b5fff10f6ef9` contained the H3 Max livestream; live capture `sc_24747b719124dc16` contained the Shaky Cam LoRA and real-time chat client; live capture `sc_db74d7ad59d793e8` grouped H3 Max with OpenMontage. The exact X status IDs above returned matching root posts through a read-only thread lookup on 2026-09-28; replies cited here were in those threads. No important setup recipe was present in the H3 Max replies. All download and model claims above were reconciled against the linked first-party model cards, ComfyUI documentation, and repository files.

## Related notes

- [[Local Setup Index]]
- [[Task Checklist]]
- [[MiniMax H3 Character Swap LoRA Windows Tutorial]]
- [[MiniMax H3 Handheld Shaky Cam LoRA Windows Tutorial]]
- [[Realtime Conversation Video Windows Feasibility Tutorial]]
- [[LongCat Video Avatar 1.5 Workstation Feasibility Tutorial]]
