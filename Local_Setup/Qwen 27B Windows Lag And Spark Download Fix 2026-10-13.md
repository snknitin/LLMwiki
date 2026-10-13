---
created: 2026-10-13
status: software-fixes-applied; hardware-steps-pending
tags: [qwen, ollama, windows, gpu, dgx-spark, network]
---

# Qwen 27B Windows lag and Spark download fix — 13 October 2026

Day-to-day operation, model upgrades and rollback: [[Desktop Qwen Runbook]].

## Root causes found

| Problem | Cause (measured) |
|---|---|
| Qwen used ~35 GiB VRAM | Ollama app **Settings → Context length slider was 256K** (`db.sqlite` `settings.context_length=262144`). It overrides `OLLAMA_CONTEXT_LENGTH`. 262K × f16 KV = 16 GiB of KV alone. Friends on 16–24 GB use small contexts. |
| Constant reloads/waits | Fresh Brief sent `num_ctx: 16384`, Hermes got 262144. Ollama reloads the model whenever the size changes (245 reloads 8–12 Oct). |
| Desktop lag | **All three monitors are plugged into the RTX PRO 5000**; the Core Ultra 9 285K Intel iGPU drives nothing. Windows compositing (DWM) shares the GPU with 250–300 W inference. VRAM size is not the cause; GPU time-sharing is. |
| No concurrency on Windows | Ollama 0.40.3 logs `model architecture does not currently support parallel requests architecture=qwen35`. One Qwen session at a time, regardless of `OLLAMA_NUM_PARALLEL`. |
| Spark Qwen below 50 tok/s | Spark memory bandwidth (~273 GB/s) caps a dense 27B at ~10–16 tok/s; DFlash2 reaches 22–29. 50+ is not reachable for a dense 27B on one Spark. See [[Qwen 3.8 27B DFlash2 Speed Upgrade]]. |
| Slow Spark downloads | FirstSpark Ethernet `enP7s7` (r8127) is **linked at 10 Mb/s** after flapping on 10 Oct; SecondSpark on the same router is at 1000. Measured: HF over Ethernet 1.0 MiB/s, over Wi-Fi 24.6 MiB/s. Not a Hugging Face/Xet problem. |

## Applied

- Ollama app setting context 262144 → **131072** (backup `%LOCALAPPDATA%\Ollama\db.sqlite.claude-backup-20261013`).
- User env: `OLLAMA_CONTEXT_LENGTH=131072`, `OLLAMA_KV_CACHE_TYPE=q8_0`, `OLLAMA_NUM_PARALLEL=1` (before: `work/ollama-env-before-20261013.txt`).
- Ollama auto-updated 0.40.0 → 0.40.3 during the restart.
- Fresh Brief: removed `num_ctx: 16384` from `newsroom.py` and `app.py` so it uses the server context; container rebuilt, healthy.
- Hermes main `config.yaml` desktop-ollama contexts 262144 → 131072 (profiles were already 131072). Backup `~/.hermes/backups/config-before-desktop-ollama-131k-20261013.yaml`.

Result: Qwen VRAM 20.1 GiB (was ~34–35), KV 4.25 GiB. Local decode 53–55 tok/s; Spark → Tailscale → Windows **50.7 tok/s end-to-end** warm.

## Two-slot desktop Qwen (applied 20:30 IST)

Ollama can't serve Qwen 3.8 to two clients at once, so Qwen moved off Ollama to Ollama's own bundled `llama-server`, using the same model file.

- Launcher `scripts/start-desktop-qwen.ps1`: 2 slots × 262,144 context, q8_0 KV, MTP draft 3, vision projector, port **11435**. It needs Ollama's `lib\ollama\cuda_v13` on PATH; without it the server silently runs on the CPU (47 GB RAM, ~4 tok/s). `--device CUDA0` now makes that case fail with an error instead.
- Starts at login via scheduled task **Desktop Qwen - llama-server**. Log: `%LOCALAPPDATA%\desktop-qwen\server.log`.
- The duplicate task **Ollama - Start at login** is disabled (export: `work/ollama-start-at-login-task-backup.xml`); the tray app now runs Ollama alone, with logs.
- Tailscale: `:8444` → 11435 (new). `:8443` → Ollama stays for the Gemma models.
- Hermes: new provider **desktop-qwen** in all 6 configs; Qwen removed from desktop-ollama. Backup `~/.hermes/backups/desktop-qwen-2slot-20261013/`.
- Fresh Brief: `app.request` translates its Ollama-style `/api/chat` calls to `/v1/chat/completions` (test added); `compose.yaml` points at 11435.
- GPU: 41.3 GB used. Only ~7 GB is left, so a Gemma loaded through Ollama will spill onto the CPU and run slowly.

Measured: 1 stream 96–100 tok/s, first word in 0.2–0.45 s; 2 streams 82–83 tok/s each; Spark → Tailscale while Fresh Brief was using the other slot: 70 tok/s, first word in 0.18 s (Ollama: 6.5–64 s queued). These benchmark prompts are easy for MTP to predict; reasoning and code will be slower.

Rollback: disable the task, re-enable *Ollama - Start at login* if wanted, restore the Hermes backup, `git checkout app.py test_app.py compose.yaml` in fresh-brief and rebuild, `tailscale serve --https=8444 off`.

## Pending (user, hardware)

1. Move all three monitors to the motherboard (ProArt Z890-CREATOR: HDMI + two Thunderbolt 4 USB-C with DisplayPort). Needs one HDMI cable and two USB-C→DisplayPort cables. Then the NVIDIA GPU is compute-only and inference can't stall the desktop.
2. ~~Replace FirstSpark's Ethernet cable.~~ **Done 18:18 IST:** a different router port still gave 10 Mb/s with the link dropping every 15–20 s; a new cable fixed it. Link now 1000 Mb/s; HF download over Ethernet 32.3 MiB/s (was 1.0), which is the same as Wi-Fi, so ~32 MiB/s is the internet line's limit.
