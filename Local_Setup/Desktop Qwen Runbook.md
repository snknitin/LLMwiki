---
created: 2026-10-13
status: live
tags: [qwen, windows, llama-cpp, hermes, fresh-brief, runbook]
---

# Desktop Qwen Runbook

How the fast Qwen 3.8 27B on the Windows workstation is set up, how to run it day to day, and how to change it. For why it's set up this way, see [[Qwen 27B Windows Lag And Spark Download Fix 2026-10-13]].

## How it fits together

```
Hermes (FirstSpark) ──Tailscale https :8444──┐
Fresh Brief (Docker) ──host.docker.internal──┤──> llama-server :11435 ──> RTX PRO 5000
                                              │    2 slots x 262K, q8 KV, MTP, vision
Open WebUI / Perplexica / Gemmas ──:11434────> Ollama (tray app) ──> same GPU, ~7 GB left
Monitors ──> motherboard HDMI + Thunderbolt ──> Intel iGPU (never the RTX)
```

| Piece | Where |
|---|---|
| Launcher | `scripts/start-desktop-qwen.ps1` |
| Starts at **boot**, no login needed | Task Scheduler → **Desktop Qwen - llama-server** (S4U, boot trigger, restarts up to 3× on failure). Set once with `scripts/desktop-qwen-run-at-boot.ps1` as administrator |
| Log | `D:\LocalLLama\desktop-qwen\logs\server.log` |
| Program | Own copy in `D:\LocalLLama\desktop-qwen\bin` (llama-server + `cuda_v13`, copied from Ollama 0.40.3). Ollama can be quit or updated without affecting it |
| Model files | `D:\LocalLLama\desktop-qwen\models\Qwen3.8-27B-Q4_K_M.gguf` + `Qwen3.8-27B-mmproj.gguf`: hard links to Ollama blobs `sha256-f5f1dd89…` / `sha256-ac3714bf…`, so they survive `ollama rm` and use no extra disk |
| Hermes | provider **desktop-qwen**, "Desktop Qwen 3.8 27B (2 sessions, llama.cpp)", all 6 profiles |
| Fresh Brief | `compose.yaml` `OLLAMA_URL=http://host.docker.internal:11435`; commit `7523a51` |
| GPU use | ~41 GB of 48 GB |

Measured 13 Oct: 1 stream 96–100 tok/s; 2 streams 82–83 tok/s each; Hermes over Tailscale during a brief: first token 0.18 s, 70 tok/s. Reasoning and code run slower than these predictable prompts.

## Daily use

- **ComfyUI / video generation:** double-click **Qwen OFF** on the desktop first (frees ~41 GB). Hermes falls back to Spark Qwen automatically; a Fresh Brief run fails while it's off. Double-click **Qwen ON** afterwards (~20 s).
- **Is it running?** `Invoke-RestMethod http://127.0.0.1:11435/health` → `ok`. Busy slots: `Invoke-RestMethod http://127.0.0.1:11435/slots`.
- **Is it on the GPU?** `nvidia-smi` shows `llama-server.exe` with ~41 GB. If the log has no `CUDA0` lines it's on the CPU (slow); see troubleshooting.
- **Hermes:** pick *Desktop Qwen 3.8 27B (2 sessions, llama.cpp)*. A grey "Model fallback" line means it couldn't reach this server.

## Rules that keep the desktop smooth

1. No monitor on the RTX card. After moving any monitor cable, **restart Windows** so it draws the desktop on Intel again.
2. Only one big GPU job at a time: Qwen **or** ComfyUI video **or** a Gemma via Ollama. Don't pick `qwen3.8:27b-q4_k_m` in Open WebUI/Perplexica; Ollama would load a second copy that spills onto the CPU.
3. Stop Ollama from its tray icon, not by killing `ollama.exe`. Killed parents leave model processes holding VRAM.

## Ollama updates

Nothing to do: the server runs from its own copy. To deliberately move the server to a newer llama-server (e.g. for a new model's architecture), Qwen OFF, copy the new `lib\ollama\*.dll`, `llama-server.exe` and `cuda_v*` folder into `D:\LocalLLama\desktop-qwen\bin` (keep the old folder as a backup), fix `$cuda` in the launcher if the CUDA folder name changed, then Qwen ON. If a flag is rejected, remove it.

## Things that can still interrupt it

- **NVIDIA driver updates through Windows Update** can reset the GPU mid-run. Prefer turning off driver updates in Windows Update and updating drivers yourself.
- Windows Update restarts happen outside active hours (currently 02:00–08:00); the boot task brings Qwen back.
- PC sleep/hibernate are set to never; keep it that way.

## Switching to a newer Qwen model

The server answers any model name, so only the launcher changes.

1. Get the GGUF, either:
   - via Ollama: `ollama pull <new-tag>`. Then open `D:\LocalLLama\models\ollama\manifests\registry.ollama.ai\library\<name>\<tag>`; the layer with `mediaType ...image.model` is the model blob and `...image.projector` is the vision file (both `D:\LocalLLama\models\ollama\blobs\sha256-<digest>`), or
   - directly from Hugging Face (e.g. a Q4_K_M or UD-Q4_K_XL `.gguf` plus its `mmproj` file) into `D:\LocalLLama\models\gguf\`. This route also stops depending on Ollama's blobs.
2. Check it fits: Q4 weights + KV. A 27B Q4 is ~17 GB; 2 × 262K q8 KV is ~17 GB. For a bigger model, lower `--ctx-size` (it's the total for both slots).
3. Double-click **Qwen OFF**, edit `--model` and `--mmproj` in `scripts/start-desktop-qwen.ps1` (and `--alias` for tidiness). If the model has no MTP layers, remove `--spec-type draft-mtp --spec-draft-n-max 3`. The log shows `creating MTP draft context` when it works.
4. Double-click **Qwen ON**. Check `nvidia-smi` memory, then run a short Hermes question and a Fresh Brief run.
5. If the per-slot context changed, update `context_length` for `desktop-qwen` in the 6 Hermes configs on FirstSpark (`~/.hermes/config.yaml`, `~/.hermes/profiles/*/config.yaml`), and rename the Hermes display name if you like.
6. Once it's working, `ollama rm` the old tag if it came from Ollama.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Hermes shows "Model fallback … desktop-qwen unavailable" | Server stopped (Qwen OFF, crash, not logged in yet) | Qwen ON; read the log |
| Very slow (~4 tok/s), RAM use ~47 GB | Running on CPU: CUDA folder not found | Check `$cuda` in the launcher matches the folder in `bin\` |
| Desktop laggy again | A monitor on the RTX, or monitors replugged without a reboot, or VRAM overfilled | Rules above; `nvidia-smi` to see what holds VRAM |
| Fresh Brief "Needs attention" | Server was off during its run | Qwen ON, then run the brief again |
| A third request waits | Only 2 slots (Hermes chats, background review, brief share them) | Expected; it starts when a slot frees |
| Nothing after a reboot | Boot task failed | Task Scheduler → *Desktop Qwen - llama-server* → History; then the log |

## Rollback to Ollama

1. Qwen OFF, then disable the **Desktop Qwen - llama-server** task.
2. Fresh Brief: `git revert 7523a51` and `docker compose up -d --build`.
3. Hermes: restore `~/.hermes/backups/desktop-qwen-2slot-20261013/` while idle.
4. `tailscale serve --https=8444 off`.
5. Optional: re-enable **Ollama - Start at login** (export in `work/ollama-start-at-login-task-backup.xml`). The tray app alone is enough.

Ollama keeps its own settings: 128K context (Settings slider), q8_0 KV, parallel 1.

## Not covered yet

- ODS dashboard asks Ollama for `qwen3.8:27b`, a tag that's gone since 29 Sept, so its talk/vision features fail. Left alone (ODS is used for ComfyUI).
- Spark Qwen once answered "request format rejected" during a Hermes fallback; not investigated.
- First start from the boot task after a real reboot not yet observed.
