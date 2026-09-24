---
created: 2026-09-24
updated: 2026-09-24
status: installed
scope: dgx-spark, frontier, services, schedules, sparkdash, docker, systemd
---

# DGX Spark Additional Services Controller

> [!summary] Outcome
> `aux-services` is the single catalog and lifecycle controller for FirstSpark services around a large-model session. Its list includes ports, live state, underlying resource, and safety policy. Managed services participate in the bulk drain; protected control-plane services are named-control only; locked transport and Frontier entries are inventory-only. Hermes schedules remain owned entirely by Hermes and are not included.

The maintained script is `scripts/aux-services`. Its live command is `$HOME/.local/bin/aux-services` on FirstSpark. Its editable allow-list is `$HOME/.config/aux-services/services.conf`.

> [!success] Installed and round-trip verified — 2026-09-24
> A live `stop`/`start` cycle stopped and restarted the active managed services while the GLM Frontier API passed a health check after every individual restore. LiteLLM, Hermes gateway/serve, the GLM reasoning bridge, Tailscale, and SSH remained active. sparkDash, YouTube Learning Center, Signal Desk, Dunbar Dossier, and Hermes Dashboard were then individually verified from Windows.

## Normal workflow

Run these in the **FirstSpark Bash terminal**, one command at a time:

```bash
aux-services list
```

`list` is the command catalog: it prints every control name, port mapping, policy, type, live state, and underlying systemd unit, Compose service, or external owner.

```bash
aux-services status
```

```bash
aux-services stop
```

```bash
spark-frontier use qwen38-nvfp4
# or: qwen38-fp8 | glm53-flash | deepseek41-flash
```

After `spark-frontier` reports the lane as active:

```bash
aux-services start
```

`start` restores items in the order written in the config, waits between them, and rechecks the active Frontier API after each item. It does not blindly start every configured item: it restores only items captured as active by the preceding `stop` command. If a start or Frontier health check fails, it stops immediately and keeps the remaining restore snapshot for a later retry.

To control one allow-listed service directly:

```bash
aux-services start sparkdash
aux-services stop sparkdash
aux-services start signal-desk
aux-services stop signal-desk
aux-services start hermes-dashboard
aux-services stop hermes-dashboard
aux-services start youtube-learning-center
aux-services stop youtube-learning-center
aux-services start dunbar-dossier
aux-services stop dunbar-dossier
```

The optional name is case-insensitive and may omit `.service` or `.timer`. A named start or stop controls only that item without changing the saved all-services restore snapshot.

## Dashboard Command Center mapping

| Dashboard | `aux-services` name | FirstSpark owner | Access path |
|---|---|---|---|
| Signal Desk | `signal-desk` | `social-capture.service` | Tailscale Serve `:8765` |
| Hermes Agent | `hermes-dashboard` | `hermes-dashboard.service` | direct tailnet `:9120` |
| YouTube Learning Center | `youtube-learning-center` | `youtube-learning-center.service` | Tailscale Serve `:8443` |
| Dunbar Dossier | `dunbar-dossier` | `dunbar-dossier.service` | Tailscale Serve `:10000` to loopback `:8766` |
| sparkDash | `sparkdash` | Docker Compose `sparkDash` | Windows SSH tunnel `127.0.0.1:5555` |

The Local Setup dashboard is Windows-local on port `8767`, so it is not a FirstSpark item. Hermes Gateway, Hermes Serve, LiteLLM, and the reasoning shim appear as `protected`: bulk stop/start leaves them alone, but an explicit named command can control them. Tailscale Serve, SSH, and the Frontier API appear as `locked`: they can be listed or removed from the catalog, but this command will not start or stop them.

## Why there is no second Windows command

sparkDash binds only to FirstSpark loopback. Windows therefore needs an SSH local-forward listener so Dashboard Command Center can use its stable local URL, `http://127.0.0.1:5555/`. The direct OpenSSH tunnel is owned by the Windows scheduled task `DGX Spark sparkDash Tunnel`; it starts at sign-in and has a five-minute recovery trigger.

The tunnel does not start or stop the remote container. It can safely remain connected while sparkDash is intentionally stopped. Consequently, `aux-services start sparkdash` makes the Windows endpoint healthy automatically, and `aux-services stop sparkdash` makes it unavailable without creating a second manual lifecycle.

## Edit the allow-list

```bash
aux-services edit
```

The supported entries are:

```bash
user-service|UNIT|CONTROL_NAME|PORTS|POLICY
user-timer|UNIT|CONTROL_NAME|PORTS|POLICY
system-service|UNIT|CONTROL_NAME|PORTS|POLICY
system-timer|UNIT|CONTROL_NAME|PORTS|POLICY
docker|CONTAINER|CONTROL_NAME|PORTS|POLICY
frontier|OWNER|CONTROL_NAME|PORTS|POLICY
compose|DISPLAY_NAME|WORKING_DIRECTORY|FILE1,FILE2|SERVICE|CONTROL_NAME|PORTS|POLICY
```

Managed entries are listed in **start order**. `stop` automatically reverses that list so front-end consumers stop before dependencies. `protected` entries accept only named control and never join the bulk drain. `locked` entries are inventory-only. `system-service` and `system-timer` named control invokes `sudo`.

The initial allow-list contains:

- both Obsidian continuous-sync user services;
- Dunbar Dossier, Signal Desk/social capture, OpenCode Web, YouTube Learning Center, the optional Hermes dashboard, and the optional Hermes HTML viewer;
- the loopback-only sparkDash Compose service;
- protected Hermes Gateway, Hermes Serve, LiteLLM, and GLM reasoning-shim entries;
- locked Tailscale Serve, SSH, Frontier API, and Frontier NFS inventory entries.

> [!danger] Do not make model or transport owners bulk-managed
> Keep `spark-litellm`, `hermes-gateway`, `hermes-serve`, and `glm-reasoning-shim` protected. Keep the Frontier API/NFS, Tailscale, and SSH entries locked. Never change those policies to `managed`: a bulk drain must not sever routing, remote access, or the active model lane.

## State and recovery

```bash
aux-services status
```

The `WANT=yes` column means that item was active before the drain and is still waiting to be restored. The snapshot lives at:

```text
~/.local/state/aux-services/restore.list
```

Repeated `stop` calls resume the same saved drain instead of overwriting it. Repeated `start` calls resume the pending restore. Once every saved item is active, the snapshot is removed.

## Add and remove entries

```bash
aux-services add user-service example.service example-dashboard 9000
aux-services add --protected user-service example-core.service example-core 9001
aux-services remove example-dashboard
```

`add` validates the resource and saves an atomic config update with a timestamped backup. `remove` unregisters an item and removes it from a pending restore snapshot, but deliberately does not stop or uninstall the underlying resource. Hermes cron jobs are not a supported type because Hermes owns their lifecycle.

## Related notes

- [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]
- [[DGX Spark Dual-Node Community Frontier Models Runbook]]
- [[DGX Spark sparkDash Monitoring Tutorial]]
- [[FirstSpark Standalone LiteLLM Operations]]
