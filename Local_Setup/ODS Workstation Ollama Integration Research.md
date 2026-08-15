# ODS Workstation Ollama Integration Research

Research date: **2026-08-15**  
Scope: the RTX PRO 5000 Windows workstation, native Windows Ollama, and the workstation's own ODS installation. DGX Spark is treated as a separate computer and a separate ODS installation.

## Bottom line

The earlier workstation tutorial conflated three different control surfaces:

1. **Ollama Desktop** controls native Windows Ollama and its own model store.
2. **ODS Dashboard** at `http://localhost:3001` controls the workstation ODS stack and ODS-managed GGUF models.
3. **ODS Open WebUI** at `http://localhost:3000` is the workstation chat interface. ODS intentionally configures this Open WebUI differently from a generic upstream installation.

Native Ollama models do **not** need to live inside the ODS folder. In fact, Ollama and ODS use different stores and different ownership rules:

| Runtime | Native model store | Who manages it |
|---|---|---|
| Native Windows Ollama | The folder selected in Ollama Settings, otherwise `%USERPROFILE%\.ollama\models` | Ollama Desktop / Ollama API |
| Workstation ODS llama-server | The workstation ODS runtime's `data\models\` folder | ODS Dashboard → Models |
| Spark ODS/vLLM | Paths on the DGX Spark filesystem | The Spark's own ODS/vLLM deployment |

Putting Ollama blobs in `D:\LocalLLama\ods\data\models` would not make them ODS models. ODS's model manager expects compatible single-file GGUF artifacts, while Ollama manages manifests and content-addressed blobs in its own store. [ODS model-management documentation](https://github.com/Osmantic/ODS/blob/main/ods/docs/MODEL-MANAGEMENT.md#where-models-live) [Ollama Windows storage documentation](https://docs.ollama.com/windows#changing-model-location)

## What is true on this workstation now

The first inspection was read-only. The live implementation later changed the model ownership and port layout on 2026-08-15; the current-state bullets below include those verified changes.

- Installed ODS reports **ODS v2.5.3 (Windows)** when invoked with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\ods.ps1 version` from `D:\LocalLLama\ods`.
- The live ODS Dashboard also reports **v2.5.3** and currently labels it the latest release. Current upstream GitHub nevertheless has a stable **v2.6.0** tag whose release notes call v2.5.3 superseded. Treat this disagreement as a reason to avoid forcing a manual upgrade; it does not affect the model-routing findings below. [ODS 2.6.0 release notes](https://github.com/Osmantic/ODS/blob/v2.6.0/ods/docs/RELEASE_NOTES_2.6.0.md#summary)
- Native Ollama Desktop is running from the current user's per-user installation and its API reports version **0.32.13** at its conventional `http://127.0.0.1:11434/api/version`.
- Ollama stores models at `D:\LocalLLama\models\ollama` and is the chosen owner for the workstation Gemma packages. `gemma3:4b`, `gemma4:31b-it-qat`, and `gemma4:26b-a4b-it-qat` are installed there. Both large Gemmas passed direct Ollama and ODS Open WebUI tests at 16K context, ran 100% on the GPU, and were unloaded afterward.
- `D:\LocalLLama\models\lmstudio` remains the separate LM Studio lab store.
- `%USERPROFILE%\.ollama\models` exists with Ollama's default `blobs` and `manifests` structure.
- All six user-level values from the old Step 3.1 are currently absent: `OLLAMA_MODELS`, `OLLAMA_MAX_LOADED_MODELS`, `OLLAMA_NUM_PARALLEL`, `OLLAMA_KEEP_ALIVE`, `OLLAMA_CONTEXT_LENGTH`, and `OLLAMA_FLASH_ATTENTION`.
- The installed workstation ODS compose stack explicitly includes a workstation-local `ods-litellm` service. Its installed `config\litellm\local.yaml` points to the workstation's `llama-server`, not to DGX Spark.
- Container inspection verified that ODS Open WebUI v0.7.2 starts with `ENABLE_OLLAMA_API=false` and `OPENAI_API_BASE_URL=http://llama-server:8080/v1`. Authenticated UI inspection established that saved Open WebUI configuration overrides the initial Ollama default. One duplicate connection was removed; **Admin Panel → Settings → Connections** now has exactly one enabled `http://host.docker.internal:11434` Ollama entry, and the post-update selector showed each installed model once.
- The former **DeepSeek R1 70B Q4** ODS runtime was stopped and its GGUF was moved to the Windows Recycle Bin; VRAM use fell from roughly 47 GB to roughly 2.4 GB.
- The workstation ODS Dashboard's Gemma entries were found to reference nonexistent `Q4_K_M` filenames. Their local catalog metadata was corrected to the published `ggml-org` `Q4_0` files, but these Gemmas are not the active download path.
- Native Ollama owns host port `11434`. ODS's optional host-facing llama-server was moved to `11436`; Open WebUI still reaches it internally at `http://llama-server:8080/v1` and reaches native Ollama at `http://host.docker.internal:11434`.

The original Ollama symptom is therefore resolved. Ollama Desktop's saved settings—not the removed PowerShell variables—now place models in `D:\LocalLLama\models\ollama` and use a 16K initial context. Native Ollama retains the conventional port `11434`; the optional ODS runtime was moved instead.

## Files that control the installed workstation ODS

| Installed path | What it controls |
|---|---|
| `D:\LocalLLama\ods\ods.ps1` | Windows start, stop, status, logs, version, and image-refresh commands |
| `D:\LocalLLama\ods\docker-compose.base.yml` | Core services, including `ods-webui`, `llama-server`, ports, environment variables, and persistent mounts |
| `D:\LocalLLama\ods\.compose-flags` | The Compose files/extensions selected for this workstation installation |
| `D:\LocalLLama\ods\config\litellm\local.yaml` | This workstation's own LiteLLM aliases and backends |
| `D:\LocalLLama\ods\data\models` | ODS-managed single-file GGUF model storage |
| `D:\LocalLLama\ods\data\open-webui` | Persistent Open WebUI database and data |

These are workstation paths. Files with the same names on DGX Spark belong to the Spark installation and do not configure this desktop.

## Why Ollama still shows the default download directory

There are two settings layers in current Ollama Desktop.

### Layer 1: inherited Windows environment variables

Ollama's Windows documentation says the desktop process inherits user and system environment variables. It specifically documents `OLLAMA_MODELS` as the way to change the default store. After changing a Windows variable, Ollama must be fully quit from the tray and relaunched from the Start menu; a new terminal is also required to inherit the updated environment. [Ollama Windows documentation](https://docs.ollama.com/windows#changing-model-location) [Ollama FAQ](https://docs.ollama.com/faq#setting-environment-variables-on-windows)

Ollama source uses `%USERPROFILE%\.ollama\models` when `OLLAMA_MODELS` is empty. A non-empty value replaces that default. [Ollama environment source](https://github.com/ollama/ollama/blob/main/envconfig/config.go#L104-L117)

### Layer 2: Ollama Desktop's saved Settings

Current Ollama Desktop also has its own saved **Model location** and **Context length** settings. Its server launcher first copies the inherited process environment and then overwrites `OLLAMA_MODELS` and `OLLAMA_CONTEXT_LENGTH` when non-empty app settings are present. The app settings therefore win over the same environment variables. [Ollama Desktop server source](https://github.com/ollama/ollama/blob/main/app/server/server.go#L217-L260)

The current Settings screen exposes:

- **Model location** with a **Browse** button;
- **Context length** values from 4K through 256K;
- **Reset to defaults**, which clears the saved model path and sets the saved context to automatic (`0`).

These controls are visible in Ollama's first-party Settings source. [Ollama Settings UI](https://github.com/ollama/ollama/blob/main/app/ui/app/src/components/Settings.tsx#L471-L540) [Reset-to-defaults implementation](https://github.com/ollama/ollama/blob/main/app/ui/app/src/components/Settings.tsx#L193-L205)

Changing the app's model path or context causes the managed Ollama server to restart automatically. [Ollama Desktop settings handler](https://github.com/ollama/ollama/blob/main/app/ui/ui.go#L1366-L1400)

### Best beginner method

For this workstation, use the Ollama Desktop Settings screen as the visible source of truth:

1. Open **Ollama**.
2. Open **Settings**.
3. Under **Model location**, click **Browse**.
4. Select `D:\LocalLLama\models\ollama`.
5. Set **Context length** to **16K** for the first tests. Move to 32K only after checking model fit and performance.
6. Wait for Ollama to save and restart its managed server.
7. Reopen Settings and confirm both displayed values stayed selected.

The environment-variable route remains valid, but the app controls are easier to see and current Ollama source proves they have precedence.

## Why the Ollama app shows 256K context

The 256K value is expected when Ollama is left in automatic mode on a GPU in this VRAM class.

Current Ollama policy is:

| Detected VRAM | Automatic context |
|---|---:|
| Less than 24 GiB | 4K |
| 24–48 GiB | 32K |
| At least 48 GiB | 256K |

The implementation uses slightly lower 23/47 GiB boundaries to absorb reporting differences. The workstation's reported 48,935 MiB clears the implementation's 47 GiB boundary, so automatic selection becomes 262,144 tokens. [Ollama context documentation](https://docs.ollama.com/context-length) [Ollama VRAM-tier source](https://github.com/ollama/ollama/blob/main/server/routes.go#L1891-L1905)

This is not proof that every 20 GB model will run efficiently at 256K. A larger allocated context consumes more VRAM. Ollama's own documentation says to verify the loaded model using `ollama ps`; its `CONTEXT` and `PROCESSOR` columns are runtime evidence. [Ollama context documentation](https://docs.ollama.com/context-length#check-allocated-context-length-and-model-offloading) [Ollama running-model API](https://docs.ollama.com/api/ps)

Also distinguish:

- **advertised model capacity**, returned in model metadata by `/api/show`;
- **allocated runtime context**, shown for a loaded model by `ollama ps`.

A model can advertise 256K while the server deliberately allocates 16K. The latter is what consumes the active KV-cache memory.

## What the authenticated Open WebUI Admin page actually contains

The unauthenticated page initially hid the administrative controls. After the user signed into the existing administrator account, the exact path was visible:

1. profile menu;
2. **Admin Panel**;
3. **Settings**;
4. **Connections**.

Current ODS compose configuration does all of the following:

- runs the pinned image `ghcr.io/open-webui/open-webui:v0.7.2`;
- sets `ENABLE_OLLAMA_API: "false"`;
- sends Open WebUI to one OpenAI-compatible endpoint through `OPENAI_API_BASE_URL`;
- preserves Open WebUI state in `./data/open-webui`;
- publishes the chat UI on port 3000.

The container environment is an initial/default layer, not the whole active configuration. The authenticated page currently shows:

- one OpenAI-compatible base URL: `http://llama-server:8080/v1`;
- the **Ollama API** switch enabled;
- one native Ollama URL: `http://host.docker.internal:11434`; a duplicate was removed on 2026-08-15.

The connector test originally made `gemma3:4b` appear twice because the same native Ollama URL was saved twice. The duplicate was removed and the post-update selector now lists each Ollama model once.

## The two local ODS web pages

### `http://localhost:3000` — chat

This is ODS Open WebUI. Use it for conversations, document attachment, web search, and the other chat features ODS has wired into it. It is not the main ODS service/model administration page. [ODS Windows Quickstart](https://github.com/Osmantic/ODS/blob/main/ods/docs/WINDOWS-QUICKSTART.md#open-the-ui)

### `http://localhost:3001` — ODS Dashboard

This is the ODS control center. The ODS compose file publishes `ods-dashboard` on port 3001. [ODS Dashboard compose definition](https://github.com/Osmantic/ODS/blob/main/ods/docker-compose.base.yml#L428-L458)

For ODS-managed local models, open the Dashboard and go to **Models**. The supported ODS flow is discover → download/import → load → use → restore → delete. It downloads ODS-compatible GGUF files into `data\models`, updates the runtime and routes, and verifies or rolls back model activation. [ODS Model Management](https://github.com/Osmantic/ODS/blob/main/ods/docs/MODEL-MANAGEMENT.md#recommended-dashboard-models-page) [ODS verified activation behavior](https://github.com/Osmantic/ODS/blob/main/ods/docs/MODEL-MANAGEMENT.md#choosing-the-runtime-context)

This Dashboard path remains available for models deliberately owned by the ODS appliance. It is not the active ownership path for the workstation Gemmas; those belong to native Ollama.

## How native Windows Ollama participates in workstation Open WebUI

Native Ollama is already an additional Open WebUI provider; it does not replace the ODS internal `llama-server`. Ollama exposes its native API at `http://localhost:11434`, and the Dockerized Open WebUI reaches the Windows host through `http://host.docker.internal:11434`.

Current ODS source also contains an external-LLM contract for a host-managed Ollama or LM Studio server. It describes host URL, container URL, provider, and model variables and says the installer should validate the endpoint and change Compose topology atomically. [ODS external-LLM environment contract](https://github.com/Osmantic/ODS/blob/main/ods/.env.example#L51-L76)

The active additional-provider path is:

```text
ODS Open WebUI container -> http://host.docker.internal:11434 -> native Windows Ollama
```

This exists alongside, rather than instead of:

```text
ODS Open WebUI container -> http://llama-server:8080/v1 -> ODS llama-server
```

An Ollama model remains in Ollama's own store even when its name is selected in ODS Open WebUI. An ODS Dashboard model remains a GGUF in ODS storage. Open WebUI aggregates the API model lists; it does not merge the files.

Recommended policy:

- use **Ollama Desktop** as the canonical workstation model shelf that the existing Open WebUI connector can list;
- use **ODS Dashboard → Models** only for a later model deliberately owned by workstation ODS;
- do not duplicate an Ollama container through an ODS extension;
- keep just one identical native Ollama connector after its first successful test;
- do not point workstation ODS at the Spark LiteLLM endpoint unless that cross-machine connection is an intentional later design decision.

The implemented model path is therefore:

1. Keep native Ollama on standard port `11434` and keep its models in `D:\LocalLLama\models\ollama`.
2. Keep the optional ODS llama-server stopped on host port `11436` unless an ODS-owned GGUF is intentionally needed.
3. Pull `gemma4:31b-it-qat` and `gemma4:26b-a4b-it-qat` through Ollama and select them in ODS Open WebUI.
4. Expect only one large workstation inference model to be GPU-resident at a time; use `ollama stop MODEL_TAG` between tests.
5. Do not expose or add Spark models to workstation ODS unless you later choose that as an explicit remote-provider project.

## Workstation ODS and Spark ODS are separate

There are four distinct services, not one shared ODS:

| Name | Machine | Purpose | Automatic connection to the other machine? |
|---|---|---|---|
| Workstation ODS | RTX PRO 5000 Windows desktop | Local chat/search/dashboard and workstation-managed models | No |
| Workstation native Ollama | RTX PRO 5000 Windows desktop | Separate native Ollama app and model shelf | No; ODS must be intentionally configured to use it |
| Spark ODS | DGX Spark | Spark-local ODS services | No |
| Spark LiteLLM/vLLM | DGX Spark | Spark model routing and Spark inference endpoints | No; a desktop client must be deliberately given a Spark URL and credential |

The installed workstation `.compose-flags` enables a local LiteLLM container. The installed workstation `config\litellm\local.yaml` routes its aliases to the workstation's local `llama-server`. That is not the Spark LiteLLM merely because both programs are named LiteLLM.

ODS does not automatically discover a Spark `spark/...` connection. If `spark/...` appears in the workstation Open WebUI, it came from a deliberate prior configuration or persisted Open WebUI database state. It should not be documented as a default workstation connection without inspecting that state.

## Updating Open WebUI safely inside ODS

Do not update the `ods-webui` container independently to `main`, `latest`, or an arbitrary Open WebUI tag. ODS pins Open WebUI and supplies ODS-specific environment variables, service dependencies, search/voice/image routes, and a persistent data mount.

For the currently installed ODS runtime, the supported image refresh command is:

```powershell
cd 'D:\LocalLLama\ods'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\ods.ps1 update
```

ODS's Windows documentation describes `.\ods.ps1 update` as pulling images and restarting. [ODS Windows Quickstart](https://github.com/Osmantic/ODS/blob/main/ods/docs/WINDOWS-QUICKSTART.md#quick-commands)

The installed implementation performs `docker compose pull`, then `docker compose up -d --force-recreate`, and runs status checks. Because the compose file bind-mounts `./data/open-webui` to `/app/backend/data`, recreation is designed to retain the Open WebUI database and user data. [ODS Open WebUI data mount](https://github.com/Osmantic/ODS/blob/main/ods/docker-compose.base.yml#L165-L168)

Important limitation: the installed compose file pins `v0.7.2`. The supported `ods.ps1 update` completed successfully on 2026-08-15 and preserved the configuration, but it did not replace ODS v2.5.3's runtime source tree or change the Open WebUI tag. Current ODS `main` and stable v2.6.0 also pin Open WebUI v0.7.2, so a safe ODS-managed refresh is not the same as independently upgrading Open WebUI to the newest upstream release.

Before any whole-ODS version upgrade:

1. back up `D:\LocalLLama\ods\data\open-webui` and the ODS `.env` using the current Windows account;
2. record `.\ods.ps1 version` and `.\ods.ps1 status`;
3. use a pinned ODS release rather than mutable `main`;
4. upgrade ODS as a unit;
5. verify ODS Dashboard, Open WebUI, local inference, search, and persisted chats afterward.

ODS's provenance guide recommends installing Windows from a reviewed stable tag in a normal, non-administrator PowerShell. [ODS Installer Trust](https://github.com/Osmantic/ODS/blob/v2.6.0/ods/docs/INSTALLER_TRUST.md#windows-powershell-install)

## Recommended correction to the workstation tutorial

The tutorial should be rewritten around these two non-overlapping tracks:

### Track A — Native Ollama lab

1. Configure **Model location** and **Context length** in Ollama Desktop Settings.
2. Verify the setting persisted by reopening Settings.
3. Download and run Ollama-tagged models with Ollama.
4. Verify runtime context and GPU residency with `ollama ps`.
5. Keep the Ollama store outside ODS.

### Track B — Workstation ODS appliance

1. Open `http://localhost:3001`.
2. Use **Dashboard → Models** for ODS-managed compatible GGUFs.
3. Open `http://localhost:3000` only for chat.
4. Verify that the saved Ollama connector lists the downloaded Ollama model.
5. Keep ODS GGUF files and Ollama blobs in their separate stores.
6. Do not expect Spark aliases unless an explicit Spark provider is later configured.

The tutorial should remove the statements that the workstation Open WebUI already has or must preserve a `spark/` LiteLLM connection. That was an unverified cross-machine assumption.

## Related notes

- [[RTX PRO 5000 Workstation ODS Models And LM Studio Desktop Tutorial]]
- [[RTX PRO 5000 Workstation Models And LM Studio Lab Tutorial]] — superseded
- [[Local Setup Index]]
- [[DGX Spark Operations Setup Guide]]

## Primary sources

- [ODS repository and current architecture](https://github.com/Osmantic/ODS)
- [ODS Windows Quickstart](https://github.com/Osmantic/ODS/blob/main/ods/docs/WINDOWS-QUICKSTART.md)
- [ODS Open WebUI compose definition](https://github.com/Osmantic/ODS/blob/main/ods/docker-compose.base.yml)
- [ODS Model Management](https://github.com/Osmantic/ODS/blob/main/ods/docs/MODEL-MANAGEMENT.md)
- [ODS environment reference](https://github.com/Osmantic/ODS/blob/main/ods/.env.example)
- [ODS 2.6.0 release notes](https://github.com/Osmantic/ODS/blob/v2.6.0/ods/docs/RELEASE_NOTES_2.6.0.md)
- [Ollama Windows](https://docs.ollama.com/windows)
- [Ollama context length](https://docs.ollama.com/context-length)
- [Ollama FAQ](https://docs.ollama.com/faq)
- [Ollama OpenAI compatibility](https://docs.ollama.com/api/openai-compatibility)
- [Ollama Desktop server-setting precedence](https://github.com/ollama/ollama/blob/main/app/server/server.go#L217-L260)
- [Ollama Desktop Settings UI](https://github.com/ollama/ollama/blob/main/app/ui/app/src/components/Settings.tsx#L471-L540)
