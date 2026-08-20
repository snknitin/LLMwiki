---
created: 2026-08-20
updated: 2026-08-20
scope: dgx-spark, second-node, power-on, nvidia-sync, connectx-7, qsfp112, dual-spark, deepseek
status: official-research-complete-cable-pending
---

# DGX Spark Second Node And Dual Spark Readiness Research — 2026-08-20

## Bottom Line

1. **After restoring UPS power, do not hold the power button.** NVIDIA documents that DGX Spark starts immediately when power is applied, and its default UEFI after-power-loss setting is `Auto Boot`. It may therefore already be booting. [NVIDIA first-boot guide](https://docs.nvidia.com/dgx/dgx-spark/first-boot.html#get-ready), [NVIDIA UEFI Power On Behavior](https://docs.nvidia.com/dgx/dgx-spark-uefi/advanced-tab.html#power-on-behavior)
2. If it remains fully off, first check the UPS outlet, the included 240 W adapter, and the USB-C power connection. If the firmware was changed to `Power Button Press`, use **one brief press and release**. NVIDIA's current Spark documentation does not publish a hold duration, so a long press is not an appropriate startup instruction. Do not copy a four- or ten-second rule from a different DGX model or ordinary PC.
3. The second Spark can be prepared and used independently now. Add it separately to NVIDIA Sync, give it a unique device name, update it through DGX Dashboard, and verify its username, numeric UID/GID, SSH, `sudo`, Docker, NVIDIA Container Toolkit, driver, CUDA, and free storage.
4. A supported two-Spark direct cluster needs **one supported QSFP112 DAC, 400 GbE, Ethernet-mode-only cable**. Each Spark link operates at 200 Gbit/s. Use only one cable between the two devices; a second cable does not improve performance in the supported NVIDIA Sync topology. [NVIDIA Sync Cluster Assistant](https://docs.nvidia.com/sync/latest/cluster-assistant.html#supported-device-configurations-number-of-devices-and-topologies)
5. NVIDIA now publishes a **two-Spark DeepSeek recipe**, but it is specifically the `deepseek-ai/DeepSeek-V4-Flash-0731` profile managed by NemoClaw—not full DeepSeek-R1. NVIDIA labels the profile **Experimental** because physical two-node end-to-end validation is still pending. [NVIDIA NemoClaw two-Spark vLLM recipe](https://docs.nvidia.com/nemoclaw/user-guide/openclaw/inference/local-inference/set-up-vllm-on-two-dgx-sparks)

## Power On Now

Use this order:

1. Confirm the UPS outlet is on and the original NVIDIA 240 W power adapter is connected. NVIDIA requires the supplied adapter for expected performance and boot reliability. [NVIDIA hardware overview](https://docs.nvidia.com/dgx/dgx-spark/hardware.html#power-requirements)
2. Watch and listen for boot activity before touching the button. With the documented default `Auto Boot` behavior, applying input power is the power-on action.
3. If there is no activity, check the power chain once. Then use one brief press-and-release as the fallback for a unit configured as `Power Button Press`.
4. Do not hold the button while the system is booting or running. NVIDIA's public Spark guides do not specify a safe hold interval, and a forced power interruption would bypass the clean operating-system shutdown path.
5. When NVIDIA Sync can reach the hostname again, connect to `FirstSpark` and run the exact recovery checks in [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20#Controlled reboot test]]. Apply its [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20#Pass thresholds|pass thresholds]] before declaring recovery complete.

The firmware behavior and safe AC-return test are documented separately in [[DGX Spark Automatic Power Recovery Research]].

## First Checks In NVIDIA Sync

For the first Spark, preserve the existing ownership and service layout recorded in [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20]]. Do not reinstall or duplicate the stack merely because it rebooted.

For the second Spark, add it to NVIDIA Sync as a separate device and verify this read-only baseline:

```bash
hostnamectl --static
id
uptime
nvidia-smi
nvcc --version
docker --version
systemctl --failed
df -h /
```

NVIDIA's out-of-box container test can then verify that Docker sees the GB10 GPU. This pulls a CUDA image on first use:

```bash
sudo docker run --rm --gpus=all nvcr.io/nvidia/cuda:13.0.1-devel-ubuntu24.04 nvidia-smi
```

[NVIDIA Container Runtime validation](https://docs.nvidia.com/dgx/dgx-spark/nvidia-container-runtime-for-docker.html#test-gpu-access)

Also open DGX Dashboard and confirm there is no update currently in progress. NVIDIA recommends the Dashboard for OS, driver, and firmware updates, with stable input power throughout. [NVIDIA update guide](https://docs.nvidia.com/dgx/dgx-spark/os-and-component-update.html)

## Second Spark Checklist Before The Cable Arrives

### Identity And Access

- Assign a unique, descriptive hostname such as `spark-07a8` for the established node and a distinct name for the second. NVIDIA Sync can optionally rename devices during cluster creation, but unique names now make discovery and operations safer. [NVIDIA Sync Cluster Assistant](https://docs.nvidia.com/sync/latest/cluster-assistant.html#explanation-and-instructions-for-using-the-cluster-assistant)
- Add both devices to NVIDIA Sync from the same workstation and confirm direct SSH plus `sudo` access on each.
- **The passwords do not have to match.** NVIDIA Sync accepts the password for each node during setup and says it is kept only in memory for the configuration step, then discarded.
- The same username is helpful and already matches. Also compare `id -u` and `id -g`. Matching usernames, UIDs, and GIDs are not strictly required by Cluster Assistant, but NVIDIA recommends consistency because it avoids home-path and shared-file ownership problems. [NVIDIA Sync user-detail guidance](https://docs.nvidia.com/sync/latest/cluster-assistant.html#verify-user-details)

### Software And Firmware

- Update each Founders Edition Spark through DGX Dashboard before clustering. As reviewed on 2026-08-20, NVIDIA lists DGX OS `7.5.0`, driver `580.159.03`, CUDA `13.0.2`, kernel `6.17`, and UEFI `1.110.13`; partner GB10 systems can follow a different update schedule. [NVIDIA DGX Spark release notes](https://docs.nvidia.com/dgx/dgx-spark/release-notes.html#current-software-versions)
- Verify Docker and NVIDIA Container Toolkit on both nodes. NVIDIA's multi-node vLLM and fine-tuning playbooks require them.
- Record each node's hostname, management IP, storage capacity/free space, DGX OS version, driver/CUDA versions, and whether UEFI `After Power Loss Behavior` is `Auto Boot`.
- Do not interrupt OS or firmware updates. Perform them only while both Sparks are on stable UPS power.

### Power And Placement

- Use each Spark's own included 240 W adapter. NVIDIA's current compliance data lists 233.2 W maximum per Spark, so two can approach 466.4 W before counting any other UPS load. Confirm the UPS's continuous watt rating and desired runtime have adequate margin; NVIDIA does not publish a Spark-specific UPS-sizing formula. [NVIDIA hardware overview](https://docs.nvidia.com/dgx/dgx-spark/hardware.html#power-requirements), [NVIDIA compliance power data](https://docs.nvidia.com/dgx/dgx-spark/compliance.html#commission-regulation-eu-no-617-2013-technical-information)
- Preserve the documented clearance: 10 cm in front, 2 cm at each side, and 40 cm behind. Do not stack the units unless following NVIDIA's Spark stacking guidance. [NVIDIA DGX Spark Quick Start Guide](https://www.nvidia.com/content/dam/en-zz/solutions/support/dgx-spark/DGX-Spark-Quick-Start-Guide.pdf)

### Role Until Clustering

The cleanest temporary division is:

- **First Spark:** keep the known-good Hermes, ODS/Qwen, LM Studio/LM Link, Tailscale, and existing model-routing ownership unchanged. See [[Local Setup Index]] and [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20]].
- **Second Spark:** use as an independent experimental compute node for model downloads, single-node inference, fine-tuning experiments, Jupyter/data science, image/video generation, or an isolated test of new runtimes.
- Do not automatically copy the first Spark's always-on gateway, bot credentials, ports, or authoritative Hermes state. Duplicate instances could contend for external identities even though the machines have different IP addresses.
- If DeepSeek is the immediate goal, one Spark can already use NVIDIA's managed `deepseek-ai/DeepSeek-R1-Distill-Llama-70B` profile; it is gated and requires Hugging Face license acceptance plus a token. NVIDIA also has a separate one-Spark NVFP4 quantization tutorial for `DeepSeek-R1-Distill-Llama-8B`. [NVIDIA NemoClaw single-host vLLM models](https://docs.nvidia.com/nemoclaw/user-guide/openclaw/inference/local-inference/set-up-vllm#select-a-managed-model), [NVIDIA NVFP4 quantization playbook](https://build.nvidia.com/spark/nvfp4-quantization)

## Cable To Buy And How To Connect It

For a direct two-Spark cluster, buy **one** of NVIDIA's listed QSFP112 DAC cables:

- Amphenol `NJAAKK-N911` — QSFP to QSFP112, 400 mm; NVIDIA also lists `NJAAKK0006` as the 0.5 m version.
- Luxshare `LMTQF022-SD-R` — QSFP112 400G DAC, 400 mm.

NVIDIA specifies 400 GbE-capable, Ethernet-mode-only QSFP112 DAC cabling even though each Spark port is capped at 200 Gbit/s. A direct-attach cable has the end modules integrated; do not separately buy optical transceivers for this DAC topology. [NVIDIA ConnectX-7 networking](https://docs.nvidia.com/dgx/dgx-spark/spark-clustering.html#the-qsfp-ports-and-cables), [NVIDIA Sync troubleshooting](https://docs.nvidia.com/sync/latest/cluster-assistant.html#set-network-configuration)

Connection rules:

1. Use one cable only for the direct two-device link.
2. Use the same physical QSFP port on each Spark when following the manual two-Spark playbook. The ports are electrically interchangeable, but the playbook assumes consistent port placement.
3. Gracefully shut down both Sparks before connecting or disconnecting the cable. Although QSFP technology is hot-swappable, NVIDIA's Spark safety guide says not to connect or disconnect cables while the device is powered on. [NVIDIA DGX Spark safety information](https://www.nvidia.com/content/dam/en-zz/solutions/support/dgx-spark/DGX-Spark-Quick-Start-Guide.pdf)
4. Insert with the pull tab facing upward. It should slide in smoothly; never force it.
5. Add both Sparks to NVIDIA Sync first. Then use **Settings → Cluster Assistant → Add New Cluster**.
6. Let Cluster Assistant validate the devices, configure the ConnectX-7 network, test the 200 Gbit/s negotiation and 184 Gbit/s lower-bound throughput, and create inter-device key-based SSH.
7. Save the network information shown at completion.
8. Run the official NCCL playbook before deploying a distributed workload. Cluster Assistant configures networking and SSH; it does not install or start the model-serving workload. [NVIDIA Sync Cluster Assistant](https://docs.nvidia.com/sync/latest/cluster-assistant.html), [NVIDIA NCCL playbook](https://build.nvidia.com/spark/nccl)

## DeepSeek Decision

The DeepSeek name is not specific enough to choose a two-node deployment. Current official NVIDIA evidence supports this decision:

| Target | Current NVIDIA Spark Status |
|---|---|
| `DeepSeek-R1-Distill-Llama-8B` NVFP4 | Official one-Spark Model Optimizer recipe; multi-node is not part of that recipe. |
| `DeepSeek-R1-Distill-Llama-70B` | Official one-Spark NemoClaw managed-vLLM option; gated and requires Hugging Face license acceptance plus a token. |
| `DeepSeek-V2-Lite` | Official SGLang example on a single Spark. |
| `DeepSeek-V4-Flash-0731` | Official two-Spark NemoClaw profile, but **Experimental** pending physical two-node end-to-end validation. NVIDIA pins an exact 166.899 GB model snapshot on each node, TP2, PP1, and a 1,048,576-token configured context. The recipe does not state an FP4, FP8, AWQ, or other quantization label, so do not invent one. |
| Full `DeepSeek-R1` 671B | NVIDIA describes the full model as 671B, while its current two-Spark guidance is up to about 400B inference. Therefore full R1 is outside the documented two-Spark envelope and is not a validated target. [NVIDIA DeepSeek-R1 performance article](https://developer.nvidia.com/blog/nvidia-blackwell-delivers-world-record-deepseek-r1-inference-performance/), [NVIDIA multi-Spark scaling article](https://developer.nvidia.com/blog/scaling-autonomous-ai-agents-and-workloads-with-nvidia-dgx-spark/) |
| Qwen3-235B-A22B NVFP4 | Official two-Spark TensorRT-LLM target and the safest first large-model cluster validation. |
| Llama 3.3 70B | Official two-Spark vLLM/Ray tensor-parallel example. |
| Llama 3.1 405B AWQ-INT4 | Official vLLM two-node test example, but NVIDIA warns of insufficient memory headroom for production use. |

The DeepSeek V4 Flash profile has stricter requirements than merely connecting one cable:

- One physical ConnectX-7 port must expose exactly two active 200,000 Mbps Ethernet rails.
- Both rails need MTU at least 9,000, separate reciprocal private IPv4 `/30` networks, RoCEv2 GIDs, and pre-existing strict public-key plus host-key SSH trust.
- `~/.cache/huggingface` must exist, be writable by the same numeric user, and both Docker storage and the Hugging Face cache must pass inode checks.
- When Docker and Hugging Face cache share a filesystem, NVIDIA requires approximately **203.520 GB free on each Spark** for a cold installation.
- The containers have **no Docker restart policy**. NVIDIA says this experimental distributed runtime does not automatically persist across a Docker restart or host reboot, so its restart/recovery design must be solved separately before it is treated as an always-on service.
- The recipe exposes distributed and operational network surfaces and requires explicit firewall isolation. Follow its security section exactly.

[NVIDIA two-Spark DeepSeek V4 Flash prerequisites, storage, runtime, and persistence](https://docs.nvidia.com/nemoclaw/user-guide/openclaw/inference/local-inference/set-up-vllm-on-two-dgx-sparks)

Recommended sequence after the cable arrives:

1. Build and validate the NVIDIA Sync cluster.
2. Pass the official NCCL tests.
3. Run one NVIDIA-validated two-node model first to prove the physical cluster independently of the experimental DeepSeek profile.
4. If `DeepSeek-V4-Flash-0731` is the desired model, satisfy every NemoClaw profile prerequisite and preserve the existing first-Spark service ownership before installation.
5. If the desired model is instead full DeepSeek-R1 671B, do not treat the V4 Flash recipe as proof that it fits; it remains outside NVIDIA's documented two-Spark envelope.

## Primary Sources

- [NVIDIA DGX Spark User Guide — Initial Setup and First Boot](https://docs.nvidia.com/dgx/dgx-spark/first-boot.html)
- [NVIDIA DGX Spark UEFI Guide — Power On Behavior](https://docs.nvidia.com/dgx/dgx-spark-uefi/advanced-tab.html#power-on-behavior)
- [NVIDIA DGX Spark User Guide — ConnectX-7 Networking](https://docs.nvidia.com/dgx/dgx-spark/spark-clustering.html)
- [NVIDIA Sync User Guide — Cluster Assistant](https://docs.nvidia.com/sync/latest/cluster-assistant.html)
- [NVIDIA DGX Spark — Connect Two Sparks](https://build.nvidia.com/spark/connect-two-sparks/stacked-sparks)
- [NVIDIA DGX Spark — NCCL for Multiple Sparks](https://build.nvidia.com/spark/nccl)
- [NVIDIA DGX Spark — vLLM Multi-Node Serving](https://build.nvidia.com/spark/vllm/multi-node)
- [NVIDIA DGX Spark — TensorRT-LLM](https://build.nvidia.com/spark/trt-llm)
- [NVIDIA DGX Spark — NVFP4 Quantization](https://build.nvidia.com/spark/nvfp4-quantization)
- [NVIDIA NemoClaw — Set Up vLLM on Two DGX Sparks](https://docs.nvidia.com/nemoclaw/user-guide/openclaw/inference/local-inference/set-up-vllm-on-two-dgx-sparks)
- [NVIDIA NemoClaw — Set Up vLLM](https://docs.nvidia.com/nemoclaw/user-guide/openclaw/inference/local-inference/set-up-vllm)
- [NVIDIA DGX Spark Release Notes](https://docs.nvidia.com/dgx/dgx-spark/release-notes.html)

Related: [[DGX Spark Pre-Shutdown And Automatic Recovery Snapshot 2026-08-20]] | [[DGX Spark Automatic Power Recovery Research]] | [[DGX Spark Operations Setup Guide]] | [[Local Setup Index]]
