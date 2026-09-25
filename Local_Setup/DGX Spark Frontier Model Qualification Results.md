# DGX Spark Frontier Model Qualification Results

Snapshot: 2026-09-25, including the GLM recipe refresh at commit `0f49cfdbaa131286eb592cd6ebfa048f3aa85c4e` and the first SecondSpark single-node Qwen v0.30 qualification attempt. The headline rows are **local, saved probe results**, not upstream recipe claims or pure decode benchmarks. Each headline source is the timestamped directory under `~/frontier-results/<profile>/` on FirstSpark; a profile's `latest` symlink can later move to a newer run. `C1`, `C2`, `C4`, and the one measured `C8` are aggregate **end-to-end output tokens per second** at that many simultaneous client requests using the shared 512-output-token prose probe. `Quality` is a separate end-to-end response test. Do not compare its rate to a C1 rate as though they were the same request. The SecondSpark attempt used the recipe's own smoke and structured harnesses, so it is tabulated separately rather than mixed into the standardized headline table.

| Result profile | Served context | Quality tok/s | C1 tok/s | C2 tok/s | C4 tok/s | Largest passing prompt tokens | Chat / tool / vision | Saved run | C8 tok/s |
|---|---:|---:|---:|---:|---:|---:|---|---|---:|
| `spark-fast` (FirstSpark only) | 262,144 | 62.360 | 77.214 | 126.060 | 122.872 | 235,029 | Pass / pass / pass | `20260922-191753` | — |
| `qwen38-nvfp4` | 262,144 | 33.494 | 48.840 | 85.973 | 134.719 | 235,029 | Pass / pass / pass | `20260921-192534` | 205.461 |
| `qwen38-fp8` | 262,144 | 21.153 | 41.354 | 62.964 | 90.977 | 235,029 | Pass / pass / pass | `20260921-210554` | — |
| `glm53-flash` (DFlash/850K) | 850,000 | 18.685 | 23.826 | 34.136 | 47.510 | 790,022 | Pass / pass / pass | `20260921-215645` | — |
| `glm53-flash-mtp-850k` | 850,000 | 21.798 | 21.700 | 39.730 | 55.196 | 790,022 | Pass / pass / pass | `20260922-084501` | — |
| `glm53-flash-v2` | 850,000 | 22.283 | 18.741 | 29.457 | 31.421 | 790,022 | Pass / pass / pass | `20260925-123053` | — |
| `glm53-flash-dflash-500k` | 500,000 | 21.484 | 24.098 | 32.260 | 49.242 | 490,022 | Pass / pass / pass | `20260922-092858` | — |
| `deepseek41-bringup-131k` | 131,072 | 29.564 | 34.153 | 34.875 | 34.803 | 120,019 | Pass / pass / pass | `20260922-174513` | — |
| `deepseek41-flash` (DSpark/600K) | 600,000 | 29.989 | 34.477 | 50.746 | 47.014 | 580,019 | Pass / pass / pass | `20260922-104802` | — |

All listed chat, tool, vision, context, and concurrency results passed in their saved runs. The updated GLM row also has a passing `identity.json` receipt and retained `ORANGE-427` through a 790,022-token prompt in 250.867 seconds. Its matched five-run recipe benchmarks are stored beside the probe results: structured decode **24.169 tok/s** median and hash-map prose **19.572 tok/s** median, versus **18.966** and **19.261** immediately before the source refresh. The structured improvement is +27.4%; prose is +1.6%.

The updated GLM row's standardized C2/C4 rates are materially below the earlier MTP row (29.457/31.421 versus 39.730/55.196). An immediate repeat saved as `concurrency-repeat.json` measured C1/C2/C4 at **18.642/29.809/42.626**: C4 improved, but C1/C2 remained close and the gap did not disappear. Treat this as a flagged concurrency regression or workload-sensitive scheduler effect, not a reason to erase either receipt. The raw identity, quality, tools, vision, near-limit retrieval, routed smoke, and memory guards all passed; do not claim a general throughput win from the structured benchmark alone.

The fresh 131K and `spark-fast` runs also have passing `identity.json` receipts. The 131K profile remains an adapted one-sequence profile, distinct from the recipe-faithful DeepSeek 600K baseline. Its C2/C4 figures are **offered-client loads with queuing**, not two or four active 131K model sequences. DeepSeek 600K and `spark-fast` each allow two scheduled sequences, so their C4 loads can also queue. The Qwen NVFP4 C8 result comes from its saved raw `concurrency.json`; the comparison generator currently displays only C1/C2/C4. `—` means not measured in that run.

### Fresh DeepSeek 131K and SparkFast receipt details

| Profile | Quality output / words / elapsed | Passing context rungs (prompt tokens; elapsed) | C1 / C2 / C4 wall time | Startup `MemAvailable` head / worker |
|---|---|---|---|---|
| `deepseek41-bringup-131k` | 353 tokens / 281 words / 11.940 s | 30,019; 29.879 s · 120,019; 122.715 s | 14.991 / 29.362 / 58.846 s | 7.5 / 9.4 GiB |
| `spark-fast` | 362 tokens / 294 words / 5.805 s | 30,029; 5.357 s · 120,029; 37.288 s · 235,029; 115.847 s | 6.631 / 8.123 / 16.668 s | 72 GiB / worker idle |

### SecondSpark single-node Qwen v0.30 — Attempt 1

This is the pinned `b8439110eec0230facbe4ddf0dffe01b8f769be0` lane serving `qwen3.8-flash-next` directly on SecondSpark. It is **installed but not qualified, routed, or production-ready**. Functional requests passed, but the near-limit context load failed the memory and kernel safety gates. The server was stopped with `./stop.sh`; its checkpoint and PLE cache remain intact.

| Test or observation | Result | Evidence / measurement | Gate disposition |
|---|---|---|---|
| Raw model endpoint | Passed | `/v1/models` exposed `qwen3.8-flash-next`; non-streaming completion passed | Pass |
| Streaming | Passed | incremental deltas completed normally | Pass |
| Recipe smoke suite | 7 passed, 0 failed, 1 warning | health, 262,144 metadata, coherent answer, tool round-trip, vision, and metrics passed; expected temperature-zero determinism warning | Pass |
| Smoke prose decode | 23.6 tok/s | 400 tokens in 16.9 s; above recipe's 15 tok/s floor but 35.9% below the published 36.8 tok/s v0.30 reference on a non-identical prompt | Pass with performance flag |
| Structured warm-up C1 | 47.3 aggregate tok/s | 48.9 per-stream mean; 277 ms TTFT; 8.5 s wall | Informational |
| Structured C1, reps 1–2 | 53.6 / 55.3 aggregate tok/s | per-stream means 55.1 / 56.3; 199 / 134 ms TTFT | Pass |
| Structured C2, reps 1–2 | 103.7 / 103.4 aggregate tok/s | per-stream means 53.3 / 53.2; 215 / 211 ms TTFT | Pass |
| Structured C4, reps 1–2 | 179.0 / 190.3 aggregate tok/s | per-stream means 46.3 / 48.9; minimums 46.0 / 48.9; 236 / 228 ms TTFT | Pass |
| 100-turn sequential tool loop | 100/100 plus final `DONE` | 206,465 initial prompt tokens, 211,984 by turn 100; 448.6 s total | Functional pass |
| Intended long-agent prompt band | Missed | harness generated 206K instead of the intended 90K–140K; corrected rerun now uses half the filler and validates measured tokens | Rerun required |
| Memory before long-agent load | About 19 GiB available | NVIDIA driver about 96 GiB; container about 16.7 GiB | Baseline |
| Memory low-water | 3,208 MiB available | below the mandatory 10 GiB floor | **Fail** |
| Driver-accounted memory | About 96→111.6 GiB | grew during the 206K request and remained high after active KV usage returned to zero | **Fail / primary cause** |
| Kernel allocation errors | 9 | post-health `NV_ERR_NO_MEMORY` events | **Fail** |
| Preemption metric | Not evaluated | Step 12 exited immediately at the memory failure | Incomplete |
| Thermal state before stop | 57 °C, 11.1 W, 0% GPU use | warm chassis, but not a thermal-limit condition | Safe / not causal |
| Graceful recovery | Passed | after `./stop.sh`: no model container, about 118 GiB available, 50 °C, 3.7 W, 0% GPU use | Pass |
| LiteLLM and Hermes | Not registered | FirstSpark `spark-fast` route and LM Studio/Nemotron configuration preserved | Correctly blocked |

Saved evidence on SecondSpark under `~/src/frontier/qwen38-single-v030/logs/`: `qualification-v030-raw-started-at.txt`, `qualification-v030-smoke.txt`, `qualification-v030-structured.txt`, `qualification-v030-long-agent.txt`, and archived stop-time logs `archive/vllm-fn-tp1-20260925T233028-{container,memwatch}.log`. The full procedure and corrected rerun are in [[DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial]].

### SecondSpark single-node Qwen v0.30 — Attempt 2 corrected safety retest

Attempt 2 restarted the same pinned server with the shipped settings unchanged and ran only the corrected long-agent workload plus the Step 12 safety gate. This establishes raw eligibility for controlled promotion at the measured 103K–109K workload; it does not prove the unsafe 206K Attempt 1 workload can now pass.

| Test or observation | Result | Evidence / measurement | Gate disposition |
|---|---|---|---|
| First-turn prompt size | 103,425 tokens | inside the required 90K–140K band | Pass |
| 100-turn sequential tool loop | 100/100 plus final `DONE` | prompt grew to 108,944 tokens; 418.0 s total | Pass |
| Memory low-water | 17,094 MiB available | above the mandatory 10 GiB floor | Pass |
| Kernel allocation errors | 0 | counted from `2026-09-25T23:52:27+05:30` | Pass |
| vLLM preemptions | 0 | one metric series present, summed value zero | Pass |
| Post-test server | Healthy | `vllm-fn-tp1` remained running; about 18 GiB available | Pass |
| Post-test thermal state | 53 °C, 10.48 W, 0% GPU use | measured after the gate | Safe |
| Raw qualification verdict | Eligible for controlled promotion | LiteLLM and Hermes remained unchanged at the time of this receipt | Pass |

Attempt 2 uses `logs/qualification-v030-long-agent.txt`, the current `logs/memwatch-vllm-fn-tp1.log`, `logs/qualification-v030-raw-started-at.txt`, the kernel journal, and the live vLLM metrics endpoint. Preserve both attempts: Attempt 1 defines the current near-limit failure boundary, while Attempt 2 defines the accepted long-agent operating point.

The context elapsed values are whole-request timings and may reflect prefix-cache state; they are not separate prefill or time-to-first-token (TTFT) measurements. Startup memory comes from each run's `startup-memory.txt` after launch, **not** the minimum during context or concurrency loads. The preliminary C1/C2 passes are preserved as `concurrency-c1-c2-before-c4.json`; the headline table uses the final `concurrency.json` that repeated C1/C2 and added C4. Each C request asked for 512 output tokens and every level passed its 128-token-per-request minimum.

Source files per run: `metadata.json`, `chat-quality.json`, `tool-call.json`, `vision.json`, `context-raw-*.json`, `startup-memory.txt`, and `concurrency.json`; the two new runs also have `identity.json`. The probe's `compare` command reads **only each profile's latest run**. Regenerate its eight-profile raw table with:

```bash
python3 "$HOME/ai/tools/frontier-model-probe.py" compare \
  --profiles spark-fast,qwen38-nvfp4,qwen38-fp8,glm53-flash,glm53-flash-mtp-850k,glm53-flash-v2,glm53-flash-dflash-500k,deepseek41-bringup-131k,deepseek41-flash \
  --output "$HOME/frontier-results/comparison-all.md"
```

The generated table at `~/frontier-results/comparison-all.md` was regenerated on 2026-09-25 at 07:18:45 UTC and agrees with the nine-profile headline values above. Raw context probes request at most 64 output tokens and do **not** measure useful decode speed. The probe does not save separate TTFT or head/worker memory low-water inside its JSON. Preserve monitored minima and kernel evidence with the relevant run before comparing operating safety. These rows measure **raw endpoints**: SparkFast used FirstSpark alone; the frontier recipes used both Sparks. The updated GLM row additionally has a routed `SMOKE_PASS glm53-flash` receipt through LiteLLM and Hermes, but it is not a 48-hour soak or rollback receipt.

[[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]] retains the exact user-run steps that produced the two fresh rows. Compare answer quality and capacity alongside rates, not the aggregate rates alone.

Related: [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]] · [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] · [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]] · [[DGX Spark DeepSeek 131K And SparkFast Comparison Protocol]] · [[DGX Spark Frontier Model Hot-Swap And Routing Guide]]
