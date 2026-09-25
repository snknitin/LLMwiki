---
created: 2026-09-18
updated: 2026-09-24
status: active-authoritative-reference
scope: dgx-spark, dual-node, connectx-7, qsfp112, netplan, ssh, nccl, vllm, tensorrt-llm
authority: live-audit-plus-successful-nccl-run
---

# DGX Spark Dual-Node Configuration And Operations Reference

> [!important] Current authority
> This is the authoritative handoff and operations reference for the two connected DGX Sparks. It supersedes the cable-pending and NCCL-pending portions of [[DGX Spark Second Node And Dual Spark Readiness Research 2026-08-20]]. Re-check live state before a destructive network change, driver update, or distributed-model deployment.

## Executive Summary

Two DGX Sparks are directly connected with one supported QSFP112 DAC through the right-hand ConnectX-7 port. The link is persistent across reboot through a manually managed Netplan file, both logical rails negotiate at 200,000 Mb/s full duplex, both private data networks pass bidirectional ping, and the official two-node NCCL `all_gather_perf` test completed successfully.

The established result is:

```text
Out of bounds values : 0 OK
Avg bus bandwidth    : 21.7568 GB/s
Collective test concluded: all_gather_perf
```

`21.7568 GB/s × 8 = 174.0544 Gbit/s` of NCCL collective bus bandwidth. This is usable end-to-end collective bandwidth, not the physical signaling-rate test used by NVIDIA Sync Cluster Assistant.

The cable and network do **not** automatically combine the machines into one 256 GB computer. A distributed runtime such as vLLM with Ray or TensorRT-LLM with MPI must explicitly start a coordinator, start a worker, shard a compatible model with tensor parallelism, and expose an API from the primary node.

## Node Identity And Roles

| Property | FirstSpark | SecondSpark |
|---|---|---|
| Windows/NVIDIA Sync alias | `FirstSpark` | `SecondSpark` |
| Hostname | `spark-07a8` | `spark-7047` |
| User | `snknitin` | `snknitin` |
| UID/GID | `1000:1000` | `1000:1000` |
| Management IP | `192.168.0.101/24` | `192.168.0.100/24` |
| Current role | Production Hermes/LiteLLM/Qwen owner and cluster launcher | Worker/experimental compute node |
| Docker access as `snknitin` | Member of `docker` group | Not currently in `docker` group; use `sudo docker` or deliberately add membership |
| Root filesystem | 3.7 TB total, about 3.1 TB available at audit | 3.7 TB total, about 3.5 TB available at audit |

The Windows NVIDIA Sync SSH configuration is:

```text
C:\Users\Nitin Kishore Sai\AppData\Local\NVIDIA Corporation\Sync\config\ssh_config
```

Use the aliases from Windows rather than memorizing hostnames:

```powershell
ssh -F "$env:LOCALAPPDATA\NVIDIA Corporation\Sync\config\ssh_config" FirstSpark
ssh -F "$env:LOCALAPPDATA\NVIDIA Corporation\Sync\config\ssh_config" SecondSpark
```

## Software Baseline — Live Audit 2026-09-18

| Component | FirstSpark | SecondSpark | Assessment |
|---|---|---|---|
| OS | Ubuntu 24.04.4 LTS | Ubuntu 24.04.4 LTS | Matched |
| Kernel | `6.17.0-1029-nvidia` | `6.17.0-1029-nvidia` | Matched |
| GPU | NVIDIA GB10 | NVIDIA GB10 | Matched |
| Driver | `580.173.02` | `580.173.02` | Matched |
| Docker | `29.2.1` | `29.2.1` | Matched |
| NVIDIA Container Toolkit | `1.19.1` | `1.20.0` | Mismatch; reconcile before treating a distributed container runtime as production |
| NCCL source | `v2.30.7-1` | `v2.30.7-1` | Matched |
| `nccl-tests` revision | `b4d5bee` plus local build/link correction | `b4d5bee` plus local build/link correction | Matched functional build |

Do not assume firmware parity from this table; firmware was not re-read during the 2026-09-18 live audit.

> [!success] Frontier readiness update — 2026-09-24
> The later dual-Spark Frontier run reconciled Docker access, reverse SSH trust, and NVIDIA Container Toolkit parity before the distributed model tutorials were completed. The table above remains the dated 2026-09-18 audit snapshot.

## Physical Topology

- One NVIDIA-approved QSFP112 400 GbE-capable Ethernet-mode DAC connects the two Sparks.
- Each DGX Spark port is capped at 200 Gbit/s; a 400G-labelled approved cable does not make the Spark port operate at 400 Gbit/s.
- The connected physical port is the right-hand port as represented by the `f1` interfaces.
- One physical port exposes two Linux Ethernet interfaces because the ConnectX-7 has two PCIe paths to the SoC.
- The corresponding `f0` interfaces are unconnected and correctly show `Down`/`NO-CARRIER`.

```text
FirstSpark right QSFP port                         SecondSpark right QSFP port

enp1s0f1np1     192.168.100.10/24  ───────────  192.168.100.11/24     enp1s0f1np1
enP2p1s0f1np1   192.168.101.10/24  ───────────  192.168.101.11/24     enP2p1s0f1np1

Management:      192.168.0.101       LAN/SSH      192.168.0.100
```

Both active CX-7 interfaces currently report:

```text
Speed: 200000Mb/s
Duplex: Full
Auto-negotiation: on
Link detected: yes
MTU: 1500
```

The two active RoCE-to-Ethernet mappings on each node are:

```text
rocep1s0f1   port 1 ==> enp1s0f1np1   (Up)
roceP2p1s0f1 port 1 ==> enP2p1s0f1np1 (Up)
```

## Address Plan

| Network | Purpose | FirstSpark | SecondSpark |
|---|---|---:|---:|
| `192.168.0.0/24` | Management, launcher SSH, MPI bootstrap | `192.168.0.101` | `192.168.0.100` |
| `192.168.100.0/24` | CX-7 private rail 1 | `192.168.100.10` | `192.168.100.11` |
| `192.168.101.0/24` | CX-7 private rail 2 | `192.168.101.10` | `192.168.101.11` |

The management IPs are arguments to the current NCCL helper script. They are not substitutes for the private CX-7 addresses used by distributed runtimes.

## Persistent Network Ownership

The current network is manually managed by this root-owned file on both nodes:

```text
/etc/netplan/40-cx7.yaml
owner: root:root
mode: 0600
```

No NVIDIA Sync Cluster Assistant file exists:

```text
/etc/netplan/99-nvidia-sync-cluster.yaml   ABSENT
```

This distinction is intentional. Cluster Assistant would create `99-nvidia-sync-cluster.yaml`, and Netplan merges multiple YAML files in lexical order. A new `99-...` file could override the existing `40-cx7.yaml` addresses and invalidate scripts, hostfiles, and this reference.

Inspect, but do not casually edit, the live network plan:

```bash
sudo ls -l /etc/netplan/40-cx7.yaml
sudo cat /etc/netplan/40-cx7.yaml
ip -br -4 addr
ibdev2netdev
ethtool enp1s0f1np1 | grep -E 'Speed:|Duplex:|Link detected:'
ethtool enP2p1s0f1np1 | grep -E 'Speed:|Duplex:|Link detected:'
```

For any future change:

1. Back up the active file.
2. Use `sudo netplan generate` to catch syntax errors.
3. Use `sudo netplan try` from a connection that is not dependent on the CX-7 address being changed.
4. Confirm both private rails from both directions.
5. Rerun NCCL before declaring the cluster ready.

Do not add Cluster Assistant on top of the manual plan merely to get another green check. If NVIDIA Sync-managed networking is desired, treat it as an explicit migration with a rollback plan and update every recorded IP afterward.

## Connectivity And SSH State

Both CX-7 private rails passed bidirectional ICMP with zero packet loss during the 2026-09-18 audit. Observed round-trip latency was sub-millisecond to roughly 1.5 ms across the short sample.

FirstSpark can launch noninteractive SSH to SecondSpark over the management network:

```bash
ssh -o BatchMode=yes snknitin@192.168.0.100 hostname
# spark-7047
```

The reverse management-IP test currently fails with `Host key verification failed`:

```bash
# From SecondSpark:
ssh -o BatchMode=yes snknitin@192.168.0.101 hostname
```

This does not invalidate the completed NCCL run because FirstSpark is the launcher and its direction works. It is nevertheless a preflight item for runtimes that require symmetric SSH. Diagnose the exact stale/conflicting `known_hosts` entry before removing anything; do not disable host-key verification globally.

The reverse trust issue was subsequently repaired and rechecked during the completed Frontier readiness gate on 2026-09-24.

The earlier missing `~/.ssh/id_rsa.pub` error was not evidence that SSH was unconfigured. The environment uses Ed25519 material, and FirstSpark-to-SecondSpark passwordless SSH is already functional.

## NCCL Installation And Helper Scripts

On both nodes:

- NCCL tag: `v2.30.7-1`
- `nccl-tests` revision: `b4d5bee`
- Build architecture: Blackwell GB10 `sm_121`
- OpenMPI development libraries installed

The current `nccl-tests` tree needed an additional C++ MPI link dependency because `-lmpi` alone produced unresolved `MPI::Win::Free()` symbols. The functional build includes `-Xlinker -lmpi_cxx`; do not replace it with an unverified half-built tree.

The launcher files live on FirstSpark:

```text
/home/snknitin/setup.sh
SHA-256 033b2b50495b121bbf4178027ecab068f55e3d726be095645dafb5022fca7cce

/home/snknitin/launch.sh
SHA-256 a6c2e69b234f3455283f354b9f21b13cd2665d69a563e69aa2f51f49a31c00f3
```

`launch.sh` uses:

```text
Management interface: enP7s7
Default BEGIN:          16G
Default END:            16G
Default FACTOR:         2
Collective:             all_gather_perf
Topology:               direct
```

Do not rerun `setup.sh` as routine maintenance. It is an installation/build step, not the normal bandwidth-test command.

## Exact NCCL Test Procedure

### 1. Drain GPU workloads first

The 16 GiB test previously made the terminal and SSH appear hung when large inference processes were resident. Before the full test, stop FirstSpark's GPU model services:

```bash
docker stop vllm-spark-fast
systemctl --user stop lmstudio.service
```

Check both nodes:

```bash
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
pgrep -af '[a]ll_gather_perf|[m]pirun' || echo "No NCCL processes"
```

At the 2026-09-18 audit, FirstSpark's production Qwen engine was healthy and occupied approximately 40,209 MiB. It must be stopped before another full 16 GiB NCCL run. SecondSpark had no verified resident GPU process, although ordinary Docker access as `snknitin` is currently blocked by missing group membership.

### 2. Run from FirstSpark only

```bash
cd ~
BEGIN=16G END=16G FACTOR=2 \
bash launch.sh --topology direct 192.168.0.101 192.168.0.100
```

The unqualified command is equivalent because those are the script defaults:

```bash
bash launch.sh --topology direct 192.168.0.101 192.168.0.100
```

### 3. Acceptance evidence

A completed run must show all of the following:

```text
Out of bounds values : 0 OK
Avg bus bandwidth    : <measured value>
Collective test concluded: all_gather_perf
```

The established measurement is `21.7568 GB/s`, or `174.0544 Gbit/s`. NVIDIA's Cluster Assistant uses a separate direct link test with a documented 184 Gbit/s lower bound; do not compare that threshold one-for-one with NCCL `Avg bus bandwidth`.

### 4. Restore the production model

```bash
cd ~/ai/services/qwen35
docker compose --env-file .env up -d
docker logs -f vllm-spark-fast
```

Wait for `Application startup complete`, then leave log-follow mode with `Ctrl+C`. Verify:

```bash
docker inspect -f '{{.State.Health.Status}}' vllm-spark-fast
curl -sS http://127.0.0.1:8000/v1/models
```

Current Qwen details and the restored 18 GiB KV-cache/five-sequence profile are documented in [[DGX Spark Qwen NVFP4 Memory And Startup Optimization Research]].

## NVIDIA Driver/CDI Recovery Note

After the host driver changed from `580.159.03` to `580.173.02`, the old `/etc/cdi/nvidia.yaml` still referenced removed versioned libraries and prevented GPU containers from starting. The characteristic error was:

```text
failed to fulfil mount request:
open /usr/lib/aarch64-linux-gnu/libEGL_nvidia.so.580.159.03:
no such file or directory
```

The correct repair is to regenerate CDI metadata from the installed driver, not create fake library symlinks. After any future driver update, compare `nvidia-smi` with CDI references and regenerate only if stale:

```bash
nvidia-smi --query-gpu=driver_version --format=csv,noheader
grep -n 'host-driver-version' /etc/cdi/nvidia.yaml
nvidia-ctk cdi generate --output /tmp/nvidia-current.yaml
sudo cp -p /etc/cdi/nvidia.yaml /etc/cdi/nvidia.yaml.before-driver-refresh
sudo install -o root -g root -m 0644 /tmp/nvidia-current.yaml /etc/cdi/nvidia.yaml
```

Then recreate, rather than merely restart, any container whose GPU device specification was created while CDI was stale.

## Cluster Assistant Decision

NVIDIA Sync Cluster Assistant can configure ConnectX-7 networking, check 200 Gbit/s negotiation, run its own link test with a 184 Gbit/s lower bound, and create inter-device SSH. It does **not** install NCCL, Ray, vLLM, TensorRT-LLM, fine-tuning, or any distributed workload.

Current decision:

- Manual Netplan remains authoritative.
- Cluster Assistant was not used to create the active network.
- `99-nvidia-sync-cluster.yaml` is absent on both nodes.
- Do not click **Confirm Network Configuration** unless intentionally migrating ownership away from `40-cx7.yaml`.
- If migration is chosen, back up both nodes, record the Assistant-assigned IPs, update this note and all hostfiles/scripts, and rerun NCCL.

## Using Both Sparks For Large Models

### What the cable does not do

It does not automatically pool two 128 GB unified-memory systems. Each node retains its own memory, GPU, Docker daemon, model cache, and operating system. A distributed runtime divides the model and continually exchanges intermediate tensors over NCCL/RoCE.

### Option 1 — Independent nodes

Keep FirstSpark as the production Qwen/Hermes owner and use SecondSpark for an unrelated model or experiment. This is the simplest operational model and avoids distributed-runtime overhead, but a single model cannot consume memory from both machines.

### Option 2 — vLLM with Ray and tensor parallelism

NVIDIA's official two-node vLLM playbook creates a Ray head on FirstSpark, a Ray worker on SecondSpark, and launches with `--tensor-parallel-size 2`. The documented first proof is Llama 3.3 70B.

For this cluster, start with:

```text
MN_IF_NAME:       enp1s0f1np1
FirstSpark CX-7:  192.168.100.10
SecondSpark CX-7: 192.168.100.11
```

Use a separate endpoint and model alias. Do not overwrite `spark-fast` until the distributed service has independently passed health, inference, tool, context, restart, and shutdown tests.

### Option 3 — TensorRT-LLM with MPI and tensor parallelism

NVIDIA's official two-Spark TensorRT-LLM playbook documents `nvidia/Qwen3-235B-A22B-FP4`, `--tp_size 2`, and an OpenAI-compatible API on port `8355`. This is the clearest current NVIDIA path for a genuinely large Qwen model across two Sparks.

Before either distributed path:

1. Stop the single-node Qwen and any LM Studio GPU model on FirstSpark.
2. Resolve SecondSpark Docker access or use `sudo docker` consistently.
3. Reconcile NVIDIA Container Toolkit versions.
4. Repair reverse SSH host-key trust if the chosen runtime requires symmetric SSH.
5. Confirm adequate disk capacity and inode availability on both nodes.
6. Pin the exact container image, model revision, and playbook version.
7. Verify Ray/MPI reports two GPU resources before downloading or starting a large model.
8. Expose the API from FirstSpark only, test it directly, then add a new LiteLLM/Hermes alias.

## Known Open Items

- [x] Diagnose and repair SecondSpark-to-FirstSpark management-IP host-key verification without disabling strict checking globally.
- [x] Add `snknitin` to SecondSpark's `docker` group and prove normal Docker access without `sudo`.
- [x] Reconcile NVIDIA Container Toolkit `1.19.1` versus `1.20.0` before the first distributed container workload.
- [ ] Re-read and record firmware versions on both nodes.
- [ ] Prove one NVIDIA-documented two-node workload end to end.
- [x] Close the original either/or decision: the first real distributed-model proof used the pinned dual-Spark Qwen 3.8 NVFP4/FP8 Frontier recipe instead; the NVIDIA-documented workload remains a separate optional item above.
- [ ] Keep Cluster Assistant migration optional; it is not a prerequisite for the already working manual network.
- [ ] Treat MTU 1500 as the current fact. Do not assume jumbo frames or NemoClaw-specific MTU 9000 prerequisites are satisfied.

## Quick Verification Block

Run on each Spark when starting a new cluster-related session:

```bash
hostnamectl --static
id
grep '^PRETTY_NAME=' /etc/os-release
uname -r
nvidia-smi --query-gpu=driver_version,name --format=csv,noheader
docker --version
nvidia-ctk --version
ibdev2netdev
ip -br -4 addr | grep -E 'enP7s7|enp1s0|enP2p1s0'
ethtool enp1s0f1np1 | grep -E 'Speed:|Duplex:|Link detected:'
ethtool enP2p1s0f1np1 | grep -E 'Speed:|Duplex:|Link detected:'
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
```

From FirstSpark:

```bash
ping -c 3 192.168.100.11
ping -c 3 192.168.101.11
ssh -o BatchMode=yes snknitin@192.168.0.100 hostname
```

Expected peer hostname: `spark-7047`.

## Primary Sources

- [NVIDIA NCCL for Multiple Sparks](https://build.nvidia.com/spark/nccl/stacked-sparks)
- [NVIDIA DGX Spark ConnectX-7 Networking](https://docs.nvidia.com/dgx/dgx-spark/spark-clustering.html)
- [NVIDIA Sync Cluster Assistant](https://docs.nvidia.com/sync/latest/cluster-assistant.html)
- [Inspect and Verify a ConnectX-7 Cluster Network Plan](https://docs.nvidia.com/sync/latest/cluster-network-inspection.html)
- [NVIDIA vLLM Multi-Node Serving](https://build.nvidia.com/spark/vllm/multi-node)
- [NVIDIA TensorRT-LLM on Two Sparks](https://build.nvidia.com/spark/trt-llm/stacked-sparks)

## Related Notes

- [[Local Setup Index]]
- [[Task Checklist]]
- [[DGX Spark Second Node And Dual Spark Readiness Research 2026-08-20]]
- [[DGX Spark Qwen NVFP4 Memory And Startup Optimization Research]]
- [[DGX Spark Operations Setup Guide]]
- [[DGX Spark Model Installation And Switching Guide]]
