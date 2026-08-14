# DGX Spark Ollama And ODS Tutorial

This tutorial installs one **current, isolated Ollama server** beside ODS. It does not install a second Open WebUI and does not use ODS's old public Ollama extension, whose published Compose file is pinned to Ollama 0.5.7 with an 8 GB limit.

The selected design is:

| Item | Value |
|---|---|
| Runtime | Official current `ollama/ollama` ARM64 Docker image, pinned to its pulled digest |
| Container | `ollama-current` |
| Spark-only raw URL | `http://127.0.0.1:11435` |
| ODS Docker URL | `http://ollama-current:11434` |
| Model store | `~/.local/share/ollama` |
| Loaded models | At most one |

Port `11435` is deliberate: the existing ODS plan may already use host port `11434`. Inside the Docker network, Ollama still uses its normal internal port 11434.

> [!important] What “installed” means here
> The Ollama program lives inside a Docker container. Its downloaded models live outside that container in `~/.local/share/ollama`, so recreating or upgrading the container does not delete the models.

Run every command in this guide in the **Spark terminal opened from NVIDIA Sync**, except where the guide explicitly says **Hermes Desktop** or **Windows PowerShell**.

## Step 1 — Confirm the architecture and the port

This is read-only:

```bash
uname -m
docker version --format '{{.Server.Arch}}'
ss -ltn | grep ':11435 ' || true
docker inspect ods-litellm \
  --format '{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}'
```

Expected:

- the machine architecture is ARM64/aarch64;
- nothing is listening on port 11435;
- the last command prints the Docker network used by ODS.

If port 11435 is already occupied, stop here and identify that process instead of choosing ports at random.

## Step 2 — Create the preparation script

```bash
mkdir -p "$HOME/ai/tools"
nano "$HOME/ai/tools/prepare-ollama-current.sh"
```

Paste this entire script into Nano:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SERVICE_DIR="$HOME/ai/services/ollama"
MODEL_STORE="$HOME/.local/share/ollama"
IMAGE_TAG="ollama/ollama:latest"
HOST_PORT="11435"

docker inspect ods-litellm >/dev/null 2>&1 || {
  echo 'ERROR: ods-litellm was not found.'
  exit 1
}

ODS_NETWORK="$(docker inspect -f '{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}' ods-litellm | head -n 1)"
test -n "$ODS_NETWORK" || {
  echo 'ERROR: the ODS Docker network could not be discovered.'
  exit 1
}

if ss -ltn | awk '{print $4}' | grep -qE '(^|:)11435$'; then
  echo 'ERROR: host port 11435 is already in use.'
  exit 1
fi

mkdir -p "$SERVICE_DIR" "$MODEL_STORE"

docker pull "$IMAGE_TAG"
OLLAMA_IMAGE_PINNED="$(docker image inspect --format '{{index .RepoDigests 0}}' "$IMAGE_TAG")"

if [[ "$OLLAMA_IMAGE_PINNED" != *@sha256:* ]]; then
  echo 'ERROR: Docker did not return a pinned Ollama digest.'
  exit 1
fi

cat > "$SERVICE_DIR/.env" <<EOF
HOST_PORT=$HOST_PORT
ODS_NETWORK=$ODS_NETWORK
MODEL_STORE=$MODEL_STORE
OLLAMA_IMAGE_PINNED=$OLLAMA_IMAGE_PINNED
EOF

cat > "$SERVICE_DIR/compose.yaml" <<'YAML'
services:
  ollama:
    image: ${OLLAMA_IMAGE_PINNED}
    container_name: ollama-current
    restart: unless-stopped
    gpus: all
    ports:
      - "127.0.0.1:${HOST_PORT}:11434"
    environment:
      OLLAMA_HOST: 0.0.0.0:11434
      OLLAMA_KEEP_ALIVE: 5m
      OLLAMA_MAX_LOADED_MODELS: "1"
      OLLAMA_NUM_PARALLEL: "1"
    volumes:
      - ${MODEL_STORE}:/root/.ollama
    networks:
      default:
        aliases:
          - ollama-current

networks:
  default:
    external: true
    name: ${ODS_NETWORK}
YAML

chmod 600 "$SERVICE_DIR/.env"
docker compose --env-file "$SERVICE_DIR/.env" -f "$SERVICE_DIR/compose.yaml" config --quiet

echo
echo "Prepared Ollama image: $OLLAMA_IMAGE_PINNED"
echo "Model store:           $MODEL_STORE"
echo "Spark raw URL:         http://127.0.0.1:$HOST_PORT"
echo "ODS Docker URL:        http://ollama-current:11434"
echo 'The server has not been started.'
```

Save with **Ctrl+O**, **Enter**, and **Ctrl+X**, then run:

```bash
chmod 700 "$HOME/ai/tools/prepare-ollama-current.sh"
"$HOME/ai/tools/prepare-ollama-current.sh"
```

Success ends with the pinned digest, both URLs, and the message that the server has not started.

## Step 3 — Start the empty Ollama server

```bash
cd "$HOME/ai/services/ollama"
docker compose --env-file .env up -d
docker logs --tail 100 ollama-current
```

Test it:

```bash
curl -fsS http://127.0.0.1:11435/api/version
curl -fsS http://127.0.0.1:11435/api/tags
docker exec ollama-current ollama ps
```

The tags list will initially be empty. The `ps` output should have no loaded model. An empty Ollama server can remain running alongside Qwen; it consumes little GPU memory.

## Step 4 — Pull one small first model

Start with the small Gemma 4 E4B package, not four large models:

```bash
docker exec -it ollama-current ollama pull gemma4:e4b-it-qat
```

This downloads model files to disk. It does not need to load the model into unified memory. Verify:

```bash
docker exec ollama-current ollama list
du -sh "$HOME/.local/share/ollama"
```

## Step 5 — Stop Qwen before actually running the Ollama model

If `vllm-spark-fast` is running:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
free -h
nvidia-smi
```

Now run a one-shot test:

```bash
docker exec -it ollama-current \
  ollama run gemma4:e4b-it-qat \
  'Reply with exactly OLLAMA_GEMMA4_OK'
```

See what is loaded:

```bash
docker exec ollama-current ollama ps
```

Unload it immediately after the test:

```bash
docker exec ollama-current ollama stop gemma4:e4b-it-qat
```

The model remains downloaded on disk.

## Step 6 — Choose future Ollama downloads deliberately

Current relevant choices include:

| Exact Ollama tag | Approximate download | Recommendation |
|---|---:|---|
| `gemma4:e4b-it-qat` | 6.1 GB | First smoke test and quick utility model |
| `gemma4:26b-a4b-it-qat` | 16 GB | Convenience version of the Gemma MoE; duplicates the vLLM use case |
| `gemma4:31b-it-qat` | 19 GB | Convenience dense Gemma; duplicates the vLLM use case |
| `nemotron3:33b` | 28 GB | Text/image convenience; do not assume vLLM's full audio/video support |
| `nemotron-3.5-lightning` | model-dependent | NVIDIA documents this for Ollama 0.32.9 or newer |

Before every pull, ask whether you already downloaded a better NVFP4 version into `~/.cache/huggingface`. Ollama cannot directly reuse that checkpoint, so pulling its tag creates a second copy.

Pull only a tag you intend to test:

```bash
docker exec -it ollama-current ollama pull EXACT_TAG
```

Replace `EXACT_TAG` with one value from the table; do not type the word `EXACT_TAG` literally.

## Step 7 — Connect the existing ODS Open WebUI

Do not install another Open WebUI.

In the existing ODS Open WebUI:

1. Open the administrator/settings area.
2. Open **Connections**.
3. Add an **Ollama** connection.
4. Enter `http://ollama-current:11434`.
5. Save and refresh the model list.

If the UI uses the term **Base URL**, use the same address. This address works inside the shared ODS Docker network; `127.0.0.1:11435` would point back into the Open WebUI container and is therefore wrong there.

When you select an Ollama model in Open WebUI, Ollama may load it. Stop the active vLLM model first.

## Step 8 — Add one Ollama model to LiteLLM and Hermes

Back up and open LiteLLM's configuration:

```bash
cp -a "$HOME/ods/config/litellm/local.yaml" \
  "$HOME/ods/config/litellm/local.yaml.before-ollama.$(date +%Y%m%d-%H%M%S)"
nano "$HOME/ods/config/litellm/local.yaml"
```

Add this item beneath the existing `model_list:`:

```yaml
  - model_name: ollama-gemma4-e4b
    litellm_params:
      model: ollama_chat/gemma4:e4b-it-qat
      api_base: http://ollama-current:11434
      keep_alive: 5m
    model_info:
      supports_function_calling: true
```

Save, then run:

```bash
docker restart ods-litellm
docker logs --tail 100 ods-litellm
```

Test LiteLLM using model name `ollama-gemma4-e4b`. Once it succeeds, Hermes can select that friendly name like the vLLM routes.

> [!note] Selecting versus loading
> Ollama can load a downloaded model on the first request. The static vLLM routes cannot start their stopped containers. This is why Ollama feels more like an easy model shelf, although its first response after a switch is slower.

## Step 9 — Use it directly from a laptop or desktop safely

Prefer Open WebUI, Hermes, or LiteLLM because those already provide controlled access. If an application needs the raw Ollama API, create an SSH tunnel instead of exposing unauthenticated Ollama to the LAN.

In **Windows PowerShell** on the laptop or desktop:

```powershell
ssh -N -L 11435:127.0.0.1:11435 spark
```

Leave that PowerShell window open. The Windows application can then use:

```text
http://127.0.0.1:11435
```

Replace `spark` with the SSH alias you already use if its name differs.

## Daily commands

List downloaded models:

```bash
docker exec ollama-current ollama list
```

List loaded models:

```bash
docker exec ollama-current ollama ps
```

Unload one model without deleting it:

```bash
docker exec ollama-current ollama stop EXACT_TAG
```

Stop the server without deleting models:

```bash
cd "$HOME/ai/services/ollama"
docker compose --env-file .env down
```

Start it again:

```bash
cd "$HOME/ai/services/ollama"
docker compose --env-file .env up -d
```

## Where Ollama saved everything

The host directory is:

```text
/home/snknitin/.local/share/ollama
```

The model blobs are content-addressed and not arranged as friendly folders. Use `ollama list`, not File Explorer folder names, to track model identity. Do not rename blobs, symlink Hugging Face snapshots into this store, or recursively change ownership of your entire home directory.

## Primary sources

- [Ollama Docker instructions](https://docs.ollama.com/docker)
- [Ollama GB10 GPU support](https://docs.ollama.com/gpu)
- [Ollama model loading and storage FAQ](https://docs.ollama.com/faq)
- [LiteLLM Ollama provider](https://docs.litellm.ai/docs/providers/ollama)
- [Open WebUI Ollama connection](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-ollama/)
- [ODS public Ollama extension](https://github.com/Osmantic/ODS/tree/main/ods/extensions/library/services/ollama)

Related: [[DGX Spark Additional Model Tutorials Index]] | [[DGX Spark LM Studio And LM Link Tutorial]] | [[DGX Spark Multi-Model Runtime Research]]
