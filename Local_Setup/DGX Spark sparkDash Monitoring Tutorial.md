---
updated: 2026-09-18
status: ready-for-user-execution
scope: dgx-spark, sparkdash, monitoring, benchmarks, ssh
---

# DGX Spark sparkDash Monitoring Tutorial

> [!summary] Outcome
> Install the pinned MiaAI-Lab sparkDash release on FirstSpark as a loopback-only observer for both DGX Sparks. It may monitor and benchmark the active model, but it does not own model start/stop, Hermes, LiteLLM, or machine shutdown.

This is the standalone sparkDash companion to:

- [[DGX Spark Dual-Node Community Frontier Models Runbook]]
- [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]
- [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]]
- [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]]

> [!tip] Beginner execution rule
> Unless a step explicitly says **Windows** or **SecondSpark**, run its Linux commands in the `FirstSpark` SSH terminal. Run one command block at a time and continue only after its **Expected** or **Pass** result matches. sparkDash is the first repository to install, but complete the shared readiness gates in [[DGX Spark Dual-Node Community Frontier Models Runbook]] before launching it.

## What this installs

| Item | Value |
|---|---|
| Repository | `https://github.com/MiaAI-Lab/sparkDash.git` |
| Reviewed commit | `e448d6b940fefa1762aca25200273484170d4b6c` |
| License | MIT |
| Host | FirstSpark |
| Listen address | `127.0.0.1:5555` only |
| Windows access | SSH tunnel |
| Default challenger probe | port `8100` |
| Remote node | SecondSpark at management IP `192.168.0.100` |

The container uses host networking, host PID namespace, privileged mode, and read-only host filesystem mounts. It is an administrator console. Never publish it directly to the LAN.

## Resource and coexistence decision

sparkDash does not load model weights and does not intentionally reserve GPU memory. It does consume Node.js/Docker host RAM, keeps telemetry history, and polls the second Spark over SSH. Since GB10 host RAM and GPU memory are one unified pool:

- it can normally stay on beside `spark-fast` and the Qwen NVFP4 recipe;
- stop it for the first GLM and DeepSeek boot;
- re-enable it only while recording `MemAvailable` on both nodes;
- leave it stopped if a long-prefill low-water loses the desired safety margin.

## Before starting

On **FirstSpark**, verify the remote key already works:

```bash
ssh -o BatchMode=yes snknitin@192.168.0.100 hostname
```

Expected: `spark-7047`.

List the key files and identify the one actually used:

```bash
ls -l "$HOME/.ssh"
ssh -G snknitin@192.168.0.100 | grep -i '^identityfile '
```

The examples below assume `~/.ssh/id_ed25519_shared`. If the working key has another name, replace only the host-side source path in the override file.

## Step 1 — Clone and pin the reviewed source

Run on **FirstSpark**:

```bash
install -d "$HOME/src/frontier"
cd "$HOME/src/frontier"
git clone https://github.com/MiaAI-Lab/sparkDash.git
cd sparkDash
git checkout --detach e448d6b940fefa1762aca25200273484170d4b6c
git rev-parse HEAD
```

Expected hash:

```text
e448d6b940fefa1762aca25200273484170d4b6c
```

Do not run `git pull` before a model evaluation. A source update changes the monitoring instrument and invalidates benchmark comparisons.

## Step 2 — Configure loopback, port, and SSH reuse

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/sparkDash"
cp .env.example .env
sed -i \
  -e 's/^PORT=.*/PORT=5555/' \
  -e 's/^BIND_HOST=.*/BIND_HOST=127.0.0.1/' \
  -e 's/^SPARKDASH_ALLOW_OPEN_REMOTE=.*/SPARKDASH_ALLOW_OPEN_REMOTE=0/' \
  -e 's/^LLM_PORT=.*/LLM_PORT=8100/' \
  -e 's/^SSH_CONTROL_PERSIST_SECONDS=.*/SSH_CONTROL_PERSIST_SECONDS=300/' \
  .env
printf '\nSSH_IDENTITY_FILE=/root/.ssh/id_ed25519\n' >> .env
chmod 600 .env
```

Keep `BIND_HOST=127.0.0.1` even though the source has token-related remote settings. The reviewed commit's documentation and `.env.example` disagree about tokenless remote behavior; loopback plus an SSH tunnel avoids that ambiguity.

## Step 3 — Mount a read-only key without editing upstream Compose

Create `docker-compose.local.yml` on **FirstSpark**:

```bash
cd "$HOME/src/frontier/sparkDash"
touch docker-compose.local.yml
chmod 600 docker-compose.local.yml
```

Open that file in an editor and save:

```yaml
services:
  sparkdash:
    environment:
      LLM_PORT: "8100"
    volumes:
      - ${HOME}/.ssh/id_ed25519_shared:/root/.ssh/id_ed25519:ro
```

The `environment` override is required. At the reviewed commit, upstream Compose hard-codes `LLM_PORT=8888`, so the `.env` value alone does not change the in-container probe. The container receives only a read-only key. Prefer a dedicated monitoring key later; do not store an SSH password unless necessary.

## Step 4 — Validate the source and Compose plan

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/sparkDash"
npm ci
npm run typecheck
npm test
docker compose -f docker-compose.yml -f docker-compose.local.yml config > /tmp/sparkdash-compose.merged.yaml
grep -A20 '^  sparkdash:' /tmp/sparkdash-compose.merged.yaml | \
  grep -E 'BIND_HOST: 127\.0\.0\.1|LLM_PORT: "?8100"?|SPARKDASH_ALLOW_OPEN_REMOTE: "?0"?'
```

**Pass:** type-check and tests exit zero, and the merged Compose output contains loopback binding, `LLM_PORT=8100`, and `SPARKDASH_ALLOW_OPEN_REMOTE=0`. Do not launch if it still shows `LLM_PORT=8888`.

If Node 22 benchmark behavior fails, do not ignore it. The repository has reported Node-version-sensitive benchmark failures; monitoring can still be assessed separately, but benchmark results are not accepted until the error is resolved.

## Step 5 — Build and launch

Run on **FirstSpark** and keep the build visible:

```bash
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml up --build -d
docker compose -f docker-compose.yml -f docker-compose.local.yml ps
docker logs --tail 100 sparkDash
curl -fsS http://127.0.0.1:5555/api/health | python3 -m json.tool
```

Also prove it is not exposed on FirstSpark's management address:

```bash
ss -ltnp | grep ':5555'
```

**Pass:** the listener is `127.0.0.1:5555`, not `0.0.0.0:5555` or `192.168.0.101:5555`.

## Step 6 — Open the dashboard from Windows

Run in **Windows PowerShell** and keep the command open:

```powershell
$SshConfig = 'C:\Users\Nitin Kishore Sai\AppData\Local\NVIDIA Corporation\Sync\config\ssh_config'
ssh -F $SshConfig -N -L 5555:127.0.0.1:5555 FirstSpark
```

Open `http://127.0.0.1:5555`.

## Step 7 — Add the two Sparks

Add FirstSpark:

| Field | Value |
|---|---|
| Name | `FirstSpark` |
| Unit type | NVIDIA DGX Spark |
| This host | Yes |
| Role | Head |
| LLM port | `8100` |
| Hermes monitoring | Off initially |
| ComfyUI | Off |
| Shutdown/Wake | Off |

Add SecondSpark:

| Field | Value |
|---|---|
| Name | `SecondSpark` |
| Unit type | NVIDIA DGX Spark |
| This host | No |
| LAN/SSH host | `192.168.0.100` |
| SSH user | `snknitin` |
| CX-7 IP | `192.168.100.11` |
| Role | Worker |
| LLM port | none unless a single-node service is deliberately running there |
| Hermes monitoring | Off |
| ComfyUI | Off |
| Shutdown/Wake | Off |

Use the UI's connection test. Remote system collectors must pass. The worker is not expected to expose the head's OpenAI API.

## Step 8 — Configure an authenticated model probe

The frontier model on port `8100` uses an API key. In sparkDash, add port `8100` to FirstSpark and save the same key through the per-port API-key setting. The key lives in sparkDash's encrypted secret store, not `sparks.json`.

Back up both of these after initial configuration:

```bash
cd "$HOME/src/frontier/sparkDash"
install -d -m 700 "$HOME/backups/sparkdash"
cp -a config/.secrets-key "$HOME/backups/sparkdash/.secrets-key"
cp -a config/sparks-secrets.json "$HOME/backups/sparkdash/sparks-secrets.json" 2>/dev/null || true
chmod 600 "$HOME/backups/sparkdash/"*
```

If `.secrets-key` is lost, encrypted passwords/API keys cannot be recovered.

## Step 9 — Validate monitoring without granting control

With `spark-fast` active, confirm:

- FirstSpark and SecondSpark temperatures, utilization, memory, storage, and network data update;
- no repeated SSH authentication failures appear in `docker logs sparkDash`;
- token counters are absent or offline for port `8100` when no frontier model runs;
- the dashboard does not start or stop a model;
- shutdown and Hermes-update actions remain unconfigured.

Then launch one frontier model from its dedicated tutorial and confirm:

- FirstSpark port `8100` becomes healthy;
- SecondSpark shows worker GPU activity without a separate API;
- model name and token counters match the active recipe;
- memory readings agree with `free -h` and `nvidia-smi` closely enough for operational use.

## Step 10 — Benchmark policy

Use sparkDash benchmark results only when:

1. the active model is already healthy through direct `curl` tests;
2. the dashboard points to port `8100` with the API key;
3. no other requests are hitting the server;
4. the exact repository commit, model revision, and `.env` profile are recorded;
5. both nodes remain reachable and free of `NV_ERR_NO_MEMORY`.

Record cold prefill, warm prefill, TTFT, one-stream decode, and supported concurrency separately. Do not compare one model's thinking-on output against another model's thinking-off output.

## Daily commands

Status and logs on **FirstSpark**:

```bash
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml ps
docker logs --tail 100 sparkDash
```

Stop during a memory-tight model qualification:

```bash
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml stop
```

Restart after measuring sufficient headroom:

```bash
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml start
```

Remove the container while preserving the repository configuration:

```bash
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml down
```

## Troubleshooting

### Remote unit repeatedly reconnects

```bash
docker logs --since 10m sparkDash | grep -Ei 'ssh|timeout|auth|error'
```

Keep key authentication and the 300-second control-persist setting. If churn remains excessive, stop remote polling and retain FirstSpark-only monitoring until the upstream issue is resolved.

### Port 5555 is not loopback-only

```bash
cd "$HOME/src/frontier/sparkDash"
sed -i 's/^BIND_HOST=.*/BIND_HOST=127.0.0.1/' .env
docker compose -f docker-compose.yml -f docker-compose.local.yml up -d --force-recreate
ss -ltnp | grep ':5555'
```

### Dashboard memory affects GLM or DeepSeek

Stop it and repeat the same long-prefill test. Keep it off if the dashboard-on run materially lowers `MemAvailable` or adds driver allocation failures. Monitoring is optional; model stability is not.

## Acceptance checklist

- [ ] Source is pinned at `e448d6b940fefa1762aca25200273484170d4b6c`.
- [ ] Tests pass or any limitation is explicitly recorded.
- [ ] Listener is only `127.0.0.1:5555`.
- [ ] Windows access works through the SSH tunnel.
- [ ] Both Sparks report correct hardware telemetry.
- [ ] The worker uses key authentication without password prompts.
- [ ] Model port `8100` works with a stored per-port API key.
- [ ] No shutdown, Wake, Hermes-update, or model-lifecycle authority is enabled.
- [ ] `.secrets-key` has a protected backup.
- [ ] GLM/DeepSeek A/B testing establishes whether sparkDash can remain resident.

## Primary source

**Next:** keep sparkDash installed, record the idle baseline, then open [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]. Stop sparkDash when that tutorial explicitly asks for a raw memory qualification.

- [MiaAI-Lab sparkDash](https://github.com/MiaAI-Lab/sparkDash)
