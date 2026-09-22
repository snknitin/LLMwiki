---
updated: 2026-09-21
status: implement-after-model-validation
scope: dgx-spark, litellm, hermes, hot-swap, model-manager, dual-node
---

# DGX Spark Frontier Model Hot-Swap And Routing Guide

> [!summary] Outcome
> Keep Qwen 3.8 NVFP4, Qwen 3.8 official FP8, GLM 5.3 Flash, and DeepSeek V4.1 Flash installed and permanently named in LiteLLM/Hermes. A cluster-aware command hot-swaps the resident two-node backend, waits for health, restores LiteLLM/Hermes, selects the matching Hermes default, and preserves `spark-fast` as rollback.

This guide implements the user's required end state: the new frontier models behave like the existing `spark-fast`, `qwen27-dflash`, and `nemotron3-omni` choices from the client perspective, while respecting the fact that only one large dual-node model can be resident.

## Required order

Do not begin here until these are complete:

1. [[DGX Spark Dual-Node Community Frontier Models Runbook]] readiness gate.
2. [[DGX Spark sparkDash Monitoring Tutorial]]
3. [[DGX Spark Dual-Node Qwen 3.8 Flash Next Tutorial]]
4. [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]]
5. [[DGX Spark Dual-Node DeepSeek V4.1 Flash EXL3 Tutorial]]

A lane may be registered after its own direct and coexistence gates pass; all four do not need to pass on the same day. Never register an untested backend merely to make it appear in a model list.

> [!tip] Beginner execution rule
> Perform this guide from the `FirstSpark` SSH terminal, one numbered step at a time. Do not install the switch command until you have manually started, tested, stopped, and rolled back every lane you intend to register. The model names remain visible in LiteLLM/Hermes when cold, but you must run `spark-frontier use <name>` and wait for success before selecting that model for a session.

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
> `glm53-flash`, `glm53-flash-mtp-850k`, and `glm53-flash-dflash-500k` are **qualification result profiles**, not automatically three LiteLLM aliases. Complete Step 16 of [[DGX Spark Dual-Node GLM 5.3 Flash EXL3 Tutorial]], choose one accepted operating profile, install that profile as `~/src/frontier/glm53-dual/.env`, and make the hot-swap manager's `GLM53_ACCEPTED_CONTEXT` match it. Keep the named profile files under `~/.config/frontier/glm53-profiles/`; do not leave API-key-bearing `.env.*` copies unignored inside the Git checkout. Register extra public aliases only if you intentionally want multiple GLM operating contracts and the switch manager can select their corresponding configuration files deterministically.

## Resource policy for normal hot-swaps

The raw qualification shuts down all nonessential services. Normal routed use adds only the control plane that passed A/B testing:

- `ods-litellm`;
- `hermes-serve.service`;
- `hermes-gateway.service`;
- optionally sparkDash for lanes whose dashboard-on memory A/B passed.

The rest of ODS stays stopped while a memory-tight frontier lane runs. Live inspection found several GiB of RSS across the complete ODS stack, larger than the published low-water margin of some recipes.

If a lane cannot pass the same long-context/load test with LiteLLM and Hermes running, it is not eligible for this guide. Keep it as a raw research lane instead of presenting it as a usable Hermes choice.

## Step 1 — Back up routing and manager state

Run on **FirstSpark**:

```bash
stamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$HOME/backups/frontier-routing/$stamp"
install -d -m 700 "$backup_dir"
cp -a "$HOME/ods/config/litellm/local.yaml" "$backup_dir/litellm-local.yaml"
cp -a "$HOME/ods/extensions/services/litellm/compose.local.yaml" "$backup_dir/litellm-compose-local.yaml"
cp -a "$HOME/ods/.env" "$backup_dir/ods.env"
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

**Pass:** Hermes reports a valid configuration, the final line is a new timestamped backup directory, and that directory contains the LiteLLM, ODS, Hermes, and manager files listed above. Stop if any `cp` command or `hermes config check` fails.

## Step 2 — Make the frontier key available to LiteLLM

Confirm the shared key exists:

```bash
test -s "$HOME/.config/frontier/api-key"
stat -c '%a %n' "$HOME/.config/frontier/api-key"
```

Expected mode: `600`.

Add it to the existing ODS environment without printing it:

```bash
cd "$HOME/ods"
frontier_key="$(<"$HOME/.config/frontier/api-key")"
if grep -q '^SPARK_FRONTIER_API_KEY=' .env; then
  sed -i "s|^SPARK_FRONTIER_API_KEY=.*|SPARK_FRONTIER_API_KEY=$frontier_key|" .env
else
  printf '\nSPARK_FRONTIER_API_KEY=%s\n' "$frontier_key" >> .env
fi
unset frontier_key
chmod 600 .env
```

Replace `$HOME/ods/extensions/services/litellm/compose.local.yaml` with the following. Remove the current `depends_on: llama-server` block: a frontier switch must be able to recreate LiteLLM while the ODS llama server and every other ODS service remain stopped.

```yaml
services:
  litellm:
    environment:
      - SPARK_FRONTIER_API_KEY=${SPARK_FRONTIER_API_KEY:?set SPARK_FRONTIER_API_KEY in ~/ods/.env}
```

Validate the merged ODS configuration with its supported validator:

```bash
cd "$HOME/ods"
ods config validate
```

The existing Hermes custom provider named `spark-fast` already points to FirstSpark LiteLLM. Make sure its key environment variable holds the ODS LiteLLM master key without printing either secret:

```bash
set -a
. "$HOME/ods/.env"
set +a
export HERMES_ENV_FILE="$HOME/.hermes/.env"
python3 - <<'PY'
import os
from pathlib import Path

name = "HERMES_CUSTOM_127_0_0_1_4000_API_KEY"
value = os.environ["LITELLM_KEY"]
path = Path(os.environ["HERMES_ENV_FILE"])
lines = path.read_text(encoding="utf-8").splitlines() if path.exists() else []
out = []
replaced = False
for line in lines:
    if line.startswith(name + "="):
        out.append(f"{name}={value}")
        replaced = True
    else:
        out.append(line)
if not replaced:
    out.append(f"{name}={value}")
path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY
chmod 600 "$HOME/.hermes/.env"
unset LITELLM_KEY HERMES_ENV_FILE
```

**Pass:** `ods config validate` exits successfully, `.env` and `.hermes/.env` both remain mode `600`, and no secret value was printed. Stop before editing routes if validation fails.

## Step 3 — Add all validated LiteLLM aliases

Open:

```bash
nano "$HOME/ods/config/litellm/local.yaml"
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

Keep the existing `spark-fast`, `qwen27-dflash`, `nemotron3-omni`, default, and wildcard entries. Do not create a second `model_list:` heading.

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
chmod 600 "$HOME/ods/config/litellm/local.yaml"
python3 - <<'PY'
import yaml
p='/home/snknitin/ods/config/litellm/local.yaml'
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

## Step 4 — Recreate LiteLLM once with the new environment

Run on **FirstSpark**:

```bash
ods stop litellm
ods start litellm
docker logs --tail 120 ods-litellm
docker inspect ods-litellm --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep '^SPARK_FRONTIER_API_KEY=' \
  | sed 's/=.*/=<redacted>/'
docker exec ods-litellm /bin/sh -c 'test -n "$SPARK_FRONTIER_API_KEY"'
```

Do not display the real value. If YAML or environment validation fails, restore the Step 1 backup before continuing.

Load the LiteLLM master key without printing it and confirm all aliases are advertised:

```bash
set -a
. "$HOME/ods/.env"
set +a
curl -fsS http://127.0.0.1:4000/v1/models \
  -H "Authorization: Bearer $LITELLM_KEY" \
  | python3 -m json.tool
unset LITELLM_KEY
```

It is normal for the aliases to be listed while cold. Do not send chat to a cold alias.

## Step 5 — Install a cluster-aware switch command

The existing `spark-model` manager supports single-node Compose and LM Studio. Preserve it. Add a separate `spark-frontier` command that calls the repositories' own two-node lifecycle scripts and uses `spark-model` for the known-good single-node rollback.

Create the file:

```bash
nano "$HOME/.local/bin/spark-frontier"
```

Paste:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/src/frontier"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/spark-frontier"
LOCK_FILE="$STATE_DIR/manager.lock"
ACTIVE_FILE="$STATE_DIR/active-lane"
KEY_FILE="$HOME/.config/frontier/api-key"
WORKER_MGMT="snknitin@192.168.0.100"
API_BASE="http://127.0.0.1:8100"
HERMES="$HOME/.local/bin/hermes"
SPARK_MODEL="$HOME/.local/bin/spark-model"
mkdir -p "$STATE_DIR"

lane_values() {
  case "$1" in
    qwen38-nvfp4)
      DIR="$ROOT/qwen38-dual"
      START='./start.sh --launch'
      API_MODEL='qwen3.8-flash-next'
      HERMES_ALIAS='qwen38-nvfp4'
      CONTEXT='262144'
      ;;
    qwen38-fp8)
      DIR="$ROOT/qwen38-dual"
      START='./start-fp8.sh --no-download --nfs'
      API_MODEL='qwen3.8-flash-next-fp8'
      HERMES_ALIAS='qwen38-fp8'
      CONTEXT='262144'
      ;;
    glm53-flash)
      DIR="$ROOT/glm53-dual"
      START='SKIP_BUILD=1 ./start.sh'
      API_MODEL='GLM-5.3-Flash-EXL3'
      HERMES_ALIAS='glm53-flash'
      CONTEXT="${GLM53_ACCEPTED_CONTEXT:-500000}"
      ;;
    deepseek41-flash)
      DIR="$ROOT/deepseek41-dual"
      START='SKIP_BUILD=1 ./start.sh'
      API_MODEL='DeepSeek-v4.1-Flash-EXL3'
      HERMES_ALIAS='deepseek41-flash'
      CONTEXT="${DEEPSEEK41_ACCEPTED_CONTEXT:-262144}"
      ;;
    *)
      printf 'Unknown frontier lane: %s\n' "$1" >&2
      return 2
      ;;
  esac
}

stop_all_frontier() {
  local rc=0
  # Stop DeepSeek before Qwen: DeepSeek may reuse a live Qwen NFS exporter.
  if [[ -d "$ROOT/deepseek41-dual" ]] && \
     { docker ps --format '{{.Names}}' | grep -qx 'dsv41-exl3-head' || \
       ssh -o BatchMode=yes "$WORKER_MGMT" "docker ps --format '{{.Names}}'" | grep -qx 'dsv41-exl3-worker'; }; then
    (cd "$ROOT/deepseek41-dual" && ./start.sh stop) || rc=1
  fi
  if [[ -d "$ROOT/glm53-dual" ]] && \
     { docker ps --format '{{.Names}}' | grep -qx 'glm53-exl3-head' || \
       ssh -o BatchMode=yes "$WORKER_MGMT" "docker ps --format '{{.Names}}'" | grep -qx 'glm53-exl3-worker'; }; then
    (cd "$ROOT/glm53-dual" && ./start.sh stop) || rc=1
  fi
  if [[ -d "$ROOT/qwen38-dual" ]] && \
     { docker ps --format '{{.Names}}' | grep -qx 'vllm-fn' || \
       ssh -o BatchMode=yes "$WORKER_MGMT" "docker ps --format '{{.Names}}'" | grep -qx 'vllm-fn'; }; then
    # Keep the NFS exporter; --nfs could tear down an exporter another lane reused.
    (cd "$ROOT/qwen38-dual" && ./stop.sh) || rc=1
  fi
  # The optional SecondSpark TP1 lane cannot coexist with a dual-node lane.
  ssh -o BatchMode=yes "$WORKER_MGMT" \
    "docker rm -f vllm-fn-tp1 >/dev/null 2>&1 || true; pkill -f '[m]emwatch.sh vllm-fn-tp1' 2>/dev/null || true" || rc=1
  return "$rc"
}

assert_frontier_stopped() {
  local head worker ports_head ports_worker
  head="$(docker ps --format '{{.Names}}' | \
    grep -E '^(vllm-fn|glm53-exl3-head|dsv41-exl3-head)$' || true)"
  worker="$(ssh -o BatchMode=yes "$WORKER_MGMT" \
    "docker ps --format '{{.Names}}'" | \
    grep -E '^(vllm-fn|vllm-fn-tp1|glm53-exl3-worker|dsv41-exl3-worker)$' || true)"
  ports_head="$(ss -ltn | grep -E ':(8100|29521|50000)([[:space:]]|$)' || true)"
  ports_worker="$(ssh -o BatchMode=yes "$WORKER_MGMT" ss -ltn | \
    grep -E ':(8100|29521|50000)([[:space:]]|$)' || true)"
  if [[ -n "$head$worker$ports_head$ports_worker" ]]; then
    printf '%s\n' 'Refusing to continue: a frontier rank or distributed port remains.' >&2
    printf 'HEAD_CONTAINERS=%s\nWORKER_CONTAINERS=%s\nHEAD_PORTS=%s\nWORKER_PORTS=%s\n' \
      "$head" "$worker" "$ports_head" "$ports_worker" >&2
    return 1
  fi
  rm -f "$ACTIVE_FILE"
}

wait_model_idle() {
  local base="$1" deadline=$((SECONDS + 300)) metrics sum matches key=''
  local -a auth=()
  [[ "$base" == *':8100' ]] && key="$(<"$KEY_FILE")"
  [[ -n "$key" ]] && auth=(-H "Authorization: Bearer $key")
  if ! curl -fsS "$base/health" "${auth[@]}" >/dev/null 2>&1; then
    return 0
  fi
  while (( SECONDS < deadline )); do
    metrics="$(curl -fsS "$base/metrics" "${auth[@]}" 2>/dev/null || true)"
    matches="$(printf '%s\n' "$metrics" | grep -Ec '^vllm:(num_requests_running|num_requests_waiting)' || true)"
    sum="$(printf '%s\n' "$metrics" | awk '$1 ~ /^vllm:(num_requests_running|num_requests_waiting)/ {s+=$2} END {print s+0}')"
    if [[ "$matches" -gt 0 && "$sum" == '0' ]]; then
      return 0
    fi
    sleep 5
  done
  printf 'Could not prove zero active/queued requests at %s within 300 seconds.\n' "$base" >&2
  return 1
}

quiesce_ingress() {
  printf '%s\n' 'Entering maintenance mode; do not submit new direct API requests.'
  systemctl --user stop hermes-dashboard.service hermes-gateway.service hermes-serve.service || true
  wait_model_idle 'http://127.0.0.1:8100'
  wait_model_idle 'http://127.0.0.1:8000'
  ods stop litellm || true
  ods stop || true
}

show_gpu_holders() {
  printf '%s\n' 'Head GPU holders:'
  nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
  printf '%s\n' 'Worker GPU holders:'
  ssh -o BatchMode=yes "$WORKER_MGMT" \
    'nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv'
}

wait_api() {
  local expected="$1" deadline=$((SECONDS + 3600)) key
  key="$(<"$KEY_FILE")"
  while (( SECONDS < deadline )); do
    if body="$(curl -fsS "$API_BASE/v1/models" \
      -H "Authorization: Bearer $key" 2>/dev/null)"; then
      if python3 - "$expected" "$body" <<'PY'
import json,sys
expected=sys.argv[1]
d=json.loads(sys.argv[2])
ids={x.get('id') for x in d.get('data',[])}
raise SystemExit(0 if expected in ids else 1)
PY
      then
        unset key
        return 0
      fi
    fi
    sleep 10
  done
  unset key
  return 1
}

start_control_plane() {
  local deadline=$((SECONDS + 240)) health
  ods start litellm
  while (( SECONDS < deadline )); do
    health="$(docker inspect ods-litellm --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' 2>/dev/null || true)"
    [[ "$health" == 'healthy' ]] && return 0
    [[ "$health" == 'unhealthy' || "$health" == 'exited' ]] && break
    sleep 5
  done
  docker logs --tail 120 ods-litellm >&2 || true
  return 1
}

select_hermes() {
  "$HERMES" config set model.provider custom:spark-fast
  "$HERMES" config set model.base_url http://127.0.0.1:4000/v1
  "$HERMES" config set model.default "$HERMES_ALIAS"
  "$HERMES" config set model.context_length "$CONTEXT"
  "$HERMES" config check
  systemctl --user restart hermes-serve.service hermes-gateway.service
}

probe_litellm() {
  local alias="$1" key body
  set -a
  # shellcheck disable=SC1091
  source "$HOME/ods/.env"
  set +a
  key="${LITELLM_KEY:?LITELLM_KEY missing from ~/ods/.env}"
  body="$(printf '{"model":"%s","messages":[{"role":"user","content":"Reply with exactly ROUTE_OK"}],"temperature":0,"max_tokens":16}' "$alias")"
  curl --fail --silent --show-error --max-time 3600 \
    http://127.0.0.1:4000/v1/chat/completions \
    -H "Authorization: Bearer $key" \
    -H 'Content-Type: application/json' \
    -d "$body" >/dev/null
  unset LITELLM_KEY key body
}

activate_spark_fast() {
  "$SPARK_MODEL" use qwen35
  ods start
  "$HERMES" config set model.provider custom:spark-fast
  "$HERMES" config set model.base_url http://127.0.0.1:4000/v1
  "$HERMES" config set model.default spark-fast
  "$HERMES" config set model.context_length 262144
  "$HERMES" config check
  systemctl --user start hermes-dashboard.service hermes-gateway.service hermes-serve.service
  rm -f "$ACTIVE_FILE"
}

rollback_verified() {
  set +e
  printf '%s\n' 'Rollback requested; first proving every frontier compute rank is gone.' >&2
  stop_all_frontier
  local stop_rc=$?
  assert_frontier_stopped
  local verify_rc=$?
  set -e
  if (( stop_rc != 0 || verify_rc != 0 )); then
    printf '%s\n' 'ROLLBACK BLOCKED: do not start spark-fast; remove the reported rank/port and rerun restore-spark-fast.' >&2
    return 1
  fi
  activate_spark_fast
}

write_state() {
  printf '%s\n' "$1" > "$ACTIVE_FILE"
}

use_lane() {
  local requested="$1"
  lane_values "$requested"
  [[ -s "$KEY_FILE" ]] || { echo "Missing $KEY_FILE" >&2; return 1; }
  [[ -d "$DIR" ]] || { echo "Missing recipe directory: $DIR" >&2; return 1; }

  exec 9>"$LOCK_FILE"
  flock -n 9 || { echo 'Another spark-frontier operation is running.' >&2; return 1; }

  local rollback_armed=1
  trap 'rc=$?; trap - ERR INT TERM; if (( rollback_armed )); then rollback_verified || true; fi; exit "$rc"' ERR INT TERM
  write_state 'stopping-old'
  quiesce_ingress
  if [[ -d "$ROOT/sparkDash" ]]; then
    (cd "$ROOT/sparkDash" && \
      docker compose -f docker-compose.yml -f docker-compose.local.yml stop) || true
  fi

  "$SPARK_MODEL" stop
  stop_all_frontier
  assert_frontier_stopped
  show_gpu_holders

  write_state "starting:$requested"
  printf 'Starting frontier lane %s...\n' "$requested"
  (cd "$DIR" && bash -lc "$START")
  wait_api "$API_MODEL"

  write_state "raw-ready:$requested"
  start_control_plane
  probe_litellm "$HERMES_ALIAS"
  select_hermes
  write_state "active:$requested"
  rollback_armed=0
  trap - ERR INT TERM
  printf 'Active frontier lane: %s; Hermes model: %s; context: %s\n' \
    "$requested" "$HERMES_ALIAS" "$CONTEXT"
}

restore_spark_fast() {
  exec 9>"$LOCK_FILE"
  flock -n 9 || { echo 'Another spark-frontier operation is running.' >&2; return 1; }
  write_state 'stopping-old'
  quiesce_ingress
  "$SPARK_MODEL" stop
  stop_all_frontier
  assert_frontier_stopped
  activate_spark_fast
  echo 'Started spark-fast, restored the full ODS stack, and routed Hermes explicitly to spark-fast.'
}

status() {
  printf 'Desired/transition state: '
  cat "$ACTIVE_FILE" 2>/dev/null || echo none
  docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' \
    | grep -E 'NAMES|vllm-fn|glm53|dsv41|ods-litellm' || true
  ssh -o BatchMode=yes "$WORKER_MGMT" \
    "docker ps -a --format 'table {{.Names}}\t{{.Status}}'" \
    | grep -E 'NAMES|vllm-fn|glm53|dsv41' || true
  ss -ltnp | grep -E ':(4000|8000|8100|29521|50000)([[:space:]]|$)' || true
  if [[ -s "$KEY_FILE" ]]; then
    local key; key="$(<"$KEY_FILE")"
    curl -fsS "$API_BASE/v1/models" -H "Authorization: Bearer $key" 2>/dev/null || true
    unset key
    echo
  fi
  docker inspect ods-litellm --format 'LiteLLM={{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' 2>/dev/null || true
  for k in model.provider model.base_url model.default model.context_length; do
    printf 'Hermes %s=' "$k"
    "$HERMES" config get "$k" 2>/dev/null || true
  done
  systemctl --user is-active hermes-dashboard.service hermes-gateway.service hermes-serve.service || true
  show_gpu_holders
  free -h
  ssh -o BatchMode=yes "$WORKER_MGMT" free -h
}

usage() {
  cat <<'EOF'
Usage:
  spark-frontier use qwen38-nvfp4
  spark-frontier use qwen38-fp8
  spark-frontier use glm53-flash
  spark-frontier use deepseek41-flash
  spark-frontier status
  spark-frontier emergency-stop-all
  spark-frontier restore-spark-fast

Cold models remain listed in LiteLLM/Hermes but must not receive requests.
EOF
}

case "${1:-status}" in
  use) [[ $# -eq 2 ]] || { usage >&2; exit 2; }; use_lane "$2" ;;
  emergency-stop-all)
    exec 9>"$LOCK_FILE"; flock -n 9 || exit 1
    systemctl --user stop hermes-dashboard.service hermes-gateway.service hermes-serve.service || true
    ods stop || true
    "$SPARK_MODEL" stop || "$SPARK_MODEL" stop --force
    stop_all_frontier
    assert_frontier_stopped
    ;;
  restore-spark-fast) restore_spark_fast ;;
  status) status ;;
  help|-h|--help) usage ;;
  *) usage >&2; exit 2 ;;
esac
```

Save, then:

```bash
chmod 700 "$HOME/.local/bin/spark-frontier"
bash -n "$HOME/.local/bin/spark-frontier"
"$HOME/.local/bin/spark-frontier" help
```

Important boundaries:

- The command assumes every selected lane has already completed its download/sync/NFS setup.
- It does not auto-start sparkDash; start it only for lanes whose dashboard-on A/B passed.
- `spark-frontier` and the existing `spark-model` have different lock files. Never invoke them concurrently; `spark-frontier` is the lifecycle owner from the beginning of a frontier switch until it reports completion.
- GLM and DeepSeek accepted contexts default conservatively in the command. The variables below change **Hermes metadata only**; they do not change the serving profile. Each value must be a positive integer no larger than the `MAX_MODEL_LEN` already qualified in that repository's `.env`:

```bash
GLM53_ACCEPTED_CONTEXT=850000 spark-frontier use glm53-flash
DEEPSEEK41_ACCEPTED_CONTEXT=600000 spark-frontier use deepseek41-flash
```

- `restore-spark-fast` explicitly routes Hermes to `spark-fast`; it does not restore the pre-switch workstation-Ollama selection. Step 10 restores the exact backed-up Hermes state when that is the desired outcome.

## Step 6 — First managed switch: Qwen NVFP4

Run on **FirstSpark**:

```bash
spark-frontier use qwen38-nvfp4
spark-frontier status
```

Then test LiteLLM:

```bash
set -a
. "$HOME/ods/.env"
set +a
curl -fsS http://127.0.0.1:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"qwen38-nvfp4",
    "messages":[{"role":"user","content":"Reply with exactly QWEN38_ROUTE_OK"}],
    "temperature":0,
    "max_tokens":40
  }' | python3 -m json.tool
unset LITELLM_KEY
```

Test Hermes:

```bash
"$HOME/.local/bin/hermes" -z 'Reply with exactly QWEN38_HERMES_OK'
```

Run the same context/load used in the tutorial one more time while LiteLLM and Hermes are active. Record the low-water; the managed lane passes only if that result remains safe.

## Step 7 — Prove all managed switches

After each corresponding tutorial passes, run one at a time:

```bash
spark-frontier use qwen38-fp8
spark-frontier status

spark-frontier use glm53-flash
spark-frontier status

spark-frontier use deepseek41-flash
spark-frontier status
```

For each lane:

1. verify raw `/v1/models` reports the correct upstream model;
2. call the matching LiteLLM alias;
3. run `hermes -z` and a real structured tool;
4. repeat the accepted memory/load test;
5. switch to another lane;
6. confirm the previous worker rank disappeared.

Do not send a request to another registered alias while the wrong backend is active. The intentional model-name mismatch should fail; it is not an automatic switch signal.

## Step 8 — Normal session workflow

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

With Qwen NVFP4 active, deliberately send a tiny request to `glm53-flash`. It should fail cleanly rather than silently run Qwen under the GLM name. Record the HTTP/LiteLLM error and confirm the active Qwen rank remains healthy.

This proves that stable aliases preserve identity and do not accidentally cross-route.

## Step 10 — Rollback the routing changes

If the routing or manager integration fails:

```bash
spark-frontier restore-spark-fast || true
```

Restore the Step 1 files:

```bash
backup_dir="$(find "$HOME/backups/frontier-routing" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
cp -a "$backup_dir/litellm-local.yaml" "$HOME/ods/config/litellm/local.yaml"
cp -a "$backup_dir/litellm-compose-local.yaml" "$HOME/ods/extensions/services/litellm/compose.local.yaml"
cp -a "$backup_dir/ods.env" "$HOME/ods/.env"
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
ods stop litellm || true
ods start litellm
"$HOME/.local/bin/hermes" config check
systemctl --user restart hermes-dashboard.service hermes-gateway.service hermes-serve.service
docker logs --tail 100 ods-litellm
```

The model repositories, images, and weights remain installed. This rollback restores ODS and Hermes routing, restores or removes the manager according to its pre-change state, and clears only the manager's own small state files.

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
- [ ] `spark-frontier restore-spark-fast` starts `spark-fast`, restores full ODS, and routes Hermes explicitly to `spark-fast`.
- [ ] `spark-fast`, `qwen27-dflash`, and `nemotron3-omni` routes remain unchanged.

**Next:** return to [[Task Checklist]], record which aliases passed, and use `spark-frontier status` before every model-selection session.

## Related notes

- [[DGX Spark Dual-Node Community Frontier Models Runbook]]
- [[DGX Spark Model Installation And Switching Guide]]
- [[Always-On Hermes on DGX Spark]]
- [[Local Setup Index]]
