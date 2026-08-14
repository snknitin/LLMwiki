# DGX Spark Nemotron 3 Nano Omni Tutorial

This tutorial installs NVIDIA's multimodal NVFP4 model as a stopped-by-default vLLM profile:

| Item                | Value                                                 |
| ------------------- | ----------------------------------------------------- |
| Model               | `nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4` |
| Container           | `vllm-nemotron3-omni`                                 |
| Raw Spark API       | `http://127.0.0.1:8004/v1`                            |
| ODS network address | `http://nemotron3-omni:8000/v1`                       |
| LiteLLM/Hermes name | `nemotron3-omni`                                      |

Nemotron 3 Nano Omni can accept text, images, audio, and video. We will first prove that ordinary text serving works. Multimodal tests come only after the basic server is healthy.

Unless a section says **Hermes Desktop**, run every command in the **Spark terminal opened from NVIDIA Sync**.

> [!important] Memory rule
> You may download and build this profile while Qwen is running. You must stop Qwen, Gemma, SGLang, Ollama models, and LM Studio models before starting this container.

## Step 1 — Check the current Spark state

Paste this whole block into the Spark terminal:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
free -h
df -h "$HOME"
command -v docker
command -v hf
```

This is read-only. It does not stop or change anything.

## Step 2 — Create the preparation script

The official NVIDIA recipe installs vLLM's audio dependencies in the vLLM image. This guide builds that small derived image once instead of reinstalling packages every time the container starts.

Create a script:

```bash
mkdir -p "$HOME/ai/tools"
nano "$HOME/ai/tools/prepare-nemotron3-omni.sh"
```

Copy everything in the next box into Nano:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

PROFILE="nemotron3-omni"
MODEL_ID="nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4"
MODEL_ALIAS="nemotron3-omni"
HOST_PORT="8004"
SERVICE_DIR="$HOME/ai/services/$PROFILE"
HF_CACHE="$HOME/.cache/huggingface"
VLLM_CACHE="$HOME/.cache/vllm/$PROFILE"
TRITON_CACHE="$HOME/.cache/triton/$PROFILE"
MEDIA_DIR="$HOME/ai/media"
BASE_IMAGE_TAG="vllm/vllm-openai:v0.20.0"
LOCAL_IMAGE="local/vllm-nemotron3-omni:v0.20.0"

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

mkdir -p "$SERVICE_DIR" "$HF_CACHE" "$VLLM_CACHE" "$TRITON_CACHE" "$MEDIA_DIR"

set -a
. "$HOME/.config/dgx-spark/secrets.env"
set +a

echo "Downloading $MODEL_ID"
MODEL_PATH="$(HF_HOME="$HF_CACHE" hf download "$MODEL_ID")"
MODEL_REVISION="$(basename "$MODEL_PATH")"
unset HF_TOKEN NGC_API_KEY

echo "Pulling $BASE_IMAGE_TAG"
docker pull "$BASE_IMAGE_TAG"
BASE_IMAGE_PINNED="$(docker image inspect --format '{{index .RepoDigests 0}}' "$BASE_IMAGE_TAG")"

if [[ "$BASE_IMAGE_PINNED" != *@sha256:* ]]; then
  echo 'ERROR: Docker did not return a pinned base-image digest.'
  exit 1
fi

cat > "$SERVICE_DIR/Dockerfile" <<'DOCKERFILE'
ARG BASE_IMAGE=vllm/vllm-openai:v0.20.0
FROM ${BASE_IMAGE}
RUN pip install --no-cache-dir 'vllm[audio]==0.20.0'
DOCKERFILE

docker build \
  --build-arg "BASE_IMAGE=$BASE_IMAGE_PINNED" \
  -t "$LOCAL_IMAGE" \
  "$SERVICE_DIR"

cat > "$SERVICE_DIR/.env" <<EOF
PROFILE=$PROFILE
MODEL_ID=$MODEL_ID
MODEL_REVISION=$MODEL_REVISION
MODEL_ALIAS=$MODEL_ALIAS
HOST_PORT=$HOST_PORT
ODS_NETWORK=$ODS_NETWORK
LOCAL_IMAGE=$LOCAL_IMAGE
BASE_IMAGE_PINNED=$BASE_IMAGE_PINNED
HF_HOME=$HF_CACHE
VLLM_CACHE_ROOT=$VLLM_CACHE
TRITON_CACHE_ROOT=$TRITON_CACHE
MEDIA_DIR=$MEDIA_DIR
RESTART_POLICY=no
EOF

cat > "$SERVICE_DIR/compose.yaml" <<'YAML'
services:
  nemotron3-omni:
    image: ${LOCAL_IMAGE}
    container_name: vllm-nemotron3-omni
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
    volumes:
      - ${HF_HOME}:/root/.cache/huggingface
      - ${VLLM_CACHE_ROOT}:/root/.cache/vllm
      - ${TRITON_CACHE_ROOT}:/root/.triton
      - ${MEDIA_DIR}:/media:ro
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
      - --gpu-memory-utilization
      - "0.70"
      - --max-model-len
      - "65536"
      - --max-num-seqs
      - "4"
      - --max-num-batched-tokens
      - "16384"
      - --limit-mm-per-prompt
      - '{"video":1,"image":1,"audio":1}'
      - --media-io-kwargs
      - '{"video":{"fps":2,"num_frames":128}}'
      - --allowed-local-media-path
      - /media
      - --enable-prefix-caching
      - --reasoning-parser
      - nemotron_v3
      - --tool-call-parser
      - qwen3_coder
      - --enable-auto-tool-choice
    networks:
      default:
        aliases:
          - nemotron3-omni

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
echo 'The model has not been started.'
```

Save and exit Nano:

1. Press **Ctrl+O**.
2. Press **Enter**.
3. Press **Ctrl+X**.

Make the script executable:

```bash
chmod 700 "$HOME/ai/tools/prepare-nemotron3-omni.sh"
```

## Step 3 — Download the model and build the image

Start a persistent terminal session:

```bash
tmux new -s nemotron-omni-prepare
```

Inside tmux, run:

```bash
"$HOME/ai/tools/prepare-nemotron3-omni.sh"
```

To detach, press **Ctrl+B**, release both keys, then press **D**. Reattach with:

```bash
tmux attach -t nemotron-omni-prepare
```

Success looks like `Prepared: nemotron3-omni` followed by `The model has not been started.`

> [!success] The reported `InvalidDefaultArgInFrom` output was only a warning
> Your image build completed, Docker wrote image `local/vllm-nemotron3-omni:v0.20.0`, the exact model revision was recorded, and the script printed `Prepared: nemotron3-omni`. **Do not repeat the download or preparation. Continue with Step 4.** The Dockerfile in the current version of this tutorial supplies a harmless default image value, which prevents that warning on future preparations while the build still replaces it with the pinned digest.

If you want one read-only confirmation before continuing, run this in the **Spark terminal**:

```bash
docker image inspect local/vllm-nemotron3-omni:v0.20.0 \
  --format 'Image ID={{.Id}} Size={{.Size}}'

test -f "$HOME/ai/services/nemotron3-omni/.env" \
  && test -f "$HOME/ai/services/nemotron3-omni/compose.yaml" \
  && echo 'NEMOTRON_OMNI_PREPARED_OK'
```

Success is an image ID followed by `NEMOTRON_OMNI_PREPARED_OK`. This does not start the model.

## Step 4 — Stop the currently loaded large model

If Qwen 35B is running:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
```

Also check that no other large runtime is loaded:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}' \
  | grep -E 'NAMES|vllm|sglang|ollama' || true
free -h
nvidia-smi
```

An `ods-ollama` server container is harmless if it has no loaded model. Check it later with `docker exec ods-ollama ollama ps`.

## Step 5 — Start Nemotron and follow its logs

```bash
cd "$HOME/ai/services/nemotron3-omni"
docker compose \
  --env-file "$HOME/.config/dgx-spark/secrets.env" \
  --env-file .env \
  up -d

docker logs -f vllm-nemotron3-omni
```

Wait for the API server to report that it is ready. Press **Ctrl+C** to stop following the logs; the model continues running.

## Step 6 — Test text before testing media

```bash
curl -fsS http://127.0.0.1:8004/v1/models

curl -fsS http://127.0.0.1:8004/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "nemotron3-omni",
    "messages": [{"role": "user", "content": "Reply with exactly NEMOTRON_OMNI_OK"}],
    "max_tokens": 80,
    "temperature": 0
  }'
```

Do not continue until the first response lists `nemotron3-omni` and the second gives a successful answer.

## Step 7 — Add the route to LiteLLM

Back up the current file:

```bash
cp -a "$HOME/ods/config/litellm/local.yaml" \
  "$HOME/ods/config/litellm/local.yaml.before-nemotron-omni.$(date +%Y%m%d-%H%M%S)"

nano "$HOME/ods/config/litellm/local.yaml"
```

Under the existing `model_list:` heading, add:

```yaml
  - model_name: nemotron3-omni
    litellm_params:
      model: openai/nemotron3-omni
      api_base: http://nemotron3-omni:8000/v1
      api_key: not-needed
```

Do not create a second `model_list:`. Save the file, then run:

```bash
docker restart ods-litellm
docker logs --tail 100 ods-litellm
```

Test through LiteLLM using the same authenticated command pattern from the Qwen guide, replacing its model name with `nemotron3-omni`.

## Step 8 — Test in Hermes

Only after LiteLLM succeeds:

```bash
hermes config set model.default nemotron3-omni
hermes config set model.context_length 65536
hermes config check
systemctl --user restart hermes-serve.service
hermes gateway stop
hermes gateway start
```

In Hermes Desktop, select `nemotron3-omni` and perform one text test. Then add one small image through the normal attachment button. Do not begin with a long video or a large PDF.

## Step 9 — Stop it and return to Qwen

```bash
cd "$HOME/ai/services/nemotron3-omni"
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

Stopping the container does not delete the checkpoint, image, cache, or media directory.

## Troubleshooting

Show the last logs:

```bash
docker logs --tail 300 vllm-nemotron3-omni
```

If memory allocation fails, reduce `--max-model-len` from `65536` to `32768` before changing anything else. If audio-related Python modules are missing, do not install packages on the Spark host; rebuild the derived Docker image and capture the exact build or runtime error.

If local media is rejected, confirm that the file is under `~/ai/media`. Only that directory is mounted into the container.

## Primary sources

- [NVIDIA Nemotron 3 Nano Spark instructions](https://build.nvidia.com/spark/nemotron/instructions-nano)
- [NVIDIA Nemotron 3 Nano Omni model card](https://huggingface.co/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4)
- [vLLM multimodal inputs](https://docs.vllm.ai/en/latest/features/multimodal_inputs/)

Related: [[DGX Spark Additional Model Tutorials Index]] | [[DGX Spark Nemotron 3.5 Lightning Tutorial]] | [[DGX Spark LM Studio And LM Link Tutorial]]
