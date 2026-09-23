---
updated: 2026-09-22
status: implement-after-model-validation
scope: dgx-spark, litellm, hermes, hot-swap, model-manager, dual-node
---

# DGX Spark Frontier Model Hot-Swap And Routing Guide

> [!summary] Outcome
> Keep Qwen 3.8 NVFP4, Qwen 3.8 official FP8, GLM 5.3 Flash, and DeepSeek V4.1 Flash installed and permanently named in LiteLLM/Hermes. A cluster-aware command hot-swaps the resident two-node backend, waits for health, restores LiteLLM/Hermes, selects the matching Hermes default, and preserves `spark-fast` as rollback.

This guide implements the user's required end state: the new frontier models behave like the existing `spark-fast`, `qwen27-dflash`, and `nemotron3-omni` choices from the client perspective, while respecting the fact that only one large dual-node model can be resident.

> [!important] FirstSpark routing changed on 2026-09-22
> FirstSpark ODS was retired. LiteLLM now runs independently from `$HOME/ai/services/litellm` as `spark-litellm` on `127.0.0.1:4000`; the model services use `spark-model-net`. The old ODS `.env`, `ods` command, and `ods-network` no longer exist on FirstSpark. The separate workstation ODS installation is outside this guide.

## Required order

Before changing routing, complete the shared readiness and monitoring setup:

1. [[DGX Spark Dual-Node Community Frontier Models Runbook]] readiness gate.
2. [[DGX Spark sparkDash Monitoring Tutorial]]

Then complete the individual tutorial **only for each lane you intend to register**: [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]], [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]], or [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]]. A lane may be registered after its own direct and coexistence gates pass; all four do not need to pass on the same day. Never register an untested backend merely to make it appear in a model list.

> [!tip] Beginner execution rule
> Perform this guide from the `FirstSpark` SSH terminal. **Each code block is one action:** copy one block, wait for its command to return to the shell prompt, check its **Pass/Stop** text, and only then move to the next block. Never copy across blocks. A file-install block may contain several lines because they form one installation action; a model-switch block contains exactly one switch. Do not install the switch command until you have manually started, tested, stopped, and rolled back every lane you intend to register. The model names remain visible in LiteLLM/Hermes when cold, but you must run `spark-frontier use <name>` and wait for success before selecting that model for a session.

## What “available” means

| State | Meaning |
|---|---|
| Installed | Source, image, and weights are present |
| Registered | A stable LiteLLM/Hermes alias exists |
| Cold | Registered but not resident; requests to it must not be sent yet |
| Warming | The cluster switch command is loading both ranks |
| Raw-ready | Both ranks and port `8100` are healthy, but LiteLLM/Hermes are still closed |
| Active | Raw identity, matching LiteLLM alias, and Hermes routing have all passed |
| Rollback | Frontier rank pair is stopped and `spark-fast` is restored |

LiteLLM does not start a 125–400 GiB model in response to an API request. Always run the hot-swap command before selecting a cold alias in Hermes.

## Permanent names

| Switch target | LiteLLM/Hermes alias | Upstream model on port 8100 | Context metadata after validation |
|---|---|---|---:|
| `qwen38-nvfp4` | `qwen38-nvfp4` | `qwen3.8-flash-next` | 262,144 |
| `qwen38-fp8` | `qwen38-fp8` | `qwen3.8-flash-next-fp8` | 262,144 |
| `glm53-flash` | `glm53-flash` | `GLM-5.3-Flash-EXL3` | Use the accepted profile: 500,000 or 850,000 |
| `deepseek41-flash` | `deepseek41-flash` | `DeepSeek-v4.1-Flash-EXL3` | Use the accepted profile: 131,072, 262,144, or 600,000 |

Do not rename `spark-fast`. Do not use one mutable `spark-frontier` alias as the only client identity; distinct aliases preserve session intent and make errors diagnosable.

> [!important] GLM operating profile is a deployment decision
> `glm53-flash`, `glm53-flash-mtp-850k`, and `glm53-flash-dflash-500k` are **qualification result profiles**, not automatically three LiteLLM aliases. Complete Step 16 of [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]] and choose **one fully accepted** operating profile. Keep the three named, API-key-bearing configurations under `~/.config/frontier/glm53-profiles/`: DFlash/850K uses GMU `0.87` and the 512 MiB InstantTensor buffer; MTP/850K uses GMU `0.87`, that buffer, and `INSTANTTENSOR_MAX_FREE_MEM_USAGE=0.75`; DFlash/500K uses GMU `0.86` and the buffer. The old DFlash/500K `0.84` setting failed this pair's KV-cache startup gate. After qualification, freeze the chosen profile as private `accepted.env` in Step 5. The switch manager reinstalls that file before **every** GLM hot-swap and derives Hermes context from its `MAX_MODEL_LEN`; it never trusts a leftover recipe `.env` or defaults to 500K. Do not leave API-key-bearing `.env.*` copies unignored in the Git checkout. Register extra public aliases only if the switch manager can select and validate their corresponding configurations deterministically.

## Resource policy for normal hot-swaps

The raw qualification shuts down all nonessential services. Normal routed use adds only the control plane that passed A/B testing:

- `spark-litellm`;
- `hermes-serve.service`;
- `hermes-gateway.service`;
- optionally sparkDash for lanes whose dashboard-on memory A/B passed.

The retired ODS stack is absent from FirstSpark. Keep the standalone LiteLLM and Hermes control plane within the lane's measured low-water margin.

If a lane cannot pass the same long-context/load test with LiteLLM and Hermes running, it is not eligible for this guide. Keep it as a raw research lane instead of presenting it as a usable Hermes choice.

## Step 1 — Back up routing and manager state

Run on **FirstSpark**:

```bash
stamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$HOME/backups/frontier-routing/$stamp"
install -d -m 700 "$backup_dir"
cp -a "$HOME/ai/services/litellm/config.yaml" "$backup_dir/litellm-config.yaml"
cp -a "$HOME/ai/services/litellm/compose.yaml" "$backup_dir/litellm-compose.yaml"
cp -a "$HOME/ai/services/litellm/runtime.env" "$backup_dir/litellm-runtime.env"
cp -a "$HOME/.local/bin/spark-model" "$backup_dir/spark-model"
cp -a "$HOME/.config/spark-model" "$backup_dir/spark-model-config"
if [[ -f "$HOME/.local/bin/spark-frontier" ]]; then
  cp -a "$HOME/.local/bin/spark-frontier" "$backup_dir/spark-frontier"
else
  touch "$backup_dir/no-spark-frontier-before"
fi
cp -a "$HOME/.hermes/config.yaml" "$backup_dir/hermes-config.yaml"
cp -a "$HOME/.hermes/.env" "$backup_dir/hermes.env"
chmod -R go-rwx "$backup_dir"
"$HOME/.local/bin/hermes" config check
printf '%s\n' "$backup_dir"
```

Do not place API-key contents in the backup report.

**Pass:** Hermes reports a valid configuration, the final line is a new timestamped backup directory, and that directory contains the standalone LiteLLM, Hermes, and manager files listed above. Stop if any `cp` command or `hermes config check` fails.

## Step 2 — Verify the standalone LiteLLM key and environment

Run on **FirstSpark**. The 2026-09-22 migration already put the shared frontier key into the private standalone `runtime.env`. Keep it outside the retired ODS schema:

```bash
test -s "$HOME/.config/frontier/api-key"
test -s "$HOME/ai/services/litellm/runtime.env"
stat -c '%a %n' "$HOME/.config/frontier/api-key"   "$HOME/ai/services/litellm/runtime.env"
python3 - <<'PY'
from pathlib import Path
home = Path.home()
def values(path):
    return dict(line.split('=', 1) for line in path.read_text().splitlines() if '=' in line)
runtime = values(home / 'ai/services/litellm/runtime.env')
hermes = values(home / '.hermes/.env')
assert runtime['SPARK_FRONTIER_API_KEY'] == (home / '.config/frontier/api-key').read_text().strip()
assert runtime['LITELLM_MASTER_KEY'] == hermes['HERMES_CUSTOM_127_0_0_1_4000_API_KEY']
print('FRONTIER_AND_HERMES_KEYS_MATCH')
PY
cd "$HOME/ai/services/litellm"
docker compose -p spark-litellm config --quiet
```

The standalone Compose file loads `runtime.env` as a private service environment file. It has no `llama-server` dependency. `docker compose config --quiet` validates its syntax without printing the merged secrets.

**Pass:** both secret files report mode `600`, the check prints `FRONTIER_AND_HERMES_KEYS_MATCH`, and Compose validation exits successfully. Stop before editing routes if any check fails.

## Step 3 — Add all validated LiteLLM aliases

Open:

```bash
nano "$HOME/ai/services/litellm/config.yaml"
```

Under the existing single `model_list:` heading, add one block for each lane that has passed its tutorial. The intended final set is:

```yaml
  - model_name: qwen38-nvfp4
    litellm_params:
      model: openai/qwen3.8-flash-next
      api_base: http://192.168.0.101:8100/v1
      api_key: os.environ/SPARK_FRONTIER_API_KEY

  - model_name: qwen38-fp8
    litellm_params:
      model: openai/qwen3.8-flash-next-fp8
      api_base: http://192.168.0.101:8100/v1
      api_key: os.environ/SPARK_FRONTIER_API_KEY

  - model_name: glm53-flash
    litellm_params:
      model: openai/GLM-5.3-Flash-EXL3
      api_base: http://192.168.0.101:8100/v1
      api_key: os.environ/SPARK_FRONTIER_API_KEY

  - model_name: deepseek41-flash
    litellm_params:
      model: openai/DeepSeek-v4.1-Flash-EXL3
      api_base: http://192.168.0.101:8100/v1
      api_key: os.environ/SPARK_FRONTIER_API_KEY
```

Keep the existing `spark-fast`, `qwen27-dflash`, and `nemotron3-omni` entries. The retired ODS `llama-server` default and wildcard routes were removed during migration. Do not create a second `model_list:` heading.

The live config currently uses `request_timeout: 120` and `stream_timeout: 60`, which is too short for 500K–850K prefill validation. During frontier qualification, set:

```yaml
litellm_settings:
  drop_params: true
  set_verbose: false
  request_timeout: 3600
  stream_timeout: 3600
```

These are client patience limits, not proof that a context fits. Retain the loaded-context memory and correctness gates in each model tutorial.

Protect and validate the file:

```bash
chmod 600 "$HOME/ai/services/litellm/config.yaml"
python3 - <<'PY'
import yaml
p='/home/snknitin/ai/services/litellm/config.yaml'
d=yaml.safe_load(open(p, encoding='utf-8'))
names=[x['model_name'] for x in d['model_list']]
assert len(names)==len(set(names)), names
required_base={'spark-fast','qwen27-dflash','nemotron3-omni'}
known_frontier={'qwen38-nvfp4','qwen38-fp8','glm53-flash','deepseek41-flash'}
assert required_base.issubset(names), (required_base-set(names))
assert known_frontier.intersection(names), 'add at least one validated frontier alias'
print('LITELLM_ROUTE_YAML_OK')
PY
```

If host Python lacks PyYAML, validate through the LiteLLM container after recreation instead of installing into the system Python.

Also edit `$HOME/.hermes/config.yaml`. In the existing `custom_providers` list, keep the `spark-fast` provider's `base_url`, `model`, and `key_env` unchanged. Add only the lanes that have passed; the block below shows the intended final mapping after all four pass, so omit any unvalidated frontier entry for now:

```yaml
custom_providers:
  - name: spark-fast
    base_url: http://127.0.0.1:4000/v1
    model: spark-fast
    key_env: HERMES_CUSTOM_127_0_0_1_4000_API_KEY
    models:
      spark-fast:
        context_length: 262144
      nemotron3-omni:
        context_length: 131072
      qwen38-nvfp4:
        context_length: 262144
      qwen38-fp8:
        context_length: 262144
      glm53-flash:
        context_length: 500000
      deepseek41-flash:
        context_length: 262144
```

Preserve any other existing model entries, including `qwen27-dflash`. Set GLM/DeepSeek metadata to the context that actually passes; the values above are conservative starting metadata. Then run:

```bash
"$HOME/.local/bin/hermes" config check
```

**Pass:** the LiteLLM validator prints `LITELLM_ROUTE_YAML_OK`, Hermes reports a valid configuration, and every newly listed frontier alias has already passed its individual tutorial. Stop if an alias is duplicated, missing from its matching Hermes mapping, or not yet validated.

## Step 4 — Recreate standalone LiteLLM once with the new routes

Run on **FirstSpark**:

```bash
cd "$HOME/ai/services/litellm"
docker compose -p spark-litellm config --quiet
docker compose -p spark-litellm up -d --force-recreate --pull never
docker inspect spark-litellm --format '{{.State.Status}}|{{.State.Health.Status}}'
docker exec spark-litellm /bin/sh -c 'test -n "$SPARK_FRONTIER_API_KEY"'
```

**Pass:** the container becomes `running|healthy`, the in-container key test exits successfully, and no secret value is printed. If the container is unhealthy, inspect `docker logs --tail 120 spark-litellm` after redacting any secret-bearing line.

Confirm every validated alias is advertised:

```bash
key="$(sed -n 's/^LITELLM_MASTER_KEY=//p' "$HOME/ai/services/litellm/runtime.env")"
test -n "$key"
curl -fsS http://127.0.0.1:4000/v1/models   -H "Authorization: Bearer $key"   | python3 -m json.tool
unset key
```

It is normal for aliases to be listed while their backend is cold. Do not send chat to a cold alias.

## Step 5 — Confirm the cluster-aware switch command

The cluster manager is already installed on FirstSpark at `$HOME/.local/bin/spark-frontier`. Its maintained source is the separate `scripts/spark-frontier` file beside this guide. **Do not paste its source, recreate it with `nano`, or copy it again.**

### 5.1 Confirm the command is ready

Run in the **FirstSpark SSH terminal**:

```bash
test -x "$HOME/.local/bin/spark-frontier" && bash -n "$HOME/.local/bin/spark-frontier" && echo SWITCH_COMMAND_READY
```

**Pass:** `SWITCH_COMMAND_READY` appears and the shell prompt returns.

**Stop:** if the marker does not appear. Do not start a model switch.

### 5.2 Confirm the accepted GLM profile

The current qualified GLM profile is already frozen for managed switching. Inspect its nonsecret signature:

```bash
grep -E '^(SPEC_METHOD|MAX_MODEL_LEN|GPU_MEM_UTIL)=' "$HOME/.config/frontier/glm53-profiles/accepted.env"
```

**Pass:** the output is exactly:

```text
SPEC_METHOD=mtp
MAX_MODEL_LEN=850000
GPU_MEM_UTIL=0.87
```

**Stop:** missing or different values. Do not select `glm53-flash` until its accepted profile is restored or requalified.

### 5.3 Safety rules enforced by the manager

Every `spark-frontier use <lane>` operation automatically:

1. takes an exclusive switch lock;
2. stops Hermes ingress and standalone LiteLLM before changing the model;
3. proves the prior head and worker compute ranks and distributed ports are gone;
4. identifies the NFS exporter that owns port `2049`;
5. removes a known exporter whose filesystem layout is incompatible with the requested lane;
6. refuses to continue when an unknown service owns NFS port `2049`;
7. requires Qwen's exporter to map `/export` to the verified Hugging Face cache;
8. proves the worker can see the requested checkpoint before starting its model rank;
9. waits for the correct raw model identity, restarts LiteLLM, probes the matching alias, and updates Hermes; and
10. writes `active:<lane>` only after every preceding check passes, otherwise restoring `spark-fast`.

The NFS checks prevent the DeepSeek-exporter/Qwen-cache mismatch that previously caused Qwen FP8 to roll back. Startup logs also hide configured API-key values.

Read the current state without changing anything:

```bash
"$HOME/.local/bin/spark-frontier" status
```

**Pass:** one stable state is shown: `active:<lane>` for a frontier model, or `none` while the rollback model `spark-fast` is active. A `starting:`, `raw-ready:`, or `stopping-old` state means a switch is still in progress; wait for that switch command to return.
## Step 6 — First managed switch: Qwen NVFP4

Use the **FirstSpark SSH terminal**. Copy **one code block at a time**. A two-node model can take more than ten minutes to load. While the switch is running, port `4000` is deliberately unavailable; do not start the next block or send a LiteLLM request yet.

**6.1 Start Qwen NVFP4.** This changes the active model and waits for both ranks and the route:

```bash
"$HOME/.local/bin/spark-frontier" use qwen38-nvfp4
```

**Pass:** the command returns to the shell prompt after printing `Active frontier lane: qwen38-nvfp4; Hermes model: qwen38-nvfp4; context: 262144`. **Stop:** if it reports rollback, fails, or has not returned to the prompt. A quiet terminal during weight loading is normal; check another SSH terminal with the status command below instead of starting a second switch.

**6.2 Inspect the completed switch.** This command only reads state; it does not run the tests in Step 7:

```bash
"$HOME/.local/bin/spark-frontier" status
```

**Pass:** `Desired/transition state: active:qwen38-nvfp4`, head and worker `vllm-fn` ranks, `LiteLLM=healthy`, and Hermes default `qwen38-nvfp4`. **Stop:** if the state says `starting:`, `stopping-old`, `none`, or another model. Wait for the first command to finish or inspect its error.

**6.3 Make one routed LiteLLM request.** The key stays private and the response is checked, not just printed:

```bash
python3 - <<'PY'
from pathlib import Path
import json, urllib.request
env = (Path.home() / "ai/services/litellm/runtime.env").read_text().splitlines()
key = next(line.split("=", 1)[1] for line in env if line.startswith("LITELLM_MASTER_KEY="))
body = {"model": "qwen38-nvfp4", "messages": [{"role": "user", "content": "Reply with exactly QWEN38_ROUTE_OK"}], "temperature": 0, "max_tokens": 128}
request = urllib.request.Request("http://127.0.0.1:4000/v1/chat/completions", data=json.dumps(body).encode(), headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"})
with urllib.request.urlopen(request, timeout=180) as response:
    answer = (json.load(response)["choices"][0]["message"].get("content") or "").strip()
assert answer == "QWEN38_ROUTE_OK", f"STOP: unexpected answer: {answer!r}"
print("QWEN38_ROUTE_OK")
PY
```

**Pass:** `QWEN38_ROUTE_OK`. **Stop:** any traceback or different answer.

**6.4 Test Hermes through the selected route:**

```bash
"$HOME/.local/bin/hermes" -z 'Reply with exactly QWEN38_HERMES_OK'
```

**Pass:** `QWEN38_HERMES_OK`. Continue to Step 7.2 for the structured-tool and managed-load gates.

## Step 7 — Validate each managed model, one at a time

Start this step only after Step 6 has finished and returned you to the shell prompt. On a first run, Qwen NVFP4 should still be active from Step 6.

Run every command in this step in the **FirstSpark SSH terminal**. Each code block is one action:

1. Copy one code block.
2. Wait until it returns to the shell prompt.
3. Read the **Pass/Stop** line beneath it.
4. Continue only after the pass marker appears.

Never paste multiple code blocks together. A model switch can take more than ten minutes. If any command prints `STOP:`, reports rollback, or fails to return the stated pass marker, stop this step and do not switch to the next model.

### What the three commands mean

| Command | What it does | Does it switch models? |
|---|---|---|
| `spark-frontier status` | Displays the current lane, containers, ports, LiteLLM, Hermes settings, and GPU holders | No |
| `spark-frontier-check <lane>` | Sends small real requests through the raw API, LiteLLM, structured tools, and Hermes; checks both model ranks and memory; for Qwen, also proves the NFS exporter and worker checkpoint mount | No |
| `spark-frontier-check <lane> --load` | Repeats the smoke check, then runs the qualified long-context and concurrency tests while monitoring both Sparks | No |
| `spark-frontier use <lane>` | Stops the current two-node model and starts the selected model | **Yes** |

The smoke check proves routing and basic correctness. The `--load` check is the longer acceptance test. A lane is fully validated for managed use only after both commands pass.

### 7.1 Confirm the verifier is ready

The verifier is already installed on FirstSpark at `$HOME/.local/bin/spark-frontier-check`. **Do not copy or install it.** Run only this readiness check:

```bash
test -x "$HOME/.local/bin/spark-frontier-check" && python3 -m py_compile "$HOME/.local/bin/spark-frontier-check" && echo CHECK_COMMAND_READY
```

**Pass:** `CHECK_COMMAND_READY` appears and the shell prompt returns.

**Stop:** if the marker does not appear. Do not continue to 7.2.

### 7.2 Validate Qwen NVFP4

Qwen NVFP4 should already be active from Step 6. Confirm it:

```bash
"$HOME/.local/bin/spark-frontier" status
```

**Pass:** `Desired/transition state: active:qwen38-nvfp4`, `LiteLLM=healthy`, and Hermes default `qwen38-nvfp4`.

**Stop:** if another lane is active, the state is transitional, or LiteLLM is unhealthy. Return to Step 6 instead of continuing.

Run the smoke check:

```bash
"$HOME/.local/bin/spark-frontier-check" qwen38-nvfp4
```

**Pass:** the final line is `SMOKE_PASS qwen38-nvfp4`.

**Stop:** any `STOP:` line or missing pass marker.

Run the long context and concurrency check:

```bash
"$HOME/.local/bin/spark-frontier-check" qwen38-nvfp4 --load
```

**Pass:** the final line is `LOAD_PASS qwen38-nvfp4`, with both reported memory low-water values at least 3 GiB.

**Stop:** any failure, rank loss, memory-floor stop, or missing pass marker. Do not start Qwen FP8.

### 7.3 Validate Qwen FP8

Do this subsection only after the Qwen FP8 tutorial and its release gates have passed.

Switch to Qwen FP8:

```bash
"$HOME/.local/bin/spark-frontier" use qwen38-fp8
```

**Pass:** `Active frontier lane: qwen38-fp8` appears and the shell prompt returns.

**Stop:** rollback, failure, or no completion line.

Run the smoke check:

```bash
"$HOME/.local/bin/spark-frontier-check" qwen38-fp8
```

**Pass:** the final line is `SMOKE_PASS qwen38-fp8`.

**Stop:** any `STOP:` line or missing pass marker.

Run the long context and concurrency check:

```bash
"$HOME/.local/bin/spark-frontier-check" qwen38-fp8 --load
```

**Pass:** the final line is `LOAD_PASS qwen38-fp8`, with both memory low-water values at least 3 GiB.

**Stop:** any failure or missing pass marker. Do not start GLM.

### 7.4 Validate GLM 5.3 Flash

Do this subsection only after the GLM tutorial and its release gates have passed.

Confirm the accepted GLM profile:

```bash
grep -E '^(SPEC_METHOD|MAX_MODEL_LEN|GPU_MEM_UTIL)=' "$HOME/.config/frontier/glm53-profiles/accepted.env"
```

**Pass:** the current qualified profile prints exactly these values:

```text
SPEC_METHOD=mtp
MAX_MODEL_LEN=850000
GPU_MEM_UTIL=0.87
```

**Stop:** missing file or different values. Do not switch to GLM until the accepted profile matches the qualified result.

Switch to GLM:

```bash
"$HOME/.local/bin/spark-frontier" use glm53-flash
```

**Pass:** `Active frontier lane: glm53-flash` appears and the shell prompt returns.

**Stop:** rollback, failure, or no completion line.

Run the smoke check:

```bash
"$HOME/.local/bin/spark-frontier-check" glm53-flash
```

**Pass:** the final line is `SMOKE_PASS glm53-flash`.

**Stop:** any `STOP:` line or missing pass marker.

Run the accepted 850K-profile load check:

```bash
"$HOME/.local/bin/spark-frontier-check" glm53-flash --load
```

**Pass:** the final line is `LOAD_PASS glm53-flash`, with both memory low-water values at least 3 GiB.

**Stop:** any failure or missing pass marker. Do not start DeepSeek.

### 7.5 Validate DeepSeek V4.1 Flash

Do this subsection only after the DeepSeek 600K tutorial profile and its release gates have passed.

Switch to DeepSeek:

```bash
"$HOME/.local/bin/spark-frontier" use deepseek41-flash
```

**Pass:** `Active frontier lane: deepseek41-flash` appears and the shell prompt returns.

**Stop:** rollback, failure, or no completion line.

Run the smoke check:

```bash
"$HOME/.local/bin/spark-frontier-check" deepseek41-flash
```

**Pass:** the final line is `SMOKE_PASS deepseek41-flash`.

**Stop:** any `STOP:` line or missing pass marker.

Run the qualified 600K-profile load check:

```bash
"$HOME/.local/bin/spark-frontier-check" deepseek41-flash --load
```

**Pass:** the final line is `LOAD_PASS deepseek41-flash`, with both memory low-water values at least 3 GiB.

**Stop:** any failure or missing pass marker.

### 7.6 Finish Step 7

After the DeepSeek load check passes, inspect the final state:

```bash
"$HOME/.local/bin/spark-frontier" status
```

**Pass:** the state is `active:deepseek41-flash`, both DeepSeek ranks are present, `LiteLLM=healthy`, and Hermes default is `deepseek41-flash`.

Step 7 is complete. DeepSeek remains active because it was the final model tested. Continue to Step 8 to select the model you actually want to use.

### Load profiles used by the verifier

You do not enter these values manually. They document what each `--load` command runs:

| Lane | Context filler | Concurrency levels |
|---|---:|---|
| Qwen NVFP4 | 235,000 | 1, 2, 4, 8 |
| Qwen FP8 | 235,000 | 1, 2, 4 |
| GLM MTP 850K | 790,000 | 1, 2, 4 |
| DeepSeek 600K | 440,000 | 1, 2 |

The saved API `usage.prompt_tokens` value is authoritative because filler counts are approximate. The verifier saves timestamped results under the existing qualification result directories and stops its load client if either Spark falls below 3 GiB available memory.
## Step 8 — Normal session workflow

These blocks are **alternatives**, not a sequence. In the **FirstSpark SSH terminal**, copy only the block for the model you want now. Wait for its `Active frontier lane: ...` completion line before using its Hermes alias. For a newly qualified lane or after a configuration change, run the matching Step 7 verifier again.

Before a Qwen NVFP4 session:

```bash
spark-frontier use qwen38-nvfp4
```

Before a Qwen FP8 comparison session:

```bash
spark-frontier use qwen38-fp8
```

Before a GLM session:

```bash
spark-frontier use glm53-flash
```

Before a DeepSeek session:

```bash
spark-frontier use deepseek41-flash
```

Then select the same alias in Hermes Desktop or use the default already set by the command.

Return to the normal FirstSpark stack:

```bash
spark-frontier restore-spark-fast
```

## Step 9 — Cold-route behavior test

Do this **once**, after Qwen NVFP4 and GLM have passed their own tutorials and Step 7 checks, and both aliases are registered. In the **FirstSpark SSH terminal**, select Qwen with this one switch:

```bash
"$HOME/.local/bin/spark-frontier" use qwen38-nvfp4
```

**Pass:** the completion line says `Active frontier lane: qwen38-nvfp4`. Then send one deliberately mismatched request to the cold GLM alias. This request must fail; it must never return Qwen text under the GLM name:

```bash
python3 - <<'PY'
from pathlib import Path
import json, urllib.error, urllib.request
env = (Path.home() / "ai/services/litellm/runtime.env").read_text().splitlines()
key = next(line.split("=", 1)[1] for line in env if line.startswith("LITELLM_MASTER_KEY="))
models_request = urllib.request.Request("http://127.0.0.1:4000/v1/models", headers={"Authorization": "Bearer " + key})
with urllib.request.urlopen(models_request, timeout=20) as response:
    aliases = {item["id"] for item in json.load(response)["data"]}
assert "glm53-flash" in aliases, "STOP: GLM alias is not registered"
body = {"model": "glm53-flash", "messages": [{"role": "user", "content": "Reply with COLD_ROUTE_TEST"}], "max_tokens": 16}
request = urllib.request.Request("http://127.0.0.1:4000/v1/chat/completions", data=json.dumps(body).encode(), headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"})
try:
    with urllib.request.urlopen(request, timeout=45) as response:
        raise SystemExit("STOP: cold GLM alias returned HTTP " + str(response.status))
except urllib.error.HTTPError as error:
    if error.code in (401, 403):
        raise SystemExit("STOP: authentication failed; the cold-route behavior was not tested")
    print("COLD_ROUTE_REJECTED HTTP", error.code)
PY
```

**Pass:** `COLD_ROUTE_REJECTED HTTP ...`. Any `STOP:` or timeout fails this gate. Check that Qwen still answers after the rejected request:

```bash
"$HOME/.local/bin/spark-frontier-check" qwen38-nvfp4
```

**Pass:** `SMOKE_PASS qwen38-nvfp4`, including both ranks and the correct raw model. This proves the cold alias did not silently run through the active Qwen backend.

## Step 10 — Rollback the routing changes

If the routing or manager integration fails:

```bash
"$HOME/.local/bin/spark-frontier" restore-spark-fast
```

**Pass:** `Started spark-fast, restored standalone LiteLLM, and routed Hermes explicitly to spark-fast.` **Stop:** if this command fails or is still running. Do not paste the file-restore block while a switch or rollback is active.

Restore the Step 1 files on **FirstSpark**:

```bash
backup_dir="$(find "$HOME/backups/frontier-routing" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
test -d "$backup_dir"
cp -a "$backup_dir/litellm-config.yaml" "$HOME/ai/services/litellm/config.yaml"
cp -a "$backup_dir/litellm-compose.yaml" "$HOME/ai/services/litellm/compose.yaml"
cp -a "$backup_dir/litellm-runtime.env" "$HOME/ai/services/litellm/runtime.env"
cp -a "$backup_dir/hermes-config.yaml" "$HOME/.hermes/config.yaml"
cp -a "$backup_dir/hermes.env" "$HOME/.hermes/.env"
if [[ -f "$backup_dir/spark-frontier" ]]; then
  cp -a "$backup_dir/spark-frontier" "$HOME/.local/bin/spark-frontier"
elif [[ -f "$backup_dir/no-spark-frontier-before" ]]; then
  rm -f "$HOME/.local/bin/spark-frontier"
fi
rm -f "$HOME/.local/state/spark-frontier/active-lane" \
  "$HOME/.local/state/spark-frontier/manager.lock"
rmdir "$HOME/.local/state/spark-frontier" 2>/dev/null || true
cd "$HOME/ai/services/litellm"
docker compose -p spark-litellm config --quiet
docker compose -p spark-litellm up -d --force-recreate --pull never
"$HOME/.local/bin/hermes" config check
systemctl --user restart hermes-dashboard.service hermes-gateway.service hermes-serve.service
docker inspect spark-litellm --format '{{.State.Status}}|{{.State.Health.Status}}'
```

The model repositories, images, and weights remain installed. This rollback restores standalone LiteLLM and Hermes routing, restores or removes the frontier manager according to its pre-change state, and clears only the manager's small state files.

## Acceptance checklist

- [ ] Every registered alias already passed its individual tutorial.
- [ ] LiteLLM config and manager state have timestamped backups.
- [ ] Shared frontier key reaches LiteLLM without being printed.
- [ ] `/v1/models` lists all validated aliases plus existing routes.
- [ ] `spark-frontier` passes `bash -n`; the operator prohibition on concurrent `spark-model` use is documented.
- [ ] Qwen NVFP4, Qwen FP8, GLM, and DeepSeek each start through the manager.
- [ ] Manager verifies the expected upstream model identity.
- [ ] Matching LiteLLM alias and Hermes request pass for each active lane.
- [ ] Cold alias fails cleanly and cannot masquerade as the active model.
- [ ] Previous head and worker ranks are gone after every switch.
- [ ] Each lane repeats its accepted load with LiteLLM/Hermes resident.
- [ ] `spark-frontier restore-spark-fast` starts `spark-fast`, restores standalone LiteLLM, and routes Hermes explicitly to `spark-fast`.
- [ ] `spark-fast`, `qwen27-dflash`, and `nemotron3-omni` routes remain unchanged.

**Next:** return to [[Task Checklist]], record which aliases passed, and use `spark-frontier status` before every model-selection session.

## Related notes

- [[DGX Spark Dual-Node Community Frontier Models Runbook]]
- [[DGX Spark Model Installation And Switching Guide]]
- [[FirstSpark Standalone LiteLLM Operations]]
- [[Always-On Hermes on DGX Spark]]
- [[Local Setup Index]]
