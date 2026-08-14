# DGX Spark Nemotron 3.5 Lightning Tutorial

This guide installs the current official one-DGX-Spark vLLM recipe for Nemotron 3.5 Lightning and its DSpark speculative-decoding assistant.

| Item                | Value                                                       |
| ------------------- | ----------------------------------------------------------- |
| Main model          | `nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4`        |
| DSpark assistant    | `nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DSpark` |
| Runtime             | `vllm/vllm-openai:v0.27.1`                                  |
| Container           | `vllm-nemotron35-lightning`                                 |
| Raw Spark API       | `http://127.0.0.1:8005/v1`                                  |
| ODS network address | `http://nemotron35-lightning:8000/v1`                       |
| LiteLLM/Hermes name | `nemotron35-lightning`                                      |

NVIDIA documents this combination on one DGX Spark. The main checkpoint is about 23.45 GiB and the DSpark assistant about 1.26 GiB on disk. The assistant predicts several tokens so the main model can verify them together; it is not another full chat model.

Unless a section says **Hermes Desktop**, run every command in the **Spark terminal opened from NVIDIA Sync**.

> [!important] This supersedes the community recipe as the default
> The MiaAI-Lab repository was useful before the official path was available. It uses SGLang, a mutable development image, host networking, and a start script that recreates its container. The official numbered vLLM recipe is safer for your main beginner setup. The community path remains documented at the end for later benchmarking.

## Step 1 — Read-only preflight

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
free -h
df -h "$HOME"
command -v docker
command -v hf
```

You may leave Qwen running during Steps 2 and 3. Do not start Nemotron until Step 4 stops the current large worker.

## Step 2 — Create the preparation script

```bash
mkdir -p "$HOME/ai/tools"
nano "$HOME/ai/tools/prepare-nemotron35-lightning.sh"
```

Copy everything in the next box into Nano:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

PROFILE="nemotron35-lightning"
TARGET_ID="nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4"
DRAFT_ID="nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4-DSpark"
MODEL_ALIAS="nemotron35-lightning"
HOST_PORT="8005"
SERVICE_DIR="$HOME/ai/services/$PROFILE"
HF_CACHE="$HOME/.cache/huggingface"
VLLM_CACHE="$HOME/.cache/vllm/$PROFILE"
TRITON_CACHE="$HOME/.cache/triton/$PROFILE"
IMAGE_TAG="vllm/vllm-openai:v0.27.1"

for tool in docker hf; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: $tool is missing."
    exit 1
  }
done

docker inspect ods-litellm >/dev/null 2>&1 || {
  echo 'ERROR: ods-litellm was not found.'
  exit 1
}

ODS_NETWORK="$(docker inspect -f '{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}' ods-litellm | head -n 1)"
test -n "$ODS_NETWORK" || {
  echo 'ERROR: the ODS Docker network could not be discovered.'
  exit 1
}

mkdir -p "$SERVICE_DIR" "$HF_CACHE" "$VLLM_CACHE" "$TRITON_CACHE"

set -a
. "$HOME/.config/dgx-spark/secrets.env"
set +a

echo "Downloading main checkpoint: $TARGET_ID"
TARGET_PATH="$(HF_HOME="$HF_CACHE" hf download "$TARGET_ID")"

echo "Downloading DSpark assistant: $DRAFT_ID"
DRAFT_PATH="$(HF_HOME="$HF_CACHE" hf download "$DRAFT_ID")"

unset HF_TOKEN NGC_API_KEY

echo "Pulling $IMAGE_TAG"
docker pull "$IMAGE_TAG"
VLLM_IMAGE_PINNED="$(docker image inspect --format '{{index .RepoDigests 0}}' "$IMAGE_TAG")"

if [[ "$VLLM_IMAGE_PINNED" != *@sha256:* ]]; then
  echo 'ERROR: Docker did not return a pinned image digest.'
  exit 1
fi

cat > "$SERVICE_DIR/.env" <<EOF
PROFILE=$PROFILE
TARGET_ID=$TARGET_ID
TARGET_PATH=$TARGET_PATH
TARGET_REVISION=$(basename "$TARGET_PATH")
DRAFT_ID=$DRAFT_ID
DRAFT_PATH=$DRAFT_PATH
DRAFT_REVISION=$(basename "$DRAFT_PATH")
MODEL_ALIAS=$MODEL_ALIAS
HOST_PORT=$HOST_PORT
ODS_NETWORK=$ODS_NETWORK
VLLM_IMAGE_PINNED=$VLLM_IMAGE_PINNED
VLLM_CACHE_ROOT=$VLLM_CACHE
TRITON_CACHE_ROOT=$TRITON_CACHE
RESTART_POLICY=no
EOF

cat > "$SERVICE_DIR/compose.yaml" <<'YAML'
services:
  nemotron35-lightning:
    image: ${VLLM_IMAGE_PINNED}
    container_name: vllm-nemotron35-lightning
    restart: "${RESTART_POLICY:-no}"
    gpus: all
    ipc: host
    ports:
      - "127.0.0.1:${HOST_PORT}:8000"
    environment:
      HF_HUB_OFFLINE: "1"
      VLLM_CACHE_ROOT: /root/.cache/vllm
      TRITON_CACHE_DIR: /root/.triton
    volumes:
      - ${TARGET_PATH}:/models/target:ro
      - ${DRAFT_PATH}:/models/draft:ro
      - ${VLLM_CACHE_ROOT}:/root/.cache/vllm
      - ${TRITON_CACHE_ROOT}:/root/.triton
    entrypoint: ["vllm", "serve"]
    command:
      - --model
      - /models/target
      - --served-model-name
      - ${MODEL_ALIAS}
      - --host
      - "0.0.0.0"
      - --port
      - "8000"
      - --tensor-parallel-size
      - "1"
      - --trust-remote-code
      - --max-model-len
      - "131072"
      - --max-num-seqs
      - "4"
      - --gpu-memory-utilization
      - "0.91"
      - --moe-backend
      - marlin
      - --kv-cache-dtype
      - fp8
      - --enable-prefix-caching
      - --mamba-backend
      - flashinfer
      - --mamba-cache-mode
      - align
      - --reasoning-parser
      - nemotron_v3
      - --tool-call-parser
      - qwen3_coder
      - --enable-auto-tool-choice
      - --speculative_config.num_speculative_tokens
      - "3"
      - --speculative_config.model
      - /models/draft
    networks:
      default:
        aliases:
          - nemotron35-lightning

networks:
  default:
    external: true
    name: ${ODS_NETWORK}
YAML

chmod 600 "$SERVICE_DIR/.env"

docker compose \
  --env-file "$SERVICE_DIR/.env" \
  -f "$SERVICE_DIR/compose.yaml" \
  config --quiet

echo
echo "Prepared:        $PROFILE"
echo "Main revision:   $(basename "$TARGET_PATH")"
echo "DSpark revision: $(basename "$DRAFT_PATH")"
echo "Raw API:         http://127.0.0.1:$HOST_PORT/v1"
echo 'The model has not been started.'
```

Save with **Ctrl+O**, press **Enter**, then exit with **Ctrl+X**. Make it executable:

```bash
chmod 700 "$HOME/ai/tools/prepare-nemotron35-lightning.sh"
```

## Step 3 — Download and prepare without loading the model

```bash
tmux new -s nemotron35-prepare
```

Inside tmux:

```bash
"$HOME/ai/tools/prepare-nemotron35-lightning.sh"
```

Detach with **Ctrl+B**, release, then **D**. Reattach with:

```bash
tmux attach -t nemotron35-prepare
```

Success ends with `Prepared: nemotron35-lightning` and says the model has not started.

## Step 4 — Stop Qwen and verify memory recovery

If Qwen 35B is running:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
```

Now verify:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}' \
  | grep -E 'NAMES|vllm|sglang' || true
free -h
nvidia-smi
```

The official `0.91` memory utilization is intentionally aggressive for performance. Do not continue if another large model remains loaded. If the Spark is still under memory pressure after Qwen stops, rebooting or killing random processes is not the next step; identify the remaining process first.

## Step 5 — Start the official vLLM profile

```bash
cd "$HOME/ai/services/nemotron35-lightning"
docker compose --env-file .env up -d
docker logs -f vllm-nemotron35-lightning
```

Wait until the API server is ready, then press **Ctrl+C**.

## Step 6 — Test the raw API

```bash
curl -fsS http://127.0.0.1:8005/v1/models

curl -fsS http://127.0.0.1:8005/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "nemotron35-lightning",
    "messages": [{"role": "user", "content": "Reply with exactly NEMOTRON35_OK"}],
    "max_tokens": 80,
    "temperature": 0
  }'
```

Record the identity and a short speed result before connecting it to Hermes:

```bash
mkdir -p "$HOME/runs/nemotron35-lightning"
docker inspect vllm-nemotron35-lightning \
  --format '{{.Config.Image}}' \
  | tee "$HOME/runs/nemotron35-lightning/image-used.txt"
```

## Step 7 — Add it to LiteLLM

```bash
cp -a "$HOME/ods/config/litellm/local.yaml" \
  "$HOME/ods/config/litellm/local.yaml.before-nemotron35.$(date +%Y%m%d-%H%M%S)"

nano "$HOME/ods/config/litellm/local.yaml"
```

Add this item under the one existing `model_list:`:

```yaml
  - model_name: nemotron35-lightning
    litellm_params:
      model: openai/nemotron35-lightning
      api_base: http://nemotron35-lightning:8000/v1
      api_key: not-needed
```

Save, then restart only the gateway whose configuration changed:

```bash
docker restart ods-litellm
docker logs --tail 100 ods-litellm
```

Run the authenticated LiteLLM smoke test from the Qwen tutorial, replacing the model name with `nemotron35-lightning`.

## Step 8 — Test through Hermes

```bash
hermes config set model.default nemotron35-lightning
hermes config set model.context_length 131072
hermes config check
systemctl --user restart hermes-serve.service
hermes gateway stop
hermes gateway start
```

In Hermes Desktop, select `nemotron35-lightning`. Test:

1. a short factual question;
2. a reasoning problem;
3. one tool call;
4. a short coding edit.

Do not judge DSpark from one response. Compare output quality and tokens per second with the same prompts used for Qwen.

## Step 9 — Stop it and restore Qwen

```bash
cd "$HOME/ai/services/nemotron35-lightning"
docker compose --env-file .env down

cd "$HOME/ai/services/qwen35"
docker compose --env-file .env up -d

hermes config set model.default spark-fast
hermes config set model.context_length 131072
hermes config check
systemctl --user restart hermes-serve.service
hermes gateway stop
hermes gateway start
```

## If the official `0.91` setting is too aggressive

Open the Compose file:

```bash
nano "$HOME/ai/services/nemotron35-lightning/compose.yaml"
```

Change only `0.91` to `0.85`, save, and start again. If it still fails, change the initial maximum length from `131072` to `65536`. Do not remove the DSpark assistant or change five flags at once; that would make the cause unclear.

## Optional advanced appendix — the MiaAI-Lab SGLang recipe

This is not required for the official installation above. Clone it only when you are ready to benchmark SGLang against vLLM:

```bash
mkdir -p "$HOME/src"
cd "$HOME/src"
git clone https://github.com/MiaAI-Lab/Nemotron3.5-Lightning-DGX-Spark-RTX-5090-6000-PRO.git
cd Nemotron3.5-Lightning-DGX-Spark-RTX-5090-6000-PRO
git rev-parse HEAD
sed -n '1,240p' start.sh
```

The last two commands record the exact commit and show you what the launcher will do. Do **not** run `start.sh` as a 24/7 service yet. Its mutable `lmsysorg/sglang:dev-nemotron3-5-lightning` image, host networking, and container-recreation behavior need to be converted into the same pinned, loopback-restricted profile pattern before production use.

## Primary sources

- [NVIDIA Build Nemotron 3.5 Lightning](https://build.nvidia.com/nvidia/nemotron-3.5-lightning-30b-a3b)
- [NVIDIA Nemotron 3.5 Lightning model card](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4)
- [MiaAI-Lab SGLang/DSpark recipe](https://github.com/MiaAI-Lab/Nemotron3.5-Lightning-DGX-Spark-RTX-5090-6000-PRO)

Related: [[DGX Spark Additional Model Tutorials Index]] | [[DGX Spark Nemotron 3 Nano Omni Tutorial]] | [[DGX Spark Muse Glimmer 30B Readiness Tutorial]]
