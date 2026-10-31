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
| Settings | `scripts/desktop-qwen-apply.ps1`: model, context, slots and flags in one place. After editing, run it **as administrator** (right-click → Run with PowerShell as admin, or `Start-Process powershell -Verb RunAs -ArgumentList '-File F:\Vaults\LLMWiki\Local_Setup\scripts\desktop-qwen-apply.ps1'`). It re-registers the task and restarts the server |
| Starts at **boot**, no login needed | Task Scheduler → **Desktop Qwen - llama-server** (S4U, boot trigger, restarts up to 3× on failure). It runs `llama-server.exe` directly, so stopping the task stops the server |
| Log | `D:\LocalLLama\desktop-qwen\logs\server.log` (last apply: `apply-result.txt`) |
| Program | Own copy in `D:\LocalLLama\desktop-qwen\bin`: Ollama 0.40.3's llama-server with the `cuda_v13` DLLs flattened beside the exe. Ollama can be quit or updated without affecting it |
| Model in use | `models\Qwen3.8-27B-UD-Q5_K_XL.gguf` (Unsloth, copied from FirstSpark, SHA-256 `8601193d…`). Fallback `models\Qwen3.8-27B-Q4_K_M.gguf` and vision `models\Qwen3.8-27B-mmproj.gguf` are hard links to Ollama blobs `sha256-f5f1dd89…` / `sha256-ac3714bf…` |
| Hermes | provider **desktop-qwen**, model **`qwen3.8-27b-desktop`** (server alias), "Desktop Qwen 3.8 27B (2 sessions, llama.cpp)", all 6 profiles. Rename backup: `~/.hermes/backups/desktop-qwen-rename-20261013/`. The server answers any model name, so older chats still asking for `qwen3.8:27b-q4_k_m` keep working |
| Fresh Brief | `compose.yaml` `OLLAMA_URL=http://host.docker.internal:11435`; commit `7523a51`. It still sends `qwen3.8:27b-q4_k_m` on purpose: its article-note cache is keyed by model name, and renaming would re-read every article. Its dashboard's **Gemma** choices are also answered by Qwen now, because every Fresh Brief request goes to this server |
| GPU use | Q5: ~44.9 GB of 48 GB (Q4: ~41 GB) |

Measured 13 Oct, 512-token answers:

| | Explanation, 1 stream | Code, 1 stream | Code, 2 streams (each) | Spark → Tailscale |
|---|---|---|---|---|
| Q4_K_M | 98 tok/s | 114 tok/s | 99–102 tok/s | 70 tok/s (during a brief) |
| **UD-Q5_K_XL (live)** | 91 tok/s | 108 tok/s | 90–93 tok/s | 87 tok/s |

Q5 costs 5–9% speed for higher weight precision. Fresh Brief JSON, tool calls, two parallel requests and vision all passed on Q5.

## Daily use

- **ComfyUI / video generation:** double-click **Qwen OFF** on the desktop first (frees ~45 GB). Hermes falls back to Spark Qwen automatically; a Fresh Brief run fails while it's off. Double-click **Qwen ON** afterwards (~20 s).
- **Is it running?** `Invoke-RestMethod http://127.0.0.1:11435/health` → `ok`. Busy slots: `Invoke-RestMethod http://127.0.0.1:11435/slots`.
- **Is it on the GPU?** `nvidia-smi` shows ~45 GB used. If the log has no `CUDA0` lines it's on the CPU (slow); see troubleshooting.
- **Hermes:** pick *Desktop Qwen 3.8 27B (2 sessions, llama.cpp)*. A grey "Model fallback" line means it couldn't reach this server.
- **sparkDash:** FirstSpark's dashboard reads this server at `http://nike-workstation.tail4a1242.ts.net:11435` (tailnet-only `tailscale serve --http=11435`, added 2026-10-31). It must use that name: the bare tailnet IP gets a 404 from `tailscale serve`.

## Rules that keep the desktop smooth

1. No monitor on the RTX card. After moving any monitor cable, **restart Windows** so it draws the desktop on Intel again.
2. Only one big GPU job at a time: Qwen **or** ComfyUI video **or** a Gemma via Ollama. Don't pick `qwen3.8:27b-q4_k_m` in Open WebUI/Perplexica; Ollama would load a second copy that spills onto the CPU.
3. Stop Ollama from its tray icon, not by killing `ollama.exe`. Killed parents leave model processes holding VRAM.

## Ollama updates

Nothing to do: the server runs from its own copy. To deliberately move to a newer llama-server (e.g. for a new model architecture): Qwen OFF, rename `bin` to `bin.old`, copy the new `lib\ollama\*.dll` and `llama-server.exe` into a fresh `bin`, copy the contents of its `cuda_v*` folder into `bin` too, then run the apply script as admin. If a flag is rejected, remove it from the apply script.

## Things that can still interrupt it

- **NVIDIA driver updates through Windows Update** can reset the GPU mid-run. Prefer turning off driver updates in Windows Update and updating drivers yourself.
- Windows Update restarts happen outside active hours (currently 02:00–08:00); the boot task brings Qwen back.
- PC sleep/hibernate are set to never; keep it that way.

## Switching to a newer Qwen model

The server answers any model name, so only the apply script changes. Switching between the Q5 and Q4 files already in `models\` is just step 3.

1. Get the GGUF into `D:\LocalLLama\desktop-qwen\models\`, either:
   - from FirstSpark over the LAN (fast now): `scp -F "$env:LOCALAPPDATA\NVIDIA Corporation\Sync\config\ssh_config" -o HostName=192.168.0.101 -o HostKeyAlias=spark-07a8.local FirstSpark:<path>.gguf D:\LocalLLama\desktop-qwen\models\`, then check its SHA-256, or
   - via Ollama: `ollama pull <new-tag>`, then open `D:\LocalLLama\models\ollama\manifests\registry.ollama.ai\library\<name>\<tag>`; the layer with `mediaType ...image.model` is the model and `...image.projector` the vision file (`D:\LocalLLama\models\ollama\blobs\sha256-<digest>`). Hard-link them into `models\` with `cmd /c mklink /H <new> <blob>`, or
   - directly from Hugging Face (`.gguf` plus its `mmproj`).
2. Check it fits in ~47 GB: weights + 17 GB for 2 × 262K q8 KV + ~3 GB buffers. Q5 27B came to 44.9 GB. For a bigger model, lower `--ctx-size` (the total for both slots).
3. Edit `$model` (and `--mmproj` if it has its own vision file) in `scripts/desktop-qwen-apply.ps1`. If the model has no MTP layers, remove `--spec-type draft-mtp --spec-draft-n-max 3`; the log shows `creating MTP draft context` when it works. Run the script as administrator.
4. Check `apply-result.txt` shows `ready=True` and the GPU memory, then run a short Hermes question and a Fresh Brief run.
5. If the per-slot context changed, update `context_length` for `desktop-qwen` in the 6 Hermes configs on FirstSpark (`~/.hermes/config.yaml`, `~/.hermes/profiles/*/config.yaml`), and rename the Hermes display name if you like.
6. Once it's working, `ollama rm` the old tag if it came from Ollama.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Hermes shows "Model fallback … desktop-qwen unavailable" | Server stopped (Qwen OFF, crash, not logged in yet) | Qwen ON; read the log |
| Very slow (~4 tok/s), RAM use ~47 GB | Running on CPU: the CUDA DLLs (`ggml-cuda.dll`, `cublas*`) are missing from `bin\` | Copy them from Ollama's `lib\ollama\cuda_v13\` into `bin\`, rerun the apply script |
| Qwen OFF says "STILL RUNNING" | Task was registered with a wrapper, or a second server is loaded | Run the apply script as admin; it stops every background-session llama-server and re-registers the task |
| Desktop laggy again | A monitor on the RTX, or monitors replugged without a reboot, or VRAM overfilled | Rules above; `nvidia-smi` to see what holds VRAM |
| Fresh Brief "Needs attention" | Server was off during its run | Qwen ON, then run the brief again |
| A third request waits | Only 2 slots (Hermes chats, background review, brief share them) | Expected; it starts when a slot frees |
| Nothing after a reboot | Boot task failed | Task Scheduler → *Desktop Qwen - llama-server* → History; then the log |

## Rollback to Ollama

1. Qwen OFF, then disable the **Desktop Qwen - llama-server** task. (To go back to Q4 only, see "Switching" step 3.)
2. Fresh Brief: `git revert 7523a51` and `docker compose up -d --build`.
3. Hermes: restore `~/.hermes/backups/desktop-qwen-2slot-20261013/` while idle.
4. `tailscale serve --https=8444 off` and `tailscale serve --http=11435 off`.
5. Optional: re-enable **Ollama - Start at login** (export in `work/ollama-start-at-login-task-backup.xml`). The tray app alone is enough.

Ollama keeps its own settings: 128K context (Settings slider), q8_0 KV, parallel 1.

## Not covered yet

- ODS dashboard asks Ollama for `qwen3.8:27b`, a tag that's gone since 29 Sept, so its talk/vision features fail. Left alone (ODS is used for ComfyUI).
- Spark Qwen once answered "request format rejected" during a Hermes fallback; not investigated.
- First start from the boot task after a real reboot not yet observed.
