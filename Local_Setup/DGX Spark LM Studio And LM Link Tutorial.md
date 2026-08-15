# DGX Spark LM Studio And LM Link Tutorial

LM Studio's headless CLI is already installed on your Spark:

```text
/home/snknitin/.lmstudio/bin/lms
```

Do **not** reinstall it. This tutorial verifies the existing installation, signs the Spark into LM Link, enables just-in-time model loading, and optionally makes the daemon return after a reboot.

> [!important] Active Step 4 model
> The active rollout is **NVIDIA Nemotron 3.5 Lightning 30B-A3B Q4_K_M** in the Spark LM Studio store. Nemotron 3 Nano Omni remains a separate prepared vLLM specialist and must not be downloaded again into LM Studio for this step.

LM Studio uses its own model store:

```text
/home/snknitin/.lmstudio/models
```

It cannot reuse Ollama blobs or the tuned NVFP4 Hugging Face snapshots automatically. Use LM Studio only for models you specifically want to control from the LM Studio graphical application.

## What LM Link does

LM Link connects LM Studio on your Windows desktop or laptop to `llmster` on the Spark. When both devices use the same LM Studio account, the Spark appears as a remote device and its downloaded models appear in the desktop model loader.

LM Link can coexist with Tailscale. Continue using Tailscale/NVIDIA Sync for SSH, ODS, and Hermes; LM Link is only the private device connection for LM Studio.

## Step 1 — Verify the existing Spark installation

Run these commands in the **Spark terminal opened from NVIDIA Sync**:

```bash
command -v lms
lms --version
lms ls
lms daemon status || true
lms server status || true
```

Expected:

- `command -v` prints `/home/snknitin/.lmstudio/bin/lms`;
- the version command prints the CLI commit/version;
- `lms ls` shows the two small embedding entries you already reported;
- a daemon/server status error is acceptable if they have not been started.

## Step 2 — Start the headless daemon

```bash
lms daemon up
lms daemon status
```

This starts the background model-management process. It does not load a large model.

## Step 3 — Sign in and enable LM Link on the Spark

Run:

```bash
lms login
```

Follow the sign-in instructions it prints. It may show a browser URL or device code. Complete that sign-in using your normal browser.

Return to the Spark terminal and run:

```bash
lms link enable
lms link status
```

Success looks like LM Link is enabled for this Spark. Do not paste login codes or account tokens into a Markdown note or chat.

## Step 4 — Add the Spark in LM Studio on Windows

On the **desktop computer**:

1. Open LM Studio.
2. Sign into the same LM Studio account used in Step 3.
3. Open **LM Link** or the linked-devices area.
4. Enable LM Link if it is off.
5. Wait for the Spark/llmster device to appear.
6. Select the Spark as the remote inference device.

Repeat these steps on the laptop using the same account. You do not need to add another Tailscale node or copy model files to Windows.

If the Spark does not appear, return to its terminal and run:

```bash
lms daemon status
lms link status
```

Do not expose port 1234 to the whole LAN as the first workaround.

## Step 5 — Download the one intentional LM Studio model

This rollout deliberately gives LM Studio one Spark-hosted GGUF model that is not also served as another vLLM instance. Download only the Q4_K_M edition of Nemotron 3.5 Lightning:

```bash
lms get nvidia/nemotron-3.5-lightning@q4_k_m --gguf --yes
lms ls --json
```

LM Studio resolves this to **NVIDIA Nemotron 3.5 Lightning 30B A3B Q4_K_M [GGUF]**, approximately 24.52 GB as reported by `lms get`. The download uses disk and does not make the model resident. Do not download Nemotron 3 Omni here and do not create a Lightning vLLM container.

## Step 6 — Estimate memory before loading

Stop the current vLLM model before the estimate becomes a real load:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env down
free -h
nvidia-smi
```

Ask LM Studio for an estimate:

```bash
lms load nvidia/nemotron-3.5-lightning \
  --estimate-only \
  --context-length 65536 \
  --gpu max
```

Read the estimate. Do not continue if it predicts that the model plus context will exhaust available memory.

## Step 7 — Load it with an automatic timeout

```bash
lms load nvidia/nemotron-3.5-lightning \
  --context-length 65536 \
  --gpu max \
  --ttl 3600 \
  --yes
```

`--ttl 3600` asks LM Studio to unload it after one hour of inactivity. Start at 64K and raise it only after the memory estimate, plain chat, and Hermes tool-call tests pass.

> [!success] Verified on this Spark
> At 65,536 context and full GPU offload, LM Studio estimated and loaded 22.83 GiB. The model loaded in 4.78 seconds after Qwen was taken down. Its identifier is `nvidia/nemotron-3.5-lightning`.

Verify what is resident:

```bash
lms ps
free -h
nvidia-smi
```

## Step 8 — Start and test the local API

Start the Spark's LM Studio API without opening it to the LAN:

```bash
lms server start --bind 127.0.0.1 --port 1234
lms server status
```

Test from the Spark:

```bash
curl -fsS http://127.0.0.1:1234/v1/models
```

In LM Studio on Windows, choose the linked Spark and its model in the model loader/chat interface. The computation happens on the Spark even though you control it from the desktop.

The rollout passed all of these non-representational checks: Spark `/v1/models`, a Spark raw completion, a structured raw function call, a Spark Hermes terminal-tool call, Windows `localhost:1234` through LM Link, and a Windows local-Hermes terminal-tool call. Telegram and Discord are connected to the same Spark Hermes home, but send an intentional bot test message before marking their model-specific check complete.

> [!important] LM Link is not a vLLM importer
> LM Link controls models managed by LM Studio. It does not discover or start the Qwen/Gemma vLLM Docker containers. Those remain available through ODS, LiteLLM, Hermes, and their own raw endpoints.

## Step 9 — Understand JIT loading and auto-eviction

The verified Spark LM Studio settings for this rollout are:

- just-in-time loading enabled;
- initially verified with a 3,600-second idle TTL, then deliberately reloaded without a TTL for persistent warm co-residency with Qwen;
- automatic eviction of the previous JIT-loaded model enabled;
- only the last JIT-loaded model retained;
- default context raised from 8,192 to 65,536 only after the staged configuration is validated.

This is the closest match to an easy model shelf. The model names can remain visible while only the selected model is resident. The first request after a switch waits for weights to load.

For the Spark, retain the one-large-model policy even with auto-eviction. Check `lms ps`, `docker ps`, and `ollama ps` before assuming memory is free.

## Step 10 — Unload the test and restore Qwen

Unload all LM Studio models:

```bash
lms unload --all
lms ps
```

Restore Qwen:

```bash
cd "$HOME/ai/services/qwen35"
docker compose --env-file .env up -d
```

The installed model manager performs safe handoffs and waits for the selected endpoint to become API-ready:

```bash
spark-model list
spark-model use nemotron35-lightning
spark-model use qwen35
spark-model status
```

It also supports any future model already installed in the Spark LM Studio catalog:

```bash
spark-model lmstudio-list
spark-model use lmstudio:publisher/model-key
```

The manager does not change the Hermes default. `spark-fast` remains the 24/7 default after Qwen is restored; choose the `Spark LM Studio` provider and loaded model in Hermes while an LM Studio lane is active. The legacy `spark-inference-lane nemotron|qwen` aliases remain only for compatibility.

## Step 11 — Optional: make llmster and its API return after reboot

First check whether a service already exists:

```bash
systemctl --user list-unit-files \
  | grep -Ei 'lmstudio|llmster|lms' || true
```

If that prints an existing enabled LM Studio/llmster service, do not create a duplicate. Inspect it with:

```bash
systemctl --user status NAME_FROM_THE_LIST
```

If no service exists, create one:

```bash
mkdir -p "$HOME/.config/systemd/user"
nano "$HOME/.config/systemd/user/lmstudio-link.service"
```

Paste:

```ini
[Unit]
Description=LM Studio llmster API and LM Link
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
Environment=HOME=/home/snknitin
Environment=PATH=/home/snknitin/.lmstudio/bin:/usr/local/bin:/usr/bin:/bin
ExecStartPre=/home/snknitin/.lmstudio/bin/lms daemon up
ExecStart=/home/snknitin/.lmstudio/bin/lms server start --bind 127.0.0.1 --port 1234
ExecStop=/home/snknitin/.lmstudio/bin/lms server stop
ExecStop=/home/snknitin/.lmstudio/bin/lms daemon down
TimeoutStartSec=120

[Install]
WantedBy=default.target
```

Save with **Ctrl+O**, **Enter**, and **Ctrl+X**, then validate and enable it:

```bash
systemd-analyze --user verify "$HOME/.config/systemd/user/lmstudio-link.service"
lms server stop || true
lms daemon down || true
systemctl --user daemon-reload
systemctl --user enable --now lmstudio-link.service
systemctl --user status lmstudio-link.service
```

Check user lingering:

```bash
loginctl show-user "$USER" -p Linger
```

If it says `Linger=yes`, no change is needed. If it says `Linger=no`, run:

```bash
sudo loginctl enable-linger "$USER"
```

Linger lets user services start at boot even before you open an SSH session. Your existing persistent Hermes setup may already have enabled it.

Reboot persistence keeps the daemon and API available; it does not force a 30B model to remain loaded. JIT/TTL behavior still controls model residency.

## ODS integration decision

Do not add LM Studio's unauthenticated host API to ODS during this first setup. You already have:

- vLLM/SGLang through LiteLLM for tuned serving;
- Ollama directly on the ODS Docker network for a convenience shelf;
- LM Link for the Windows graphical workflow.

That division avoids binding LM Studio to `0.0.0.0`. If you later need ODS to call an LM Studio-only model, add a protected, explicitly routed connection after verifying Docker-to-host networking and firewall policy.

## Daily commands

```bash
lms daemon status
lms link status
lms server status
lms ls
lms ps
spark-model list
spark-model status
```

Unload models without deleting them:

```bash
lms unload --all
```

Stop only the API:

```bash
lms server stop
```

## Primary sources

- [NVIDIA DGX Spark LM Studio playbook](https://build.nvidia.com/spark/lm-studio/instructions)
- [LM Studio headless mode](https://lmstudio.ai/docs/developer/core/headless)
- [LM Link device setup](https://lmstudio.ai/docs/lmlink/basics/add-device)
- [LM Studio model TTL and auto-eviction](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict)
- [LM Studio model loading CLI](https://lmstudio.ai/docs/cli/local-models/load)

Related: [[DGX Spark Additional Model Tutorials Index]] | [[DGX Spark Ollama And ODS Tutorial]] | [[DGX Spark Nemotron 3 Nano Omni Tutorial]]
