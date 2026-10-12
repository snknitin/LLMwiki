---
created: 2026-09-28
updated: 2026-09-28
status: unresolved-partial-fixes-deployed
tags: [hermes, qwen, ollama, windows, gpu, investigation, handoff]
---

# Hermes + Qwen Desktop Lag — Consolidated Investigation And Handoff

**Evidence cutoff: 28 September 2026, 16:48:55 IST (Asia/Calcutta).** Consolidates the original “Hermes + Qwen Desktop Lag: Investigation Handoff,” the cloud control, the referenced orphan-request repair audit, deployed changes, and the subsequent live feature-request test. This document supersedes the original handoff's proposed-next-test and configuration status. Timestamped observations below are not promises about future live state.

## 1. Read This First

**The user's smooth-desktop objective is not achieved.** They report less severe but still definite lag in Handy, keyboard/mouse input, and ordinary Windows use after the Hermes fixes. Their previous experience was smooth while Hermes worked; explaining that regression remains the goal.

What is established:

1. Sustained local Qwen inference contends with Windows display work on the same NVIDIA GPU. Stopping the request dropped GPU load and restored responsiveness in the original investigation. This immediate mechanism does not need another stress test.
2. Large request growth and substantial recovery work also occurred with cloud Codex through Hermes. The phenomenon is **not exclusive to Qwen tool-call parsing**. Cloud smoothness says nothing about Hermes orchestration health.
3. Several real defects/amplifiers were identified: a user-correction/retry-budget coupling; a 600-second nested tool inside a 300-second code-cell deadline; contradictory download-skill instructions; automatic review inheriting the foreground model; and oversized tool results entering context.
4. The correction bug, review routing, long-job guidance, and download skill were changed and tested. These are partial fixes, not a proven repair of all lag.
5. The post-fix coding run still generated sustained work. Its first broad repository listing unnecessarily included **765 `.venv` paths** and added about **15,600 prompt tokens**. At the cutoff it had **56 completed API calls**, a latest/max input of **88,541 tokens**, and was still working.
6. Current local inference still allocates approximately **35 GiB dedicated GPU memory** for the Qwen process. The unchanged 262K context allocates **16 GiB main KV cache**, with another **1 GiB draft KV cache**. Removing wasted rounds does not itself shrink those allocations.

**Monitoring is PAUSED at the user's request to avoid further Astra consumption.** The Hermes task was not stopped, restarted, or steered when monitoring was paused. No final feature-task outcome or live post-fix background-review execution has been verified. Continue from these records with a less expensive model if desired; the investigator did not change the model of this Codex chat.

## 2. User Objective And Boundaries

Restore smooth Windows use while Hermes runs workstation `qwen3.8:27b`, preserving quality, speed, stable route/model identity, context capability, MTP/speculative decoding, and long-goal completion as far as possible. Do not silently trade these away and call the result fixed.

- Do not recreate/change `qwen3.8:27b`, its context, MTP, or stable route without a separately authorized, controlled experiment.
- Do not reinstall ODS or LiteLLM as speculative troubleshooting.
- Do not reintroduce a low main `agent.max_turns`, a short run budget, or a repeated “send continue” requirement.
- Preserve `spark-fast`, existing routes, and unrelated profiles.
- Do not rerun the six-book cloud control, five-minute timeout, or GPU saturation demonstration merely to reconfirm known results.
- Do not interrupt an active user task, inject corrections, restart services, or modify its project while observing it.
- Distinguish model-emitted tool mistakes, infrastructure failures, API retries, user corrections, and useful coding work. A high round count alone does not prove a loop.
- Report facts, inference, and unknowns separately. The precise historical regression onset has not been established.

## 3. Machines, Routes, And Ownership

| Component | Verified role |
|---|---|
| Windows workstation | NVIDIA RTX PRO 5000 Blackwell, about 48 GiB VRAM; drives three monitors and runs native Ollama, Handy, desktop apps |
| FirstSpark | Authoritative Hermes backend/gateway and state; SSH alias `FirstSpark`, user `snknitin` |
| Hermes source | `/home/snknitin/.hermes/hermes-agent`; base commit `fdec926ef54391edcf6caad5f7f6761fdcccdaa2`, dated September 25 |
| Hermes main home | `/home/snknitin/.hermes`; config `config.yaml`, database `state.db`, logs `logs/agent.log` and rotations |
| Hermes services | User services `hermes-serve.service` and `hermes-gateway.service` |
| Desktop RPC | Authenticated backend at `http://100.94.199.98:9119`; existing WebSocket/JSON-RPC interface used for control and observation |
| Workstation Qwen route | Existing private Tailscale HTTPS route directly to workstation Ollama; **bypasses standalone LiteLLM**. Reuse the saved provider rather than inventing a new URL |
| Standalone LiteLLM | FirstSpark loopback `http://127.0.0.1:4000/v1`, serving Spark aliases; not in the workstation Qwen request path |
| SecondSpark Qwen | Alias `qwen38-tp1-second`; LiteLLM forwards to `192.168.100.11:8888`, service/container `vllm-fn-tp1` |
| SecondSpark runtime | Observed 262144 context, 4 sequences, FP8 KV pool 12 GiB, MTP-3; not changed in this investigation |
| ODS | No active ODS component was found responsible for this request/load path. Do not generalize this to every workstation ODS installation described in older vault notes |
| `ylc-searxng` | Independent YouTube Learning Center service; no evidence it caused GPU/display pressure |

`custom:spark-fast` is the name of a provider connection. Supplying model `qwen38-tp1-second` on that connection selects SecondSpark Qwen, not the model named SparkFast.

**Documentation drift:** `Local Setup Index.md` contains older workstation Ollama version/context and infrastructure descriptions. For this incident, use the timestamped live measurements here. The index was not broadly rewritten during this handoff.

## 4. Configuration And Drift Ledger

### Workstation model/runtime preserved

- Ollama `0.34.3`; a bad session also occurred on this build, so a version rollback alone is not a demonstrated solution.
- Model `qwen3.8:27b`, Q4_K_M, reported 27.3B parameters.
- Model digest: `22130167c4c20e20c7b71454612966ca8e8171e9b3cc8ab6ce8aa6cbfec79643`.
- Context 262144; one parallel slot; flash attention enabled; maximum loaded models 1; keep-alive 5 minutes.
- MTP enabled, four draft tokens on workstation. No disable/rebuild/context reduction was applied.
- NVIDIA driver reported by the live Windows capture: `596.59`, WDDM; no driver change was performed during this investigation.
- Model store observed under `D:\LocalLLama\models\ollama`.

### Hermes main profile at deployment

| Setting | Installed default / interpretation | Main profile after fixes |
|---|---|---|
| `agent.max_turns` | Unset resolves to observed 500 iterations per user turn | Unset; no low cap |
| `agent.budget_warning_ratio` | Optional | Unset |
| `agent.run_budget_seconds` | Optional | Unset |
| `agent.api_max_retries` | 3 | Earlier override of 1 removed; default 3 |
| `agent.auto_recovery_cycles` | 5 | 1 remains from earlier diagnostic changes |
| `agent.reasoning_effort` | Configurable | medium; earlier morning backup had low |
| Local stale-stream timeout | 900 seconds | Existing override 180 seconds |
| Code execution timeout | 300 seconds | 300 seconds |
| Code-cell tool-call ceiling | 50 | 50 |
| `goals.max_turns` | Separate goal control | 120, unchanged |
| `delegation.max_iterations` | Separate child control | 250, unchanged |
| Background review | Enabled; unset route inherits selected foreground runtime | Explicit SecondSpark route below |
| Compression auxiliary | Independent selection | SparkFast, low reasoning, 360-second timeout |
| Goal judge auxiliary | Independent selection | SparkFast, no reasoning, 120-second timeout |
| Title generation | Separate from background review | Disabled in main profile |
| Weekly curator | Separate maintenance feature | Do not confuse it with per-turn background review |

Original diagnostic cap 20, warning ratio, and 600-second run budget were removed before the continuation. Do not restore them. An iteration ceiling is per user turn, not a lifetime session limit, but a low ceiling can still prematurely terminate a long task.

Config hashes in chronological order:

- At 15:30, diagnostic API retry override still 1: `be84a604533a76a0f8e62230a9bdce4b86f133cbd55fa873fd632e90d64c0a65`.
- After restoring API retry default; unchanged through cloud control: `6c6653e6e7654208ff1f6432989ac827cd52806efe5b1b272d59e7e859caf8a9`.
- After explicit background-review route: `b56343b0ed39f086b3b2fdeb942bfffd85d4837ce0bee3d85a0005e97454d45c`.

Semantic comparison confirmed that the review deployment changed only its three route fields. Already initialized agents retain settings captured at construction; fresh agents or an intentional idle service restart are needed for relevant runtime changes.

### Saved profile defaults, observed in this session

| Profile | Saved default | Reasoning | Explicit fallback |
|---|---|---|---|
| Main | `spark-fast` | medium | SparkFast |
| Builder | `qwen38-tp1-second` | medium | None |
| Orchestrator | `qwen38-tp1-second` | high | SparkFast |
| Researcher | `gpt-5.6-sol` | xhigh | None |
| Creator | `grok-4.7` | medium | SparkFast |
| Reviewer | `claude-opus-5-5` | medium | None |

Relevant explicit `persist_switch_by_default` values are false. Resumed chats can retain per-chat model overrides. No saved default in this table selects workstation Qwen; the user selects it per chat. Builder/orchestrator/researcher/reviewer already had `agent.max_turns: 100`; this investigation did not add or change those values, and they did not govern the main-profile controls. Do not silently propagate them to main.

## 5. Established GPU/Display Mechanism

Original stop/unload observations:

| Measurement | During local Qwen work | After stopping/unloading |
|---|---:|---:|
| GPU utilization | 75–99% | 3–4% |
| GPU memory | Approximately 39,400 MiB of 48,935 MiB | Approximately 3,660–3,733 MiB |
| GPU power | 298–301 W | About 32–71 W |
| GPU temperature | 85–89 C | 57–71 C while cooling |
| `llama-server` GPU 3D engine | 81% average, 94% peak | Idle after stop |
| CPU | 15% average, 24% peak | Not the measured bottleneck |
| Free system RAM | About 72–73 GB | Not the measured bottleneck |
| Disk activity | 1.3% average | Not the measured bottleneck |
| DPC/interrupt time | Below 1% peak | Not the measured bottleneck |
| FirstSpark-to-Ollama route | About 13 ms total | Not the measured bottleneck |

Desktop Window Manager and inference share the display GPU. Ample system RAM does not prevent GPU scheduling contention. These measurements rule out the listed immediate bottlenecks for the captured event; they do not establish that every possible later symptom has the same cause.

At 15:26, after the user stopped a frozen run, an idle-runner check preceded `ollama stop qwen3.8:27b`. GPU allocation fell from 39,457 to 3,733 MiB, utilization to 3%, and power to about 32 W. That unloaded the unchanged model; it was not a model repair.

### Post-fix live allocation, 16:33 IST

| Counter | Observation |
|---|---:|
| NVIDIA total GPU allocation | 39,545 / 48,935 MiB = 38.6 / 47.8 GiB, about 81% |
| Qwen `llama-server`, PID 61184 | 34.96 GiB dedicated + 1.30 GiB shared GPU memory |
| Desktop Window Manager, PID 2324 | 2.50 GiB dedicated |
| Handy, PID 18964 | 0.78 GiB dedicated |
| GPU utilization / temperature / power | 99% / 88 C / approximately 300 W |
| Ollama `/api/ps` reported `size_vram` | 18,542,692,923 bytes; **not the full process allocation** |

Later instantaneous monitor samples: 16:36:49, 88% GPU / 39,500 MiB / 86 C / 301 W; 16:38:51, 91% / 38,813 MiB / 86 C / 286 W; 16:40:48, 89% / 38,786 MiB / 86 C / 301 W. Do not treat snapshots as sustained averages or as proof of thermal throttling. Do not infer actual mouse responsiveness from utilization alone; the user's direct report is the acceptance signal.

### Runtime allocation from the current startup log

| Allocation | GPU size |
|---|---:|
| Main model weights | 15,339.44 MiB |
| Main KV cache, f16 K/V, 262144 context | 16,384 MiB |
| Recurrent state | 748.13 MiB |
| Main compute buffer | 378.02 MiB |
| MTP draft KV cache | 1,024 MiB |
| Draft compute buffer | 324.02 MiB |
| Additional vision compute buffer observed | 248.10 MiB |

Additional allocations/overheads exist. Windows per-process counters and NVIDIA total allocation need not sum exactly. The original handoff loosely described roughly 39.4 GB as the loaded-process footprint; current evidence separates total device allocation from the approximately 35 GiB Qwen process. Do not add GiB, decimal GB, and MiB as if they were identical.

## 6. Original Qwen Task And Cloud Control

Original Qwen session: `20260928_145704_132060`. The exact initial request was recovered from the database rather than guessed. It requested six Anna's Archive books, followed the existing skill, preferred `.gl` then fallback domains, cleared staging, and transferred to Windows. It contains EPUB annotations and a later PDF request; preserve this ambiguity when describing the control.

Cloud session: `20260928_154149_8643a1`, UI session `819cf8e9`, `gpt-5.6-sol` / `openai-codex`, medium reasoning, normal tier, same default-profile Hermes desktop backend. Started at 15:41:49, after the user asked us to wait for their separate book-repair task to finish. No low turn cap and no investigator steering were injected.

Exact prompt SHA-256: `cb4918a03d9ceb5f2dbb615f278c1b61945cd89724dc14db5b1dd5f84a774492`.

### Matched approximately five-minute window

| Measurement | Historical local Qwen | Cloud Codex |
|---|---:|---:|
| Cutoff | Response 23, 319.3 seconds | Response 19, 318.4 seconds |
| Completed API/model calls | 23 | 19 |
| Initial prompt | 20,140 | 17,238 |
| Prompt at cutoff | 41,920 | 42,136 |
| Prompt growth | +21,780 | +24,898 |
| API-reported output | 17,317 | 4,578 |
| Emitted top-level tool calls | 27 | 21 |
| Tool results returned before cutoff response | 26 | 20 |
| Cumulative input tokens | 728,947 | 572,821 |
| Cumulative reported cached input | 686,939 | 528,256 |
| Sum of API latency | 253.9 seconds | 156.5 seconds |
| Completed by cutoff | No | No |

The original handoff's 40,708-token checkpoint was round 22; round 23 was 41,920. Its approximately **11,640 MTP-accepted tokens** are a different counter from **17,317 API-reported output tokens**. Preserve both; do not use one to contradict the other. Tokenizers/accounting differ between providers. Cumulative input is not unique context or necessarily recomputed tokens.

Counts are deduplicated across archived and active message copies. An ending model response may emit tools that return after the cutoff, hence calls/results differ. Nested work inside `execute_code` is not counted as additional model-emitted top-level tools.

Qwen's 26 returned tools: 2 skill loads, 15 terminal, 5 browser, 2 writes, 2 reads. Cloud's 20: 3 skill loads, 9 terminal, 7 browser, 1 code execution.

### Full cloud outcome

- Main task ended normally at 16:00:01: **18 minutes 13 seconds**, **39 API calls**, **40 top-level tools**, **12,119 output tokens**, final/max prompt **63,525**.
- Cumulative main input 1,598,715; cached input 1,499,392; summed model latency 374.4 seconds. The rest includes tool time, notably a code-cell timeout.
- Transfer receipts verified six filenames, lengths, and SHA-256 hashes in `G:\Books\Download_from_AA`: **five PDFs and one EPUB** (`Deep Learning on Graphs`). This is not proof of six-PDF completion or exhaustive EPUB unavailability.
- Automatic background review added **3 API calls**, **3,476 output tokens**, max prompt **65,995**, and finished at 16:01:33. Total task plus review: **42 calls**, **15,595 output tokens**, approximately **19 minutes 45 seconds**.
- Review tried to modify the user-owned download skill; the curator/tool guard refused. The investigator later edited it under the user's explicit apply request.

### Control limitations — do not erase these

- Same prompt, not identical environment. Original Qwen had to install the missing managed browser CLI; cloud inherited it but encountered a broken debugger connection.
- Cloud attempted to restart Vivaldi. The user subsequently said they opened the browser with debugging. This externally assisted browser recovery was disclosed; do not call the whole run fully autonomous.
- API retry setting was restored from 1 to default 3 before the cloud test. No corrections were injected into that control.
- Provider tokenization differs. Stored tool-set hashes matched; an inspected stored system-prompt variant differed in model/provider label, but no matched pre-regression prompt baseline exists.
- Both models needed substantial repair work. The control demonstrates shared inefficient behavior, not that every Hermes subsystem is defective or that Qwen cannot add its own overhead.
- The cloud was not expected to stress the workstation GPU; smoothness was not the comparison metric.

## 7. Confirmed Workload Contributors And Separate Symptoms

### Tool readiness and recovery

Original Qwen received missing-browser-CLI errors at 14:57:37 and 14:58:04, attempted wrong setup commands, installed the CLI, then encountered browser IPC timeout. Later searches hit foreground timeouts; it rebuilt scripts and eventually used background processing. Cloud had connection reset, browser target error, undefined `workspace`, and generated-code errors. These are real runtime/generated-code failures; no malformed-tool-call protocol loop has been established.

Qwen responses 19 and 22 generated 6,751 and 3,194 reported output tokens while constructing/reworking scripts—over half the first-window output. A later terminal result contained 29,357 characters, after which input grew 61,445 → 70,912. The continued historical session reached 68 successful Qwen responses and at least 74,349 input tokens, but includes additional corrections/tasks; never present those totals as the clean initial control.

### Nested execution deadline mismatch

Cloud placed 600-second download commands inside a code cell with a 300-second outer deadline. It timed out after **300.07 seconds**, killed the kernel, and lost variables after three nested tool calls. Partial-file inspection and further recovery followed. At 15:57:34 no remaining `aa_*.py` downloader process was found; that observation does not establish an orphaned downloader.

Isolated installed-function tests, with zero model calls:

- Same two-second operation in a kernel with a test-only 0.25-second deadline timed out in approximately 0.26 seconds; next cell confirmed the variable was gone.
- Through real `terminal(background=True)`, a handle returned in 0.031 seconds; the process completed once, exit 0, with persisted `DONE` output, collected through the process interface.

This minimal mechanism test is conclusive; do not repeat a five-minute failure. The deployed mitigation is guidance to use background jobs and durable checkpoints, not an automatic runtime transformation of every foreground command.

### Correction cancellation error

User-visible text: “No reply: the request was cancelled by a new correction on every attempt, so the turn stopped instead of retrying forever. Your last correction is queued as the next message.”

Confirmed cause: Hermes initialized the redirect restart budget from `_api_max_retries`; `agent/turn_iteration_prep.py::apply_retry_restarts` incremented a shared per-turn counter for redirected messages and fallback rebuilds. The diagnostic retry override of 1 therefore reduced user-steering tolerance too. Isolated tests showed second correction stopped at budget 1, fourth at budget 3, with the last correction requeued.

The investigator did not send interfering corrections to the user's sessions. First the override was removed, restoring default 3; then the durable core change below separated pending new user input from no-new-input restart debt. Lack of this error in the later run does not independently prove the fix under live repeated steering; focused regression tests provide that evidence.

### SecondSpark first-chunk delay

The switched old session waited about 125 seconds without output and was interrupted. Both LiteLLM and SecondSpark were running, and SecondSpark health responded. Tiny probes saw the first SSE role chunk after 12.536 seconds directly and 4.110 seconds through LiteLLM, then closed. These are first-chunk transport observations, not full-request health or throughput tests. Inference-time Triton compilation was logged and can contribute to latency; it does not fully explain the earlier wait.

The separate Spark repair session `20260928_152728_113e74` later completed the book conversion/relay task after a Windows command-length error and switching to a transferred script. Example successful round at 15:30:57: 37,722 input, 1,661 output, 57.3 seconds. This steered repair task is not a substitute matched control.

### Background review inheritance

Before deployment, automatic review inherited the live foreground model and conversation, including reasoning settings. Selecting desktop Qwen could therefore cause more local inference after visible completion. Its idle deferral recognizes a managed llama-server endpoint, not every external Ollama route. This explains possible post-turn load, not the initial five-minute expansion. It is separate from title generation and weekly curator scheduling.

## 8. Audit Of The Suspected Morning Orphan-Request Fix

Referenced chat: **“Clarify ODS on FirstSpark”**, thread `01a0e33a-1fda-7cb1-9ed3-8bea33e11fbd`. Its content and deployment commands were read, not inferred from the title.

| Change | Verified evidence | Interpretation |
|---|---|---|
| Social Capture streaming/socket abort/semaphore | Active SHA-256 `7ec7c1c33d5c43992df0f49c823be906d0a27e8c2d2c181bc3ee81fa0c58c44f` matched deployment; diff against backup inspected | New handlers are gated to configured Telegram chat/topic; semaphore is not global Hermes inference control |
| Social Capture prompt surface | All four tool schemas and `TURN_CONTEXT` AST-identical before/after | No enlargement of these prompt definitions by that patch |
| LiteLLM image | 1.81.3 → 1.102.1; compose diff changed only pinned image digest | Relevant to Spark proxy requests, bypassed by workstation Qwen |
| Fallback temporarily removed | Restored from original backup at user instruction | Current intended fallback preserved |
| Hermes core in morning deployment | Clean at `fdec926ef...` before later local fix | No core parser/loop patch from that morning change found |

Relevant backups:

- `/home/snknitin/.hermes/backups/social-capture-cancellation-20260928T102425`
- `/home/snknitin/ai/services/litellm/compose.yaml.bak-20260928T102953-pre-v1.102.1`

The morning change fixed abandoned upstream work after disconnection. Temporal sequence alone does not prove it caused the later desktop regression. There is no demonstrated execution path from its topic-specific handlers to the ordinary desktop book task. The LiteLLM upgrade can still be investigated for a reproducible Spark-only streaming issue; its cancellation acceptance test did not prove every future request healthy. Do not roll it back speculatively to fix the direct desktop route.

## 9. Changes Actually Applied, 16:24 IST

### A. Correction accounting — production code changed

File: `/home/snknitin/.hermes/hermes-agent/agent/turn_iteration_prep.py`.

In the redirected-message restart branch, a pending accepted correction is new input. It no longer increments or fails against the automatic restart counter. `begin_iteration` then drains and appends it through existing role-safe, cache-preserving code. A flag re-armed with no pending correction still consumes the bounded budget. Fallback rebuilds remain bounded.

Core condition:

```python
if _retry.restart_with_redirected_messages:
    _new_correction = agent._has_pending_redirect()
    if not _new_correction:
        restart_count += 1
    if not _new_correction and restart_count > max_retries:
        # Existing stop/requeue path remains.
        ...
    # Existing iteration refund and continuation remain.
```

This does not remove actual API retry limits, fallback guards, the normal iteration budget, or explicit stop behavior. It does not alter model/provider settings or historical messages.

### B. Main-profile background review — configuration changed

```yaml
auxiliary:
  background_review:
    provider: custom:spark-fast
    model: qwen38-tp1-second
    base_url: http://127.0.0.1:4000/v1
```

Applied with the supported `hermes config set` commands. Real installed resolver returned `provider=custom`, the intended model/base URL, chat-completions, `routed=true`, and an available credential. Only these three fields changed in this deployment. Other saved profiles were not rewritten.

**Important limit:** existing Hermes behavior can warn and fall back to the main model if review route resolution fails. The post-fix feature task was still running at handoff, so actual automatic-review requests on SecondSpark have not yet been observed. Do not mark end-to-end routing acceptance complete from YAML alone.

### C. Long-tool instructions — guidance changed

File: `/home/snknitin/.hermes/hermes-agent/tools/code_execution_tool.py`.

The existing tool description now explicitly says nested waits share the cell deadline; a longer nested timeout cannot extend it. Launch long background jobs through normal tool calls outside the cell, checkpoint to files, and check completion in later calls rather than sleeping/polling inside one code cell. No timeout or turn ceiling was lowered/raised, and no new core tool was added.

### D. Anna's Archive skill — reconciled

File: `/home/snknitin/.hermes/skills/research/annas-archive-epub-downloads/SKILL.md`, version 1.2.0 → 1.2.1.

- Unified default any-format download through existing `aa_any.py`; `aa_book.py` only for an explicitly EPUB-only request.
- Explicit current user format/domain preferences override saved defaults. Otherwise sequential domain searches may union candidates because results differ.
- Removed the unsupported universal 350/400-character transport limit and tiny-append workaround.
- Kept title/author validation, actual-file-format detection, title-first `Title (Year) - Author.ext`, Windows-safe names, flat `G:\Books\Download_from_AA` destination, quota handling, and exact manifest ownership/cleanup.
- Made clear that PDF magic bytes/size, page count, and producer alone do not establish title identity.
- Added resumable background jobs and discouraged restarting the user's shared Vivaldi as automatic recovery.
- Preserved existing conversion ownership; the separate conversion skill was not rewritten.

### Deployment and verification

- Main backend/gateway were checked idle before restart: all desktop sessions idle, gateway active agents 0.
- `hermes-serve.service` restarted at 16:24:45 IST; `hermes-gateway.service` at 16:24:48.
- New service PIDs observed: 3393377 and 3393545. Authenticated RPC reconnected; no service journal errors since restart at verification.
- Desktop Qwen was unloaded during deployment. No inference requests were sent by the investigator to deploy/test these fixes.
- **106 distinct focused tests passed:** iteration preparation 11, steering 32, API-call interrupts 3, interrupt propagation 11, code execution 33, execution modes 16.
- New correction tests failed on original code and passed after the patch. They cover repeated identical user corrections, existing automatic-retry debt, unchanged historical prefixes, role alternation, and no-new-input guard behavior.
- Test caveat: interrupt-propagation's lazy import initially hit the installed checkout's real-home I/O guard. A temporary collection-time runtime-import wrapper ran the same 11 unchanged tests successfully. Wrapper removed; no dependency install or production workaround.
- `git diff --check` passed. Live tracked changes are `agent/turn_iteration_prep.py`, `tools/code_execution_tool.py`, `tests/agent/test_turn_iteration_prep.py`. Core is now intentionally locally modified, unlike its pre-deployment clean state.

## 10. Backups, Rollback, And Update Safety

| Backup | Purpose |
|---|---|
| `/home/snknitin/.hermes/backups/config-before-desktop-gpu-circuit-breaker-20260928T144947.yaml` | Before original temporary circuit-breaker settings |
| `/home/snknitin/.hermes/backups/config-before-restore-api-retries-20260928T1535.yaml` | Before removing API retry override 1 |
| `/home/snknitin/.hermes/backups/desktop-qwen-fix-20260928/` | Before correction/guidance/review/skill deployment |

The deployment backup preserves source absolute paths underneath `home/snknitin/.hermes/`. It contains original `config.yaml`, skill, two production source files, and regression-test file. Before rollback, compare later user changes; restore only intended files while idle, then intentionally restart the two Hermes services. Do not overwrite newer config wholesale or restart an active task. Local core patches are not upstreamed and must be reconciled during Hermes updates.

Original handoff text remains preserved outside the vault at:

`C:\Users\Nitin Kishore Sai\Documents\Codex\2026-09-28\use-my-windows-desktop-workstation-suddenly\outputs\hermes-qwen-desktop-lag-handoff-2026-09-28.md`

Its SHA-256 was `cd33e0c8a6e7ff8c1e2acf93f21d6bc47af9a556ef96033f2948a3156d2cf244`; it matched the pre-update vault copy. This consolidated note replaces that vault copy rather than adding another competing incident handoff.

## 11. Post-Fix Feature Test — Latest Observed State

Session `20260928_163050_bdfeb0`, UI `d80d7157`, main/default profile, workstation `qwen3.8:27b`. Started 16:30:50. Fresh request: 1,252 user-text characters plus one screenshot, concerning the YouTube Learning Center Evidence-tab redesign and related behavior. Project: `/home/snknitin/Workspace/GIT_ROOT/Projects/youtube-learning-center`.

The investigator only read logs, database, RPC session state, and Windows counters. No investigator prompt/correction, activation, project edit, restart, or inference request was sent to this task.

| Snapshot | Completed API calls | Latest input | Max input | Cumulative reported output | State |
|---|---:|---:|---:|---:|---|
| First response | 1 | 23,698 | 23,698 | 388 | Initial inspection |
| Round 3 | 3 | 43,016 | 43,016 | — | After dependency-file listing |
| Round 10, 16:33 | 10 | 70,573 | 70,573 | — | Inspection; no logged tool errors yet |
| 16:36:51 snapshot | 17 | 71,345 | 71,345 | 14,821 | Working |
| 16:38:50 snapshot | 20 | 74,504 | 74,504 | 21,599 | Working |
| 16:40:51 snapshot | 23 | 79,476 | 79,476 | 27,978 | First observed patch work/error |
| 16:42:50 snapshot | 34 | 62,714 | 82,464 | 34,224 | Editing and recovering |
| 16:44:49 snapshot | 41 | 73,185 | 82,464 | 42,073 | Editing |
| 16:46:49 snapshot | 49 | 83,537 | 83,537 | 46,925 | Terminal/test work |
| **16:48:55 cutoff** | **56** | **88,541** | **88,541** | **49,541** | **Still working** |

At cutoff: 75 model-emitted tool calls, 74 results before the last response cutoff; cumulative input 3,822,576, reported cached input 3,628,600; summed API latency 928.4 seconds; elapsed to latest completed response 1,074.0 seconds (17 minutes 54 seconds). Returned-tool mix through cutoff: terminal 12, read_file 11, execute_code 24, patch 23, write_file 1, browser_exec 3. Counts include substantial successful work and are not a claim that all rounds were wasted.

### Newly isolated source of avoidable growth

The first code-tool file search excluded root `node_modules` but traversed `.venv`. Result: 852 stdout lines, **765 `.venv/lib` paths**, 49,878 stdout bytes, **51,036 serialized result characters**, no truncation. The next prompt rose **27,405 → 43,016** (+15,611). Additional full-file reads grew context further; a 37,570-character source read preceded another large jump. This is concrete search-scope/output-volume waste, not a demonstrated parser loop.

### Failures observed and recovery

- Three `patch` results reported `old_string` not found: one at 16:40:43, two at 16:42:09. Subsequent reads and successful patches show continued recovery rather than a terminal failure.
- At 16:43:12 a code cell failed with `NameError: name 'terminal' is not defined`. The run continued through a file write and later successful edits. It was not another observed 300-second timeout.
- No `redirect_restart_limit_exceeded` or repeating API transport retry storm was found in inspected logs through cutoff.
- A lower prompt checkpoint was observed during the run; the available summary does not establish the exact pruning/compaction mechanism. Do not invent one.
- No final turn completion, code correctness, full test outcome, or automatic background-review route is certified by this monitor. The feature task may continue after this note.

The user said “Slower, but usable,” then clarified definite lag in Handy, keyboard, and mouse, whereas the ideal/prior setup allowed ordinary desktop use without lag. Later they said the situation had not changed much. That overrides any temptation to label the remediation successful merely because tests passed.

## 12. Facts, Inferences, And Open Questions

### Confirmed

- Immediate contention mechanism; fixed allocations at the preserved runtime configuration.
- Cloud reproduction of substantial prompt growth and tool/recovery rounds.
- Specific execution-deadline and steering-accounting defects, with isolated tests.
- Scope of the suspected morning repair and direct local route bypass of LiteLLM.
- Deployed source/config/skill changes, backups, tests, idle restarts, and successful backend reconnection.
- Post-fix `.venv` listing inflation, continued useful edits plus four logged tool failures, persistent user-reported lag, and incomplete task at cutoff.

### Supported interpretation

Shared tool-readiness/workflow failures, large results, and model-dependent output volume extend local GPU occupancy. Qwen produced more reported output than GPT in the matched book-task window. The code-task listing supplies a specific avoidable cost even without a tool failure. Background-review inheritance can add hidden post-turn work, but cannot explain expansion before task completion.

### Not established

- A matched before/after cause explaining why formerly smooth sessions became slow.
- A Qwen weight regression, an Ollama-version-only regression, or malformed-tool-call protocol loop.
- That the morning Social Capture/LiteLLM cancellation fix caused workstation lag.
- That GPU temperature proves throttling, that allocated VRAM alone causes input lag, or that all cached tokens are recomputed each round.
- That the new review route has actually executed successfully in this user's post-fix run.
- That a coding feature request should finish in as few rounds as a download task. The tasks are different; do not use their totals as a controlled model comparison.
- That guidance alone reliably prevents oversized searches/foreground execution across all models.

## 13. Ranked Causal Conclusion

1. **Immediate mechanism, proven:** sustained inference on the display GPU interferes with desktop responsiveness. This identifies the physical pathway, not the historical trigger.
2. **Best-supported avoidable workload causes:** environment/skill recovery in the book task and oversized repository/tool output in the coding task. Both can inflate requests without broken tool-call parsing.
3. **Supported amplifier:** Qwen's longer output/planning in the matched control, plus repeated large requests, sustains local load. Quality and task completion still need measurement; “more tokens” alone is not failure.
4. **Separate confirmed Hermes defects/amplifiers:** steering/retry coupling, nested cell deadline, and auto-inherited review. These have been addressed to the degree described, with review execution still awaiting verification.
5. **Plausible remaining runtime contributors:** the large fixed context cache, MTP behavior, Windows/NVIDIA scheduling, and possibly temperature-related effects. They have not been isolated as the regression trigger. Earlier 128K use still reportedly lagged, so context alone is not an established explanation.
6. **Weak candidate for the desktop path:** the morning orphan-request change. The verified call paths do not support it as a direct cause; Spark streaming delay remains a separate incomplete investigation.

## 14. Smallest Useful Next Work — Do Not Restart Generic Troubleshooting

First obtain a read-only final status of the feature task when convenient. Separate foreground completion from background review; confirm the review's actual logged model and any fallback warning. This needs no new inference or user-task replay. Monitoring is paused, so a successor must deliberately perform that check.

**Smallest new A/B for the coding finding:** compare the already-captured repository listing with a read-only source-scoped listing on the same repository state (for example tracked project paths via `git ls-files`, plus explicitly needed untracked source files, or `rg --files` with dependency/build/cache directories excluded). Measure relevant file coverage, emitted bytes/lines, and dependence on ignored/untracked files. Do not merely truncate arbitrary output and risk hiding needed source. No model call is required for this first check.

If coverage is retained with much less output, the candidate fix is source-scoped discovery and concise, structured results with detailed spill files available on demand. Put it in existing coding guidance/tool presentation and test it on a small identical read-only discovery task in fresh sessions, changing only that instruction/output policy. Do not modify the active feature task's history or project as part of this experiment. Avoid generic low turn/output limits that weaken long-goal completion.

The earlier skill A/B remains optional: one identical read-only title search under old versus reconciled instructions with the same now-working browser, model, fresh history, and tools. Measure candidate correctness and repair/script reconstruction; do not download six books again. The full cloud control and foreground-versus-background mechanism test are already complete.

For the historical regression, find one known-smooth prior Hermes session/config/runtime receipt and compare initial prompt composition, tools, request count, cache behavior, and sampling/reasoning configuration. Without that baseline, explicitly retain uncertainty about onset. Current profile defaults alone do not prove causation.

Only if these focused workload measures leave unacceptable lag should a separately authorized one-variable runtime A/B be considered. Context/MTP or inference-scheduling/prefill changes can trade memory/speed; do not silently apply them. `draft_num_predict=0` was researched as an MTP-off option but **never applied**. The original handoff cites the Ollama 0.34.3 Modelfile documentation at `https://github.com/ollama/ollama/blob/v0.34.3/docs/modelfile.mdx`; verify current support before any future experiment. Changing context, disabling MTP, moving the model, and reducing batch size together cannot isolate a cause.

Acceptance: a complete representative task with preserved quality/long-goal behavior, reduced avoidable request/output cost, correct review routing, and the user's ordinary desktop use staying responsive. Do not substitute passing unit tests or low sampled GPU utilization for that final acceptance.

## 15. Evidence Files And Efficient Resume

Local investigation workspace:

`C:\Users\Nitin Kishore Sai\Documents\Codex\2026-09-28\read-the-attached-hermes-qwen-desktop-2`

| File under that workspace | Contents |
|---|---|
| `outputs/hermes-qwen-investigation.md` | Detailed cloud comparison and pre-deployment findings, with deployment update at top |
| `outputs/investigation-status.md` | Historical chronological checkpoint; explicitly superseded |
| `outputs/comparison-evidence.json` | Structured control evidence |
| `outputs/applied-fixes.md` | Deployment, tests, backup, and limitations |
| `outputs/applied-verification.json` | Actual route resolution, config diff/hash; old DB activity descriptions are not live work status |
| `outputs/mechanism-test-results.json` | Redirect/deadline mechanism probes |
| `outputs/background-job-test-results.json` | Actual background process execution proof |
| `outputs/feature-test-observation.md` | Initial coding-run and GPU observations |
| `work/feature-run.json` | Latest feature-run snapshot at the cutoff above |
| `work/qwen-evidence.json`, `work/cloud-evidence.json` | Detailed captured traces and original user prompt |
| `work/regression-red.log`, `work/focused-tests.log`, `work/interrupt-tests.log` | Deployment test receipts, including explained bootstrap failure/workaround |
| `work/source/` | Staged source/skill edits |

FirstSpark scratch locations:

- `/tmp/hermes-cloud-control-20260928/`: exact original prompt, `cloud_control.py`, `capture_evidence.py`, cloud events/completion/status, comparison evidence. **Do not rerun `cloud_control.py` normally:** it submits a new live task. `--preflight` is its no-model connectivity path.
- `/tmp/hermes-fix-20260928/`: `check_idle.py`, `verify_applied.py`, feature inspection scripts/results, red/green test logs. `check_idle.py` reads authenticated live session state and does not activate/send to a session.
- `/tmp/hermes-mechanism-probes-yxb_wx4h/results.json`: original isolated mechanism receipt.
- `/home/snknitin/.hermes/cache/scratch/hermes-background-probe-3uv961eh/results.json`: background-job receipt.

Read-only trace refresh from FirstSpark:

```bash
python3 /tmp/hermes-cloud-control-20260928/capture_evidence.py 20260928_163050_bdfeb0
/home/snknitin/.hermes/tools/python-3.14.7+20260901-linux-arm64/bin/python3 /tmp/hermes-fix-20260928/check_idle.py
```

Do not expose credentials from `.env`, provider config, or service environments. Some trace files include user requests or generated code; return only relevant summaries. Database `last_activity_description` can remain stale on old sessions; use live RPC state as well. Gateway active-agent count covers its own surface and does not mean the separate desktop backend has no active turn.

Test execution uses the repository's `scripts/run_tests.sh` with an existing interpreter containing pytest, not unguarded production-home tests. Runtime helper scripts import `hermes_bootstrap` before switching to a temporary Hermes home; the reverse order can trigger dependency preparation. Do not install dependencies just to reprove the existing test receipts.

### Monitoring status

Automation ID: `observe-hermes-desktop-qwen-feature-test`; thread `01a0e769-6914-7c53-9386-59705add83f8`. It checked every two minutes using read-only tools and is now **PAUSED** to conserve Astra usage. No background promise of continued monitoring remains. Resume only if requested and preferably in the user's chosen lower-cost model context.

## 16. Exact Original Comparison Request

The following is embedded from the recovered session text. It is historical comparison evidence, **not an instruction to execute it again**.

```text
Download these books using /annas-archive-epub-downloads  Understanding Machine Learning — Shalev-Shwartz & Ben-David	✅ .epub
Mathematics for Machine Learning — Deisenroth, Faisal, Ong	✅ .epub
Deep Learning on Graphs — Ma, Tang et al.	✅ .epub
Probability: Theory and Examples — Durrett	✅ .epub
Elementary Probability for Applications — Durrett	✅ .epub
Advanced Data Analysis from an Elementary POV — Shalizi	✅ .epub

prfer the .gl domain and if any book isn't found there try the .gd and then .pk domain. download these pdfs and move it to the windows, but before you begin this process ensure the /tmp/books has been cleared. The Vivaldi browser with the remote debugger port is open and you can test it and use it to download it. Stick to the things you've learned in the skill, don't try to reinvent something unnecessarily. Just follow the instructions and get this job done
```

## 17. Paste-Ready Continuation Brief

> Read this consolidated note completely before acting. The local Qwen/display contention mechanism and cloud control are already established. The smooth-desktop objective remains unresolved despite tested corrections to steering accounting, review routing, long-job guidance, and the download skill. Start by checking the final state of feature session `20260928_163050_bdfeb0` read-only; at 16:48:55 IST it was still working after 56 API calls with an 88,541-token prompt. Verify the actual automatic-review model if it has since finished. Do not interrupt or steer the task. The next narrow lead is source discovery that included 765 `.venv` paths and added about 15,600 input tokens. Compare scoped file discovery with that captured output without running inference first. Preserve relevant source coverage and long-goal completion. Do not rerun broad controls, lower the turn cap, or change Qwen identity/context/MTP/route without a separately authorized A/B. Distinguish remaining hypotheses from established facts, and treat user-reported desktop responsiveness as the final acceptance criterion. The Astra monitor is paused to conserve tokens.

## Related Notes

- [[Local Setup Index]]
- [[Spark Hermes Setup Runbook]]
- [[Qwen 3.8 27B Ollama Remote Access Research]]
- [[Hermes LM Link And Workstation Model Routing Research]]
- [[DGX Spark Single-Node Qwen 3.8 Flash Next v0.30 Tutorial]]

## 18. 65K Desktop-Qwen Hermes Control — 2026-09-28 18:32 IST

This is a new bounded control after the workstation Ollama context was reduced. It does not repeat the earlier book-transfer or coding workload.

### Live configuration and drift

- Main Hermes config and the actual Ollama runner both used 65,536 context; /api/ps confirmed context_length 65536.
- The stable FirstSpark -> Tailscale HTTPS -> Windows Ollama route was unchanged.
- MTP remained enabled with draft_num_predict 4.
- Drift: builder, creator, orchestrator, researcher, and reviewer profile YAML files still declare 262,144 for qwen3.8:27b.

### Bounded result

Fresh session: 20260928_183243_190d0a. It read three tiny files, summed eight integers, compared two names, and returned four bullets.

| Measure | Result |
|---|---:|
| Completion | Normal; correct sum 98 |
| Wall duration | 28.7 s, including 5.53 s cold load |
| API/model rounds | 4 |
| Tool calls/results | 5 / 5 |
| Initial prompt | 20,108 tokens |
| Final/max prompt | 21,281 tokens |
| Prompt growth | +1,173 (+5.8%) |
| Output across rounds | 890 tokens |
| Cache hit | 74% |
| Compression | 0 |
| Final context use | 21,281 / 65,536 (32%) |
| Retry/correction or transport failure | None |

One execute_code attempt raised KeyError: content because the model assumed a helper return shape. Qwen immediately retried with native JSON loading, completed correctly, and disclosed the recovered error. This was not an orphaned LiteLLM call, stream failure, or blocked Hermes loop.

### GPU/display-pressure evidence

- Main KV cache: 4,096 MiB; draft KV: 256 MiB. The old 262K run used 16 GiB plus 1 GiB.
- Peak total GPU memory: 26,017 MiB of 48,935 MiB, versus about 38.6 GiB in the earlier 262K feature run.
- Peak Qwen process memory: 22.07 GiB dedicated plus 1.10 GiB shared, versus about 34.96 GiB dedicated plus 1.30 GiB shared before.
- GPU compute still reached 99%, 301.7 W, and 64 C.
- Windows GPU-process WMI made the sampler sparse: nine active-window points. Peak readings are valid; the average is not a fine-grained trace.

### Conclusion

The 65K setting is active and cut total GPU allocation by roughly 12.6 GiB compared with the captured 262K run. It did not produce a blocked request, runaway tool loop, retry storm, or abnormal prompt expansion. It preserves MTP, the stable route, normal completion, and answer quality on this bounded task.

It does not eliminate display-GPU contention: active generation still saturated compute and reached about 302 W. Noticeable keyboard/mouse lag therefore remains plausible even with ample free VRAM. Physical responsiveness must be judged from the user's experience during the exact 18:32:49–18:33:10 generation window.

If lag remains unacceptable, the smallest next A/B is the identical bounded task with one scheduling/load variable changed, while keeping 65K, MTP, model, route, prompt, and Hermes settings constant. Before testing other profiles, reconcile their stale 262K entries so they actually use the intended context.
