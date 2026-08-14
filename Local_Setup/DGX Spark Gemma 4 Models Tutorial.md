# DGX Spark Gemma 4 Models Tutorial

This beginner tutorial prepares two independent vLLM profiles:

| Profile         | Exact checkpoint               | Raw port | LiteLLM/Hermes name |
| --------------- | ------------------------------ | -------: | ------------------- |
| Gemma 4 26B-A4B | `nvidia/Gemma-4-26B-A4B-NVFP4` |   `8002` | `gemma4-26b-a4b`    |
| Gemma 4 31B     | `nvidia/Gemma-4-31B-IT-NVFP4`  |   `8003` | `gemma4-31b`        |

The 26B-A4B model is the recommended first Gemma test. It has 25.2B total parameters but activates about 3.8B per token, and the maintained vLLM recipe explicitly marks DGX Spark/GB10 as verified. The 31B model is dense and is primarily a quality comparison. Its one-GPU NVFP4 recipe makes a Spark test reasonable, but that recipe does **not** currently mark DGX Spark as verified. Treat the 31B profile as experimental. [Gemma 4 26B card](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4), [official 26B recipe](https://github.com/vllm-project/recipes/blob/main/models/Google/gemma-4-26B-A4B-it.yaml), and [official 31B recipe](https://github.com/vllm-project/recipes/blob/main/models/Google/gemma-4-31B-it.yaml)

> [!warning] Choose one Gemma packaging path
> This tutorial downloads NVIDIA's Hugging Face NVFP4 checkpoints for vLLM. The Ollama tutorial offers different Gemma packages. Do not do both unless you deliberately want duplicate model copies.

Unless a section says **Hermes Desktop**, run every command in the **Spark terminal opened from NVIDIA Sync**.

## Step 1 — Preflight without changing anything

Paste this whole block into the Spark terminal:

```bash
echo '=== Running large-model containers ==='
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' \
  | grep -E 'NAMES|vllm|sglang|ollama' || true

echo '=== Memory ==='
free -h

echo '=== Storage ==='
df -h "$HOME"

echo '=== Required commands ==='
for tool in docker hf nano; do
  command -v "$tool" || true
done
```

Expected now:

- `vllm-spark-fast` may still be running;
- you have roughly 3.2 TiB free disk;
- `docker`, `hf`, and `nano` print paths.

You may continue with the downloads while Qwen 35B is running. Do not start either Gemma until Step 5 stops Qwen.

## Step 2 — Create one reusable preparation script

This script accepts either `gemma26` or `gemma31`. It downloads the selected model into the shared Hugging Face cache, records the exact revision, pins the Docker image digest, and creates the service files. It does **not** start a model.

Create the script file:

```bash
mkdir -p "$HOME/ai/tools"
nano "$HOME/ai/tools/prepare-gemma4-profile.sh"
```

Nano opens an empty editor. Copy everything in the next box and paste it into Nano:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

case "${1:-}" in
  gemma26)
    PROFILE="gemma4-26b-a4b"
    MODEL_ID="nvidia/Gemma-4-26B-A4B-NVFP4"
    MODEL_ALIAS="gemma4-26b-a4b"
    HOST_PORT="8002"
    GPU_MEMORY_UTILIZATION="0.80"
    MAX_NUM_SEQS="8"
    ;;
  gemma31)
    PROFILE="gemma4-31b"
    MODEL_ID="nvidia/Gemma-4-31B-IT-NVFP4"
    MODEL_ALIAS="gemma4-31b"
    HOST_PORT="8003"
    GPU_MEMORY_UTILIZATION="0.80"
    MAX_NUM_SEQS="4"
    ;;
  *)
    echo 'Usage: prepare-gemma4-profile.sh gemma26|gemma31'
    exit 2
    ;;
esac

SERVICE_DIR="$HOME/ai/services/$PROFILE"
HF_CACHE="$HOME/.cache/huggingface"
VLLM_CACHE="$HOME/.cache/vllm/$PROFILE"
TRITON_CACHE="$HOME/.cache/triton/$PROFILE"
IMAGE_TAG="vllm/vllm-openai:gemma4-0505-cu130"

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

echo "Downloading $MODEL_ID into $HF_CACHE"
MODEL_PATH="$(HF_HOME="$HF_CACHE" hf download "$MODEL_ID")"
MODEL_REVISION="$(basename "$MODEL_PATH")"
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
MODEL_ID=$MODEL_ID
MODEL_REVISION=$MODEL_REVISION
MODEL_ALIAS=$MODEL_ALIAS
HOST_PORT=$HOST_PORT
ODS_NETWORK=$ODS_NETWORK
VLLM_IMAGE_PINNED=$VLLM_IMAGE_PINNED
HF_HOME=$HF_CACHE
VLLM_CACHE_ROOT=$VLLM_CACHE
TRITON_CACHE_ROOT=$TRITON_CACHE
RESTART_POLICY=no
GPU_MEMORY_UTILIZATION=$GPU_MEMORY_UTILIZATION
MAX_NUM_SEQS=$MAX_NUM_SEQS
EOF

cat > "$SERVICE_DIR/compose.yaml" <<'YAML'
services:
  gemma4:
    image: ${VLLM_IMAGE_PINNED}
    container_name: vllm-${PROFILE}
    restart: "${RESTART_POLICY:-no}"
    gpus: all
    ipc: host
    ports:
      - "127.0.0.1:${HOST_PORT}:8000"
    environment:
      HF_HOME: /root/.cache/huggingface
      HF_HUB_OFFLINE: "1"
      HF_TOKEN: ${HF_TOKEN}
      VLLM_CACHE_ROOT: /root/.cache/vllm
      TRITON_CACHE_DIR: /root/.triton
      VLLM_USE_V2_MODEL_RUNNER: "1"
    volumes:
      - ${HF_HOME}:/root/.cache/huggingface
      - ${VLLM_CACHE_ROOT}:/root/.cache/vllm
      - ${TRITON_CACHE_ROOT}:/root/.triton
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
      - --quantization
      - modelopt
      - --dtype
      - auto
      - --trust-remote-code
      - --gpu-memory-utilization
      - "${GPU_MEMORY_UTILIZATION}"
      - --max-model-len
      - "65536"
      - --max-num-seqs
      - "${MAX_NUM_SEQS}"
      - --max-num-batched-tokens
      - "8192"
      - --enable-chunked-prefill
      - --enable-prefix-caching
      - --kv-cache-dtype
      - fp8
      - --load-format
      - fastsafetensors
      - --reasoning-parser
      - gemma4
      - --tool-call-parser
      - gemma4
      - --enable-auto-tool-choice
      - --default-chat-template-kwargs
      - '{"enable_thinking":true}'
    networks:
      default:
        aliases:
          - ${MODEL_ALIAS}

networks:
  default:
    external: true
    name: ${ODS_NETWORK}
YAML

chmod 600 "$SERVICE_DIR/.env"

docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file "$SERVICE_DIR/.env" \
  -f "$SERVICE_DIR/compose.yaml" \
  config --quiet

echo
echo "Prepared:       $PROFILE"
echo "Model:          $MODEL_ID"
echo "Revision:       $MODEL_REVISION"
echo "Raw API:        http://127.0.0.1:$HOST_PORT/v1"
echo "Docker network: $ODS_NETWORK"
echo 'The model has not been started.'
```

Save the script:

1. Press **Ctrl+O**.
2. Press **Enter**.
3. Press **Ctrl+X**.

Make it executable:

```bash
chmod 700 "$HOME/ai/tools/prepare-gemma4-profile.sh"
```

## Step 3 — Download and prepare Gemma 4 26B-A4B

Use `tmux` so the download survives an SSH interruption:

```bash
tmux new -s gemma26-prepare
```

Inside tmux, run:

```bash
"$HOME/ai/tools/prepare-gemma4-profile.sh" gemma26
```

To detach while it downloads, press **Ctrl+B**, release both keys, then press **D**. Reattach later with:

```bash
tmux attach -t gemma26-prepare
```

Success looks like the final output contains `Prepared: gemma4-26b-a4b` and says that the model has not been started.

Verify the files:

```bash
cd "$HOME/ai/services/gemma4-26b-a4b"
sed -n '1,20p' .env
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  config --quiet
```

No output from `config --quiet` means the Compose file is valid.

## Step 4 — Optionally prepare Gemma 4 31B now

This only downloads and prepares the profile; it does not load it into memory:

```bash
tmux new -s gemma31-prepare
```

Inside tmux:

```bash
"$HOME/ai/tools/prepare-gemma4-profile.sh" gemma31
```

You can skip this step and return later. Test Gemma 26B before Gemma 31B.

## Step 5 — Stop Qwen 35B before loading Gemma

Run:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
```

Verify memory was released:

```bash
docker ps --filter name=vllm-spark-fast
free -h
nvidia-smi
```

The Docker result for `vllm-spark-fast` must be empty. Do not continue if it is still running.

## Step 6 — Start and test Gemma 4 26B-A4B

Start it:

```bash
cd "$HOME/ai/services/gemma4-26b-a4b"
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  up -d

docker logs -f vllm-gemma4-26b-a4b
```

Wait until the API server reports that it is ready. This can take several minutes on the first start. Press **Ctrl+C** to stop following the log; the container keeps running.

Test the raw API:

```bash
curl -fsS http://127.0.0.1:8002/v1/models

curl -fsS http://127.0.0.1:8002/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "gemma4-26b-a4b",
    "messages": [{"role": "user", "content": "Reply with exactly GEMMA26_OK"}],
    "max_tokens": 40,
    "temperature": 0
  }'
```

Success looks like the first response lists `gemma4-26b-a4b` and the second contains `GEMMA26_OK`.

## Step 7 — Add Gemma 26B to LiteLLM and Hermes

Back up the LiteLLM configuration:

```bash
cp -a "$HOME/ods/config/litellm/local.yaml" \
  "$HOME/ods/config/litellm/local.yaml.before-gemma26.$(date +%Y%m%d-%H%M%S)"

nano "$HOME/ods/config/litellm/local.yaml"
```

Under the existing `model_list:` heading, add this item at the same indentation level as `spark-fast`:

```yaml
  - model_name: gemma4-26b-a4b
    litellm_params:
      model: openai/gemma4-26b-a4b
      api_base: http://gemma4-26b-a4b:8000/v1
      api_key: not-needed
```

Do not create a second `model_list:` heading. Save with **Ctrl+O**, **Enter**, and **Ctrl+X**.

Restart only LiteLLM because its configuration changed:

```bash
docker restart ods-litellm
docker logs --tail 100 ods-litellm
```

Test through LiteLLM:

```bash
set -a
. "$HOME/ods/.env"
set +a

curl -fsS http://127.0.0.1:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "gemma4-26b-a4b",
    "messages": [{"role": "user", "content": "Reply with exactly GEMMA26_LITELLM_OK"}],
    "max_tokens": 40,
    "temperature": 0
  }'

unset LITELLM_KEY
```

Only after that succeeds, make it the temporary Hermes test model:

```bash
hermes config set model.default gemma4-26b-a4b
hermes config set model.context_length 65536
hermes config check
systemctl --user restart hermes-serve.service
hermes gateway stop
hermes gateway start
```

In Hermes Desktop, select `gemma4-26b-a4b` and ask:

```text
Reply with exactly HERMES_GEMMA26_OK
```

> [!note] Static menu entry
> Hermes will continue listing this model even after its container stops. Selecting a stopped profile will cause a connection error until you start that profile again.

## Step 8 — Stop Gemma 26B and test Gemma 31B

Stop Gemma 26B:

```bash
cd "$HOME/ai/services/gemma4-26b-a4b"
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  down
```

Start Gemma 31B:

```bash
cd "$HOME/ai/services/gemma4-31b"
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  up -d

docker logs -f vllm-gemma4-31b
```

When ready, press **Ctrl+C** and test:

```bash
curl -fsS http://127.0.0.1:8003/v1/models

curl -fsS http://127.0.0.1:8003/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "gemma4-31b",
    "messages": [{"role": "user", "content": "Reply with exactly GEMMA31_OK"}],
    "max_tokens": 40,
    "temperature": 0
  }'
```

Add this separate LiteLLM item under `model_list:` if the raw test succeeds:

```yaml
  - model_name: gemma4-31b
    litellm_params:
      model: openai/gemma4-31b
      api_base: http://gemma4-31b:8000/v1
      api_key: not-needed
```

Back up the file before editing and restart `ods-litellm` afterward, exactly as in Step 7.

## Step 9 — Return to Qwen 35B

Stop whichever Gemma is running:

```bash
cd "$HOME/ai/services/gemma4-26b-a4b"
docker compose --env-file "$HOME/.config/dgx-spark/secrets.env" --env-file .env down || true

cd "$HOME/ai/services/gemma4-31b"
docker compose --env-file "$HOME/.config/dgx-spark/secrets.env" --env-file .env down || true
```

Start Qwen 35B and restore the Hermes default:

```bash
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

## Daily commands

Start Gemma 26B after stopping another large model:

```bash
cd "$HOME/ai/services/gemma4-26b-a4b"
docker compose --env-file "$HOME/.config/dgx-spark/secrets.env" --env-file .env up -d
```

Stop it without deleting weights:

```bash
cd "$HOME/ai/services/gemma4-26b-a4b"
docker compose --env-file "$HOME/.config/dgx-spark/secrets.env" --env-file .env down
```

The corresponding Gemma 31B commands use `~/ai/services/gemma4-31b`.

## Troubleshooting

If a container exits:

```bash
docker logs --tail 300 vllm-gemma4-26b-a4b
docker logs --tail 300 vllm-gemma4-31b
```

If you see an out-of-memory error, do not add swap or start both Gemmas. Edit the profile's `.env` and lower the model's memory utilization from `0.80` to `0.75`, or edit `compose.yaml` and lower `--max-model-len` from `65536` to `32768`. Change one setting at a time and keep a note of the result.

If vLLM says the model architecture or `modelopt` quantization is unsupported, stop. Do not switch to a random nightly image. Copy the exact log into Codex so the runtime version can be revalidated.

## Primary sources

- [NVIDIA Gemma 4 26B-A4B NVFP4 model card](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)
- [NVIDIA Gemma 4 31B IT NVFP4 model card](https://huggingface.co/nvidia/Gemma-4-31B-IT-NVFP4)
- [vLLM memory configuration](https://docs.vllm.ai/en/latest/api/vllm/config/)

Related: [[DGX Spark Additional Model Tutorials Index]] | [[DGX Spark Model Installation And Switching Guide]] | [[DGX Spark Ollama And ODS Tutorial]]
