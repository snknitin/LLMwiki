# DGX Spark Model Installation And Switching Guide

This is the beginner-focused continuation of [[DGX Spark Operations Setup Guide]]. It starts at Step 16 so the numbering continues from that guide.

> [!important] Your current position
> You have completed the original Steps 1–12 and reached Step 13. Do not repeat Steps 1–12. First complete the **corrected** Steps 13–15 in [[DGX Spark Operations Setup Guide]]: persistent authenticated `hermes serve`, persistent Telegram gateway, final service checks, and the first `spark-fast` model test. Return here only after Step 15 succeeds.

Unless a section explicitly says **Windows PowerShell**, every command in this note runs in the **Spark terminal opened from NVIDIA Sync**.

## What this guide will give you

You will have:

- one shared Hugging Face cache instead of duplicate model downloads;
- one folder for each model service;
- a unique container name, API alias, and port for each model;
- only one memory-heavy model server running at a time;
- a repeatable way to switch Hermes between models;
- safe stop and rollback commands that do not delete model weights.

## The model order for this Spark

Do not download every model at once. Use this order:

| Order | Model | Role | Initial policy |
|---:|---|---|---|
| 1 | Qwen 3.6 35B-A3B NVFP4 | Default always-on Hermes/tool model | Already built as `spark-fast` in the operations guide |
| 2 | Qwen 3.6 27B NVFP4 + DFlash | Dense speed/quality comparison | Install next; run on demand |
| 3 | Nemotron 3 Nano Omni 30B-A3B Reasoning NVFP4 | NVIDIA reasoning/multimodal comparison | Add after Qwen 27B passes |
| 4 | DeepSeek V4 Flash SparkInfer build | Large-MoE quality experiment | Isolated experiment; never auto-start initially |
| 5 | Ling 3.0 Flash SGLang build | Experimental large MoE | Hold until its exact runtime and Hermes tool calls are verified |

Gemma 4, MiniMax H3, Ornith, StepFun, Laguna, and other community models remain candidates, not automatic installations. Every extra model consumes disk even while stopped.

## Step 16 — Confirm the baseline before adding anything

### 16.1 Run the status block

Copy and run this entire block in the **Spark terminal**:

```bash
echo '=== Filesystem ==='
df -h "$HOME"

echo '=== Memory ==='
free -h

echo '=== GPU ==='
nvidia-smi

echo '=== Running containers ==='
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo '=== Hermes ==='
hermes gateway status
systemctl --user is-active hermes-serve.service

echo '=== Tailscale ==='
tailscale ip -4
```

Do not continue unless:

- the home filesystem has enough free space for another model;
- `hermes-serve.service` prints `active`;
- the Telegram gateway is running;
- the Spark has a `100.x.x.x` Tailscale address;
- you know whether `vllm-spark-fast` is currently running.

### 16.2 Understand “downloaded” versus “running”

A Docker image is the inference program. A model download is the model's weights. A container is a currently configured or running instance of the program.

Stopping or removing a container does **not** delete the Hugging Face weights when the weights live in `~/.cache/huggingface`. Never run cache-cleanup commands merely to switch models.

## Step 17 — Learn the safe Qwen 35B stop/start commands

The current default service lives at:

```text
/home/snknitin/ai/services/qwen35
```

### Stop Qwen 35B without deleting its weights

Run in the **Spark terminal**:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
```

Verify it stopped:

```bash
docker ps --filter name=vllm-spark-fast
nvidia-smi
```

An empty Docker result means the container is stopped. The downloaded model remains in `~/.cache/huggingface`.

### Start Qwen 35B again

Run in the **Spark terminal**:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env up -d
docker logs --tail 50 vllm-spark-fast
```

Do this start/stop exercise once before installing the next model. It proves you can recover the known-good model.

## Step 18 — Prepare the Qwen 27B DFlash service

The upstream community script uses a repository-local Hugging Face cache, host networking, `--privileged`, a whole-repository mount, and a mutable nightly image. This guide keeps its DFlash/runtime flags but gives the model a shared cache, private ODS network, localhost-only raw API, unique service folder, and pinned image digest.

### 18.1 Clone the recipe without starting it

Run in the **Spark terminal**:

```bash
cd "$HOME/src"

if [ ! -d Qwen3.6-27B-NVFP4-DFlash-DGX-Spark ]; then
  git clone https://github.com/MiaAI-Lab/Qwen3.6-27B-NVFP4-DFlash-DGX-Spark.git
fi

cd "$HOME/src/Qwen3.6-27B-NVFP4-DFlash-DGX-Spark"
git pull --ff-only
git rev-parse HEAD
```

Record the printed commit in your run notes. Do **not** run the repository's `./start.sh`.

### 18.2 Download both model repositories into the shared cache

Long downloads should run inside `tmux`:

```bash
tmux new -s qwen27-download
```

Inside the `tmux` session, run:

```bash
set -a
. "$HOME/.config/dgx-spark/secrets.env"
set +a

MAIN_MODEL_ID=nvidia/Qwen3.6-27B-NVFP4
DRAFT_MODEL_ID=z-lab/Qwen3.6-27B-DFlash
MAIN_REVISION="$(python3 -c 'from huggingface_hub import HfApi; print(HfApi().model_info("nvidia/Qwen3.6-27B-NVFP4").sha)')"
DRAFT_REVISION="$(python3 -c 'from huggingface_hub import HfApi; print(HfApi().model_info("z-lab/Qwen3.6-27B-DFlash").sha)')"

hf download "$MAIN_MODEL_ID" --revision "$MAIN_REVISION"
hf download "$DRAFT_MODEL_ID" --revision "$DRAFT_REVISION"

mkdir -p "$HOME/ai/services/qwen27-dflash"
cat > "$HOME/ai/services/qwen27-dflash/model-revisions.env" <<EOF
MAIN_REVISION=$MAIN_REVISION
DRAFT_REVISION=$DRAFT_REVISION
EOF

unset HF_TOKEN NGC_API_KEY MAIN_MODEL_ID DRAFT_MODEL_ID MAIN_REVISION DRAFT_REVISION
```

The small `model-revisions.env` file records the exact commits you downloaded. It contains no API token. This is necessary because the container will deliberately run with Hugging Face offline mode enabled after the download.

To leave the download running, press **Ctrl+B**, release both keys, and then press **D**. Reopen it later with:

```bash
tmux attach -t qwen27-download
```

After both downloads finish, check disk use:

```bash
du -sh "$HOME/.cache/huggingface"
df -h "$HOME"
```

### 18.3 Pin the runtime image and create the service settings

Run this entire block in the **Spark terminal**:

```bash
QWEN27_IMAGE='vllm/vllm-openai:nightly-aarch64'
docker pull "$QWEN27_IMAGE"
QWEN27_IMAGE_PINNED="$(docker image inspect --format '{{index .RepoDigests 0}}' "$QWEN27_IMAGE")"
ODS_NETWORK="$(docker inspect -f '{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}' ods-litellm | head -n 1)"

cd "$HOME/ai/services/qwen27-dflash"
test -f model-revisions.env || {
  echo 'ERROR: model-revisions.env is missing. Finish Step 18.2 first.'
  exit 1
}
. ./model-revisions.env

test -n "$QWEN27_IMAGE_PINNED" || {
  echo 'ERROR: Docker did not return a pinned image digest.'
  exit 1
}

test -n "$ODS_NETWORK" || {
  echo 'ERROR: the ODS LiteLLM Docker network was not found.'
  exit 1
}

mkdir -p "$HOME/ai/services/qwen27-dflash/triton"
cd "$HOME/ai/services/qwen27-dflash"

cat > .env <<EOF
QWEN27_IMAGE=$QWEN27_IMAGE
QWEN27_IMAGE_PINNED=$QWEN27_IMAGE_PINNED
MODEL_ID=nvidia/Qwen3.6-27B-NVFP4
DRAFT_MODEL_ID=z-lab/Qwen3.6-27B-DFlash
MODEL_REVISION=$MAIN_REVISION
DRAFT_REVISION=$DRAFT_REVISION
MODEL_ALIAS=qwen27-dflash
HOST_PORT=8001
ODS_NETWORK=$ODS_NETWORK
RESTART_POLICY=no
HF_HOME=/home/snknitin/.cache/huggingface
RECIPE_DIR=/home/snknitin/src/Qwen3.6-27B-NVFP4-DFlash-DGX-Spark
EOF

unset QWEN27_IMAGE QWEN27_IMAGE_PINNED ODS_NETWORK MAIN_REVISION DRAFT_REVISION
```

This file contains deployment settings but no Hugging Face token.

Record the planned port once:

```bash
 
```

### 18.4 Create the controlled Compose file

Open a new file in the **Spark terminal**:

```bash
cd "$HOME/ai/services/qwen27-dflash"
nano compose.yaml
```

Paste the following exactly:

```yaml
services:
  qwen27-dflash:
    image: ${QWEN27_IMAGE_PINNED}
    container_name: vllm-qwen27-dflash
    restart: "${RESTART_POLICY:-no}"
    gpus: all
    ipc: host
    ports:
      - "127.0.0.1:${HOST_PORT}:8000"
    environment:
      HF_HOME: /root/.cache/huggingface
      HF_HUB_OFFLINE: "1"
      HF_TOKEN: ${HF_TOKEN}
      TRITON_CACHE_DIR: /root/.triton
      VLLM_TARGET_DEVICE: cuda
      VLLM_FLOAT32_MATMUL_PRECISION: high
      CUTE_DSL_ARCH: sm_121a
    volumes:
      - ${HF_HOME}:/root/.cache/huggingface
      - ./triton:/root/.triton
      - ${RECIPE_DIR}/chat_template.jinja:/workspace/chat_template.jinja:ro
    entrypoint: ["vllm", "serve"]
    command:
      - ${MODEL_ID}
      - --revision
      - ${MODEL_REVISION}
      - --served-model-name
      - ${MODEL_ALIAS}
      - --host
      - "0.0.0.0"
      - --port
      - "8000"
      - --tensor-parallel-size
      - "1"
      - --trust-remote-code
      - --quantization
      - compressed-tensors
      - --moe-backend
      - flashinfer_b12x
      - --attention-backend
      - flashinfer
      - --kv-cache-dtype
      - fp8
      - --gpu-memory-utilization
      - "0.65"
      - --kv-cache-memory-bytes
      - "44G"
      - --max-model-len
      - "262144"
      - --max-num-seqs
      - "4"
      - --max-num-batched-tokens
      - "8192"
      - --enable-chunked-prefill
      - --enable-prefix-caching
      - --skip-mm-profiling
      - --reasoning-parser
      - qwen3
      - --tool-call-parser
      - qwen3_coder
      - --enable-auto-tool-choice
      - --generation-config
      - vllm
      - --speculative-config
      - '{"method":"mtp","num_speculative_tokens":3}'
      - --chat-template
      - /workspace/chat_template.jinja
      - --default-chat-template-kwargs
      - '{"enable_thinking":true,"preserve_thinking":true}'
    networks:
      default:
        aliases:
          - qwen27-dflash

networks:
  default:
    external: true
    name: ${ODS_NETWORK}
```

Save with **Ctrl+O**, press **Enter**, and exit with **Ctrl+X**.

Validate without starting anything:

```bash
cd "$HOME/ai/services/qwen27-dflash"
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  config --quiet
```

No output means the Compose file is valid.

## Step 19 — Start and test Qwen 27B safely

### 19.1 Stop Qwen 35B first

Run in the **Spark terminal**:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
```

Confirm that the old model stopped:

```bash
docker ps --filter name=vllm-spark-fast
nvidia-smi
```

Do not proceed if the old model container is still running.

### 19.2 Start Qwen 27B with restart disabled

#### One-time repair if you saw `LocalEntryNotFoundError`

Use this repair only if you created `.env` and `compose.yaml` from the earlier version of this guide and then saw an error saying that outgoing traffic was disabled and no cached snapshot could be found. **Do not delete the Hugging Face cache.** The downloaded model files are still useful; the old Compose file simply failed to tell vLLM which cached commit to open.

First, if you are still following the log, press **Ctrl+C**. Then run this entire block in the **Spark terminal**. It stops only the failed Qwen 27B container, backs up `.env`, verifies that there is exactly one cached snapshot for each model, and records those two snapshot names:

```bash
cd "$HOME/ai/services/qwen27-dflash"

docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  down

cp -a .env ".env.before-revision-fix.$(date +%Y%m%d-%H%M%S)"

MAIN_ROOT="$HOME/.cache/huggingface/hub/models--nvidia--Qwen3.6-27B-NVFP4/snapshots"
DRAFT_ROOT="$HOME/.cache/huggingface/hub/models--z-lab--Qwen3.6-27B-DFlash/snapshots"
MAIN_COUNT="$(find "$MAIN_ROOT" -mindepth 1 -maxdepth 1 -type d | wc -l)"
DRAFT_COUNT="$(find "$DRAFT_ROOT" -mindepth 1 -maxdepth 1 -type d | wc -l)"

if [ "$MAIN_COUNT" -ne 1 ] || [ "$DRAFT_COUNT" -ne 1 ]; then
  echo "STOP: expected one cached snapshot per model; found main=$MAIN_COUNT draft=$DRAFT_COUNT"
  echo 'Main snapshots:'
  find "$MAIN_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
  echo 'Draft snapshots:'
  find "$DRAFT_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
  echo 'Do not guess. Copy this output into the Codex chat.'
  exit 1
fi

MAIN_REVISION="$(basename "$(find "$MAIN_ROOT" -mindepth 1 -maxdepth 1 -type d)")"
DRAFT_REVISION="$(basename "$(find "$DRAFT_ROOT" -mindepth 1 -maxdepth 1 -type d)")"

cat > model-revisions.env <<EOF
MAIN_REVISION=$MAIN_REVISION
DRAFT_REVISION=$DRAFT_REVISION
EOF

sed -i -e '/^MODEL_REVISION=/d' -e '/^DRAFT_REVISION=/d' .env
printf 'MODEL_REVISION=%s\nDRAFT_REVISION=%s\n' \
  "$MAIN_REVISION" "$DRAFT_REVISION" >> .env

grep -E '^(MODEL_ID|MODEL_REVISION|DRAFT_MODEL_ID|DRAFT_REVISION)=' .env
unset MAIN_ROOT DRAFT_ROOT MAIN_COUNT DRAFT_COUNT MAIN_REVISION DRAFT_REVISION
```

**Success looks like:** the last four lines show both model IDs and two long hexadecimal revision values. They are public model commit IDs, not passwords.

Next back up and open the Compose file:

```bash
cd "$HOME/ai/services/qwen27-dflash"
cp -a compose.yaml "compose.yaml.before-revision-fix.$(date +%Y%m%d-%H%M%S)"
nano compose.yaml
```

Find this line under `command:`:

```yaml
      - ${MODEL_ID}
```

Immediately below it, add these two lines with the same indentation:

```yaml
      - --revision
      - ${MODEL_REVISION}
```

Then find the old DFlash JSON line under `--speculative-config` and replace that entire line with:

```yaml
      - "{\"method\":\"dflash\",\"model\":\"${DRAFT_MODEL_ID}\",\"revision\":\"${DRAFT_REVISION}\",\"num_speculative_tokens\":10}"
```

Save with **Ctrl+O**, press **Enter**, and exit with **Ctrl+X**. Validate the repaired files without starting the model:

```bash
cd "$HOME/ai/services/qwen27-dflash"
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  config --quiet
```

No output means the repair is syntactically valid. Continue with the normal start commands below.

Run in the **Spark terminal**:

```bash
cd "$HOME/ai/services/qwen27-dflash"
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  up -d

docker logs -f vllm-qwen27-dflash
```

Model startup can take several minutes. When the log says the API server is ready, press **Ctrl+C**. This stops following the logs; it does not stop the container.

If the container exits, run:

```bash
docker logs --tail 250 vllm-qwen27-dflash
```

Do not add `--privileged` unless the log proves the runtime specifically requires it.

### 19.3 Test the raw model API

Run in the **Spark terminal**:

```bash
curl -fsS http://127.0.0.1:8001/v1/models

curl -fsS http://127.0.0.1:8001/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen27-dflash",
    "messages": [{"role": "user", "content": "Reply with exactly QWEN27_OK"}],
    "max_tokens": 40,
    "temperature": 0
  }'
```

**Success looks like:** the first response advertises `qwen27-dflash`, and the second contains `QWEN27_OK`.

## Step 20 — Add Qwen 27B to LiteLLM and Hermes

### 20.1 Back up LiteLLM configuration

Run in the **Spark terminal**:

```bash
cp -a "$HOME/ods/config/litellm/local.yaml" \
  "$HOME/ods/config/litellm/local.yaml.before-qwen27.$(date +%Y%m%d-%H%M%S)"

nano "$HOME/ods/config/litellm/local.yaml"
```

Find the existing `model_list:` section. Add this item at the same indentation level as the existing `spark-fast` item:

```yaml
  - model_name: qwen27-dflash
    litellm_params:
      model: openai/qwen27-dflash
      api_base: http://qwen27-dflash:8000/v1
      api_key: not-needed
```

Do not create a second `model_list:` heading. Save with **Ctrl+O**, **Enter**, and **Ctrl+X**.

Restart LiteLLM and inspect its log:

```bash
docker restart ods-litellm
docker logs --tail 100 ods-litellm
```

If the log reports a YAML error, restore the newest Qwen 27 backup:

```bash
cp -a "$(ls -1t $HOME/ods/config/litellm/local.yaml.before-qwen27.* | head -n 1)" \
  "$HOME/ods/config/litellm/local.yaml"
docker restart ods-litellm
```

### 20.2 Test through LiteLLM

Run in the **Spark terminal**:

```bash
set -a
. "$HOME/ods/.env"
set +a

curl -fsS http://127.0.0.1:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen27-dflash",
    "messages": [{"role": "user", "content": "Reply with exactly LITELLM_QWEN27_OK"}],
    "max_tokens": 40,
    "temperature": 0
  }'

unset LITELLM_KEY
```

### 20.3 Make Qwen 27B the current Hermes default

Only do this after the LiteLLM test succeeds:

```bash
hermes config set model.default qwen27-dflash
hermes config set model.context_length 262144
hermes config check

systemctl --user restart hermes-serve.service
hermes gateway stop
hermes gateway start
```

Open Hermes Desktop and Telegram and send:

```text
Reply with exactly HERMES_QWEN27_OK
```

Both surfaces should answer through the same Spark model and shared Hermes state.

## Step 21 — Return to the known-good Qwen 35B model

Run these commands in the **Spark terminal**, in this order:

```bash
cd "$HOME/ai/services/qwen27-dflash"
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  down

cd "$HOME/ai/services/qwen35"
docker compose --env-file .env up -d

hermes config set model.default spark-fast
hermes config set model.context_length 131072
hermes config check

systemctl --user restart hermes-serve.service
hermes gateway stop
hermes gateway start
```

Verify:

```bash
docker ps --filter name=vllm-spark-fast
hermes -z 'Reply with exactly BACK_ON_SPARK_FAST'
```

## Step 22 — Rules for every additional model

For Nemotron, DeepSeek, Ling, Gemma, or another model, always follow this order:

1. Stop the currently running large model.
2. Run `free -h`, `nvidia-smi`, and `df -h "$HOME"`.
3. Put the upstream Git checkout under `~/src/<repository>`.
4. Record its exact Git commit.
5. Put your controlled Compose file and `.env` under `~/ai/services/<profile>`.
6. Reuse `~/.cache/huggingface` when the runtime supports the Hugging Face cache contract.
7. Give the container, raw port, Docker alias, and LiteLLM model alias unique names.
8. Keep `RESTART_POLICY=no` during the first tests.
9. Test raw API, LiteLLM API, Hermes chat, and Hermes tool calls.
10. Enable restart persistence only after the model is proven stable.

### DeepSeek V4 Flash is an isolated appliance

Its SparkInfer repository uses converted/pruned weights, EXL3/custom kernels, and a large disk workspace. Do not treat it as another ordinary vLLM model.

The safe first action is checkout and inspection only:

```bash
cd "$HOME/src"
git clone https://github.com/0xSero/deepseek-v4-flash-0731-spark-sparkinfer.git
cd deepseek-v4-flash-0731-spark-sparkinfer
git rev-parse HEAD
docker compose config
```

Do not run `docker compose up` until every other GPU model is stopped and `df -h "$HOME"` shows at least 250 GB free; 300 GB is safer.

### Ling 3.0 Flash remains experimental

The community repository uses a custom mutable SGLang runtime for a roughly 120 GB-class model. Do not make it persistent until its checkpoint provenance, runtime digest, context/memory limits, and structured Hermes tool calls are verified.

## Step 23 — Daily model operations

The installed `spark-model` manager replaces repeated `cd` and Compose commands. It drains the active vLLM lane, unloads LM Studio when necessary, stops the old lane, waits for unified memory, starts the requested lane, and does not return until its OpenAI-compatible model endpoint is ready.

```bash
spark-model list
spark-model status

spark-model use qwen35
spark-model use qwen27-dflash
spark-model use nemotron3-omni
spark-model use nemotron35-lightning

spark-model logs qwen35
spark-model stop
```

The explicit lane names are:

| Lane | Engine | Service/model |
|---|---|---|
| `qwen35` | Compose/vLLM | `~/ai/services/qwen35`, API model `spark-fast` |
| `qwen27-dflash` | Compose/vLLM | `~/ai/services/qwen27-dflash` |
| `nemotron3-omni` | Compose/vLLM | `~/ai/services/nemotron3-omni`, 131,072 context with a 12 GiB KV pool |
| `nemotron35-lightning` | LM Studio | `nvidia/nemotron-3.5-lightning` at 65,536 context |

List installed Spark LM Studio models and load any future one without adding a hard-coded case:

```bash
spark-model lmstudio-list
spark-model use lmstudio:publisher/model-key
```

The dynamic form defaults to 65,536 context and a 3,600-second idle TTL. Override those for one shell only when the installed model was verified at the larger value:

```bash
SPARK_MODEL_LMSTUDIO_CONTEXT=131072 \
  spark-model use lmstudio:publisher/model-key
```

Lane definitions live in `~/.config/spark-model/lanes.d/*.conf`. A future vLLM, SGLang, or llama.cpp **container** uses the same `ENGINE="compose"` adapter; give it a unique service directory, container, loopback port, API model name, and Hermes context. The manager itself does not need to be rewritten as long as the service exposes `/v1/models` when ready. Preserve external secret files in `COMPOSE_ENV_FILES` rather than putting credentials in the lane definition.

The older `spark-inference-lane` command remains as a compatibility wrapper, but its aliases now resolve to explicit lanes. Prefer `spark-model` in new instructions.

Run this wider status block when diagnosing a switch:

```bash
dgx-status
dgx-models
dgx-space
column -ts $'\t' "$HOME/.config/dgx-spark/ports.tsv"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
nvidia-smi
```

Keep these ownership rules:

- Hugging Face models: `~/.cache/huggingface`
- NIM cache: `~/.cache/nim`
- LM Studio models: `~/.lmstudio/models`
- service definitions: `~/ai/services/<profile>`
- community source checkouts: `~/src/<repository>`
- benchmark records: `~/runs/YYYY-MM-DD_<engine>_<model>`
- secrets: `~/.config/dgx-spark/secrets.env` or the owning application's protected secrets file

Do not combine all model stores with symlinks. Track them in the manifest instead.

### Refresh newly installed Ollama and LM Studio models in Hermes

Both the Spark Remote Gateway and Windows Local Gateway have `discover_models: true` for `desktop-ollama` and `spark-lmstudio`. A newly installed desktop Ollama model or Spark LM Studio model therefore remains on its owning machine and is discovered through the existing stable provider endpoint.

After installing a model, open the Hermes model picker and use **Refresh models**, or run this in the owning Hermes profile:

```bash
hermes model --refresh
```

The command wipes the picker cache and re-fetches each provider's live `/v1/models` list. Add an explicit per-model `context_length` entry after verifying the runtime value; discovery proves identity and availability, not the safe context ceiling. Selecting an Ollama model causes Ollama to load that model and evict the previous resident model according to its one-model setting. Selecting an LM Studio model can trigger LM Studio JIT/Auto-Evict only among LM Studio-owned models; use `spark-model` first when crossing between a container lane and LM Studio.

Telegram and Discord use the Spark gateway's same provider inventory. In either bot, send `/model --refresh` to bypass Hermes's one-hour provider cache and open the refreshed interactive picker. A laptop connected to the Spark Remote Gateway inherits this inventory automatically. A laptop running an independent Local Gateway needs the two stable endpoints configured once, but `discover_models: true` then removes the need to edit its provider configuration after each new download.

For a tailnet-only Spark LM Studio URL usable by an independent laptop Local Gateway, grant the regular Spark user one-time Tailscale Serve control and create the proxy:

```bash
sudo tailscale set --operator=snknitin
tailscale serve --bg --https=8443 http://127.0.0.1:1234
tailscale serve status
```

The resulting provider base is `https://spark-07a8.tail4a1242.ts.net:8443/v1`. This is not needed by the recommended Remote Gateway path and must never be changed to Tailscale Funnel.

## Current primary sources

- [NVIDIA Hermes Agent on DGX Spark](https://build.nvidia.com/spark/hermes-agent/instructions)
- [NVIDIA DGX Spark playbook catalog](https://build.nvidia.com/spark)
- [NVIDIA vLLM for inference](https://build.nvidia.com/spark/vllm/instructions)
- [NVIDIA SGLang for inference](https://build.nvidia.com/spark/sglang/instructions)
- [NVIDIA NIM on Spark](https://build.nvidia.com/spark/nim-llm)
- [MiaAI Qwen 35B DGX Spark repository](https://github.com/MiaAI-Lab/Unsloth-Qwen3.6-35b-NVFP4-DGX-Spark)
- [MiaAI Qwen 27B DFlash repository](https://github.com/MiaAI-Lab/Qwen3.6-27B-NVFP4-DFlash-DGX-Spark)
- [MiaAI Ling 3.0 Flash SGLang repository](https://github.com/MiaAI-Lab/Ling-3.0-Flash-SGLang-DGX-Spark)
- [0xSero DeepSeek V4 Flash SparkInfer repository](https://github.com/0xSero/deepseek-v4-flash-0731-spark-sparkinfer)

Related: [[DGX Spark Operations Setup Guide]] | [[DGX Spark Aug 2026 Model Deployment Research]] | [[Local Setup Index]]
