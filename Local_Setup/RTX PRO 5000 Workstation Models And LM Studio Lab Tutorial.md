# RTX PRO 5000 Workstation Ollama Models And LM Studio Lab Tutorial

> [!danger] Superseded on 2026-08-15
> Do not continue with this version. Live inspection showed that it treated Windows environment variables as authoritative over Ollama Desktop, mixed the runtime model stores, and treated Spark LiteLLM as part of workstation ODS. Use [[RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial]] instead. The replacement explains the active Ollama API connection and the separate ODS, Ollama, LM Studio, and Spark ownership boundaries.

This is the beginner, line-by-line tutorial for **Step 2**, **Step 3**, and **Step 4** in [[Local Setup Index]]. It starts with native Windows Ollama installation and the ODS Open WebUI connection, then adds the workstation models, and finally configures LM Studio and LM Link. It covers:

1. installing and testing the two workstation Gemma models with native Windows Ollama;
2. comparing each workstation model with the existing `spark-fast` model;
3. configuring LM Studio and LM Link as an experimental lab layer;
4. keeping Ollama, LM Studio, ODS, and Spark from duplicating or competing with one another.

## Confirmed starting point

This tutorial assumes the following facts are already true:

- the workstation runs Windows;
- the GPU is **NVIDIA RTX PRO 5000 Blackwell**, with **48,935 MiB VRAM**, compute capability **12.0**, and NVIDIA driver **596.59**;
- ODS Open WebUI and SearXNG run on the workstation;
- Hermes Gateway, Hermes Serve, the authoritative LiteLLM, and both working Qwen services run on DGX Spark;
- Tailscale is already installed on the workstation, laptop, and Spark;
- the ODS Hermes module remains disabled.

Ollama officially lists the RTX PRO 5000 Blackwell under its supported compute-capability 12.0 NVIDIA professional GPUs, and requires an NVIDIA driver version 550 or newer. Your verified GPU and driver satisfy both conditions. See [Ollama hardware support](https://docs.ollama.com/gpu) and the [NVIDIA RTX PRO 5000 Blackwell datasheet](https://www.nvidia.com/content/dam/en-zz/Solutions/products/workstations/professional-desktop-gpus/rtx-pro-5000-blackwell/workstation-datasheet-blackwell-rtx-pro-5000-gtc25-spring-nvidia-3658700.pdf).

> [!important] Downloaded is not the same as loaded
> Both Gemma models may remain **downloaded on the SSD at the same time**. Downloaded files consume disk space but do not consume 20–40 GB of VRAM merely by existing. Only the model currently serving a request is **loaded** into VRAM. This guide limits Ollama to **one loaded model at a time** and explicitly unloads each model after its test.

## Final ownership after this tutorial

| Layer | Owner | What belongs there |
|---|---|---|
| Persistent agents | DGX Spark | Hermes Gateway and Hermes Serve |
| Canonical routing | DGX Spark | LiteLLM and the existing Qwen aliases |
| Human UI and search | Workstation ODS | Open WebUI and SearXNG |
| Stable workstation model shelf | Native Windows Ollama | Gemma 4 31B and Gemma 4 26B-A4B |
| Temporary experiment bench | Workstation LM Studio | A small lab test model, later experimental GGUFs, and LM Link |

Do not install another Hermes instance. Do not download the working Spark Qwens into Ollama or LM Studio during this tutorial.

---

## Part 1 — Learn which terminal to use

The instructions will explicitly name one of these locations before every action:

- **Workstation PowerShell** means Windows Terminal or PowerShell on the RTX PRO 5000 desktop.
- **Workstation browser** means a browser on that same desktop.
- **Workstation Open WebUI** means the existing ODS Open WebUI website.
- **Workstation LM Studio** means the graphical LM Studio application on the desktop.
- **Laptop LM Studio** means the graphical LM Studio application on the laptop.
- **Spark terminal** means an SSH/NVIDIA Sync terminal connected to DGX Spark.

Unless a step explicitly says otherwise, do not run these commands in the Spark terminal, WSL, Command Prompt, or an ODS Docker container.

---

## Part 2 — Choose permanent model directories

Ollama and LM Studio use different model formats and stores. Give each runtime its own directory.

This guide uses:

```text
D:\LocalLLama\models\ollama
D:\LocalLLama\models\lmstudio
```

Do not point both programs at the same directory. Do not put the models inside the ODS application-data or Docker-volume directories.

### Step 2.1 — Check free space

Open **Workstation PowerShell**.

Copy and run:

```powershell
Get-Volume | Sort-Object DriveLetter | Format-Table DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Size
```

Look for drive `D:`. For this initial model shelf, keep at least **100 GB free** so that the two Gemmas, a small LM Studio test model, updates, and temporary files have breathing room.

If `D:` does not exist or does not have enough free space, stop here. Replace `D:` in every later path with a large NTFS SSD drive that does have enough space.

### Step 2.2 — Create the two directories

Still in **Workstation PowerShell**, copy and run this block:

```powershell
$OllamaModelDir = 'D:\LocalLLama\models\ollama'
$LmStudioModelDir = 'D:\LocalLLama\models\lmstudio'

New-Item -ItemType Directory -Force -Path $OllamaModelDir | Out-Null
New-Item -ItemType Directory -Force -Path $LmStudioModelDir | Out-Null

Get-Item -LiteralPath $OllamaModelDir
Get-Item -LiteralPath $LmStudioModelDir
```

Success looks like PowerShell printing both directories without an error.

- [x] Both directories exist on a large SSD.
- [x] The two programs have separate directories.

---

## Part 3 — Install and configure native Windows Ollama

Ollama is the **service of record** for workstation models. It will start with Windows and provide the local API used by ODS Open WebUI.

Ollama's official Windows installer runs without administrator access, installs into the user account, runs in the background, and serves its API at `http://localhost:11434`. See [Ollama for Windows](https://docs.ollama.com/windows).

### Step 3.1 — Set the model directory and one-model policy

Do this **before downloading a model**.

If Ollama is already installed and visible in the Windows system tray:

1. Right-click the Ollama tray icon.
2. Click **Quit Ollama**.
3. Wait five seconds.

Now open a fresh **Workstation PowerShell** window and run:

```powershell
$OllamaModelDir = 'D:\LocalLLama\models\ollama'

[Environment]::SetEnvironmentVariable('OLLAMA_MODELS', $OllamaModelDir, 'User')
[Environment]::SetEnvironmentVariable('OLLAMA_MAX_LOADED_MODELS', '1', 'User')
[Environment]::SetEnvironmentVariable('OLLAMA_NUM_PARALLEL', '1', 'User')
[Environment]::SetEnvironmentVariable('OLLAMA_KEEP_ALIVE', '5m', 'User')
[Environment]::SetEnvironmentVariable('OLLAMA_CONTEXT_LENGTH', '16384', 'User')
[Environment]::SetEnvironmentVariable('OLLAMA_FLASH_ATTENTION', '1', 'User')
```

These settings mean:

| Variable | Meaning |
|---|---|
| `OLLAMA_MODELS` | Put downloads in the explicit `D:` directory |
| `OLLAMA_MAX_LOADED_MODELS=1` | Keep at most one model resident |
| `OLLAMA_NUM_PARALLEL=1` | Start with one request at a time so context memory is predictable |
| `OLLAMA_KEEP_ALIVE=5m` | Automatically unload an idle model after five minutes |
| `OLLAMA_CONTEXT_LENGTH=16384` | Use a safe initial 16K-token default rather than allocating a huge context |
| `OLLAMA_FLASH_ATTENTION=1` | Enable the supported attention-memory optimization |

Ollama documents these controls in its [official FAQ](https://docs.ollama.com/faq). A larger context consumes more VRAM, and parallel requests multiply the context-memory requirement. Do not start at the models' theoretical 256K context on a 48 GB card.

Verify the saved user variables:

```powershell
'OLLAMA_MODELS','OLLAMA_MAX_LOADED_MODELS','OLLAMA_NUM_PARALLEL','OLLAMA_KEEP_ALIVE','OLLAMA_CONTEXT_LENGTH','OLLAMA_FLASH_ATTENTION' |
    ForEach-Object {
        [PSCustomObject]@{
            Name  = $_
            Value = [Environment]::GetEnvironmentVariable($_, 'User')
        }
    } | Format-Table -AutoSize
```

Expected values are the six values shown in the table above.

> [!warning] Do not set `OLLAMA_HOST=0.0.0.0`
> The raw Ollama API has no local authentication requirement. Keep it on the Windows host and let Open WebUI reach it through Docker's host gateway. Do not expose port 11434 to the LAN or Internet for this setup.

### Step 3.2 — Install Ollama

Use the **Workstation browser**:

1. Open [the official Ollama download page](https://ollama.com/download/windows).
2. Download the Windows installer.
3. Run `OllamaSetup.exe`.
4. Accept the normal per-user installation.
5. Let the installer finish.
6. Open the Windows Start menu.
7. Search for **Ollama** and launch it once.

If Ollama was already installed, do not reinstall it. Launch it again from the Start menu so it inherits the environment variables saved in Step 3.1.

Close the old PowerShell window and open a **new Workstation PowerShell** window. This matters because an already-open terminal may not see the new environment variables.

Run:

```powershell
Get-Command ollama
ollama --version
```

Write the version shown here for your test record:

```text
Ollama version tested: ____________________
Date tested: ____________________
```

### Step 3.3 — Verify the empty Ollama server

In **Workstation PowerShell**, run:

```powershell
Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/version'
ollama ls
ollama ps
```

Success means:

- the API prints a version;
- `ollama ls` may be empty before the first download;
- `ollama ps` has no loaded models.

Also verify that Ollama is listening locally:

```powershell
Get-NetTCPConnection -LocalPort 11434 -State Listen | Format-Table LocalAddress, LocalPort, OwningProcess
```

- [x] `ollama --version` works.
- [x] `http://127.0.0.1:11434/api/version` responds.
- [x] `ollama ps` is empty before testing.

---

## Part 4 — Connect workstation Open WebUI to workstation Ollama

The existing ODS Open WebUI runs in Docker. Inside that container, `localhost` refers to the container itself, not Windows. Open WebUI officially documents this host connection address:

```text
http://host.docker.internal:11434
```

See the [Open WebUI Ollama connection guide](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-ollama/).

### Step 4.1 — Add the connection

Open **Workstation Open WebUI** in the browser, then:

1. Sign in with the existing administrator account.
2. Open **Admin Settings**.
3. Open **Connections**.
4. Find **Ollama**.
5. Click **Manage** or the wrench icon.
6. Add or edit the workstation Ollama connection.
7. Enter this URL exactly:

   ```text
   http://host.docker.internal:11434
   ```

8. If the screen offers **Prefix ID**, enter:

   ```text
   local/
   ```

9. Leave **Model IDs (Filter)** empty for now.
10. Save the connection.

Do not enter an API key for local Ollama unless your specific ODS configuration explicitly requires a placeholder value. Ollama's local endpoint itself does not require one.

### Step 4.2 — Preserve the Spark connection

Do not replace or edit the existing Spark LiteLLM connection. Open WebUI should ultimately show two clearly different sources:

- `local/…` for workstation Ollama models;
- `spark/…` for Spark LiteLLM models such as `spark-fast`.

SearXNG remains the existing ODS search backend. Nothing in this tutorial changes it.

### Step 4.3 — Verify the connection before downloading models

Refresh Open WebUI. It is normal for the new Ollama connection to have no models yet.

If Open WebUI says it cannot connect, return to **Workstation PowerShell** and rerun:

```powershell
Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/version'
```

- If this fails, Ollama is not running. Launch Ollama from the Start menu.
- If this succeeds, recheck that Open WebUI uses `host.docker.internal`, not `localhost` or `127.0.0.1`.

- [ ] Open WebUI has a `local/` Ollama connection.
- [ ] The existing `spark/` LiteLLM connection is unchanged.

---

## Part 5 — Download and test Gemma 4 31B

The exact initial tag is:

```text
gemma4:31b-it-qat
```

Ollama's current official entry identifies this as a 30.7B dense `Q4_0` QAT package of approximately 19 GB. See [Ollama Gemma 4 31B QAT](https://ollama.com/library/gemma4:31b-it-qat). Google's official Gemma 4 documentation describes the 31B dense model as the higher-quality workstation/server member of the family, with text and image input. See [Google's Gemma 4 overview](https://ai.google.dev/gemma/docs/core).

### Step 5.1 — Confirm that no model is loaded

In **Workstation PowerShell**, run:

```powershell
ollama ps
nvidia-smi --query-gpu=name,memory.total,memory.used,memory.free,utilization.gpu --format=csv
```

`ollama ps` should be empty. Other Windows programs may use some VRAM, so the NVIDIA reading does not need to be exactly zero.

### Step 5.2 — Download the 31B model

Still in **Workstation PowerShell**, run:

```powershell
ollama pull gemma4:31b-it-qat
```

The download can take time. Leave this PowerShell window open until it reaches 100% and reports success.

This command downloads weights to disk. It does **not** need to keep the model loaded in VRAM.

Verify the exact installed name:

```powershell
ollama ls
ollama show gemma4:31b-it-qat
ollama ps
```

Record what Ollama reports:

```text
Model tag: gemma4:31b-it-qat
Reported size: ____________________
Reported context: ____________________
Ollama version: ____________________
```

### Step 5.3 — Run the first direct test

Copy this into **Workstation PowerShell**:

```powershell
$ComparisonPrompt = @'
You are being evaluated as a local project assistant. Complete all three tasks concisely:
1. Explain in four bullets why downloading a model is different from loading it into VRAM.
2. Write a PowerShell function named Get-LargeFiles that accepts a Path and returns the ten largest files beneath it without deleting or changing anything.
3. Translate this sentence into natural German: "The project is ready for review, but the deployment still needs approval."
Do not use web search or external tools.
'@

ollama run gemma4:31b-it-qat $ComparisonPrompt
```

Wait for the entire answer. Then run:

```powershell
ollama ps
nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu --format=csv
```

In `ollama ps`, check the **PROCESSOR** column. The target is `100% GPU`. Ollama documents this exact verification method in its [official FAQ](https://docs.ollama.com/faq).

If it reports a CPU/GPU split, do not assume the setup is finished. First close other GPU-heavy applications, unload the model, and try again.

### Step 5.4 — Test the same model through Open WebUI

Open **Workstation Open WebUI**:

1. Start a new chat.
2. Select `local/gemma4:31b-it-qat`. If no prefix is displayed, select the exact tag `gemma4:31b-it-qat` from the Ollama connection.
3. Turn off web search, tools, and document attachments for this comparison.
4. If you changed generation controls, use the same values for every model. Otherwise leave the model defaults alone.
5. Paste the exact three-part comparison prompt from Step 5.3.
6. Send it once.
7. Save the answer in the chat history under a descriptive title such as `Gemma 4 31B workstation comparison`.

### Step 5.5 — Compare against Spark Qwen with the same prompt

Still in **Workstation Open WebUI**:

1. Start another new chat so the Gemma response is not in the context.
2. Select the existing Spark LiteLLM model `spark-fast` or its displayed `spark/spark-fast` name.
3. Keep web search, tools, and attachments off.
4. Paste the **same prompt without changing a word**.
5. Send it once.
6. Save this chat as `spark-fast comparison`.

Use this simple scorecard:

| Criterion | Gemma 4 31B | `spark-fast` |
|---|---:|---:|
| Followed all three instructions, 1–5 |  |  |
| PowerShell code correctness, 1–5 |  |  |
| German translation quality, 1–5 |  |  |
| Concision and formatting, 1–5 |  |  |
| Subjective response speed, 1–5 |  |  |

This is a smoke comparison, not a scientific benchmark. It confirms that both routing paths work and exposes obvious strengths or failures.

### Step 5.6 — Unload the 31B model

Return to **Workstation PowerShell** and run:

```powershell
ollama stop gemma4:31b-it-qat
Start-Sleep -Seconds 3
ollama ps
nvidia-smi --query-gpu=name,memory.used,memory.free --format=csv
```

Success means `ollama ps` no longer lists the model. The 20 GB download remains safely on disk.

- [ ] The exact 31B tag is downloaded.
- [ ] Direct Ollama inference works.
- [ ] `ollama ps` reported GPU execution.
- [ ] Open WebUI inference works.
- [ ] The same prompt was compared with `spark-fast`.
- [ ] The 31B model was unloaded after testing.

---

## Part 6 — Download and test Gemma 4 26B-A4B

The exact initial tag is:

```text
gemma4:26b-a4b-it-qat
```

Ollama's official entry identifies it as a 25.2B-total, Q4_0 QAT package of approximately 16 GB. See [Ollama Gemma 4 26B-A4B QAT](https://ollama.com/library/gemma4:26b-a4b-it-qat). Google describes the model as a mixture-of-experts model with about 3.8B active parameters, while still requiring all model weights to remain available in memory. See [Google's Gemma 4 model overview](https://ai.google.dev/gemma/docs/core).

This model is intended as the faster workstation option for creative writing, translation, summarization, image work, and responsive project assistance.

### Step 6.1 — Confirm that 31B is not loaded

In **Workstation PowerShell**, run:

```powershell
ollama ps
```

If `gemma4:31b-it-qat` is still listed, run:

```powershell
ollama stop gemma4:31b-it-qat
```

### Step 6.2 — Download the 26B-A4B model

Run:

```powershell
ollama pull gemma4:26b-a4b-it-qat
```

Wait for completion. Then verify:

```powershell
ollama ls
ollama show gemma4:26b-a4b-it-qat
ollama ps
```

At this point both large models should be **downloaded together on disk**, but neither needs to be loaded.

Record what Ollama reports:

```text
Model tag: gemma4:26b-a4b-it-qat
Reported size: ____________________
Reported context: ____________________
Ollama version: ____________________
```

### Step 6.3 — Run the same direct comparison prompt

In **Workstation PowerShell**, recreate the exact prompt and run it:

```powershell
$ComparisonPrompt = @'
You are being evaluated as a local project assistant. Complete all three tasks concisely:
1. Explain in four bullets why downloading a model is different from loading it into VRAM.
2. Write a PowerShell function named Get-LargeFiles that accepts a Path and returns the ten largest files beneath it without deleting or changing anything.
3. Translate this sentence into natural German: "The project is ready for review, but the deployment still needs approval."
Do not use web search or external tools.
'@

ollama run gemma4:26b-a4b-it-qat $ComparisonPrompt
```

Verify residency and GPU execution:

```powershell
ollama ps
nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu --format=csv
```

### Step 6.4 — Test through Open WebUI

In **Workstation Open WebUI**:

1. Start a fresh chat.
2. Select `local/gemma4:26b-a4b-it-qat` or the unprefixed exact tag if that is how ODS displays it.
3. Keep search, tools, and attachments off.
4. Paste the identical comparison prompt.
5. Send it once.
6. Save the chat as `Gemma 4 26B-A4B workstation comparison`.

Add a third column to the scorecard from Part 5 and score the 26B-A4B response.

### Step 6.5 — Unload it

Return to **Workstation PowerShell**:

```powershell
ollama stop gemma4:26b-a4b-it-qat
Start-Sleep -Seconds 3
ollama ps
nvidia-smi --query-gpu=name,memory.used,memory.free --format=csv
```

### Step 6.6 — Verify the final Ollama shelf state

Run:

```powershell
ollama ls
ollama ps
Get-ChildItem -LiteralPath 'D:\LocalLLama\models\ollama' -Force | Select-Object Name, LastWriteTime
```

The intended final state is:

- `ollama ls` lists both exact Gemma tags;
- `ollama ps` is empty after the tests;
- the model store contains data on `D:`;
- Open WebUI lists both local models;
- Spark Qwen remains available through the separate `spark/` connection.

- [ ] The exact 26B-A4B tag is downloaded.
- [ ] Direct Ollama inference works.
- [ ] `ollama ps` reported GPU execution.
- [ ] Open WebUI inference works.
- [ ] The same prompt was compared with 31B and `spark-fast`.
- [ ] The 26B-A4B model was unloaded after testing.
- [ ] Both large models remain downloaded on disk.
- [ ] No large model remains loaded unnecessarily.

---

## Part 7 — Understand the normal Ollama daily workflow

Open **Workstation PowerShell** and use these commands whenever you need them.

List models downloaded on disk:

```powershell
ollama ls
```

List models currently loaded into memory:

```powershell
ollama ps
```

Use 31B for a quality-oriented task:

```powershell
ollama run gemma4:31b-it-qat
```

Use 26B-A4B for a faster task:

```powershell
ollama run gemma4:26b-a4b-it-qat
```

Exit an interactive Ollama session with:

```text
/bye
```

Unload 31B without deleting it:

```powershell
ollama stop gemma4:31b-it-qat
```

Unload 26B-A4B without deleting it:

```powershell
ollama stop gemma4:26b-a4b-it-qat
```

Do not use `ollama rm` as an unload command. `ollama rm` deletes the downloaded model and requires another large download if you change your mind.

When starting a GPU-heavy training job or LM Studio experiment:

1. stop both known Ollama models;
2. run `ollama ps` and confirm it is empty;
3. run `nvidia-smi` and confirm VRAM has been released;
4. only then start the other workload.

---

## Part 8 — Install LM Studio as the lab layer

LM Studio is not the permanent model shelf. Use it for:

- temporary GGUF testing;
- estimating whether a model fits before loading;
- comparing unusual quantizations;
- testing very new models such as Muse after runtime support is confirmed;
- LM Link access from the laptop;
- project-specific experiments that should not become permanent Ollama services.

Do not download Gemma 4 31B or Gemma 4 26B-A4B again in LM Studio. Ollama already owns those two models.

LM Studio supports Windows x64, recommends at least 16 GB RAM and 4 GB VRAM, and includes the `lms` command-line utility after the application has been run. See [LM Studio system requirements](https://lmstudio.ai/docs/app/system-requirements) and [the official `lms` guide](https://lmstudio.ai/docs/cli).

### Step 8.1 — Check whether LM Studio is already installed

In **Workstation PowerShell**, run:

```powershell
Get-Command lms -ErrorAction SilentlyContinue
```

- If it prints a command path, LM Studio is already installed. Open the graphical app once and continue to Step 8.3.
- If it prints nothing, continue to Step 8.2.

### Step 8.2 — Install LM Studio on the workstation

Use the **Workstation browser**:

1. Open [the official LM Studio download page](https://lmstudio.ai/download).
2. Download the Windows x64 installer.
3. Run the installer.
4. Finish the normal installation.
5. Open **LM Studio** from the Windows Start menu.
6. Wait until the main screen fully opens.

Close the old PowerShell window and open a **new Workstation PowerShell** window.

Run:

```powershell
lms --help
lms ls
lms ps
```

Success means `lms --help` shows the CLI commands. `lms ls` may initially be empty, and `lms ps` should show no loaded model.

### Step 8.3 — Set the LM Studio model directory

In **Workstation LM Studio**:

1. Open **My Models**.
2. Find the model-directory setting or folder control.
3. Change the models directory to:

   ```text
   D:\LocalLLama\models\lmstudio
   ```

4. Confirm or save the change.

LM Studio officially supports changing this directory from **My Models**. See [Download an LLM in LM Studio](https://lmstudio.ai/docs/app/basics/download-model).

Return to **Workstation PowerShell** and run:

```powershell
lms ls
```

Do not point LM Studio at `D:\LocalLLama\models\ollama`. Ollama's content-addressed blob store is not an LM Studio GGUF library.

- [ ] LM Studio is installed and opens.
- [ ] `lms --help` works.
- [ ] LM Studio uses its own `D:` model directory.
- [ ] No Gemma model was downloaded a second time.

---

## Part 9 — Download one small lab-only smoke model

The initial LM Studio model should be deliberately different from the permanent Ollama shelf. Use the small catalog model that LM Studio itself uses in its current API documentation:

```text
ibm/granite-4-micro
```

This model is only a smoke test for downloading, loading, the local API, and LM Link. It is not replacing Gemma or `spark-fast`.

### Step 9.1 — Confirm that Ollama is empty

In **Workstation PowerShell**, run:

```powershell
ollama stop gemma4:31b-it-qat
ollama stop gemma4:26b-a4b-it-qat
ollama ps
```

It is acceptable if an `ollama stop` command says the model was not running. The final `ollama ps` output should be empty.

### Step 9.2 — Download the lab model

Use **Workstation LM Studio**:

1. Open **Discover**.
2. Search for this exact catalog identifier:

   ```text
   ibm/granite-4-micro
   ```

3. Choose a **GGUF Q4_K_M** option.
4. Check the displayed download size and confirm it is a small lab model, not a 20–60 GB Gemma or Qwen.
5. Click **Download**.
6. Wait for the download to complete.

LM Studio documents `ibm/granite-4-micro` as a valid catalog identifier in its [model download API](https://lmstudio.ai/docs/developer/rest/download). Its general model guide recommends a 4-bit or higher quantization on capable hardware. See [LM Studio model downloads](https://lmstudio.ai/docs/app/basics/download-model).

Verify in **Workstation PowerShell**:

```powershell
lms ls
lms ps
```

Copy the exact model key shown by `lms ls` into this field:

```text
LM Studio Granite model key: ______________________________
```

The later commands use `ibm/granite-4-micro`. If `lms ls` prints a longer or slightly different key, replace `ibm/granite-4-micro` in the later `lms load` commands with the exact key printed on your computer.

---

## Part 10 — Estimate, load, and automatically unload the lab model

LM Studio can estimate memory without loading a model. Use that feature before every unfamiliar 20–40 GB experiment.

### Step 10.1 — Estimate memory without loading

In **Workstation PowerShell**, run:

```powershell
lms load ibm/granite-4-micro --estimate-only --gpu max --context-length 16384
```

If your exact key differs, replace only `ibm/granite-4-micro` with the key recorded in Step 9.2.

An estimate does not load the model. Confirm:

```powershell
lms ps
```

### Step 10.2 — Load it with a stable API name and 30-minute TTL

Run:

```powershell
lms load ibm/granite-4-micro --identifier lab-granite --gpu max --context-length 16384 --ttl 1800
```

Then verify:

```powershell
lms ps
nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu --format=csv
```

`--ttl 1800` means LM Studio may unload this manually loaded model after 1,800 seconds, or 30 minutes, of inactivity. LM Studio documents `--estimate-only`, GPU offload, context length, identifiers, and TTL in the [`lms load` reference](https://lmstudio.ai/docs/cli/local-models/load).

### Step 10.3 — Start the local LM Studio API

In **Workstation PowerShell**, run:

```powershell
lms server start --port 1234
lms server status
```

Verify the OpenAI-compatible model list:

```powershell
Invoke-RestMethod -Uri 'http://127.0.0.1:1234/v1/models'
```

### Step 10.4 — Send a test API request

Copy this whole block into **Workstation PowerShell**:

```powershell
$LmRequest = @{
    model = 'lab-granite'
    messages = @(
        @{
            role = 'user'
            content = 'Reply with exactly: LM_STUDIO_API_OK'
        }
    )
    temperature = 0
    stream = $false
} | ConvertTo-Json -Depth 6

$LmResponse = Invoke-RestMethod `
    -Method Post `
    -Uri 'http://127.0.0.1:1234/v1/chat/completions' `
    -ContentType 'application/json' `
    -Body $LmRequest

$LmResponse.choices[0].message.content
```

Success looks like:

```text
LM_STUDIO_API_OK
```

LM Studio documents the OpenAI-compatible server and `localhost:1234` workflow in [LM Studio, llmster, and lms](https://lmstudio.ai/docs/app/basics/lmstudio-vs-llmster-vs-lms).

- [ ] The estimate completed without loading.
- [ ] The model loaded as `lab-granite`.
- [ ] `lms ps` listed only the intended model.
- [ ] The local API returned `LM_STUDIO_API_OK`.

---

## Part 11 — Configure JIT loading, TTL, and Auto-Evict

These controls make LM Studio suitable for experiments without leaving old models resident.

In **Workstation LM Studio**:

1. Open the **Developer** tab.
2. Open **Server Settings**.
3. Ensure **Just-In-Time model loading** is enabled.
4. Set the default idle TTL to **30 minutes** if the interface offers the setting.
5. Ensure **Auto-Evict** is enabled.
6. Keep the server bound to the local machine for now. Do not expose it publicly.

LM Studio's current defaults are:

- JIT loading: enabled;
- JIT idle TTL: 60 minutes;
- Auto-Evict: enabled;
- at most one JIT-loaded model kept resident when Auto-Evict is enabled.

This guide shortens the lab TTL to 30 minutes. See [LM Studio Idle TTL and Auto-Evict](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict).

> [!note] Auto-Evict applies to JIT-loaded models
> A model you manually load may not be treated exactly like a JIT-loaded model. That is why this guide also supplies `--ttl 1800` and uses `lms unload --all` at the end of a lab session.

### Step 11.1 — Unload the manual test

In **Workstation PowerShell**, run:

```powershell
lms unload --all
lms ps
nvidia-smi --query-gpu=name,memory.used,memory.free --format=csv
```

Leave the API server running only if you will immediately test LM Link. Otherwise stop it:

```powershell
lms server stop
```

- [ ] JIT loading is enabled.
- [ ] Auto-Evict is enabled.
- [ ] Default lab TTL is understood or set to 30 minutes.
- [ ] `lms unload --all` releases the lab model.

---

## Part 12 — Enable LM Link between workstation and laptop

LM Link provides a separate, end-to-end encrypted device network built with Tailscale technology. LM Studio states that it coexists with an existing personal Tailscale VPN without interference. It does not expose Windows files, the operating system, Hermes, ODS, or other services. See the [LM Link FAQ](https://lmstudio.ai/docs/lmlink/basics/faq).

You do not need to create another personal Tailscale node or change the Spark tailnet for this step.

### Step 12.1 — Enable LM Link on the workstation

In **Workstation LM Studio**:

1. Sign into your LM Studio account.
2. Open **LM Link** in the sidebar.
3. Follow the prompt to create or enable your Link.
4. Give the device a clear name such as:

   ```text
   Nike-Workstation
   ```

5. Leave LM Studio running.

If you prefer to verify from **Workstation PowerShell**, run:

```powershell
lms link status
```

Do not paste login URLs, device codes, cookies, or account tokens into this note.

### Step 12.2 — Install or open LM Studio on the laptop

On the **laptop**, use its browser:

1. Open [the official LM Studio download page](https://lmstudio.ai/download).
2. Install the correct LM Studio build if it is not already installed.
3. Open LM Studio.
4. Sign into the **same LM Studio account** used on the workstation.
5. Open **LM Link** in the sidebar.
6. Enable LM Link.

LM Studio's official [Add a Device guide](https://lmstudio.ai/docs/lmlink/basics/add-device) says linked GUI devices discover one another automatically after LM Link is enabled.

### Step 12.3 — Verify that the workstation appears

In **Laptop LM Studio**:

1. Wait for `Nike-Workstation`, or the name you selected, to appear.
2. Confirm that it shows as connected.
3. Open the model loader.
4. Filter for remote models if the loader offers that option.
5. Confirm that the workstation's Granite lab model appears with the workstation device name.
6. If LM Studio offers a **Preferred device** option, choose the RTX workstation for this test.

If the device does not appear:

1. keep LM Studio open on both computers;
2. confirm both use the same LM Studio account;
3. confirm LM Link is enabled on both;
4. update LM Studio on both devices;
5. rerun `lms link status` on the workstation.

Do not expose port 1234 to the LAN as a workaround.

### Step 12.4 — Run a remote chat from the laptop

In **Laptop LM Studio**:

1. Select the Granite model entry associated with the workstation.
2. Load it with a modest context such as 16,384 tokens.
3. Send:

   ```text
   Reply with exactly: LM_LINK_WORKSTATION_OK
   ```

4. Wait for the response.

On the **workstation**, open PowerShell and verify that the workstation GPU handled the model:

```powershell
lms ps
nvidia-smi --query-gpu=name,memory.used,memory.free,utilization.gpu --format=csv
```

Success means the laptop displayed `LM_LINK_WORKSTATION_OK` while the workstation showed the loaded model and increased GPU use.

LM Studio documents that remote Link models can be used as though they were local and can be reached through the local LM Studio API at `localhost:1234`. See the [LM Link FAQ](https://lmstudio.ai/docs/lmlink/basics/faq).

### Step 12.5 — End the remote test cleanly

In **Workstation PowerShell**, run:

```powershell
lms unload --all
lms ps
```

If no application needs the workstation LM Studio API now, run:

```powershell
lms server stop
```

- [ ] Workstation LM Link is enabled.
- [ ] Laptop LM Link is enabled under the same account.
- [ ] The workstation appears as a connected device.
- [ ] The laptop can use the workstation's lab model.
- [ ] The workstation GPU handled the remote request.
- [ ] The model was unloaded after the test.

---

## Part 13 — Optional Open WebUI connection to LM Studio

This connection is optional and should be enabled only during a lab session. Ollama remains the permanent local ODS provider.

### Step 13.1 — Start the LM Studio server

In **Workstation PowerShell**:

```powershell
lms server start --port 1234
lms server status
```

### Step 13.2 — Add the temporary OpenAI-compatible connection

In **Workstation Open WebUI**:

1. Open **Admin Settings**.
2. Open **Connections**.
3. Add an **OpenAI-compatible** connection.
4. Enter this Base URL:

   ```text
   http://host.docker.internal:1234/v1
   ```

5. If an API-key field is mandatory, enter the harmless placeholder:

   ```text
   lm-studio
   ```

6. If the screen offers a prefix, enter:

   ```text
   lab/
   ```

7. Save.

Do not replace the `local/` Ollama or `spark/` LiteLLM connections.

When the lab session ends:

1. disable the `lab/` connection in Open WebUI so a stopped server does not delay model-list refreshes;
2. run `lms unload --all`;
3. run `lms server stop`.

---

## Part 14 — Avoid duplicate model files

Follow this ownership table:

| Model or type | Download with | Do not duplicate in |
|---|---|---|
| Gemma 4 31B QAT | Ollama | LM Studio |
| Gemma 4 26B-A4B QAT | Ollama | LM Studio |
| Existing Qwen `spark-fast` and Qwen 27 DFlash | Spark Hugging Face/vLLM | Workstation Ollama and LM Studio |
| Granite lab smoke model | LM Studio | Ollama |
| Future experimental GGUF such as Muse | LM Studio first | Ollama unless it later becomes an accepted permanent service |

Ollama blobs cannot be turned into normal LM Studio entries simply by pointing LM Studio at the Ollama directory.

### Importing a standalone GGUF without copying it

If you later download a `.gguf` file manually to the **same `D:` NTFS drive**, LM Studio can hard-link it instead of making a second full copy.

First perform a dry run in **Workstation PowerShell**:

```powershell
lms import 'D:\Path\To\TheModel.gguf' --dry-run
```

Read the result. If the source and LM Studio directory are on the same NTFS volume, import with a hard link:

```powershell
lms import 'D:\Path\To\TheModel.gguf' --hard-link
```

Replace the example path with the real `.gguf` file. Do not type the placeholder literally.

LM Studio's default `lms import` behavior is to **move** the file. Always use `--dry-run` first and explicitly use `--hard-link` when that is what you intend. See the official [`lms import` documentation](https://lmstudio.ai/docs/cli/local-models/import).

---

## Part 15 — Troubleshooting

### Ollama command is not found

On the workstation:

1. launch Ollama once from the Windows Start menu;
2. close PowerShell;
3. open a new PowerShell window;
4. run:

   ```powershell
   Get-Command ollama
   ```

If it is still missing, check that Ollama appears under **Installed apps** and reinstall using the official Windows installer.

### Ollama API does not respond

Run in **Workstation PowerShell**:

```powershell
Get-NetTCPConnection -LocalPort 11434 -ErrorAction SilentlyContinue
Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/version'
```

If both fail, launch Ollama from the Start menu. Official Windows logs are stored under:

```text
%LOCALAPPDATA%\Ollama
```

Open that directory with:

```powershell
explorer "$env:LOCALAPPDATA\Ollama"
```

Check `server.log` without posting secrets or unrelated private paths.

### Open WebUI cannot see Ollama

Confirm all three facts:

1. Windows PowerShell can reach `http://127.0.0.1:11434/api/version`.
2. Open WebUI uses `http://host.docker.internal:11434`.
3. Docker Desktop and the ODS Open WebUI container are running.

Do not use `http://localhost:11434` inside the Open WebUI connection.

### Ollama runs on CPU or shows a CPU/GPU split

Run:

```powershell
ollama ps
nvidia-smi
```

Then:

1. stop the model;
2. close other GPU-heavy applications;
3. confirm the current NVIDIA driver is still installed;
4. update/restart Ollama;
5. reload the model and check `ollama ps` again.

Your verified card and driver meet Ollama's published requirements, so persistent CPU-only execution should be investigated rather than accepted as normal.

### A model consumes much more VRAM than its download size

The downloaded package mostly describes the compressed weights. Runtime memory additionally includes:

- KV cache for the chosen context;
- vision projector/runtime state;
- CUDA kernels and working buffers;
- request batching and parallel contexts.

Reduce the context to 16K or 8K, keep parallelism at one, and close other GPU workloads. Do not conclude that the download is corrupt merely because runtime memory is larger than the model file.

### `lms` is not found

1. Open the LM Studio graphical app once.
2. Wait for it to finish starting.
3. close PowerShell;
4. open a new PowerShell window;
5. run `lms --help` again.

### LM Studio says port 1234 is already in use

In **Workstation PowerShell**:

```powershell
lms server stop
Get-NetTCPConnection -LocalPort 1234 -ErrorAction SilentlyContinue | Format-Table LocalAddress, LocalPort, OwningProcess
```

Do not kill an unknown process. Identify it before deciding whether to stop it or use another lab port.

### LM Link shows the workstation as disconnected

Confirm:

- LM Studio is running on the workstation;
- LM Studio is running on the laptop;
- both use the same LM Studio account;
- LM Link is enabled on both;
- both applications are current.

Existing personal Tailscale does not need to be removed. LM Studio says LM Link uses a separate self-contained network.

---

## Part 16 — Safe rollback

### Stop all model residency without deleting downloads

In **Workstation PowerShell**:

```powershell
ollama stop gemma4:31b-it-qat
ollama stop gemma4:26b-a4b-it-qat
lms unload --all
lms server stop
ollama ps
lms ps
nvidia-smi --query-gpu=name,memory.used,memory.free --format=csv
```

This is the normal rollback. It keeps all model files on disk.

### Disable LM Link without uninstalling LM Studio

In **Workstation LM Studio**:

1. open **Settings**;
2. open **LM Link**;
3. turn **Enable LM Link** off.

Or run in **Workstation PowerShell**:

```powershell
lms link disable
```

### Uninstall an application

Use **Windows Settings → Apps → Installed apps**.

Uninstalling Ollama does not automatically remove a custom `OLLAMA_MODELS` directory. Uninstalling LM Studio should not be treated as authorization to delete the separate lab-model directory. Keep both directories until you deliberately decide the downloads are no longer needed.

Do not recursively delete `D:\LocalLLama` just to remove one model.

To delete one Ollama model intentionally, use its exact name:

```powershell
ollama rm gemma4:31b-it-qat
```

That command deletes the downloaded 31B model. Do not run it merely to free VRAM; use `ollama stop` for that.

---

## Part 17 — Final success gate

Do not mark Local Setup Index Steps 2, 3, and 4 complete until every applicable box below is checked.

### Workstation Ollama and models

- [ ] Native Windows Ollama is installed and starts normally.
- [ ] `OLLAMA_MODELS` points to `D:\LocalLLama\models\ollama` or the deliberately chosen replacement SSD path.
- [ ] Ollama is limited to one loaded model and one parallel request.
- [ ] Open WebUI uses `http://host.docker.internal:11434` with a visible `local/` prefix.
- [ ] The existing Spark LiteLLM connection remains separate and visible as `spark/`.
- [ ] `gemma4:31b-it-qat` is downloaded and tested directly and through Open WebUI.
- [ ] `gemma4:26b-a4b-it-qat` is downloaded and tested directly and through Open WebUI.
- [ ] Both models remain downloaded together on disk.
- [ ] Only one large model was loaded at a time.
- [ ] `ollama ps` is empty after the tests.
- [ ] Each Gemma was compared with the same prompt against `spark-fast`.

### LM Studio lab and LM Link

- [ ] LM Studio is installed on the workstation.
- [ ] LM Studio uses `D:\LocalLLama\models\lmstudio` or the deliberately chosen replacement path.
- [ ] The Ollama Gemmas were not downloaded again in LM Studio.
- [ ] A small lab-only model completed estimate, load, API, and unload tests.
- [ ] JIT loading and Auto-Evict are enabled.
- [ ] A 30-minute lab TTL is configured or deliberately supplied during loading.
- [ ] LM Link is enabled on workstation and laptop under the same account.
- [ ] The laptop successfully used a model running on the workstation.
- [ ] `lms unload --all` released the model after testing.
- [ ] LM Studio remains an optional lab layer, not a replacement for Ollama or Spark LiteLLM.

### After completion

Return to [[Local Setup Index]] and check off:

- **Step 2 — Make workstation Ollama the ODS model shelf**;
- **Step 3 — Add workstation models one at a time**;
- **Step 4 — Configure LM Studio and LM Link only as the lab layer**.

Then continue with **Step 5 — Add the first genuinely specialized Spark model**. The warning shown while building the Nemotron Omni image is addressed separately in [[DGX Spark Nemotron 3 Nano Omni Tutorial]]; an image that was successfully exported and named is not a failed build.

### Primary sources

- [Ollama for Windows](https://docs.ollama.com/windows)
- [Ollama hardware support](https://docs.ollama.com/gpu)
- [Ollama FAQ: storage, GPU verification, keep-alive, and concurrency](https://docs.ollama.com/faq)
- [Ollama CLI reference](https://docs.ollama.com/cli)
- [Ollama Gemma 4 31B QAT](https://ollama.com/library/gemma4:31b-it-qat)
- [Ollama Gemma 4 26B-A4B QAT](https://ollama.com/library/gemma4:26b-a4b-it-qat)
- [Google Gemma 4 overview](https://ai.google.dev/gemma/docs/core)
- [Open WebUI Ollama connection guide](https://docs.openwebui.com/getting-started/quick-start/connect-a-provider/starting-with-ollama/)
- [LM Studio system requirements](https://lmstudio.ai/docs/app/system-requirements)
- [LM Studio CLI](https://lmstudio.ai/docs/cli)
- [LM Studio model downloading](https://lmstudio.ai/docs/app/basics/download-model)
- [LM Studio model loading](https://lmstudio.ai/docs/cli/local-models/load)
- [LM Studio Idle TTL and Auto-Evict](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict)
- [LM Link Add a Device](https://lmstudio.ai/docs/lmlink/basics/add-device)
- [LM Link FAQ](https://lmstudio.ai/docs/lmlink/basics/faq)
- [LM Studio model import](https://lmstudio.ai/docs/cli/local-models/import)
- [NVIDIA RTX PRO 5000 Blackwell datasheet](https://www.nvidia.com/content/dam/en-zz/Solutions/products/workstations/professional-desktop-gpus/rtx-pro-5000-blackwell/workstation-datasheet-blackwell-rtx-pro-5000-gtc25-spring-nvidia-3658700.pdf)

Related: [[Local Setup Index]] | [[DGX Spark And RTX 5000 Workstation Model Placement Research]] | [[DGX Spark Model Installation And Switching Guide]] | [[DGX Spark Nemotron 3 Nano Omni Tutorial]] | [[DGX Spark LM Studio And LM Link Tutorial]]
