# DGX Spark Dual-Node Frontier Model Recipes — Research Dossier

> [!danger] Research only — do not execute from this note
> This is the source, issue, license, and capacity evidence behind the tutorials. Its command blocks preserve upstream examples and are **not** the local execution path. Port `8888`, placeholder GIDs, and other upstream values in this dossier are intentionally not the values to paste into this cluster. Start with [[DGX Spark Dual-Node Community Frontier Models Runbook]], clear its readiness gate, and then follow the linked sparkDash/Qwen/GLM/DeepSeek tutorials, which use the correct local port `8100`, exact host labels, pass conditions, and rollback steps.

> Status: source audit completed 2026-09-18. Nothing in this dossier has been run on FirstSpark or SecondSpark.

## Executive decision

The repositories and model releases named in this investigation are real. The safest implementation order for this pair is:

1. Clear the readiness gate in [[DGX Spark Dual-Node Community Frontier Models Runbook]].
2. Install **sparkDash** as a loopback-only observer; do not let it own the model lifecycle.
3. Bring up **Qwen3.8 Flash Next NVFP4** exactly as the MiaAI-Lab dual-Spark recipe ships, changing only this pair's topology. It has the broadest GB10-specific evidence in the four repositories.
4. Test **official Qwen3.8 Flash Next FP8** as a separate checkpoint in the same Qwen lane. This is the closest reproducible public match to “qwen3.8 flash next fp8 using Aiden stack,” but it is **not** evidence that Aiden's unpublished setup was reproduced.
5. Try **GLM-5.3 Flash EXL3** only as an experimental lane with watchdog/soak testing. Current open issues include hard resets, a sustained-load host lockup, cache failures, and a long-generation CUDA failure.
6. Defer **DeepSeek-v4.1 Flash EXL3** until its first-boot/download and optional cooperative-MoE artifact issues are resolved. It has the thinnest operating margin and newest codebase.

Do not replace the existing `spark-fast` route during evaluation. The three upstream model recipes default to raw port `8888`, but that port belongs to SearXNG on this cluster; the execution tutorials therefore use `8100`. Treat the models as one mutually exclusive **dual-frontier lane** and add a LiteLLM/Hermes alias only after the raw endpoint passes the acceptance tests.

## What was verified

| Item | Exact source reviewed | Existence / maturity on 2026-09-18 | Decision |
|---|---|---|---|
| sparkDash | [`e448d6b`](https://github.com/MiaAI-Lab/sparkDash/commit/e448d6b940fefa1762aca25200273484170d4b6c) | Public, MIT, v1.8.6 package; no normal GitHub release | Install loopback-only |
| GLM recipe | [`ca85576`](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/commit/ca8557665bffa6529758f2c330ba8fb44c1e801a) | Public, AGPL-3.0; one cooperative-MoE binary release, not an application release | Experimental after Qwen |
| DeepSeek recipe | [`8404ac7`](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks/commit/8404ac7d389c418300d0bee960d52313247930e1) | Public, AGPL-3.0; created 2026-09-13; no releases | Defer / last |
| Qwen recipe | [`d2f54b7`](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks/commit/d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22) | Public, AGPL-3.0; no releases | First model recipe |
| GLM source model | [`zai-org/GLM-5.3-Flash`](https://huggingface.co/zai-org/GLM-5.3-Flash) | Exists, approximately 306 GiB, MIT model card | Upstream exists |
| GLM EXL3 checkpoint | [`Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw`](https://huggingface.co/Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw) | Exists, approximately 164 GiB, ShapleyMCG License 1.0 | Recipe input exists |
| DFlash2 drafter | [`incoai/GLM-5.3-Flash-DFlash2`](https://huggingface.co/incoai/GLM-5.3-Flash-DFlash2) | Exists, approximately 2.2 GiB, CC BY-NC-ND 4.0 | License-sensitive optional component |
| DeepSeek source model | [`deepseek-ai/DeepSeek-V4.1-Flash`](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash) | Exists, approximately 475 GiB, MIT model card | Upstream exists |
| DeepSeek EXL3 checkpoint | [`Mia-AiLab/DeepSeek-V4.1-Flash-EXL3-2.9bpw`](https://huggingface.co/Mia-AiLab/DeepSeek-V4.1-Flash-EXL3-2.9bpw) | Exists, approximately 196 GiB, MIT model card | Recipe input exists |
| Qwen NVFP4 checkpoint | [`nvidia/Qwen3.8-Flash-Next-NVFP4`](https://huggingface.co/nvidia/Qwen3.8-Flash-Next-NVFP4) | Exists, approximately 124 GiB, NVIDIA Open Model License | Default recipe input exists |
| Qwen official FP8 | [`Qwen/Qwen3.8-Flash-Next-FP8`](https://huggingface.co/Qwen/Qwen3.8-Flash-Next-FP8) | Exists, approximately 173 GiB, Qwen Community License 1.0 | Optional recipe path exists |
| Official Qwen architecture | [`QwenLM/Qwen3.8-Flash-Next`](https://github.com/QwenLM/Qwen3.8-Flash-Next) | 125B main + 51B n-gram + 4B MTP, 6B active; native 262,144 context | Confirms model identity |
| Official vLLM FP8 recipe | [`recipes.vllm.ai`](https://recipes.vllm.ai/Qwen/Qwen3.8-Flash-Next-FP8) | Dedicated `vllm/vllm-openai:qwen38-flash-next` image; TP2 validated on GB300, not GB10 | Upstream corroboration, not Spark proof |

The GitHub repositories were reviewed at the immutable commits above. Pin those commits for the first boot; later `git pull` changes the experiment.

## The local pair this runbook targets

The topology below comes from [[DGX Spark Dual-Node Configuration And Operations Reference]] and must remain the source of truth:

| Role | Host | Management | Selected first-boot CX7 rail | Interface | RoCE HCA |
|---|---|---:|---:|---|---|
| Head | FirstSpark / `spark-07a8` | `192.168.0.101` | `192.168.100.10` | `enp1s0f1np1` | `rocep1s0f1` |
| Worker | SecondSpark / `spark-7047` | `192.168.0.100` | `192.168.100.11` | `enp1s0f1np1` | `rocep1s0f1` |

The second rail (`192.168.101.10 ↔ 192.168.101.11`, `enP2p1s0f1np1`, `roceP2p1s0f1`) already passed NCCL, but these community launchers are easiest to reproduce on one rail first. Multi-rail is a later optimization.

Known local blockers to clear before a model start:

- FirstSpark → SecondSpark non-interactive SSH must work. GLM and DeepSeek have a separate `WORKER_SSH`, so they can use `snknitin@192.168.0.100` for control while `WORKER_IP=192.168.100.11` carries distributed traffic. Qwen SSHes `WORKER_IP` directly, so **Qwen additionally requires SSH over `192.168.100.11`** unless its launcher is reviewed and patched.
- Determine the actual non-zero RoCEv2 GID index on **both** selected HCAs. Do not assume the sample value `3`.
- SecondSpark must permit `snknitin` to use Docker non-interactively, or every remote Docker action in these launchers will fail. Fix group membership rather than adding `sudo` into vendor scripts.
- Both GPUs must be idle. Stop the current vLLM and LM Studio model processes before a dual-node launch; keep Hermes/LiteLLM itself available if it has no route to the new model yet.
- Confirm free disk before downloading. Node-local copies need the full checkpoint on both nodes; NFS saves worker disk but makes FirstSpark's storage path part of every cold load.

## Phase 0 — common preflight

Run these on **FirstSpark**. They do not change state.

```bash
ssh FirstSpark

ip -br -4 addr show enp1s0f1np1
ssh -o BatchMode=yes -o ConnectTimeout=10 snknitin@192.168.0.100 'hostname; echo MANAGEMENT_SSH_OK'
ssh -o BatchMode=yes -o ConnectTimeout=10 snknitin@192.168.100.11 \
  'hostname; ip -br -4 addr show enp1s0f1np1; docker info >/dev/null && echo CX7_SSH_AND_DOCKER_OK'

for host in localhost snknitin@192.168.100.11; do
  if [ "$host" = localhost ]; then
    sh -c 'hostname; nvidia-smi; df -h "$HOME"; docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  else
    ssh "$host" 'hostname; nvidia-smi; df -h "$HOME"; docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  fi
done

for host in localhost snknitin@192.168.100.11; do
  if [ "$host" = localhost ]; then
    sh -c 'dev=rocep1s0f1; for f in /sys/class/infiniband/$dev/ports/1/gids/*; do printf "%s " "${f##*/}"; cat "$f"; done'
  else
    ssh "$host" 'dev=rocep1s0f1; for f in /sys/class/infiniband/$dev/ports/1/gids/*; do printf "%s " "${f##*/}"; cat "$f"; done'
  fi
done

ss -ltnp | grep -E ':(5555|8888)\b' || true
```

Select the GID index whose entry contains the node's own `192.168.100.x` address (often displayed as an IPv4-mapped IPv6 value). If the good indices differ, GLM and DeepSeek support `HEAD_GID`/`WORKER_GID`; the Qwen script has one shared `IB_GID_INDEX`, so first choose an index populated on both nodes or stop and patch/review the launcher.

Before a dual model launch, intentionally drain current GPU services:

```bash
docker stop vllm-spark-fast
systemctl --user stop lmstudio.service

nvidia-smi
ssh snknitin@192.168.100.11 nvidia-smi
```

Rollback to the current production lane is intentionally simple:

```bash
# Run the selected recipe's ./stop.sh first.
docker start vllm-spark-fast
systemctl --user start lmstudio.service
```

Use the existing `spark-model` workflow from [[DGX Spark Model Installation And Switching Guide]] when this dual-node lane is eventually integrated; do not improvise a second lifecycle authority.

## Phase 1 — sparkDash, observation only

### Security decision

The current compose stack is powerful: ARM64 container, host networking, host PID namespace, privileged mode, and read-only mounts of `/`, `/proc`, and `/sys`. It can also receive a read-only SSH private key for remote monitoring. Treat it as an administrator console.

More importantly, current code and documentation disagree. The docs describe fail-closed remote binding, but [`.env.example`](https://github.com/MiaAI-Lab/sparkDash/blob/e448d6b940fefa1762aca25200273484170d4b6c/.env.example) and the compose path default `SPARKDASH_ALLOW_OPEN_REMOTE=1`; [`server/auth.js`](https://github.com/MiaAI-Lab/sparkDash/blob/e448d6b940fefa1762aca25200273484170d4b6c/server/auth.js) allows tokenless requests in that mode. Therefore:

- keep `BIND_HOST=127.0.0.1`;
- reach it through an SSH tunnel;
- do not publish `5555` on the LAN/Tailscale until a separately authenticated reverse proxy and access policy have been designed;
- do not enable shutdown/control actions during the first installation.

### Install and verify on FirstSpark

```bash
mkdir -p "$HOME/services"
cd "$HOME/services"
git clone https://github.com/MiaAI-Lab/sparkDash.git
cd sparkDash
git checkout --detach e448d6b940fefa1762aca25200273484170d4b6c

cp .env.example .env
chmod 600 .env
sed -i 's/^BIND_HOST=.*/BIND_HOST=127.0.0.1/' .env

docker compose up --build -d
docker compose ps
curl --fail --silent http://127.0.0.1:5555/ >/dev/null && echo SPARKDASH_OK
```

From Windows, keep the tunnel open:

```powershell
ssh -N -L 5555:127.0.0.1:5555 FirstSpark
```

Open `http://127.0.0.1:5555`, add FirstSpark as “this host,” then add SecondSpark via SSH. If an SSH key is mounted into the container, use a dedicated restricted key, mode `0600`, not the general-purpose primary key. Back up sparkDash's `.secrets-key`; stored SSH passwords are AES-256-GCM encrypted with it.

Useful current caveats: [#73](https://github.com/MiaAI-Lab/sparkDash/issues/73) reports approximately 311,000 short-lived SSH logins per remote node/day, [#88](https://github.com/MiaAI-Lab/sparkDash/issues/88) reports Node 22 benchmark failures, [#90](https://github.com/MiaAI-Lab/sparkDash/issues/90) reports Docker shutdown-control failures, and [#105](https://github.com/MiaAI-Lab/sparkDash/issues/105) reports zero token-rate readings for CRLF SSE servers. Monitoring is useful; lifecycle automation is not ready to become authoritative here.

Stop/update:

```bash
cd "$HOME/services/sparkDash"
docker compose down

# Update only after reviewing upstream changes and repinning a new commit.
git status --short
git fetch origin
```

## Phase 2 — Qwen3.8 Flash Next dual-Spark lane

### 2A. Pin and configure the default NVFP4 recipe

This is the recipe-faithful first boot. Copy the sample, change only topology, and preserve the checked-in performance defaults: native 262,144 context, YaRN off, TP2, expert parallel on, MTP3, FP8 KV cache, `MAX_NUM_SEQS=8`, and port `8888`. The README's environment table still mentions 1M/YaRN defaults in places; [the actual `.env.sample`](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks/blob/d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22/.env.sample) and launcher are the executable truth.

```bash
mkdir -p "$HOME/services"
cd "$HOME/services"
git clone https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks.git
cd Qwen3.8-Flash-Next-Dual-DGX-Sparks
git checkout --detach d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22

cp .env.sample .env
chmod 600 .env
```

Edit only these values for the first run:

```dotenv
HEAD_IP="192.168.100.10"
WORKER_IP="192.168.100.11"
WORKER_USER="snknitin"
IFACE="enp1s0f1np1"
WORKER_IFACE="enp1s0f1np1"
IB_HCA="=rocep1s0f1"
WORKER_IB_HCA="=rocep1s0f1"
IB_GID_INDEX=<verified-common-index>
PORT=8888
```

Do not change the model, context, cache, speculation, or memory settings until this baseline passes. Do not select the gated “abliterated” checkpoint for the baseline.

```bash
./download.sh
./check-weights.sh --verify
./start.sh --no-download
```

Default distribution is `rsync`, so each node keeps a local copy. That is the most reproducible first boot if both nodes have at least roughly 150 GiB free beyond normal headroom. If worker disk is insufficient, explicitly use `./start.sh --no-download --nfs`; the trade-off is a head-hosted NFS dependency.

The script hardcodes `StrictHostKeyChecking=no`. That weakens host identity protection. Before the first run, manually verify and pin the worker host key in `~/.ssh/known_hosts`; a later local wrapper/patch should remove that option, but changing vendor code is outside the recipe-faithful first boot.

### 2B. Raw endpoint verification

```bash
curl --fail --silent http://127.0.0.1:8888/v1/models | jq .

curl --fail --silent http://127.0.0.1:8888/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"qwen3.8-flash-next",
    "messages":[{"role":"user","content":"Return only the number: 17 * 19"}],
    "temperature":0,
    "max_tokens":32
  }' | jq .

./check-weights.sh --verify
docker logs --tail 200 vllm-fn
ssh snknitin@192.168.100.11 'docker logs --tail 200 vllm-fn'
```

Acceptance gate before LiteLLM: `/v1/models` correct; simple answer `323`; tool call JSON accepted by the intended client; image input works; 32K and 128K prefill tests complete; 24-hour mixed agentic soak has no rank loss, CUDA error, host lockup, or growing page cache; stop and restart succeeds twice.

Known issue [#46](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks/issues/46) reports top-k/top-p failure after about 31 hours, so the soak must exceed 31 hours before calling this production-ready. [#64](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks/issues/64) reports a dead `huggingface-cli` stub taking precedence over `hf`; the pinned script currently still checks `huggingface-cli` before `hf`. If download fails for that exact reason, remove/rename the dead stub or run `uvx hf download nvidia/Qwen3.8-Flash-Next-NVFP4 --cache-dir "$HOME/.cache/huggingface/hub"`, then rerun `./check-weights.sh --verify`—do not delete a partial cache blindly.

### 2C. Official FP8 checkpoint

Stop NVFP4 first because both paths use container name `vllm-fn` and port `8888`.

```bash
./stop.sh
./download.sh --fp8
./start-fp8.sh --no-download --nfs
```

Why `--nfs` is explicit: [`start-fp8.sh`](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks/blob/d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22/start-fp8.sh) says FP8 weights stay on the head and are NFS-exported, but the wrapper does not actually force `NFS_SHARE=true`; it delegates to `start.sh`, while `.env.sample` defaults to `false`. The explicit flag makes execution match the documented FP8 topology. If node-local copies are preferred and disk permits, use `--no-nfs` deliberately and record that deviation.

Verify with model name `qwen3.8-flash-next-fp8`. The wrapper forces native 262,144 context, YaRN off, and skips the NVFP4 PLE patch. The repository estimates around 500K available KV tokens on two Sparks. Open [#50](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks/issues/50) and [#55](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks/issues/55) show that FP8 proposal-head and node-local PLE-offload work are still experimental.

The official vLLM recipe corroborates the image/checkpoint combination but validates TP2 on GB300, not GB10, and documents at least 51 GiB plus headroom for CPU PLE offload. Do not treat that upstream recipe as a second independent DGX Spark validation.

### 2D. What “Aiden stack” does and does not establish

The exact phrase comes from a single NVIDIA forum reply: “i’m running qwen3.8 flash next fp8 using aiden stack.” See the [dual-Spark GLM/DeepSeek discussion](https://forums.developer.nvidia.com/t/so-for-dual-spark-what-is-the-choice-now-glm5-3-flash-or-deepseek-v4-flash/382628). The reply provides no repository, image tag, launch command, configuration, or benchmark.

The current [Aiden recipes index](https://aidenle.com/recipes/) lists 4×-Spark DeepSeek and GLM recipes, not a public Qwen3.8 FP8 dual-Spark recipe. The public `aidendle94/sparkrun-vllm-ds4-gb10` image naming is DeepSeek-specific, and no public Aiden Qwen recipe was found. Therefore:

- the anecdote supports **possibility**, not reproducibility;
- “Aiden stack” is not an installable, versioned Qwen recipe in the evidence reviewed;
- do not pull an unrelated DeepSeek image and infer that it is the Qwen stack;
- the MiaAI-Lab official-FP8 path above is the documented public implementation candidate.

This absence is narrow, not a claim that no other public dual-Spark Qwen FP8 recipe exists. Two independent non-Aiden alternatives were reviewed: [0rand/qwen3.8-flash-next-2x-dgx-sparks](https://github.com/0rand/qwen3.8-flash-next-2x-dgx-sparks) at `15a2488e3ec7593ddfbb062523200627bb8f4d6b`, and [tsarihan/qwen3.8-flash-next-fp8-2x-dgx-spark-playbook](https://github.com/tsarihan/qwen3.8-flash-next-fp8-2x-dgx-spark-playbook) at `640714535dc132f1ce90c10efe796e1083c42b23`. They use different KV, parser, context, and launch choices; treat them as independent corroboration and do not merge their settings into the pinned Mia profile.

If the original poster publishes a commit/image/config, add it as a separate recipe and compare it against this baseline; do not silently merge its settings.

## Phase 3 — GLM-5.3 Flash EXL3 trial

The recipe serves `GLM-5.3-Flash-EXL3` on `:8888`, TP2, with a 4 bpw EXL3 checkpoint and DFlash2 by default. It downloads about 164 GiB of main weights plus the small drafter. The default is a node-local worker copy (`NFS_SHARE=0`).

```bash
cd "$HOME/services"
git clone https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks.git
cd GLM-5.3-Flash-EXL3-2x-DGX-Sparks
git checkout --detach ca8557665bffa6529758f2c330ba8fb44c1e801a

cp .env.example .env
chmod 600 .env
```

For the recipe-faithful baseline, change only:

```dotenv
HEAD_IP=192.168.100.10
WORKER_IP=192.168.100.11
WORKER_USER=snknitin
WORKER_SSH=snknitin@192.168.0.100
HEAD_CX7_IF=enp1s0f1np1
WORKER_CX7_IF=enp1s0f1np1
HEAD_CX7_IB=rocep1s0f1
WORKER_CX7_IB=rocep1s0f1
HEAD_GID=<verified-head-index>
WORKER_GID=<verified-worker-index>
PORT=8888
VLLM_API_KEY=<new-long-random-secret>
```

Keep the pinned defaults for the first attempt: `MAX_MODEL_LEN=850000`, `GPU_MEM_UTIL=0.85`, `MAX_NUM_SEQS=4`, `MAX_NUM_BATCHED_TOKENS=7168`, `KV_CACHE_DTYPE=fp8`, `SPEC_METHOD=dflash`, and `NFS_SHARE=0`. This is deliberately faithful even though current [#204](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/issues/204) says the InstantTensor loader can make this exact memory profile fail to boot. A faithful failure is actionable evidence; do not pre-tune and then wonder which variable mattered.

```bash
./start.sh download
./start.sh
./start.sh status
./start.sh logs
./start.sh logs worker
```

Authenticated verification:

```bash
export GLM_API_KEY='<same secret>'
curl --fail --silent http://127.0.0.1:8888/v1/models \
  -H "Authorization: Bearer $GLM_API_KEY" | jq .
```

Stop:

```bash
./start.sh stop
# or ./stop.sh
```

Only after recording the baseline result may a tuning run change one dimension at a time. The repository discusses lower-context/conservative profiles; start by reducing context, not by stacking context, GMU, cache, and speculation changes together.

Do not overlook current risks: agentic repetition [#78](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/issues/78), prefix-cache failure [#106](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/issues/106), long-form corruption on rebuilt images [#121](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/issues/121), worker hard reset [#152](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/issues/152), host lockup [#193](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/issues/193), page-cache/preflight blind spot [#205](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/issues/205), and a DFlash2 CUDA failure after 21,637 computed tokens [#214](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/issues/214).

License boundary: repository code is AGPL-3.0; the EXL3 weights use ShapleyMCG License 1.0; the default DFlash2 drafter is CC BY-NC-ND 4.0. The latter is a non-commercial/no-derivatives license and deserves legal review before any business-facing service. A later `SPEC_METHOD=mtp` experiment can remove the DFlash2 component, but it is not the faithful baseline.

## Phase 4 — DeepSeek-v4.1 Flash EXL3 trial

This recipe is extremely tight on a 128 GiB unified-memory node. Its own accounting leaves roughly 4 GiB after warm-up and about 2.1 GiB after a 601K prefill. The head stages about 196 GiB of EXL3 weights plus approximately 190 GiB of the two native Engram shards, so budget about 387 GiB before temporary/cache headroom. Default NFS avoids duplicating that entire tree on the worker.

Do not start this phase until Qwen and GLM can start/stop cleanly and a recovery window is available.

```bash
cd "$HOME/services"
git clone https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks.git
cd DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks
git checkout --detach 8404ac7d389c418300d0bee960d52313247930e1

cp .env.example .env
chmod 600 .env
```

Change only:

```dotenv
HEAD_IP=192.168.100.10
WORKER_IP=192.168.100.11
WORKER_USER=snknitin
WORKER_SSH=snknitin@192.168.0.100
HEAD_CX7_IF=enp1s0f1np1
WORKER_CX7_IF=enp1s0f1np1
HEAD_CX7_IB=rocep1s0f1
WORKER_CX7_IB=rocep1s0f1
HEAD_GID=<verified-head-index>
WORKER_GID=<verified-worker-index>
PORT=8888
VLLM_API_KEY=<new-long-random-secret>
```

Preserve first-boot defaults: `WEIGHT_SYNC=nfs`, `NFS_SHARE=1`, `MAX_MODEL_LEN=600000`, `MAX_NUM_SEQS=2`, `MAX_NUM_BATCHED_TOKENS=1536`, `GPU_MEM_UTIL=0.88`, explicit 2.5 GiB KV cache, DSpark speculation, and vision on. In particular, do not lower `MAX_NUM_BATCHED_TOKENS` below 1536 while vision is enabled; the recipe warns that the server can fail.

> [!danger] Do not launch DeepSeek from this dossier
> The upstream sequence below is retained only as audited evidence. Fresh-pair failures and the missing/unavailable optional artifacts described after it make unattended use unsafe. Use [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]], where safe bring-up, exact local values, stop conditions, and rollback come before the launch.

```bash
./start.sh
./start.sh status
./start.sh logs
./start.sh logs worker
```

Verify `/v1/models`, deterministic text (`17 * 19`), an image request, tool calling, and a long prefill. Stop with:

```bash
./start.sh stop
# or ./stop.sh
```

This phase is currently **blocked for unattended use**, even though the commands are documented. Open [#1](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks/issues/1) reports missing Engram configuration and an NFS exporter failure on a fresh pair; [#14](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks/issues/14) says `download.sh` is not working; [#17](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks/issues/17) and [#20](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks/issues/20) say the pinned optional cooperative-MoE binary is unavailable. Leave cooperative MoE disabled; do not download an unverified `.so` from comments or third-party mirrors.

## LiteLLM and Hermes integration gate

Raw vLLM should remain private. GLM and DeepSeek have a first-class `VLLM_API_KEY`; Qwen passes one through `EXTRA_VLLM_ARGS="--api-key ..."`. At the reviewed commit the generated `.last_head_launch.sh` is forced to mode `0600`, but it still contains the secret; never copy, commit, or attach that file. The execution tutorials bind the authenticated challenger on port `8100` and keep it behind the private Spark network.

Recommended internal identities:

| Checkpoint | Raw served model | Proposed LiteLLM/Hermes alias |
|---|---|---|
| Qwen NVFP4 | `qwen3.8-flash-next` | `qwen38-nvfp4` |
| Qwen FP8 | `qwen3.8-flash-next-fp8` | `qwen38-fp8` |
| GLM EXL3 | `GLM-5.3-Flash-EXL3` | `glm53-flash` |
| DeepSeek EXL3 | `DeepSeek-v4.1-Flash-EXL3` | `deepseek41-flash` |

Only one model may own port `8100` and the two GPUs at a time; upstream `8888` is intentionally not used because ODS SearXNG already owns it. Register every validated named alias, but activate only the matching backend before selecting it. Test through LiteLLM locally, then through Hermes. Preserve the existing `spark-fast` route and identity as rollback. Do not let sparkDash, a systemd unit, and `spark-model` all start/stop the lane independently. Follow [[DGX Spark Frontier Model Hot-Swap And Routing Guide]] for the final integration.

Minimum end-to-end check after routing:

```bash
curl --fail --silent http://127.0.0.1:4000/v1/models \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" | jq .

curl --fail --silent http://127.0.0.1:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"qwen38-nvfp4",
    "messages":[{"role":"user","content":"Reply with exactly ROUTE_OK"}],
    "temperature":0,
    "max_tokens":16
  }' | jq .
```

## Acceptance and rollback record

For every model, save a small run receipt containing:

- repository URL and exact commit;
- container image name **and resolved digest** from `docker image inspect`;
- HF model ID and resolved snapshot commit;
- `.env` checksum with secrets redacted;
- selected IP/interface/HCA/GID per rank;
- free disk and memory before/after load;
- cold-start time, model-list response, deterministic answer, tool call, vision, 32K/128K prefill, sustained decode, and stop/restart results;
- head and worker logs;
- the exact reason for any failure.

Immediate rollback conditions: CUDA/NCCL fatal error, rank divergence, host unresponsiveness, kernel GPU fault, sustained swap/memory pressure, corrupt output, authentication exposure, or inability to stop cleanly. Stop via the recipe first; if the head is still responsive, collect logs before rebooting. Restore `vllm-spark-fast` and LM Studio only after port `8100` and every distributed compute container are gone. Retained, known NFS helper containers are a separate storage-lifecycle decision and must never be removed underneath a running rank.

## Evidence versus unknowns

| Question | Evidence | Status |
|---|---|---|
| Do all four repositories exist? | GitHub API and immutable commits above | Verified |
| Do all named model checkpoints exist? | Hugging Face repositories above | Verified |
| Is Qwen3.8 Flash Next an actual released architecture? | Official Qwen GitHub and model pages | Verified |
| Is official FP8 supported by vLLM? | Official vLLM recipe/image | Verified upstream; not independently GB10-validated there |
| Does MiaAI-Lab provide a dual-GB10 FP8 path? | `download.sh --fp8` + `start-fp8.sh` in pinned Qwen repo | Verified in code; community validation depth is limited |
| Is an Aiden-authored or explicitly Aiden-derived Qwen stack public and reproducible? | Forum post, Aiden recipe index, public repos/images reviewed | No; the claim has no matching public artifacts. Separate non-Aiden dual-Spark FP8 recipes do exist. |
| Can management SSH and CX7 rank traffic use separate addresses? | GLM/DeepSeek expose `WORKER_SSH`; Qwen directly SSHes `WORKER_IP` | Yes for GLM/DeepSeek; Qwen needs CX7 SSH or a reviewed patch |
| Is GID index `3` correct here? | Live sysfs/driver inspection on both connected Sparks plus the existing NCCL proof | Verified for `rocep1s0f1` on this pair; recheck before each rollout |
| Can SecondSpark run Docker as `snknitin`? | Existing local operations note reports missing group access | Known blocker until reverified/fixed |
| Is one rail enough? | Existing NCCL validation and recipe single-rail defaults | Yes for faithful first boot; multi-rail is later tuning |
| Can Qwen FP8 fit and serve native 262K? | Mia recipe claim plus official checkpoint size; not run here | Plausible, requires live proof |
| Is GLM safe for unattended long-running use? | Multiple open hard-reset/lockup/corruption/CUDA issues | Not established |
| Is DeepSeek first boot reliable from a clean pair? | Open download/NFS/Engram issues | Not established |
| Are the licenses interchangeable? | Repo and model cards show AGPL, MIT, NVIDIA, Qwen, ShapleyMCG, CC BY-NC-ND | No; review each deployed combination |

## Final recommendation

Implement in two controlled windows:

1. **Window A:** clear SSH/Docker/GID blockers, install loopback-only sparkDash, pin Qwen commit, run the untouched NVFP4 baseline, and restore the current production lane.
2. **Window B:** run official FP8 with explicit NFS and compare quality/throughput/stability to NVFP4. Keep each accepted profile under its own permanent LiteLLM/Hermes alias; the comparison may select a preferred default, but it does not erase the other validated route.

GLM and DeepSeek should remain follow-on experiments, not replacements for `spark-fast`, until their open failure modes have been reproduced or cleared on this exact pair. The public evidence does not currently justify describing any of these larger lanes as production-safe merely because a first boot succeeds.

## Primary sources

- [sparkDash repository](https://github.com/MiaAI-Lab/sparkDash) and [pinned README](https://github.com/MiaAI-Lab/sparkDash/blob/e448d6b940fefa1762aca25200273484170d4b6c/README.md)
- [GLM dual-Spark repository](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks) and [pinned README](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/blob/ca8557665bffa6529758f2c330ba8fb44c1e801a/README.md)
- [DeepSeek dual-Spark repository](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks) and [pinned README](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks/blob/8404ac7d389c418300d0bee960d52313247930e1/README.md)
- [Qwen dual-Spark repository](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks) and [pinned README](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Next-Dual-DGX-Sparks/blob/d2f54b78c0d2f9d74ac61aa56200e3c40fac3f22/README.md)
- [Official Qwen3.8 Flash Next repository](https://github.com/QwenLM/Qwen3.8-Flash-Next)
- [Official vLLM Qwen3.8 Flash Next FP8 recipe](https://recipes.vllm.ai/Qwen/Qwen3.8-Flash-Next-FP8)
- [NVIDIA forum thread containing the Aiden-stack phrase](https://forums.developer.nvidia.com/t/so-for-dual-spark-what-is-the-choice-now-glm5-3-flash-or-deepseek-v4-flash/382628)
- Local authoritative context: [[DGX Spark Dual-Node Configuration And Operations Reference]], [[DGX Spark Model Installation And Switching Guide]], [[DGX Spark Multi-Model Runtime Research]], and [[Local Setup Index]]
