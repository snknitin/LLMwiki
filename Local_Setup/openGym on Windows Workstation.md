---
updated: 2026-10-17
status: completed
scope: workstation, docker, dashboard-command-center, personal, fitness
---

# openGym on Windows Workstation

[openGym](https://github.com/DuarteSantos8/openGym) (AGPL-3.0) is a self-hosted gym and body-weight tracker. It runs on this Windows PC in Docker, loopback only, and is the **openGym** tab in the Dashboard Command Center **Personal** group.

| Item | Value |
|---|---|
| URL | `http://localhost:8095/` (loopback only; use `localhost`, not `127.0.0.1`, because passkeys are bound to `RP_ID=localhost`) |
| Checkout | `E:\GIT_ROOT\External\openGym` |
| Runtime | upstream `docker-compose.yml` (prebuilt `ghcr.io/duartesantos8/opengym-{api,web}`, `restart: unless-stopped`) + local `.env` (gitignored): `WEB_PORT=127.0.0.1:8095`, `ORIGIN=http://localhost:8095`, `FIRST_USER_ADMIN=1` |
| Data | `E:\GIT_ROOT\External\openGym\data` (back this up: accounts, passkeys, workouts, session secret) |
| Start on logon | task `openGym Local` runs `scripts/opengym-start.ps1`: starts Docker Desktop if the engine is down, then `docker compose up -d` |
| Dashboard | registry ids `opengym`, endpoint `opengym-local` (health `/api/health`), session `opengym-session`; backup `registry.pre-opengym-20261017.json` |

## Verified 2026-10-17

- `docker ps`: `opengym-web-1` on `127.0.0.1:8095->80`, `opengym-api-1` internal only.
- `/` returned 200; `/api/health` returned `{"ok":true,"users":0,"writable":true}`.
- Logon task `openGym Local` registered (Ready). Command Center rehashed the registry (seq 4301), opened the openGym tab and did not quarantine it.

## Notes

- The first profile created becomes the admin (`FIRST_USER_ADMIN=1`); create yours before anything else.
- Docker Desktop does not autostart on this PC (see the ODS lite runbook). The logon task starts it, so ODS containers that were running at shutdown come back with it, as Docker always does.

## Update

```powershell
cd E:\GIT_ROOT\External\openGym; git pull; docker compose pull; docker compose up -d
```
