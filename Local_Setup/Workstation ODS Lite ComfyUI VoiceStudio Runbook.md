---
created: 2026-10-16
status: live
tags: [ods, comfyui, voicestudio, windows, docker, runbook]
---

# Workstation ODS Lite, ComfyUI And VoiceStudio Runbook

How the occasional-use creative/search tools on the Windows workstation are set up since 2026-10-16. The always-on model is still Desktop Qwen on `:11435` ([[Desktop Qwen Runbook]]).

## What runs where

| Tool | Where | How to start | Uses |
|---|---|---|---|
| Open WebUI | ODS container `ods-webui`, http://127.0.0.1:3000 | Docker Desktop → Containers → **ods** ▶ (or `scripts/ods-lite.ps1 on`) | Desktop Qwen `:11435` (and Ollama `:11434` if the tray app is up); web search via SearXNG |
| Perplexica | ODS container `ods-perplexica`, http://127.0.0.1:3004 | same **ods** group | chat `ods/current` → `:11435`; embeddings: local Transformers `all-MiniLM-L6-v2` |
| SearXNG | ODS container `ods-searxng`, :8888 | same **ods** group | backend for both |
| ComfyUI 0.41.0 | Native portable, `D:\Apps\ComfyUI` (not Docker), http://127.0.0.1:8188 | **Command Center → Operations → ComfyUI** (starts it hidden, log `D:\Apps\ComfyUI\comfyui-dashboard.log`), or the desktop **ComfyUI** icon (console window) | Whole RTX. Qwen holds ~45 of 48 GB, so starting ComfyUI stops Qwen. **Qwen ON** stops ComfyUI and starts Qwen; quitting Command Center does the same for a ComfyUI it started |
| VoiceStudio 0.5.6 | Electron app in `D:\Apps\VoiceStudio`; backend http://127.0.0.1:3900 | Desktop **VoiceStudio** icon | Clean install 2026-10-16 ("Max" model strategy). Data `%APPDATA%\OmniVoice`, runtime `%APPDATA%\VoiceStudio\runtime` (~18 GB, on C:). Old 0.5.0 and its data deleted; its stale "VoiceStudio 0.5.0" entry in Windows Apps is harmless |

## ODS: what changed

- Code updated in place from upstream `main` 36b9501 (3.0.0 plus fixes for GHSA-vqpg-pvjj-4cmq and GHSA-v3hj-52g2-2hmc; 2.5.3 had both). `.env`, `data/`, `docker-compose.override.yml` and `.compose-flags` were kept. Backup: `D:\LocalLLama\ods-backup-20261016` (includes the old `ods-host-agent.vbs` startup entry under `startup\`).
- The **ods** compose project now holds only open-webui, searxng and perplexica. The other 17 containers were removed (`docker compose down`), so Docker Desktop's ▶/■ on the **ods** group toggles just those three. Removed: dashboard + dashboard-api (where the security holes were), n8n, Langfuse (6 containers), token-spy, privacy-shield, APE, Qdrant, TEI embeddings (bge-m3), Whisper, Kokoro TTS, ODS ComfyUI (it never had a model).
- Open WebUI override: `ENABLE_PERSISTENT_CONFIG=false`, chroma vector DB, built-in embeddings/STT, browser TTS. Settings changed in the Open WebUI admin UI **reset on restart**; change them in `D:\LocalLLama\ods\docker-compose.override.yml` instead.
- Docker Desktop no longer starts at sign-in (HKCU Run entry removed). The ODS host agent no longer starts at login.
- **Don't** run `ods start` / `ods.ps1 start` or the ODS dashboard's start: they bring up the full 20-container stack again. If that happens, `scripts/ods-lite.ps1 on` returns it to the slim set. `ods-lite.ps1 off` also quits Docker and runs `wsl --shutdown` to free RAM.
- The desktop **ODS** icon is a Vivaldi app for the ODS dashboard, which no longer runs.

## ComfyUI: how to use it

1. Open **Command Center → Operations → ComfyUI**. If ComfyUI isn't running, the app stops Desktop Qwen, starts ComfyUI in the background and shows it (~15 s). Refresh restarts it only if it died. (Or: desktop **ComfyUI** icon, then open http://127.0.0.1:8188.)
2. Left sidebar → **Templates** (or Workflow → Browse Templates). Pick one from the table, replace the example text in the **prompt** box of the big node (e.g. "Text to Image (Qwen Image 2.1)"), then press **Run** (Ctrl+Enter). Size, steps and seed are on the same node; `switch` turns on the prompt enhancer. The first run loads the models from disk and is slow; later runs are fast.
3. Outputs go to `D:\Apps\ComfyUI\ComfyUI\output`. Inputs you upload go to `...\ComfyUI\input`.
4. When you're done, double-click **Qwen ON** (it stops ComfyUI first), or quit Command Center.

| Want | Template | Models already installed |
|---|---|---|
| Picture from text | Image → **Qwen Image 2.1: Text to Image** | `qwen_image_2.1_int8_convrot`, `qwen3vl_8b_int8_convrot`, `qwen_image_2.1_vae_bf16`, prompt enhancer `..._pe_t2i` |
| Edit a picture | Image → **Qwen Image 2.1: Image Edit** | same, plus enhancer `..._pe_i2i`. First image = the one to edit; others are references (`<image1>`, `<image2>`) |
| Body / head swap, relighting | Edit template + a **LoraLoaderModelOnly** between the model loader and the sampler | `loras/bfs_body_swap_v1.0_qwen_2.1`, `bfs_head_v1.1_qwen_2.1`, `Qwenimag21_c2-st2000` (lighting: start the prompt with `pengyu`) |
| Video with sound from text or a first frame | Video → **MiniMax H3: Text to Video** / **MiniMax H3: Image to Video** | `minimax_h3_fl2va_pruned_int8_convrot`, `qwen3vl_32b_minimax_h3_nvfp4_awq`, video VAE int8, audio VAE, turbo LoRAs 4-step/8-step |
| Video from reference images / character swap | Video → **MiniMax H3: Reference to Video** | `minimax_h3_ref2va_pruned_int8_convrot`, `ref2v_turbo_4step` LoRA, `h3_character_swap_v1.5` |
| Video looks | Add a LoRA loader to an H3 template | `handheld_h3_100` (shaky cam; don't write "camera" in the prompt), `h3-realism-people-t2v-i2v-r2v` (trigger `r34l1sm`, strength 0.6–1.0), drbaph `minimax_h3_turbo_v4_step600_ema_pruned_comfyui` |
| Style ideas | Add node **Clio Style** (custom node `clio-style-preview`, 400+ styles); feed its text output into the prompt | — |
| Fix edit drift (edited image shifted/stretched vs. the original) | Add **PixelDriftFix** (simple 4-point fit) or **KleinEditComposite** (also colour-corrects and masks so only changed areas are kept) after the edit. Example workflows: `custom_nodes/ComfyUI-PixelDriftFix/workflows/`, `custom_nodes/comfyui-klein-edit-composite/example workflow/` | none (no model) |
| LTX 2.5 video (text/image to video, restore old footage) | Workflows are not in Templates: drag a JSON from `custom_nodes/ComfyUI-LTXVideo/example_workflows/2.5/` onto the canvas. Restore = `LTX-2.5_V2V_TiledFusion_Upscale.json` with the restore LoRA at 1.0, 8 steps, CFG 1, tiles 960×544; switch its loaders to the int8 files | `ltx-2.5-22b-distilled-transformer-comfy-int8-convrot`, `gemma4-12b-with-proj-ltx-2.5-comfy-int8-convrot`, `gemma4_e2b_it_int8_convrot`, LTX video/audio/conv VAEs, x2 spatial upscaler, `loras/ltx-2.5-22b-ic-lora-restore-1.0`, `...-refine-details-1.0` |

Tips: skip templates marked **API** (and all "H3 Max" ones): they run on paid cloud services, not this GPU. Keep Qwen images at 1024×1024 until it works, then go up (multiples of 32). H3: 1344×768 is full 16:9 quality, and short 4–5 s clips first. For faster H3 video, start ComfyUI with `D:\Apps\ComfyUI\run_nvidia_gpu_fast_fp16_accumulation.bat` instead (run **Qwen OFF** first); it switches VAEs to fp16, so keep the normal icon for image work. If a template shows a red "missing model" box, the file it names isn't installed. Pick the installed one in that loader's dropdown, or bypass the node (Ctrl+B).

Not installed: Mitsuba VLM (its Hugging Face repo is private/removed). Downloading more gated models: the Hugging Face token is saved for this user; log in again with `D:\Apps\ComfyUI\python_embeded\python.exe -c "from huggingface_hub import login; login()"` (the portable's `hf.exe` is broken: it points at the build machine's Python). Per-model details: the tutorials linked from [[Social Capture Local AI Model Exploration Guide]].

## Rollback

Copy `D:\LocalLLama\ods-backup-20261016` back over `D:\LocalLLama\ods`, put `startup\ods-host-agent.vbs` back in the Startup folder, then `docker compose $(cat .compose-flags) up -d`.
