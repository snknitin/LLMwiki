---
created: 2026-10-15
status: plan-ready-cable-pending
tags: [dgx-spark, third-spark, connectx-7, glm, deepseek, handoff, storage]
---

# Three Spark frontier pair handoff

Plan and handoff for adding the third DGX Spark: cable it, run the big coding models on Spark 2 + Spark 3, move existing weights instead of re-downloading, then free space on Spark 1. Nothing in sections 3–6 has been executed yet. Names follow [[Model And Provider Names]].

## 1. Goal

| Machine | Role |
|---|---|
| **FirstSpark** (`spark-07a8`, LAN 192.168.0.101) | Files, plus always-on models under ~50B: Qwen 3.6 35B-A3B (vLLM, `qwen3.6-35b-a3b`) and Qwen 3.8 27B (llama.cpp, `qwen38-27b-spark`), multi-session, scheduled and autonomous jobs. Keeps LiteLLM and Hermes. **Never drained** for a frontier model. |
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

## 7. Routing after the move

- LiteLLM on FirstSpark: point `glm53-flash` (and `deepseek41-flash` when swapped in) at the pair's head on SecondSpark, e.g. `http://192.168.100.11:8100/v1`, instead of `192.168.0.101:8100`. Restart `spark-litellm` with `docker restart spark-litellm` (`docker compose restart` failed silently on 13 Oct).
- Hermes: the `local-models` provider already lists `glm53-flash` and `deepseek41-flash`; no provider change needed. Clear the `custom:http://127.0.0.1:4000/v1#…` entries in `~/.hermes/provider_models_cache.json` (and `profiles/*/`) if the list changes.
- `~/.local/bin/spark-frontier` (drains FirstSpark, starts its lanes, sets Hermes to `custom:local-models`) should no longer be used for GLM/DeepSeek. Retire or rewrite it for the SecondSpark/ThirdSpark pair; its `restore-spark-fast` path stays useful for FirstSpark's own 35B.
- The current `qwen38-tensorfold-second` alias (SecondSpark single node) stops working while the pair runs.

## 8. Freeing space on FirstSpark

**Only after the pair is running and tested**, and only by you; nothing here has been deleted. Re-check each path with `du -sh` before removing.

| Item on FirstSpark | Size | Why it can go |
|---|---|---|
| `~/.cache/huggingface/dsv41-exl3` + `dsv41-engram` and the hard-linked `~/src/frontier/deepseek41-dual/{model,engram-src}` | 387 GB | moved to the pair |
| `~/.cache/huggingface/hub/models--Qwen--Qwen3.8-Flash-Next-FP8` | 173 GB | slowest variant (41 tok/s), no other copy needed |
| `~/.cache/huggingface/hub/models--Mia-AiLab--GLM-5.3-Flash-EXL3-TR3-4bpw` | 164 GB | Second and Third have copies |
| `~/.cache/huggingface/hub/models--nvidia--Qwen3.8-Flash-Next-NVFP4` | 124 GB | SecondSpark has it |
| `~/.cache/huggingface/hub/models--brandonmusic--GLM-5.3-Flash-tr3-4bpw` | 35 GB | no lane uses it |
| `~/.cache/huggingface/hub/models--nvidia--Qwen3.6-35B-A3B-NVFP4` | 22 GB | the 35B runs `unsloth/Qwen3.6-35B-A3B-NVFP4` |
| `~/.lmstudio` (Nemotron 3.5 Lightning GGUF) | 41 GB | LM Studio is disabled |
| `~/backups/ods-to-standalone-litellm` | 32 GB | 22 Sept migration backup |
| Unused Docker images + build cache | ~56 GB | `docker image prune -a` / `docker builder prune` after copying any lane images you keep |
| **Total** | **≈1 TB** | FirstSpark from ~1.4 TB to ~0.4 TB used |

Keep: `models--unsloth--Qwen3.6-35B-A3B-NVFP4` (live 35B), `~/ai/stores/models/ggml-org-Qwen3.8-27B-*` (live 27B + drafter). Decide separately: `models--nvidia--Qwen3.6-27B-NVFP4` + `models--z-lab--Qwen3.6-27B-DFlash` (24 GB, `qwen27-dflash` lane) and `models--nvidia--Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4` (21 GB, `nemotron3-omni` lane). Both lanes are listed in LiteLLM but their containers aren't running.

SecondSpark, ~60 GB: `models--Vontra--Qwen3.8-Flash-Next-MLX-4bit-MTP` (11 GB, MLX doesn't run on these machines), `~/ai/staging/qwen38-q4-k-m` (25 GB staging copy of FirstSpark's 27B files), ~25 GB unused Docker images.

Example removal, FirstSpark, after verification:

```bash
du -sh ~/.cache/huggingface/hub/models--Qwen--Qwen3.8-Flash-Next-FP8
rm -rf ~/.cache/huggingface/hub/models--Qwen--Qwen3.8-Flash-Next-FP8
```

For DeepSeek, remove both hard-linked paths, or the space isn't freed.

## 9. Order of work

1. **You:** plug one QSFP112 DAC into SecondSpark Port0 ↔ ThirdSpark Port0; run `hf auth login` on ThirdSpark; NGC `docker login nvcr.io` if the recipe pulls NGC images.
2. Configure and test the new link (section 4), including NCCL.
3. Copy GLM and its lane image to ThirdSpark (section 6), install MiaAI TensorFold GLM on SecondSpark + ThirdSpark, benchmark against 22–24 tok/s with the same probe, point LiteLLM at it (section 7).
4. Copy DeepSeek First → Second (→ Third), add it as the pair's swap lane, benchmark against 34 tok/s.
5. Free FirstSpark space (section 8), update [[Local Setup Index]] and this note.

## 10. Paste-ready continuation brief

> Read `Three Spark Frontier Pair Handoff.md` in F:\Vaults\LLMWiki\Local_Setup. Goal: FirstSpark keeps files and the always-on <50B models and is never drained; SecondSpark + ThirdSpark (spark-6ce7, 192.168.0.182) run GLM 5.3 Flash (MiaAI TensorFold v0.6.0) as the resident coding model, with DeepSeek V4.1 Flash as a swap lane. First check whether the SecondSpark Port0 ↔ ThirdSpark Port0 cable is in (`ibdev2netdev`, `ethtool enp1s0f0np0`). Configure it by hand as 192.168.102.x / 192.168.103.x, without NVIDIA's ring script, and run NCCL. Copy weights over CX-7 with `rsync -aH`; don't re-download. Don't touch the existing 192.168.100/101 link or FirstSpark's services. The user deletes files themselves.

Related: [[DGX Spark Dual-Node Configuration And Operations Reference]], [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]], [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]], [[DGX Spark Frontier Model Hot-Swap And Routing Guide]], [[DGX Spark Frontier Model Qualification Results]], [[Model And Provider Names]].
