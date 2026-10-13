# Qwen desktop regression evidence — 12 October 2026

All times below are IST (+05:30). This audit used read-only API, log, Windows-event, container-metadata, and source inspection. It did not load a model, run inference, change settings, stop a service, or alter any application. The two JSON evidence files contain operational metadata, not conversation contents or credentials.

## Conclusion and limits

The desktop problem is real. The preserved 28 September investigation measured active Qwen inference competing with Windows desktop rendering, with recovery when inference stopped. Current logs additionally show frequent Qwen runner reloads with incompatible client context sizes, long waits ending in client disconnects, and an October 6 NVIDIA TDR event during Qwen serving.

These observations support moving the foreground Qwen inference off the Windows display GPU. They do **not** establish that every Qwen request causes visible lag, that a particular Ollama release introduced the problem, or that the first occurrence was exactly three to four weeks ago. No matched pre-regression desktop responsiveness benchmark survives in the inspected evidence. A successful HTTP 200 also does not prove a whole streamed task completed correctly.

Removing Qwen only from Hermes does not eliminate all Windows inference: **Fresh Brief currently runs scheduled Qwen requests on the same Windows Ollama server.** The user's later final decision explicitly retains that dependency unchanged and moves only Hermes Qwen work to Spark. This relieves desktop load from those migrated Hermes requests; it does not promise that Fresh Brief or another deliberate Windows GPU workload cannot cause contention.

## Current Windows snapshot

| Item | Observed value |
|---|---|
| Ollama `/api/version` | `0.40.0` |
| Current server startup | 8 October, 09:43:01 |
| GPU | NVIDIA RTX PRO 5000 Blackwell, 48,935 MiB |
| NVIDIA driver | `596.59`; same version as September 28 DxDiag (`32.0.15.9659`) |
| Idle sample | 3% GPU, 4,072 MiB allocated, 33.49 W, 53°C |
| `/api/ps` | No loaded models at audit time |
| Installed Qwen tag | `qwen3.8:27b-q4_k_m`; old `qwen3.8:27b` absent from live tag list |
| Qwen manifest | `25b843619e944cd0ae6069f94ff4e5e26a16e109ccbc0a66a0f05979ed70098e` |
| Qwen model layer | `f5f1dd8920d417aac2718b0bda3403da274301efdd6760b4f0f4b864ff2ad57d` |
| Qwen tag modified | 29 September, 17:02:45 |
| User environment | `OLLAMA_NUM_PARALLEL=1`, `OLLAMA_MAX_LOADED_MODELS=1`, `OLLAMA_FLASH_ATTENTION=1`, `OLLAMA_KEEP_ALIVE=5m` |
| Other environment | No nonempty persistent `OLLAMA_CONTEXT_LENGTH`; no `OLLAMA_KV_CACHE_TYPE` override |

Environment values are persistence settings; actual logged runner arguments are stronger evidence of per-request behavior. The September 28 65K trial is **not** the current operating limit: October logs show actual 262,144-token runners and prompts reaching approximately 160K.

The other installed tags are three distinct Gemma models: `gemma4:26b-a4b-it-qat`, `gemma4:31b-it-qat`, and `gemma3:4b`. Distinct sizes are not duplicate copies of one model. Hermes picker cleanup should distinguish duplicate route entries from intentionally retained different models.

## Dated evidence

| Date | Evidence | What it establishes |
|---|---|---|
| September 13–17 | Retained Ollama 0.34.0 log has 3,207 HTTP-200 chat-completion entries and 42 HTTP-500 entries; largest logged prompt 159,933 tokens | Heavy usage and some errors already existed then; neither smooth desktop operation nor an exact onset can be inferred |
| September 24 | Retained startup records show 0.34.0 at 08:56 and 0.34.3 at 08:58 | Runtime changed in the reported time window; temporal correlation alone does not identify cause |
| September 28 | Preserved active/idle comparison: `llama-server.exe` averaged 81.37% and peaked 94.48% on the shared GPU 3D engine; roughly 75–99% overall GPU, ~300 W; canceling inference promptly reduced load while weights remained resident | Direct evidence of inference/display contention, rather than merely loaded weights |
| September 28, 18:31–18:35 | Re-read 173-row 65K CSV: full-file peaks 99% GPU, 301.72 W, 26,056 MiB total GPU allocation | Lower context reduced VRAM use but did not remove compute contention; prior 26,017 MiB figure described the narrower active-task window |
| October 4 | Startup records show 0.34.4 → 0.35.0 → 0.35.1 | Multiple runtime versions were used; no controlled version A/B establishes benefit magnitude |
| October 6, 20:28 | NVIDIA TDR events and Ollama GPU discovery failures overlap; see below | Real GPU instability occurred during Qwen serving |
| October 8, 09:42–09:43 | Upgrade log and server startup record show update followed by 0.40.0 | Current Ollama update is verified |
| October 8–12 | 245 Qwen runner launches: 107 with 16,384 context, 138 with 262,144; all map to the same Qwen layer | Repeated runtime recreation is current, not merely historical |
| October 12 | 127 Qwen launches in retained current log: 62 at 16K, 65 at 262K; long waits and canceled loads still present | Update has not eliminated waiting/reload behavior |

Counts are from the retained files at audit time, not a complete lifetime history. The current log ends with requests around 14:13 on October 12. Older log archives and current rotation have gaps.

### October 6 GPU event correlation

- `nvlddmkm` event 153 at **20:28:24.282**: `UCodeReset TDR occurred on GPUID:200`; event 14 has the same timestamp.
- Event 153 at **20:28:36.709**: `Resetting TDR occurred on GPUID:200`.
- Ollama 0.35.1 logged GPU-discovery timeouts at **20:28:20.835**, **20:28:22.584**, and **20:28:25.585**, then attempted a Qwen 262K load at **20:28:25.632**.
- Windows recorded unclean-reboot event 41 at **20:32:49**. Event 6008 followed. There is also an October 2 unclean reboot, but no matching NVIDIA event in the inspected set establishes its cause.

This is a time-correlated GPU failure. It does not isolate Ollama, GPU scheduling, the driver, another workload, or hardware as the sole trigger. Event 41 itself is a record of an unclean restart, not a root-cause diagnosis.

## Two clients requesting incompatible Qwen contexts

The current `server.log` repeatedly recreates the **same model layer** with different contexts. One example:

| October 12 time | Runner context | Source log line |
|---|---:|---:|
| 10:25:55.260 | 262,144 | 255189 |
| 10:31:15.603 | 16,384; aborted after client disconnected | 255999 |
| 10:31:16.742 | 16,384 | 256009 |
| 10:31:49.139 | 262,144 | 256342 |
| 10:35:15.907 | 16,384 | 257080 |
| 10:35:26.215 | 262,144 | 257404 |

The 10:31:15 local `/api/chat` request ended **HTTP 499 after 5m22s**. At 09:59:49 a remote `/v1/chat/completions` request ended **HTTP 499 after 1m26s**. Both windows explicitly say `client connection closed before llama-server finished loading, aborting load`. Therefore the following `Load failed ... context canceled` entry is **not by itself a crash**. It proves the client disconnected during the wait; it does not tell us whether a human canceled or a client deadline elapsed.

This alternating launch pattern is consistent with clients forcing the single-slot server to switch runtime context configurations. It adds cold loading and queueing to GPU compute contention. Client-to-every-request attribution and the precise share of latency attributable to reloads remain unmeasured.

### Fresh Brief is a verified additional Windows Qwen consumer

- Live container `fresh-brief` is healthy and uses `OLLAMA_URL=http://host.docker.internal:11434`, `OLLAMA_MODEL=qwen3.8:27b-q4_k_m`.
- Read-only [Fresh Brief health](http://127.0.0.1:8787/api/health) and `/api/data` reported selected Qwen, `busy=false`, and `schedule=twice_daily`.
- [compose.yaml](E:/GIT_ROOT/Projects/fresh-brief/compose.yaml:14) points to Windows Ollama.
- [newsroom.py](E:/GIT_ROOT/Projects/fresh-brief/newsroom.py:71) and [app.py](E:/GIT_ROOT/Projects/fresh-brief/app.py:284) explicitly request `num_ctx: 16384` through `/api/chat`.
- [The scheduler](E:/GIT_ROOT/Projects/fresh-brief/app.py:394) retains the user's 08:00 and 20:00 IST schedule.
- ODS Open WebUI and ODS Perplexica also have `OLLAMA_BASE_URL=http://host.docker.internal:11434`. This proves configured access, not that either produced the observed Qwen calls.

Fresh Brief uses Ollama's `/api/chat` request/response format, structured-output schema and `think` options. **Changing its base URL to LM Studio `/v1` is not a sufficient migration.** A separate tested OpenAI-compatible adapter or a deliberately retained Ollama-compatible remote backend is needed. Preserve its chosen twice-daily schedule and cached editions. Do not silently delete the Qwen Ollama tag while this dependency exists.

## Historical Hermes evidence and scope

The [September 28 investigation](<C:/Users/Nitin Kishore Sai/Documents/Codex/2026-09-28/read-the-attached-hermes-qwen-desktop-2/outputs/hermes-qwen-investigation.md>) found shared tool setup/recovery overhead with both Qwen and a cloud-model control. Qwen produced much more output in the matched window, prolonging local GPU use. The comparison had differing browser prerequisites and provider accounting, so it was not a clean model-regression benchmark.

The [applied fixes](<C:/Users/Nitin Kishore Sai/Documents/Codex/2026-09-28/read-the-attached-hermes-qwen-desktop-2/outputs/applied-fixes.md>) addressed correction handling, hidden background-review routing and long-job workflow guidance. They explicitly did not establish that sustained display-GPU inference became smooth. Whether those local Hermes patches survive the current checkout requires the separate current Hermes audit.

## Evidence files and repeatable read-only checks

- [Sanitized Ollama log metadata](work/qwen-regression-audit-2026-10-12.json): per-file versions, dates, runner starts, load failures, status counts and largest prompt counts.
- [Sanitized Windows event metadata](work/qwen-windows-events-2026-10-12.json).
- Current original logs: `C:\Users\Nitin Kishore Sai\AppData\Local\Ollama\server.log`, `server-3.log`, and `upgrade.log`. Line references above apply to the inspected file before later rotation.
- Historical archive: `C:\Users\Nitin Kishore Sai\Documents\Codex\2026-09-28\use-my-windows-desktop-workstation-suddenly\work\ollama-rollback-20260928-135217\`.
- Re-read GPU CSV: `C:\Users\Nitin Kishore Sai\Documents\Codex\2026-09-28\read-the-attached-hermes-qwen-desktop-2\work\qwen65-gpu.csv`.

Run in **Windows PowerShell**; these checks do not send inference:

```powershell
Invoke-RestMethod http://127.0.0.1:11434/api/version
Invoke-RestMethod http://127.0.0.1:11434/api/ps | ConvertTo-Json -Depth 5
nvidia-smi --query-gpu=name,driver_version,memory.total,memory.used,utilization.gpu,power.draw,temperature.gpu --format=csv
Invoke-RestMethod http://127.0.0.1:8787/api/health
```

For the selected scope, migration acceptance must demonstrate an active Spark Qwen response and the actual Hermes endpoint/model while retaining Windows Ollama/Fresh Brief. A Windows GPU observation during that response is a separate end-to-end check; it cannot be inferred solely from a picker or resident weights. The scheduled Fresh Brief consumer deliberately remains on Windows. See [[Qwen 3.8 27B Native Spark Setup Tutorial]] for the final configuration and measured qualification status.
