---
updated: 2026-10-13
status: qwen27b-operational-qualified
---

# SparkFast and Qwen 27B capacity comparison

Names: `spark-fast` was renamed on 13 Oct 2026; see [[Model And Provider Names]].

Native Qwen27B was qualified and published in the FirstSpark Hermes catalog at 00:06 IST on 13 October 2026. Four isolated real Hermes research/coding sessions, the reviewed pressure observation and post-restart API checks passed. Qwen 3.6 35B-A3B (`qwen3.6-35b-a3b`) remains unchanged and remains the default. The earlier 240K test's strict zero-global-swap failure is retained; publication followed a documented review and a separate monitored qualification. The real main-profile native request also passed:262K context,7200second request/stream settings, no fallback or output-token cap. Authenticated Windows UI observation, controlled reboot and extended soak remain separate checks.

| Property | Qwen 3.6 35B-A3B now | Earlier Qwen27B Q8 proposal | Selected Qwen27B Q4 target |
|---|---|---|---|
| Model | Unsloth Qwen3.6-35B-A3B-NVFP4, MoE | Unsloth Qwen3.8-27B UD-Q5_K_XL, dense | Same Q5 weights |
| Runtime | vLLM | Native llama.cpp | Native llama.cpp |
| Per-request ceiling | 262,144 tokens | 262,144 tokens | 262,144 tokens |
| Concurrent requests | Eight scheduled, sharing a global pool | Approximately two uncapped full-context requests under admission | Four independent contexts allocated; four 240K requests and four isolated Hermes sessions completed |
| Cache | FP8, explicit 18 GiB | Q8 K/V, shared 524K allocation, approximately 17 GiB attention cache | Q4 K/V, separate 4 x 262K allocations, approximately 18 GiB attention cache |
| GPU-attributed process memory |48,820MiB /47.68GiB| Not measured locally |42,091MiB /41.10GiB during the23:14IST long-test snapshot; system memory is a separate metric |
| Full-context capacity | Startup reports 1,588,632 cache tokens / 6.06 full-context equivalents | Two full contexts | Four 262K slots allocated; four 240K-input requests tested below each ceiling |
| Primary advantage | Efficient shared-service batching; existing mixed-load tests | Lower context-cache compression risk | More independent long-context agents within the selected memory budget |
| Primary limitation | Eight full 262K requests exceed shared cache; potential scheduling/preemption | Lower full-context concurrency | Greater long-context accuracy risk; expensive cold prefill; broad reasoning-quality comparison remains unmeasured |
| Performance evidence | October1 five/six/eight-sequence comparisons exist | No local inference comparison | Four 100K batch approximately 13.5 minutes; four 240K batch approximately 44.7 minutes, all responses correct; strict global-swap gate failed |

Uncapped output means no separate generation cap is imposed. It does not remove total context limits, stop tokens, client timeouts or contention. Saved Hermes sessions are distinct from simultaneously active model requests. FP8 cache is not identical to llama.cpp Q8_0; these are different models, formats and serving engines. Smaller active parameter count primarily reduces compute, not the requirement to store the full MoE checkpoint. Neither parameter count nor Q5 precision proves superior reasoning on the user's tasks.

## Why the same cache budget holds different numbers of contexts

At 19:31 IST on 12 October, the installed SparkFast checkpoint config and the downloaded Qwen GGUF metadata were read directly. SparkFast has 40 main layers, of which 10 use full attention, with 2 KV heads of dimension256. Qwen27B has 64 main layers plus one MTP layer; 16 main layers use full attention, with 4 KV heads of dimension256. The pinned llama.cpp Qwen35 loader confirms the every-fourth-layer layout and separate MTP layer.

Main full-attention cache size is approximately tokens x full-attention layers x KV heads x head dimension x 2 (K and V) x bytes per stored value. Thus the main Qwen attention cache stores (16 x 4)/(10 x 2) = **3.2 times as many values per token**. MoE active parameter count is not the KV sizing rule.

| Main attention cache only | Bytes per token | One262K context | Four 262K contexts |
|---|---:|---:|---:|
| Qwen 3.6 35B-A3B FP8 | About10 KiB | About2.5 GiB | About10 GiB |
| Qwen27B Q8_0 | About34 KiB | About8.5 GiB | About34 GiB |
| Qwen27B Q4_0 | About18 KiB | About4.5 GiB | About18 GiB |

These are explanatory main-attention estimates, not total process allocations. MTP, recurrent states, checkpoints, alignment and runtime buffers are additional. The native Q8_0 format stores34bytes per32values and Q4_0 stores18bytes per32values, including scales. Qwen 3.6 35B-A3B's measured engine capacity remains the stronger number: 1,588,632 tokens in its configured18GiB pool, approximately6.06 full contexts.

### Can Qwen also share its cache?

Yes. The pinned binary supports `--kv-unified` and `--kv-unified-per-slot 262144`; shared storage still tracks requests separately and does not mix conversations. The earlier Q8 proposal already used a shared524,288-token pool across four scheduler slots. It can hold a mixture such as four 100K inputs with bounded outputs, or two near-full contexts. Our conservative admission policy reserves262K when output is uncapped, so that pool admits only two such requests. Four simultaneous full contexts require1,048,576tokens regardless of whether storage is shared or separate; sharing alone cannot halve the memory needed for four unrelated full histories.

A unified Q4 pool of1,048,576tokens is technically another option, with approximately the same worst-case main-attention allocation as four independent Q4 slots. It does not eliminate the Q4 accuracy tradeoff. The selected installation remains four independent Q4 slots for a clear per-request capacity target; no live configuration was changed for this explanation. A smaller shared Q8 pool is preferable only if the workload accepts a lower total active-context budget, bounded output reservations or additional queuing.

### Actual Qwen baseline allocation, evening qualification

The completed model loaded successfully and passed plain responses, tool round trips and four overlapping short streams. Allocation logs showed18,569.94MiB GPU weights,994.63MiB host weights,18,432MiB Q4 KV,598.50MiB recurrent state, and approximately4.1GiB GPU compute buffers. Short-test memory minima were13.26–14.09GiB, below the original 16 GiB target; these trials were stopped before long-context testing or publication.

Pinned CUDA source explains the large fixed buffer: `fattn.cu` chooses F16 MMA for larger query batches, and `fattn-common.cuh` reserves temporary F16 copies of K and V. At this total context that is approximately 4 GiB. A unified pool with the same token capacity does not remove it. Microbatch128→64 reduced compute storage by only44.5MiB. The selected profile restored256 for prompt throughput, reduced recurrent checkpoints from two to one, and disabled the optional saved-prompt RAM cache. Its disclosed minimum is12GiB with an 8 GiB emergency stop and long-test swap guards; MTP remains off because the baseline did not meet its 18 GiB eligibility gate. The later reviewed operational qualification passed as detailed below.

That revised trial passed four 100K-input requests at22:42IST: all four checkpoint-retrieval answers and completion/concurrency gates passed, aggregate actual usage401,592tokens, minimum available memory14.65GiB, and zero additional swap-out. The cold batch took approximately 13.5 minutes. These results and the October1 SparkFast mixed-workload figures use different prompts and cannot be used as a matched speed comparison. SparkFast independently returned the expected short response in0.547seconds during the native100K run; this is a coexistence check, not a heavy mixed-load benchmark.

The four 240K-input test finished at approximately 23:27 IST. All four retrieval answers were correct and ended normally; observed busy slots reached four, aggregate actual usage was 961,716 tokens, and minimum available memory was 13.747 GiB. The batch took 44.7 minutes; first output (including reasoning) ranged from approximately10.7 to43.8minutes; first visible answer content arrived after25.8 to44.5minutes across the four requests. These cold-input measurements demonstrate the substantial latency cost of this workload, even when its contexts fit.

The original receipt remains **failed** because the strict global-swap gate observed 44 pages, or 176 KiB, written in one sampled interval. Available memory at that event was 14.415 GiB. This was a host-global counter, so its process origin is unknown. Historical ten-minute `sar` samples displayed 0.00 for memory PSI, and the checked OOM counters were zero; these observations do not reconstruct every moment or prove an absence of all pressure. That initial attempt stopped the new worker for review without publishing the catalog; the later reviewed continuation is described below.

The reviewed follow-up preserved that failed receipt and used preregistered criteria: at least 12 GiB available, an 8 GiB emergency floor, zero worker `VmSwap`, no OOM-counter increase, host and worker full-memory PSI stall fractions at most 1%, and the existing sustained swap-out guard of 8 MiB/s for five seconds. These are engineering criteria for the new observation, not a retroactive pass or universal Linux safety thresholds. Global page counts alone remain diagnostic. See `Qwen Spark Migration/shared-host-memory-review-20261012.json` for pinned receipt hashes and measurement limitations.

Thermal evidence for this qualification comprises 175 snapshots at 15-second intervals: maximum 86°C, zero samples reporting active thermal slowdown, and no sampling errors. This does not prove no throttling between samples or 24-hour stability. The authoritative files are `thermal-samples.jsonl` and `thermal-summary.json` beside the long-test receipts in `/home/snknitin/runs/qwen38-native/qualification-20261012T165724.907854Z/`.

### Completed Hermes and pressure qualification — 13 October

Four isolated Hermes sessions used `spark-qwen38` through admission port 1235 without fallback. The two local-source research tasks passed in 252.8 and 337.3 seconds; the two coding/tool tasks passed in 515.7 and 706.8 seconds, including independent held-out and empty-input checks. These are measured task times, not a matched comparison with SparkFast or a general web-research quality benchmark.

The 767.3-second pressure observation included the Hermes workload and a final 60-second idle observation. It passed with at least 15.115 GiB available, zero worker `VmSwap`, zero global swap-out and zero host/worker OOM-counter increases. Host full-memory PSI occupied approximately 0.000943% of the observation; worker full-memory PSI was 0%. SparkFast's bounded response check completed in 0.128 seconds before and 0.147 seconds after. These small coexistence probes do not measure simultaneous heavy SparkFast load.

The worker was then restarted and passed plain response, tool round-trip and four overlapping stream checks; that short post-restart test retained at least 16.43 GiB available. Both Qwen units are enabled and active, and admission health returned `accepting:true`. Six Hermes configs received the provider with defaults preserved. The recorded stage is `qualified_and_published`; the real main-profile native request subsequently passed (`production-route-v2.json`). Authenticated Windows UI observation, controlled reboot and extended real-use soak remain pending. Evidence: `/home/snknitin/runs/qwen38-native/qualification-20261012T182033.027090Z/`, including `q5xl-four-986efb09a85c/receipt.json`, `reviewed-pressure-qualification.json`, `short-after-restart.json` and `hermes-catalog-apply.log`.

## Latest Qwen 3.6 35B-A3B settings (verified values)

Effective container command, current Compose and latest boot log agree:

```text
model: unsloth/Qwen3.6-35B-A3B-NVFP4
revision: 739af1e7aac320af1682ed1e0cce369af4c5265d
max-model-len: 262144
max-num-seqs: 8
kv-cache-memory-bytes: 18G
kv-cache-dtype: fp8
max-num-batched-tokens: 8192
gpu-memory-utilization: 0.60
chunked-prefill: enabled
async-scheduling: enabled
speculation: MTP, 2 tokens
```

Live GPU-process allocation was 48,820 MiB = 47.68 GiB. Startup measured 24.84 GiB model loading and 18 GiB KV allocation; remaining attributed memory is runtime/state/workspace overhead. The current boot reported 1,588,632 cache tokens and 6.06x concurrency at 262,144 tokens. Dividing evenly across eight gives about 198,579 tokens each, an illustration rather than a per-session cap. Requests can grow to 262K individually while the shared pool permits.

## What changed on October 1

The saved audit tested five, six and eight sequences twice using the same 19-request mixed workload. Eight reached eight running requests, with zero request/structured-output failures, zero preemptions and a maximum 17.39% KV usage. Five versus eight completed 15.73 versus 15.70 requests/minute, effectively unchanged. Interactive p95 time to first token improved from 21.92 to 19.67 seconds, about 10%. These are historical synthetic mixed-load results, not present-day guaranteed latency or eight-full-context proof.

The initial audit preferred five on aggregate-throughput grounds. A later explicit user choice selected eight for availability across concurrent services; `capacity-live-8-2026-10-01.md` supersedes `capacity-final-2026-10-01.md` despite the latter's name.

The cache stayed at 18 GiB. The utilization setting changed from 0.72 to 0.60 to relax this image's startup free-memory check while LM Studio was resident. It did not reduce the model's precision or explicit cache allocation. The current boot explicitly logs that the fixed cache allocation bypasses utilization-based cache sizing.

## Why 47 GiB and almost 100 GB can both appear

The October 1 five-sequence audit recorded three different quantities: about 48,176 MB for the vLLM process, 30,617 MB for LM Studio, and 97,500 MB whole-system unified memory used. Its SparkDash GPU allocation total was 78,793 MB. Thus the documented near-100 GB figure was whole-system usage, not SparkFast alone. Without the original screenshot, this cannot prove which metric the user remembers.

There was also an older August profile with automatic 58.52 GiB KV allocation alongside 24.84 GiB model memory. Pinning KV to 18 GiB removed approximately 40.52 GiB of cache reservation. That predates the October five-to-eight change. September's five-sequence profile already used approximately 48 GiB for SparkFast.

DGX Spark uses unified CPU/GPU memory. GPU-process allocation, total GPU-attributed memory and Linux system memory used are different measurements. This session also stopped LM Studio/Nemotron, releasing its approximately 30 GiB process residency. Eight requests do not load eight model copies.

## Evidence and usage

Remote authority: `/home/snknitin/ai/services/qwen35/compose.yaml`; saved audit: `/home/snknitin/ai/services/qwen35/audit/`, including `capacity-live-8-2026-10-01.md`, `capacity-final-2026-10-01.md`, `benchmark-comparison.csv`, raw JSON runs and before/after Compose snapshots. Live evidence: container effective command, current startup logs, nvidia-smi and vLLM metrics. No inference load or restart was introduced for this check.

Keep Qwen 3.6 35B-A3B (`qwen3.6-35b-a3b`) as the default shared-service route; select `spark-qwen38` explicitly for the qualified dense Qwen service. Expect shared-device contention when both generate heavily. Eight Qwen 3.6 35B-A3B scheduler positions plus four Qwen positions are not twelve guaranteed full-context, full-speed sessions. Follow [[Qwen 3.8 27B Native Spark Setup Tutorial]] for use, remaining verification and recovery.
