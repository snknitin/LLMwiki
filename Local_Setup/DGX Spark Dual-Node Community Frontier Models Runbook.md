---
updated: 2026-09-21
status: ready-for-user-execution
scope: dual-dgx-spark, vllm, exl3, qwen3.8, glm-5.3, deepseek-v4.1, sparkdash, litellm, hermes
---

# DGX Spark Dual-Node Community Frontier Models Runbook

> [!summary] Decision
> Implement the MiaAI-Lab repositories as pinned, isolated, two-node challenger lanes. Preserve their tested images, checkpoints, launchers, quantization, speculative decoding, and default runtime geometry for the first successful boot. Change only this cluster's addresses, interface/HCA names, API port, SSH user, and authentication. Keep `spark-fast` as the rollback. After each lane passes direct and coexistence validation, register it under its own LiteLLM/Hermes alias so every installed model remains selectable while only one large backend is resident.

This is the command-first implementation guide for the connected `FirstSpark` and `SecondSpark`. It complements [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]] and uses the live network and service ownership recorded in [[DGX Spark Dual-Node Configuration And Operations Reference]].

## Canonical reading and execution path

Follow this order. Do not jump from research directly to DeepSeek.

1. This overview: shared architecture, memory, readiness, and rollback.
2. [[DGX Spark sparkDash Monitoring Tutorial]]: install the observer first and record the idle two-node baseline.
3. [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]: NVFP4 baseline, then official FP8 A/B.
4. [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]]: experimental second model family.
5. [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]]: final, tightest-memory model.
6. [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]: register every validated alias in LiteLLM/Hermes and install the cluster-aware switch command.

Each tutorial ends with a stop and `spark-fast` rollback gate. Pass that gate before opening the next tutorial.

> [!tip] How to use these guides
> 1. Start in Windows PowerShell and open the Spark terminal named immediately above each command block.
> 2. Copy and run **one block at a time**. Do not copy headings, explanatory text, or an example output into the terminal.
> 3. Wait for long downloads, image pulls, builds, and model starts to finish; do not open the next step just because the terminal is quiet.
> 4. Compare the result with the stated **Expected** or **Pass** condition. If it does not match, stop at that step and use its troubleshooting section.
> 5. Never “fix” a prerequisite by disabling authentication, idle-GPU checks, SSH host-key checking, or memory checks.

## Read this conclusion first

The three frontier recipes are **hot-swap appliances**, not additional always-hot models. Each recipe uses one GB10 rank on **both** Sparks and consumes most of each node's 121.69 GiB CUDA-visible unified memory. Do not run `spark-fast`, Spark LM Studio, or another GPU model while one is active.

`sparkDash` is different: it is a CPU-side monitoring dashboard and does not load model weights. It can normally remain running, but stop it during the first GLM or DeepSeek boot and near-limit context tests because even host RAM is part of the same unified-memory pool.

### Memory and coexistence matrix

| Lane | Nodes occupied | Published per-node runtime facts | Practical coexistence decision |
|---|---:|---|---|
| Current `spark-fast` | First only | Current live model allocation was about 40.2 GiB; the user's end-to-end observation is roughly 50 GiB after the new 10 GiB KV/two-sequence profile. SecondSpark remains free. | May coexist with an **independent** model on SecondSpark. It cannot coexist with any recipe below because every recipe needs both nodes idle. |
| sparkDash | One management host | No model weights or intentional GPU allocation; Node.js, SSH polling, history, and Docker still consume host RAM. | Usually always on. Stop for the first GLM/DeepSeek boot and re-enable only after measured `MemAvailable` proves room. |
| Qwen 3.8 Flash Next NVFP4 | Both | Per node: 101.61 GiB vLLM budget at GMU 0.835; approximately 66–69 GiB weights plus non-torch allocations (the README contains two measurements); 1.07 GiB peak activation; 0.54 GiB CUDA graphs; 32.02 GiB FP8 KV. The repository measured a 2.33–2.38 GiB host-memory low-water during its sweep. | Exclusive two-node lane. No other GPU model. Raw-qualify with nonessential services stopped; add LiteLLM/Hermes and sparkDash back only through measured A/B gates. |
| Qwen 3.8 Flash Next official FP8 | Both | Same two-node launcher and 0.835 budget, but the larger FP8 weight footprint leaves only about 500K cache tokens versus 3.65M for NVFP4. The repository does not publish a complete per-line memory table for this path. | Exclusive two-node lane. Less context/concurrency headroom than NVFP4; measure the live startup lines before promotion. |
| GLM 5.3 Flash EXL3 4 bpw | Both | On this pair, the pinned image failed at the upstream GMU 0.85 because 850K needed 13.46 GiB KV and only 12.25 GiB was available. The live-validated correction is GMU 0.87 plus `GLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912`; it exposed 14.15 GiB KV / 880,357 tokens. The optional 500K/0.84 profile remains the safer-memory adaptation. | Exclusive two-node lane. Stop Spark LM Studio and sparkDash for first boot. Do not schedule downloads, indexing, or other large host jobs beside it. Use the GLM tutorial's Step 16 for MTP/500K A/B profiles and separate result records. |
| DeepSeek V4.1 Flash EXL3 2.9 bpw | Both | Per node: 99.5 GiB weights, 2.5 GiB KV, about 5–7 GiB context/CUDA/NCCL/graphs, and about 9 GiB for vLLM/OS/Docker/desktop. Measured 4.07–4.21 GiB available after warm-up and 2.1 GiB after a 601K prefill. | Strictly exclusive. This is the tightest lane and the last one to implement. Stop all nonessential services during qualification. |

These are **unified-memory** figures. `nvidia-smi`, Linux `MemAvailable`, page cache, Docker, and desktop processes all draw from the same physical 128 GB. A model can boot and still fail later during a long prefill; acceptance therefore includes loaded-context tests, not merely `/health`.

### What can actually run in parallel

| Combination | Supported here? | Reason |
|---|---|---|
| `spark-fast` on First + a single-node model on Second | Yes, after explicitly building a SecondSpark-only lane | Each node owns its own memory; no inter-node tensor parallelism is involved. |
| `spark-fast` + Qwen/GLM/DeepSeek two-node recipe | No | Rank 0 needs FirstSpark and rank 1 needs SecondSpark; memory on FirstSpark would be oversubscribed. |
| Any two frontier recipes together | No | All claim both GB10 devices, the same distributed ports, and similar container names. |
| sparkDash + Qwen NVFP4 | Conditional after Qwen passes alone | sparkDash has no intended CUDA allocation, but its actual host-RAM ceiling is unpublished. Verify the host-memory low-water in a matched A/B. |
| sparkDash + GLM or DeepSeek | Qualification only after an A/B memory check | These recipes have narrow host-memory margins. |
| LiteLLM and Hermes + one frontier recipe | Conditional and required before alias promotion | Live observation found LiteLLM at roughly 0.5 GiB RSS and standalone Hermes processes around 1.1 GiB. Add them only after the raw model passes, repeat the long-context load, and promote only if the low-water remains safe. The rest of ODS stays stopped during qualification. |

## Reviewed and pinned source set

The commits below are the versions reviewed for this guide. Do not run an unreviewed `git pull` immediately before a model launch.

| Repository | Reviewed commit | License relevant to this rollout | Role |
|---|---|---|---|
| [sparkDash](https://github.com/MiaAI-Lab/sparkDash) | `e448d6b940fefa1762aca25200273484170d4b6c` | MIT | Monitoring and benchmark UI |
| [Qwen3.8 Flash Next Dual DGX Sparks](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks) | `d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22` | AGPL-3.0-or-later for recipe code; checkpoint terms remain separate | First model implementation; NVFP4 and official FP8 paths |
| [GLM 5.3 Flash EXL3 2x DGX Sparks](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks) | `ca8557665bffa6529758f2c330ba8fb44c1e801a` | AGPL-3.0-or-later; DFlash2 is CC BY-NC-ND 4.0 research/evaluation | Second model implementation |
| [DeepSeek V4.1 Flash EXL3 2x DGX Sparks](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks) | `8404ac7d389c418300d0bee960d52313247930e1` | AGPL-3.0-or-later for recipe code; model license remains separate | Final, highest-risk implementation |

The public repositories are reproducible enough to implement. Public non-Aiden dual-Spark Qwen FP8 recipes also exist, including [0rand's stack](https://github.com/0rand/qwen3.8-flash-next-2x-dgx-sparks) and [Tom Sarihan's measured playbook](https://github.com/tsarihan/qwen3.8-flash-next-fp8-2x-dgx-spark-playbook). What remains unavailable is a public **Aiden-authored or explicitly Aiden-derived** Qwen recipe with an immutable image digest, launcher, patch set, and configuration. Use the requested MiaAI-Lab repository's supported `start-fp8.sh` path first and treat the other public recipes as independent corroboration, not settings to merge. Add an Aiden lane only after obtaining its exact artifacts and validation receipts.

## Fixed values for this cluster

| Setting | FirstSpark/head | SecondSpark/worker |
|---|---|---|
| NVIDIA Sync alias | `FirstSpark` | `SecondSpark` |
| Hostname | `spark-07a8` | `spark-7047` |
| User | `snknitin` | `snknitin` |
| Management IP | `192.168.0.101` | `192.168.0.100` |
| Primary CX-7 IP | `192.168.100.10` | `192.168.100.11` |
| Interface | `enp1s0f1np1` | `enp1s0f1np1` |
| HCA | `rocep1s0f1` | `rocep1s0f1` |
| RoCE GID | `3` | `3` |
| Challenger API | `192.168.0.101:8100` | No public API |

Port `8888`, used by the upstream recipes, is already occupied on FirstSpark by ODS SearXNG. Every challenger therefore uses host port `8100`. This is a local integration change, not a model/runtime change.

## Rollout order

1. Repair the two prerequisite mismatches.
2. Install sparkDash in loopback-only monitoring mode.
3. Stage all repositories at the reviewed commits.
4. Prove Qwen NVFP4 exactly as shipped, with only cluster/port/auth substitutions.
5. A/B the repository's official FP8 path against NVFP4.
6. Prove GLM 5.3 at the tutorial's live-validated 850K/DFlash profile, then optionally A/B MTP/850K and DFlash/500K as separately recorded profiles.
7. Prove DeepSeek V4.1 last.
8. Register every validated lane under a distinct LiteLLM/Hermes alias.
9. Install the cluster-aware hot-swap command only after manual start/stop/rollback is stable.
10. Keep a generic `spark-frontier` alias only as an optional pointer to the currently preferred lane; never use it instead of the named aliases.

Do not extend the existing `spark-model` script before the first proof. Its current adapters manage single-node Compose or LM Studio lanes, while these repositories own two-node shell launchers. Manual repository lifecycle commands are the faithful path.

---

## Phase 0 — Open the correct terminals

### Windows PowerShell

```powershell
$SshConfig = 'C:\Users\Nitin Kishore Sai\AppData\Local\NVIDIA Corporation\Sync\config\ssh_config'
ssh -F $SshConfig FirstSpark
```

Open a second PowerShell window when this guide says **SecondSpark terminal**:

```powershell
$SshConfig = 'C:\Users\Nitin Kishore Sai\AppData\Local\NVIDIA Corporation\Sync\config\ssh_config'
ssh -F $SshConfig SecondSpark
```

All remaining Linux commands state where to run them. Long downloads, image pulls, builds, and model starts are deliberately left visible in the user's terminal.

## Phase 1 — Repair the readiness gates

### 1.1 Give SecondSpark normal Docker access

Run on **SecondSpark**:

```bash
sudo usermod -aG docker snknitin
sudo reboot
```

Reconnect after the reboot, then run:

```bash
id
docker ps
```

**Pass:** `id` includes the `docker` group and `docker ps` succeeds without `sudo`.

### 1.2 Repair the reverse management-IP host key without weakening SSH

Run on **FirstSpark** and keep the printed fingerprint visible:

```bash
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Run on **SecondSpark**:

```bash
tmp_key="$(mktemp)"
ssh-keyscan -t ed25519 192.168.0.101 > "$tmp_key"
ssh-keygen -lf "$tmp_key"
```

Compare the fingerprints. Only if they match, continue on **SecondSpark**:

```bash
install -d -m 700 "$HOME/.ssh"
cat "$tmp_key" >> "$HOME/.ssh/known_hosts"
chmod 600 "$HOME/.ssh/known_hosts"
rm -f "$tmp_key"
ssh -o BatchMode=yes snknitin@192.168.0.101 hostname
```

**Pass:** the last command prints `spark-07a8`. Never use a global `StrictHostKeyChecking=no` workaround.

### 1.3 Align NVIDIA Container Toolkit at 1.20.0

Live inspection on 2026-09-18 found FirstSpark at `1.19.1-1`, SecondSpark at `1.20.0-1`, and `1.20.0-1` as the candidate on both. This restart affects Docker, so perform it as a maintenance action.

Run on **FirstSpark**:

```bash
spark-model stop
docker ps --format 'table {{.Names}}\t{{.Status}}'
apt-cache policy nvidia-container-toolkit nvidia-container-toolkit-base
sudo apt-get update
sudo apt-get install --only-upgrade \
  nvidia-container-toolkit=1.20.0-1 \
  nvidia-container-toolkit-base=1.20.0-1 \
  libnvidia-container-tools=1.20.0-1 \
  libnvidia-container1=1.20.0-1
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
nvidia-ctk --version
docker ps
```

Run on **SecondSpark**:

```bash
nvidia-ctk --version
docker ps
```

**Pass:** both report 1.20.0 and Docker works without `sudo`.

### 1.4 Re-prove the actual fabric values

Run on **both Sparks**:

```bash
hostnamectl --static
ip -br -4 addr show enp1s0f1np1
ibdev2netdev
cat /sys/class/infiniband/rocep1s0f1/ports/1/gids/3
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
```

Run on **FirstSpark**:

```bash
ping -c 3 192.168.100.11
ssh -o BatchMode=yes snknitin@192.168.100.11 hostname
ssh snknitin@192.168.100.11 docker ps
```

**Pass:** the interface/HCA/GID values match the fixed-value table, the peer is `spark-7047`, and remote Docker succeeds.

## Phase 2 — Create the common secret and source layout

Run on **FirstSpark**:

```bash
install -d -m 700 "$HOME/.config/frontier" "$HOME/src/frontier"
umask 077
test -s "$HOME/.config/frontier/api-key" || \
  openssl rand -hex 32 > "$HOME/.config/frontier/api-key"
chmod 600 "$HOME/.config/frontier/api-key"
```

Do not print this key, paste it into chat, commit it, or enable shell tracing while loading it.

Clone and pin all reviewed repositories on **FirstSpark**:

```bash
cd "$HOME/src/frontier"

git clone https://github.com/MiaAI-Lab/sparkDash.git
git -C sparkDash checkout --detach e448d6b940fefa1762aca25200273484170d4b6c

git clone https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks.git qwen38-dual
git -C qwen38-dual checkout --detach d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22

git clone https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks.git glm53-dual
git -C glm53-dual checkout --detach ca8557665bffa6529758f2c330ba8fb44c1e801a

git clone https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks.git deepseek41-dual
git -C deepseek41-dual checkout --detach 8404ac7d389c418300d0bee960d52313247930e1

for repo in sparkDash qwen38-dual glm53-dual deepseek41-dual; do
  printf '%-18s %s\n' "$repo" "$(git -C "$repo" rev-parse HEAD)"
done
```

**Pass:** all four hashes match the reviewed source table.

> [!important] Beginner stop-and-handoff point
> Stop executing this overview here. Open [[DGX Spark sparkDash Monitoring Tutorial]] and follow it from Step 1 through its acceptance checklist. The remaining phases in this runbook are a compact reference map; the individual tutorials are the authoritative paste-ready procedures with detailed tests and rollback.

## Phase 3 — Install sparkDash in monitoring-only mode

> [!warning] Reference summary only
> Execute [[DGX Spark sparkDash Monitoring Tutorial]], not this condensed phase. Continue to Qwen only after that tutorial's acceptance checklist passes.

This first deployment deliberately keeps loopback binding, omits shutdown/Wake configuration, and uses SSH key authentication. The container is privileged and mounts host `/proc`, `/sys`, and `/`; treat it as an administrator tool, not a public web app.

### 3.1 Verify the shared SSH key path

Run on **FirstSpark**:

```bash
ls -l "$HOME/.ssh"
ssh -o BatchMode=yes snknitin@192.168.0.100 hostname
```

Use the existing private key that produced the successful second command. The examples below assume it is `~/.ssh/id_ed25519_shared`; substitute the verified path if different.

### 3.2 Configure and launch

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

Create a Compose override rather than editing upstream `docker-compose.yml`:

```bash
cp /dev/null docker-compose.local.yml
chmod 600 docker-compose.local.yml
```

Open `docker-compose.local.yml` in an editor and save exactly:

```yaml
services:
  sparkdash:
    environment:
      LLM_PORT: "8100"
    volumes:
      - ${HOME}/.ssh/id_ed25519_shared:/root/.ssh/id_ed25519:ro
```

The override must set `LLM_PORT`; the reviewed upstream Compose file hard-codes `8888` and otherwise wins over `.env`.

Validate before launch:

```bash
docker compose -f docker-compose.yml -f docker-compose.local.yml config > /tmp/sparkdash-compose.merged.yaml
grep -A20 '^  sparkdash:' /tmp/sparkdash-compose.merged.yaml | \
  grep -E 'BIND_HOST: 127\.0\.0\.1|LLM_PORT: "?8100"?|SPARKDASH_ALLOW_OPEN_REMOTE: "?0"?'
npm ci
npm test
docker compose -f docker-compose.yml -f docker-compose.local.yml up --build -d
docker compose -f docker-compose.yml -f docker-compose.local.yml ps
docker logs --tail 100 sparkDash
curl -fsS http://127.0.0.1:5555/api/health
```

### 3.3 Open it from Windows without exposing it to the LAN

Run in **Windows PowerShell** and keep this tunnel open:

```powershell
$SshConfig = 'C:\Users\Nitin Kishore Sai\AppData\Local\NVIDIA Corporation\Sync\config\ssh_config'
ssh -F $SshConfig -N -L 5555:127.0.0.1:5555 FirstSpark
```

Open `http://127.0.0.1:5555` in the browser.

Add:

- FirstSpark as **This host**, role **Head**, LLM port `8100`.
- SecondSpark as remote `192.168.0.100`, user `snknitin`, CX-7 IP `192.168.100.11`, role **Worker**.
- Leave ComfyUI, Hermes update, shutdown, and Wake controls disabled for the first rollout.

If API authentication is enabled for the model, use sparkDash's per-port API-key setting for port `8100`; do not remove model authentication to make monitoring easier.

Stop/start commands:

```bash
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml stop
docker compose -f docker-compose.yml -f docker-compose.local.yml start
```

## Phase 4 — Common drain, observation, and rollback

### Drain before every two-node launch

Run on **FirstSpark**:

```bash
spark-model stop
systemctl --user stop lmstudio.service 2>/dev/null || true
systemctl --user stop hermes-dashboard.service hermes-gateway.service hermes-serve.service
ods stop
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
free -h
```

Run on **SecondSpark**:

```bash
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
free -h
```

Stop sparkDash for the first raw boot and stress test of **every** frontier profile:

```bash
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml stop
```

Do not set a recipe's idle-GPU guard to false to bypass this gate.

After the raw model passes its long-context/load test, add services back one layer at a time and repeat the identical load:

1. start only `ods-litellm`;
2. start `hermes-serve` and `hermes-gateway`;
3. start sparkDash;
4. keep the rest of ODS stopped unless a measured low-water proves it is safe.

This is necessary because the live ODS containers use several GiB of RSS, while the published Qwen/GLM/DeepSeek low-water margins are only a few GiB.

Run these commands on **FirstSpark**. Do not use `ods start litellm` here: this ODS installation declares `llama-server` as a LiteLLM dependency, so that command also starts the GPU model container.

```bash
# 1. LiteLLM only; do not start its declared llama-server dependency.
docker start ods-litellm
docker ps --filter name='^/ods-' --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# 2. Hermes API and gateway only.
systemctl --user start hermes-serve.service hermes-gateway.service
systemctl --user --no-pager --full status hermes-serve.service hermes-gateway.service

# 3. sparkDash, with a bounded readiness wait rather than an immediate curl.
cd "$HOME/src/frontier/sparkDash"
docker compose -f docker-compose.yml -f docker-compose.local.yml up -d sparkdash
for attempt in $(seq 1 30); do
  curl -fsS http://127.0.0.1:5555/api/health && break
  (( attempt == 30 )) && exit 1
  sleep 1
done

# 4. This must print only ods-litellm. If another ODS container appears, stop it.
docker ps --filter name='^/ods-' --format '{{.Names}}'
```

### Observe both nodes during a long start or test

Open one terminal on each Spark and run:

```bash
watch -n 2 'free -h; echo; nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv; echo; dmesg --level=err,warn 2>/dev/null | tail -n 12'
```

Stop immediately if either node repeatedly reports `NV_ERR_NO_MEMORY`, a rank dies, SSH stops responding, or `MemAvailable` is exhausted.

### Universal rollback

Run the active repository's own stop command first. Then on **FirstSpark**:

```bash
docker ps --format '{{.Names}}' | grep -E 'vllm-fn|glm53|dsv41' && exit 1 || true
ssh -o BatchMode=yes snknitin@192.168.0.100 \
  "docker ps --format '{{.Names}}' | grep -E 'vllm-fn|glm53|dsv41' && exit 1 || true"
ss -ltnp | grep -E ':(8100|29521|50000)\b' && exit 1 || true
ssh -o BatchMode=yes snknitin@192.168.0.100 \
  "ss -ltnp | grep -E ':(8100|29521|50000)\\b' && exit 1 || true"
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
docker stop ods-llama-server 2>/dev/null || true
"$HOME/.lmstudio/bin/lms" daemon down >/dev/null 2>&1 || true
spark-model use qwen35
curl -fsS http://127.0.0.1:8000/v1/models
```

**Pass:** the frontier containers are absent and `spark-fast` answers on port `8000`.

If `spark-model` still reports that another operation is running while LM Studio's server is stopped, identify the lock owner before retrying:

```bash
fuser -v "$HOME/.local/state/spark-model/manager.lock"
```

An `llmster` owner in this state is an inherited LM Studio daemon lock, not an active model switch. Shut it down with `"$HOME/.lmstudio/bin/lms" daemon down`, confirm `fuser` returns no owner, and rerun `spark-model use qwen35`. Do not delete the lock file while a process still owns it.

---

## Phase 5 — Qwen 3.8 Flash Next NVFP4: first community recipe

> [!warning] Reference summary only
> Execute [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]], which supplies the immediate health, identity, correctness, memory, stop, and rollback gates omitted from this overview.

This is the preferred first challenger. The published default uses TP2 + expert parallelism + MTP3, an NVIDIA NVFP4 checkpoint, FP8 KV, native 262K context, and a local checkpoint copy on each node.

### 5.1 Configure only the cluster-specific substitutions

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
cp .env.sample .env
sed -i \
  -e 's|^HEAD_IP=.*|HEAD_IP="192.168.100.10"|' \
  -e 's|^WORKER_IP=.*|WORKER_IP="192.168.100.11"|' \
  -e 's|^WORKER_USER=.*|WORKER_USER="snknitin"|' \
  -e 's|^IFACE=.*|IFACE="enp1s0f1np1"|' \
  -e 's|^IB_HCA=.*|IB_HCA="=rocep1s0f1"|' \
  -e 's|^IB_GID_INDEX=.*|IB_GID_INDEX=3|' \
  -e 's|^PORT=.*|PORT=8100|' \
  -e 's|^NFS_SHARE=.*|NFS_SHARE=false|' \
  .env
printf '\nWORKER_IFACE="enp1s0f1np1"\nWORKER_IB_HCA="=rocep1s0f1"\n' >> .env
frontier_key="$(<"$HOME/.config/frontier/api-key")"
printf 'EXTRA_VLLM_ARGS="--api-key %s"\n' "$frontier_key" >> .env
unset frontier_key
chmod 600 .env
```

Confirm the non-secret values without printing the secret:

```bash
grep -E '^(HEAD_IP|WORKER_IP|WORKER_USER|IFACE|WORKER_IFACE|IB_HCA|WORKER_IB_HCA|IB_GID_INDEX|PORT|MODEL_ID|MAX_MODEL_LEN|GPU_MEMORY_UTILIZATION|MAX_NUM_SEQS|MTP_NUM_SPECULATIVE_TOKENS|NFS_SHARE)=' .env
```

Expected recipe settings remain `MAX_MODEL_LEN=262144`, GMU `0.835`, eight sequences, MTP3, FP8 KV, and `NFS_SHARE=false`.

### 5.2 Stage and verify weights

Keep this visible on **FirstSpark**:

```bash
./download.sh
./start.sh --no-launch
./check-weights.sh
./check-weights.sh --verify
```

The first command downloads to the head; `--no-launch` performs the default worker rsync. Full verification hashes both copies and is intentionally long-running.

### 5.3 Launch

First run the common drain. Then on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
./start.sh --launch
```

Do not background it. The repository reports roughly eleven minutes for weight load and initialization.

In another **FirstSpark** terminal:

```bash
docker logs -f vllm-fn
```

After health succeeds:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/health -H "Authorization: Bearer $api_key"
curl -fsS http://127.0.0.1:8100/v1/models -H "Authorization: Bearer $api_key" | python3 -m json.tool
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen3.8-flash-next","messages":[{"role":"user","content":"Reply with only 323."}],"temperature":0,"max_tokens":16}' \
  | python3 -m json.tool
unset api_key
docker logs vllm-fn 2>&1 | grep -E 'Available KV cache memory|GPU KV cache size|Free memory on device|weights'
free -h
```

Record the live per-node memory lines. Published values are a comparison target, not a substitute for this cluster's evidence.

### 5.4 Stop and restore

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
./stop.sh
spark-model use qwen35
```

## Phase 6 — Qwen official FP8 A/B, including the Aiden boundary

> [!warning] Reference summary only
> Use the FP8 section of [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]. Do not launch from this condensed block.

The same repository includes a supported official FP8 path. It is the reproducible substitute for the currently underspecified “Aiden stack” statement.

### 6.1 Download, verify, and launch FP8

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/qwen38-dual"
spark-model stop
./download.sh --fp8
./stop.sh --nfs
./start-fp8.sh --no-download --nfs
```

The served model name is `qwen3.8-flash-next-fp8`. Repeat the health, `/v1/models`, chat, tool, long-context, and memory-log checks from Phase 5 with that model name.

Capture:

```bash
docker logs vllm-fn 2>&1 | grep -E 'Available KV cache memory|GPU KV cache size|Free memory on device|weights'
free -h
```

Compare NVFP4 and FP8 on:

- exact model/checkpoint revision;
- per-node weight and non-torch memory;
- available KV bytes and tokens;
- maximum resident 262K requests;
- single-stream and four-stream output rate;
- reasoning, coding, structured tools, and vision quality;
- cold-start time and minimum `MemAvailable`.

Do not assume “FP8” is automatically smaller here. The repository explicitly reports much less KV headroom for the official FP8 checkpoint than for its NVFP4 checkpoint.

### 6.2 What is required before implementing an Aiden-specific lane

Obtain all of the following:

1. public repository or complete launcher/Compose files;
2. immutable container repository, tag, architecture, and digest;
3. exact Qwen model ID and revision;
4. vLLM fork/commit and patch list;
5. TP/EP/speculative-decoding geometry;
6. per-rank CX-7/HCA/GID configuration;
7. API authentication and bind behavior;
8. published two-node memory and validation receipts.

Without those artifacts, “Aiden stack” is a result claim, not an installable recipe. Do not substitute a DeepSeek Aiden image for Qwen.

Stop and restore:

```bash
cd "$HOME/src/frontier/qwen38-dual"
./stop.sh --nfs
spark-model use qwen35
```

---

## Phase 7 — GLM 5.3 Flash EXL3: second community recipe

> [!warning] Reference summary only
> Execute [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]]. It places stop conditions and rollback beside the risky long-prefill steps.

Only begin after Qwen has passed start, inference, stop, and rollback. The first GLM boot preserves EXL3 4 bpw, the published InstantTensor image, DFlash2 k=7, E3 grouped MoE, 850K maximum context, four sequences, and local rsync weight copies. On this pair, the tutorial's required startup corrections are GMU 0.87 and the explicit InstantTensor buffer setting; GMU 0.85 failed the 850K KV-capacity gate.

### 7.1 Configure

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
cp .env.example .env
sed -i \
  -e 's|^HEAD_IP=.*|HEAD_IP=192.168.100.10|' \
  -e 's|^WORKER_IP=.*|WORKER_IP=192.168.100.11|' \
  -e 's|^# WORKER_USER=.*|WORKER_USER=snknitin|' \
  -e 's|^WORKER_CX7_IF=.*|WORKER_CX7_IF=enp1s0f1np1|' \
  -e 's|^WORKER_CX7_IB=.*|WORKER_CX7_IB=rocep1s0f1|' \
  -e 's|^PORT=.*|PORT=8100|' \
  -e 's|^NFS_SHARE=.*|NFS_SHARE=0|' \
  -e 's|^GPU_MEM_UTIL=.*|GPU_MEM_UTIL=0.87|' \
  .env
printf '\nWORKER_SSH=snknitin@192.168.0.100\nNCCL_IB_GID_INDEX=3\nGLM53_EXTRA_ENV=INSTANTTENSOR_BUFFER_SIZE=536870912\n' >> .env
frontier_key="$(<"$HOME/.config/frontier/api-key")"
printf 'VLLM_API_KEY=%s\n' "$frontier_key" >> .env
unset frontier_key
chmod 600 .env
```

Confirm the recipe remains faithful:

```bash
grep -E '^(HEAD_IP|WORKER_IP|WORKER_USER|WORKER_SSH|HEAD_CX7_IF|WORKER_CX7_IF|HEAD_CX7_IB|WORKER_CX7_IB|NCCL_IB_GID_INDEX|MODEL|MODEL_REVISION|IMAGE|LOAD_FORMAT|PORT|NFS_SHARE|SPEC_METHOD|DFLASH_REVISION|MAX_MODEL_LEN|GPU_MEM_UTIL|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|EXL3_FAT_GROUPED|GLM53_EXTRA_ENV)=' .env
```

### 7.2 Preflight and stage

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
bash scripts/spark_doctor.sh
./download.sh
docker pull ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor
docker image inspect --format '{{index .RepoDigests 0}}' \
  ghcr.io/miaai-lab/glm-5.3-flash-2x-dgx-sparks:exl3-instanttensor
```

Record the returned digest in the acceptance record. The launcher will copy weights and synchronize the image as needed.

### 7.3 Launch and validate

Run the common drain, including stopping sparkDash. Then on **FirstSpark**:

```bash
cd "$HOME/src/frontier/glm53-dual"
SKIP_BUILD=1 ./start.sh
```

In another terminal:

```bash
cd "$HOME/src/frontier/glm53-dual"
./start.sh status
./start.sh logs
```

After health succeeds:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/health -H "Authorization: Bearer $api_key"
curl -fsS http://127.0.0.1:8100/v1/models -H "Authorization: Bearer $api_key" | python3 -m json.tool
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d '{"model":"GLM-5.3-Flash-EXL3","messages":[{"role":"user","content":"What is 17*19? Reply with the integer only."}],"max_tokens":32,"temperature":0}' \
  | python3 -m json.tool
unset api_key
docker logs glm53-exl3-head 2>&1 | grep -E 'Available KV|GPU KV cache size|MemAvailable|DFlash|InstantTensor|error' | tail -n 100
free -h
```

Do not lower context or switch speculation before this corrected baseline has either passed or produced a reproducible failure. The completed local baseline measured 18.685 quality tok/s, 23.826 C1, 47.510 aggregate C4, and passed a 790,022-token prompt; those ordinary prose/end-to-end figures are not comparable to the recipe's high-acceptance structured headline. For MTP/850K and DFlash/500K adaptations, API-key-safe configuration storage, unique result profiles, full retest commands, comparison generation, and FAQs, execute Step 16 of [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]]. Do not use the old one-line `SPEC_METHOD=mtp ./start.sh restart` shortcut while `spark-fast` is resident.

Stop and restore:

```bash
cd "$HOME/src/frontier/glm53-dual"
./start.sh stop
spark-model use qwen35
```

---

## Phase 8 — DeepSeek V4.1 Flash EXL3: final community recipe

> [!danger] Reference summary only
> Execute [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]]. Do not launch this tight-memory lane from the abbreviated commands below.

This recipe is last because it has the largest download, the narrowest runtime memory margin, and documented historical node-wedge behavior. Preserve the shipped 600K/two-sequence/2.5 GiB KV/DSpark-k3/NFS profile as the recipe-faithful baseline. The individual tutorial recommends a separately named 131K/one-sequence/1 GiB-KV safety boot before attempting that baseline; restore the untouched 600K file before recording the faithful result.

### 8.1 Configure

Run on **FirstSpark**:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
cp .env.example .env
sed -i \
  -e 's|^HEAD_IP=.*|HEAD_IP=192.168.100.10|' \
  -e 's|^WORKER_IP=.*|WORKER_IP=192.168.100.11|' \
  -e 's|^WORKER_USER=.*|WORKER_USER=snknitin|' \
  -e 's|^WORKER_CX7_IF=.*|WORKER_CX7_IF=enp1s0f1np1|' \
  -e 's|^WORKER_CX7_IB=.*|WORKER_CX7_IB=rocep1s0f1|' \
  -e 's|^PORT=.*|PORT=8100|' \
  -e 's|^NCCL_IB_GID_INDEX=.*|NCCL_IB_GID_INDEX=3|' \
  .env
printf '\nWORKER_SSH=snknitin@192.168.0.100\n' >> .env
frontier_key="$(<"$HOME/.config/frontier/api-key")"
printf '\nVLLM_API_KEY=%s\n' "$frontier_key" >> .env
unset frontier_key
chmod 600 .env
```

Confirm the recipe-critical settings:

```bash
grep -E '^(HEAD_IP|WORKER_IP|WORKER_USER|WORKER_SSH|HEAD_CX7_IF|WORKER_CX7_IF|HEAD_CX7_IB|WORKER_CX7_IB|NCCL_IB_GID_INDEX|HF_MODEL_REPO|HF_ENGRAM_REPO|WEIGHT_SYNC|NFS_SHARE|IMAGE|PORT|SPEC_METHOD|DSPARK_TOKENS|MAX_MODEL_LEN|MAX_NUM_SEQS|MAX_NUM_BATCHED_TOKENS|GPU_MEM_UTIL|KV_CACHE_MEMORY_BYTES|LANGUAGE_MODEL_ONLY)=' .env
```

Expected first-boot values include `WEIGHT_SYNC=nfs`, `NFS_SHARE=1`, `SPEC_METHOD=dspark`, `DSPARK_TOKENS=3`, 600K, two sequences, and a 2.5 GiB KV pool.

### 8.2 Stage the 387 GiB source set

Run visibly on **FirstSpark**:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
df -h "$HOME"
./download.sh
```

This downloads about 197 GiB of EXL3 weights plus the two approximately 95 GiB native Engram shards. It is resumable. Do not run a large Hugging Face upload, indexer, or unrelated build at the same time.

### 8.3 Launch and validate

Run the common drain and stop sparkDash. Confirm both nodes are otherwise idle. Then on **FirstSpark**:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
SKIP_BUILD=1 ./start.sh
```

In another terminal:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
./start.sh status
./start.sh logs
```

After health succeeds:

```bash
api_key="$(<"$HOME/.config/frontier/api-key")"
curl -fsS http://127.0.0.1:8100/health -H "Authorization: Bearer $api_key"
curl -fsS http://127.0.0.1:8100/v1/models -H "Authorization: Bearer $api_key" | python3 -m json.tool
curl -fsS http://127.0.0.1:8100/v1/chat/completions \
  -H "Authorization: Bearer $api_key" \
  -H 'Content-Type: application/json' \
  -d '{"model":"DeepSeek-v4.1-Flash-EXL3","messages":[{"role":"user","content":"What is 17*19? Reply with the integer only."}],"max_tokens":32,"temperature":0,"chat_template_kwargs":{"enable_thinking":false}}' \
  | python3 -m json.tool
unset api_key
free -h
```

The smoke test is not the memory test. Before promotion, run the repository's own test surface and a staged context ladder while watching both nodes:

1. short chat and deterministic arithmetic;
2. structured tool call;
3. image request;
4. 32K context;
5. 128K context;
6. 256K context;
7. near-600K only after every lower step preserves safe `MemAvailable`.

Do not enable cooperative MoE, abliterated overlays, Engram packing, ZFS replication, or memory guard during the baseline. Each is a separate experiment.

Stop and restore:

```bash
cd "$HOME/src/frontier/deepseek41-dual"
./start.sh stop
spark-model use qwen35
```

---

## Phase 9 — Acceptance gate for every model

A recipe is **installed** when its repository, image, and weights are staged. It is **validated** only when all applicable rows pass.

| Gate | Required evidence |
|---|---|
| Provenance | Repository commit, image digest, model ID/revision, license notes |
| Clean start | Both ranks start from an idle cluster without manual container surgery |
| Raw health | `/health` and `/v1/models` return through authenticated port `8100` |
| Chat | Deterministic short answer succeeds |
| Reasoning | Fixed reasoning set completes without malformed output |
| Coding | Same repair/generation prompts used for `spark-fast` |
| Tools | Structured tool call and actual Hermes tool execution |
| Multimodal | Image path passes when the recipe claims vision |
| Context | 32K, 128K, 256K, then advertised near-limit ladder |
| Concurrency | One, two, and four streams only when the recipe's `MAX_NUM_SEQS` supports them |
| Memory | Startup allocation, KV bytes/tokens, post-warm-up `MemAvailable`, and long-prefill low-water on both nodes |
| Logs | No rank loss, NCCL timeout, CUDA OOM, `NV_ERR_NO_MEMORY`, or silent fallback |
| Stop | Repository stop command removes both ranks cleanly |
| Rollback | `spark-model use qwen35` returns `spark-fast` to service |
| Router | Direct LiteLLM call passes after raw API; then Hermes chat and tool calls pass |

Use this minimal acceptance record for each profile:

```text
Profile:
Date:
Repo commit:
Image digest:
Model ID/revision:
Recipe deviations:
Head/worker startup memory:
Head/worker long-prefill low-water:
KV bytes/tokens:
Chat/tools/vision/context/concurrency:
Start time:
Stop result:
Rollback result:
Decision: promote | adapt and retest | reject
```

## Phase 10 — Register every validated lane in LiteLLM and Hermes

The goal is the same user experience as `spark-fast`, `qwen27-dflash`, and `nemotron3-omni`: all installed models have persistent names in LiteLLM/Hermes, but only the selected large backend is resident.

Use these distinct aliases:

| Lane command | LiteLLM/Hermes alias | Upstream served model |
|---|---|---|
| `qwen38-nvfp4` | `qwen38-nvfp4` | `qwen3.8-flash-next` |
| `qwen38-fp8` | `qwen38-fp8` | `qwen3.8-flash-next-fp8` |
| `glm53-flash` | `glm53-flash` | `GLM-5.3-Flash-EXL3` |
| `deepseek41-flash` | `deepseek41-flash` | `DeepSeek-v4.1-Flash-EXL3` |

All four routes point to `http://192.168.0.101:8100/v1` and use the protected `SPARK_FRONTIER_API_KEY`. They remain present in `/v1/models` and Hermes discovery even while cold. A cold alias is intentionally unavailable until its matching hot-swap command completes; LiteLLM does not launch 200–400 GiB models on an incoming request.

Register a lane only after:

1. its raw API, context, memory, stop, and rollback gates pass;
2. LiteLLM-only coexistence passes the same load;
3. Hermes coexistence passes the same load;
4. the measured low-water is recorded in that lane's acceptance record.

The exact backup, secret injection, four LiteLLM entries, Hermes discovery, and cluster-aware switch installation are in [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]. Do not overwrite `spark-fast` or reuse one mutable alias as the only way to find the models.

## Phase 11 — How to hot-swap safely

### From `spark-fast` to a frontier recipe

```bash
spark-frontier use qwen38-nvfp4
# or: qwen38-fp8 | glm53-flash | deepseek41-flash
spark-frontier status
```

The manager drains the current lane, starts the selected recipe, verifies the raw upstream identity, starts only LiteLLM/Hermes, and selects the matching Hermes default. The permanent alias definitions do not change during a switch.

### From one frontier recipe to another

1. Run `spark-frontier use <named-lane>`.
2. Confirm the previous head and worker ranks disappeared.
3. Confirm the new raw `/v1/models` identity.
4. Test the matching LiteLLM alias and Hermes default.
5. Confirm memory low-water remains inside the lane's accepted service-on envelope.

Never start the next recipe merely because the previous head API stopped; the worker rank may still be alive.

### From a frontier recipe back to `spark-fast`

```bash
spark-frontier restore-spark-fast
```

There is no need to delete frontier weights or images. See [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] for installation, cold-route behavior, recovery, and the manual repository commands used before manager promotion.

## Adaptation policy after the faithful baseline

Adapt only one variable at a time and keep a separate acceptance record.

Recommended order:

1. lower context or concurrency for safer headroom;
2. compare speculative method on/off or documented fallback;
3. compare NVFP4 versus official FP8 for Qwen;
4. re-enable sparkDash and measure the memory delta;
5. register every accepted named alias and validate cold-route failure behavior;
6. install the separate cluster-aware `spark-frontier` manager without changing `spark-model`;
7. consider experimental overlays only after the stock recipe remains stable.

Do not combine an image from one repository, patches from another, and launch flags from a third and still call it the community-verified recipe. That becomes a new local profile and must be qualified from zero.

## Immediate stop conditions

- either node loses SSH or the desktop becomes unresponsive;
- `NV_ERR_NO_MEMORY`, CUDA OOM, rank death, or repeated NCCL timeout appears;
- the worker continues after the head has failed;
- context output corrupts or loops at a length that short prompts pass;
- a launcher rebuilds unexpectedly instead of using the reviewed image;
- a model ID, revision, image tag/digest, or license differs from the acceptance record;
- the start requires disabling the idle-GPU or network preflight;
- LiteLLM/Hermes integration is attempted before direct API proof.

## Primary sources

- [MiaAI-Lab sparkDash](https://github.com/MiaAI-Lab/sparkDash)
- [MiaAI-Lab Qwen3.8 Flash Next Dual DGX Sparks](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks)
- [MiaAI-Lab GLM 5.3 Flash EXL3 2x DGX Sparks](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks)
- [MiaAI-Lab DeepSeek V4.1 Flash EXL3 2x DGX Sparks](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks)
- [NVIDIA NCCL for Multiple Sparks](https://build.nvidia.com/spark/nccl/stacked-sparks)
- [NVIDIA vLLM Multi-Node Serving](https://build.nvidia.com/spark/vllm/multi-node)

## Related notes

- [[Local Setup Index]]
- [[Task Checklist]]
- [[DGX Spark Dual-Node Frontier Model Recipes Research 2026-09-18]]
- [[DGX Spark Dual-Node Configuration And Operations Reference]]
- [[DGX Spark Model Installation And Switching Guide]]
- [[DGX Spark Qwen NVFP4 Memory And Startup Optimization Research]]
