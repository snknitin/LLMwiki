---
updated: 2026-08-15
status: active
supersedes: RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial
---

# RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial

This is the corrected, beginner-level runbook for workstation Steps 2, 3, and 4 in [[Local Setup Index]]. It was written after inspecting the ODS and Ollama installations that are actually running on the RTX PRO 5000 workstation.

> [!important] Use this guide instead of the earlier version
> The earlier tutorial treated Windows environment variables as though they controlled Ollama Desktop, mixed the ODS and Ollama model stores, and treated Spark LiteLLM as though it were part of workstation ODS. The authenticated ODS inspection below establishes the actual boundaries.

## What is running on each machine

| System | What it owns | Where you control it |
|---|---|---|
| **Workstation ODS** | ODS Open WebUI, ODS Dashboard, SearXNG, ODS `llama-server`, workstation GGUF models, and UI connections to other runtimes | Dashboard: `http://localhost:3001`; chat: `http://localhost:3000` |
| **Native Windows Ollama** | A separate model runtime and separate model library that ODS Open WebUI can query over its Ollama connection | Ollama desktop application; models can also be selected in ODS chat after download |
| **Workstation LM Studio** | A separate experimental runtime, GGUF library, local API, and LM Link | LM Studio desktop application |
| **DGX Spark** | Hermes Gateway/Serve, Spark LiteLLM, vLLM, the working Qwen profiles, Spark ODS | Hermes Desktop or a Spark terminal |

The workstation ODS and Spark ODS are two separate installations. Their containers, model directories, LiteLLM configurations, and Open WebUI databases are not shared.

The workstation ODS is not currently connected to Spark LiteLLM. Therefore, a `spark/` model prefix should not appear in workstation ODS unless you deliberately add such a connection later. This guide does not add one.

## What the live inspection confirmed

- Workstation ODS Open WebUI is at `http://localhost:3000`.
- The ODS management Dashboard is at `http://localhost:3001`.
- The authenticated **Admin Panel → Settings → Connections** page has its OpenAI-compatible connection set to the internal ODS `llama-server` at `http://llama-server:8080/v1`.
- The **Ollama API** switch is enabled with one `http://host.docker.internal:11434` entry. A duplicate entry was removed and the model selector was verified to show each Ollama model exactly once. Port `11434` remains native Ollama's standard API port; ODS's optional host-facing llama-server port was moved to `11436`.
- The active saved Open WebUI configuration therefore enables Ollama even though the container's initial environment default said otherwise. The authenticated UI is the authoritative current state.
- ODS stores its GGUF model files under `D:\LocalLLama\ods\data\models`.
- Native Ollama 0.32.13 is installed and stores models under `D:\LocalLLama\models\ollama`. The `gemma3:4b`, `gemma4:31b-it-qat`, `gemma4:26b-a4b-it-qat`, and `qwen3.8:27b` packages are downloaded there. Both large Gemmas passed direct Ollama and ODS Open WebUI tests. Qwen 3.8 passed text, structured-tool, vision-path, ODS, Spark-to-workstation, and Hermes tests at its live 256K context. Every model was unloaded after testing.
- Native Ollama uses its standard `127.0.0.1:11434`; Open WebUI reaches it at `http://host.docker.internal:11434`. ODS's stopped host-facing llama-server is reserved at `127.0.0.1:11436` and remains `http://llama-server:8080/v1` inside Docker.
- The former ODS DeepSeek 70B runtime was stopped and its GGUF was moved to the Windows Recycle Bin on 2026-08-15. It is no longer resident in VRAM or present in the ODS model directory.
- The ODS Dashboard has its own separate GGUF catalog, but the two workstation Gemmas in this guide are being installed through Ollama. Do not download second copies from the ODS Dashboard.

> [!warning] One model library cannot be dropped into the other
> ODS uses ordinary GGUF files in its own model directory. Ollama uses its own blobs and manifests. LM Studio also manages its own library. Do not copy an Ollama `blobs` folder into the ODS model directory, and do not point all three applications at the same folder.

---

## Part 1 — Understand the two ODS pages

### Step 1.1 — Open the ODS Dashboard

On the RTX PRO 5000 workstation:

1. Open your normal web browser.
2. Enter `http://localhost:3001` in the address bar.
3. Press **Enter**.
4. You should see the ODS Dashboard or control center.

Use this page to manage ODS services, models, extensions, settings, and updates.

### Step 1.2 — Open the ODS chat page

1. Open another browser tab.
2. Enter `http://localhost:3000`.
3. Press **Enter**.
4. Sign in to the existing ODS Open WebUI account if asked.

Use this page to chat with whichever model the workstation ODS `llama-server` is currently serving.

The Open WebUI page is an ODS component, but the authenticated account does have the relevant administrative controls. To see them:

1. Click the profile picture in the upper-left area.
2. Click **Admin Panel**.
3. Click **Settings** in the Admin Panel navigation.
4. Click **Connections**.

The live page shows the internal ODS `llama-server` connection and the native Ollama connection. Do not change or save anything on this page yet.

---

## Part 2 — Confirm the ODS connections and keep the stores separate

There is no model-file collision. Native Ollama owns the conventional host port `11434`. ODS's own llama-server uses host port `11436` and is reached by Open WebUI through Docker's internal network. Both backends can be listed by the same Open WebUI.

The real constraint is GPU memory: only one large model should be resident at a time. Before DeepSeek was removed it consumed approximately 47 GB of the 48 GB GPU; after it was stopped, usage fell to approximately 2.4 GB.

### Step 2.1 — Verify the internal ODS connection

1. In ODS Open WebUI, click your profile picture.
2. Click **Admin Panel**.
3. Click **Settings**.
4. Click **Connections**.
5. Under **OpenAI API**, confirm that one API Base URL is:

```text
http://llama-server:8080/v1
```

6. Do not replace it with an Ollama URL. This is the internal ODS model route.

### Step 2.2 — Verify the native Ollama connection

On the same page:

1. Confirm that the **Ollama API** switch is on.
2. Confirm that at least one URL is:

```text
http://host.docker.internal:11434
```

3. Do not change the URL to `localhost:11434`. From inside the Open WebUI container, `localhost` would mean the container itself, not Windows.
4. Do not click **Save** unless you intentionally changed something.

The duplicate Ollama URL was removed on 2026-08-15. One `http://host.docker.internal:11434` connection remains, and the post-update model selector showed exactly one entry for each installed Ollama model.

### Step 2.3 — Understand which folder each visible model uses

| Model shown in ODS Open WebUI | Backend | File owner |
|---|---|---|
| Models downloaded from ODS Dashboard | ODS `llama-server` | `D:\LocalLLama\ods\data\models` |
| Models downloaded in Ollama Desktop | Native Ollama | The model location selected in Ollama Settings |
| Spark Qwens | Spark LiteLLM/vLLM | DGX Spark; not currently connected to workstation Open WebUI |

Open WebUI is a front end that can combine model lists from multiple API connections. The underlying model files do not need to live in one directory.

### Step 2.4 — Follow the one-resident-model rule

- Downloaded models consume disk space.
- A running model consumes GPU memory.
- The former DeepSeek model has been removed; no large ODS model is resident while the first Gemma downloads.
- Before running a substantial Ollama or LM Studio model, stop the ODS `llama-server` from `http://localhost:3001` and wait for VRAM use to fall.
- Before returning to an ODS model, unload the Ollama or LM Studio model, then start the ODS `llama-server` again.

---

## Part 3 — Use Ollama as the workstation model shelf

Ollama is the canonical workstation model owner. Its models remain in:

```text
D:\LocalLLama\models\ollama
```

Do not click **Download** for these Ollama models in the ODS Dashboard. ODS Open WebUI discovers them through its saved Ollama connection, so the same models can be used in ODS chat without putting GGUF files in `D:\LocalLLama\ods\data\models`.

### Step 3.1 — Confirm Ollama is ready

1. Start **Ollama** from the Windows Start menu.
2. Open Ollama **Settings**.
3. Confirm **Model location** is `D:\LocalLLama\models\ollama`.
4. Do not be alarmed if **Context length** shows **256K**. Ollama selects that default on this 48 GiB GPU; the loaded-model check in Step 3.6 is the authoritative value.
5. Open a normal, non-administrator **PowerShell** window.
6. Run:

```powershell
Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/version'
ollama list
```

**Success looks like:** the version request answers and `gemma3:4b` appears in the model list.

### Step 3.2 — Download Gemma 4 31B through Ollama

This is the dense quality/coding/multilingual model. The exact Ollama tag is:

```text
gemma4:31b-it-qat
```

In PowerShell, run:

```powershell
ollama pull gemma4:31b-it-qat
```

Leave the window open until it reports success. The files go to Ollama's configured model location; they do not go into the ODS folder.

Verify the download without loading the model:

```powershell
ollama list
```

### Step 3.3 — Test Gemma 4 31B in ODS Open WebUI

1. Confirm ODS `llama-server` and LM Studio are not holding a large model in VRAM.
2. Open or refresh `http://localhost:3000`.
3. Open the model selector.
4. Select `gemma4:31b-it-qat`. It should appear once; the duplicate connection was removed on 2026-08-15.
5. Start a new chat and ask:

```text
State your model identity if it is available to you, then write a four-line Python function that returns the larger of two numbers. Explain it in two sentences.
```

6. Wait for the first load; it is slower than later replies.
7. When the test is finished, unload it from PowerShell:

```powershell
ollama stop gemma4:31b-it-qat
```

### Step 3.4 — Download and test Gemma 4 26B-A4B through Ollama

This is the faster MoE creative-writing, translation, summarization, and vision worker. Its exact tag is:

```text
gemma4:26b-a4b-it-qat
```

1. In PowerShell, run:

```powershell
ollama pull gemma4:26b-a4b-it-qat
```

2. Wait for success, then run `ollama list`.
3. Refresh `http://localhost:3000`.
4. Select `gemma4:26b-a4b-it-qat` and use the same test prompt.
5. Record latency and answer quality.
6. Unload it when finished:

```powershell
ollama stop gemma4:26b-a4b-it-qat
```

Both Gemma packages may remain downloaded in the Ollama library. Only the model currently answering requests should occupy most of the GPU memory.

### Step 3.5 — Compare workstation Ollama with Spark correctly

Use the same prompts in two different applications:

1. Test the workstation Gemma in ODS chat at `http://localhost:3000`.
2. Open Hermes Desktop.
3. Select the desired Spark model exposed by Spark LiteLLM, such as `spark-fast` or `qwen27-dflash`.
4. Send the same prompt.
5. Record the results side by side.

This comparison does not require connecting workstation ODS to Spark LiteLLM.

### Step 3.6 — Install and use Qwen 3.8 27B from the same Ollama shelf

This installation was completed and verified on 2026-08-20. Keep these instructions as the exact recovery and daily-use procedure.

The official Ollama tag is:

```text
qwen3.8:27b
```

It is a 27.3B-parameter `Q4_K_M` package with text, vision, thinking, and tool-call support. Ollama reports approximately 17 GB in `ollama list`; the downloaded payload is about 16.52 GiB. It is stored only in `D:\LocalLLama\models\ollama`.

#### A. Download or repair the download

1. Start Ollama Desktop.
2. Open a normal, non-administrator PowerShell window on **Nike-Workstation**.
3. Run:

```powershell
ollama pull qwen3.8:27b
```

4. Leave the window open until it says `success`.
5. If it ends with `unexpected EOF`, run the identical command again. Ollama resumes and verifies its content-addressed layers; do not delete the partial data first.
6. Verify the installed identity:

```powershell
ollama list
ollama show qwen3.8:27b
```

**Success looks like:** one `qwen3.8:27b` row appears, and `ollama show` reports 27.3B parameters, `Q4_K_M`, context length `262144`, and the `vision`, `tools`, and `thinking` capabilities.

#### B. Load it once and check GPU placement

1. In the same PowerShell window, run:

```powershell
ollama run qwen3.8:27b
```

2. Enter a short test prompt, such as:

```text
Write a Python function named square that returns x multiplied by x.
```

3. Press `Ctrl+D` to leave the interactive model prompt.
4. Before the five-minute idle timer unloads it, run:

```powershell
ollama ps
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader
```

The verified workstation result was `100% GPU`, context `262144`, and about 37,890 MiB used out of 48,935 MiB. That leaves roughly 11 GiB of GPU headroom. Do not load another large Ollama, LM Studio, or ODS model beside it.

#### C. Use the same copy in ODS Open WebUI

1. Keep native Ollama running on `127.0.0.1:11434`.
2. Open or refresh `http://localhost:3000`.
3. Open **Select a model**.
4. Choose `qwen3.8:27b`. It should appear exactly once.
5. Send a short test message.

ODS already connects to native Ollama at `http://host.docker.internal:11434`. Do not use the ODS Dashboard's **Download** button for Qwen and do not copy model files into `D:\LocalLLama\ods\data\models`. The verified ODS chat returned the requested response from the single Ollama copy.

#### D. Use it from the Spark Remote Gateway, laptop, and bots

No new provider is required. The existing Spark Hermes provider named **Desktop Ollama via Tailscale** discovers Ollama models dynamically through the workstation's tailnet-only HTTPS route.

In a Spark Remote Gateway Hermes chat, choose:

```text
Desktop Ollama via Tailscale → qwen3.8:27b
```

The equivalent Hermes model identifier is:

```text
custom:desktop-ollama:qwen3.8:27b
```

The provider metadata is already installed in the Spark main and orchestrator profiles with context `262144` and vision enabled. The Windows Local Gateway has matching metadata at its loopback Ollama endpoint. A Spark Hermes one-shot test returned `Hermes Qwen route verified` after the persistent Gateway and Serve services were restarted.

The laptop needs no Ollama installation and no duplicate provider when it uses the recommended **Spark Remote Gateway**. It reads the same Spark provider catalog. Telegram and Discord also use that Spark Gateway; they inherit the model catalog, although sending a representational bot test message still requires your deliberate choice.

#### E. Unload it without deleting it

When finished, run this in workstation PowerShell:

```powershell
ollama stop qwen3.8:27b
ollama ps
ollama list
```

**Success looks like:** `ollama ps` has no running model, while `ollama list` still contains `qwen3.8:27b`. The verified post-test GPU use returned to about 2,082 MiB. Selecting Qwen again in ODS or Hermes automatically reloads it; the first reply will therefore take longer.

---

## Part 4 — Ollama settings and connector-test reference

Ollama is a separate convenience runtime and model library. The authenticated ODS Open WebUI is already configured to query it over an API connection, so Ollama models can appear in the ODS model picker without moving their files into the ODS directory.

### Why the earlier settings did not appear

The environment-variable commands in the old tutorial did not become current-user Windows settings. The live inspection found no saved current-user values for `OLLAMA_MODELS`, `OLLAMA_CONTEXT_LENGTH`, `OLLAMA_KEEP_ALIVE`, or the other variables from that section.

Current Ollama Desktop also has saved application settings for **Model location** and **Context length**. Those app settings can override inherited environment variables. Set these values in the desktop application you will actually use.

### Why Ollama shows 256K context

Ollama automatically selects a 256K default context on NVIDIA GPUs with at least 48 GiB VRAM. Your RTX PRO 5000 reports 48,935 MiB, so it crosses that threshold. This display is expected; it does not prove that a downloaded model is already using a 256K KV cache.

The two Gemmas were initially tested at 16K and later verified at 128K. Qwen 3.8 was verified at the automatic 256K setting and still left about 11 GiB of GPU headroom. Use `ollama ps` while a model is loaded instead of inferring its live context from the settings screen alone.

### Step 4.1 — Set Ollama's model location in the app

1. Start **Ollama** from the Windows Start menu.
2. Open Ollama **Settings**.
3. Find **Model location**.
4. Click **Browse**.
5. Choose or create:

```text
D:\LocalLLama\models\ollama
```

6. Confirm the selection.
7. Allow Ollama to restart its server if prompted.
8. Close Settings, reopen it, and verify that the selected folder is still shown.

Do not choose `D:\LocalLLama\ods\data\models`. Ollama and ODS must keep separate stores.

### Step 4.2 — Verify the live context instead of guessing from the app

1. In Ollama **Settings**, note the displayed **Context length**. The automatic **256K** value is expected on this GPU.
2. Load only the model you want to test.
3. In PowerShell, run `ollama ps`.
4. Read the `CONTEXT` column. This is the live value to record in Hermes.
5. Leave Qwen 3.8 at `262144` while it continues to fit with safe headroom. Reduce context only if a real workload causes memory pressure or instability.

Larger context consumes more memory and can reduce the space available for parallel requests. Never assume every model has the same safe context merely because the application shows one global default.

### Step 4.3 — Keep Ollama on its standard port

Native Ollama intentionally keeps its normal API address:

```text
http://127.0.0.1:11434
```

ODS's optional host-facing llama-server was moved to `127.0.0.1:11436`, while its internal Docker address remains `http://llama-server:8080/v1`. Do not set a custom `OLLAMA_HOST` user variable for this workstation.

Verify the live layout in PowerShell:

```powershell
Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/version'
Get-NetTCPConnection -LocalPort 11434 -State Listen
docker inspect ods-llama-server --format '{{json .HostConfig.PortBindings}}'
```

**Success looks like:** Ollama responds on `11434`, and the stopped ODS container's binding says host port `11436` for container port `8080`.

### Step 4.4 — Decide when Ollama may run

For the simplest and safest workflow:

- the Ollama server may run while Open WebUI is open, because that is how Open WebUI reads the Ollama model list;
- before asking Ollama to load a model, stop the large ODS `llama-server` if it is still consuming most of the GPU;
- after downloading a model in Ollama, refresh ODS Open WebUI or reopen its model selector;
- keep the Ollama files in the Ollama model location even though the model name appears in ODS Open WebUI;
- do not install the ODS Ollama extension in this workstation deployment.

The ODS extension catalog contains an older, separately pinned Ollama package with its own storage and limits. Installing it would create a third Ollama ownership path and make the setup harder to reason about.

### Step 4.5 — Do not duplicate the Ollama models

The two workstation Gemmas and Qwen 3.8 belong to Ollama. Do not download second copies from the ODS Dashboard or LM Studio merely to make them appear in another UI. ODS Open WebUI can already use the Ollama copies through `http://host.docker.internal:11434`.

### Step 4.6 — Connector test already completed

The small connector test was completed on 2026-08-15. The official `gemma3:4b` Ollama tag was downloaded, ran on the GPU with a 16K context, answered successfully in ODS Open WebUI, and was then unloaded. The steps below are retained only for recovery.

1. Open `http://localhost:3001`.
2. Open **Services**.
3. Find `llama-server` or `ods-llama-server`.
4. If an ODS model is running, choose **Stop** so it releases the GPU. The former DeepSeek model has already been stopped and removed.
5. Wait until the Models page says **Model runtime: none** and VRAM use is low.
6. Open Ollama Desktop.
7. In its model search or new-chat model field, search for:

```text
gemma3:4b
```

8. Choose the exact `gemma3:4b` result and download it.
9. If the desktop app does not expose a download control, open workstation PowerShell and use this one fallback command:

```powershell
ollama run gemma3:4b
```

10. Wait for the model to answer once.
11. Leave Ollama running.
12. Open or refresh `http://localhost:3000`.
13. Click **Select a model**.
14. Search for `gemma3:4b`.
15. Select it and send:

```text
Reply with exactly: Ollama connection works.
```

16. `gemma3:4b` should now appear once. If any Ollama model becomes duplicated again, inspect **Admin Panel → Settings → Connections** for a repeated URL instead of downloading or deleting a model.
17. When the test is complete, quit Ollama from its system-tray icon to unload the model.
18. Return to `http://localhost:3001` and start the ODS `llama-server` again.
19. Wait until the ODS model is healthy before returning to normal ODS chat.

---

## Part 5 — Use LM Studio only as the lab layer

LM Studio is useful for temporary GGUF testing, checking fit estimates, using a local OpenAI-compatible API, and LM Link access. It should not remain loaded alongside a large ODS model.

### Step 5.1 — Set the LM Studio model directory

1. Open **LM Studio** on the RTX PRO 5000 workstation.
2. Open **Settings**.
3. Find the model storage or models directory setting.
4. Choose:

```text
D:\LocalLLama\models\lmstudio
```

5. Save the setting.
6. Restart LM Studio if requested.

Do not select either the ODS model folder or the Ollama model folder.

### Step 5.2 — Preserve VRAM before loading an LM Studio model

Before loading a large model in LM Studio:

1. Close native Ollama.
2. Open `http://localhost:3001`.
3. Stop or unload the ODS model service if the Dashboard provides that action.
4. Wait for workstation GPU usage to fall.
5. Load only one LM Studio model.

When the LM Studio test is finished, eject/unload its model before restarting an ODS model.

### Step 5.3 — Download a model through LM Studio

1. Open LM Studio's **Discover** or model search page.
2. Search for the exact model and quantization you want to test.
3. Check the estimated memory requirement.
4. Prefer a quantization that leaves several gigabytes of headroom below 48 GB.
5. Click **Download**.
6. Wait until the download is complete.
7. Open the local chat page and load the model.

Do not download a second copy of an ODS Gemma merely to complete this tutorial. Use LM Studio first for a model or quantization that ODS does not already manage.

### Step 5.4 — Use the LM Studio local server when needed

1. In LM Studio, open the **Developer** page.
2. Select the model to serve.
3. Start the local server.
4. Note the host, port, and model identifier shown by LM Studio.
5. Keep the server bound to the local machine unless you deliberately need LAN access.
6. Stop the server after the test.

This server is separate from ODS, Ollama, and Spark LiteLLM.

### Step 5.5 — Enable LM Link for laptop access

1. Sign in to the same LM Studio account on the workstation and laptop.
2. On the workstation, open LM Studio's **LM Link** controls.
3. Enable sharing for the workstation runtime.
4. Keep just-in-time loading and automatic eviction enabled if the application offers those controls.
5. On the laptop, open LM Studio and select the linked workstation.
6. Send a short test prompt.
7. Verify that inference runs on the workstation, not on the laptop GPU.
8. Unload the linked model when the test is finished.

LM Link is for interactive human access. It does not replace the Spark Hermes Remote Gateway and does not synchronize Hermes skills, providers, tools, or conversations.

---

## Part 6 — Update ODS Open WebUI safely

Do not update the `ods-webui` container independently to an arbitrary Open WebUI `latest` or `main` image. ODS pins its Open WebUI version and connects it to ODS persistence, search, voice, image, and model services.

### Step 6.1 — Use the Dashboard update check

1. Open `http://localhost:3001`.
2. Open **Settings**.
3. Find **Updates**.
4. Click **Check for Updates**.
5. Follow the ODS-provided update path only if it offers an update.

The ODS-supported image update was run successfully on 2026-08-15. It preserved `.env`, `.compose-flags`, the corrected model catalog, Open WebUI data, native Ollama, and the `11436` ODS port binding. The installed package still reports ODS 2.5.3 and pins Open WebUI v0.7.2. The embedded WebUI advertises upstream v0.11.0, but that is not an ODS-managed upgrade; do not click the upstream link or force a standalone image tag.

### Step 6.2 — Know what the recovery command does

If an ODS container image becomes damaged or the Dashboard specifically directs you to refresh the runtime, open PowerShell and run:

```powershell
cd D:\LocalLLama\ods
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\ods.ps1 update
```

This refreshes the versions pinned by the installed ODS source and preserves the persistent Open WebUI data directory. It does not upgrade the ODS source tree or replace the pinned Open WebUI version with an arbitrary newer release.

Do not run this merely to make Ollama models appear in Open WebUI; it will not change the backend architecture.

---

## Part 7 — Your normal daily workflow

### To use a workstation Ollama model in ODS chat

1. Keep the optional ODS `llama-server` stopped unless you deliberately need an ODS-owned GGUF.
2. Make sure LM Studio has no loaded model or running local server.
3. Start native Ollama.
4. Open `http://localhost:3000`.
5. Select the desired downloaded Ollama model.
6. Chat normally.
7. When finished, run `ollama stop MODEL_TAG` or quit Ollama so the model unloads.

### To use a Spark model

1. Open Hermes Desktop.
2. Remain connected to the authenticated Spark Remote Gateway.
3. Select the Spark LiteLLM model alias.
4. Chat through Hermes.

Do not search for the Spark model in workstation ODS.

### To run an optional ODS-owned GGUF later

1. Unload the active Ollama model.
2. Make sure LM Studio has no loaded model.
3. Use ODS Dashboard **Models** only for a model you intentionally want ODS to own separately.
4. Its host API uses port `11436`; Open WebUI still reaches it internally at `http://llama-server:8080/v1`.
5. Stop the ODS `llama-server` after the test so Ollama remains the normal workstation runtime.

### To run an LM Studio experiment

1. Stop or unload the large workstation ODS model.
2. Quit Ollama.
3. Load one model in LM Studio.
4. Run the test or enable LM Link.
5. Unload the model when finished.

---

## Completion checklist

### ODS controls

- [ ] I understand that `localhost:3001` manages ODS and `localhost:3000` is ODS chat.
- [ ] I can see the currently running model in the ODS Dashboard.
- [ ] I know that workstation ODS and Spark ODS are separate deployments.
- [ ] I do not expect Spark LiteLLM models in workstation ODS.

### Workstation models

- [x] `gemma4:31b-it-qat` is downloaded through Ollama and stored in the Ollama model location.
- [x] `gemma4:31b-it-qat` passed a direct Ollama test at 16K context, ran 100% on the GPU, and was unloaded afterward.
- [x] `gemma4:31b-it-qat` has been run and tested at `localhost:3000` through ODS Open WebUI's native Ollama connection.
- [x] `gemma4:26b-a4b-it-qat` is downloaded through Ollama and stored in the Ollama model location.
- [x] `gemma4:26b-a4b-it-qat` passed a direct Ollama test and an ODS Open WebUI test at `localhost:3000`, ran 100% on the GPU at 16K context, and was unloaded afterward.
- [x] `qwen3.8:27b` is downloaded once through Ollama and stored in the Ollama model location.
- [x] `qwen3.8:27b` passed local text, structured-tool, vision-path, ODS Open WebUI, Spark Tailscale, and Spark Hermes route tests at its live 256K context.
- [x] `qwen3.8:27b` ran 100% on the GPU, used about 37,890 MiB, and was unloaded without deleting it.
- [x] Only one large workstation model is resident at a time during these tests.

### Ollama

- [x] Ollama's app settings show `D:\LocalLLama\models\ollama` as its own model location.
- [x] Qwen 3.8's loaded-model check reports context `262144`; its matching Hermes metadata is installed.
- [ ] I understand why the automatic default was 256K on a 48 GiB GPU.
- [x] Native Ollama responds at its conventional `http://127.0.0.1:11434` API.
- [x] ODS's optional stopped llama-server is reserved at host port `11436`.
- [x] Admin Panel → Settings → Connections shows the Ollama API at `http://host.docker.internal:11434`.
- [x] The duplicate Ollama connection was removed; each installed Ollama model appears once in Open WebUI.
- [x] `gemma3:4b` has been downloaded as the small connector test.
- [x] `gemma3:4b` appeared in the ODS Open WebUI model selector during the connector test.
- [x] I unload one runtime's large model before loading another runtime's model.

### LM Studio

- [ ] LM Studio uses `D:\LocalLLama\models\lmstudio`.
- [ ] One non-duplicated lab model has been tested when needed.
- [ ] The local server is stopped when it is not needed.
- [ ] LM Link has been tested from the laptop if remote lab access is desired.

### Updates and safety

- [x] The ODS-supported image update completed; persistent configuration was verified afterward.
- [ ] Open WebUI was not independently replaced with an upstream `latest` image.
- [ ] The ODS, Ollama, and LM Studio model stores remain separate.

## References

- [ODS repository](https://github.com/Osmantic/ODS)
- [Ollama on Windows: changing the model location](https://docs.ollama.com/windows#changing-model-location)
- [Ollama context length](https://docs.ollama.com/context-length)
- [Official Ollama `gemma3:4b` entry](https://ollama.com/library/gemma3:4b)
- [[ODS Workstation Ollama Integration Research]]
