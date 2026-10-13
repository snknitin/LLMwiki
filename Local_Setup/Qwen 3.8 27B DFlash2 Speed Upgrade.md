---
created: 2026-10-13
updated: 2026-10-13
status: q4-dflash2-live-verified-below-50-toks
tags: [qwen, dgx-spark, dflash2, performance]
---

# Qwen 3.8 27B DFlash2 Speed Upgrade

## Q4 implementation and measured limit — 2026-10-13

FirstSpark now serves the pinned official `ggml-org/Qwen3.8-27B-GGUF:Q4_K_M` target with the matching Q4 DFlash2 assistant, DFlash draft maximum 7, and confidence cutoff 0.1. It exposes two independent 262K sessions through the unchanged Hermes alias `qwen38-27b-spark`. The target is 18,973,870,528 bytes with SHA-256 `c600de0300ae8a0eb3a6c0b8b5561b8b96f16bd2c863c2a66c42de29d391a747`; the Q4 assistant is 1,094,346,080 bytes with SHA-256 `0a994382adf17c720c9e5d4292f57344f3b445f058d3e9d5b0f601ae7d6ca3c4`.

The fastest transfer route was Hugging Face to SecondSpark at about 34 MiB/s, then ConnectX-7 to FirstSpark at roughly 500–900 MiB/s. Direct Hugging Face and Windows-to-FirstSpark transfers were both near 1 MiB/s. The Q4 target, Q4/Q8/BF16 DFlash assistants, and matching MTP draft were hash-verified on both ends. Q5 and every rollback copy remain preserved.

The fixed 128-token comparison on the same prompts measured:

| Valid configuration | Thinking | Non-thinking |
|---|---:|---:|
| Q4 target + Q4 DFlash7, confidence 0 | 21.80 tok/s | 29.39 tok/s |
| Q4 target + Q8 DFlash7 | 21.32 tok/s | 26.86 tok/s |
| Q4 target + BF16 DFlash7 | 19.92 tok/s | 25.23 tok/s |
| Q4 target + Q4 DFlash7, confidence 0.1 (live) | 22.22 tok/s | **29.59 tok/s** |
| Q4 target + Q4 DFlash7, confidence 0.3 | 22.83 tok/s | 28.37 tok/s |
| Q4 target + external MTP2 | 21.14 tok/s | 23.60 tok/s |

A 512-token steady-state check of the live winner measured 23.59 tok/s thinking and 29.23 tok/s non-thinking. A diagnostic-only perfect synthetic-acceptance run reached 54.52 and 63.45 tok/s, proving that the runtime and target can cross 50 only if the drafter accepts almost every token; its output was intentionally invalid and it was removed immediately. Real DFlash accepted roughly 27–36% of drafted tokens on these prompts. Q8 and BF16 did not improve acceptance and cost more draft time. The requested general-output floor above 50 tok/s is therefore **not achieved by the available Q4 DFlash2 weights on one DGX Spark**; no synthetic setting is left enabled.

The live valid profile passed plain API, required-tool round-trip, two overlapping streams, and the real Hermes production route with no fallback. Each session retains 262,144 tokens, idle `MemAvailable` was about 25 GiB, and the two-stream test minimum was 25.49 GiB. Evidence and rollback configuration are in `/home/snknitin/runs/qwen38-native/q4-speed-20261013T095951Z/` and `/home/snknitin/ai/tools/qwen38-migration/backups/two-slot-q4-q8-20261013T101404Z/`.

### Workstation Ollama comparison

The retained workstation `qwen3.8:27b-q4_k_m` is also selectable from Spark Hermes as `custom:desktop-ollama:qwen3.8:27b-q4_k_m` through tailnet-only Tailscale Serve. Its Q4_K_M package digest is `25b843619e944cd0ae6069f94ff4e5e26a16e109ccbc0a66a0f05979ed70098e`, and Ollama loaded it with a 262,144-token context entirely in 33,814,552,246 bytes of VRAM allocation.

On the same 512-token prompt used above, streamed from FirstSpark through the private Tailscale route, the workstation produced **55.51 tok/s non-thinking** and **56.86 tok/s thinking** when warm. The initial cold request still decoded at 54.84 tok/s but took 7.90 seconds to emit its first token while the model loaded. A real Spark Hermes one-shot through `custom:desktop-ollama` returned the exact requested marker. Receipts are `/home/snknitin/runs/qwen38-native/desktop-ollama-qwen-speed-20261013.json`, `desktop-ollama-qwen-speed-warm-20261013.json`, `desktop-ollama-qwen-speed-thinking-20261013.json`, and `desktop-ollama-qwen-catalog-20261013.json`.

## Previous Q5 implemented result — 2026-10-13

Q5 + DFlash2 draft3 is now live on FirstSpark. The Q5 target, four independent 262K contexts, Q4 target caches, Hermes provider and model alias are unchanged. The matching assistant was verified at 1,094,346,080 bytes with SHA-256 `0a994382adf17c720c9e5d4292f57344f3b445f058d3e9d5b0f601ae7d6ca3c4` before it was published.

The fixed 128-token comparison measured:

| Mode | Q5 baseline | Q5 + DFlash2 draft3 | Change |
|---|---:|---:|---:|
| Thinking | 10.24 tok/s | 19.38 tok/s | 1.89x |
| Non-thinking | 10.22 tok/s | 22.24 tok/s | 2.18x |

The API/tool/four-stream receipt and the real Hermes route receipt both passed. The four-stream test reached a 12.26 GiB minimum `MemAvailable`, just above the 12 GiB safety floor. DFlash metrics after qualification showed 1,683 drafted tokens, 1,146 accepted tokens and 562 verification steps. Both Qwen units are active and enabled, and the admission endpoint is healthy with four 262K slots.

Evidence and the exact rollback copy are in `/home/snknitin/runs/qwen38-native/speed-20261013T091623Z/`. Test this Q5 deployment in normal Hermes work before considering Q4. Do not raise the draft maximum to seven with the current memory margin.

The sections below are retained as the implementation and rollback procedure. Do not rerun the original installer, main-model download or CUDA build.

The service originally had Q5 weights, four independent 262K contexts, Q4 target caches and speculation disabled. The completed implementation changed only speculation to `draft-dflash`, added the pinned matching assistant and set the draft maximum to three.

Keep Q5 for this first trial. Start with **three drafted tokens**: this is DFlash2 with a smaller verification block. Draft7 adds approximately 5.2 GiB or more over the baseline and is likely to exceed the preserved memory margin alongside SparkFast. Draft3 adds approximately 2.8 GiB before additional buffers. If Q5+DFlash3 remains too slow, Q4+DFlash7 is the next separate trial; do not download Q4 yet.

## 1. Copy the downloaded assistant — Windows PowerShell

Run in **Windows PowerShell**. This transfers the new assistant only, using the checked Ethernet address and existing trusted Spark host identity.

~~~powershell
$speedSshConfig = "$env:LOCALAPPDATA\NVIDIA Corporation\Sync\config\ssh_config"
$speedDraftFile = Join-Path $env:TEMP 'codex-qwen38-dflash2\dflash-Qwen3.8-27B-Q4_0.gguf'
if (!(Test-Path -LiteralPath $speedDraftFile)) { throw 'Assistant file is missing. Use the fallback in section 2.' }
if ((Get-Item -LiteralPath $speedDraftFile).Length -ne 1094346080) { throw 'Assistant file has the wrong size.' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $speedDraftFile).Hash.ToLowerInvariant() -ne '0a994382adf17c720c9e5d4292f57344f3b445f058d3e9d5b0f601ae7d6ca3c4') { throw 'Assistant hash does not match.' }
scp -F $speedSshConfig -o HostName=192.168.0.101 -o HostKeyAlias=spark-07a8.local -X nrequests=256 -X buffer=262144 $speedDraftFile FirstSpark:/home/snknitin/ai/stores/models/ggml-org-Qwen3.8-27B-DFlash2/dflash-Qwen3.8-27B-Q4_0.gguf.scp-incoming
if ($LASTEXITCODE -ne 0) { throw 'Copy failed; do not continue to model loading.' }
~~~

The Ethernet SSH route returned **spark-07a8** during verification. Windows OpenSSH supports the transfer options shown. Away from this LAN, remove only the two options specifying HostName and HostKeyAlias; keep the saved FirstSpark configuration.

Connect to Spark:

~~~powershell
ssh -F $speedSshConfig FirstSpark
~~~

**All remaining commands are FirstSpark Bash commands. Keep this same SSH terminal open.**

## 2. Verify and publish the assistant — FirstSpark Bash

~~~bash
cd /home/snknitin/ai/tools/qwen38-migration
hostname
~~~

Expected host: **spark-07a8**. Stop on any other host.

If the Windows temporary file was missing, use this fallback **instead of section 1's copy**, then run the verification block below. The former Spark downloader is stopped and its completed chunks remain resumable. This route was slower during preparation.

~~~bash
python3 download_dflash2.py --workers 8
~~~

Otherwise, skip that download. Verify the completed copy and create the receipt required by the launcher:

~~~bash
python3 - <<'PY'
import hashlib, json
from pathlib import Path
root = Path('/home/snknitin/ai/stores/models/ggml-org-Qwen3.8-27B-DFlash2')
final = root / 'dflash-Qwen3.8-27B-Q4_0.gguf'
incoming = root / (final.name + '.scp-incoming')
source = final if final.is_file() else incoming
assert source.is_file(), 'Assistant missing: finish the copy or fallback download'
assert source.stat().st_size == 1094346080, 'Copy incomplete or wrong size'
with source.open('rb') as stream:
    digest = hashlib.file_digest(stream, 'sha256').hexdigest()
assert digest == '0a994382adf17c720c9e5d4292f57344f3b445f058d3e9d5b0f601ae7d6ca3c4', 'Hash mismatch'
if source != final:
    source.replace(final)
final.chmod(0o600)
receipt = root / 'verified-sha256.json'
verified = json.loads(receipt.read_text()) if receipt.exists() else {}
verified[final.name] = digest
tmp = receipt.with_suffix('.tmp')
tmp.write_text(json.dumps(verified, indent=2) + '\n')
tmp.chmod(0o600)
tmp.replace(receipt)
print('PASS: matching DFlash2 assistant verified and ready')
PY
~~~

Required output: **PASS: matching DFlash2 assistant verified and ready**.

## 3. Finish Qwen chats and record an idle baseline

Finish or cancel active Qwen jobs in Hermes. Submit no new Qwen work until section 7. Check the admission endpoint:

~~~bash
python3 - <<'PY'
import json
from urllib.request import urlopen
with urlopen('http://127.0.0.1:1235/health', timeout=10) as response:
    status = json.load(response)
print(status)
assert status['active'] == 0 and status['queued'] == 0, 'Qwen still has work'
PY
~~~

Create a unique results directory and measure before changing anything:

~~~bash
export QWEN_SPEED_RUN="/home/snknitin/runs/qwen38-native/speed-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$QWEN_SPEED_RUN"
python3 measure_interactive_speed.py --label q5-none --output "$QWEN_SPEED_RUN/baseline.json"
printf '%s\n' "$QWEN_SPEED_RUN"
~~~

Save the printed directory path. The probe tests thinking and non-thinking requests against Qwen and SparkFast. Its 128-token cap is **only a benchmark setting**; production output stays uncapped. A thinking test can exhaust that budget before visible answer text, so a null first-visible time is not itself a failure. Compare equivalent modes before/after. Other active requests make the results contention measurements rather than isolated throughput.

## 4. Back up configuration and enable Q5 + DFlash2

This briefly stops only the Qwen worker and admission service. SparkFast remains available.

~~~bash
systemctl --user stop qwen38-admission.service qwen38-native.service
~~~

Run this block once. It refuses a different target or an already-changed accelerator setting, and retains every other setting:

~~~bash
python3 - <<'PY'
import json, os
from pathlib import Path
path = Path('/home/snknitin/ai/tools/qwen38-migration/native-config.json')
raw = path.read_bytes()
config = json.loads(raw)
assert config['model_sha256'] == '8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276', 'Current Q5 required'
assert config['speculation'] == 'none', 'Accelerator already changed: inspect first'
backup = Path(os.environ['QWEN_SPEED_RUN']) / 'native-config.before.json'
with backup.open('xb') as destination:
    destination.write(raw)
backup.chmod(0o600)
config.update(
    speculation='draft-dflash',
    draft_model='/home/snknitin/ai/stores/models/ggml-org-Qwen3.8-27B-DFlash2/dflash-Qwen3.8-27B-Q4_0.gguf',
    draft_model_sha256='0a994382adf17c720c9e5d4292f57344f3b445f058d3e9d5b0f601ae7d6ca3c4',
    draft_revision='71bc7b627595dc8a91039addd9c791ae548d6747',
    draft_max=3,
)
tmp = path.with_suffix('.tmp')
tmp.write_text(json.dumps(config, indent=2) + '\n')
tmp.chmod(0o600)
tmp.replace(path)
print('Configuration staged; backup:', backup)
PY
~~~

Inspect the generated launch command:

~~~bash
python3 run_native_qwen.py --print-command
~~~

Required settings: speculation **draft-dflash**, matched draft-model path, draft maximum **3**, draft GPU layers **all**, draft K/V **q8_0**. Target K/V remain **q4_0** and the main-model path remains Q5.

Start and wait for readiness:

~~~bash
python3 -c 'from finish_native_install import reset_worker_start_limits; reset_worker_start_limits()'
systemctl --user start qwen38-native.service qwen38-admission.service
python3 -c 'from finish_native_install import wait_health; wait_health(900)'
curl --fail http://127.0.0.1:1235/health
~~~

The launcher still requires at least 52 GiB available before loading. The readiness wait is bounded at 15 minutes. Expected health: accepting true, max-active 4, pool-tokens 1048576, per-request-tokens 262144.

If startup fails, inspect the errors and use section 7's rollback:

~~~bash
journalctl --user -u qwen38-native -u qwen38-admission -n 60 --no-pager
~~~

## 5. Check real acceleration and memory

~~~bash
journalctl --user -u qwen38-native -n 120 --no-pager | rg 'draft-dflash|block_size|n_extract|speculat|error|failed'
free -h
~~~

Expected draft initialization includes **draft-dflash**, trained block-size **8**, and n-extract **5**. The runtime calls both DFlash and DFlash2 draft-dflash; the matched assistant's selector identifies DFlash2 internally. The three-token maximum limits verification length.

At least **12 GiB MemAvailable** must remain during the trial. In a second Spark terminal, monitor:

~~~bash
watch -n 1 free -h
~~~

If available memory falls below 12 GiB, stop the Qwen pair and roll back with section 7. Do not lower the floor to force a passing result. Keep LM Studio stopped and avoid other large model loads.

## 6. Measure speed and verify requests

Run the identical benchmark:

~~~bash
python3 measure_interactive_speed.py --label q5-dflash2-draft3 --output "$QWEN_SPEED_RUN/dflash3.json"
~~~

Verify real drafting instead of trusting the configuration label:

~~~bash
curl --fail http://127.0.0.1:1236/metrics | rg 'spec_decode_num_(draft_tokens|accepted_tokens|drafts)_total'
~~~

Drafted **and accepted** token counters must exceed zero. Acceptance alone is not proof of a speed gain.

Print the before/after table:

~~~bash
python3 - <<'PY'
import json, os
from pathlib import Path
root = Path(os.environ['QWEN_SPEED_RUN'])
for name in ['baseline.json', 'dflash3.json']:
    data = json.loads((root / name).read_text())
    print('\n' + name)
    for row in data['checks']:
        print(row['model'], 'thinking=' + str(row['thinking']),
              'tokens/s=' + str(row['stream_decode_tokens_per_second']),
              'first output=' + str(row['first_output_seconds']),
              'total=' + str(row['total_seconds']))
PY
~~~

Run the existing API/tool/four-stream test and main-profile request check:

~~~bash
python3 probe_qwen.py --base http://127.0.0.1:1235/v1 --parallel 4 --output "$QWEN_SPEED_RUN/api-tools-four.json"
~/.hermes/hermes-agent/venv/bin/python probe_hermes_production.py --run --timeout 600 --output "$QWEN_SPEED_RUN/hermes-route.json"
~~~

Required: both receipts passed true, memory minimum at least 12 GiB, and the real Hermes answer correct. Compare an actual short coding task too. DFlash mainly improves generation; cold large-prompt processing remains. **Do not call this fast merely because it starts.** Look for a substantial measured gain—ideally twice your own idle baseline—and acceptable whole-task latency.

The initial real Hermes measurements were approximately 6–9 tokens/second. This exact Spark/Q5/DFlash2 combination has not yet been benchmarked. There is no 45-minute context test in this first speed trial; full-context accelerated workloads still require qualification after choosing the candidate.

## 7. Keep the winner or roll back

If acceleration, speed, API/tool correctness and memory pass, both units are already enabled. Keep the configuration and select **FirstSpark Qwen 3.8 27B (llama.cpp)** / **qwen38-27b-spark** in Hermes. No provider migration or Hermes restart is needed for this backend change.

If it fails or remains too slow, restore the exact saved configuration. Use the same SSH terminal so QWEN_SPEED_RUN still points to your results:

~~~bash
systemctl --user stop qwen38-admission.service qwen38-native.service
python3 - <<'PY'
import json, os
from pathlib import Path
source = Path(os.environ['QWEN_SPEED_RUN']) / 'native-config.before.json'
raw = source.read_bytes()
original = json.loads(raw)
assert original['speculation'] == 'none'
assert original['model_sha256'] == '8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276'
dest = Path('/home/snknitin/ai/tools/qwen38-migration/native-config.json')
tmp = dest.with_suffix('.tmp')
tmp.write_bytes(raw)
tmp.chmod(0o600)
tmp.replace(dest)
print('Original Q5 configuration restored')
PY
python3 -c 'from finish_native_install import reset_worker_start_limits; reset_worker_start_limits()'
systemctl --user start qwen38-native.service qwen38-admission.service
python3 -c 'from finish_native_install import wait_health; wait_health(900)'
~~~

After reopening SSH, set QWEN_SPEED_RUN to the exact directory saved in section 3 before rollback. Do not guess a backup path or restore over later unrelated edits.

Q4 target weights remain a permitted next option, not an action in this guide. Keep the benchmark JSON files to decide whether Q5+DFlash2 is useful or Q4 plus a larger draft block is worth testing.

## Prepared assets and references

- Launcher: /home/snknitin/ai/tools/qwen38-migration/run_native_qwen.py. Matching-draft and target guards passed ten fixtures; runtime acceleration and speed are not yet tested.
- Original launcher backup: /home/snknitin/ai/tools/qwen38-migration/backups/launcher-dflash-20261013T043206.567195Z/.
- Draft: ggml-org/Qwen3.8-27B-GGUF, revision 71bc7b627595dc8a91039addd9c791ae548d6747, 1,094,346,080 bytes; SHA-256 specified above.
- [Pinned assistant repository](https://huggingface.co/ggml-org/Qwen3.8-27B-GGUF/tree/71bc7b627595dc8a91039addd9c791ae548d6747), [DFlash2 author model card](https://huggingface.co/incoai/Qwen3.8-27B-DFlash2). Published acceleration measurements use different hardware/runtime.
- [[Qwen 3.8 27B Native Spark Setup Tutorial]] retains the original installation and capacity evidence. This document is the active manual speed-up procedure.
