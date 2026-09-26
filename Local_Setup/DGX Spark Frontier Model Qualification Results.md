# DGX Spark Frontier Model Qualification Results

Snapshot: 2026-09-26, including the GLM recipe refresh at commit `0f49cfdbaa131286eb592cd6ebfa048f3aa85c4e`, both SecondSpark single-node Qwen v0.30 qualification attempts, the FirstSpark five-session Spark-Fast/LM Studio Nemotron co-residency retest, and the later permanent Nemotron 1M-context/one-slot profile. The headline rows are **local, saved probe results**, not upstream recipe claims or pure decode benchmarks. Each headline source is the timestamped directory under `~/frontier-results/<profile>/` on FirstSpark; a profile's `latest` symlink can later move to a newer run. `C1`, `C2`, `C4`, and the one measured `C8` are aggregate **end-to-end output tokens per second** at that many simultaneous client requests using the shared 512-output-token prose probe. `Quality` is a separate end-to-end response test. Do not compare its rate to a C1 rate as though they were the same request. The SecondSpark attempts used the recipe's own smoke and structured harnesses, so they are tabulated separately rather than mixed into the standardized headline table. The later co-residency retest uses its own explicitly labelled prompt and therefore does not overwrite the saved standardized `spark-fast` headline row.

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

### FirstSpark five-session Spark-Fast and Nemotron retest — 2026-09-26

FirstSpark's production `spark-fast` service was restored from the temporary 10 GiB/two-sequence profile to the previously proven **18 GiB FP8 KV / five-sequence / 262,144-token** profile. The unchanged custom vLLM image loaded 24.84 GiB of model memory, allocated **1,588,632 KV tokens**, and reported **6.06 complete 262,144-token contexts**. `--max-num-batched-tokens 8192`, MTP-2, FlashInfer, asynchronous scheduling, and the image-specific `--gpu-memory-utilization 0.72` preflight remain unchanged.

LM Studio then loaded `nvidia/nemotron-3.5-lightning` Q4_K_M at 65,536 context and four parallel slots. LM Studio reported 22.83 GiB allocation; `nvidia-smi` attributed about 24.1 GiB to `llama-server`. Final idle co-residency left about **35 GiB `MemAvailable`**. The ordering constraint is now directly reproduced: starting Nemotron first left 87.38 GiB CUDA-visible memory, just below Spark-Fast's 87.62 GiB preflight request. The stable order is therefore **Spark-Fast first, Nemotron second**; the existing `lmstudio.service` already waits for Spark-Fast health.

| Gate | Result | Evidence |
|---|---|---|
| Spark-Fast identity and chat | Pass | `/v1/models` exposed `spark-fast`; the direct completion returned `SPARK_FAST_FIVE_READY` |
| Five simultaneous Spark-Fast sessions | Pass | 5/5 HTTP 200 with exact responses; 39,418 MiB `MemAvailable` low-water; vLLM preemptions remained zero |
| Nemotron raw chat | Pass | `/v1/models` exposed `nvidia/nemotron-3.5-lightning`; 512-token-budget request returned `NEMOTRON_READY` |
| Simultaneous Qwen plus Nemotron generation | Pass | Both exact responses completed together; 36,057 MiB `MemAvailable` low-water; zero new kernel allocation errors |
| LiteLLM `spark-fast` route | Pass | Standalone LiteLLM was healthy and returned `LITELLM_SPARK_FAST_OK` |
| Hermes Spark-Fast route | Pass | Explicit `custom:spark-fast` one-shot returned `HERMES_SPARK_FAST_OK` |
| Hermes Nemotron route | Pass | Explicit `custom:spark-lmstudio` one-shot returned `HERMES_NEMOTRON_OK` |
| Telegram and Discord configuration | Pass without outbound message | Telegram logged a current polling connection. Discord is enabled, the YouTube channel override selects `custom:spark-fast`/`spark-fast`, and the gateway process held an established TLS connection to the current `gateway.discord.gg` address. No representational test message was sent. |
| YouTube Learning Center | Pass | Live `/api/health` reported `local-vllm`; its real `LocalVllmAdapter.feedback` tool-call path returned schema-valid non-empty feedback through direct Spark-Fast |
| Signal Desk / Social Capture | Pass | Live `/api/health` passed; AI consolidation against a temporary copy of the sample queue completed in `live-spark-fast-validation` mode without touching the authoritative queue |

One `NV_ERR_NO_MEMORY` kernel event occurred at 01:01:04 IST during LM Studio's initial `--gpu max` load. The model finished loading five seconds later, both APIs remained healthy, later five-session and simultaneous dual-model requests passed, and the simultaneous generation window produced no new kernel error. Record this as a **recoverable startup warning**, not a zero-error load receipt. If it repeats or either service becomes unstable, keep the five-session Spark-Fast profile and unload/reload Nemotron rather than shrinking the verified KV pool silently.

The following three-run benchmark used the same 180-word local-first prompt for both models, one warm-up per model, 512 maximum completion tokens, and serial requests while **both models remained resident**. Every measured request reached the 512-token cap. Rates are completion tokens divided by wall-clock HTTP time and include reasoning tokens; they are not isolated decode-only engine counters and are not interchangeable with the standardized headline table.

| Model | Run 1 tok/s | Run 2 tok/s | Run 3 tok/s | Median tok/s | Co-resident configuration |
|---|---:|---:|---:|---:|---|
| `spark-fast` | 76.549 | 81.173 | 75.125 | **76.549** | 262,144 context, 18 GiB FP8 KV, five sequences |
| `nvidia/nemotron-3.5-lightning` | 64.013 | 64.404 | 64.325 | **64.325** | 65,536 context, four parallel slots, GPU-max Q4_K_M |

Configuration backup: `/home/snknitin/ai/services/qwen35/compose.yaml.pre-five-sessions-20260926-005337`. The live file remains `/home/snknitin/ai/services/qwen35/compose.yaml`.

### FirstSpark permanent Nemotron 1M × 1 profile — 2026-09-26

The enabled user unit `/home/snknitin/.config/systemd/user/lmstudio.service` now persistently loads `nvidia/nemotron-3.5-lightning` with `--context-length 1048576 --parallel 1`. Its existing Spark-Fast readiness wait and loopback-only port `127.0.0.1:1234` are unchanged. A five-second guard after `lms daemon up` prevents the CLI executable-update race described below. The previous 65,536-context unit is preserved at `/home/snknitin/.config/systemd/user/lmstudio.service.bak-20260926-104829`; the pre-guard 1M unit is preserved at `/home/snknitin/.config/systemd/user/lmstudio.service.bak-20260926-110435-start-race`.

| Gate | Result | Evidence |
|---|---|---|
| Persistent configuration | Pass | `systemd-analyze --user verify` passed; the enabled live unit contains the post-daemon guard followed by `--context-length 1048576 --parallel 1` |
| Actual backend arguments | Pass | Live `llama-server` command contained `--ctx-size 1048576 --parallel 1` with F16 K/V cache and KV offload |
| Raw model identity and completion | Pass | `/v1/models` exposed `nvidia/nemotron-3.5-lightning`; a 400-token-budget request returned `OK` with `finish_reason=stop` (21 prompt, 141 completion, 136 reasoning tokens) |
| Co-resident memory | Pass with startup warning | `llama-server` used 30,617 MiB alongside Spark-Fast's 48,170 MiB; idle `MemAvailable` was 27,569 MiB, above the 10 GiB safety floor |
| Existing services and Hermes route | Pass | Spark-Fast and standalone LiteLLM remained healthy. Hermes's live `spark-lmstudio` entry was raised from 65,536 to 1,048,576, both Hermes services restarted, Hermes's own config parser returned `1048576`, and an explicit route returned `HERMES_NEMOTRON_1M_OK`. |
| Driver/kernel gate | Warning | One recoverable `NV_ERR_NO_MEMORY` occurred at 10:49:04 IST during the `--gpu max` load. The model completed loading two seconds later and the API test passed. Treat a repeat plus instability as a stop condition, not as an error-free start receipt. |
| Unload recovery | Pass | Nemotron was unloaded after the initial qualification while the service stayed enabled. `MemAvailable` recovered to 60,444 MiB; only Spark-Fast remained GPU-resident; the GPU was 49 °C, 12.48 W, and 0% utilized. |
| Requested running state | Pass | The corrected controlled restart completed on its first attempt with `NRestarts=0`. LM Studio, Hermes Gateway, and Hermes Serve were active; Spark-Fast and LiteLLM were healthy; `MemAvailable` was 28,703 MiB. |

This gate proves that the permanent profile loads and serves at 1,048,576 configured context with one slot; it is not a million-token prompt-quality benchmark. The earlier 65,536 × 4 throughput row remains the latest measured Nemotron speed result and must not be relabelled as a 1M benchmark.

At 10:59:50 IST, the first user-issued start failed because systemd attempted the next `lms` command while the CLI executable was being replaced after `lms daemon up`; the exact error was `Failed to execute .../lms: Text file busy`. The existing `Restart=on-failure` recovered automatically, but the initiating terminal correctly reported the first failed job. The permanent five-second post-daemon guard removes that immediate execution race. A controlled restart at 11:06 ran the guard, loaded the model once, reached the API without a systemd retry, and produced no new `Text file busy` or `Failed to start` event. Hermes's previous 65K display was a separate stale static value in `/home/snknitin/.hermes/config.yaml`, not evidence that the live LM Studio backend had remained at 65K; that authoritative metadata is now 1,048,576. Its prior config is preserved at `/home/snknitin/.hermes/config.yaml.bak-20260926-110435-nemotron-1m`.

#### SparkFast orphan-request guard — 2026-09-26

An automatic Hermes title-generation request continued decoding through SparkFast after its user turn had ended and its client connection had disappeared. It produced sustained GPU load with `num_requests_running=1`, no waiting requests, zero established port-8000 clients, and a steadily growing KV allocation. Because this vLLM chat-completion request exposed no usable cancellation endpoint, the controlled recovery stopped Hermes, unloaded Nemotron, restarted only `vllm-spark-fast`, waited for SparkFast health, reloaded Nemotron in the required second position, and restarted Hermes. The final two-sample audit reported `running=0`, `waiting=0`, 0.000% KV use, 0% GPU utilization, and an idle 1,048,576-context/one-slot Nemotron.

Hermes automatic LLM title upgrades are now disabled with `auxiliary.title_generation.enabled: false`; ordinary chats and the other explicitly configured auxiliary jobs remain enabled. The previous config is preserved at `/home/snknitin/.hermes/config.yaml.bak-20260926-112026-disable-title-generation`.

Two manual commands are installed in `/home/snknitin/.local/bin`:

```bash
spark-gpu-audit
spark-clear-orphans --confirm
```

Always run `spark-gpu-audit` first. It samples request counts, KV growth, port-8000 clients, LM Studio state, and GPU activity twice over ten seconds. `spark-clear-orphans` refuses to run without `--confirm`, exits without restarting when no requests remain, refuses when an established client exists, and rechecks for fifteen seconds before recovery. It is deliberately manual: no timer or unattended self-healing restart may interrupt a legitimate long request.

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
