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
| Open WebUI | ODS container `ods-webui`, http://127.0.0.1:3000 | Docker Desktop â†’ Containers â†’ **ods** â–¶ (or `scripts/ods-lite.ps1 on`) | Desktop Qwen `:11435` (and Ollama `:11434` if the tray app is up); web search via SearXNG |
| Perplexica | ODS container `ods-perplexica`, http://127.0.0.1:3004 | same **ods** group | chat `ods/current` â†’ `:11435`; embeddings: local Transformers `all-MiniLM-L6-v2` |
| SearXNG | ODS container `ods-searxng`, :8888 | same **ods** group | backend for both |
| ComfyUI 0.41.0 | Native portable, `D:\Apps\ComfyUI` (not Docker), http://127.0.0.1:8188 | Desktop **ComfyUI** icon: runs `qwen-off.ps1`, then `run_nvidia_gpu.bat` | Whole RTX. Qwen holds ~45 of 48 GB, so it must be off. Run **Qwen ON** when finished |
| VoiceStudio 0.5.6 | Electron, `%LOCALAPPDATA%\Programs\VoiceStudio` | Desktop **VoiceStudio** icon | Fresh install: data `D:\Apps\VoiceStudio\data` (`OMNIVOICE_DATA_DIR` user env var), runtime `D:\Apps\VoiceStudio\runtime`. The old 0.5.0 portable and its data were deleted 2026-10-16 |

## ODS: what changed

- Code updated in place from upstream `main` 36b9501 (3.0.0 plus fixes for GHSA-vqpg-pvjj-4cmq and GHSA-v3hj-52g2-2hmc; 2.5.3 had both). `.env`, `data/`, `docker-compose.override.yml` and `.compose-flags` were kept. Backup: `D:\LocalLLama\ods-backup-20261016` (includes the old `ods-host-agent.vbs` startup entry under `startup\`).
- The **ods** compose project now holds only open-webui, searxng and perplexica. The other 17 containers were removed (`docker compose down`), so Docker Desktop's â–¶/â–  on the **ods** group toggles just those three. Removed: dashboard + dashboard-api (where the security holes were), n8n, Langfuse (6 containers), token-spy, privacy-shield, APE, Qdrant, TEI embeddings (bge-m3), Whisper, Kokoro TTS, ODS ComfyUI (it never had a model).
- Open WebUI override: `ENABLE_PERSISTENT_CONFIG=false`, chroma vector DB, built-in embeddings/STT, browser TTS. Settings changed in the Open WebUI admin UI **reset on restart**; change them in `D:\LocalLLama\ods\docker-compose.override.yml` instead.
- Docker Desktop no longer starts at sign-in (HKCU Run entry removed). The ODS host agent no longer starts at login.
- **Don't** run `ods start` / `ods.ps1 start` or the ODS dashboard's start: they bring up the full 20-container stack again. If that happens, `scripts/ods-lite.ps1 on` returns it to the slim set. `ods-lite.ps1 off` also quits Docker and runs `wsl --shutdown` to free RAM.
- The desktop **ODS** icon is a Vivaldi app for the ODS dashboard, which no longer runs.

## Rollback

Copy `D:\LocalLLama\ods-backup-20261016` back over `D:\LocalLLama\ods`, put `startup\ods-host-agent.vbs` back in the Startup folder, then `docker compose $(cat .compose-flags) up -d`.
