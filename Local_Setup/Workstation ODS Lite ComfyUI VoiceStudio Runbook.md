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
| ComfyUI 0.41.0 | Native portable, `D:\Apps\ComfyUI` (not Docker), http://127.0.0.1:8188 | Desktop **ComfyUI** icon: runs `qwen-off.ps1`, then `run_nvidia_gpu.bat` | Whole RTX. Qwen holds ~45 of 48 GB, so it must be off. Run **Qwen ON** when finished |
| VoiceStudio 0.5.6 | Electron app in `D:\Apps\VoiceStudio`; backend http://127.0.0.1:3900 | Desktop **VoiceStudio** icon | Clean install 2026-10-16 ("Max" model strategy). Data `%APPDATA%\OmniVoice`, runtime `%APPDATA%\VoiceStudio\runtime` (~18 GB, on C:). Old 0.5.0 and its data deleted; its stale "VoiceStudio 0.5.0" entry in Windows Apps is harmless |

## ODS: what changed

- Code updated in place from upstream `main` 36b9501 (3.0.0 plus fixes for GHSA-vqpg-pvjj-4cmq and GHSA-v3hj-52g2-2hmc; 2.5.3 had both). `.env`, `data/`, `docker-compose.override.yml` and `.compose-flags` were kept. Backup: `D:\LocalLLama\ods-backup-20261016` (includes the old `ods-host-agent.vbs` startup entry under `startup\`).
- The **ods** compose project now holds only open-webui, searxng and perplexica. The other 17 containers were removed (`docker compose down`), so Docker Desktop's ▶/■ on the **ods** group toggles just those three. Removed: dashboard + dashboard-api (where the security holes were), n8n, Langfuse (6 containers), token-spy, privacy-shield, APE, Qdrant, TEI embeddings (bge-m3), Whisper, Kokoro TTS, ODS ComfyUI (it never had a model).
- Open WebUI override: `ENABLE_PERSISTENT_CONFIG=false`, chroma vector DB, built-in embeddings/STT, browser TTS. Settings changed in the Open WebUI admin UI **reset on restart**; change them in `D:\LocalLLama\ods\docker-compose.override.yml` instead.
- Docker Desktop no longer starts at sign-in (HKCU Run entry removed). The ODS host agent no longer starts at login.
- **Don't** run `ods start` / `ods.ps1 start` or the ODS dashboard's start: they bring up the full 20-container stack again. If that happens, `scripts/ods-lite.ps1 on` returns it to the slim set. `ods-lite.ps1 off` also quits Docker and runs `wsl --shutdown` to free RAM.
- The desktop **ODS** icon is a Vivaldi app for the ODS dashboard, which no longer runs.

## ComfyUI: how to use it

1. Double-click **ComfyUI** on the desktop (it turns Qwen off first). Wait for `To see the GUI go to: http://127.0.0.1:8188`, then open that URL.
2. Left sidebar → **Templates** (or Workflow → Browse Templates). Pick one from the table, replace the example text in the **prompt** box of the big node (e.g. "Text to Image (Qwen Image 2.1)"), then press **Run** (Ctrl+Enter). Size, steps and seed are on the same node; `switch` turns on the prompt enhancer. The first run loads the models from disk and is slow; later runs are fast.
3. Outputs go to `D:\Apps\ComfyUI\ComfyUI\output`. Inputs you upload go to `...\ComfyUI\input`.
4. When you're done, close the ComfyUI console window and double-click **Qwen ON**.

| Want | Template | Models already installed |
|---|---|---|
| Picture from text | Image → **Qwen Image 2.1: Text to Image** | `qwen_image_2.1_int8_convrot`, `qwen3vl_8b_int8_convrot`, `qwen_image_2.1_vae_bf16`, prompt enhancer `..._pe_t2i` |
| Edit a picture | Image → **Qwen Image 2.1: Image Edit** | same, plus enhancer `..._pe_i2i`. First image = the one to edit; others are references (`<image1>`, `<image2>`) |
| Body / head swap, relighting | Edit template + a **LoraLoaderModelOnly** between the model loader and the sampler | `loras/bfs_body_swap_v1.0_qwen_2.1`, `bfs_head_v1.1_qwen_2.1`, `Qwenimag21_c2-st2000` (lighting: start the prompt with `pengyu`) |
| Video with sound from text or a first frame | Video → **MiniMax H3: Text to Video** / **MiniMax H3: Image to Video** | `minimax_h3_fl2va_pruned_int8_convrot`, `qwen3vl_32b_minimax_h3_nvfp4_awq`, video VAE int8, audio VAE, turbo LoRAs 4-step/8-step |
| Video from reference images / character swap | Video → **MiniMax H3: Reference to Video** | `minimax_h3_ref2va_pruned_int8_convrot`, `ref2v_turbo_4step` LoRA, `h3_character_swap_v1.5` |
| Video looks | Add a LoRA loader to an H3 template | `handheld_h3_100` (shaky cam; don't write "camera" in the prompt), `h3-realism-people-t2v-i2v-r2v` (trigger `r34l1sm`, strength 0.6–1.0), drbaph `minimax_h3_turbo_v4_step600_ema_pruned_comfyui` |
| Style ideas | Add node **Clio Style** (custom node `clio-style-preview`, 400+ styles); feed its text output into the prompt | — |

Tips: skip templates marked **API** (and all "H3 Max" ones): they run on paid cloud services, not this GPU. Keep Qwen images at 1024×1024 until it works, then go up (multiples of 32). H3: 1344×768 is full 16:9 quality, and short 4–5 s clips first. For faster H3 video, start ComfyUI with `D:\Apps\ComfyUI\run_nvidia_gpu_fast_fp16_accumulation.bat` instead (run **Qwen OFF** first); it switches VAEs to fp16, so keep the normal icon for image work. If a template shows a red "missing model" box, the file it names isn't installed. Pick the installed one in that loader's dropdown, or bypass the node (Ctrl+B).

Not installed on purpose: LTX 2.5 video restoration (gated licence you must accept on Hugging Face, plus ~45 GB more and the ComfyUI-LTXVideo node pack), Mitsuba VLM (repo no longer public), Qwen pixel-drift nodes (repo not confirmed). Per-model details: the tutorials linked from [[Social Capture Local AI Model Exploration Guide]].

## Rollback

Copy `D:\LocalLLama\ods-backup-20261016` back over `D:\LocalLLama\ods`, put `startup\ods-host-agent.vbs` back in the Startup folder, then `docker compose $(cat .compose-flags) up -d`.
