---
created: 2026-10-26
status: live-qualifying
tags: [dgx-spark, deepseek, tensorfold, exl3, second-spark, third-spark, setup-log]
---

# DeepSeek V4.1 Flash 1017 on the SecondSpark + ThirdSpark pair: setup log

How the DeepSeek lane was installed on 26 Oct 2026, what went wrong and how each problem was fixed. Why this model and recipe: [[DGX Spark DeepSeek V4.1 Flash 1017 Pair Research]]. Measured numbers and the comparison with GLM and Qwen: [[DGX Spark Frontier Model Qualification Results]]. Pair network and the other lanes: [[Three Spark Frontier Pair Handoff]].

## Where it stands

**Live on port 8890** since ~20:06 on 26 Oct (head SecondSpark, worker ThirdSpark). Qualification is under way; GLM is stopped while DeepSeek runs (only one lane fits).

| Step | State |
|---|---|
| 1. Recipe cloned and configured | done |
| 2. Sudo: NFS export, GPU clock limits | done (owner ran the commands; verified) |
| 3. Weights downloaded and merged | done |
| 4. Prepared and started | done: 47 s load, 8.0 / 10.0 GiB free after load, both rails used |
| 5. Qualification against GLM | standard probe, `validate.py`, `bench.py`, 1M needle, minefield done; Hermes A/B running |
| 6. Plus-Ten pack A/B | not started |
| 7. 2-hour soak | not started |
| 8. Swap script, shortcut, boot unit | drafted in the vault, not deployed |
| 9. LiteLLM alias and Hermes model lists | done (pulled ahead of 6–8 so the Hermes A/B runs through the real path) |
| 10. Notes | this file, the results note, the handoff |

## What was installed

| Item | Value |
|---|---|
| Recipe | [MiaAI-Lab/DeepSeek-v4.1-Flash-1017-2x-DGX-Sparks](https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-1017-2x-DGX-Sparks) at **`27741e17`** (24 Oct; still the newest on 26 Oct), in `~/src/frontier/deepseek41-1017-tf` on SecondSpark |
| Engine | BertholomusAI's TensorFold fork `629c524a` + 26 engine and 2 inputs patches, Zig 0.17.0, `-Dsm=121`; image `tensorfold-dsv41:exl3-tp2-928adbd0e57d`, **built locally** (no published image for these pins), copied to ThirdSpark by `prepare.sh` |
| Quantized pack | `Mia-AiLab/DeepSeek-V4.1-Flash-1017-EXL3-EAQ-v1-2.9-bpw@45ee5d0f` (197 GiB, 39 shards) |
| Engram tables | shards 47–48 of `deepseek-ai/DeepSeek-V4.1-Flash-1017@1bae0e10` (190 GiB) plus its `config.json` and `model.safetensors.index.json`; sizes match the release (101,535,150,936 and 101,537,926,640 bytes) |
| Kernel kit | `bertholomus/deepseek-v4.1-tensorfold-tp2-2xgb10@abe07c7d`; 222 of 223 files match its manifest (the image routing bias is 1017's own, which the recipe expects) |
| Container | `dsv41-1017-exl3-tf` on both Sparks, restart policy `no` |
| Logs | `~/.cache/dsv41-tensorfold/logs/` on each Spark; start log `~/src/frontier/dsv41-start.log`; prepare logs `~/src/frontier/dsv41-prepare*.log` |

`scripts/local.sh` (not in git):

```bash
WORKER=snknitin@192.168.102.12
FABRIC_PEER=192.168.102.12
CONTEXT=1048576
PORT=8890                 # GLM 8888, Qwen 8889: one port per lane so an alias never reaches the wrong model
THINKING_BUDGET=16384
REASONING_EFFORT=high     # not max: loops in agent jobs (issues #33, #37)
```

Everything else is the recipe default: 4 requests at once, FP8 KV, drafts on (DSpark), `MIN_AVAIL_GIB=112`, engine reserve 12.2 GiB, memguard floor 2.5 GiB (kills a rank below it for 4 s, or below 1 GiB at once), sampling temperature 1.0 / top_p 0.95 / top_k 20 unless a request sets its own.

Start / stop on SecondSpark: `cd ~/src/frontier/deepseek41-1017-tf && PATH=$HOME/.local/bin:$PATH ./start.sh` · `./stop.sh`.

## Timeline (26 Oct, IST)

| Time | What happened |
|---|---|
| 15:54 | Pair checked: GLM live, 3.1 TB free on SecondSpark, 3.2 TB on ThirdSpark; `nfs-kernel-server` missing on SecondSpark; `~/.cache/huggingface/hub/.locks` root-owned |
| 15:55 | Recipe cloned at `27741e17`, `local.sh` written |
| 15:57 | Pack and Engram download started into a staging cache `~/hf-staging-dsv41/hub` (the root-owned `.locks` blocks `hf` in the main cache); measured **38 MB/s**, the full 300 Mb/s line |
| 16:02–16:40 | While downloading: qualify script given `FLOOR_GIB` / `LOOP_EFFORT` / `RUNGS` overrides; the Hermes coding A/B harness built (`scripts/pair-hermes-ab/`) and GLM's baseline run (6/6 pass) |
| afternoon | Owner ran the sudo commands; NFS export and clock limits verified (a root container on ThirdSpark read the cache over NFS; SM clock 2190 MHz on both) |
| ~19:04 | Download finished (Engram 3 h 7 min) |
| 19:41 | Merged into the main cache; 0 broken links |
| 19:42 | GLM stopped (idle, no requests cut); 117.7 / 118.1 GiB free |
| 19:43–19:52 | `prepare.sh` attempts 1 and 2 stopped (see below) |
| 19:53–20:06 | `prepare.sh` attempt 3: **776 s** to build the kit, both rank weight files and the worker's Engram copy |
| ~20:06 | `start.sh`: live in **47 s** |
| 20:07 | Qualification started from FirstSpark |

## What went wrong and how it was fixed

| # | Problem | Cause | Fix | Lesson |
|---|---|---|---|---|
| 1 | `hf` refused to download into `~/.cache/huggingface/hub` | `hub/.locks` on SecondSpark is owned by root (left over from 30 Sep) | Downloaded into `~/hf-staging-dsv41/hub` and moved the repos in afterwards (neither existed in the main cache) | Permanent fix needs sudo: `sudo chown -R snknitin:snknitin /home/snknitin/.cache/huggingface/hub/.locks` (offered, not run) |
| 2 | After the move, 43 snapshot links were broken | hf 2.x keeps Xet downloads in a **shared blob store** `hub/blobs/<2 chars>/<sha256>` (with `.refs` and `.lock` files beside each blob); moving only the `models--…` folders left the blobs in staging | Merged the shared store file by file with `mv -n` (129 files, none already present); 0 broken links afterwards | When merging an hf 2.x cache, move `hub/blobs/` too, and check links with `find -L <repo>/snapshots -type l` (lists only broken ones) |
| 3 | The 300 Mb/s line was full for ~3 h | Line speed, not the LAN (SecondSpark's LAN port is at 1000 Mb/s) | None possible; measured 37–38 MB/s throughout | Plan big downloads for when nobody needs the internet; nothing from the old DeepSeek V4.1 could be reused (deleted 16 Oct, and a different release) |
| 4 | Worker's containers would be refused by NFS | `~/.cache/huggingface` is mode 700 and NFS maps a client's root to `nobody` | Export with `all_squash,anonuid=1000,anongid=1000` (read-only, one address: `192.168.102.12`) | The recipe's README export line (`ro,no_subtree_check`) assumes a world-readable cache |
| 5 | `prepare.sh` stopped: "`hf` is not installed" | `hf` is in `~/.local/bin`, which a non-interactive ssh shell doesn't put on PATH; the recipe calls `hf` even when the files are present | Ran it with `PATH=$HOME/.local/bin:$PATH` | Launch `prepare.sh` / `start.sh` over ssh with that PATH |
| 6 | `prepare.sh` stopped: Engram's `model.safetensors.index.json` missing | The Engram step needs the base repo's `config.json` and index as well as shards 47–48; only the shards had been downloaded | Downloaded the two small files (7.5 MB) into staging and merged them by name | Read `prepare.sh`'s `--include` list before downloading by hand |
| 7 | A merge command expanded a wildcard against the **main** cache | A `*/*` loop on an already-empty staging folder stayed a literal pattern; bash then expanded it against `hub/blobs` | GNU `mv` refused before moving anything ("Not a directory", the last argument was a file); every model checked afterwards: 0 broken links for GLM, its drafter, Qwen and both DeepSeek repos | Name files explicitly, or `shopt -s nullglob`, when moving inside a model cache |
| 8 | Two background watchers waited on the wrong process | `pgrep -f "<pattern>"` inside `bash -c '…<pattern>…'` matches its own command line | Watched the real PID (`kill -0 <pid>` loop) | Use `pgrep -x -f "<exact command>"` or `ps … | grep "[x]yz"` |
| 9 | The image build could freeze the head if run while GLM was loaded | Zig build with `-j20` plus `nvcc`, and only 4.5 GiB free on the head with GLM resident | Stopped GLM first, then ran `prepare.sh` | A Spark that runs out of memory freezes (power cycle); never build next to a resident lane |
| 10 | `tools/validate.py` got "connection refused" | It takes the base URL as its first argument and defaults to `:8888` (GLM's port); it does not read `local.sh` (`bench.py` does) | `python3 -I tools/validate.py http://127.0.0.1:8890 --model DeepSeek-V4.1-Flash-1017` | Pass the URL to every recipe tool |
| 11 | A memory sampler wrote awk errors instead of numbers; a `pkill -f` killed its own ssh session | Nested single quotes in a heredoc sent through `ssh '…'` broke the script's awk lines; `pkill -f "<pattern>"` matched the ssh command line that contained the pattern | Wrote the script locally and sent it over stdin (`ssh … 'cat > file' < file`); bracketed patterns (`[m]em-sample.sh`) | Don't write scripts with quotes through a quoted ssh command |

## Measured so far

Details and the comparison table: [[DGX Spark Frontier Model Qualification Results]].

- Load 47 s; `MemAvailable` after load 8.0 GiB head / 10.0 GiB worker; model 104.96 GiB a rank.
- One short request moved +75 MB each way on **both** RoCE rails (`rocep1s0f0`, `roceP2p1s0f0`), split evenly.
- Identity, chat, tool call, vision: pass. Prose C1 **69.1 tok/s**, code C1 **99.1 tok/s**; C4 183.7 / 229.0.
- Loop check at `reasoning_effort: max`: all three stop on their own with correct answers.
- Retrieval: 30,019 tokens in 12.5 s, 195,019 in 72.6 s, **790,019 in 295.1 s**: the standard qualification passed (`GLM_PAIR_QUALIFY_PASS`, 20:07–~20:30).
- Lowest `MemAvailable` over the qualification 5.7 GiB head / 9.3 GiB worker; no kernel memory or Xid errors.

## Routing (step 9, 26 Oct)

- LiteLLM on FirstSpark: `deepseek41-flash-pair` → `openai/DeepSeek-V4.1-Flash-1017` at `http://192.168.100.11:8890/v1`, added after `qwen38-flash-pair` (backup `~/ai/services/litellm/config.yaml.bak-20261026-pre-deepseek41-pair`), `docker restart spark-litellm`: healthy, `/v1/models` lists `qwen3.6-35b-a3b`, `glm53-flash`, `qwen38-flash-pair`, `deepseek41-flash-pair`; the alias answered, and the 35B still answers.
- Hermes: `deepseek41-flash-pair` (`context_length: 1048576`) added under `qwen38-flash-pair` in the `local-models` list of `~/.hermes/config.yaml`, `profiles/creator` and `profiles/agents-board-prep` (two lines each; YAML parses); `custom:http://127.0.0.1:4000/v1#11bc07540439304b` cleared from the main `provider_models_cache.json` (the profiles had none). Backups `~/.hermes/backups/deepseek41-pair-20261026/`. Default models unchanged.
- Verified: a Hermes `custom:local-models` / `deepseek41-flash-pair` one-shot ran `sha256sum` through its terminal tool, wrote `hashes.txt` with both correct hashes and returned `HERMES_DEEPSEEK_PAIR_OK` in 19 s; `session_model_usage` shows only `deepseek41-flash-pair` (3 calls), no fallback.
- While GLM or Qwen holds the pair, this alias returns a connection error, and vice versa.

## Still to do

Steps 5 (rest) to 10 above. Owner decisions pending: deleting whichever pack loses the step 6 A/B, enabling the boot unit (needs `sudo loginctl enable-linger snknitin`), and freeing `~/hf-staging-dsv41` (only empty `.lock` files are left).
