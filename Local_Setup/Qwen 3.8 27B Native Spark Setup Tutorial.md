---
updated: 2026-10-13
status: speed-correction-in-progress
tags: [dgx-spark, qwen, hermes, llama-cpp]
---

# Qwen 3.8 27B Native Spark Setup Tutorial

## Speed correction — 13 October 2026

The initial baseline met capacity/tool checks but failed the user's required interactive speed: real Hermes decode measured approximately6–9tokens/second. **DFlash was not enabled** (`speculation:none`); MTP was also skipped. Treat the capacity qualification below as historical evidence, not approval of this baseline for fast interactive work. A matching DFlash2 assistant is now being installed and will be compared on the existing Q5 weights first. Q4 target weights are allowed only if they provide a worthwhile further speed gain.

## Final decision and scope

The user selected **Unsloth Qwen3.8-27B UD-Q5_K_XL served by native llama.cpp on FirstSpark**. It will serve research, planning, tool use and coding in Hermes alongside the existing Qwen3.6-35B-A3B `spark-fast` service. Main Hermes remains on `spark-fast`; Qwen3.8 is an explicit selectable provider.

LM Studio is stopped and disabled on FirstSpark. Its files and Nemotron weights are retained for rollback, but neither is meant to be resident. **Windows Ollama, its existing Qwen copy, Fresh Brief and Windows configuration are unchanged.** This removes Hermes Qwen inference from the desktop GPU; Fresh Brief can still use that GPU intentionally.

Q5 retains more weight precision than Q4. This is a quality preference, not a measured promise that every reasoning answer improves. Native llama.cpp was chosen for explicit service ownership, private API access and direct MTP controls; LM Link is no longer required. [[Qwen 3.8 27B Spark Serving Options]] retains the alternatives and research rationale.

## Find the model now

Refresh the Hermes model picker. Select **FirstSpark Qwen 3.8 27B (llama.cpp)** and **`qwen38-27b-spark`**; the CLI provider is `custom:spark-qwen38`. You can favorite this entry or choose it as the default through Hermes. This installation deliberately preserves your existing SparkFast default and profile defaults. Select the new entry explicitly when resuming a chat that previously used Windows Qwen; saved conversation history was not rewritten.

The provider is installed in the main, builder, creator, orchestrator, researcher and reviewer configurations. Ollama shows exactly `gemma4:31b-it-qat`, `gemma4:26b-a4b-it-qat` and `gemma3:4b`. Removing Windows Qwen from the Hermes picker does not remove it from Ollama or Fresh Brief.

Catalog backup: `/home/snknitin/.hermes/backups/qwen-spark-migration-20261012T183646.228998Z`. Picker verification uses the installed inventory code; authenticated browser rendering itself has not been checked.

## Exact configuration

For the current eight-request SparkFast settings, measured cache capacity, and explanation of its 47 GiB versus whole-system near-100 GB readings, see [[SparkFast And Qwen 27B Capacity Comparison]].

| Setting | Selected value |
|---|---|
| Machine / account | FirstSpark, `spark-07a8`, `snknitin` |
| Model repository | `unsloth/Qwen3.8-27B-GGUF` |
| Pinned model revision | `4ca720788d1e01f1bff70c033e0d0028fd02e502` |
| File | `Qwen3.8-27B-UD-Q5_K_XL.gguf`, 20,876,938,144 bytes |
| SHA-256 | `8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276` |
| Runtime | Official llama.cpp `b11429`, commit `d81235049384534c167caea52b85a694f6103d14` |
| Build | Native ARM64, installed CUDA13.0, compute capability12.1; no driver or system-package replacement |
| Model alias | `qwen38-27b-spark` |
| Hermes provider | `spark-qwen38` / CLI `custom:spark-qwen38` |
| Hermes API | `http://127.0.0.1:1235/v1` on FirstSpark |
| Internal worker | `http://127.0.0.1:1236`; do not route ordinary clients around admission control |
| Capacity | Four independent active slots, 262,144 maximum tokens each, 1,048,576 aggregate allocated context |
| Cache | **Q4 K and V**, explicitly selected by the user; Flash Attention; one recurrent checkpoint per slot; optional saved-prompt RAM cache disabled to preserve headroom |
| Accelerator | None; MTP is not enabled or qualified in this installation |
| Hermes timeouts | New provider only: `request_timeout_seconds: 7200` and `stale_timeout_seconds: 7200`; accommodates slow cold prefill without changing other providers |
| Default sampling | Thinking template, temperature1.0, top_p0.95, top_k20, min_p0, repeat_penalty1; request settings may override |

**Four independent slots are the chosen target.** Input, tools, reasoning and output share each request's262K context. The user explicitly selected Q4 cache precision to allow four uncapped requests instead of the earlier Q8 shared-cache proposal, which would admit only two uncapped requests. Target attention KV is approximately18GiB with Q4 versus34GiB with Q8 for all four full contexts, before recurrent state or work buffers. Q5 model weights are unchanged. This increases concurrency capacity but introduces a possible long-context accuracy tradeoff that must pass qualification.

Admission counts rendered input including tools, reserves the request's declared output allowance plus a small margin, and permits at most four active requests. If an output cap is absent, it reserves the full262K request capacity; the new aggregate allocation accommodates **four uncapped requests**. It does **not** insert a permanent output or tool-turn limit. Up to eight additional requests may wait; the current wait limit is120seconds, after which clients receive an explicit retryable503. Excessive requests therefore have a clear capacity boundary, not a no-delay guarantee. Uncapped output is still bounded by the model's total context and client/runtime timeouts.

The proxy allows at most7200seconds for an admitted upstream request. The new Hermes provider explicitly uses7200second request/stale settings because its ordinary local streaming default is900seconds without output; a large cold prefill can exceed that. The existing SparkFast and other provider timeout settings remain unchanged. This permits long work but does not make it fast or remove finite timeout boundaries.

On a client disconnect the proxy drains the upstream response while retaining its reservation. This avoids admitting too much work before native cancellation has completed, but generation may continue after a client closes. Ambiguous upstream failures close admission until repeated checks confirm all four slots idle. The endpoint serves text/tool chat, not image or audio requests.

Four slots mean four requests can be active, not four permanently assigned chat histories. Hermes can retain more saved conversations; resuming a history that is no longer in a matching slot may require a cold prefill. Keeping the optional CPU prompt cache disabled saves memory but removes that extra history cache. Repeated retries during a slow prefill can consume additional capacity because the original request may still be draining. Keep the request open and inspect service progress before retrying.

## Current installation state

**Published at00:06:46IST on13October2026.** Native Qwen and admission services are enabled and running. The installed picker inventory is verified in all six Spark profiles. The real main-profile request subsequently passed: native route,262K context,7200second request/stream settings, no fallback, no tools and no output-token cap; the main config was unchanged.

- [x] User selected native Q5XL, four-session target, existing `spark-fast` retained.
- [x] Backed up the LM Studio unit, stopped it and disabled boot startup; available memory rose to about57GiB.
- [x] Started the pinned CUDA source build directly on FirstSpark.
- [x] Completed the pinned CUDA build and verified its version/device/required flags.
- [x] Started direct pinned model download on FirstSpark. The initial Xet attempt stalled; its partial was preserved before switching transport.
- [x] Confirmed actual Q5 GGUF metadata includes `nextn_predict_layers=1` and MTP tensors. A separate draft model is not required.
- [x] Admission proxy's nine fake-backend tests passed on Spark's existing Hermes Python.
- [x] Completed the 20,876,938,144-byte download and verified the pinned SHA-256 at 20:33 IST on 12 October 2026.
- [x] Load the worker, measure memory, qualify real API/tools and four overlapping short requests.
- [x] Qualify four100K-input requests: all retrieval/completion/concurrency/memory gates passed at22:42IST; minimum14.65GiB available, zero swap-out, approximately13.5minutes for the cold-input batch.
- [x] Complete four240K-input requests: all four retrievals correct, four busy slots observed, aggregate961,716 tokens, minimum13.747GiB available; cold batch44.7minutes. The original strict memory gate failed on44 host swap-out pages (176KiB); its failed receipt is retained.
- [x] Complete four real Hermes research/coding sessions and the reviewed pressure-aware follow-up: all passed, minimum15.115GiB available, zero worker swap, zero new host page-out, zero OOM events.
- [x] Record MTP eligibility: skipped because post-baseline available memory was14.99GiB, below18GiB; baseline remains selected.
- [x] Verify native worker restart and repeat short API/tool/four-stream checks; minimum16.43GiB available. Enable both services and publish the backed-up catalog to six Hermes configurations.
- [x] Verify installed picker inventory: new native provider present,262K and7200second settings, all defaults preserved, each Gemma once, offline LM Studio hidden.
- [x] Complete the final real main-profile request verification; receipt `production-route-v2.json` passed.
- [ ] Controlled reboot and longer real-use soak remain separate evidence.

The following commands are a reproducible tutorial for later use. The agent is performing the current installation; do not start a competing download, installer or build while its job is running.

The first automatic attempt stopped at20:34IST before model loading: systemd rejected `reset-failed` for the newly installed, inactive/unloaded worker units. That lifecycle edge case was fixed and five regression checks passed on Spark. Subsequent short model/API/tool/concurrency checks passed. The original16GiB memory target did not pass; the revised trial and its reason are documented below. The Hermes catalog was subsequently published after the reviewed qualification and restart gates passed. SparkFast returned the expected seven-token co-residency response in0.547seconds during Qwen's four100K-input test.

At23:00IST on12October, while Spark was actively prefilling the second240K prompt, Windows reported3% GPU utilization,3,934MiB GPU memory,29.55W and43°C; Ollama `/api/ps` listed no loaded model. During the final Hermes coding session after midnight on13October, a second read-only Windows observation showed2% GPU,3,149MiB,27.06W,45°C and zero loaded Ollama models. This is a simultaneous observation of desktop relief during Spark inference, not a measured desktop UI latency benchmark or proof about the retained Fresh Brief workload.

The finite `qwen38-install.service` continuation waits up to24hours for the verified download, checks baseline and, only with sufficient headroom, bundledMTP2; qualifies long context and isolated Hermes, verifies a worker restart, and publishes the provider only after acceptance. It records progress in `/home/snknitin/runs/qwen38-native/installation-status.json`; its `evidence_directory` identifies the unique folder holding this attempt's receipts and logs. It is a one-time installation job, not a recurring monitor or reboot task. Failure stops the new worker for review; it never stops `spark-fast` or changes Windows. `qualified_and_published` is the success stage; `waiting_for_verified_download` is **not** ready for use. SIGTERM/SIGINT stop qualification and trigger cleanup; partial downloads remain resumable.

### Review of the completed 240K test

The strict long-probe receipt remains `passed:false`: all functional/concurrency gates passed, but its zero-global-swap requirement failed on one44-page (176KiB) page-out event. That counter is host-wide, so it cannot identify which process was paged. Archived ten-minute memory-pressure samples showed0.00 and no OOM was recorded, but those samples cannot rule out a short stall. The native worker was stopped automatically and no provider was published from that failed run.

`shared-host-memory-review-20261012.json` pins the original receipts and records an explicit engineering exception: retain their functional capacity evidence, then require fresh four-Hermes testing with0.5second host/worker telemetry and60seconds of idle observation. The follow-up requires at least12GiB available, zero native-worker VmSwap, no new host or worker OOM events, host and worker full-memory stall fractions no greater than1%, and no sustained host page-out at8MiB/s for5seconds. Missing telemetry or worker identity changes fail closed. These are selected acceptance criteria, not universal Linux safety thresholds. This does not retroactively pass the strict zero-swap test or provide missing per-worker telemetry for its44.7minute run.

The reviewed continuation uses `continue_native_reviewed.py --run` only after its default preview validates the exact saved configuration, model and receipt hashes. It keeps speculation disabled, loads the model afresh, runs short checks, the monitored Hermes tasks and a restart test, then publishes using the original backed-up installer. A separate evidence directory preserves every attempt. This wrapper is specific to the preserved12October evidence on this host; it is not a substitute for new qualification on a clean machine or after changing model/runtime/context settings. Do not run it while a native service already owns live requests.

Thermal monitoring captured175 snapshots at15second intervals: maximum86°C, zero sampled active thermal-slowdown flags, no sampling errors. This is limited to qualification; a24hour soak remains unverified.

### Real Hermes task results

All four isolated real Hermes sessions completed successfully before publication. Two local-source research tasks took252.8 and337.3seconds and returned the expected decision with exact source-line citations. Two coding tasks took515.7 and706.8seconds; both produced a program and tests, passed independent original-input verification, unseen-input verification and the empty-input case. One session recovered from an existing command-approval rejection without changing the guard. The admission service was observed with four active requests reserving all1,048,576tokens, and the worker used uncapped generation.

The fresh pressure test plus60seconds idle retained at least15.115GiB available. Native-worker VmSwap and host page-out delta were zero; host and worker OOM deltas were zero. Host full-memory stall fraction was0.000009425 (about0.000943% of observed time), worker fraction0. SparkFast non-thinking test replies returned in0.128 and0.147seconds before/after. These results satisfy the separately disclosed follow-up policy; they do not change the original240K strict-gate failure.

These are short-context synthetic task checks using the real Hermes tool loop. They do not establish internet-research accuracy, unlimited goal reliability or equal Q4/Q8 quality. The long-context retrieval checks provide separate capacity evidence. Detailed task receipt: `/home/snknitin/runs/qwen38-native/qualification-20261012T182033.027090Z/q5xl-four-986efb09a85c/receipt.json`.

### Q8 versus Q4 context caches

Both proposals use the same Q5 model weights. The earlier Q8 proposal allocated a shared524K cache, accommodating approximately two uncapped262K requests within the selected budget. Q8 keeps more cache precision and reduces compression-related accuracy risk. Four fully allocated Q8 contexts would approximately double that cache allocation and leave too little margin alongside SparkFast under the current plan.

The selected Q4 proposal allocates four independent262K contexts for a similar total cache budget. Its advantage is concurrent capacity; its cost is greater risk of long-context accuracy loss. Four active requests still share GPU throughput. The long retrieval, tool, memory and concurrency probes are qualification evidence, not proof that Q4 equals Q8 on every research task. Uncapped output means no separate output limit is imposed; each session still has a finite262K combined input/output context.

## 1. Connect to the correct machine

**Windows PowerShell:**

```powershell
ssh -F "$env:LOCALAPPDATA\NVIDIA Corporation\Sync\config\ssh_config" FirstSpark
```

All remaining shell commands run **in that FirstSpark SSH terminal**, unless explicitly labelled Windows. Confirm the host:

```bash
hostname
```

**Pass:** `spark-07a8`. Stop if you are on Windows, SecondSpark or another host.

## 2. Locate the installed files and inspect progress

The setup files are staged at `/home/snknitin/ai/tools/qwen38-migration`. The Windows source copies are in `F:\Vaults\LLMWiki\Local_Setup\Qwen Spark Migration`.

```bash
cd /home/snknitin/ai/tools/qwen38-migration
```

```bash
systemctl --user status qwen38-install qwen38-parallel-download --no-pager
```

```bash
cat /home/snknitin/runs/qwen38-native/installation-status.json
```

```bash
journalctl --user -u qwen38-runtime-build -n 30 --no-pager
```

```bash
journalctl --user -u qwen38-parallel-download -n 20 --no-pager
```

Transient preparation units can disappear after success. Use completed files and verification receipts as evidence, not only their unit names. A running download or source build is not a serving model.

## 3. Reproduce the model download and native build

Only rerun a downloader when the previous one is stopped. Keep incomplete files and use the same chosen downloader to resume. The older Ollama `.incoming` file is a different model build and must never be treated as an Unsloth partial.

```bash
python3 download_native_parallel.py --workers 8
```

This downloads only the pinned Q5 target to the dedicated model directory, verifies every range and the full SHA-256, then publishes a completed filename and receipt. It resumes durable chunks from its manifest. On the initial switch from a stopped HTTP transfer, the agent supplied `--seed-http-partial` to reuse complete chunks; the original partial remains retained. Different partial formats are not interchangeable. Do not use apparent sparse-file size as download progress; read the manifest or journal.

```bash
bash build_native_runtime.sh
```

**Pass:** a CUDA device listing and `Built only; no model or service started`. The runtime is `/home/snknitin/.local/opt/llama.cpp-b11429/build/bin/llama-server`. The source is pinned, so future upstream changes are not adopted silently.

## 4. Retire LM Studio residency

The current installation already performed this step. For a later rebuild, back up the unit before disabling it:

```bash
systemctl --user disable --now lmstudio.service
```

```bash
systemctl --user is-enabled lmstudio.service
```

**Pass:** `disabled`. `inactive` from `is-active` is also expected. No uninstall or Nemotron weight deletion is needed to free its resident memory. Preserve the rollback copy at `/home/snknitin/ai/backups/qwen38-native-20261012/lmstudio.service.before`.

## 5. Review and start the worker

```bash
python3 run_native_qwen.py --print-command
```

Review `native-config.json`. The launcher requires a verified model receipt, a healthy `spark-fast`, at least52GiB available before loading, and no active LM Studio API. It waits up to660seconds for three consecutive memory readings at least52GiB, sampled five seconds apart, then rechecks the other residents before loading. It refuses unsafe startup rather than adjusting your model/context silently.

This service uses the existing FirstSpark foundation: working Docker access and the healthy `vllm-spark-fast` container, the installed Hermes Python with `aiohttp`, the existing `~/.local/bin/wait-for-spark-fast` startup helper, and user lingering enabled so services survive logout. These were verified on the current host. For a fresh host, establish that foundation first; copying these two unit files alone is insufficient.

```bash
test -x ~/.local/bin/wait-for-spark-fast
docker inspect --format '{{.State.Status}}' vllm-spark-fast
~/.hermes/hermes-agent/venv/bin/python -c 'import aiohttp; print(aiohttp.__version__)'
loginctl show-user snknitin -p Linger
```

Expected: helper present, container `running`, an installed `aiohttp` version, and `Linger=yes`. The startup helper must continue to wait for the existing SparkFast endpoint rather than launch a second model worker.

Once preparation has passed, install the two user units:

```bash
install -m 644 qwen38-native.service qwen38-admission.service ~/.config/systemd/user/
```

```bash
systemctl --user daemon-reload
```

For a deliberate retry after an earlier startup failure, clear the units' failure counters first:

```bash
systemctl --user reset-failed qwen38-native.service qwen38-admission.service
```

```bash
systemctl --user start qwen38-native.service qwen38-admission.service
```

```bash
curl --fail http://127.0.0.1:1235/health
```

**Pass:** HTTP200, `accepting:true`, `max_active:4`, `pool_tokens:1048576`, `per_request_tokens:262144`. Loading and initial slot verification can return503 temporarily. Persistent503 means inspect logs; do not point Hermes directly at port1236 to bypass the guard.

```bash
journalctl --user -u qwen38-native -u qwen38-admission -n 50 --no-pager
```

## 6. Qualify the actual service

Run the short API, structured tool round-trip and four-stream checks:

```bash
mkdir -p /home/snknitin/runs/qwen38-native
```

```bash
python3 probe_qwen.py --base http://127.0.0.1:1235/v1 --parallel 4 --output /home/snknitin/runs/qwen38-native/short.json
```

The long probes use the internal worker in a reserved test window, with explicit independent-slot limits and independent memory/swap guards. Get its actual PID:

```bash
systemctl --user show qwen38-native.service -p MainPID --value
```

Use that number in place of `WORKER_PID` below; do not type the literal placeholder.

```bash
python3 probe_qwen_long.py --base http://127.0.0.1:1236/v1 --server-pid WORKER_PID --parallel 4 --repetitions 100000 --min-prompt-tokens 100000 --min-memory-gib 12 --output /home/snknitin/runs/qwen38-native/long-four-100k.json
```

```bash
python3 probe_qwen_long.py --base http://127.0.0.1:1236/v1 --server-pid WORKER_PID --parallel 4 --min-memory-gib 12 --timeout 3600 --output /home/snknitin/runs/qwen38-native/long-four-240k.json
```

**Pass:** actual token usage, checkpoint retrieval, completion, observed four-slot activity and memory criteria all pass. The strict long-probe command requires **12GiB available** under load and no swap-out. Its completed240K run failed the latter criterion; the reviewed continuation above is a separately disclosed acceptance path, not a change to the original receipt or command. The initial16GiB acceptance target failed: short API/tool/four-stream checks passed but left13.26–14.09GiB. The pinned CUDA attention path reserves about4GiB of temporary FP16 K/V storage during prefill even with Q4 resident KV. Reducing microbatch256→128→64 saved too little to meet16GiB, so the selected profile restores256 for prompt throughput, retains one checkpoint and disables optional saved-prompt RAM caching. The12GiB threshold is an explicitly revised margin, not a claim that the original16GiB gate passed. The helper defaults to20 unless explicit12 is supplied. **8GiB is an emergency abort threshold**, not a successful capacity target. Stop on sustained swap-out, OOM or thermal throttling. The harness verifies actual launch flags, Q4 caches and four262K slots; labels alone are insufficient. Synthetic retrieval plus local research/tool fixtures are limited evidence, not proof of universal Q4/Q8 quality equivalence.

Then test real isolated Hermes sessions. The helper uses the installed Hermes Python and sets `HERMES_DISABLE_LAZY_INSTALLS=1` only for its isolated subprocesses; it must not build duplicate per-session environments. Four fresh test homes keep prompts and generated files separate, while model weights remain shared. The twelve-turn/900second test budgets do not become production limits:

```bash
python3 probe_hermes_pair.py --base http://127.0.0.1:1235/v1 --provider spark-qwen38 --parallel 4 --task mixed --namespace q5xl-four
```

This exercises uncapped local-source research and coding/tool actions without production-home changes or fallback to another model. It does not by itself prove internet research quality, production-profile customizations or sustained day-long agent work. The selected capacity can admit all four uncapped requests; distinguish independent completed sessions from actual overlapping generation, which the direct API/slot observations also verify.

## 7. Test the bundled MTP accelerator

**Current decision: skip MTP.** Post-baseline availability was14.99GiB, below the18GiB required before attempting its additional buffers. The automatic installer records this decision and proceeds with baseline long-context qualification. Do not run the optional steps below on the current memory budget; revisit only if measured headroom improves.

Only change accelerator settings while requests are idle. Back up `native-config.json`, set `speculation` to `draft-mtp` and `draft_max` to2, then restart the worker and admission service. The launcher uses the target model's embedded head and Q4 draft cache. No separate draft file or second full model is loaded.

Expect the worker log to include `creating MTP draft context against the target model`. Repeat the same tests and compare whole-task time, correctness, memory and queueing. Test3 only as a separate comparison. If it is slower or less stable, retain `none`. A speculative accelerator is not a reasoning-quality upgrade.

### Verify restart before publication

For a manual installation, reserve an idle window before this step: admission health must report `active:0` and `queued:0`, and no other client should submit work during the restart. The automatic installer already performs this gate before publication.

```bash
curl --fail http://127.0.0.1:1235/health
systemctl --user reset-failed qwen38-native.service qwen38-admission.service
systemctl --user restart qwen38-native.service qwen38-admission.service
python3 -c 'from finish_native_install import wait_health; wait_health()'
python3 probe_qwen.py --base http://127.0.0.1:1235/v1 --parallel 4 --output /home/snknitin/runs/qwen38-native/short-after-manual-restart.json
```

Run this from the migration tools directory. The wait is bounded at15minutes and requires admission readiness. Continue only when the saved short receipt reports `passed:true`; preserve any failure receipt for diagnosis. This verifies a service restart, not a full host reboot.

## 8. Make Qwen selectable in Hermes

### Named-provider timeout compatibility

The installed Hermes checkout normalized the selected `custom:spark-qwen38` provider to `custom` before looking up timeouts. Provider fields alone therefore had no effect. The migration applies a backed-up, route-aware fix to `hermes_cli/timeouts.py` and seven call sites across `run_agent.py`, `agent/agent_init.py`, and `agent/chat_completion_helpers.py`. Named-provider settings take precedence; absent settings retain the old generic-custom fallback. No global timeout setting changes.

For a fresh copy of the same affected Hermes version, preview the reproducible patch, inspect its result, then apply:

```bash
~/.hermes/hermes-agent/venv/bin/python patch_hermes_timeouts.py
```

```bash
~/.hermes/hermes-agent/venv/bin/python patch_hermes_timeouts.py --apply
```

The current installation already contains this fix; do not stack it again. The helper refuses unexpected source layouts and preserves a hash-checked backup. After a future Hermes update, rerun the production verification below; do not assume the local patch survived or blindly reapply it to a different version. A code change requires fresh Hermes processes, unlike a catalog-only change. With the user's authorization, gateway, Serve and dashboard were restarted at23:46IST on12October; all three returned running, and both HTTP status routes reported the gateway running and idle. Use a drained gateway restart. For Serve/dashboard, check actual in-flight turn lifecycle and durable turn markers before restarting; the recent-session count alone does not establish whether a task is running. Never interrupt an active user job for this step.

### Publish and verify the catalog

Preview the exact changes using the installed Hermes Python:

```bash
~/.hermes/hermes-agent/venv/bin/python configure_hermes_native.py --home ~/.hermes --context 262144 --disable-lmstudio-provider
```

**Pass:** six audited configs; each adds `spark-qwen38`; every saved default remains unchanged; desktop Ollama shows the three Gemmas once; offline LM Studio is disabled but its catalog is preserved. The adapter refuses conflicting defaults or unreviewed references.

After service qualification, apply the same command with its explicit write flag:

```bash
~/.hermes/hermes-agent/venv/bin/python configure_hermes_native.py --home ~/.hermes --context 262144 --disable-lmstudio-provider --apply
```

It prints the backup directory. Preserve that receipt. It does not delete Windows Ollama models or change Fresh Brief. Installed Hermes rereads changed configs, so a catalog-only change does not require restarting the gateway or interrupting jobs. Use `/model --refresh` in the gateway, or refresh the Serve model picker. Saved conversations retain their old model choice; choose the new provider explicitly for those conversations.

A new CLI session can select it directly:

```bash
~/.hermes/hermes-agent/venv/bin/python -m hermes_cli.main chat --provider custom:spark-qwen38 --model qwen38-27b-spark
```

Run this from the installed Hermes source directory if Python cannot resolve the module. Keep `spark-fast` as the default for other sessions. A normal production-profile chat must be checked after the isolated qualification. The provider's7200second timeout applies to individual inference requests and stalled streams, not the lifetime of an entire saved chat or research goal; the262K context and output-token policy are separate limits.

From the migration tools directory, the following bounded check reads the real main profile, resolves the native provider and262K context, and generates one no-tools response. It verifies7200second effective client/stream timeouts and confirms that no output-token cap or fallback was sent. Its default180second test deadline does not alter production settings. The completed check used a600second test budget and passed. The helper selects Hermes' committed PM runtime automatically, avoiding mismatched Python/site-packages; it does not install dependencies:

```bash
~/.hermes/hermes-agent/venv/bin/python probe_hermes_production.py --run --output /home/snknitin/runs/qwen38-native/production-route.json
```

Verify all six catalogs against the exact backup printed by publication:

```bash
~/.hermes/hermes-agent/venv/bin/python verify_native_catalog.py --backup BACKUP_DIRECTORY --output /home/snknitin/runs/qwen38-native/catalog-verification.json
```

Replace `BACKUP_DIRECTORY` with that recorded path. This invokes installed picker inventory and checks defaults/Gemma de-duplication; it does not claim authenticated browser verification. Existing Serve/dashboard picker HTTP endpoints require OAuth; an unauthenticated401 is not a model failure.

### Completed verification and remaining observations

The final main-profile receipt is `/home/snknitin/runs/qwen38-native/qualification-20261012T182033.027090Z/production-route-v2.json`; all six catalog checks are in `catalog-verification.json`, and service enablement/binds are in `final-runtime.json`. Final thermal observation recorded65 snapshots, maximum81°C and no sampled thermal-slowdown flag. Both native units are enabled and accept requests only on Spark loopback; SparkFast remained running from its existing9October start.

Authenticated Windows picker rendering/chat, a full host reboot and an extended real-use soak remain unverified. Refresh the existing Hermes Remote Gateway model picker to use the published provider; no new Windows model copy or LM Link setup is required. An optional direct Windows-to-native API tunnel test was rejected by automatic approval review with the message “blocked by policy”; it was not retried through another mechanism. This does not affect the verified Spark-local Hermes inference route. Rollback assets remain until longer observation is complete.

## 9. Enable startup and observe normal use

After qualification:

```bash
systemctl --user enable qwen38-native.service qwen38-admission.service
```

```bash
curl --fail http://127.0.0.1:1235/v1/models
```

```bash
free -h
```

```bash
nvidia-smi
```

The auxiliary-service catalog now lists `qwen38-native` on1236 and `qwen38-admission` on1235 as **locked inventory-only** entries. `aux-services status` shows their unit state, while bulk or named auxiliary start/stop cannot change their residency. Use their dedicated systemd commands and health endpoint. See [[DGX Spark Additional Services Controller]].

Spark Dash currently monitors vLLM on port8000; its existing model statistics are not evidence of this new service's request count. Use Qwen's health endpoint for active/queued/reserved-token counts and its journal for errors. Both inference services share Spark GPU compute and bandwidth, so overlapping work can slow them down even when memory fits.

This pair is the normal FirstSpark resident set. Before using an exclusive two-Spark Frontier lane or loading Nemotron again, stop the native Qwen pair and confirm its process exits and memory is released. Existing lane names and a green SparkFast status do not account for this additional native worker automatically. Do not add another large resident model to the measured pair without a new capacity check.

A service restart should be verified after installation. A full reboot should happen in your chosen maintenance window; enabling units is not proof that a reboot test passed. No unattended reboot is part of this setup.

## 10. Stop or roll back

Stop the Qwen pair deliberately:

```bash
systemctl --user disable --now qwen38-admission.service qwen38-native.service
```

This does not stop `spark-fast`. To restore Nemotron later, first confirm Qwen's worker has exited and memory is released, then:

```bash
systemctl --user enable --now lmstudio.service
```

Restore Hermes using the migration's recorded backup and the helper's `--rollback BACKUP_DIRECTORY --apply` facility only if the saved configs have not subsequently changed. It refuses stale rollback overwrites. Model files remain on disk; an uninstall is a separate cleanup decision.

Related: [[Local Setup Index]], [[Task Checklist]], [[Qwen Spark Migration Evidence 2026-10-12]].
