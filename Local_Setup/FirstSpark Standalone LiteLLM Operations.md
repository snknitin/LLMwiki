---
updated: 2026-09-22
status: canonical
scope: firstspark, litellm, hermes, model-routing
---

# FirstSpark Standalone LiteLLM Operations

FirstSpark ODS was retired on 2026-09-22. This note describes the independent LiteLLM installation on **FirstSpark**. The separate Windows workstation ODS installation was not changed.

## Current service

| Item | Current value |
|---|---|
| Compose project and container | `spark-litellm` |
| Files | `$HOME/ai/services/litellm/{compose.yaml,config.yaml,runtime.env}` |
| Image | `ghcr.io/berriai/litellm@sha256:3d80908e35230a0dfb58051ae4e2847371b2a327b44e105e79b8c4f67a65596c` (the prior ODS v1.81.3 image) |
| API | `http://127.0.0.1:4000/v1` |
| Shared Docker network | `spark-model-net` |
| Permanent LiteLLM aliases | `spark-fast`, `qwen27-dflash`, `nemotron3-omni` |
| Private files | `config.yaml`, `compose.yaml`, and `runtime.env` are mode `600`; the service directory is mode `700` |

Hermes kept its `custom:spark-fast` provider, base URL, and API key. The old ODS `default` and `*` aliases pointed to its stopped `llama-server` and were retired. The old Langfuse callback was disabled because the ODS Langfuse service was not running and was removed. The frontier key is present in `runtime.env`, but no unqualified frontier alias was added.

## Normal commands on FirstSpark

```bash
cd "$HOME/ai/services/litellm"
docker compose -p spark-litellm config --quiet
docker compose -p spark-litellm up -d --pull never
docker inspect spark-litellm --format '{{.State.Status}}|{{.State.Health.Status}}'
curl -fsS http://127.0.0.1:4000/health/readiness >/dev/null && echo LITELLM_READY
```

The container uses `restart: unless-stopped`. A post-migration host reboot has not yet been performed, so boot recovery remains to be verified. Model aliases can appear in `/v1/models` while their backend is cold; start the intended backend with `spark-model` before sending chat.

To change `config.yaml` or the image, take a timestamped backup of all three service files, validate Compose, recreate only this service, and check a real model request plus Hermes before accepting the change. Do not run `ods config validate`, `ods start`, or `ods stop` on FirstSpark; the `ods` command and installation no longer exist there.

## Migration proof and rollback archive

The 2026-09-22 migration verified:

- LiteLLM readiness and authenticated `/v1/models` (`spark-fast`, `qwen27-dflash`, `nemotron3-omni`);
- an authenticated `spark-fast` chat completion returning `ROUTE_OK` through LiteLLM;
- a Hermes one-shot request returning `HERMES_ROUTE_OK`;
- `spark-model use qwen35`, model health, and Docker DNS over `spark-model-net`;
- no FirstSpark ODS command, installation path, system unit, container, named volume, or Docker network remained active.

The restricted rollback archive is `$HOME/backups/ods-to-standalone-litellm/20260922-142725/`. It contains the old routing and Hermes files, host-unit copies, archived named volumes, and the former ODS installation and approximately 32 GB of application/model data. It is inert, but it still occupies disk space. Preserve it until the standalone setup passes a controlled reboot and the user decides whether the old data should be deleted.

Continue frontier registration and hot swapping only through [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] after each lane's acceptance gates pass.
