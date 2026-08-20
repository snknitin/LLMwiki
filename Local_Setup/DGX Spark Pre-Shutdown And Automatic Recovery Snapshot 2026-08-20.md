---
created: 2026-08-20
updated: 2026-08-20
scope: dgx-spark, shutdown, reboot, power-recovery, hermes, ods, lm-studio, lm-link
status: physical-power-cycle-and-button-start-passed-boot-order-corrected
---

# DGX Spark Pre-Shutdown And Automatic Recovery Snapshot — 2026-08-20

## Purpose

This is the recovery contract for the first DGX Spark, NVIDIA Sync alias `FirstSpark`, before moving its power cable to the UPS. It records what was live, what owns restart behavior, the one recovery gap that was fixed, and the checks that must pass after boot.

Do not deliberately pull live power to test this. Use a controlled shutdown, wait until the Spark is fully off, move the cable, and then apply UPS power. NVIDIA documents that the Spark starts when power is applied and that the UEFI default after-power-loss behavior is `Auto Boot`; see [[DGX Spark Automatic Power Recovery Research]].

## Pre-change capture

Captured from `spark-07a8` between 17:47 and 17:55 IST on 2026-08-20.

| Item | Live state |
|---|---|
| Hardware | NVIDIA DGX Spark / GB10, arm64 |
| OS | Ubuntu 24.04.4 LTS, kernel `6.17.0-1029-nvidia` |
| NVIDIA | Driver `580.173.02`, CUDA `13.0`, persistence mode on |
| Firmware reported by OS | `5.36_0ACUM027` |
| Previous boot | 2026-08-04 16:38 IST; about 16 days uptime |
| Storage | 3.7 TiB root volume, 384 GiB used, 3.2 TiB available |
| Network | Ethernet up; Tailscale active; NVIDIA Sync `FirstSpark` SSH route working |
| Docker | Docker and containerd active and boot-enabled |
| Compose | ODS project: 18 running containers; Qwen project: 1 running container |
| Container health | All 19 running containers healthy at capture time |
| Failed units | No failed system or user units at capture time |
| Hermes schedules | No Hermes cron jobs configured |

## Intended resident model state

| Lane | Runtime | State | Endpoint | Identity/settings |
|---|---|---|---|---|
| Qwen 35 | Docker/vLLM | Healthy and always restored | `127.0.0.1:8000` | API id `spark-fast`; checkpoint root `unsloth/Qwen3.6-35B-A3B-NVFP4`; `max_model_len=262144` |
| Nemotron 3.5 Lightning | LM Studio/llmster | One persistent instance | `127.0.0.1:1234` | `nvidia/nemotron-3.5-lightning`; Q4_K_M; 65,536 context; parallelism 4; about 22.83 GiB allocation |
| Nemotron 3 Nano Omni | Compose lane | Stopped/on demand | `127.0.0.1:8004` when active | Validated 131K profile; not part of boot residency |
| Qwen 27 DFlash | Compose lane | Stopped/on demand | `127.0.0.1:8001` when active | Not part of boot residency |

The audit initially found two copies of the same Lightning GGUF loaded as `nvidia/nemotron-3.5-lightning` and `nvidia/nemotron-3.5-lightning:2`, each using about 24 GiB. The recovery configuration deliberately restores one copy only. After correction, available unified memory increased from about 13 GiB to about 35 GiB while Qwen and one Lightning instance remained resident.

## Services that recover automatically

### System services

These are active and enabled at the system level:

- `docker.service`
- `containerd.service`
- `tailscaled.service`
- `ssh.service`
- NVIDIA persistence, telemetry, dashboard, and ODS host services

Every currently running ODS and Qwen container uses Docker restart policy `unless-stopped`. Therefore the 18-container ODS project and `vllm-spark-fast` return when Docker starts, provided they were not deliberately stopped before shutdown.

### User services

User lingering is enabled for `snknitin`, so the user service manager starts at boot without waiting for a graphical login. These services are enabled:

- `hermes-serve.service` — `Restart=always`, Tailscale endpoint `:9119`
- `hermes-gateway.service` — `Restart=always`, Discord/Telegram gateway owner
- `hermes-dashboard.service` — `Restart=always`, Tailscale endpoint `:9120`
- `opencode-web.service` — `Restart=on-failure`, loopback `:3003`
- `lmstudio.service` — newly added and enabled during this recovery work

Hermes Agent version at capture: `v0.20.4 (2026.8.18)`.

## LM Studio recovery unit

Installed at `/home/snknitin/.config/systemd/user/lmstudio.service` and enabled under `default.target`:

```ini
[Unit]
Description=LM Studio headless daemon, local API, LM Link, and Nemotron Lightning
Wants=network-online.target docker.service
After=network-online.target docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
Environment=HOME=/home/snknitin
Environment=PATH=/home/snknitin/.lmstudio/bin:/home/snknitin/.local/bin:/usr/local/bin:/usr/bin:/bin
ExecStartPre=/home/snknitin/.local/bin/wait-for-spark-fast
ExecStartPre=-/home/snknitin/.lmstudio/bin/lms daemon down
ExecStartPre=/usr/bin/sleep 2
ExecStartPre=/home/snknitin/.lmstudio/bin/lms daemon up
ExecStartPre=/home/snknitin/.lmstudio/bin/lms load nvidia/nemotron-3.5-lightning --gpu max --context-length 65536 --yes
ExecStart=/home/snknitin/.lmstudio/bin/lms server start --port 1234 --bind 127.0.0.1
ExecStop=/home/snknitin/.lmstudio/bin/lms daemon down
Restart=on-failure
RestartSec=15s
TimeoutStartSec=10min
TimeoutStopSec=2min

[Install]
WantedBy=default.target
```

The unit waits for Qwen to report healthy, starts from a clean daemon, loads exactly one Lightning instance, starts the loopback API last, and keeps LM Link enabled through llmster's persisted link state. `/home/snknitin/.local/bin/wait-for-spark-fast` checks `vllm-spark-fast` every five seconds for up to 15 minutes. The service-level recovery test passed: unit active/enabled, daemon running, server on `127.0.0.1:1234`, one Lightning model loaded, and `/v1/models` returned HTTP 200.

LM Studio's official headless guide recommends llmster for boot-time service use and provides the same `lms daemon up` / `lms load` / `lms server start` systemd pattern: [Run LM Studio headlessly](https://lmstudio.ai/docs/developer/core/headless) and [set up llmster as a Linux startup task](https://lmstudio.ai/docs/developer/core/headless_llmster).

## Health baseline before reboot

| Check | Expected result |
|---|---|
| Qwen raw health | `http://127.0.0.1:8000/health` → 200 |
| Qwen identity | `/v1/models` → `spark-fast` |
| LiteLLM liveliness | `http://127.0.0.1:4000/health/liveliness` → 200 |
| LM Studio catalog | `http://127.0.0.1:1234/v1/models` → 200 and one Lightning id |
| Hermes Serve | Tailscale `:9119` → HTTP redirect/302, indicating listener active |
| Hermes dashboard | Tailscale `:9120` → HTTP redirect/302, indicating listener active |
| ODS Open WebUI | `http://127.0.0.1:3000/` → 200 |
| SearXNG | `http://127.0.0.1:8888/` → 200 |
| n8n | `http://127.0.0.1:5678/healthz` → 200 |

## Controlled reboot test

Status: **passed through a physical power cycle followed by a normal power-button start on 2026-08-20**. The user ran a controlled shutdown, removed input power, connected the Spark to the UPS, reapplied power, and used one normal power-button press after waiting. The Spark returned with boot time `2026-08-20 18:10:28 IST` and boot ID `d8403435-e8a9-42d5-af9f-d38a45695aab`. Because the button was used, the live UEFI `Auto Boot` value remains unverified even though NVIDIA documents it as the default.

For future controlled reboot checks, run:

```bash
sudo systemctl reboot
```

After SSH returns, run the checks below. Success means no manual service start was necessary and every expected service/model returned.

```bash
uptime
systemctl is-active docker tailscaled ssh
systemctl --user is-active hermes-serve hermes-gateway hermes-dashboard opencode-web lmstudio
systemctl --user is-enabled hermes-serve hermes-gateway hermes-dashboard opencode-web lmstudio
docker ps --format 'table {{.Names}}\t{{.Status}}'
/home/snknitin/.local/bin/spark-model status
/home/snknitin/.lmstudio/bin/lms status
/home/snknitin/.lmstudio/bin/lms ps
/home/snknitin/.lmstudio/bin/lms link status
curl -fsS http://127.0.0.1:8000/health
curl -fsS http://127.0.0.1:1234/v1/models
curl -fsS http://127.0.0.1:4000/health/liveliness
systemctl --failed
systemctl --user --failed
```

### Pass thresholds

- `docker`, `tailscaled`, and `ssh` are active.
- All five named user services are active without manual starts.
- ODS reports 18 healthy containers and Qwen reports one healthy container.
- `spark-model status` shows `qwen35` healthy, Lightning loaded, and Omni/Qwen 27 absent.
- LM Studio lists exactly one Lightning identifier, not a `:2` duplicate.
- LM Studio server is on port 1234 and LM Link reports the Spark online. The workstation peer may take a short time to reconnect if its LM Studio app is sleeping.
- No failed system or user units remain.

### Cold-boot ordering correction

The first physical recovery test exposed a boot-order race rather than a model failure. LM Studio loaded Lightning before Qwen initialized. Qwen then measured only 85.31 GiB free against its 87.62 GiB startup reservation and restarted instead of becoming healthy.

The durable fix was to make `lmstudio.service` wait for `vllm-spark-fast` to become healthy before starting llmster and loading Lightning. After stopping Lightning temporarily, Qwen became healthy; starting the corrected LM Studio unit then restored exactly one Lightning instance. Final verified state:

- Qwen `spark-fast` healthy at `127.0.0.1:8000`, model ceiling 262,144.
- One `nvidia/nemotron-3.5-lightning` instance at 65,536 context on `127.0.0.1:1234`.
- LM Link online and workstation peer connected.
- All 18 ODS containers healthy.
- Hermes Serve, Gateway, and Dashboard active.
- No failed system or user units.

## Safe move to the UPS and physical power-return test

Status: **power cycle and button-start recovery passed on 2026-08-20**. Automatic no-button startup remains a separate UEFI verification. Keep the procedure below for future moves or outage drills.

Once the controlled reboot passes:

1. In NVIDIA Sync, run `sudo systemctl poweroff`.
2. Wait until the Spark is completely off: SSH is gone and fans/activity have stopped.
3. Unplug the Spark from its present outlet and connect it to the UPS. Do not remove live power while databases and model services are running.
4. Apply UPS output power.
5. The Spark should power on automatically because NVIDIA documents `Auto Boot` as the default after-power-loss behavior.
6. Wait for `FirstSpark` SSH to return, then repeat the controlled-reboot verification block.
7. Record boot time, total recovery time, any failed unit, any unhealthy container, and whether manual intervention was required.

If the Spark does not power on automatically, enter UEFI with a physical keyboard and set:

`Advanced → Power On Behavior → After Power Loss Behavior → Auto Boot`

Then save with `Save & Exit → Save Changes and Exit`. Do not perform an AC-loss test during OS or firmware installation.

## Targeted recovery only if a check fails

```bash
# LM Studio / LM Link
systemctl --user restart lmstudio.service

# Hermes processes
systemctl --user restart hermes-serve.service hermes-gateway.service hermes-dashboard.service

# Qwen worker
cd /home/snknitin/ai/services/qwen35
docker compose up -d

# ODS stack
cd /home/snknitin/ods
docker compose up -d
```

Use these only for the failed owner. Do not start Omni or Qwen 27 as part of normal boot recovery, and do not create a second Hermes gateway with the same bot state.

## Related notes

- [[DGX Spark Automatic Power Recovery Research]]
- [[DGX Spark Second Node And Dual Spark Readiness Research 2026-08-20]]
- [[Local Setup Index]]
- [[Always-On Hermes on DGX Spark]]
- [[DGX Spark Model Installation And Switching Guide]]
- [[Hermes LM Link And Workstation Model Routing Research]]
- [[DGX Spark Nemotron 3.5 Lightning Via LM Studio Research]]
- [[Task Checklist]]
