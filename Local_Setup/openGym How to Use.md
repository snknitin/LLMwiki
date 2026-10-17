---
updated: 2026-10-17
status: canonical
scope: workstation, personal, fitness, dashboard-command-center
---

# openGym: How to Use

How to use openGym, the self-hosted gym and body-weight tracker on this PC. How it is installed and started is in [[openGym on Windows Workstation]].

## Open it

- In the Dashboard Command Center, open **Personal → openGym**. That starts it; give it about a minute if Docker Desktop was off.
- Or, while it is running, go to **http://localhost:8095/** in a browser. Use `localhost`, not `127.0.0.1`, or passkeys fail.
- Quitting the Command Center stops it again. Nothing runs at boot.

## First run: profile or guest

Everything stays on this PC. There is no cloud account and no telemetry.

| Choice | Where your data lives | Use when |
|---|---|---|
| **Create profile** (recommended) | `E:\GIT_ROOT\External\openGym\data` | You want history that survives and can be backed up |
| **Continue without account** | The Command Center tab's browser storage only | Just trying it; resetting that tab's session erases it |

Creating a profile asks for a passkey. On Windows that is Windows Hello (PIN or fingerprint). The first profile becomes the admin (`FIRST_USER_ADMIN=1`), which adds an **Admin dashboard** link in Settings.

## Plan your week

1. Load a starter plan (Push/Pull/Legs, Upper/Lower, Full Body or 5×5), or build routines yourself from the exercise library (5,600+ exercises, searchable or by muscle on the body map).
2. Assign a routine to each weekday, or switch to a **rotation** (A, B, C…) where the next session is simply the next one you have not done.
3. In Settings, set the equipment you own (to filter exercises), the plates you own (for plate math) and whether the week starts on Monday or Sunday.
4. Optionally set a progression rule per routine or exercise (linear, double or triple progression, Greyskull LP). It then suggests the next target and explains it.

## Train

- **Home** shows today's workout. Start it and weights are pre-filled from last time.
- Log each set. A rest timer runs between sets, and PRs are flagged as you go.
- Swipe a set left to delete it (with Undo), or right to copy it.
- Forgot to log? You can log a past workout or edit a saved one afterwards.

## Body weight and progress

- Log your weight on Home and set a goal weight, which shows as a line on the chart.
- **Stats** has the year heatmap, estimated 1RM curves, PRs, the muscle map (volume, recovery, untrained) and the body-weight chart.
- Progress photos go on a timeline with a before/after slider.

## Bring data in, take it out

- **Import:** Settings has importers for FitNotes, Strong, Hevy (CSV or API key) and Apple Health weight exports.
- **Export:** Settings exports everything as one JSON file.
- **Back up:** copy `E:\GIT_ROOT\External\openGym\data`. It holds profiles, passkeys, workouts, uploads and the session secret. Losing `secret` signs everyone out but keeps the data.

## Not set up here (on purpose)

- **Phone access:** it is reachable only from this PC. Passkeys on a phone need HTTPS on a real hostname, such as Tailscale Serve plus `RP_ID`/`ORIGIN` in `.env`; see upstream `docs/SELF_HOSTING.md`. The standalone Android APK is a separate, offline app that does not sync with this one.
- **AI coach:** off until an admin turns it on in Settings and adds a provider key (it can use local Ollama). See upstream `docs/AI_COACH.md`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Tab shows an error or a blank page | Docker Desktop may still be starting; wait a minute and press Refresh |
| Passkey prompt fails | Make sure the address is `localhost:8095`, not `127.0.0.1:8095` |
| Need it without the Command Center | `powershell -File F:\Vaults\LLMWiki\Local_Setup\scripts\opengym-start.ps1`, then open http://localhost:8095/ |
| Stop it by hand | `docker compose --project-directory E:\GIT_ROOT\External\openGym stop` |
| Health check | http://localhost:8095/api/health should return `{"ok":true,...}` |

## Update

```powershell
cd E:\GIT_ROOT\External\openGym; git pull; docker compose pull; docker compose up -d
```
