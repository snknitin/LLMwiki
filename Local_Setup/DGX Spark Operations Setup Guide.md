---
title: DGX Spark Operations Setup Guide
created: 2026-08-07
updated: 2026-08-07
status: active-runbook
tags:
  - dgx-spark
  - operations
  - model-serving
  - docker
---

# DGX Spark Operations Setup Guide

> [!important] Scope
> This is the environment, storage, and service-layout foundation for the executable setup guide. It was checked against the live [NVIDIA DGX Spark catalog](https://build.nvidia.com/spark) and the official [`NVIDIA/dgx-spark-playbooks`](https://github.com/NVIDIA/dgx-spark-playbooks) repository on 2026-08-07. NVIDIA's examples are playbook-local recipes, not a single prescribed host layout; the proposed layout below is a synthesis for this Spark and its existing ODS installation.

Related: [[Local Setup Index]] | [[DGX Spark ODS Playbook and Model Roadmap]] | [[Spark Hermes Setup Runbook]]

## How to follow this guide

This guide assumes no prior Linux administration experience.

1. Open NVIDIA Sync on the Windows computer, select **FirstSpark**, and click **Terminal**.
2. Confirm the terminal prompt contains something similar to `snknitin@spark-07a8`. Run all commands in this guide in that Spark terminal, **not** in Windows PowerShell or Command Prompt.
3. Copy only the text inside each `bash` code block. Do not copy the opening `````bash`` or closing ````` markers.
4. Paste with `Ctrl+Shift+V` in most Linux terminals, or right-click and choose **Paste**. Press `Enter` if the command does not start automatically.
5. Commands beginning with `sudo` may ask for the Spark login password. Type it and press `Enter`; Linux intentionally displays no dots or characters while a password is typed.
6. Run one numbered step at a time. Read the verification immediately below it before continuing.
7. If a command prints `permission denied`, `command not found`, `failed`, `error`, or unexpected red text, stop at that step and ask for help. Do not continue hoping a later command will repair it.

### Using the `nano` editor

Some steps ask you to create a file with `nano`:

1. Run the provided `nano <filename>` command.
2. Paste the requested file contents.
3. Press `Ctrl+O` (the letter O) to save.
4. Press `Enter` to confirm the filename.
5. Press `Ctrl+X` to exit.

In command examples, `$HOME` automatically means `/home/snknitin`. Text such as `<replace_me>` is a placeholder; replace it with the requested value and do not type the angle brackets. Lines beginning with `#` are comments and are safe to include.

## Do this now: one-time foundation

Run these sections in order on the Spark as `snknitin`. They do not install another copy of ODS, vLLM, SGLang, NIM, or LM Studio. They organize the host, preserve the runtime-native model stores, and prepare the first model deployment.

### 1. Capture the current state

This is read-only. If a later step behaves unexpectedly, this snapshot shows what existed beforehand.

The `{ ... }` braces are Bash syntax that group several commands so their combined output can be sent through `tee`. Do **not** type the braces separately. To make this easiest and repeatable, create a script file and run it.

**Action A — create the audit script:**

```bash
nano "$HOME/capture-dgx-state.sh"
```

Paste everything in the next block into `nano`. Save with `Ctrl+O`, press `Enter`, and exit with `Ctrl+X`.

```bash
#!/usr/bin/env bash

mkdir -p "$HOME/runs/host-audits"
AUDIT="$HOME/runs/host-audits/$(date +%F-%H%M)-before-models.txt"

{
  echo '== host =='
  hostnamectl
  echo '== storage =='
  df -hT "$HOME" /srv 2>&1
  echo '== memory/GPU =='
  free -h
  nvidia-smi
  echo '== ODS =='
  ods status 2>&1
  ods list 2>&1
  echo '== containers =='
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'
  echo '== images =='
  docker images --digests
  echo '== volumes =='
  docker volume ls
  echo '== Docker disk =='
  docker system df
  echo '== listening TCP ports =='
  ss -ltn
} | tee "$AUDIT"

echo "Saved: $AUDIT"
```

**Action B — make the script executable and run it:**

```bash
chmod 700 "$HOME/capture-dgx-state.sh"
bash "$HOME/capture-dgx-state.sh"
```

Wait until the normal terminal prompt returns. The script may produce several screens of output.

**Success looks like:** the final line starts with `Saved:` and names a file under `/home/snknitin/runs/host-audits/`. Confirm the file exists:

```bash
ls -lt "$HOME/runs/host-audits" | head
```

If `ods status` reports an error but the audit reaches the final `Saved:` line, keep the audit and note the ODS error for later; do not reinstall ODS.

Do **not** run `docker system prune`. Installed images are reusable, and pruning makes the inventory harder to understand.

### 2. Clean `.bashrc` without losing the original

The token values shown in the planning conversation were intentionally redacted; the real `.bashrc` contains live credentials. This is deliberately a **two-stage process**. The script first creates a protected backup, migrates the credentials without printing them, and builds a separate candidate file. It does **not** change the live `.bashrc`. You verify the candidate and apply it with a separate command only when every check passes.

**Action A — create the migration script:** Open a new script file:

```bash
nano "$HOME/migrate-dgx-bashrc.sh"
```

Paste everything in the next block into `nano`. Save with `Ctrl+O`, press `Enter`, and exit with `Ctrl+X`.

```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/.config/dgx-spark"
SECRETS_FILE="$CONFIG_DIR/secrets.env"
BACKUP_FILE="$CONFIG_DIR/bashrc.backup.$(date +%F-%H%M%S)"
CANDIDATE_FILE="$CONFIG_DIR/bashrc.candidate"

mkdir -p "$CONFIG_DIR"
chmod 700 "$CONFIG_DIR"
umask 077
cp "$HOME/.bashrc" "$BACKUP_FILE"
chmod 600 "$BACKUP_FILE"
cp "$HOME/.bashrc" "$CANDIDATE_FILE"
chmod 600 "$CANDIDATE_FILE"

if [[ -e "$SECRETS_FILE" ]]; then
  echo "Existing secrets file preserved: $SECRETS_FILE"
else
  grep -E '^export[[:space:]]+(HF_TOKEN|NGC_API_KEY)=' "$HOME/.bashrc" \
    | sed -E 's/^export[[:space:]]+//' \
    > "$SECRETS_FILE"
fi
chmod 600 "$SECRETS_FILE"

for name in HF_TOKEN NGC_API_KEY; do
  if ! grep -Eq "^${name}=.+$" "$SECRETS_FILE"; then
    echo "Migration stopped: $name was not captured in $SECRETS_FILE" >&2
    echo "The original .bashrc is unchanged. Protected backup: $BACKUP_FILE" >&2
    exit 1
  fi
done

sed -i \
  -e '/^export[[:space:]]\+NGC_API_KEY=/d' \
  -e '/^export[[:space:]]\+HF_TOKEN=/d' \
  -e '/^export[[:space:]]\+LATEST_VLLM_VERSION=/d' \
  -e '/^export[[:space:]]\+LOCAL_NIM_CACHE=/d' \
  -e '/^export[[:space:]]\+LOCAL_NIM_WORKSPACE=/d' \
  -e '/^export[[:space:]]\+HF_HOME=/d' \
  -e '/^export[[:space:]]\+PATH="\$HOME\/.local\/bin:\$PATH"$/d' \
  -e '/^export[[:space:]]\+PATH="\$PATH:\/home\/snknitin\/\.lmstudio\/bin"$/d' \
  "$CANDIDATE_FILE"

if ! grep -q '^# >>> DGX SPARK >>>$' "$CANDIDATE_FILE"; then
  cat >> "$CANDIDATE_FILE" <<'EOF'

# >>> DGX SPARK >>>
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
case ":$PATH:" in *":$HOME/.lmstudio/bin:"*) ;; *) PATH="$HOME/.lmstudio/bin:$PATH" ;; esac
export PATH
[ -r "$HOME/.config/dgx-spark/env" ] && . "$HOME/.config/dgx-spark/env"
[ -r "$HOME/.config/dgx-spark/functions.sh" ] && . "$HOME/.config/dgx-spark/functions.sh"
# <<< DGX SPARK <<<
EOF
fi

if grep -Eq '^export[[:space:]]+(HF_TOKEN|NGC_API_KEY)=' "$CANDIDATE_FILE"; then
  echo "Candidate validation failed: a credential export remains." >&2
  echo "The live .bashrc is unchanged." >&2
  exit 1
fi

bash -n "$CANDIDATE_FILE"

echo "Credentials migrated without displaying them."
echo "Protected backup: $BACKUP_FILE"
echo "Validated candidate: $CANDIDATE_FILE"
echo "The live $HOME/.bashrc has NOT been changed."
```

**Action B — make the script executable and run it:**

```bash
chmod 700 "$HOME/migrate-dgx-bashrc.sh"
bash "$HOME/migrate-dgx-bashrc.sh"
```

If the script reports that either credential was not captured or that validation failed, stop. The live `.bashrc` is still unchanged. Do not continue until the export uses the expected `export HF_TOKEN=...` / `export NGC_API_KEY=...` form or you have manually placed both values in the protected secrets file.

**Success looks like:** the final output names the protected backup and validated candidate, and explicitly says the live `.bashrc` has not changed.

**Action C — verify without exposing secrets:** These commands show permissions, variable names, the new block, and Bash syntax. They do not print credential values.

```bash
stat -c '%a %n' "$HOME/.config/dgx-spark/secrets.env"
cut -d= -f1 "$HOME/.config/dgx-spark/secrets.env"
grep -n '^# >>> DGX SPARK >>>\|^# <<< DGX SPARK <<<' "$HOME/.config/dgx-spark/bashrc.candidate"
bash -n "$HOME/.config/dgx-spark/bashrc.candidate" && echo 'Candidate syntax is valid'
```

Expected output contains permission `600`, the names `HF_TOKEN` and `NGC_API_KEY`, both DGX Spark marker lines, and `Candidate syntax is valid`. Do not run `cat` on the secrets file while sharing the screen or copying terminal output.

**Action D — apply the tested candidate:** Only do this after Action C matches the expected output.

```bash
install -m 600 "$HOME/.config/dgx-spark/bashrc.candidate" "$HOME/.bashrc"
bash -n "$HOME/.bashrc" && echo 'Live .bashrc syntax is valid'
source "$HOME/.bashrc"
```

The current terminal should remain open and print `Live .bashrc syntax is valid`. Confirm the two CLI paths still work:

```bash
command -v hf
command -v lms
```

`command -v hf` should print a path, normally under `/home/snknitin/.local/bin`. `command -v lms` should print a path under `/home/snknitin/.lmstudio/bin`.

**Emergency restore:** Use this only if applying the candidate causes a problem. It restores the newest protected backup and reloads it:

```bash
BACKUP_FILE="$(ls -1t "$HOME/.config/dgx-spark"/bashrc.backup.* | head -n 1)"
install -m 600 "$BACKUP_FILE" "$HOME/.bashrc"
bash -n "$HOME/.bashrc" && source "$HOME/.bashrc"
echo "Restored: $BACKUP_FILE"
```

The backup contains the original credential lines, so keep its permission at `600`. After the entire setup is confirmed and the credentials work from `secrets.env`, the backup can be retained securely or deleted deliberately.

### 3. Create the navigable layout

Keep caches where their tools expect them, but expose convenient links under `~/ai/stores`. This avoids duplicate model downloads while making the important locations easy to browse.

**Action:** Copy and run the whole block below. It creates directories and symbolic links; it does not download models.

```bash
mkdir -p \
  "$HOME/.config/dgx-spark/services" \
  "$HOME/.config/dgx-spark/manifests" \
  "$HOME/.local/share/dgx-spark/projects" \
  "$HOME/.local/share/dgx-spark/datasets" \
  "$HOME/.local/share/dgx-spark/checkpoints" \
  "$HOME/.local/share/dgx-spark/outputs" \
  "$HOME/.local/share/dgx-spark/nim/workspace" \
  "$HOME/.cache/huggingface" \
  "$HOME/.cache/nim" \
  "$HOME/.lmstudio/models" \
  "$HOME/ai/stores" \
  "$HOME/runs" \
  "$HOME/src"

ln -sfn "$HOME/.cache/huggingface" "$HOME/ai/stores/huggingface"
ln -sfn "$HOME/.cache/nim" "$HOME/ai/stores/nim"
ln -sfn "$HOME/.lmstudio/models" "$HOME/ai/stores/lmstudio"
ln -sfn "$HOME/.local/share/dgx-spark/datasets" "$HOME/ai/datasets"
ln -sfn "$HOME/.local/share/dgx-spark/checkpoints" "$HOME/ai/checkpoints"
ln -sfn "$HOME/.local/share/dgx-spark/outputs" "$HOME/ai/outputs"
ln -sfn "$HOME/.local/share/dgx-spark/projects" "$HOME/ai/projects"

cat > "$HOME/.config/dgx-spark/env" <<'EOF'
export DGX_CONFIG_HOME="$HOME/.config/dgx-spark"
export DGX_DATA_HOME="$HOME/.local/share/dgx-spark"
export DGX_RUNS_HOME="$HOME/runs"
export HF_HOME="$HOME/.cache/huggingface"
export HF_HUB_CACHE="$HOME/.cache/huggingface/hub"
EOF

chmod 700 "$HOME/.config/dgx-spark"
chmod 644 "$HOME/.config/dgx-spark/env"
source "$HOME/.bashrc"
```

**Verify before continuing:**

```bash
echo "$HF_HOME"
ls -la "$HOME/ai"
df -hT "$HOME"
```

The first command should print `/home/snknitin/.cache/huggingface`. The second should show `datasets`, `checkpoints`, `outputs`, `projects`, and `stores`. In the disk report, check that the filesystem containing `/home/snknitin` has enough free space for large models—preferably hundreds of gigabytes.

### Understanding `~/src`, `/srv`, and the physical disk

These are unrelated directory names:

- `~/src` means `/home/snknitin/src`. It is an ordinary folder inside your home directory for source-code checkouts. The guide creates it, which is why you can see it.
- `/srv` means a folder named `srv` directly under the Linux filesystem root `/`. It is **not** inside your home directory and is not the same as `src`. View it with `ls -ld /srv` or browse to `/` first. It may be empty, and you do not need to create or use it for this setup.
- **NVMe** describes the Spark's physical internal SSD. It is hardware, not a folder. Many different paths—including `$HOME` and `/srv`—can be stored on the same NVMe filesystem.

Run this read-only storage check:

```bash
df -hT "$HOME" /srv 2>/dev/null
findmnt -T "$HOME"
findmnt -T /srv 2>/dev/null || true
```

Read the `Filesystem` and `Avail` columns from `df`:

- If `$HOME` has hundreds of gigabytes or more available, continue using `~/.cache/huggingface`, `~/.cache/nim`, and `~/.lmstudio/models`. This is the recommended simple setup.
- If `$HOME` and `/srv` show the same value in the `Filesystem` column, moving files to `/srv` would **not** gain space; both paths are on the same filesystem.
- Consider moving caches only if the storage check reveals a different mounted filesystem with substantially more free space. That mount might be `/srv`, `/mnt/...`, or another path. Do not assume `/srv` is a different or larger disk merely because it has a different name.

The older local roadmap provisionally suggested `/srv/models/hf`. This guide supersedes that suggestion because no models have been downloaded yet and the tools' normal cache locations are easier for a beginner to manage. Do not create both a `/srv/models/hf` collection and a `~/.cache/huggingface` collection. For now, use the home-directory cache unless the storage output proves that it is on a small filesystem.

### 4. Store secrets outside `.bashrc`

Step 2 already created this file by securely copying the real values from `.bashrc`. Verify its permissions and variable **names** without displaying either value. Do not put real tokens in this guide, Git, Obsidian, a Dockerfile, or a Compose file.

```bash
stat -c '%a %n' "$HOME/.config/dgx-spark/secrets.env"
cut -d= -f1 "$HOME/.config/dgx-spark/secrets.env"
```

Expected output includes permission `600` and these two names:

```text
HF_TOKEN
NGC_API_KEY
```

Use `nano "$HOME/.config/dgx-spark/secrets.env"` only if you need to correct or rotate a value. Do not paste either credential into a command line.

**Action:** After the verification output matches, run the authentication block below. It loads the secrets only into this terminal session, logs the two tools in, verifies Hugging Face access, and then removes the variables from the active shell.

Authenticate once without placing either literal token in shell history:

```bash
set -a
. "$HOME/.config/dgx-spark/secrets.env"
set +a

hf auth login --token "$HF_TOKEN"
printf '%s' "$NGC_API_KEY" | docker login nvcr.io --username '$oauthtoken' --password-stdin

hf auth whoami
unset HF_TOKEN NGC_API_KEY
```

**Success looks like:** Hugging Face identifies your account, and Docker reports `Login Succeeded`. If either login fails, stop here and correct the corresponding token; do not proceed to model downloads.

The secret file is **not** sourced by `.bashrc`. Load it only for a download or service that actually requires it.

### 5. Create the human-readable registries

These small TSV files answer three different questions: what is downloaded, what is supposed to run, and which process owns each port.

**Action:** Copy and run the first block once. It creates the initial registry files.

```bash
printf 'alias\tmodel_id\trevision\tformat\towner\tstatus\tadded_at\n' \
  > "$HOME/.config/dgx-spark/manifests/models.tsv"

printf 'service\tengine\timage\tmodel_alias\tport\trestart_policy\tstatus\n' \
  > "$HOME/.config/dgx-spark/manifests/services.tsv"

cat > "$HOME/.config/dgx-spark/ports.tsv" <<'EOF'
service	port	owner	policy
litellm	4000	ODS	stable gateway
vllm-spark-fast	8000	standalone	localhost until gateway is ready
ods-llama	8080	ODS	do not duplicate
hermes-serve	9119	standalone	persistent; bind to Spark Tailscale IP only
ods-hermes-proxy	9120	ODS	do not reuse
sglang-lab	30000	standalone	on-demand only
lmstudio	1234	llmster	on-demand or LM Link
ollama	11434	ODS/optional	on-demand unless selected
EOF

column -ts $'\t' "$HOME/.config/dgx-spark/ports.tsv"
```

**Success looks like:** a neatly aligned table whose first row is `service port owner policy`. These are planning records; they do not start or stop any service.

Before assigning a new port, compare this registry with reality:

```bash
ss -ltn
docker ps --format 'table {{.Names}}\t{{.Ports}}\t{{.Status}}'
```

### 6. Add three useful status commands

**Action:** Copy and run this whole block once. It creates three convenience functions and then immediately tests `dgx-status`.

```bash
cat > "$HOME/.config/dgx-spark/functions.sh" <<'EOF'
dgx-status() {
  echo '== ODS =='
  ods status
  echo '== containers =='
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'
  echo '== GPU =='
  nvidia-smi
}

dgx-models() {
  echo '== registry =='
  column -ts $'\t' "$HOME/.config/dgx-spark/manifests/models.tsv"
  echo '== Hugging Face cache =='
  hf cache ls 2>/dev/null || true
  echo '== LM Studio =='
  lms ls 2>/dev/null || true
}

dgx-space() {
  df -h "$HOME"
  du -sh "$HOME/.cache/huggingface" "$HOME/.cache/nim" "$HOME/.lmstudio/models" 2>/dev/null
  docker system df
}
EOF

chmod 644 "$HOME/.config/dgx-spark/functions.sh"
source "$HOME/.bashrc"
dgx-status
```

**Verify:** Open a second Spark terminal and run `type dgx-status`. Bash should say that `dgx-status is a function`. You can now type `dgx-status`, `dgx-models`, or `dgx-space` from future interactive terminals.

## Continue here: deploy the first model and Hermes

You said you have completed Steps 1 through 6. Start here with **Step 7**. Do not repeat the earlier steps.

The recommended first working stack is:

```text
Hermes terminal / Gateway / Desktop
                 |
                 v
      ODS LiteLLM on 127.0.0.1:4000
                 |
                 v
  vLLM "spark-fast" on the private ODS Docker network
                 |
                 v
 unsloth/Qwen3.6-35B-A3B-NVFP4
```

This gives Hermes one stable address even when you later change the model behind it. The raw vLLM port stays bound to the Spark's loopback interface, so it is not exposed to the LAN.

### Why this is now the first model

NVIDIA's June 2026 Hermes playbook uses `nvidia/Qwen3.6-35B-A3B-NVFP4`. That is still the clean first-party comparison model. However, an open NVIDIA playbook [issue reported on July 21, 2026](https://github.com/NVIDIA/dgx-spark-playbooks/issues/89) documents a same-Spark test in which the NVIDIA ModelOpt quant produced malformed tool calls with a 46-tool surface, while `unsloth/Qwen3.6-35B-A3B-NVFP4` passed the same test. This is a detailed community report, not yet an NVIDIA resolution.

For an agent whose main job is calling tools, the guide therefore uses the **Unsloth checkpoint provisionally**. It uses the [MiaAI DGX Spark runtime](https://github.com/MiaAI-Lab/Unsloth-Qwen3.6-35b-NVFP4-DGX-Spark), which adds a GB10 B12X path and reports high Spark throughput. We pin the downloaded model revision and the pulled container digest before starting it. We also remove that repository's broad workspace mount, wildcard media access, public bind, and host networking.

Do not interpret a tweet's tokens-per-second number as a quality ranking. Quantization, context length, concurrency, output length, speculative decoding, and runtime all change the number.

### Final model shelf for one 128 GB Spark

| Priority | Model/profile | Purpose | Operating decision |
|---|---|---|---|
| 1 | `unsloth/Qwen3.6-35B-A3B-NVFP4` | Hermes, coding, everyday agent work | **First 24x7 model** after the tests below pass |
| Control | `nvidia/Qwen3.6-35B-A3B-NVFP4` | Compare first-party NVIDIA ModelOpt with the agent default | On demand; do not use as the Hermes default until its large-tool test passes |
| 2 | `nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-NVFP4` | Image, audio, and video work | On demand; use NVIDIA's model-specific recipe |
| 3 | `nvidia/Gemma-4-26B-A4B-NVFP4` | Fast creative writing, translation, multilingual work | On demand; good lighter alternative |
| 4 | Laguna S 2.1 NVFP4 plus its supported DFlash profile | Coding/agent challenger | On demand; read Poolside's license and acceptable-use terms first |
| 5 | Qwen3.5 122B-A10B NVFP4 | Large-model quality experiment | On demand; memory-tight, so stop other GPU models first |
| 6 | DeepSeek V4 Flash SparkInfer derivative | Largest experimental MoE that can be made resident | Isolated experiment only; needs roughly 250–300 GB free disk and is not the untouched upstream model |
| Hold | Qwen3.6 27B DFlash, Ling 3.0 Flash, StepFun 3.7 GGUF, Gemma 31B | Benchmark experiments | Do not install yet; each adds a different custom image, quant, or memory edge case |
| Not selected | MiniMax H3 | Unverified one-Spark claim | Wait for a reproducible one-Spark model card or repository |

This is intentionally a small **working shelf**, not a request to download all of them. Download Model 1 now. Add another model only when Model 1 is recorded, tested, and easy to stop.

## Step 7 — Read-only preflight

These commands change nothing. Paste the whole block into the Spark terminal:

```bash
echo '== storage =='
df -hT "$HOME"

echo '== memory =='
free -h

echo '== GPU =='
nvidia-smi

echo '== ODS =='
ods status

echo '== running containers =='
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'

echo '== occupied listening ports =='
ss -ltn
```

**Stop here if:**

- `$HOME` has less than **120 GB available**. The first model is much smaller than that, but the margin prevents a partial cache, Docker layers, and logs from filling the disk.
- another service already owns port `8000`;
- `docker`, `ods`, or `nvidia-smi` reports an error.

If `ods status` says LiteLLM is disabled, enable it:

```bash
ods enable litellm
ods status
```

**Success looks like:** LiteLLM is enabled, and a container named `ods-litellm` appears in `docker ps`. Its host address should be `127.0.0.1:4000`.

Do not continue until `docker ps` shows the actual LiteLLM container. The next step discovers its Docker network instead of guessing the network name.

## Step 8 — Prepare and pin the first model

Use `tmux` for the download so an SSH interruption does not stop it:

```bash
tmux new -s qwen35-install
```

You are now inside a protected terminal session. If your connection drops, reconnect to the Spark and run:

```bash
tmux attach -t qwen35-install
```

### 8.1 Create the preparation script

Run:

```bash
mkdir -p "$HOME/ai/services/qwen35" "$HOME/src"
nano "$HOME/ai/services/qwen35/prepare.sh"
```

Nano opens an empty file. Copy **everything** in the next code box and paste it into Nano:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SERVICE_DIR="$HOME/ai/services/qwen35"
SOURCE_DIR="$HOME/src/Unsloth-Qwen3.6-35b-NVFP4-DGX-Spark"
MODEL_ID="unsloth/Qwen3.6-35B-A3B-NVFP4"
IMAGE_TAG="ghcr.io/miaai-lab/mia-vllm-gb10-linear-b12x:latest"
HF_CACHE="$HOME/.cache/huggingface"
VLLM_CACHE="$HOME/.cache/vllm"

for tool in docker git hf; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: $tool is not installed or is not on PATH."
    exit 1
  }
done

docker inspect ods-litellm >/dev/null 2>&1 || {
  echo "ERROR: ods-litellm was not found. Run: ods enable litellm"
  exit 1
}

ODS_NETWORK="$(docker inspect -f '{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}' ods-litellm | head -n 1)"
test -n "$ODS_NETWORK" || {
  echo "ERROR: could not discover the ODS Docker network."
  exit 1
}

mkdir -p "$SERVICE_DIR" "$HF_CACHE" "$VLLM_CACHE"

if [[ ! -d "$SOURCE_DIR/.git" ]]; then
  git clone --filter=blob:none \
    https://github.com/MiaAI-Lab/Unsloth-Qwen3.6-35b-NVFP4-DGX-Spark.git \
    "$SOURCE_DIR"
fi

RECIPE_COMMIT="$(git -C "$SOURCE_DIR" rev-parse HEAD)"

set -a
. "$HOME/.config/dgx-spark/secrets.env"
set +a

echo "Downloading $MODEL_ID. This can take a long time."
MODEL_PATH="$(HF_HOME="$HF_CACHE" hf download "$MODEL_ID")"
MODEL_REVISION="$(basename "$MODEL_PATH")"
unset HF_TOKEN NGC_API_KEY

echo "Pulling the community GB10 runtime image."
docker pull "$IMAGE_TAG"
QWEN_IMAGE="$(docker image inspect --format '{{index .RepoDigests 0}}' "$IMAGE_TAG")"

if [[ "$QWEN_IMAGE" != *@sha256:* ]]; then
  echo "ERROR: Docker did not return a digest-pinned image reference."
  exit 1
fi

cat > "$SERVICE_DIR/.env" <<EOF
MODEL_ID=$MODEL_ID
MODEL_REVISION=$MODEL_REVISION
QWEN_IMAGE=$QWEN_IMAGE
RECIPE_COMMIT=$RECIPE_COMMIT
ODS_NETWORK=$ODS_NETWORK
HF_HOME=$HF_CACHE
VLLM_CACHE_HOME=$VLLM_CACHE
RESTART_POLICY=no
EOF

chmod 600 "$SERVICE_DIR/.env"

if ! grep -q '^spark-fast[[:space:]]' "$HOME/.config/dgx-spark/manifests/models.tsv"; then
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    spark-fast "$MODEL_ID" "$MODEL_REVISION" compressed-tensors \
    huggingface downloaded "$(date -Iseconds)" \
    >> "$HOME/.config/dgx-spark/manifests/models.tsv"
fi

echo
echo "Preparation complete."
echo "Model revision: $MODEL_REVISION"
echo "Image digest:   $QWEN_IMAGE"
echo "ODS network:    $ODS_NETWORK"
echo "Recipe commit:  $RECIPE_COMMIT"
```

Save the file:

1. Press **Ctrl+O**. Nano shows the filename at the bottom.
2. Press **Enter** to confirm it.
3. Press **Ctrl+X** to exit Nano.

Make it executable and run it:

```bash
chmod 700 "$HOME/ai/services/qwen35/prepare.sh"
"$HOME/ai/services/qwen35/prepare.sh"
```

During the model download, changing progress percentages are normal. To detach from tmux without stopping it, press **Ctrl+B**, release both keys, then press **D**.

**Success looks like:** the final four lines show a 40-character model revision, an image containing `@sha256:`, an ODS network name, and a 40-character recipe commit.

Display the saved **non-secret** settings:

```bash
sed -n '1,20p' "$HOME/ai/services/qwen35/.env"
```

This file contains IDs and local paths, not your Hugging Face or NVIDIA tokens.

### 8.2 Create the Compose service

Open a second file:

```bash
nano "$HOME/ai/services/qwen35/compose.yaml"
```

Paste the entire block below:

```yaml
services:
  qwen35:
    image: ${QWEN_IMAGE}
    container_name: vllm-spark-fast
    restart: "${RESTART_POLICY:-no}"
    user: root
    gpus: all
    ipc: host
    cap_add:
      - IPC_LOCK
    ulimits:
      memlock:
        soft: -1
        hard: -1
    ports:
      - "127.0.0.1:8000:8000"
    networks:
      ods_model:
        aliases:
          - spark-fast
    environment:
      VLLM_TARGET_DEVICE: cuda
      CUTE_DSL_ARCH: sm_121a
      HF_HOME: /root/.cache/huggingface
      HF_HUB_OFFLINE: "1"
      VLLM_CACHE_ROOT: /root/.cache/vllm
    volumes:
      - "${HF_HOME}:/root/.cache/huggingface"
      - "${VLLM_CACHE_HOME}:/root/.cache/vllm"
    entrypoint:
      - /usr/local/bin/vllm
    command:
      - serve
      - ${MODEL_ID}
      - --revision
      - ${MODEL_REVISION}
      - --served-model-name
      - spark-fast
      - --host
      - "0.0.0.0"
      - --port
      - "8000"
      - --tensor-parallel-size
      - "1"
      - --trust-remote-code
      - --moe-backend
      - auto
      - --linear-backend
      - flashinfer_b12x
      - --attention-backend
      - flashinfer
      - --gpu-memory-utilization
      - "0.72"
      - --kv-cache-memory-bytes
      - "18G"
      - --max-model-len
      - "262144"
      - --max-num-seqs
      - "5"
      - --max-num-batched-tokens
      - "8192"
      - --enable-chunked-prefill
      - --async-scheduling
      - --kv-cache-dtype
      - fp8
      - --speculative-config
      - '{"method":"mtp","num_speculative_tokens":2,"moe_backend":"triton"}'
      - --reasoning-parser
      - qwen3
      - --default-chat-template-kwargs
      - '{"enable_thinking":true,"preserve_thinking":true}'
      - --tool-call-parser
      - qwen3_coder
      - --enable-auto-tool-choice
      - --override-generation-config
      - '{"temperature":0.6,"top_p":0.95,"top_k":20,"min_p":0.0,"presence_penalty":0.0,"repetition_penalty":1.0}'
    healthcheck:
      test:
        - CMD
        - python3
        - -c
        - "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/v1/models', timeout=5)"
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 10m
    stop_grace_period: 2m

networks:
  ods_model:
    external: true
    name: ${ODS_NETWORK}
```

Save with **Ctrl+O**, **Enter**, and **Ctrl+X**.

Validate the file without starting anything:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env config --quiet
docker compose --env-file .env config | sed -n '1,80p'
```

**Success looks like:** the first command prints no error. In the displayed configuration, `image:` contains `@sha256:`, port 8000 is bound to `127.0.0.1`, and the external network has a real ODS network name.

### Why this profile uses an explicit 18 GiB KV pool

The original 0.72 auto-profiled profile reserved 58.52 GiB of KV cache and exposed 4,838,587 KV tokens—far beyond this single-user workload. The verified replacement keeps the image-specific 0.72 preflight flag but pins `--kv-cache-memory-bytes 18G`, raises the request ceiling to 262,144, allows five scheduled sequences, and uses an 8,192-token chunked-prefill budget.

On 2026-08-15, the live vLLM 0.26.1.dev image allocated 1,588,632 KV tokens and reported **6.06 complete 262,144-token contexts**. A real 260,016-token prompt completed without preemption or OOM. The patched B12X/FlashInfer path, FP8 KV, asynchronous scheduling, CUDA graphs, tool parser, and two-token MTP remain enabled. Keep `--gpu-memory-utilization 0.72` alongside the explicit cache: this custom image still applies the utilization value to its startup free-memory preflight even though the explicit byte value controls KV sizing.

## Step 9 — Start and test vLLM manually

Start it:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env up -d
docker compose --env-file .env logs -f
```

The first load may take several minutes. Warnings during CUDA graph capture are not automatically failures. Wait for a message that the server is listening, or for the health status to become healthy. Press **Ctrl+C** to stop watching the logs; this does **not** stop the container.

Check it:

```bash
docker inspect --format '{{.State.Status}} / {{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' vllm-spark-fast
curl -fsS http://127.0.0.1:8000/v1/models
```

Run a small chat test:

```bash
curl -fsS http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "spark-fast",
    "messages": [{"role": "user", "content": "Reply with exactly SPARK_FAST_OK"}],
    "max_tokens": 40,
    "temperature": 0
  }'
```

**Success looks like:** an HTTP JSON response containing `SPARK_FAST_OK`.

If the container exits or never becomes healthy, do not change random flags. Collect:

```bash
docker logs --tail 200 vllm-spark-fast
nvidia-smi
free -h
```

Then stop it cleanly:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
```

Send the three outputs with secrets removed before tuning anything.

If the chat test succeeds, leave it running and continue to Step 10. Keep `RESTART_POLICY=no` for now.

## Step 10 — Add the model to ODS LiteLLM

LiteLLM is the stable gateway. Hermes will use port 4000; LiteLLM will reach `spark-fast:8000` over the private ODS Docker network.

### 10.1 Back up the existing LiteLLM configuration

Run:

```bash
test -f "$HOME/ods/config/litellm/local.yaml" || {
  echo "STOP: $HOME/ods/config/litellm/local.yaml was not found."
  exit 1
}

cp -a "$HOME/ods/config/litellm/local.yaml" \
  "$HOME/ods/config/litellm/local.yaml.before-spark-fast.$(date +%Y%m%d-%H%M%S)"

sed -n '1,160p' "$HOME/ods/config/litellm/local.yaml"
```

The `cp -a` command makes a timestamped copy. It does not change the original.

### 10.2 Add one route

Open the original:

```bash
nano "$HOME/ods/config/litellm/local.yaml"
```

Find the line:

```yaml
model_list:
```

Under it, add the following item at the same indentation level as the existing `- model_name:` items:

```yaml
  - model_name: spark-fast
    litellm_params:
      model: openai/spark-fast
      api_base: http://spark-fast:8000/v1
      api_key: not-needed
```

Do **not** delete the existing default or wildcard route. Do not add a second `model_list:` heading. YAML spacing matters: use spaces, not Tab.

Save with **Ctrl+O**, **Enter**, and **Ctrl+X**. Restart only the LiteLLM container:

```bash
docker restart ods-litellm
docker logs --tail 100 ods-litellm
```

If the log contains a YAML parsing error, restore the newest backup:

```bash
cp -a "$(ls -1t $HOME/ods/config/litellm/local.yaml.before-spark-fast.* | head -n 1)" \
  "$HOME/ods/config/litellm/local.yaml"
docker restart ods-litellm
```

### 10.3 Test the protected LiteLLM route

Load the ODS key into this terminal without displaying it:

```bash
set -a
. "$HOME/ods/.env"
set +a

test -n "${LITELLM_KEY:-}" || {
  echo "STOP: LITELLM_KEY is missing from $HOME/ods/.env"
  exit 1
}

curl -fsS http://127.0.0.1:4000/v1/models \
  -H "Authorization: Bearer $LITELLM_KEY"

curl -fsS http://127.0.0.1:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "spark-fast",
    "messages": [{"role": "user", "content": "Reply with exactly LITELLM_OK"}],
    "max_tokens": 40,
    "temperature": 0
  }'
```

**Success looks like:** the model list contains `spark-fast`, and the chat response contains `LITELLM_OK`.

### 10.4 Run a large-tool smoke test

This does not reproduce every Hermes tool schema, but it catches the most important failure mode: the model narrating a tool call in text instead of returning a structured `tool_calls` field.

Create the test:

```bash
nano "$HOME/ai/services/qwen35/test-tool-calls.py"
```

Paste:

```python
#!/usr/bin/env python3
import json
import os
import sys
import urllib.request

key = os.environ.get("LITELLM_KEY")
if not key:
    raise SystemExit("LITELLM_KEY is not loaded")

tools = []
for number in range(50):
    tools.append({
        "type": "function",
        "function": {
            "name": f"tool_{number:02d}",
            "description": f"Return the integer {number}.",
            "parameters": {
                "type": "object",
                "properties": {"value": {"type": "integer"}},
                "required": ["value"],
                "additionalProperties": False,
            },
        },
    })

body = {
    "model": "spark-fast",
    "messages": [{
        "role": "user",
        "content": "Call tool_49 exactly once with value 49. Do not answer in prose.",
    }],
    "tools": tools,
    "tool_choice": "auto",
    "temperature": 0,
    "max_tokens": 256,
}

failures = 0
for attempt in range(1, 6):
    request = urllib.request.Request(
        "http://127.0.0.1:4000/v1/chat/completions",
        data=json.dumps(body).encode(),
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(request, timeout=600) as response:
        result = json.load(response)

    message = result["choices"][0]["message"]
    calls = message.get("tool_calls") or []
    ok = bool(calls) and calls[0]["function"]["name"] == "tool_49"
    print(f"attempt {attempt}: {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures += 1
        print("finish_reason:", result["choices"][0].get("finish_reason"))
        print("content:", repr(message.get("content"))[:500])

if failures:
    print(f"FAILED: {failures}/5 attempts had no valid tool_49 call")
    sys.exit(1)

print("PASSED: 5/5 structured tool calls")
```

Save with **Ctrl+O**, **Enter**, and **Ctrl+X**, then run:

```bash
chmod 700 "$HOME/ai/services/qwen35/test-tool-calls.py"
python3 "$HOME/ai/services/qwen35/test-tool-calls.py"
unset LITELLM_KEY
```

**Promotion requirement:** it must print `PASSED: 5/5 structured tool calls`. If it fails, keep `RESTART_POLICY=no` and inspect the printed `content` plus:

```bash
docker logs --tail 200 vllm-spark-fast
docker logs --tail 200 ods-litellm
```

## Step 11 — Install one current, host-native Hermes

There are two different Hermes deployments available:

- **standalone current Hermes** installed in your Linux account, using `~/.hermes`;
- **ODS Hermes**, a pinned container managed by ODS, with shared ODS state.

For your personal Spark, use the first one. It stays current through the Hermes updater, its local terminal tools run as your normal Linux user, and both the gateway and Desktop backend share the same memory, sessions, skills, and configuration.

First check ODS:

```bash
ods status
docker ps -a --format 'table {{.Names}}\t{{.Status}}' | grep -E 'hermes|NAMES' || true
```

If `ods status` says `hermes-proxy` is enabled, run:

```bash
ods disable hermes-proxy
```

If `ods status` says `hermes` is enabled, run:

```bash
ods disable hermes
```

Disabling these services does not delete their volumes. Do not run any ODS data-deletion command.

### 11.1 Install from the current official Nous installer

Download the installer to a temporary file first:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh \
  -o /tmp/hermes-agent-install.sh
less /tmp/hermes-agent-install.sh
```

`less` is a read-only viewer. Press **Q** to exit it. Then run:

```bash
bash /tmp/hermes-agent-install.sh
```

The wording can change slightly between Hermes releases. During setup choose:

1. **Blank Slate / Fresh setup**.
2. Do not migrate an old OpenClaw/other agent unless you deliberately want its state.
3. Select **Custom endpoint (self-hosted / vLLM / etc.)**.
4. Base URL: `http://127.0.0.1:4000/v1`
5. API key: paste the value of `LITELLM_KEY` from `~/ods/.env` when prompted. Do not paste it into this guide.
6. Model name: `spark-fast`
7. Context length: `131072`
8. API/transport mode: **OpenAI Chat Completions**.
9. Terminal backend: **local**.
10. Finish the wizard without configuring messaging yet; that is Step 12.

To retrieve that value locally, open a **second Spark terminal**, run `nano "$HOME/ods/.env"`, find the line beginning `LITELLM_KEY=`, and copy only the text after the equals sign. Press **Ctrl+X** without saving. This displays the key only on your own Spark; never send a screenshot of it.

Open a new Spark terminal after installation, or run:

```bash
hash -r
command -v hermes
hermes --version
```

### 11.2 Force the exact saved configuration

This block obtains the key from ODS and asks Hermes to store it in `~/.hermes/.env`. Your shell history records the text `$LITELLM_KEY`, not its expanded value.

```bash
set -a
. "$HOME/ods/.env"
set +a

hermes config set OPENAI_API_KEY "$LITELLM_KEY"
hermes config set model.provider custom
hermes config set model.base_url http://127.0.0.1:4000/v1
hermes config set model.default spark-fast
hermes config set model.context_length 131072
hermes config set terminal.backend local
chmod 600 "$HOME/.hermes/.env"
unset LITELLM_KEY

hermes config check
hermes config get model
```

Do **not** print `~/.hermes/.env`; it now contains a credential.

Test a fresh non-interactive Hermes turn:

```bash
hermes -z 'Reply with exactly HERMES_OK'
```

If your installed version says `-z` is unknown, use:

```bash
hermes chat -q 'Reply with exactly HERMES_OK'
```

**Success looks like:** Hermes returns `HERMES_OK` without a provider, authentication, context-length, or connection error.

## Step 12 — Run the Hermes gateway 24x7

The **gateway** handles Telegram/Discord/Slack and Hermes scheduled jobs. It is not the same process as `hermes serve`.

If you want Telegram, first verify that the Spark can reach Telegram:

```bash
curl -sS --connect-timeout 10 -o /dev/null \
  -w "HTTP %{http_code}\n" https://api.telegram.org/
```

Any completed HTTP response such as 200, 302, or 404 proves network reachability. A timeout or DNS error must be fixed before Telegram will work.

Run the setup wizard:

```bash
hermes gateway setup
```

For Telegram:

1. In Telegram, talk to **@BotFather** and create a bot.
2. Paste the bot token only into the Hermes prompt.
3. At **Allowed user IDs**, enter your own **numeric Telegram user ID**. Do not leave this blank. A bot name such as `@yourname` is not a numeric ID.
4. Test the bot when the wizard asks.

Install the gateway as a **user service**, enable lingering once, and start it:

```bash
hermes gateway install
sudo loginctl enable-linger "$USER"
hermes gateway start
hermes gateway status
```

Why `enable-linger` matters: without it, a user service can stop when the user logs out. With it, systemd starts your user services at boot and keeps them alive without an SSH login.

View gateway logs:

```bash
journalctl --user -u hermes-gateway -n 100 --no-pager
```

Do not also install `sudo hermes gateway install --system`. Running both the user and system gateway creates ambiguous status and can make two processes poll the same Telegram bot.

## Step 13 — Run one persistent Hermes for every device

> [!important] Your current resume point
> You have already completed Steps 1–12. Do not repeat them. Your earlier SSH test happened at the old version of Step 13; begin here at **13.1** to create the corrected persistent multi-device backend. After completing 13.1–13.6, continue with Steps 14 and 15. The separate model guide starts only after Step 15 succeeds.

This is the architecture that matches your requirements:

```text
Windows desktop Hermes ─┐
Windows laptop Hermes  ─┼─ Tailscale ─> Spark hermes serve (24x7)
                        │                    │
Telegram ───────────────┴────────────> Spark hermes gateway (24x7)
                                             │
                                      Spark ~/.hermes
                               config, keys, MCP, skills,
                               memory, sessions, and crons
```

`hermes serve` is the persistent backend used by the Desktop and laptop apps. `hermes gateway` is the separate persistent messaging process used by Telegram. Both run as `snknitin` on the Spark and use the same default profile under `/home/snknitin/.hermes`.

When both computers use **Remote Gateway** and connect to this same backend, agent-side provider settings, API credentials, model defaults, MCP configuration, runtime plugins, skills, memories, sessions, and scheduled jobs live on the Spark instead of being split between the computers. Commands and file tools also execute on the Spark. Add these items only after the app shows that it is connected to the Spark Remote Gateway; anything added while an app is in **Local Hermes** mode belongs to that computer's separate local profile. Connection credentials, window layout, keyboard shortcuts, themes, and other Desktop-shell preferences remain local to each computer. A plugin specifically described as a **Desktop-shell plugin** may also need to be installed in each Desktop app because it changes the local UI rather than the remote agent. Stay on the single `default` Hermes profile for now; introduce multiple profiles only after this shared setup is working.

### 13.1 Verify the existing Tailscale setup and identify the real Spark node

> [!important] Your current state
> Tailscale is already installed and signed in on the desktop, laptop, and Spark. NVIDIA Sync also has two Tailscale-managed connection entries, so you see five total entries. Do **not** reinstall or re-enroll Tailscale.

NVIDIA Sync's Tailscale integration can appear as its own tailnet node or managed connection. Hermes needs the address of the actual Spark operating system, not a guessed NVIDIA Sync entry.

Open the **Spark terminal from NVIDIA Sync** and run this entire block:

```bash
echo '=== This Spark ==='
hostname
tailscale ip -4

echo '=== Tailnet devices ==='
tailscale status
```

1. Under **This Spark**, record the hostname and the address beginning with `100.`.
2. Call that address `SPARK_TAILSCALE_IP` in the remaining instructions.
3. In the `tailscale status` list, find the row with that same `100.` address. That row is the actual Spark node.
4. Ignore the extra NVIDIA Sync Tailscale entries when entering the Hermes Remote URL.
5. Do not add the address to `.bashrc`; Tailscale normally keeps a stable node address.

On the **Windows desktop**, open PowerShell and verify that the native Tailscale client can reach that exact address:

```powershell
tailscale ping SPARK_TAILSCALE_IP
```

Replace `SPARK_TAILSCALE_IP` with the `100.` address. Repeat the same command in **PowerShell on the laptop**.

**Success looks like:** both computers receive a successful Tailscale ping from the actual Spark node. Then continue directly to 13.2.
### 13.2 Add the Remote Gateway login to the existing Hermes secrets file

These commands run in the **Spark terminal**. They do not change `.bashrc`.

Back up the current Hermes secrets file before opening it:

```bash
mkdir -p "$HOME/.hermes"
chmod 700 "$HOME/.hermes"
cp -a "$HOME/.hermes/.env" \
  "$HOME/.hermes/.env.before-remote-$(date +%Y%m%d-%H%M%S)"
chmod 600 "$HOME/.hermes/.env"
```

If `cp` says `.env` does not exist, create it and continue:

```bash
touch "$HOME/.hermes/.env"
chmod 600 "$HOME/.hermes/.env"
```

Generate two random values in the **Spark terminal**:

```bash
openssl rand -hex 24
openssl rand -hex 32
```

1. Save the first result in your password manager as **Hermes Remote Gateway password**.
2. Save the second result temporarily as **Hermes signing secret**. You will not type this second value into the Desktop app.
3. Do not paste either value into this chat.

Open the existing file:

```bash
nano "$HOME/.hermes/.env"
```

Go to the bottom and add these three lines. Replace the two placeholders with the random values you just generated:

```dotenv
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=nitin
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=PASTE_THE_FIRST_RANDOM_VALUE_HERE
HERMES_DASHBOARD_BASIC_AUTH_SECRET=PASTE_THE_SECOND_RANDOM_VALUE_HERE
```

Do not delete the existing LiteLLM or provider settings in this file. Save with **Ctrl+O**, press **Enter**, and exit with **Ctrl+X**. Then run:

```bash
chmod 600 "$HOME/.hermes/.env"
```

The stable signing secret keeps Desktop sessions valid after `hermes serve` restarts. If the Desktop app still asks for a raw session token later, the username/password provider was not loaded; the verification in 13.4 will detect that.

### 13.3 Create the persistent `hermes serve` service

Run these two checks in the **Spark terminal**:

```bash
command -v hermes
tailscale ip -4
```

The expected Hermes path is `/home/snknitin/.local/bin/hermes`, and the Tailscale address should begin with `100.`.

Copy and run the entire block below in the **Spark terminal**. It automatically uses the actual Hermes path and current Tailscale IP, backs up an older service file if one exists, and writes the new service:

```bash
HERMES_BIN="$(command -v hermes)"
SPARK_TAILSCALE_IP="$(tailscale ip -4)"

test -x "$HERMES_BIN" || {
  echo 'ERROR: hermes executable was not found.'
  exit 1
}

test -n "$SPARK_TAILSCALE_IP" || {
  echo 'ERROR: the Spark has no Tailscale IPv4 address.'
  exit 1
}

mkdir -p "$HOME/.config/systemd/user"

if [ -f "$HOME/.config/systemd/user/hermes-serve.service" ]; then
  cp -a "$HOME/.config/systemd/user/hermes-serve.service" \
    "$HOME/.config/systemd/user/hermes-serve.service.before-remote-$(date +%Y%m%d-%H%M%S)"
fi

cat > "$HOME/.config/systemd/user/hermes-serve.service" <<EOF
[Unit]
Description=Hermes persistent Desktop backend
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=HOME=%h
Environment=HERMES_HOME=%h/.hermes
EnvironmentFile=-%h/.hermes/.env
WorkingDirectory=%h
ExecStart=$HERMES_BIN serve --host $SPARK_TAILSCALE_IP --port 9119
Restart=always
RestartSec=10
TimeoutStopSec=30

[Install]
WantedBy=default.target
EOF

unset HERMES_BIN SPARK_TAILSCALE_IP
```

This binds Hermes only to the Spark's Tailscale address—not `0.0.0.0` and not the public internet.
The service retries every ten seconds, so it also recovers automatically if the user service starts shortly before the Tailscale interface becomes ready during boot.

Enable login-independent user services and start the backend:

```bash
sudo loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now hermes-serve.service
systemctl --user status hermes-serve.service --no-pager
```

**Success looks like:** the last command contains `Active: active (running)`.

### 13.4 Verify that authentication—not a raw token prompt—is active

Run this in the **Spark terminal**:

```bash
SPARK_TAILSCALE_IP="$(tailscale ip -4)"
curl -sS "http://$SPARK_TAILSCALE_IP:9119/api/status" | python3 -m json.tool
unset SPARK_TAILSCALE_IP
```

Look for both of these results in the JSON:

```text
"auth_required": true
"basic"
```

The exact formatting may differ, but `auth_required` must be true and `auth_providers` must include `basic`.

If the service is not active or `basic` is missing, do not continue to the Desktop app. Run these in the **Spark terminal**:

```bash
systemctl --user status hermes-serve.service --no-pager
journalctl --user -u hermes-serve.service -n 150 --no-pager
```

Check that all three `HERMES_DASHBOARD_BASIC_AUTH_...` lines exist in `~/.hermes/.env`, have no spaces around `=`, and contain their real values. Do not print that file into chat because it contains secrets. Restart after correcting it:

```bash
systemctl --user restart hermes-serve.service
```

### 13.5 Connect Hermes Desktop to the persistent backend

Perform these actions first on the Windows desktop and then repeat them on the laptop:

1. Make sure the Tailscale app says **Connected**.
2. Open Hermes Desktop.
3. Open **Settings → Gateway**.
4. Under **Applies to**, choose **All profiles**. Use only the `default` profile for now.
5. Select **Remote Gateway**.
6. In **Remote URL**, enter `http://SPARK_TAILSCALE_IP:9119`, replacing `SPARK_TAILSCALE_IP` with the Spark address beginning with `100.`.
7. Wait while Hermes checks the authentication method.
8. When **Sign in** appears, click it.
9. Enter username `nitin` and the **Hermes Remote Gateway password** saved in your password manager.
10. Complete the sign-in window, return to Gateway settings, and click **Test remote** if that button is shown.
11. Click **Save and reconnect**.

Do not paste a raw session token. A correctly configured backend advertises the username/password provider and gives you a **Sign in** action instead.

Repeat those same eleven steps on the laptop. Both apps will then operate the same Spark-hosted Hermes state. Telegram continues using the separate `hermes gateway` process from Step 12.

### 13.6 What the earlier SSH authentication error means

**Connect via SSH** starts a temporary remote backend and requires non-interactive key authentication. NVIDIA Sync can manage its own SSH connection successfully while Hermes Desktop still cannot find or unlock that private key. That produces:

```text
SSH Authentication failed. Load your key into the ssh-agent (ssh-add)
or set an Identity file in ~/.ssh/config
```

You do not need to fix this error for the persistent Remote Gateway architecture above. If you want SSH mode later as a backup connection, perform these optional checks in **Windows PowerShell**:

```powershell
Get-Content "$env:USERPROFILE\.ssh\config"
ssh-add -l
```

If the correct key is not listed, open **PowerShell as Administrator** and run:

```powershell
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service ssh-agent
```

Close the Administrator window. In a normal **PowerShell** window, load the private key, substituting its actual path:

```powershell
ssh-add "$env:USERPROFILE\.ssh\id_ed25519"
ssh-add -l
```

Never give `ssh-add` the `.pub` file. If NVIDIA Sync created a differently named key, use the `IdentityFile` path shown in `C:\Users\Nitin Kishore Sai\.ssh\config`. You may also enter that same private-key path into Hermes Desktop's **Identity file** box.

## Step 14 — Understand ODS Hermes Auth Proxy without overlap

ODS's `hermes-proxy` is **not** a general authentication wrapper for the standalone Hermes installed in Step 11.

Its actual request path is:

```text
Browser -> ODS hermes-proxy on port 9120
        -> validate signed ods-session with ODS Dashboard
        -> ODS container named ods-hermes on its internal port 9119
```

The proxy checks that a browser has a valid ODS session. It does not give every ODS user a separate Hermes brain: ODS documents that authenticated users still share the container's histories, skills, and state.

Choose exactly one of these modes:

| Mode | Enable | Disable | Best use |
|---|---|---|---|
| **Recommended personal mode** | Host `hermes gateway` + persistent authenticated host `hermes serve` + ODS LiteLLM | ODS `hermes` and ODS `hermes-proxy` | One central Spark profile shared by Telegram, desktop, and laptop |
| ODS browser mode | ODS `hermes` + `hermes-proxy` | Host gateway and host `hermes serve` | Shared ODS browser entry point, accepting shared state and ODS's pinned Hermes version |

Your selected mode is the first row. Port 9119 belongs to the host `hermes-serve.service` and is reachable only through the Spark's Tailscale address. Port 9120 stays unused. LiteLLM on port 4000 is still part of ODS and is intentionally shared by the two host Hermes processes.

If you later deliberately switch to ODS browser mode:

```bash
hermes gateway stop
systemctl --user disable --now hermes-serve.service
ods enable hermes
ods enable hermes-proxy
```

To return to the recommended personal mode:

```bash
ods disable hermes-proxy
ods disable hermes
hermes gateway start
systemctl --user enable --now hermes-serve.service
```

Then reconnect **Remote Gateway** in each Hermes Desktop app. Neither switch deletes Hermes data.

## Step 15 — Promote the tested stack to 24x7

Do this only after all four strings/tests succeeded:

- `SPARK_FAST_OK`
- `LITELLM_OK`
- `PASSED: 5/5 structured tool calls`
- `HERMES_OK`

Change the model container's restart policy:

```bash
cd "$HOME/ai/services/qwen35"
sed -i 's/^RESTART_POLICY=.*/RESTART_POLICY=unless-stopped/' .env
docker compose --env-file .env up -d
```

Record the service once:

```bash
if ! grep -q '^vllm-spark-fast[[:space:]]' \
  "$HOME/.config/dgx-spark/manifests/services.tsv"; then
  . "$HOME/ai/services/qwen35/.env"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    vllm-spark-fast vllm "$QWEN_IMAGE" spark-fast 8000 \
    unless-stopped running \
    >> "$HOME/.config/dgx-spark/manifests/services.tsv"
fi
```

Run the final status check:

```bash
dgx-status
docker inspect --format '{{.State.Status}} / {{.State.Health.Status}} / restart={{.HostConfig.RestartPolicy.Name}}' \
  vllm-spark-fast
hermes gateway status
systemctl --user is-enabled hermes-serve.service
systemctl --user is-active hermes-serve.service
loginctl show-user "$USER" -p Linger
```

**Final success state:**

- `vllm-spark-fast` is running, healthy, and has restart `unless-stopped`;
- `ods-litellm` is running;
- the Hermes gateway user service is running;
- `hermes-serve.service` is enabled and active;
- `Linger=yes`;
- both Windows computers connect to the same Spark Tailscale URL with **Remote Gateway**;
- Telegram replies through the host gateway.

### Safe stop and rollback commands

Stop only the model, keeping its downloaded files:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
```

Start it again:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env up -d
```

Stop both 24x7 Hermes processes:

```bash
hermes gateway stop
systemctl --user stop hermes-serve.service
```

Start both 24x7 Hermes processes again:

```bash
hermes gateway start
systemctl --user start hermes-serve.service
```

These commands do not delete `~/.hermes`, model weights, Docker images, or ODS volumes.

## Continue with model installation and switching

After Step 15 succeeds, continue in [[DGX Spark Model Installation And Switching Guide]]. That companion starts at Step 16 and contains the beginner-focused model download, testing, switching, and rollback workflow.

Related: [[DGX Spark Model Installation And Switching Guide]] | [[DGX Spark Aug 2026 Model Deployment Research]] | [[Local Setup Index]]
