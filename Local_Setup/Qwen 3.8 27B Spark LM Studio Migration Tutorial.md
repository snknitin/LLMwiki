---
updated: 2026-10-12
status: superseded-alternative-not-deployed
tags: [local-ai, dgx-spark, hermes, lm-studio, qwen]
---

# Qwen 3.8 27B Spark LM Studio Migration Tutorial

> [!warning] Superseded execution sequence — do not run this guide in order
> The user's revised scope keeps Fresh Brief on Windows Ollama and asks for a fresh Unsloth download directly on FirstSpark. Start with [[Qwen 3.8 27B Spark Serving Options]]. Native llama.cpp is now the preferred recommendation; LM Studio is an alternative. The Windows copy was stopped with an incomplete approximately 15 GiB `.incoming` file; it was not loaded. The old 64K-first sequence below is superseded by a **two-session, 262,144-token-per-session** qualification target. No Spark Qwen service or live Hermes catalog change has been deployed. This retained guide records the earlier alternative, not the current instructions.

## Start here

**Recommended:** keep Qwen 3.8 27B warm in **FirstSpark LM Studio**, replace Nemotron's current resident role, and use it from both Spark Hermes and Windows LM Studio. Keep `spark-fast` and SecondSpark's TensorFold service as they are. Preserve Nemotron's files for deliberate on-demand switching. Keep each of the three Windows Ollama Gemmas once in Hermes.

This removes Qwen inference from the Windows display GPU. Merely replacing Windows Ollama with Windows LM Studio would still use that GPU and would not establish a fix. LM Link carries remote inference; it does not need a Windows copy of the weights.

**State on 12 October:** investigation and documentation complete; Qwen has not been copied, loaded, benchmarked, or promoted on Spark. No live Hermes catalogs, boot units, or Fresh Brief settings were changed. Scripts below are prepared helpers, not evidence that a migration ran. Run the numbered steps in order, one command block at a time.

Read [[Qwen Spark Migration Evidence 2026-10-12]] for the regression findings. Read [[Fresh Brief Spark Qwen Migration Requirements]] before claiming that all automatic Windows Qwen use has stopped.

## 1. What is actually running

Live inspection was around 14:21–14:40 IST on 12 October; values are a snapshot, not reservations.

| Component | Observed state | Implication |
|---|---|---|
| FirstSpark vLLM | `spark-fast`, Qwen **3.6 35B-A3B** NVFP4, 262,144 context, 18G FP8 KV pool, `max-num-seqs=8`; 48,818 MiB GPU process allocation | Different model from your dense Qwen 3.8 27B; keep its production route |
| FirstSpark LM Studio | Nemotron 3.5 Lightning Q4_K_M; **1,048,576 context, parallel 1**, no TTL; 30,633 MiB process allocation | One active generation, additional requests queue |
| FirstSpark memory | About 121.7 GiB visible total, 27.1 GiB available, 5.2 GiB swap occupied | Unified CPU/GPU pool; do not treat unused GPU allocation as all available RAM |
| Spark Dash | GPU total 79,451 MiB = 48,818 vLLM + 30,633 LM Studio; vLLM monitoring configured only on port 8000 | The roughly **77.6 GiB** reading is the sum of both workers, not vLLM alone |
| Spark thermal snapshot | 61–71°C, later throttle flags false | No thermal throttling in those samples; not a sustained thermal qualification |
| Spark model library | Nemotron and Nomic embedding; **no Qwen 3.8 27B in LM Studio** | Copy/import is needed |
| SecondSpark | Qwen 3.8 Flash Next TensorFold already resident; ~17.6 GiB available | Not an empty spare GPU; do not add another model blindly |
| Windows Ollama | 0.40.0; Qwen Q4_K_M + three Gemmas; no model loaded at snapshot | Idle does not prove the active-inference issue is fixed |
| Hermes catalogs | Root and profiles disagree; some discover everything and retain old Qwen tag | Update every active home/profile, not just one picker |

Memory safety policy for this trial: aim for **at least 20 GiB MemAvailable under representative combined load**, no continuing swap-out, no new OOM events, and no sustained thermal throttling. This is a conservative operating target for this machine, not an NVIDIA specification or proof that every workload will fit. Pre-existing swap usage alone is not current thrashing.

## 2. Sessions, concurrency, context, and alternatives

Multiple Hermes conversations keep separate histories and share one loaded model. A model is not tied to one session. `parallel` controls overlapping predictions, not how many conversations can exist. LM Studio's llama.cpp engine supports continuous batching, like the general serving mechanism used by vLLM; the implementation and throughput are different.

**Nemotron right now: one generation at a time.** Its 1M context is not a million tokens reserved independently for every open chat. More simultaneous requests wait. Changing it to 2 or 4 requires a reload and new memory/performance tests; this guide does not silently change it.

**Qwen candidate: two concurrent predictions, initially 65,536 context.** Beyond two requests queue, including LM Link chats and Fresh Brief requests. Two open Hermes sessions can themselves issue more than two requests if tools spawn other agents. Neither two slots nor free RAM guarantees zero delays. Both Spark models still share GPU compute and memory bandwidth.

The 64K setting is an initial qualification point, **not an approved permanent reduction of your long-goal capacity**. Recent Windows logs have prompts near 160K. Test 131K and, if needed, 262K using Step 6 before promoting a context limit. Verify long-task compression/completion and the combined KV behavior; do not infer that `--context-length 65536 --parallel 2` guarantees two fully usable 64K contexts from the flags alone.

| Option | Assessment |
|---|---|
| Qwen warm in FirstSpark LM Studio; Nemotron on demand | Best match for your exact model, Windows UI, LM Link, and desktop relief |
| Add Qwen beside warm Nemotron and vLLM | Not recommended from the current memory snapshot; could consume the remaining headroom |
| Qwen in Windows LM Studio | Still competes with Windows graphics; not the placement fix |
| Qwen in a dedicated Spark vLLM service | Worth a later measured comparison for heavier concurrency; LM Link does not manage vLLM workers; would need a separate qualified lane |
| Use existing `qwen38-tensorfold-second` now | Immediate Spark-only alternative already configured, but a different Qwen model and not an LM Link model |
| Native Ollama on Spark | Preserves Ollama API clients, but adds another runtime and does not provide the requested LM Studio/LM Link ownership |

## 3. Copy the exact current weights — Windows PowerShell

Open **Windows PowerShell**, not the Spark terminal. The prepared helper verifies your Ollama manifest, GGUF headers, sizes, and SHA-256 hashes before and after copying. It copies files; it does not delete the Ollama model, load a model, or install software. Allow about 18 GB disk on Spark. A failed `.incoming` transfer is retained and is recopied on retry; this SCP helper does not resume midway through a file.

```powershell
Set-Location 'F:\Vaults\LLMWiki\Local_Setup'
& '.\Qwen Spark Migration\Copy-QwenToSpark.ps1'
```

**Pass:** `Copy verified. No model loaded...`. **Stop:** hash/size mismatch, unfamiliar manifest structure, an existing different destination, or SSH failure. Do not delete caches to fix it.

These are the currently installed files, not an assumed alternative quantization:

| File | Bytes | SHA-256 |
|---|---:|---|
| Main Q4_K_M GGUF | 16,810,714,464 | `f5f1dd8920d417aac2718b0bda3403da274301efdd6760b4f0f4b864ff2ad57d` |
| BF16 vision projector | 931,146,016 | `ac3714bfdddeca31351f2752bf1a63f266f4df87c0b68c895e44945ca704448e` |

Destination: `/home/snknitin/.lmstudio/models/local/Qwen3.8-27B-Ollama/`. This is a deliberate GGUF import into LM Studio's documented publisher/repository layout. The two source files are confirmed GGUF; **LM Studio compatibility with this exact exported pair is still a load/test gate**. Reusing bytes does not guarantee identical templates, reasoning, MTP, vision, or performance between runtimes.

If LM Studio rejects this import, stop. Keep the originals and use a separately evaluated catalog build; the current Unsloth alternative is **UD-Q4_K_M**, not your exact plain Q4_K_M. Do not silently substitute it and claim identical weights. The installed `lms get --help` supports a full Hugging Face URL and `--select`; do not copy newer website flags that this CLI lacks.

Copy the small helpers next, still in **Windows PowerShell**:

```powershell
$SshConfig = Join-Path $env:LOCALAPPDATA 'NVIDIA Corporation\Sync\config\ssh_config'
ssh -F $SshConfig FirstSpark 'mkdir -p /home/snknitin/ai/tools/qwen38-migration'
if ($LASTEXITCODE -ne 0) { throw 'SSH failed' }
scp -F $SshConfig '.\Qwen Spark Migration\configure_hermes.py' '.\Qwen Spark Migration\configure_boot.py' '.\Qwen Spark Migration\probe_qwen.py' 'FirstSpark:/home/snknitin/ai/tools/qwen38-migration/'
if ($LASTEXITCODE -ne 0) { throw 'Helper copy failed' }
```

## 4. Verify the import and reserve the LM Studio lane — FirstSpark terminal

Open **NVIDIA Sync → FirstSpark → Terminal**. All Bash blocks below run there unless labeled otherwise.

```bash
export PATH="$HOME/.lmstudio/bin:$HOME/.local/bin:$PATH"
lms ls --json
lms ps --json
free -h
```

Find the exact imported Qwen model key printed by `lms ls`; the key can contain the repository and filename. The model must be Qwen3.8 27B Q4_K_M, not `spark-fast`. Save that key once:

```bash
read -r -p 'Paste the exact imported Qwen modelKey from lms ls: ' QWEN_KEY
export QWEN_KEY
export QWEN_CONTEXT=65536
```

Finish active Nemotron turns. This maintenance step stops **only the LM Studio service**; vLLM/Hermes remain running, but Nemotron requests cannot succeed during the switch. Prevent future automatic Nemotron loads before pinning Qwen: JIT Auto-Evict cannot evict a manually loaded Qwen and does not coordinate with vLLM.

```bash
systemctl --user stop lmstudio.service
lms daemon status
```

**Pass:** daemon stopped. **Stop:** active daemon or unfinished Nemotron request. Disable JIT in the **existing, live-verified server config** while the daemon is stopped; keep a backup path printed by this command:

```bash
python3 - <<'PY'
import json, shutil, datetime, os
from pathlib import Path
p=Path.home()/'.lmstudio/.internal/http-server-config.json'
d=json.loads(p.read_text())
assert isinstance(d.get('justInTimeModelLoading'),bool), 'Unexpected config; stop'
b=p.with_name(p.name+'.before-qwen38-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'))
assert not b.exists(), 'Backup collision'
shutil.copy2(p,b)
d['justInTimeModelLoading']=False
t=p.with_name(p.name+'.qwen38-tmp')
t.write_text(json.dumps(d,indent=2)+'\n')
shutil.copymode(p,t)
os.replace(t,p)
print('Backup:',b)
PY
```

This internal setting was inspected on your installed version; do not assume the same schema after an update. It disables HTTP JIT loading. An explicit GUI/CLI load can still allocate another model, so keep the lane's manual switching rule.

```bash
lms daemon up
lms server start --bind 127.0.0.1 --port 1234
lms ps --json
free -h
```

**Pass:** no loaded LM Studio LLM, API remains loopback-only, memory recovered. If Nemotron is still loaded, stop and identify its owner. Do not unload all runtimes or stop production vLLM to make a result look better.

## 5. Estimate, then load the candidate

```bash
lms load "$QWEN_KEY" --estimate-only --gpu max --context-length "$QWEN_CONTEXT" --parallel 2 --no-speculative-draft-mtp
```

Compare the estimate to current `MemAvailable`, leaving the 20 GiB operating margin above. The estimator can be low-confidence and is not peak-load proof. **Stop** on unsupported architecture, estimate failure, or inadequate margin. No speculative MTP speedup is claimed in this baseline.

```bash
lms load "$QWEN_KEY" --identifier qwen38-27b-spark --gpu max --context-length "$QWEN_CONTEXT" --parallel 2 --no-speculative-draft-mtp --yes
```

```bash
lms ps --json
curl -fsS http://127.0.0.1:1234/api/v1/models
free -h
nvidia-smi
```

**Pass:** exactly one Qwen LM Studio instance, alias `qwen38-27b-spark`, expected context, `parallel:2`, no TTL, no resident Nemotron; `vllm-spark-fast` remains healthy. No TTL keeps it warm while the daemon is alive; persistence after reboot is a separate step.

## 6. Qualify before making it permanent

Run bounded API checks from **FirstSpark**:

```bash
mkdir -p "$HOME/runs/qwen38-lmstudio"
python3 "$HOME/ai/tools/qwen38-migration/probe_qwen.py" --output "$HOME/runs/qwen38-lmstudio/api-check.json"
```

The helper checks plain output, a structured harmless tool-call round trip, and two overlapping streamed requests. It records elapsed time, first stream-output latency (including reasoning), and sampled minimum free memory. **Pass:** `passed:true`. This does not by itself prove that both requests were scheduled concurrently, long-context capacity, vision, or real Hermes behavior. Observe `lms ps --json` during requests to verify active/queued predictions. A reasoning-only/truncated answer fails the check; investigate rather than declaring success.

After the API checks, Step 7 adds the candidate catalog/context and runs the real Hermes tests. Complete those before Step 8 promotes the boot unit. A successful API probe alone is not promotion approval. Do not reuse an old desktop-Qwen chat without explicitly changing its selection.

Keep a second **FirstSpark terminal** watching:

```bash
vmstat 2
```

Watch [Spark Dash](http://127.0.0.1:5555/) alongside it. `si/so` are swap-in/out; the first vmstat line is since boot, later lines reflect each interval. Test at least 20–30 minutes of representative work with Qwen's two sessions and normal `spark-fast` activity. Record response latency, completion, memory low-water, temperature, throttling, and new kernel OOM/GPU errors. Dash's current LLM panel monitors port 8000 only; the total memory includes LM Studio, but that is not a Qwen queue metric. Use `lms ps` and probe receipts for Qwen. Do not treat cumulative historical `nvErrNoMemory` as a new event.

**Windows PowerShell**, during active remote Qwen generation:

```powershell
nvidia-smi --query-gpu=timestamp,utilization.gpu,memory.used,power.draw,temperature.gpu --format=csv -l 2
```

Check actual scrolling, typing, and window interaction while Spark is generating. **Pass:** normal desktop responsiveness, Windows GPU near its ordinary workload baseline, no Windows Qwen runner appears. Stop sampling with Ctrl+C. No low GPU result counts unless a Spark Qwen request was actively generating.

### Long-context qualification

After the initial test, finish requests, unload just Qwen, and estimate 131K at parallel 2. If adequate headroom remains, load and repeat the tests at 131K. Use 262K only if necessary and after its separate estimate and load test.

```bash
lms unload qwen38-27b-spark
export QWEN_CONTEXT=131072
lms load "$QWEN_KEY" --estimate-only --gpu max --context-length "$QWEN_CONTEXT" --parallel 2 --no-speculative-draft-mtp
```

If the estimate passes, repeat Steps 5–6 with this context. Test two realistic overlapping long histories, tool calls, compression, and task completion. For 262K set `QWEN_CONTEXT=262144` and repeat the same gates. Do not send 150K-token histories to a 64K backend. If only the small profile fits, choose explicitly between reduced context, fewer simultaneous predictions, or dedicating more Spark resources; do not silently lower task limits or claim equivalent long-goal behavior.

All prepared promotion commands below use the **qualified** `QWEN_CONTEXT`. They assume parallel 2. If a different parallel setting is needed, review the boot helper and acceptance plan rather than promoting mismatched metadata.

## 7. Simplify Hermes — three Gemmas once; Spark Qwen once

The intended catalog is:

| Provider | Entries |
|---|---|
| `desktop-ollama` | `gemma4:31b-it-qat`, `gemma4:26b-a4b-it-qat`, `gemma3:4b` — each once |
| `spark-lmstudio` | `qwen38-27b-spark`; existing Nemotron catalog retained as explicitly on-demand |

The installed Hermes requires **`discover_models:false` plus explicit `models`** to filter the picker. Metadata alone does not filter discovery. Hiding a tag is not uninstalling it or revoking an old chat's saved selection. Existing defaults using `spark-fast`, TensorFold, or cloud models stay unchanged.

Preview **FirstSpark main plus five profiles**:

```bash
"$HOME/.hermes/hermes-agent/venv/bin/python" "$HOME/ai/tools/qwen38-migration/configure_hermes.py" --home "$HOME/.hermes" --context "$QWEN_CONTEXT"
```

After checking the printed plan and finishing active turns:

```bash
"$HOME/.hermes/hermes-agent/venv/bin/python" "$HOME/ai/tools/qwen38-migration/configure_hermes.py" --home "$HOME/.hermes" --context "$QWEN_CONTEXT" --apply
```

It creates backups and atomically writes affected configs. Saved desktop-Qwen defaults cause a stop unless explicitly migrated; fallback/auxiliary desktop-Qwen routes require manual review. The live audit found none, but the helper rechecks. If it refuses because something changed, inspect that change instead of disabling safeguards.

```bash
systemctl --user restart hermes-serve.service hermes-gateway.service
```

Refresh the remote Hermes picker, open two new chats and explicitly choose **Spark LM Studio → qwen38-27b-spark**. Verify tools and the long-context setting. During this test FirstSpark Hermes calls its own `127.0.0.1:1234/v1`; it does not depend on Windows LM Studio being open.

For a paste-ready real tool test, run the following in **two FirstSpark terminals**, starting the second while the first is running. Each run creates a separate temporary workspace; the ten-minute budget applies only to this test, not your normal long goals.

```bash
PROBE_DIR=$(mktemp -d "$HOME/runs/qwen38-lmstudio/hermes-XXXXXX")
hermes chat --provider custom:spark-lmstudio --model qwen38-27b-spark --in "$PROBE_DIR" --oneshot --run-budget 600 -q 'In the current temporary directory only, use the terminal tool to write a.txt containing exactly alpha followed by a newline and b.txt containing exactly beta followed by a newline. Use a tool to calculate both SHA-256 hashes. Report the hashes and finish. Do not modify any other directory.'
python3 - "$PROBE_DIR" <<'PY'
import hashlib,sys
from pathlib import Path
p=Path(sys.argv[1])
for name,expected in [('a.txt',b'alpha\n'),('b.txt',b'beta\n')]:
    data=(p/name).read_bytes()
    assert data==expected, 'Unexpected content: '+name
    print(name,hashlib.sha256(data).hexdigest())
PY
```

**Pass:** both tasks complete, independently verified hashes match each reply, no cross-session file/history mix-up, no queue/timeouts beyond your accepted latency. Then run the representative long-task/combined-vLLM acceptance from Step 6 with the selected context. Only after those pass continue to the startup promotion in Step 8. This is an explicit temporary workspace test; keep the outputs as evidence.

If you use the **Windows Local Gateway**, update that separate catalog too. In **Windows PowerShell**, this was the installed Hermes Python on the audit date:

```powershell
$HermesPython = Join-Path $env:LOCALAPPDATA 'hermes\installs\e599dac320da6712\pm-runtime\generations\28004e1274734d3a881cdcd1f3e9f0a0\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $HermesPython)) { throw 'Hermes updated; locate its current Python runtime before continuing' }
$QualifiedContext = 65536 # Replace with the context actually qualified on Spark.
& $HermesPython 'F:\Vaults\LLMWiki\Local_Setup\Qwen Spark Migration\configure_hermes.py' --home "$env:LOCALAPPDATA\hermes" --context $QualifiedContext
```

Repeat that final command with `--apply` only after reviewing the preview. Quit/reopen Windows Hermes when its turns are finished. The helper covers the main config and `localdesktop` profile. It does not terminate running chats or change their model. Do not delete the Ollama Qwen tag at this stage.

## 8. Make Qwen the normal startup model

Only after the raw API, real Hermes tools, concurrency and required context gates pass, preview the narrowly scoped change to the **existing** `lmstudio.service`:

```bash
python3 "$HOME/ai/tools/qwen38-migration/configure_boot.py" --model-key "$QWEN_KEY" --context "$QWEN_CONTEXT"
```

```bash
python3 "$HOME/ai/tools/qwen38-migration/configure_boot.py" --model-key "$QWEN_KEY" --context "$QWEN_CONTEXT" --apply
```

It backs up the unit, replaces the Nemotron load command with Qwen, keeps Spark-Fast-first ordering, and allows 25 minutes for the existing up-to-15-minute readiness gate plus model startup. It does not restart anything.

Finish test requests, then perform the planned LM Studio restart:

```bash
systemctl --user daemon-reload
systemctl --user restart lmstudio.service
systemctl --user is-enabled lmstudio.service
systemctl --user status lmstudio.service --no-pager
lms ps --json
```

**Pass:** enabled, active/exited (expected for this existing oneshot unit), only Qwen resident with the qualified context and parallel 2, server loopback-only. Rerun the probe. Also test a normal reboot later in your maintenance window before checking off reboot recovery; this guide does not initiate a reboot.

The current unit is a startup recipe, not full daemon supervision: `active (exited)` alone cannot prove the API still works later. Use `lms ps`, an actual response, and the journal to diagnose failures. Do not install an unattended model-reload loop that could fight an intentional drain. No architecture guarantees uninterrupted uptime or no hardware faults.

## 9. Use Qwen from Windows LM Studio without Windows inference

Open **LM Studio on Windows** and sign into the same LM Link account as FirstSpark. The audit found Spark online but no peer devices while the Windows UI was closed; current cross-device reachability must be checked again.

1. In linked devices, select `spark-07a8` as the preferred inference device.
2. Choose the imported remote Qwen. Verify the device badge says Spark, not this PC.
3. If the already-loaded custom alias is exposed, use `qwen38-27b-spark`; do not press another load action that creates a duplicate instance. Check `lms ps` on Spark if uncertain.
4. Send a prompt while watching Spark GPU activity and Windows GPU activity.
5. For Windows Local Gateway/API clients, start Windows LM Studio's server on `127.0.0.1:1234` and verify its `/v1/models` exposes the exact alias. Run the probe from Windows with the default base only after this check; otherwise stop and resolve LM Link alias visibility. Do not replace it with a local-weight fallback.

Useful **Windows PowerShell** checks:

```powershell
lms link status
Invoke-RestMethod http://127.0.0.1:1234/v1/models | ConvertTo-Json -Depth 5
```

`lms link set-preferred-device` requires the actual identifier shown by `lms link status`, not a guessed hostname. The preference is per client machine. Spark-hosted Hermes remains usable when Windows LM Studio is closed; the Windows localhost LM Link API naturally requires Windows LM Studio to be running.

## 10. Finish the other Windows Qwen dependency

**Fresh Brief currently calls Windows Qwen at 08:00 and 20:00 IST.** Its `/api/chat` protocol cannot be pointed unchanged at LM Studio's `/v1/chat/completions`. Follow [[Fresh Brief Spark Qwen Migration Requirements]] for the small native OpenAI transport change and its tests. This is required work before claiming that automatic Windows Qwen load has been eliminated; it was identified and specified, not implemented in this documentation task.

Keep its schedule, cached editions, and successful-coverage cursor. Retaining Qwen locally as rollback while this client is unmigrated is intentional. Choosing a Windows Gemma in Fresh Brief would avoid Qwen specifically but still use the display GPU, so it does not satisfy the stronger desktop-relief goal.

Also review saved Open WebUI/Perplexica model selections: both can reach Windows Ollama, but this audit does not prove they generated the observed requests. Switch or finish old Hermes chats that still select desktop Qwen. Once all dependent clients have moved, unload any idle remaining desktop Qwen with `ollama stop qwen3.8:27b-q4_k_m`; finish its requests first. Keep its files for rollback until the Spark soak and reboot tests pass.

## 11. Nemotron on demand and rollback

With JIT disabled, selecting an unloaded Nemotron should fail clearly instead of adding a third large resident. A deliberate Nemotron session temporarily interrupts Qwen availability: finish Qwen requests, unload **only** `qwen38-27b-spark`, estimate/load Nemotron at its recorded context/parallel, then reverse the switch after finishing. If uninterrupted Qwen and Nemotron are both required, they need separately qualified capacity; this same-GPU switching design cannot promise both simultaneously.

To roll back the trial before promoting boot, stop the manually started daemon, restore the printed server-config backup while stopped, and start the unchanged `lmstudio.service`. To roll back after boot promotion, restore both printed backups. Use the exact paths printed earlier, not an arbitrary newest glob:

```bash
systemctl --user stop lmstudio.service
lms daemon down
# Replace both placeholders with the exact backup paths you recorded.
cp -p '/EXACT/PRINTED/SERVER-CONFIG-BACKUP' "$HOME/.lmstudio/.internal/http-server-config.json"
cp -p '/EXACT/PRINTED/UNIT-BACKUP' "$HOME/.config/systemd/user/lmstudio.service"
systemctl --user daemon-reload
systemctl --user start lmstudio.service
lms ps --json
```

Skip the unit-copy line only if no unit change was made. **Pass:** original Nemotron 1M/parallel 1 restored, `spark-fast` healthy. Qwen GGUF files remain downloaded but unloaded.

Hermes rollback uses its printed backup directory. Preview, then append `--apply`:

```bash
"$HOME/.hermes/hermes-agent/venv/bin/python" "$HOME/ai/tools/qwen38-migration/configure_hermes.py" --home "$HOME/.hermes" --rollback '/EXACT/PRINTED/HERMES-BACKUP-DIRECTORY'
```

Restart affected Hermes backends after finishing turns. Rollback refuses to overwrite later config edits. Restore Windows separately with its own helper/interpreter/home/backup. No weights or services need to be uninstalled.

## Acceptance record

- [x] Live host/model/capacity and current Nemotron concurrency inspected.
- [x] Desktop regression evidence and additional Fresh Brief consumer documented.
- [x] Helper syntax checked; Hermes preview and fixture backup/rollback checks passed.
- [ ] Exact GGUF pair copied and hashes checked on Spark; runtime import accepted.
- [ ] Required Qwen context and two parallel predictions qualified with vLLM active.
- [ ] Plain chat, streaming, structured tools, real Hermes tools, long tasks, and any required vision test passed.
- [ ] Windows stays responsive during active remote Qwen generation.
- [ ] Boot unit promoted; controlled restart and later reboot recovery passed.
- [ ] Both Hermes homes/profiles show each Gemma once and Spark Qwen once; old selections switched.
- [ ] Windows LM Link route visibly executes on Spark.
- [ ] Fresh Brief migration complete; 8 AM/8 PM schedule and saved editions preserved.
- [ ] Overnight/24-hour representative soak passed with acceptable latency, memory and temperature.

## Sources and related guides

- [LM Link remote execution and per-machine preferred device](https://lmstudio.ai/docs/developer/core/lmlink)
- [LM Studio imported model layout](https://lmstudio.ai/docs/app/advanced/import-model)
- [LM Studio GGUF import CLI](https://lmstudio.ai/docs/cli/local-models/import)
- [LM Studio parallel predictions](https://lmstudio.ai/docs/app/advanced/parallel-requests)
- [Unified KV cache and concurrency](https://lmstudio.ai/blog/0.4.0)
- [Manual residency, TTL, and JIT eviction limits](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict)
- [Linux startup](https://lmstudio.ai/docs/developer/core/headless_llmster)
- [Exact Qwen model card](https://huggingface.co/Qwen/Qwen3.8-27B)
- [Alternative Unsloth GGUF files — different quantization](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/tree/main)
- Installed `lms load --help`, `lms get --help`, existing unit and APIs were checked live; they take precedence over older examples for this host.
- [[Qwen Spark Migration Evidence 2026-10-12]]
- [[Fresh Brief Spark Qwen Migration Requirements]]
- [[DGX Spark LM Studio And LM Link Tutorial]]
- [[DGX Spark sparkDash Monitoring Tutorial]]
- [[FirstSpark Standalone LiteLLM Operations]]
- [[Local Setup Index]]
