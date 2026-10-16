---
created: 2026-10-15
status: glm-live-on-pair
tags: [dgx-spark, third-spark, connectx-7, glm, deepseek, handoff, storage]
---

# Three Spark frontier pair handoff

Plan and handoff for adding the third DGX Spark: cable it, run the big coding models on Spark 2 + Spark 3, move existing weights instead of re-downloading, then free space on Spark 1. Names follow [[Model And Provider Names]].

> [!success] 16 Oct 2026: GLM 5.3 Flash is live on SecondSpark + ThirdSpark
> MiaAI TensorFold recipe, `DENSE=fp8`, FP8 KV, 1M context, 4 requests, `--thinking-budget 16384`, loop guard on. Single request **43.0 tok/s prose / 57.4 code** (old GLM 23.8), C4 107.6 / 145.3; retrieval passes at 790K tokens; loop check and tool calls pass. LiteLLM `glm53-flash` points at `http://192.168.100.11:8888/v1` and a real Hermes request passed. FirstSpark was not drained and `spark-frontier use` is retired. Full numbers: [[DGX Spark Frontier Model Qualification Results]]. Remaining: section 8 clean-up (you), and an auto-start after reboot (not set up).

## 1. Goal

| Machine | Role |
|---|---|
| **FirstSpark** (`spark-07a8`, LAN 192.168.0.101) | Files, plus the always-on Qwen 3.6 35B-A3B (vLLM, `qwen3.6-35b-a3b`) for multi-session, scheduled and autonomous jobs. Keeps LiteLLM and Hermes. **Never drained** for a frontier model. (Its Qwen 3.8 27B was retired 16 Oct; the 27B now runs only on the Windows desktop as `desktop-qwen`, see [[Model And Provider Names]].) |
| **SecondSpark** (`spark-7047`) + **ThirdSpark** (`spark-6ce7`, LAN 192.168.0.182) | Dedicated pair for the big coding models (GLM 5.3 Flash / DeepSeek V4.1 Flash), running at the same time as FirstSpark. |

Today the dual-node lanes use FirstSpark as head (LiteLLM `api_base http://192.168.0.101:8100`) and `spark-frontier` stops FirstSpark's services to run them. FirstSpark is already near its memory limit with its two always-on models (~24 GiB available), so frontier work has to leave it completely.

The pair holds **one** big model at a time: GLM needs ~80 GiB of weights per node, DeepSeek ~100 GiB. SecondSpark's single-node Qwen 3.8 Flash Next (TensorFold, `qwen38-tensorfold-second`, 62 tok/s) stops when SecondSpark joins the pair; it doesn't fit on FirstSpark.

## 2. Current state (14–15 Oct 2026)

**Network.** One QSFP112 DAC joins FirstSpark and SecondSpark on the **f1 port** (NVIDIA's Port1) of each. Details: [[DGX Spark Dual-Node Configuration And Operations Reference]].

| Interface | FirstSpark | SecondSpark | ThirdSpark |
|---|---|---|---|
| `enp1s0f1np1` (Port1, rail 1) | 192.168.100.10 | 192.168.100.11 | no cable |
| `enP2p1s0f1np1` (Port1, rail 2) | 192.168.101.10 | 192.168.101.11 | no cable |
| `enp1s0f0np0` / `enP2p1s0f0np0` (Port0) | down, free | down, free | no cable |
| LAN (`enP7s7`) | 1000 Mb/s | 1000 Mb/s | 1000 Mb/s |

ThirdSpark: newer OTA (7.6.0, kernel 7.0); DGX shell block, `dgx-status` / `models` / `space` helpers and `~/ai` layout installed; SSH aliases both ways over LAN `.local` names (First/Second → `ThirdSpark` via `id_ed25519_shared`; Third → First/Second via its own key); `uv` 0.13.1 and `hf` 2.2.0 with hf_xet. **Not yet:** QSFP cable, `hf auth login`, NGC docker login. Its ConnectX was probed at boot but the `mlx5` driver was later unbound, so reboot (or rebind) before testing the link. Its OTA/kernel differs from the other two; compare driver, CUDA, NCCL and Docker versions before a distributed run.

**Storage.** FirstSpark 1.4 TB used of 3.7 TB; SecondSpark 0.6 TB used; ThirdSpark nearly empty.

| Model files | FirstSpark | SecondSpark |
|---|---|---|
| GLM 5.3 Flash EXL3 TR3 4bpw (`models--Mia-AiLab--GLM-5.3-Flash-EXL3-TR3-4bpw`) | 164 GB | 164 GB |
| GLM 5.3 Flash DFlash2 drafter (`models--incoai--GLM-5.3-Flash-DFlash2`) | 2.2 GB | 2.2 GB |
| DeepSeek V4.1 Flash EXL3 2.9bpw (`~/.cache/huggingface/dsv41-exl3`, hard-linked as `~/src/frontier/deepseek41-dual/model`) | 197 GB | — (read over NFS) |
| DeepSeek Engram tables (`~/.cache/huggingface/dsv41-engram`, hard-linked as `~/src/frontier/deepseek41-dual/engram-src`) | 190 GB | — |
| Qwen 3.8 Flash Next NVFP4 | 124 GB | 124 GB |
| Qwen 3.8 Flash Next FP8 | 173 GB | — |

The two DeepSeek paths on FirstSpark are the same files (hard links, link count 2), not duplicates. The DeepSeek recipe's `dsv41-exl3-nfs` exporter on FirstSpark serves the weights to SecondSpark.

**Measured speeds now** (saved probes, [[DGX Spark Frontier Model Qualification Results]], 512-token prose, single request): GLM 5.3 Flash ≈ 22–24 tok/s (Sept 21–25 build); DeepSeek V4.1 Flash ≈ 34 tok/s.

## 3. Cabling the third Spark

**Required now: one approved 200G QSFP112 DAC between SecondSpark Port0 and ThirdSpark Port0.**

- Port0 is the ConnectX port **next to the RJ45 Ethernet jack**; Port1 is the one farther away (NVIDIA's naming). The existing cable is on Port1 of First and Second.
- Same port on both ends, as NVIDIA's two-Spark guide recommends for NCCL.
- Keep the FirstSpark ↔ SecondSpark cable: LiteLLM reaches the pair through it, and it's the fast path for copying weights off FirstSpark.
- **Optional later:** FirstSpark Port0 ↔ ThirdSpark Port1 closes a triangle (direct First↔Third copies and routing, and room to try 3-node recipes).

**Do not run NVIDIA's three-Spark ring setup** (`spark_cluster_setup` / `connect-three-sparks`). Its ring cables Port0↔Port1 and renumbers every link to 192.168.0–5.x, which would break today's 192.168.100/101 routes used by LiteLLM and SecondSpark. Configure the new link by hand instead.

**15 Oct: cable connected** SecondSpark Port0 ↔ ThirdSpark Port0. Without a reboot, `ibdev2netdev` showed `enp1s0f0np0` and `enP2p1s0f0np0` **Up at 200000 Mb/s on both**, `mlx5_core` was loaded on ThirdSpark, and the FirstSpark ↔ SecondSpark f1 link was unchanged. Addresses still need assigning (section 4, needs the user's sudo).

**15 Oct: link configured and tested.**

- `/etc/netplan/41-cx7-pair.yaml` applied on both; addresses as planned below.
- Pings both rails both ways, 0% loss (~1 ms).
- SSH over 192.168.102.x works both ways. Host keys were verified against the LAN-known keys before being trusted.
- ThirdSpark: OpenMPI installed, timezone set to Asia/Kolkata. NCCL `v2.30.7-1` and `nccl-tests` copied from SecondSpark (same paths, libraries resolve).
- **Raw RDMA (`ib_write_bw -R -s 1M -q 4`): 111.85 Gb/s on each rail**, so the link is healthy (~112 Gb/s per-rail ceiling, ~224 Gb/s per port).
- **NCCL `all_gather_perf` (256M–2G, Port0 HCAs only, `NET/IB` both rails): only 2.99 GB/s busbw**, versus 21.76 GB/s on the original pair. GPU Direct RDMA is disabled on all three Sparks (`mlx5dv_reg_dmabuf_mr` missing in rdma-core 50.0), so that isn't the difference.
- Likely cause: SecondSpark's resident TensorFold Qwen leaves ~1 GiB truly free (17 GiB available), slowing NCCL's host staging. The original 21.76 GB/s ran on an empty SecondSpark. **Rerun NCCL with TensorFold stopped before installing GLM**; if it is still low, compare ThirdSpark's newer OTA 7.6.0 / kernel 7.0 against the others' 7.5.0 / 6.17.
- Test command used (from SecondSpark): `mpirun -np 2 -H 192.168.102.11:1,192.168.102.12:1 -x LD_LIBRARY_PATH -x NCCL_SOCKET_IFNAME=enp1s0f0np0 -x OMPI_MCA_btl_tcp_if_include=enp1s0f0np0 -x NCCL_IB_HCA=rocep1s0f0,roceP2p1s0f0 ~/nccl-tests/build/all_gather_perf -b 256M -e 2G -f 2`, with `LD_LIBRARY_PATH=$HOME/nccl/build/lib:/usr/local/cuda/lib64`.

> [!important] Resolved 15 Oct: reboot with the QSFP cable connected
> A ConnectX-7 that initialises while the Spark is already running (cable plugged in after boot, or a cable unplugged and replugged, which removes and re-adds the card) gives **~3.0 GB/s NCCL** even though `ethtool` says 200000, raw `ib_write_bw` is ~112 Gb/s per rail and PCIe is Gen5 x4. **Rebooting that Spark with the cable already connected restores full speed.**
>
> - ThirdSpark booted without a cable, had its cable hot-plugged at 11:48, and measured 3.0 GB/s. After `sudo reboot`, SecondSpark ↔ ThirdSpark measured **19.47 GB/s avg, 21.0–22.5 GB/s at 1–2 GiB**.
> - Cable-swap test: First ↔ Second was 18.7–21.7 GB/s before the swap. FirstSpark's card was removed and re-added (`E-Switch: cleanup` at 19:49, re-probe at 20:05) and it then measured 3.0 GB/s. **FirstSpark needs a reboot with its cable connected to get its link back.**
> - "Detected insufficient power on the PCIe slot (27W)" appears at every boot on all three, including when fast, so it is not the cause.
> - FirstSpark was rebooted later on 15 Oct with the Cheetah cable connected. First ↔ Second came back to **18.4 GB/s avg, 21.5 at 1 GiB**. Hermes serve/gateway/dashboard, both native Qwen 27B units, vLLM Qwen 3.6 35B-A3B, LiteLLM and every aux service came back; LiteLLM and a Hermes `local-models` request answered end to end.
> - Rule for the future: after plugging, unplugging or moving any QSFP cable, reboot the affected Spark(s) with the cable in place, then rerun NCCL.
>
> The diagnosis below is kept as a record. Its suspects (memory pressure, ThirdSpark's newer OTA 7.6.0 / kernel 7.0) were ruled out.

**NCCL diagnosis (15 Oct, SecondSpark TensorFold stopped, 117 GiB available on both):**

| Test | Result |
|---|---|
| NCCL Second ↔ Third, 256M–2G and 1G, every variation (`NCCL_CUMEM_ENABLE=0`, `NCCL_CUMEM_HOST_ENABLE=0`, `NCCL_MAX_NCHANNELS=8`, `NCCL_PROTO=Simple`, HCA exclude instead of include) | **~3.0 GB/s busbw**, transport `NET/IB` on both rails, 64 channels |
| NCCL First ↔ Second, same settings, 256M–1G, while FirstSpark served models | **18.7 GB/s avg, 21.7 at 1G** |
| Raw RDMA Second → Third, both rails at once | 92.4 + 92.4 Gb/s (~23 GB/s) |
| Raw RDMA per rail, bidirectional | ~121 Gb/s |
| Pinned host↔device copy (1 GiB, custom CUDA test) | Second 57/59 GB/s, Third 58.5/58.9 GB/s |
| ConnectX-7 firmware | 28.45.4028 on all three |
| IOMMU | `iommu.passthrough=0` on both |

Conclusion: the link and GPU copies are healthy, and the bottleneck is NCCL on the Second ↔ Third pair. The remaining difference is ThirdSpark's software: OTA 7.6.0, kernel `7.0.0-1019-nvidia`, driver `580.178.04`, versus OTA 7.5.0, kernel `6.17.0-1029-nvidia`, driver `580.173.02` on the others. NVIDIA's DGX OS 7.6.0 release notes list Spark driver 580.173.02, so ThirdSpark's 580.178.04 likely came from a later apt upgrade. ThirdSpark's other installed kernel (6.11) has no NVIDIA module, so it can't be used for the test. Next experiment: install `linux-image-6.17.0-1029-nvidia`, `linux-modules-6.17.0-1029-nvidia`, `linux-modules-nvidia-580-open-6.17.0-1029-nvidia` and driver `580.173.02` on ThirdSpark, boot 6.17, and rerun NCCL. The 7.0 kernel stays installed for rollback.

SecondSpark's `qwen38-flash-next-tf` container was stopped for this test (restart policy `no`). Restart it with `docker start qwen38-flash-next-tf` if the pair isn't set up yet; `qwen38-tensorfold-second` in Hermes fails while it's stopped.

**Security note.** All three Sparks share one SSH host key (`SHA256:YT7DxbMu…`, created 23 Oct 2025, the factory image date). Regenerating per machine needs sudo and then re-trusting each host on every client.

**Hermes timezone.** `timezone: Asia/Kolkata` added to all six Hermes configs (previously server-local; backups in `~/.hermes/backups/timezone-20261015/`). Long-running Hermes services pick it up after their next idle restart.

## 4. New link configuration (after the cable is in)

Planned addresses (two rails, like the existing link):

| Interface | SecondSpark | ThirdSpark |
|---|---|---|
| `enp1s0f0np0` (Port0, rail 1) | 192.168.102.11/24 | 192.168.102.12/24 |
| `enP2p1s0f0np0` (Port0, rail 2) | 192.168.103.11/24 | 192.168.103.12/24 |

Steps:

1. ThirdSpark: reboot (rebinds `mlx5`), then on both machines `ibdev2netdev` must show the Port0 interfaces **Up**, and `ethtool enp1s0f0np0 | grep Speed` must report `200000Mb/s`.
2. On each machine, add a separate netplan file for the new port (don't edit the existing CX-7 file). SecondSpark example (ThirdSpark is the same with `.12`):

   ```bash
   sudo tee /etc/netplan/41-cx7-pair.yaml >/dev/null <<'EOF'
   network:
     version: 2
     ethernets:
       enp1s0f0np0:
         addresses: [192.168.102.11/24]
       enP2p1s0f0np0:
         addresses: [192.168.103.11/24]
   EOF
   sudo chmod 600 /etc/netplan/41-cx7-pair.yaml
   sudo netplan apply
   ```
3. Check: `ping -c 3 192.168.102.12` and `ping -c 3 192.168.103.12` from SecondSpark, and the reverse from ThirdSpark. Then add `192.168.102.12` to SSH config so SecondSpark ↔ ThirdSpark works on the private link without host-key prompts.
4. Install/build matching NCCL and `nccl-tests` on ThirdSpark (same tags as the other two: NCCL `v2.30.7-1`, `nccl-tests` `b4d5bee` with `-Xlinker -lmpi_cxx`), then run the two-node `all_gather_perf` on SecondSpark ↔ ThirdSpark with `NCCL_SOCKET_IFNAME`/`UCX_NET_DEVICES` pointing at `enp1s0f0np0`. Pass bar: roughly the existing pair's 21.8 GB/s (174 Gb/s) bus bandwidth.

MTU stays 1500 (what the existing link uses and what NVIDIA's pages show). One interface tops out around 112 Gb/s, so both rails need addresses.

## 5. Recipe choice

| Model | Best two-Spark recipe found (14 Oct) | Author-reported speed | Notes |
|---|---|---|---|
| **GLM 5.3 Flash** | [MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks-TensorFold](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks-TensorFold), TensorFold v0.6.0, EXL3 4bpw, FP8 KV, DFlash2, updated 3–13 Oct | 60.4 tok/s prose, 114.7 structured single-stream; C8 131 prose / 167 code total; 1M context per request | Most-used stack in forum replies. Needs ~110 GiB free per node at start; keeps a full copy (~205 GB) on each node. |
| GLM alternative | [Entrpi/glm-5.3-flash-exl3-2x-spark](https://github.com/Entrpi/glm-5.3-flash-exl3-2x-spark) | ~32 chat, 70+ structured | `--nfs` mode keeps weights on one node only. |
| **DeepSeek V4.1 Flash** | [MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-EXL3-2x-DGX-Sparks) (what you run now) | 38.8–43 code, 23.6–29.3 prose | ~99.8 GiB weights per rank; head left with ~4–6 GiB. |
| DeepSeek alternative | [0xSero/DeepSeek-V4.1-Flash-Two-Sparks](https://github.com/0xSero/DeepSeek-V4.1-Flash-Two-Sparks) | 39–41 code, ~29 prose | Copies the full checkpoint to both nodes (~700 GB head, 470 GB worker). |

All numbers are self-reported by recipe authors on Spark hardware and weren't verified here. Prose usually runs about half of code speed; forum users average ~33 tok/s for GLM on these stacks. Faster DeepSeek recipes (52–76 tok/s, e.g. christopher_owen `spark-ds41f`, eugr `3x-spark-cluster`) need **3+ Sparks**, which would take FirstSpark. A 1-Spark GLM "60 tok/s" claim uses a 2.05bpw quant with reported loops and poor quality. DeepSeek EXL3 users report reasoning loops at max effort. Sources: the NVIDIA forum threads [GLM 4.7M KV](https://forums.developer.nvidia.com/t/glm-5-3-flash-on-2x-dgx-spark-4-7m-token-kv-cache-with-fast-exl3-serving/382486), [GLM MTP-5](https://forums.developer.nvidia.com/t/glm-5-3-flash-running-on-2x-dgx-spark-sm-121-day-0-24-7-30-3-tok-s-with-mtp-5-two-silent-gb10-gotchas-worth-knowing/381433), [DeepSeek 2.9bpw](https://forums.developer.nvidia.com/t/deepseek-v4-1-flash-exl3-2-9-bpw-for-2x-dgx-sparks/383242), [DeepSeek 3+ node recipe](https://forums.developer.nvidia.com/t/new-deepseek-4-1-flash-recipe/384438).

**Decision proposed:** GLM 5.3 Flash on the current MiaAI TensorFold build is the pair's resident coding model. Expected gain over today's GLM: about 2–3× if the author's numbers hold.

### Quality-first review (15 Oct)

Criteria from the user: quality first, no aggressive quants (treat <3.5 bpw as suspect), at least ~30 tok/s single request, TensorFold where it helps.

| Rank | Model + recipe | Quant | Quality evidence | Single-stream tok/s (author) | Main risks |
|---|---|---|---|---|---|
| **1** | **GLM 5.3 Flash** (320B/18B), [MiaAI TensorFold v1.10](https://github.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks-TensorFold) | EXL3 4bpw experts, FP8 KV | Best independent scores that fit: [Artificial Analysis](https://artificialanalysis.ai/models/glm-5-3-flash) 42 (#4); [Vals](https://www.vals.ai/models/zai_glm-5.3-flash) SWE-bench 92%, Terminal-Bench 4.0 37.4%, LiveCodeBench 80.5%. Author KL to FP8: 0.090 (wikitext) | 60.4 prose / 114.7 structured; a vLLM port of the same weights measured 46.6 / 62.6 | Default `DENSE=q4` re-quantizes attention/dense weights to 4-bit and can drop the end-of-turn token (issue #18). **Run `DENSE=fp8` first** and measure its speed (not published). DFlash2 drafter is non-commercial; the `DRAFTER=mtp` fallback is single-request. Needs `--thinking-budget` against paraphrase loops |
| 2 | **Qwen 3.8 Flash Next** (125B/6B), [MiaAI dual TensorFold](https://github.com/MiaAI-Lab/Qwen3.8-Flash-Dual-DGX-Sparks-TensorFold) | NVIDIA NVFP4 routed experts, BF16 rest | [NVIDIA card](https://huggingface.co/nvidia/Qwen3.8-Flash-Next-NVFP4): NVFP4 within ~2.5 pts of FP8 on 9 benchmarks (GPQA 91.5 vs 92.0, Terminal-Bench 2.1 82.9 vs 83.3); AA 40 (#6) | 67.4 prose; 8 requests 231 total | Recipe 1 week old; `response_format` and `logprobs` return HTTP 400; avoid its INT4-AR mode (~10% lower capability). Weaker than GLM on agentic coding |
| 3 | MiMo-V2.6-Flash (309B/15B), [MiaAI SGLang](https://github.com/MiaAI-Lab/MiMo-V2.6-Flash-2x-DGX-Sparks) | Native MXFP4 (official, no extra quant) | Vendor DeepSWE 67.9, Terminal-Bench 2.1 87.6; AA 38; no independent coding evals | 35 prose / 46 code with MTP | Fragile bring-up; DFlash mode drops prose to 25.8 |
| Avoid | DeepSeek V4.1 Flash on 2 Sparks | EXL3 2.77–2.9 bpw | Under the bpw threshold. The model loops in its reasoning channel even at native precision ([deepseek-recipe #24](https://github.com/deepseek-ai/deepseek-recipe/issues/24)). [Vals](https://www.vals.ai/models/deepseek_deepseek-v4.1-flash) Terminal-Bench 2.1 74.5 vs 90.6 claimed | ~31.6 prose / ~40 code | Needs 3+ Sparks for a sane precision |
| Avoid | GLM 5.3 Flash NVFP4 on vLLM | NVFP4 | Quant is fine (within ~1 pt of BF16) | 20–30 | Misses the speed floor; corrupted ModelOpt checkpoints reported |
| Avoid | GLM 5.3 full (753B), MiniMax M3, Kimi K3, abliterated/"uncensored" variants | — | — | — | Don't fit at good precision, or aren't the official weights |

All tok/s are author-reported on Spark hardware; none were independently verified. No independent tool-use/agent eval of these quants on Sparks was found.

**Two more recipes reviewed (15 Oct), both rejected:**

| Recipe | What it is | Speed (author) | Verdict |
|---|---|---|---|
| [justincasey/RED-SNOW-5.3-Flash-2x-DGX-Spark](https://github.com/justincasey/RED-SNOW-5.3-Flash-2x-DGX-Spark) | Not official GLM. A Blackfrost-AI **offensive-security fine-tune** (LoRA merged into GLM 5.3 Flash BF16, 17K mostly offensive-security single-turn examples). Its chat template injects a "RED-SNOW operating prompt"; refusal, coding and agent evals are "Pending". Served as vcruz305 SAGE EXL3 4.91 bpw on a TensorFold 0.6.5 fork, TP2, ~102.6 GiB per rank at 128K | 31.9 prose / 39.7 code with DFlash2; 24.6 without; one request at a time | **Avoid** for general coding: about half MiaAI's speed and an unmeasured fine-tune. Four days old, 2 stars. Worth noting: a 4.91 bpw SAGE pack of **base** GLM would be an interesting A/B, if one exists |
| [vcruz305 DeepSeek-V4.1-Flash EXL3, two-spark-tp2](https://github.com/vcruz305/DeepSeek-V4.1-Flash-EXL3-DGX-Spark-recipe/blob/main/two-spark-tp2/README.md) | `vcruz305/DSV4.1-Flash-SAGE-EXL3-3.30bpw`: experts average 3.30 bpw, pack 446 GB, which needs disk-backed Engram on 256 GB | "Loader ready; not benchmarked". An older NVMe-streaming run gave 4.4–5.7 tok/s | **Avoid**: doesn't fit in memory, no speed or quality numbers, below the bpw bar, and DeepSeek's reasoning loops are unaddressed |

Decision unchanged: **MiaAI GLM 5.3 Flash TensorFold with `DENSE=fp8`** is the pair's main model.

**Revised plan:** GLM 5.3 Flash (MiaAI TensorFold, `DENSE=fp8` tested first) is the pair's main model; Qwen 3.8 Flash Next NVFP4 dual TensorFold is the fast second lane. **Drop DeepSeek V4.1 Flash as a pair lane** unless a 3-Spark setup is ever acceptable; its 387 GB on FirstSpark then simply becomes clean-up (section 8) instead of a copy (section 6).

## 6. Moving weights and images (no re-downloads)

Copy over the 200 Gb/s CX-7 links (FirstSpark → SecondSpark on 192.168.100.11; SecondSpark → ThirdSpark on 192.168.102.12). Use `rsync -aH` so Hugging Face cache symlinks and the DeepSeek hard links survive.

| What | Command (run on the source machine) |
|---|---|
| GLM 5.3 Flash EXL3 + DFlash2 drafter, Second → Third | `rsync -aH --info=progress2 ~/.cache/huggingface/hub/models--Mia-AiLab--GLM-5.3-Flash-EXL3-TR3-4bpw ~/.cache/huggingface/hub/models--incoai--GLM-5.3-Flash-DFlash2 192.168.102.12:.cache/huggingface/hub/` |
| DeepSeek EXL3 + Engram, First → Second | `rsync -aH --info=progress2 ~/.cache/huggingface/dsv41-exl3 ~/.cache/huggingface/dsv41-engram 192.168.100.11:.cache/huggingface/` |
| DeepSeek, Second → Third (only if the recipe wants a worker copy instead of NFS) | `rsync -aH --info=progress2 ~/.cache/huggingface/dsv41-exl3 ~/.cache/huggingface/dsv41-engram 192.168.102.12:.cache/huggingface/` |
| Qwen 3.8 Flash Next NVFP4, Second → Third (only if wanted as a pair option) | `rsync -aH --info=progress2 ~/.cache/huggingface/hub/models--nvidia--Qwen3.8-Flash-Next-NVFP4 192.168.102.12:.cache/huggingface/hub/` |
| Docker image for a lane, e.g. First → Second | `docker save <image> \| ssh 192.168.100.11 docker load` (find the lane's image with `docker images` and the recipe's compose file) |

Before copying GLM, check the MiaAI TensorFold v0.6.0 README: confirm it accepts the existing `GLM-5.3-Flash-EXL3-TR3-4bpw` files or needs its own conversion. Each copy should finish in minutes; check sizes with `du -sh` on both ends afterwards.

**16 Oct: README checked (recipe commit `3fd60dfc`, 12 Oct; image `v0.6.0-e66c657a433d`, 107 patches). The existing GLM files don't match it.**

| | What we have (First + Second) | What the recipe pins |
|---|---|---|
| Checkpoint | `Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw` rev `25a44fdb`, 120 shards, 164 GiB. Its `MIRROR.json` says it is a byte-identical mirror of `brandonmusic/GLM-5.3-Flash-tr3-4bpw` (ShapleyMCG codec, `serving_reader_qualified: false`), made for the older `GLM-5.3-Flash-EXL3-2x-DGX-Sparks` recipe. The repo no longer resolves on Hugging Face | `Mia-AiLab/GLM-5.3-Flash-EXL3-4bpw-TensorFold` rev `078455ff`, 83 shards, 175.7 GB (Mia's own quant, "calibrated for how TensorFold serves it"; Apache 2.0). **0 of 89 large files share a hash with ours** |
| DFlash2 drafter | `incoai/GLM-5.3-Flash-DFlash2` rev `dc77ff1c`, 2.2 GB | rev `bf582e4e`, 2.34 GB; the weights file differs |
| Image | none of the TensorFold GLM image | `ghcr.io/miaai-lab/glm-5.3-flash-exl3-2x-dgx-sparks-tensorfold@sha256:14b5072e…` (~25 GB, public GHCR; no NGC login unless it has to build from `nvcr.io/nvidia/pytorch:26.07-py3`) |
| Disk per Spark | — | ~205 GB under `~/.cache/huggingface` + 35 GB free under Docker's root. SecondSpark has 2.9 TB free, ThirdSpark 3.5 TB |

**16 Oct: ThirdSpark first-boot audit against SecondSpark.**

| Item | SecondSpark | ThirdSpark | Status |
|---|---|---|---|
| OTA / kernel / driver | 7.5.0 / 6.17.0-1029 / 580.173.02 | 7.6.0 / 7.0.0-1019 / 580.178.04 | Differs, but NCCL measured 19.5–22.5 GB/s after the reboot, and the model runs in the same container on both. **Don't `apt upgrade` either one mid-project**: SecondSpark has 426 pending upgrades, including a new kernel and driver |
| Docker group, GPU in a container | yes / yes | yes (added 16 Oct) / yes (`nvidia-smi -L` in the recipe image) | OK |
| Recipe image | pulled from GHCR | copied from SecondSpark over the CX-7 link (`docker save \| docker load`, 292 s) | OK |
| HF login / NGC login | yes / no | yes / no | OK (no NGC image needed) |
| Timezone, NTP, swap, nvidia-persistenced | Asia/Kolkata, synced, 16G, active | same | OK |
| CX-7 firmware, RoCE | 28.45.4028, Port0 + Port1 up | 28.45.4028, Port0 up (Port1 has no cable) | OK |
| NCCL v2.30.7 + nccl-tests, OpenMPI 4.1.6 | yes | yes | OK |
| Free memory at idle | 118.7 GiB | 122.9 GiB | Above the recipe's 110 GiB |
| Desktop (gdm, graphical.target) | on, no monitor | on, no monitor (~0.5 GB) | Optional to turn off |
| LAN address | DHCP 192.168.0.100 | DHCP 192.168.0.182 | Reserve both in the router so the LAN SSH names don't move |
| Unattended upgrades | not installed | not installed | OK |

Download speed: the line is 300 Mb/s (≈37.5 MB/s); the pinned download measured **36–40 MB/s over 2 minutes**, i.e. line rate, so ~80 min for 178 GB. Downloading on ThirdSpark in parallel would only split the same line; the worker copy goes over the 200G link instead.

So the recipe needs a fresh ~178 GB download (checkpoint + drafter) on the head; `prepare.sh` then rsyncs it to the worker over the link. ThirdSpark's user is **not in the `docker` group** yet (needs sudo). Its `hf` token is in place.

## 6b. GLM install on the pair (done 16 Oct)

- Checkpoint `Mia-AiLab/GLM-5.3-Flash-EXL3-4bpw-TensorFold@078455ff` and DFlash2 `@bf582e4e` downloaded on SecondSpark at line rate (36–45 MB/s, ~75 min), merged into `~/.cache/huggingface/hub`; `prepare.sh` copied both to ThirdSpark over the link at ~500 MB/s.
- Recipe: `~/src/frontier/glm53-tf` on SecondSpark (commit `3fd60dfc`). `scripts/local.sh`: `WORKER=snknitin@192.168.102.12`, `FABRIC_PEER=192.168.102.12`, `DENSE=${DENSE:-fp8}`, `export TF_GLM_LOOP_GUARD=1`. Both rails used; startup estimate 90.7 GiB/rank, pool 2,271,232 tokens; idle `MemAvailable` ~9 GiB head / ~11 GiB worker; loads in ~90 s after the first start.
- Start / restart / stop (on SecondSpark): `cd ~/src/frontier/glm53-tf && ./start.sh --thinking-budget 16384` · `./start.sh restart --thinking-budget 16384` · `./stop.sh`. Logs in `~/src/frontier/glm53-tf-logs/`.
- **Not auto-started**: the containers use restart policy `no`; after a reboot of either Spark, run the start command. The README's `FOREGROUND=1 ./start.sh` is meant for a systemd unit.
- DFlash2 is CC BY-NC-ND (non-commercial). For commercial use set `DRAFTER=mtp` (one request at a time, ~5–10% slower); not needed for personal use.
- Qualification: `scripts/glm53-pair-qualify.sh` on FirstSpark. `DENSE=q4` was measured (56.0 / 64.4 tok/s) but failed the recipe's end-of-turn test more often (4/48 vs 1/48), so fp8 stays.

## 7. Routing after the move

**Done 16 Oct:** `glm53-flash` → `http://192.168.100.11:8888/v1` (backup `~/ai/services/litellm/config.yaml.bak-20261016-pre-glm-pair`), `docker restart spark-litellm`, healthy; the reasoning shim is no longer in the path. `custom:http://127.0.0.1:4000/v1#…` cleared from the main and orchestrator Hermes caches (backups `~/.hermes/backups/glm-pair-20261016/`). Hermes one-shot via `custom:local-models` / `glm53-flash` passed. `spark-frontier use …` now refuses with a pointer to the pair (backup `~/.local/bin/spark-frontier.before-glm-pair-20261016`); `status` and `restore-spark-fast` unchanged. `deepseek41-flash` still points at the old FirstSpark-head address and will fail if called.


- LiteLLM on FirstSpark: point `glm53-flash` (and `deepseek41-flash` when swapped in) at the pair's head on SecondSpark, e.g. `http://192.168.100.11:8100/v1`, instead of `192.168.0.101:8100`. Restart `spark-litellm` with `docker restart spark-litellm` (`docker compose restart` failed silently on 13 Oct).
- Hermes: the `local-models` provider already lists `glm53-flash` and `deepseek41-flash`; no provider change needed. Clear the `custom:http://127.0.0.1:4000/v1#…` entries in `~/.hermes/provider_models_cache.json` (and `profiles/*/`) if the list changes.
- `~/.local/bin/spark-frontier` (drains FirstSpark, starts its lanes, sets Hermes to `custom:local-models`) should no longer be used for GLM/DeepSeek. Retire or rewrite it for the SecondSpark/ThirdSpark pair; its `restore-spark-fast` path stays useful for FirstSpark's own 35B.
- The current `qwen38-tensorfold-second` alias (SecondSpark single node) stops working while the pair runs.

## 8. Freeing space (done 16 Oct 2026)

Done with the user's approval after the pair passed. Each path was checked first: no running container mounted it, nothing had it open, and the live GLM checkpoint and drafter resolve with no broken links afterwards. All services were checked afterwards: `glm53-flash`, `qwen3.6-35b-a3b` and the 27B answer; Hermes, LiteLLM, sparkDash, Fresh Brief, FreshRSS and SearXNG are up.

| Spark | Before | After | Removed |
|---|---:|---:|---|
| FirstSpark | 1.4 TB used | **375 GB used** (3.2 TB free) | DeepSeek EXL3 + Engram and the hard-linked `~/src/frontier/deepseek41-dual` (387 GB); Qwen 3.8 FP8 (173 GB) and NVFP4 (124 GB); GLM TR3 (164 GB) and its old DFlash2; brandonmusic GLM (35 GB); unused nvidia Qwen 3.6 35B NVFP4 (22 GB); the parked `qwen27-dflash` (Qwen 3.6 27B NVFP4 + z-lab DFlash) and `nemotron3-omni` lanes' models and images; `~/.lmstudio` (41 GB); the ODS backup apart from its root-owned files; old images (old GLM/DeepSeek, vLLM nightly/latest/qwen38/NGC 26.07/v0.20.0, Nemotron vLLM, SGLang, LiteLLM v1.81.3, hermes-agent, the NFS exporters) and 12 GB of build cache. `vllm-fn-nfs` removed and `glm-reasoning-shim.service` disabled |
| SecondSpark | 795 GB used | **401 GB used** (3.1 TB free) | GLM TR3 (164 GB); MLX Qwen (113 GB in the shared `hub/blobs`, removed blob by blob after checking none were shared); the old DFlash2 revision; `~/ai/staging`; `~/hf-staging`; the stopped single-node Qwen container and image; vLLM v0.30/qwen38, old GLM/DeepSeek and CUDA-devel images; the three NFS volume definitions |
| ThirdSpark | — | 229 GB used | `~/hf-test` |

What is left:

| Spark | Models | Images |
|---|---|---|
| FirstSpark | `unsloth/Qwen3.6-35B-A3B-NVFP4` (live 35B), `~/ai/stores/models` (live 27B + DFlash2 drafter), `Systran/faster-whisper-base` | those of the running services |
| SecondSpark | GLM TensorFold checkpoint + DFlash2 `bf582e4e`, **Qwen 3.8 Flash Next NVFP4 `fc694b54`** (exactly the revision the Qwen dual TensorFold recipe pins, for the planned second lane) | `tensorfold-glm53:v0.6.0` |
| ThirdSpark | GLM TensorFold checkpoint + DFlash2 (copied by `prepare.sh`) | `tensorfold-glm53:v0.6.0` |

Still to do: `~/backups/ods-to-standalone-litellm` holds 1.9 GB of root-owned files (needs sudo). The dead LiteLLM aliases were removed the same day; LiteLLM now lists `qwen3.6-35b-a3b` and `glm53-flash` ([[Model And Provider Names]]).

## 9. Order of work (steps 1–3 done 16 Oct; DeepSeek dropped in section 5)

1. **You:** plug one QSFP112 DAC into SecondSpark Port0 ↔ ThirdSpark Port0; run `hf auth login` on ThirdSpark; NGC `docker login nvcr.io` if the recipe pulls NGC images.
2. Configure and test the new link (section 4), including NCCL.
3. Copy GLM and its lane image to ThirdSpark (section 6), install MiaAI TensorFold GLM on SecondSpark + ThirdSpark, benchmark against 22–24 tok/s with the same probe, point LiteLLM at it (section 7).
4. Copy DeepSeek First → Second (→ Third), add it as the pair's swap lane, benchmark against 34 tok/s.
5. Free FirstSpark space (section 8), update [[Local Setup Index]] and this note.

## 10. Paste-ready continuation brief

> Read `Three Spark Frontier Pair Handoff.md` in F:\Vaults\LLMWiki\Local_Setup. Goal: FirstSpark keeps files and the always-on <50B models and is never drained; SecondSpark + ThirdSpark (spark-6ce7, 192.168.0.182) run GLM 5.3 Flash (MiaAI TensorFold v0.6.0) as the resident coding model, with DeepSeek V4.1 Flash as a swap lane. First check whether the SecondSpark Port0 ↔ ThirdSpark Port0 cable is in (`ibdev2netdev`, `ethtool enp1s0f0np0`). Configure it by hand as 192.168.102.x / 192.168.103.x, without NVIDIA's ring script, and run NCCL. Copy weights over CX-7 with `rsync -aH`; don't re-download. Don't touch the existing 192.168.100/101 link or FirstSpark's services. Clean-up (section 8) is done; the Qwen 3.8 Flash Next dual TensorFold lane is the next candidate for the pair.

Related: [[DGX Spark Dual-Node Configuration And Operations Reference]], [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]], [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]], [[DGX Spark Frontier Model Hot-Swap And Routing Guide]], [[DGX Spark Frontier Model Qualification Results]], [[Model And Provider Names]].
