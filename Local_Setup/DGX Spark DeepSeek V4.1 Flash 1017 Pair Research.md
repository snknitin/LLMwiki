---
created: 2026-10-26
status: researched-not-installed
tags: [dgx-spark, deepseek, tensorfold, exl3, second-spark, third-spark, research]
---

# DeepSeek V4.1 Flash 1017 on the SecondSpark + ThirdSpark pair: research and plan

Should DeepSeek-V4.1-Flash-1017 become the pair's third lane, and its default, next to GLM 5.3 Flash and Qwen 3.8 Flash Next? Targets from the owner: **context 1M** (500K minimum), **decode 70+ tok/s** for one request (60 minimum), **prefill 2,000+ tok/s**, and quality better than GLM. Nothing here is installed yet; the last section is the goal command for the session that installs it. Pair setup and the existing lanes: [[Three Spark Frontier Pair Handoff]]. Measured numbers for the current lanes: [[DGX Spark Frontier Model Qualification Results]].

## Answer

**Yes, as the default lane, if it passes our own tests.** Recipe: [MiaAI-Lab/DeepSeek-v4.1-Flash-1017-2x-DGX-Sparks](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-1017-2x-DGX-Sparks) (same author as our GLM and Qwen recipes, the most-used and most-maintained of the three, 1M window, memory watchdog, tool and structured-output patches). Quant: the recipe's pinned Mia EAQ v1 2.9 bpw pack first, then an A/B with the Plus-Ten TensorFold 2.9 bpw pack (same layout, lower KL). GLM stays installed as the fallback and swap lane.

| | DeepSeek 1017 (author figures) | GLM 5.3 Flash fp8 (our measurement) | Qwen 3.8 Flash Next (our measurement) | Target |
|---|---:|---:|---:|---:|
| Decode, 1 request, prose | **74.9** (sparkDash, MiaAI); 73.1 C1 (tonyd2wild); 59.1 (forum, thinking off) | 43.0 | 66.2 | 70+ |
| Decode, 1 request, code | **109.9** (MiaAI); 103.4 (forum); 92.2 (Elevatormusic) | 57.4 | — | — |
| Decode, 4 requests together | 130 prose / 155.5 code (MiaAI) | 107.6 / 145.3 | 196.6 | — |
| Prefill | **2,166–2,183** at 8K–32K, 2,079 at 128K, 2,000 at 256K (MiaAI); 1,266 at 1,035,020 (Elevatormusic) | ~1,870 average over a 790K prompt | — | 2,000+ |
| Context | 1,048,576; needles found at 479K (MiaAI), 1M (tonyd2wild 642 s, Elevatormusic 13.6 min) | 1,048,576 | 1,048,576 | 1M |
| Vendor coding scores ([model card](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash-1017)) | Terminal-Bench 4.0 **42.3**, DeepSWE v1.1 **77.0** | Terminal-Bench 4.0 37.4 ([Vals](https://www.vals.ai/models/zai_glm-5.3-flash)); DeepSWE 63.4 ([ZenMux](https://zenmux.ai/blog/deepseek-v41-flash-vs-glm-53-flash-the-practical-comparison), other harness) | — | better than GLM |
| Quant | EXL3 2.9 bpw (experts 3-bit, 2-bit in layers 18–22, attention 5, head 6) | EXL3 4 bpw experts, fp8 dense | NVIDIA NVFP4 | ≥3.5 bpw preferred |

Author speed figures are self-reported on their Sparks; our probe (thinking off, temperature 0, 512-token prose prompt) usually lands a little lower than sparkDash: Qwen measured 66.2 against the author's 67.4.

## Why this model, and the quality risk

- **Better on paper than GLM 5.3 Flash** on agentic coding: Terminal-Bench 4.0 42.3 vs 37.4, DeepSWE 77.0 vs ~63–67, and [BenchLM](https://benchlm.ai/compare/deepseek-v4-1-flash-vs-glm-5-3-flash) coding 60.9 vs 48.7. The 1017 update fixed much of the original V4.1's weakness (Terminal-Bench 4.0 31.2 → 42.3). Caveat: [MindStudio](https://www.mindstudio.ai/blog/deepseek-v4-1-flash-benchmarks) reports two hands-on tests where V4.1 Flash did worse than its benchmarks suggest, and on the NVIDIA forum one user says it chokes under 8-agent prefill-heavy work where GLM and Qwen hold up. Hence our own A/B against GLM is a gate, not an afterthought.
- **The quant is below the owner's 3.5 bpw line.** It is the only way it fits: DeepSeek's own weights are FP8 with FP4 experts, ~307 GB without the Engram tables (510 GB with them), and two Sparks have 256 GB together. Full precision needs 3+ Sparks, which would take FirstSpark (not allowed). Mitigating facts:
  - DeepSeek's native experts are already 4-bit, so 3-bit experts are one step down, not four.
  - Measured closeness to the native model, all on sudoingX's shared panel (254,846 positions; lower KL is better): **Plus-Ten TensorFold 2.9 bpw: KL 0.0256, top-1 95.25%**; Mia EAQ v1 2.9 bpw: 0.0290, 94.93%; LibertAIDAI 2.9 bpw: 0.0304; best seen, a vLLM 2.75 bpw-experts build: 0.0201, 95.96%. Plus-Ten's card also reports MMLU-Pro (thinking off) 67.0 vs 68.0 native, and GPQA Diamond 92.9 / IFEval 89.6 matching native within noise ([card](https://huggingface.co/Plus-Ten/DeepSeek-V4.1-Flash-1017-TensorFold-EXL3-2.9bpw)).
  - These KL figures can't be compared with GLM's KL 0.090 (another harness, against FP8).
- **Loops**: the original V4.1 looped at maximum reasoning effort. The MiaAI recipe advises `reasoning_effort: "high"` instead of `"max"` for agents (issues #33, #37) and has a `THINKING_BUDGET` cap. The goal uses both and runs our loop check.
- **The drafter is commercial-safe**: DSpark draft blocks are part of DeepSeek's MIT checkpoint, unlike GLM's DFlash2 (CC BY-NC-ND).

## The three recipes compared

All three run the same engine: bertholomus's native TensorFold (Zig) `dsv41` build at TP=2, on a ~2.9 bpw EXL3 pack plus Engram's two tables (shards 47–48 of `deepseek-ai/DeepSeek-V4.1-Flash-1017` @ `1bae0e10`, ~203 GB, unquantized, which must be on **local disk on both Sparks**; over NFS, prefill falls to ~700–900 tok/s).

| Recipe | Pack | What it adds | Verdict |
|---|---|---|---|
| **[MiaAI-Lab 1017](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-1017-2x-DGX-Sparks)** (304★, last push 24 Oct, commit `27741e17`) | Mia EAQ v1 2.9 bpw @ `45ee5d0f` (`EAQ_V1_1=1` for v1.1) | 29 engine patches: tool-call gate incl. `tool_choice` and `response_format` (`0004`), prompt passes no longer freeze other streams, image prompt cache, indexer split (+4–7% prefill at 256–400K), `POOL` beyond the window, spill tier, KV sharding, `memguard.sh`, optional systemd unit, `THINKING_BUDGET`, Anthropic `/v1/messages` | **Use this.** Same `start.sh`/`stop.sh`/`scripts/local.sh` shape as our GLM and Qwen lanes |
| [Elevatormusic](https://github.com/Elevatormusic/DeepSeek-V4.1-Flash-1017-EXL3-TensorFold-2x-DGX-Spark) (66★) / [HF card](https://huggingface.co/Elevatormusic/DeepSeek-V4.1-Flash-1017-2x-DGX-Spark-TensorFold-2x-Faster) | LibertAIDAI 2.9 bpw @ `afc7aa0a` | forced tool calls, byte-exact prompt encoding, structured output, per-request fault isolation, page-cache fixes for steady long prefill; 57 prose / 92 code, 2,179 prefill at 32K | Good engineering, slower figures, smaller community; "full hardware validation pending" |
| [tonyd2wild TP2 run](https://github.com/tonyd2wild/DeepSeek-V4.1-Flash-TP2-and-TP4-DGX-Sparks/tree/main/runs/2026-10-18-1017-tensorfold-tp2) | LibertAIDAI 2.9 bpw | a measured run of bertholomus's engine: C1 73.1 / C4 135.8, prefill 1,922–2,200, needles to 1M, 69-scenario eval 97.1, 6.7 GiB free on the head while serving | Evidence, not an installer |
| [NVIDIA forum vLLM build](https://forums.developer.nvidia.com/t/deepseek-v4-1-flash-1017-exl3-2-75-bpw-experts-on-2x-spark-with-vllm-kld-0-0201-320k-ctx-vision-tools-weights-ready-image/386295) | 2.75 bpw experts, KL 0.0201 | vLLM image, 1M reached by v24 | Best KL, but 56 prose / 91 code and vLLM-only; a later option |

[Reddit thread](https://www.reddit.com/r/LocalLLaMA/comments/1x8q6t6/deepseek_v41_flash_1017_on_2x_dgx_spark_57_toks/): not readable from here (reddit blocks the fetcher).

Better models? No other model found fits two Sparks at a higher precision with these speeds. Qwen 3.8 Flash Next (66 tok/s, NVFP4) and GLM 5.3 Flash are already lanes; the guides' other two-Spark 1M options (Inkling-Small, MiMo-V2.5 Omni) run ~31–33 tok/s.

## Risks to plan for

- **Memory is the limit.** Weights ~99 GiB a Spark; rank 0 holds ~104 GiB. `start.sh` refuses below `MIN_AVAIL_GIB` 112 (our idle pair: 117–123 GiB). A Spark that runs out does not error, it freezes and must be power-cycled; `memguard.sh` kills the rank first (2.5 GiB floor). MiaAI's head (desktop + ~6 GiB of other software) bottomed at 3.1 GiB on a 100K prompt at 1M and at 2.67 GiB on a 479K needle at 512K. SecondSpark is leaner (only the GNOME session, ~0.5 GiB), so 1M is plausible; switching it to `multi-user.target` frees that too.
- **Open stability issues**: #65 (a ~360K prompt can leave CUDA graph capture broken until restart), #63 (contained to one request by patches 0011–0029), #51 (idle-spin hang after a graph error), #47 (worker hard lockup, mlx5 AER, on kernel 6.17.0-1026), #48 (prefill 25% under README on one setup). A soak test and an automatic fallback to GLM are part of the plan.
- **Disk and download.** Head ~505 GB (pack 196 GiB, Engram ~203 GB, rank 0 weight file ~106 GB) + 25 GB image; worker ~310 GB (Engram + rank 1 weight file). SecondSpark has 3.1 TB free, ThirdSpark 3.3 TB. The download is ~413 GB at the line rate (~40 MB/s): about 3 hours, and it fills the 300 Mb/s line meanwhile.
- **Needs sudo once:** an NFS export from SecondSpark to ThirdSpark (the worker reads the checkpoint over NFS; Engram is copied), and equal GPU clock ceilings (`nvidia-smi -lgc 0,2200`) on both Sparks.
- **Port**: the recipe defaults to 8888 (GLM's). Use **8890**, so each lane has its own port and an alias never reaches the wrong model.

## Goal command for a fresh session

Paste into a new Claude Code session opened in `F:\Vaults\LLMWiki\Local_Setup`:

```text
/goal Install DeepSeek-V4.1-Flash-1017 on the SecondSpark + ThirdSpark pair as a third TensorFold lane beside GLM 5.3 Flash and Qwen 3.8 Flash Next, qualify it against GLM, make it the pair's default lane if it passes, and route it to Hermes on FirstSpark through LiteLLM, without touching FirstSpark's always-on services.

Read first, in F:\Vaults\LLMWiki\Local_Setup: "DGX Spark DeepSeek V4.1 Flash 1017 Pair Research.md" (this plan and its evidence), "Three Spark Frontier Pair Handoff.md" (pair network, sections 6b/6c for how GLM and Qwen were installed, swap script, routing), "DGX Spark Frontier Model Qualification Results.md" and "Model And Provider Names.md". Follow the project CLAUDE.md (graphify query before reading code, graphify update after code changes). Reach the Sparks from Windows with: ssh -F "$LOCALAPPDATA/NVIDIA Corporation/Sync/config/ssh_config" <FirstSpark|SecondSpark|ThirdSpark>.

Targets: 1,048,576-token context (524,288 minimum); one-request decode 70+ tok/s (60 minimum) on our standard probe; cold prefill 2,000+ tok/s at 32K-128K; quality at least GLM's.

Do, in order, committing and pushing after each step:
1. Recipe: clone MiaAI-Lab/DeepSeek-v4.1-Flash-1017-2x-DGX-Sparks to ~/src/frontier/deepseek41-1017-tf on SecondSpark (head) at the current commit (27741e17 or newer; record it). Worker = snknitin@192.168.102.12, FABRIC_PEER=192.168.102.12. scripts/local.sh: CONTEXT=1048576, PORT=8890, a THINKING_BUDGET (start 16384) and REASONING_EFFORT=high (not max, issues #33/#37). Keep the engine reserve, MIN_AVAIL_GIB and memguard defaults.
2. Sudo (give me exact single-line commands in chat, never in a document): the NFS export of SecondSpark's ~/.cache/huggingface to 192.168.102.12 (read-only), nfs-common on ThirdSpark if missing, equal GPU clock ceilings (nvidia-smi -lgc 0,2200) on both, and optionally set SecondSpark to multi-user.target to free head memory. Verify each.
3. Weights: the recipe's prepare.sh downloads the pinned Mia EAQ v1 2.9 bpw pack (~210 GB) and Engram shards 47-48 from deepseek-ai/DeepSeek-V4.1-Flash-1017 @ 1bae0e10 (~203 GB) and copies Engram to ThirdSpark over the 200G link. The download fills the 300 Mb/s line for ~3 h: say so and measure the rate. If a root-owned ~/.cache/huggingface/hub/.locks blocks hf, download into a staging cache and merge as done for GLM (never overwrite). Check free disk on both first.
4. Start with GLM (or Qwen) stopped (only one lane fits in memory). Record load time, MemAvailable on both Sparks after load, and that both RoCE rails are used.
5. Qualify on FirstSpark with scripts/glm53-pair-qualify.sh (MODEL=DeepSeek-V4.1-Flash-1017 CONTAINER=<the recipe's container name> ENDPOINT=http://192.168.100.11:8890, profile deepseek41-1017-tf-eaq): identity, chat, tool call, vision, 512-token prose and code C1/C2/C4, loop check, retrieval at 30K/195K/790K. Then: the recipe's tools/validate.py and tools/bench.py (cold prefill at 8K/32K/128K/256K), a needle at ~1M, model-serving-minefield quick with --hf-repo against :8890, and a Hermes coding A/B against GLM on the same 3 real tasks (same prompts, judge correctness, tool use and loops). Stop and report if MemAvailable on either Spark ever goes under 2.5 GiB or a kernel NV_ERR_NO_MEMORY/Xid appears. If 1M is unsafe on the head, measure 524288 and say which you kept.
6. Quant A/B: if step 5 passes, try Plus-Ten/DeepSeek-V4.1-Flash-1017-TensorFold-EXL3-2.9bpw (same layout, lower KL; use its v1.1 F32 router bias) via the recipe's MODEL_ID/MODEL_REVISION override, only if it loads cleanly. Re-run the quality and speed probes; keep the pack that is better on quality without a clear speed loss. Ask me before deleting the other pack.
7. Soak: 2 hours of mixed load (4 concurrent Hermes sessions with long prompts, one 300K+ prompt, idle gaps) watching issues #65/#51/#47 symptoms. Record restarts, errors and memory low-water.
8. Swap and default: extend scripts/pair-swap.sh (and deploy to ~/src/frontier/pair-swap.sh) to deepseek|glm|qwen|status, with DeepSeek the default and an automatic fallback to GLM if DeepSeek fails to start; extend scripts/pair-swap.ps1 and add a "Spark Pair - DeepSeek V4.1 Flash" desktop shortcut beside the GLM and Qwen ones. Add a SecondSpark systemd user unit that brings the default lane up after a reboot (ask me before enabling it). Test every swap direction live.
9. Route: add LiteLLM alias deepseek41-flash-pair -> http://192.168.100.11:8890/v1 on FirstSpark (backup the config first, targeted edit, docker restart spark-litellm), add it to the Hermes local-models model lists (context 1048576) in the main config and profiles that list the pair lanes, clear the custom:http://127.0.0.1:4000/v1#... cache entries, and verify a real Hermes tool-using request through custom:local-models / deepseek41-flash-pair. Don't change Hermes' default models unless I ask.
10. Record: measured numbers and the decision in "DGX Spark Frontier Model Qualification Results.md", a new section in the handoff, "Local Setup Index.md" and "Model And Provider Names.md", plus the research note's status.

Pass bar to make DeepSeek the default: all step-5 gates pass, C1 prose >= 60 tok/s, cold prefill >= 2,000 tok/s at 32K, retrieval passes at >= 500K, the soak has no hang or freeze, and the Hermes A/B is not worse than GLM. Otherwise keep GLM the default, keep DeepSeek as a swap lane, and say why.

Rules: don't change FirstSpark's always-on services (Qwen 3.6 35B vLLM, LiteLLM except the alias, Hermes except the model lists, aux services). Anything needing sudo: the exact single-line command in chat. Never delete files: list what can be freed and I'll decide. Plain-language updates; measure before claiming and say what wasn't verified. After any QSFP cable change, reboot that Spark with the cable in and rerun NCCL.
```
