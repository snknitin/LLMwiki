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
hermes-serve	9119	standalone	Tailscale only
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
      - --max-model-len
      - "131072"
      - --max-num-seqs
      - "8"
      - --max-num-batched-tokens
      - "16384"
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

### Why this profile does not copy every maximum from the repository

The community script advertises 262,144 tokens, 24 sequences, 32,768 batched tokens, and 0.80 GPU-memory utilization. Those settings target a throughput demonstration. This guide begins at 131,072 tokens, 8 sequences, 16,384 batched tokens, and 0.72 utilization because one personal Hermes does not need 24 simultaneous conversations, while Linux, Docker, ODS, and KV cache all share the Spark's 128 GB unified memory.

The performance features that matter most remain enabled: the patched B12X linear backend, FlashInfer attention, FP8 KV cache, chunked prefill, asynchronous scheduling, and two-token MTP speculation. Reducing the declared maximum context does not lower the quality of ordinary prompts; it limits how large a single conversation can become and preserves operational margin. Establish the reliable baseline before changing one limit at a time.

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

## Step 13 — Run the Hermes Desktop backend 24x7

`hermes serve` is the JSON-RPC/WebSocket backend used by Hermes Desktop. The official Hermes documentation explicitly says it is a separate long-running process from the messaging gateway.

This guide binds it only to `127.0.0.1:9119` and reaches it through SSH. That means it is not published on your LAN and does not need a public password or OAuth gate.

### 13.1 Create its systemd user service

Check the Hermes path:

```bash
command -v hermes
```

The normal result is `/home/snknitin/.local/bin/hermes`. If your result is different, replace the `ExecStart` path in the unit below with the path you actually see.

Create the unit:

```bash
mkdir -p "$HOME/.config/systemd/user"
nano "$HOME/.config/systemd/user/hermes-serve.service"
```

Paste:

```ini
[Unit]
Description=Hermes Desktop backend
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=HOME=%h
Environment=HERMES_HOME=%h/.hermes
EnvironmentFile=-%h/.hermes/.env
ExecStart=%h/.local/bin/hermes serve --host 127.0.0.1 --port 9119
Restart=on-failure
RestartSec=10
TimeoutStopSec=30

[Install]
WantedBy=default.target
```

Save with **Ctrl+O**, **Enter**, and **Ctrl+X**.

Load, enable, and start it:

```bash
systemctl --user daemon-reload
systemctl --user enable --now hermes-serve.service
systemctl --user status hermes-serve.service --no-pager
curl -fsS http://127.0.0.1:9119/api/status
```

**Success looks like:** systemd shows `active (running)`, and the curl command returns JSON.

If it fails:

```bash
journalctl --user -u hermes-serve -n 150 --no-pager
```

The most common cause is a different Hermes executable path. Correct `ExecStart`, then repeat `daemon-reload` and `restart`.

### 13.2 Connect from the Windows Hermes Desktop app

Open a visible PowerShell or Windows Terminal window on your PC and run:

```powershell
ssh -N -L 9119:127.0.0.1:9119 snknitin@YOUR_SPARK_IP
```

Replace `YOUR_SPARK_IP` with the same Spark address you normally use for SSH. The window will appear to do nothing; that is normal. Keep it open because it is the tunnel.

In Hermes Desktop:

1. Open **Settings → Gateway**.
2. Choose **Remote gateway**.
3. Enter `http://127.0.0.1:9119`.
4. Save and reconnect.

Because the server itself is loopback-only and the connection travels inside SSH, do not change `hermes serve` to `0.0.0.0` just to make the app connect. If you later use Tailscale directly, add Hermes authentication before changing the bind address.

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
| **Recommended personal mode** | Host Hermes gateway + host `hermes serve` + ODS LiteLLM | ODS `hermes` and `hermes-proxy` | One owner, current Hermes, terminal/phone/Desktop |
| ODS browser mode | ODS `hermes` + `hermes-proxy` | Host gateway and host `hermes serve` | Shared ODS browser entry point, accepting shared state and ODS's pinned Hermes version |

Your selected mode is the first row. Port 9119 belongs to the host Hermes loopback service. Port 9120 stays unused. LiteLLM on port 4000 is still part of ODS and is intentionally shared by the host Hermes processes.

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

Neither switch deletes Hermes data.

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
- `Linger=yes`.

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

Stop the Hermes processes:

```bash
hermes gateway stop
systemctl --user stop hermes-serve.service
```

Start them again:

```bash
hermes gateway start
systemctl --user start hermes-serve.service
```

These commands do not delete `~/.hermes`, model weights, Docker images, or ODS volumes.

## Step 16 — Add later models without turning the Spark into a mess

Use this rule for every additional large model:

1. Stop `vllm-spark-fast`.
2. Check `free -h`, `nvidia-smi`, and `df -h "$HOME"`.
3. Put the recipe checkout under `~/src/<repository>`.
4. Put your own Compose file and pinned `.env` under `~/ai/services/<profile>`.
5. Reuse `~/.cache/huggingface`; do not create another model cache inside every repository.
6. Bind its raw port to `127.0.0.1` or attach it only to the ODS network.
7. Give it a unique LiteLLM alias.
8. Test chat, tools, memory, and clean restart before enabling a restart policy.
9. Keep only one memory-heavy experimental model running at a time.

### How the community repositories differ

- **MiaAI Qwen 35B:** custom GB10 B12X vLLM image, FP8 KV, MTP2, Qwen coder tool parser. The original script uses host networking, mounts the whole repository, permits wildcard media domains, and uses mutable `latest`. Steps 8–9 retain the performance path but narrow and pin the deployment.
- **MiaAI Qwen 27B DFlash:** mutable ARM nightly vLLM, `--privileged`, BF16 KV, and a DFlash draft. That changes too many variables at once, so it is not the first dense-model control.
- **MiaAI Ling 3.0 Flash SGLang:** custom mutable SGLang runtime and a roughly 120 GB-class model. Keep it on hold until the exact upstream checkpoint/runtime provenance and Hermes tool parser are verified.
- **0xSero DeepSeek V4 Flash:** an unusually well-pinned custom SparkInfer stack, but it downloads a pruned/converted derivative with custom kernels and a large disk workspace. Treat it as an isolated appliance, not as a normal Hugging Face model served by your always-on vLLM container.

For the DeepSeek experiment later, perform only the checkout first:

```bash
cd "$HOME/src"
git clone https://github.com/0xSero/deepseek-v4-flash-0731-spark-sparkinfer.git
cd deepseek-v4-flash-0731-spark-sparkinfer
git rev-parse HEAD
docker compose config
```

Do not run `docker compose up` until `vllm-spark-fast` and every other GPU model server are stopped and `df -h "$HOME"` shows at least 250 GB free; 300 GB is a more comfortable margin.

## Current primary references

- [NVIDIA Hermes Agent on DGX Spark](https://build.nvidia.com/spark/hermes-agent/instructions)
- [NVIDIA agent-ready Qwen 35B vLLM playbook](https://build.nvidia.com/spark/vllm/agent-ready-qwen35b)
- [Open NVIDIA playbook tool-call issue #89](https://github.com/NVIDIA/dgx-spark-playbooks/issues/89)
- [Current Hermes installation and documentation](https://hermes-agent.nousresearch.com/docs/)
- [Hermes AI provider configuration](https://hermes-agent.nousresearch.com/docs/integrations/providers)
- [Hermes messaging gateway](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/)
- [Hermes Desktop remote backend](https://hermes-agent.nousresearch.com/docs/user-guide/desktop)
- [ODS LiteLLM service](https://github.com/Osmantic/ODS/tree/main/ods/extensions/services/litellm)
- [ODS Hermes integration](https://github.com/Osmantic/ODS/blob/main/ods/docs/HERMES.md)
- [ODS Hermes SSO/Auth Proxy](https://github.com/Osmantic/ODS/blob/main/ods/docs/HERMES-SSO.md)
- [MiaAI Qwen 35B DGX Spark repository](https://github.com/MiaAI-Lab/Unsloth-Qwen3.6-35b-NVFP4-DGX-Spark)
- [MiaAI Qwen 27B DFlash repository](https://github.com/MiaAI-Lab/Qwen3.6-27B-NVFP4-DFlash-DGX-Spark)
- [MiaAI Ling 3.0 Flash SGLang repository](https://github.com/MiaAI-Lab/Ling-3.0-Flash-SGLang-DGX-Spark)
- [0xSero DeepSeek V4 Flash SparkInfer repository](https://github.com/0xSero/deepseek-v4-flash-0731-spark-sparkinfer)

The detailed repository-by-repository evidence and benchmark caveats are in [[DGX Spark Aug 2026 Model Deployment Research]].

<details>
<summary>Archived earlier first-model draft (superseded by Steps 7 onward)</summary>

The material below is retained only for history. Do **not** run it after following the current Steps 7 onward.

## Previous first-model draft

## First model: the recommended next session

Do not pull five models at once. Establish one reproducible baseline first: `nvidia/Qwen3.6-35B-A3B-NVFP4` on vLLM as `spark-fast`. NVIDIA's current Hermes and vLLM guidance use this agent-ready family, and your existing local roadmap already selected it as the first always-on model. [NVIDIA vLLM playbook](https://build.nvidia.com/spark/vllm/instructions)

This download is large and may take a long time. Use `tmux` so it continues if the SSH window disconnects.

**Start a protected terminal session:**

```bash
tmux new -s first-model
```

The screen will look like a normal terminal. Run the download commands inside it. To leave it running in the background, press `Ctrl+B`, release both keys, then press `D`. To return later, run:

```bash
tmux attach -t first-model
```

If `tmux: command not found` appears, stop and install it with `sudo apt update && sudo apt install -y tmux`, then retry.

### 1. Download once into the shared Hugging Face cache

**Action:** Inside the `tmux` session, copy and run the entire block. It reads your saved token without displaying it, obtains the exact current model revision, downloads that revision, and records it.

```bash
set -a
. "$HOME/.config/dgx-spark/secrets.env"
set +a

MODEL_ALIAS=spark-fast
MODEL_ID=nvidia/Qwen3.6-35B-A3B-NVFP4
MODEL_REVISION="$(python3 -c 'from huggingface_hub import HfApi; print(HfApi().model_info("nvidia/Qwen3.6-35B-A3B-NVFP4").sha)')"
MODEL_PATH="$(hf download "$MODEL_ID" --revision "$MODEL_REVISION")"

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$MODEL_ALIAS" "$MODEL_ID" "$MODEL_REVISION" safetensors huggingface downloaded "$(date -Iseconds)" \
  >> "$HOME/.config/dgx-spark/manifests/models.tsv"

echo "Host model path: $MODEL_PATH"
unset HF_TOKEN NGC_API_KEY
```

During the download, progress bars and changing percentages are normal. Do not close the Spark or delete partial cache files. If the connection drops, reconnect and use `tmux attach -t first-model`.

**Success looks like:** the final `Host model path:` is underneath `/home/snknitin/.cache/huggingface/hub/`. Verify the registry and disk use:

```bash
dgx-models
dgx-space
```

`MODEL_PATH` should be a snapshot directory beneath `$HF_HOME/hub`. vLLM and SGLang can reuse that same cache; do not download a second copy for the SGLang comparison.

### 2. Pin the existing vLLM image

Keep the version out of `.bashrc`. The tag you already selected is a service input:

**Action:** Run this after the model download finishes. Docker may show `Image is up to date` if the image is already present; that is successful.

```bash
VLLM_IMAGE=nvcr.io/nvidia/vllm:26.07-py3
docker pull "$VLLM_IMAGE"
VLLM_PINNED="$(docker image inspect --format '{{index .RepoDigests 0}}' "$VLLM_IMAGE")"
echo "$VLLM_PINNED"

cat > "$HOME/.config/dgx-spark/services/vllm-spark-fast.env" <<EOF
VLLM_IMAGE=$VLLM_IMAGE
VLLM_PINNED=$VLLM_PINNED
MODEL_ALIAS=spark-fast
MODEL_ID=nvidia/Qwen3.6-35B-A3B-NVFP4
MODEL_REVISION=$MODEL_REVISION
HOST_PORT=8000
EOF
```

If `VLLM_PINNED` is blank, do not launch yet; inspect `docker images --digests` and fix registry authentication.

**Verify:**

```bash
cat "$HOME/.config/dgx-spark/services/vllm-spark-fast.env"
```

This file contains no secret token. Confirm that `VLLM_PINNED` contains `@sha256:` and that `MODEL_REVISION` is a long hexadecimal identifier.

### 3. Start manually before enabling restart

Reload the model snapshot path if this is a new shell, translate it to the path inside the cache mount, and verify that port 8000 is free:

**Action A — check the port first:**

```bash
ss -ltn | grep ':8000 ' || echo 'Port 8000 appears free'
```

If the command prints a listening address containing `:8000`, stop and identify the owner with `docker ps` before continuing. If it prints `Port 8000 appears free`, run the launch block below.

**Action B — start vLLM:** Copy and run the whole block. Docker runs it in detached mode, so the prompt should return after printing a container ID.

```bash
source "$HOME/.config/dgx-spark/services/vllm-spark-fast.env"
MODEL_PATH="$(hf download "$MODEL_ID" --revision "$MODEL_REVISION")"
CONTAINER_MODEL_PATH="/root/.cache/huggingface/${MODEL_PATH#"$HF_HOME/"}"

docker run -d \
  --name vllm-spark-fast \
  --restart no \
  --gpus all \
  --ipc=host \
  -p 127.0.0.1:8000:8000 \
  -e HF_HOME=/root/.cache/huggingface \
  -e HF_HUB_OFFLINE=1 \
  -v "$HF_HOME:/root/.cache/huggingface" \
  "$VLLM_PINNED" \
  vllm serve "$CONTAINER_MODEL_PATH" \
    --served-model-name spark-fast \
    --host 0.0.0.0 \
    --port 8000 \
    --tensor-parallel-size 1 \
    --trust-remote-code \
    --kv-cache-dtype fp8 \
    --attention-backend flashinfer \
    --moe-backend marlin \
    --gpu-memory-utilization 0.4 \
    --max-model-len 65536 \
    --max-num-seqs 4 \
    --max-num-batched-tokens 8192 \
    --enable-chunked-prefill \
    --async-scheduling \
    --enable-prefix-caching \
    --speculative-config '{"method":"mtp","num_speculative_tokens":3,"moe_backend":"triton"}' \
    --load-format fastsafetensors \
    --reasoning-parser qwen3 \
    --tool-call-parser qwen3_xml \
    --enable-auto-tool-choice
```

If Docker says the name `vllm-spark-fast` is already in use, do not rename the new container. Run `docker ps -a --filter name=vllm-spark-fast` and decide whether the existing container is the one created by this guide before removing or replacing anything.

Follow startup and test it:

**Action C — watch startup:**

```bash
docker logs -f vllm-spark-fast
```

After the log says the server is ready, press `Ctrl+C`; that exits log-following, not the container. Then run:

**Action D — run the health and response tests:**

```bash
curl -fsS http://127.0.0.1:8000/health

curl -sS http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "spark-fast",
    "messages": [{"role": "user", "content": "Reply with exactly: Spark ready"}],
    "max_tokens": 20,
    "temperature": 0
  }'

nvidia-smi
```

**Success looks like:** the health request exits without an error, the chat response contains `Spark ready`, and `nvidia-smi` shows the model process without an out-of-memory error.

Confirm the API identity with `curl -s http://127.0.0.1:8000/v1/models`; it should advertise `spark-fast` because the launch command sets `--served-model-name spark-fast`.

Only after completions, streaming, tool calls, and four concurrent requests pass:

**Action E — enable automatic restart and record the service:** Run this only after the manual tests have passed.

```bash
docker update --restart unless-stopped vllm-spark-fast

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  vllm-spark-fast vllm "$VLLM_PINNED" spark-fast 8000 unless-stopped validated \
  >> "$HOME/.config/dgx-spark/manifests/services.tsv"
```

### 4. What remains stopped

- Keep SGLang stopped until `spark-fast` is validated. Then run it on port `30000` against the **same Hugging Face cache and exact model revision** for an A/B comparison.
- Keep NIM stopped until testing a model with an explicit NIM profile. Use `~/.cache/nim` and `~/.local/share/dgx-spark/nim/workspace`; never reuse port 8000 while vLLM owns it.
- Keep LM Studio on-demand. Its models remain under `~/.lmstudio/models` and are listed with `lms ls`; do not copy them into the Hugging Face cache.
- Keep the ODS-managed llama.cpp/Open WebUI services as their existing owner. Do not install duplicates from the NVIDIA playbooks.

## Daily operating sequence

```bash
dgx-status                 # what is running and GPU state
dgx-models                 # model registry plus native stores
dgx-space                  # cache, Docker, and filesystem usage
column -ts $'\t' "$HOME/.config/dgx-spark/ports.tsv"
```

For every new playbook:

1. Classify it as **foundation**, **persistent service**, **on-demand backend**, or **one-shot experiment**.
2. Check ODS overlap before installing anything.
3. Assign a unique name, port, image tag/digest, cache owner, output directory, and restart policy.
4. Put secrets in `secrets.env`; put image/model/port settings in the service env; put experiment-only variables in its launch script.
5. Start manually with no restart policy, smoke-test, record the result, and only then enable persistence.
6. Stop mutually exclusive GPU backends before loading another large model. One downloaded model can remain on disk while only one large serving process owns unified memory.

## Decision summary

1. Keep `~/.bashrc` small. Persist only stable interactive-shell paths and harmless defaults there.
2. Do **not** store `NGC_API_KEY` or `HF_TOKEN` directly in `~/.bashrc`. Keep secrets in a permission-restricted file or secret manager and load them only for commands/services that need them.
3. Use the normal tool-native caches instead of copying the same model into a new universal `models/` folder: Hugging Face at `~/.cache/huggingface`, NIM at `~/.cache/nim`, and LM Studio at `~/.lmstudio/models`.
4. Put durable service definitions and per-service variables under one operations root, but keep caches, source checkouts, datasets, outputs, and secrets separate.
5. Pin container image tags in service-specific env files. `LATEST_VLLM_VERSION`, `SGLANG_IMAGE`, model handles, ports, and tuning flags are deployment configuration—not global shell state.
6. Give every persistent container a unique name, explicit port, explicit volume mount, health check, restart policy, and a short manifest recording image/model/flags.
7. Do not run ODS llama.cpp/Open WebUI and duplicate playbook installations blindly. Treat ODS as the service plane and vLLM, SGLang, NIM, and LM Studio as separately managed backends or experiments.

## Assessment of the current `.bashrc`

Current entries:

```bash
export PATH="$HOME/.local/bin:$PATH"
export NGC_API_KEY=<redacted>
export HF_TOKEN=<redacted>
export LATEST_VLLM_VERSION=26.07-py3
export LOCAL_NIM_CACHE=~/.cache/nim
export LOCAL_NIM_WORKSPACE=~/.local/share/nim/workspace
export PATH="$PATH:/home/snknitin/.lmstudio/bin"
export HF_HOME="$HOME/.cache/huggingface"
```

Recommended disposition:

| Entry | Keep in `.bashrc`? | Reason |
|---|---:|---|
| `PATH="$HOME/.local/bin:$PATH"` | Yes | Hermes and `uv`-installed tools use this location; NVIDIA's Hermes playbook explicitly warns that scripted SSH shells may still need the absolute path or an explicit export. [Source](https://build.nvidia.com/spark/hermes-agent) |
| LM Studio CLI path | Yes, normalized | Use `export PATH="$HOME/.lmstudio/bin:$PATH"`; the LM Studio playbook instructs users to add `lms` to `PATH`. [Source](https://build.nvidia.com/spark/lm-studio/instructions) |
| `HF_HOME` | Optional, reasonable | It makes the chosen Hugging Face root explicit. NVIDIA's container recipes repeatedly persist `~/.cache/huggingface` by mounting it to `/root/.cache/huggingface`; retaining the default location maximizes reuse. [vLLM source](https://build.nvidia.com/spark/vllm/instructions) |
| `NGC_API_KEY` / `HF_TOKEN` (values redacted here) | Migrate, then remove | The live values must first be copied into `~/.config/dgx-spark/secrets.env` with mode `600`. Secrets should not remain in a general shell startup file or committed configuration. |
| `LATEST_VLLM_VERSION` | Move | Image versions belong in the vLLM service env/manifest. NVIDIA labels the value as a version selected for that vLLM run, and its examples change over time. [Source](https://build.nvidia.com/spark/vllm/instructions) |
| `LOCAL_NIM_CACHE` | Move, or keep only as a harmless convenience | NIM uses this path as a host bind mount to `/opt/nim/.cache`; it is a NIM deployment setting rather than a universal shell requirement. [Source](https://build.nvidia.com/meta/llama3-8b) |
| `LOCAL_NIM_WORKSPACE` | Move | This is NIM-specific durable state and should live with the NIM service definition.

Minimal proposed `.bashrc` block:

```bash
# User-installed CLIs
export PATH="$HOME/.local/bin:$HOME/.lmstudio/bin:$PATH"

# Shared Hugging Face cache used by host tools and mounted into containers
export HF_HOME="$HOME/.cache/huggingface"
```

> [!note] Non-interactive SSH
> Ubuntu commonly exits early from `.bashrc` for non-interactive shells. Do not make automation depend on `.bashrc`; use absolute executable paths or source a dedicated non-secret environment file in the service script. NVIDIA calls out this exact issue for Hermes. [Source](https://github.com/NVIDIA/dgx-spark-playbooks/tree/main/nvidia/hermes-agent)

## Proposed filesystem layout

```text
~/.config/dgx-spark/                 # small, backed-up configuration
  secrets.env                       # mode 600; never commit
  ports.env                         # central host-port assignments
  services/
    vllm.env
    sglang.env
    nim.env
    lmstudio.env
  manifests/                        # what is intended to run
    <service>.yaml

~/.local/share/dgx-spark/           # durable application state
  nim/workspace/
  open-webui/
  projects/
  datasets/
  outputs/
  checkpoints/

~/.cache/                           # reproducible/downloadable artifacts
  huggingface/                      # HF_HOME; mount to container HF cache
  nim/                              # mount to /opt/nim/.cache

~/.lmstudio/                        # owned by LM Studio/llmster
  models/

~/src/                              # Git checkouts and playbook code
  dgx-spark-playbooks/
  experiments/

~/runs/                             # benchmark/evaluation records, not model blobs
  YYYY-MM-DD_<engine>_<model>/
    manifest.yaml
    command.txt
    metrics.json
    logs/
```

This respects the paths NVIDIA's recipes actually expect. vLLM and several other playbooks mount the host Hugging Face cache into the container so downloads survive container deletion; NIM similarly mounts `~/.cache/nim`; LM Studio explicitly stores downloadable models separately under `~/.lmstudio/models`, and uninstalling llmster does not delete those models. [vLLM](https://build.nvidia.com/spark/vllm/instructions) · [NIM](https://build.nvidia.com/spark/nim-llm) · [LM Studio](https://build.nvidia.com/spark/lm-studio/instructions)

Do not symlink all three model stores into one directory. Their formats, metadata, partial-download rules, ownership, and cleanup tools differ. A single **manifest index** gives one navigable view without destabilizing the runtimes.

## Secrets and registry authentication

Keep a local file such as `~/.config/dgx-spark/secrets.env` with mode `600`:

```dotenv
HF_TOKEN=...
NGC_API_KEY=...
```

Load it only in the current shell or pass it with a service-specific `--env-file`; never commit it, echo it in logs, or place it in `manifest.yaml`. NVIDIA's NIM workflow requires two related but distinct actions: authenticate Docker to `nvcr.io` using username `$oauthtoken`, and pass `NGC_API_KEY` into the running NIM so it can fetch protected artifacts. [NIM playbook](https://build.nvidia.com/spark/nim-llm) The Hugging Face token is required for gated/private models and is passed into vLLM-style containers, while the downloaded files persist in the mounted cache. [vLLM playbook](https://build.nvidia.com/spark/vllm/instructions)

Use least-privilege, read-only Hugging Face tokens for downloads. `docker login` stores a registry credential through Docker's configured credential mechanism; do not add the NGC key to an image, Dockerfile, Compose file, or Git repository.

## Universal variables versus playbook-local variables

### Stable host defaults

Only these are broadly useful across sessions:

| Variable | Suggested value | Purpose |
|---|---|---|
| `PATH` | `$HOME/.local/bin:$HOME/.lmstudio/bin:$PATH` | User CLIs and `lms` |
| `HF_HOME` | `$HOME/.cache/huggingface` | One host-side Hugging Face cache root |

Even `HF_HOME` is optional because this is already Hugging Face's conventional cache root.

### Secrets loaded only when needed

| Variable | Used by | Persist in `.bashrc`? |
|---|---|---:|
| `HF_TOKEN` | vLLM, Nemotron, fine-tuning, quantization, gated models | No |
| `NGC_API_KEY` | NIM runtime and other NGC-backed playbooks | No |
| `NGC_CLI_API_KEY` | VSS playbook | No |
| external API/bot credentials | Hermes, agent, or application playbooks | No |

### Deployment-local settings

| Playbook/lane | Variables seen in NVIDIA recipes | Where they should live |
|---|---|---|
| vLLM | `LATEST_VLLM_VERSION`, `HF_MODEL_HANDLE`, `VLLM_IMAGE`; multi-node adds `MN_IF_NAME`, `VLLM_HOST_IP`, `HEAD_NODE_IP`, `NCCL_SOCKET_IFNAME`, `UCX_NET_DEVICES`, Ray/Gloo interface settings | `services/vllm.env`; multi-node values in a separate cluster env |
| SGLang | `SGLANG_IMAGE` | `services/sglang.env` |
| NIM | `LOCAL_NIM_CACHE`, `LOCAL_NIM_WORKSPACE`, `IMG_NAME`, `CONTAINER_NAME` | `services/nim.env` |
| TensorRT-LLM/speculative decoding | `DOCKER_IMAGE`, `MODEL`, `MODEL_HANDLE`, `TRTLLM_MN_CONTAINER`, `TIKTOKEN_ENCODINGS_BASE`, selective TRT-LLM feature flags | Per-experiment/service env |
| Nemotron | `WEIGHTS` plus model-specific vLLM backend flags | Model-specific manifest, not global shell state |
| NCCL/multi-Spark | `CUDA_HOME`, `MPI_HOME`, `NCCL_HOME`, `LD_LIBRARY_PATH`, `UCX_NET_DEVICES`, `NCCL_SOCKET_IFNAME`, and topology-specific flags | Dedicated cluster activation script; never universal |
| Isaac Sim | `ISAACSIM_PATH`, `ISAACSIM_PYTHON_EXE`, `LD_PRELOAD` | Isaac project activation script |
| VSS | `LLM_ENDPOINT_URL`, `NGC_CLI_API_KEY` | VSS `.env`, with secret separated where possible |

The official SGLang playbook, for example, sets `SGLANG_IMAGE=lmsysorg/sglang:latest-cu130` for that workflow and publishes port `30000`; this is not a reason to export it globally. [Source](https://build.nvidia.com/spark/sglang/instructions) The vLLM playbook similarly treats its image version and model handle as inputs to a particular run. [Source](https://build.nvidia.com/spark/vllm/instructions)

## Container and service conventions

For every long-running backend, record:

```yaml
service: vllm-qwen36
engine: vllm
image: nvcr.io/nvidia/vllm:<pinned-tag>
model: <exact-repository-or-local-path>
quantization: <exact-format>
host_port: <allocated-port>
container_port: 8000
cache_mount: ~/.cache/huggingface:/root/.cache/huggingface
command_flags: []
owner: standalone-or-ods
autostart: false
```

Operational rules:

- Pin a tested image tag (ideally record the image digest after pulling). Do not use `latest` for an always-on service.
- Name containers by engine and model, for example `vllm-qwen36-nvfp4`, rather than generic `vllm-server` when more than one experiment may exist.
- Persist only caches and intentional output/state directories. Containers themselves should be replaceable.
- Add `--restart unless-stopped` only after a backend passes a manual smoke test and its port does not overlap ODS.
- Use one active owner per UI/database. In particular, retain the ODS-managed Open WebUI rather than starting a second copy unless it is an isolated lab.
- Mount caches with consistent ownership. NVIDIA's Hugging Face examples mount the user's cache to root's cache inside the container; NIM examples may run the container as the host UID. Verify ownership before switching those patterns. [NIM deployment example](https://build.nvidia.com/meta/llama3-8b)
- Before launches, check `docker ps`, `nvidia-smi`, free disk, and the desired port. The SGLang playbook explicitly validates Docker, GPU visibility, container GPU support, and disk before serving. [Source](https://build.nvidia.com/spark/sglang/instructions)

## Port registry

Several playbooks choose defaults that collide. Reserve host ports centrally and map the container's native port to them.

| Service | Playbook default | Suggested ownership note |
|---|---:|---|
| vLLM | `8000` | Choose a dedicated host port if ODS/NIM already uses 8000. [Source](https://build.nvidia.com/spark/vllm/instructions) |
| NIM LLM | `8000` | Conflicts with default vLLM; remap one side. [Source](https://build.nvidia.com/meta/llama3-8b) |
| SGLang | `30000` | Native SGLang API. [Source](https://build.nvidia.com/spark/sglang/instructions) |
| LM Studio | `1234` | Bind only to trusted interfaces, or use LM Link and `localhost:1234`. [Source](https://build.nvidia.com/spark/lm-studio/instructions) |
| Ollama | `11434` | Used by the Live VLM recipe as the Ollama API. [Source](https://build.nvidia.com/spark/live-vlm-webui/instructions) |
| Live VLM WebUI | `8090` | HTTPS/WebRTC UI. [Source](https://build.nvidia.com/spark/live-vlm-webui/instructions) |
| JupyterLab examples | `8888` | Used by data-science playbooks. [Source](https://build.nvidia.com/spark/single-cell/instructions) |
| Ray dashboard | `8265` | Tunnel over SSH rather than broadly exposing it. [Source](https://build.nvidia.com/spark/vllm/stacked-sparks) |

Do not expose model APIs on `0.0.0.0` unless LAN/Tailscale access is intentional and controlled. NVIDIA's LM Studio instructions explicitly distinguish LAN binding from LM Link, which avoids opening the service to the LAN. [Source](https://build.nvidia.com/spark/lm-studio/instructions)

## Model tracking: index metadata, not duplicated files

For each downloaded or locally produced model, track:

- canonical model ID and exact revision/commit;
- engine and exact image tag/digest;
- on-disk owner/cache (`huggingface`, `nim`, `lmstudio`, ODS, or project checkpoint);
- quantization and weight format;
- context length, memory-utilization setting, and concurrency;
- API alias and host port;
- license/gated-access status;
- last successful smoke test and benchmark run;
- whether the model is base, fine-tuned, quantized, or an expendable cache.

The manifest should point to the runtime-owned cache path rather than relocating the files. This makes `lms ls`, Hugging Face cache tooling, NIM reuse, and ODS's own lifecycle controls remain authoritative.

## Playbook findings appendix

The Spark catalog is a mixture of foundations, mutually competing runtimes, experiments, and applications—not a package list to install wholesale. The official repository also includes repo-only/legacy and DGX Station directories, so the [live Spark catalog](https://build.nvidia.com/spark) remains the authority for what is currently published; the [repository](https://github.com/NVIDIA/dgx-spark-playbooks/tree/main/nvidia) is the authority for scripts and exact commands.

### Foundation and connectivity

- Local Network Access, Tailscale, DGX Dashboard, VS Code, Connect Two/Three Sparks, multi-Spark switch, and NCCL.
- Host-wide persistence is appropriate only for intentional SSH/network configuration and, for a real cluster, its dedicated NCCL/network activation settings.

### Inference runtimes

- llama.cpp, vLLM, SGLang, TensorRT-LLM, NIM, Ollama, LM Studio, Nemotron, multi-modal inference, and speculative decoding.
- These are alternative or complementary serving lanes. Share caches where the runtime supports the same cache contract, but never assume their model formats are interchangeable.
- vLLM uses port 8000 in NVIDIA's baseline; SGLang uses 30000; NIM commonly uses 8000; LM Studio uses 1234. Port assignment must precede autostart.

### Model optimization and training

- PyTorch fine-tuning, NeMo fine-tuning, Unsloth, LLaMA Factory, FLUX DreamBooth LoRA, NVFP4 quantization, optimized JAX, and cuTile kernels.
- Keep datasets, checkpoints, exports, and run metadata under durable project/run directories. Tokens, selected recipes, export names, CUDA/build variables, and model paths are experiment-scoped.

### Applications and agents

- Open WebUI, Live VLM WebUI, RAG in AI Workbench, multi-agent chatbot, text-to-knowledge-graph, VSS, Hermes, OpenClaw/OpenShell, NemoClaw and its example agents, CLI coding agent, and VS Code vibe coding.
- These often bring their own databases, workspaces, bot credentials, and ports. Reuse an existing ODS service when possible; otherwise isolate application state under its own directory and name its backend endpoint explicitly.

### Domain demonstrations

- CUDA-X data science, single-cell RNA sequencing, portfolio optimization, Isaac Sim/Lab, and Reachy photo booth.
- Treat these as project environments. Their build flags, libraries, Jupyter data, and outputs should not leak into the global shell configuration.

## Immediate conclusions for this Spark

- The existing `vLLM`, `SGLang`, and NIM container images do not mean a model has been installed; images and model caches are separate disk inventories.
- Keep the existing HF and NIM cache choices, but define them in their owning service configs.
- Leave LM Studio's model store under `~/.lmstudio/models`; its CLI can list and remove those models, and its server defaults to port 1234. [Source](https://build.nvidia.com/spark/lm-studio/instructions)
- Before pulling the first model, inventory ODS containers, images, volumes, occupied ports, disk usage, and existing cache contents. Then choose one first serving baseline and give it a pinned manifest.
- The clean first comparison is one exact Hugging Face checkpoint served by vLLM and SGLang with distinct host ports and the same evaluation prompts. Add NIM only for a supported NIM model, and use LM Studio for its separate catalog/LM Link workflow rather than treating it as the canonical copy of every model.

## Primary sources

- [NVIDIA DGX Spark playbook catalog](https://build.nvidia.com/spark)
- [Official NVIDIA DGX Spark playbooks repository](https://github.com/NVIDIA/dgx-spark-playbooks)
- [vLLM for Inference](https://build.nvidia.com/spark/vllm/instructions)
- [SGLang for Inference](https://build.nvidia.com/spark/sglang/instructions)
- [NIM on Spark](https://build.nvidia.com/spark/nim-llm)
- [LM Studio on DGX Spark](https://build.nvidia.com/spark/lm-studio/instructions)
- [Live VLM WebUI](https://build.nvidia.com/spark/live-vlm-webui/instructions)
- [Single-cell RNA Sequencing](https://build.nvidia.com/spark/single-cell/instructions)
- [Set Up Local Network Access](https://build.nvidia.com/spark/connect-to-your-spark)

</details>

Related: [[DGX Spark Aug 2026 Model Deployment Research]] | [[Local Setup Index]]
