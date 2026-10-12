---
updated: 2026-10-12
status: installation-in-progress
tags: [dgx-spark, qwen, hermes, llama-cpp]
---

# Qwen 3.8 27B Native Spark Setup Tutorial

## Final decision and scope

The user selected **Unsloth Qwen3.8-27B UD-Q5_K_XL served by native llama.cpp on FirstSpark**. It will serve research, planning, tool use and coding in Hermes alongside the existing Qwen3.6-35B-A3B `spark-fast` service. Main Hermes remains on `spark-fast`; Qwen3.8 is an explicit selectable provider.

LM Studio is stopped and disabled on FirstSpark. Its files and Nemotron weights are retained for rollback, but neither is meant to be resident. **Windows Ollama, its existing Qwen copy, Fresh Brief and Windows configuration are unchanged.** This removes Hermes Qwen inference from the desktop GPU; Fresh Brief can still use that GPU intentionally.

Q5 retains more weight precision than Q4. This is a quality preference, not a measured promise that every reasoning answer improves. Native llama.cpp was chosen for explicit service ownership, private API access and direct MTP controls; LM Link is no longer required. [[Qwen 3.8 27B Spark Serving Options]] retains the alternatives and research rationale.

## Exact configuration

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
| Cache | **Q4 K and V**, explicitly selected by the user; Flash Attention; two recurrent checkpoints per slot to bound overhead |
| Initial accelerator | None during baseline qualification; bundled MTP2 is the subsequent comparison |
| Default sampling | Thinking template, temperature1.0, top_p0.95, top_k20, min_p0, repeat_penalty1; request settings may override |

**Four independent slots are the chosen target.** Input, tools, reasoning and output share each request's262K context. The user explicitly selected Q4 cache precision to allow four uncapped requests instead of the earlier Q8 shared-cache proposal, which would admit only two uncapped requests. Target attention KV is approximately18GiB with Q4 versus34GiB with Q8 for all four full contexts, before recurrent state or work buffers. Q5 model weights are unchanged. This increases concurrency capacity but introduces a possible long-context accuracy tradeoff that must pass qualification.

Admission counts rendered input including tools, reserves the request's declared output allowance plus a small margin, and permits at most four active requests. If an output cap is absent, it reserves the full262K request capacity; the new aggregate allocation accommodates **four uncapped requests**. It does **not** insert a permanent output or tool-turn limit. Up to eight additional requests may wait; the current wait limit is120seconds, after which clients receive an explicit retryable503. Excessive requests therefore have a clear capacity boundary, not a no-delay guarantee. Uncapped output is still bounded by the model's total context and client/runtime timeouts.

On a client disconnect the proxy drains the upstream response while retaining its reservation. This avoids admitting too much work before native cancellation has completed, but generation may continue after a client closes. Ambiguous upstream failures close admission until repeated checks confirm all four slots idle. The endpoint serves text/tool chat, not image or audio requests.

## Current installation state

This section is deliberately provisional until real inference passes:

- [x] User selected native Q5XL, four-session target, existing `spark-fast` retained.
- [x] Backed up the LM Studio unit, stopped it and disabled boot startup; available memory rose to about57GiB.
- [x] Started the pinned CUDA source build directly on FirstSpark.
- [x] Completed the pinned CUDA build and verified its version/device/required flags.
- [x] Started direct pinned model download on FirstSpark. The initial Xet attempt stalled; its partial was preserved before switching transport.
- [x] Confirmed actual Q5 GGUF metadata includes `nextn_predict_layers=1` and MTP tensors. A separate draft model is not required.
- [x] Admission proxy's nine fake-backend tests passed on Spark's existing Hermes Python.
- [ ] Complete and hash-verify the model download.
- [ ] Load the worker, measure memory, qualify real API/tools and four overlapping requests.
- [ ] Qualify four100K-input requests and **four240K-input requests**, then real Hermes research/coding sessions.
- [ ] Compare bundled MTP with baseline; retain only a qualified configuration.
- [ ] Apply the backed-up Hermes catalog change and verify service restart.
- [ ] Controlled reboot and longer real-use soak remain separate evidence.

The following commands are a reproducible tutorial for later use. The agent is performing the current installation; do not start a competing download, installer or build while its job is running.

The finite `qwen38-install.service` continuation waits up to24hours for the verified download, checks baseline versus bundledMTP2, qualifies long context and isolated Hermes, verifies a worker restart, and publishes the provider only after acceptance. It records progress in `/home/snknitin/runs/qwen38-native/installation-status.json`; its `evidence_directory` identifies the unique folder holding this attempt's receipts and logs. It is a one-time installation job, not a recurring monitor or reboot task. Failure stops the new worker for review; it never stops `spark-fast` or changes Windows. `qualified_and_published` is the success stage; `waiting_for_verified_download` is **not** ready for use. SIGTERM/SIGINT stop qualification and trigger cleanup; partial downloads remain resumable.

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

Review `native-config.json`. The launcher requires a verified model receipt, a healthy `spark-fast`, at least52GiB available before loading, and no active LM Studio API. It refuses unsafe startup rather than adjusting your model/context silently.

Once preparation has passed, install the two user units:

```bash
install -m 644 qwen38-native.service qwen38-admission.service ~/.config/systemd/user/
```

```bash
systemctl --user daemon-reload
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
python3 probe_qwen_long.py --base http://127.0.0.1:1236/v1 --server-pid WORKER_PID --parallel 4 --repetitions 100000 --min-prompt-tokens 100000 --min-memory-gib 16 --output /home/snknitin/runs/qwen38-native/long-four-100k.json
```

```bash
python3 probe_qwen_long.py --base http://127.0.0.1:1236/v1 --server-pid WORKER_PID --parallel 4 --min-memory-gib 16 --output /home/snknitin/runs/qwen38-native/long-four-240k.json
```

**Pass:** actual token usage, checkpoint retrieval, completion, observed four-slot activity and memory criteria all pass. The selected four-slot trial requires **16GiB available** under load and no swap-out. This replaces the earlier two-slot proposal's conservative20GiB target; the helper defaults to20 unless the explicit16 argument is supplied. **8GiB is an emergency abort threshold**, not a successful capacity target. Stop on sustained swap-out, OOM or thermal throttling. The harness verifies actual launch flags, Q4 caches and four262K slots; labels alone are insufficient. Synthetic retrieval plus local research/tool fixtures are limited evidence, not proof of universal Q4/Q8 quality equivalence.

Then test real isolated Hermes sessions:

```bash
python3 probe_hermes_pair.py --base http://127.0.0.1:1235/v1 --provider spark-qwen38 --parallel 4 --task mixed --namespace q5xl-four
```

This exercises uncapped local-source research and coding/tool actions without production-home changes or fallback to another model. It does not by itself prove internet research quality, production-profile customizations or sustained day-long agent work. The selected capacity can admit all four uncapped requests; distinguish independent completed sessions from actual overlapping generation, which the direct API/slot observations also verify.

## 7. Test the bundled MTP accelerator

Only change accelerator settings while requests are idle. Back up `native-config.json`, set `speculation` to `draft-mtp` and `draft_max` to2, then restart the worker and admission service. The launcher uses the target model's embedded head and Q4 draft cache. No separate draft file or second full model is loaded.

Expect the worker log to include `creating MTP draft context against the target model`. Repeat the same tests and compare whole-task time, correctness, memory and queueing. Test3 only as a separate comparison. If it is slower or less stable, retain `none`. A speculative accelerator is not a reasoning-quality upgrade.

## 8. Make Qwen selectable in Hermes

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

Run this from the installed Hermes source directory if Python cannot resolve the module. Keep `spark-fast` as the default for other sessions. A normal production-profile chat must be checked after the isolated qualification.

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

Spark Dash currently monitors vLLM on port8000; its existing model statistics are not evidence of this new service's request count. Use Qwen's health endpoint for active/queued/reserved-token counts and its journal for errors. Both inference services share Spark GPU compute and bandwidth, so overlapping work can slow them down even when memory fits.

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
