---
updated: 2026-10-17
status: completed
scope: workstation, docker, dashboard-command-center, monitoring, news
---

# World Monitor on Windows Workstation

[World Monitor](https://github.com/koala73/worldmonitor) (AGPL-3.0) is a real-time global news and geopolitical dashboard. It runs on demand on this Windows PC in Docker, loopback only, and is the **World Monitor** tab in the Dashboard Command Center **Monitoring** group. Its AI briefs use the [[Desktop Qwen Runbook|Desktop Qwen 3.8 27B]] llama-server.

## Why the desktop and not Spark

- The app needs one OpenAI-compatible chat endpoint (`OLLAMA_API_URL`, or `LLM_API_URL`); no OpenRouter key needed. Desktop Qwen on `127.0.0.1:11435` is always on from boot, ~90 tok/s, and Docker reaches it at `host.docker.internal:11435`, the same path Fresh Brief uses.
- The Command Center runs here, and the openGym/ComfyUI on-demand pattern (tab opens → start script, quit → stop) only works for local processes. On Spark it would need an SSH start/stop path and a tunnel for the tab.
- The Spark fast models are kept for Hermes and the frontier pair; World Monitor's LLM load is light (short briefs, capped at 50 calls a day per IP).
- Trade-off: when Desktop Qwen is OFF for ComfyUI, the AI briefs come back empty; the maps and feeds still work.

| Item | Value |
|---|---|
| URL | `http://localhost:8096/` (loopback only; port 3000 is taken on this PC) |
| Checkout | `E:\GIT_ROOT\External\worldmonitor`, branch `local` = upstream `a5bccad` + one commit `016f612` that adds `chat_template_kwargs: {enable_thinking:false}` to the Ollama request in `server/_shared/llm.ts`. Without it llama-server ignores Ollama's `think:false`, Qwen spends the whole token budget thinking, and every brief idle-times out empty. `core.autocrlf=false` in this clone: CRLF checkouts break the Docker build at `pro-test/prerender.mjs` |
| Runtime | upstream `docker-compose.yml`, images built locally (`docker compose build`, ~10 min). Containers `worldmonitor` (`127.0.0.1:8096->8080`), `worldmonitor-redis-rest` (`127.0.0.1:8079`), `worldmonitor-ais-relay`, `worldmonitor-redis` (internal) |
| Local config (gitignored) | `.env`: `WM_PORT=127.0.0.1:8096` plus the four generated secrets (`RELAY_SHARED_SECRET`, `REDIS_PASSWORD`, `REDIS_TOKEN`, `WM_SESSION_SECRET`). `docker-compose.override.yml`: `OLLAMA_API_URL=http://host.docker.internal:11435`, `OLLAMA_MODEL=qwen3.8-27b-desktop` |
| Data | Docker volume `worldmonitor_redis-data` (cache only; safe to lose) |
| Seeding | Optional. The news digest the AI briefs read is built by the app itself when the dashboard loads. `sh scripts/run-seeders.sh` (Git Bash, after `npm ci`) fills the economic/market panels; it runs 217 seeders one by one (32 took ~15 min), and many fail without their optional API keys. A partial run was done on 17 Oct; Redis keeps it across stops |
| On demand | opening the Command Center tab runs `scripts/worldmonitor-start.ps1` (action `worldmonitor-start`): starts Docker Desktop if the engine is down, then `docker compose up -d --wait` (waits for the health checks, so the tab doesn't open on an empty reply). Quitting the app runs `docker compose stop` if the app started it |
| Dashboard | registry ids `worldmonitor`, endpoint `worldmonitor-local` (health `/api/sidecar-health`), session `worldmonitor-session`; backup `registry.pre-worldmonitor-20261017.json`. Code: dashboard-command-center `05308f2` (openGym and World Monitor now share one `composeService` helper in `recovery-service.ts`) |

## Verified 2026-10-17

- All four containers up and healthy; only `127.0.0.1:8096` and `127.0.0.1:8079` listen on the host.
- `/` and `/api/sidecar-health` returned 200; `/api/llm-health` reported provider `ollama` at `host.docker.internal:11435` available.
- Country brief for GB: grounded, cited text from `qwen3.8-27b-desktop` in 4 s (after the thinking fix).
- With the stack stopped, `--open-dashboard=worldmonitor` started all four containers and the tab went to running; registry seq 4351 accepted, not quarantined. Quit → stop was not exercised (Quit is only in the tray menu); it is the same shared code path as openGym.

## Update

Rebase the one local commit, then rebuild:

```powershell
cd E:\GIT_ROOT\External\worldmonitor; git fetch origin main; git rebase origin/main; docker compose up -d --build
```

