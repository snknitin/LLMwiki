# DGX Spark Muse Glimmer 30B Readiness Tutorial

Muse Glimmer 30B is locally runnable on one DGX Spark; it is not restricted to NVIDIA NIM. The current local vLLM path is still **advanced/pre-release**, however, because the maintained recipe uses the special image tag `vllm/vllm-openai:muse-glimmer` and describes that runtime support as forthcoming.

This guide gives you a safe go/no-go sequence. It will not substitute a random nightly image if the official Muse image is unavailable.

| Item | Value |
|---|---|
| Base checkpoint | `meta-models/Muse-Glimmer-30B` |
| Optional DFlash assistant | `meta-models/Muse-Glimmer-30B-assistant` |
| Base checkpoint download | about 55.49 GiB |
| Container | `vllm-muse-glimmer` |
| Raw Spark API | `http://127.0.0.1:8006/v1` |
| ODS network address | `http://muse-glimmer:8000/v1` |
| LiteLLM/Hermes name | `muse-glimmer` |

The model is public and Apache 2.0. It supports text and image input. The current vLLM recipe marks DGX Spark/GB10 as verified, but uses Muse-specific reasoning and tool parsers that normal stable vLLM images may not yet contain.

Unless a section says **Hermes Desktop**, run commands in the **Spark terminal opened from NVIDIA Sync**.

## Step 1 — Check whether the required image exists

This pull is the readiness gate:

```bash
docker pull vllm/vllm-openai:muse-glimmer
```

There are two possible outcomes:

- **Pull succeeds:** continue to Step 2.
- **Pull says the manifest or platform is unavailable:** stop this tutorial. Do not replace it with `latest`, a random nightly, or an x86-only image.

If the pull succeeds, record its immutable digest:

```bash
docker image inspect \
  --format '{{index .RepoDigests 0}}' \
  vllm/vllm-openai:muse-glimmer
```

The result must contain `@sha256:`. If it does not, stop and recheck the image before proceeding.

## Step 2 — Create the preparation script

```bash
mkdir -p "$HOME/ai/tools"
nano "$HOME/ai/tools/prepare-muse-glimmer.sh"
```

Copy this entire script into Nano:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

PROFILE="muse-glimmer"
MODEL_ID="meta-models/Muse-Glimmer-30B"
MODEL_ALIAS="muse-glimmer"
HOST_PORT="8006"
SERVICE_DIR="$HOME/ai/services/$PROFILE"
HF_CACHE="$HOME/.cache/huggingface"
VLLM_CACHE="$HOME/.cache/vllm/$PROFILE"
TRITON_CACHE="$HOME/.cache/triton/$PROFILE"
IMAGE_TAG="vllm/vllm-openai:muse-glimmer"

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
test -n "$ODS_NETWORK" || exit 1

docker pull "$IMAGE_TAG"
VLLM_IMAGE_PINNED="$(docker image inspect --format '{{index .RepoDigests 0}}' "$IMAGE_TAG")"

if [[ "$VLLM_IMAGE_PINNED" != *@sha256:* ]]; then
  echo 'ERROR: no immutable Muse image digest was returned.'
  exit 1
fi

mkdir -p "$SERVICE_DIR" "$HF_CACHE" "$VLLM_CACHE" "$TRITON_CACHE"

set -a
. "$HOME/.config/dgx-spark/secrets.env"
set +a

MODEL_PATH="$(HF_HOME="$HF_CACHE" hf download "$MODEL_ID")"
unset HF_TOKEN NGC_API_KEY

cat > "$SERVICE_DIR/.env" <<EOF
PROFILE=$PROFILE
MODEL_ID=$MODEL_ID
MODEL_PATH=$MODEL_PATH
MODEL_REVISION=$(basename "$MODEL_PATH")
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
  muse-glimmer:
    image: ${VLLM_IMAGE_PINNED}
    container_name: vllm-muse-glimmer
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
      - ${MODEL_PATH}:/model:ro
      - ${VLLM_CACHE_ROOT}:/root/.cache/vllm
      - ${TRITON_CACHE_ROOT}:/root/.triton
    entrypoint: ["vllm", "serve"]
    command:
      - /model
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
      - "0.80"
      - --max-model-len
      - "65536"
      - --max-num-seqs
      - "2"
      - --enable-prefix-caching
      - --generation-config
      - auto
      - --enable-auto-tool-choice
      - --tool-call-parser
      - muse_glimmer
      - --reasoning-parser
      - muse_glimmer
    networks:
      default:
        aliases:
          - muse-glimmer

networks:
  default:
    external: true
    name: ${ODS_NETWORK}
YAML

chmod 600 "$SERVICE_DIR/.env"
docker compose --env-file "$SERVICE_DIR/.env" -f "$SERVICE_DIR/compose.yaml" config --quiet

echo
echo "Prepared:  $PROFILE"
echo "Revision:  $(basename "$MODEL_PATH")"
echo "Image:     $VLLM_IMAGE_PINNED"
echo 'The model has not been started.'
```

Save with **Ctrl+O**, **Enter**, and **Ctrl+X**, then run:

```bash
chmod 700 "$HOME/ai/tools/prepare-muse-glimmer.sh"
tmux new -s muse-prepare
```

Inside tmux:

```bash
"$HOME/ai/tools/prepare-muse-glimmer.sh"
```

Detach with **Ctrl+B**, release, then **D**. Reattach with `tmux attach -t muse-prepare`.

## Step 3 — Stop every loaded large model

Do not start Muse merely because its download is complete.

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down || true

docker ps --format 'table {{.Names}}\t{{.Status}}' \
  | grep -E 'NAMES|vllm|sglang' || true
free -h
nvidia-smi
```

If you installed Ollama, also run `ollama ps`. If LM Studio is active, run `lms ps`. Unload any large model either command shows.

## Step 4 — Start the base model without DFlash

```bash
cd "$HOME/ai/services/muse-glimmer"
docker compose --env-file .env up -d
docker logs -f vllm-muse-glimmer
```

Starting without the assistant deliberately separates basic runtime compatibility from speculative-decoding problems.

Press **Ctrl+C** after the server reports that it is ready.

## Step 5 — Test identity, text, then one image

```bash
curl -fsS http://127.0.0.1:8006/v1/models

curl -fsS http://127.0.0.1:8006/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "muse-glimmer",
    "messages": [{"role": "user", "content": "Reply with exactly MUSE_GLIMMER_OK"}],
    "max_tokens": 80,
    "temperature": 0
  }'
```

If text succeeds, use a small ordinary image through a client that sends OpenAI-compatible image content. Do not test Hermes tool calls until the model can describe the image and complete ordinary chat.

## Step 6 — Add LiteLLM only after the base tests pass

Back up and open the configuration:

```bash
cp -a "$HOME/ods/config/litellm/local.yaml" \
  "$HOME/ods/config/litellm/local.yaml.before-muse.$(date +%Y%m%d-%H%M%S)"
nano "$HOME/ods/config/litellm/local.yaml"
```

Add under the existing `model_list:`:

```yaml
  - model_name: muse-glimmer
    litellm_params:
      model: openai/muse-glimmer
      api_base: http://muse-glimmer:8000/v1
      api_key: not-needed
```

Save and restart LiteLLM:

```bash
docker restart ods-litellm
docker logs --tail 100 ods-litellm
```

Test through LiteLLM before selecting Muse in Hermes. Muse uses its own `muse_glimmer` reasoning and tool-call protocol; do not change those parser flags to the Qwen or Nemotron parser.

Only after the LiteLLM test succeeds, set Hermes for this temporary test:

```bash
hermes config set model.default muse-glimmer
hermes config set model.context_length 65536
hermes config check
systemctl --user restart hermes-serve.service
hermes gateway stop
hermes gateway start
```

In Hermes Desktop, select `muse-glimmer` and repeat the same chat and tool prompts you used for Qwen.

## Step 7 — Optional DFlash assistant, only after a clean baseline

The official recipe names this assistant:

```text
meta-models/Muse-Glimmer-30B-assistant
```

Its published setting is:

```text
--speculative-config '{"method":"dflash","model":"meta-models/Muse-Glimmer-30B-assistant","num_speculative_tokens":15}'
```

Do not add it during the first run. First record base-model quality, startup time, tokens per second, and tool behavior. Then refresh this guide against the exact pinned Muse image and add DFlash as a separate benchmark change. That makes it possible to tell whether a failure comes from Muse itself or its assistant.

## Step 8 — Stop Muse and restore Qwen

```bash
cd "$HOME/ai/services/muse-glimmer"
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

Stopping does not delete the 55.49 GiB checkpoint.

## Do not do these things

- Do not silently replace the Meta checkpoint with `Inferact/Muse-Glimmer-30B-NVFP4-W4A4`; that is a third-party quantization with different provenance.
- Do not use a Qwen chat template or parser.
- Do not add the optional assistant before the base profile works.
- Do not expose raw port 8006 to the LAN.
- Do not label an unpinned `muse-glimmer` image as a reproducible 24/7 service.

## Primary sources

- [NVIDIA Build Muse Glimmer 30B](https://build.nvidia.com/meta/muse-glimmer-30b)
- [Meta Muse Glimmer 30B model card](https://huggingface.co/meta-models/Muse-Glimmer-30B)
- [Official vLLM Muse Glimmer recipe](https://github.com/vllm-project/recipes/blob/main/models/meta-models/Muse-Glimmer-30B.yaml)

Related: [[DGX Spark Additional Model Tutorials Index]] | [[DGX Spark Nemotron 3.5 Lightning Tutorial]] | [[DGX Spark LM Studio And LM Link Tutorial]]
