# Owner Context for Agents

Facts and defaults that let Claude Code, Codex and Hermes make the owner's routine decisions without asking. This file adds to the shared rules in `Nightly Runs/agent-rules/AGENTS.md` and does not repeat them. If anything here conflicts with AGENTS.md, AGENTS.md wins. If a fact here conflicts with a newer note in `Local_Setup/`, the newer note wins. Last compiled 2026-10-20.

## 1. Machines and roles

| Machine | Tailnet name / IP | LAN | Role |
|---|---|---|---|
| Windows desktop | `nike-workstation.tail4a1242.ts.net` / 100.91.148.63 | n/a | Windows 11 Pro. NVIDIA RTX PRO 5000 Blackwell (48 GB). The monitors run on the Intel iGPU, never the RTX. Runs Desktop Qwen (always on), native Ollama, workstation ODS (Open WebUI, Perplexica, SearXNG), ComfyUI, VoiceStudio, Dashboard Command Center, the Agents board and the overnight runner. Preferred home for dense 27–31B inference, evaluation and LoRA/QLoRA work. |
| FirstSpark | `spark-07a8.tail4a1242.ts.net` / 100.94.199.98 | 192.168.0.101 | DGX Spark, 128 GB unified memory. Holds files plus the always-on models under 50B: vLLM Qwen3.6-35B-A3B NVFP4, which is its only resident model. Also runs LiteLLM, Hermes (Serve, Gateway, cron) and the always-on tailnet services. **Never drained** for frontier models. |
| SecondSpark | `spark-7047` / 100.118.133.79 | 192.168.0.100 | Head of the frontier pair. Serves GLM 5.3 Flash (TensorFold, 1M context) on `192.168.100.11:8888`. |
| ThirdSpark | `spark-6ce7` / 100.122.61.53 | 192.168.0.182 | Worker of the frontier pair. Holds one big model at a time together with SecondSpark. |
| Laptop | `nikezoldyck` | n/a | Client only. Uses Spark Hermes through the Remote Gateway. |

How to reach each machine:
- **Desktop to Sparks:** use the aliases `FirstSpark`, `SecondSpark` and `ThirdSpark`. They are defined in the NVIDIA Sync ssh_config (`%LOCALAPPDATA%\NVIDIA Corporation\Sync\config\ssh_config`, user `snknitin`, hosts `spark-xxxx.local`). Call them with Windows `C:\Windows\System32\OpenSSH\ssh.exe`. Git Bash ssh with raw IPs fails because it has no key.
- **Sparks to desktop:** the alias `nike-workstation` (user "Nitin Kishore Sai"). The desktop sshd reads only `C:\ProgramData\ssh\administrators_authorized_keys`.
- **Between Sparks:** FirstSpark ↔ SecondSpark over CX-7 at 192.168.100.10/.11 and 192.168.101.10/.11. SecondSpark ↔ ThirdSpark over 192.168.102.x/103.x. Copy model weights over these links (`rsync -aH`). Never re-download them.
- **Home internet is 300 Mb/s, shared by every device.** One `hf download` on a Spark takes nearly all of it.
- **Paths:**
  - Desktop projects: `E:\GIT_ROOT\Projects\<folder>`
  - FirstSpark projects: `~/Workspace/GIT_ROOT/Projects/<folder>`
  - Third-party checkouts on the desktop: `E:\GIT_ROOT\External\`
  - Vault: `F:\Vaults\LLMWiki` on the desktop. FirstSpark has a replica at `/home/snknitin/vaults/LLMWiki`, kept in sync both ways by obsidian-headless.

## 2. Models and endpoints

| Name (what you pass as `model`) | Where it runs | Endpoint | Use it for |
|---|---|---|---|
| `glm53-flash` | SecondSpark + ThirdSpark | LiteLLM `http://127.0.0.1:4000/v1` on FirstSpark | Hermes default since 2026-10-19 and the Hermes overnight lane. Coding and long grinding work. 1,048,576 context. |
| `qwen3.6-35b-a3b` | FirstSpark vLLM | LiteLLM `127.0.0.1:4000` on FirstSpark | Fast always-on model for quick tasks, scheduled jobs and app inference. Accepts image input. The hidden alias `spark-fast` still works. |
| `spark-fast` (vLLM served name) | FirstSpark | `http://127.0.0.1:8000/v1` directly | For FirstSpark apps that skip LiteLLM. Fresh Brief, YouTube Learning Center and Social Capture already call it this way. |
| `qwen38-flash-pair` | SecondSpark + ThirdSpark | LiteLLM, backend `192.168.100.11:8889` | Swap lane. It answers only after `pair-swap.sh qwen`, and `glm53-flash` is down while it runs. Don't swap unattended. |
| `qwen3.8-27b-desktop` (Hermes provider `desktop-qwen`) | Desktop RTX, llama-server | `http://127.0.0.1:11435/v1`. From Docker: `http://host.docker.internal:11435`. From the tailnet: `https://nike-workstation.tail4a1242.ts.net:8444/v1` | Windows apps that need a local LLM. Qwen 3.8 27B UD-Q5_K_XL with 2 slots × 262K context and vision. Any model name is accepted. |
| Ollama models (Gemma 4 31B and 26B-A4B, `gemma3:4b`) | Desktop | `http://127.0.0.1:11434`. From the tailnet: `:8443` | Occasional use only. Never select `qwen3.8:27b-q4_k_m` in Ollama: it loads a second copy that spills onto the CPU. |

How a project's app should call a local model:
- **Use one OpenAI-compatible base URL and model name, read from config or env.** Never hard-code them. Tests use a fake or fixture model. (event-market-research-terminal REPORT §6.2 resolved: the extract role uses FirstSpark `spark-fast` and the synthesize role uses the frontier pair.)
- **Apps on FirstSpark** call LiteLLM at `127.0.0.1:4000` (`qwen3.6-35b-a3b` or `glm53-flash`) or vLLM at `127.0.0.1:8000` (`spark-fast`).
- **Apps on Windows** call Desktop Qwen at `127.0.0.1:11435`. The Spark LiteLLM is loopback-only and **cannot be reached from the desktop** (AI Coding Playbook).
- **Desktop Qwen thinking:** send `chat_template_kwargs: {"enable_thinking": false}` unless you really want thinking. Ollama's `think:false` is ignored, so Qwen uses up the token budget and the request times out empty (World Monitor on Windows Workstation).
- **Desktop Qwen is sometimes off.** It has only 2 slots, shared with Hermes and Fresh Brief, and the owner turns it off for ComfyUI (Qwen OFF/ON). Apps must degrade gracefully with an empty or "unavailable" result, never crash.
- **Default vision model:** `spark-fast` / Qwen3.6-35B-A3B, as an owner decision dated 2026-10-20. Pin whatever `/v1/models` reports as the model version (visual-token-compiler REPORT §6.2). finance-ops-agency also uses `spark-fast` as its vision endpoint.
- **Speech-to-text:** Parakeet Unified EN via Handy by default. Use faster-whisper `large-v3` only for non-English audio. Owner decision 2026-10-20 (daily-parent-check-in and song-phrase-mosaic REPORTs).
- **Text-to-speech:** VoiceStudio. Show "voice unavailable" when it is not running. Owner decision (language-learning-lab REPORT §6.16).

Cloud models:
- **Claude Code (Opus or Sonnet on the Max plan) and Codex (ChatGPT plan)** are the coding harnesses, not in-app models (AI Coding Playbook §4).
- **Claude API credits** are used only by Kaggle Learning Center's in-app calls. Set `ANTHROPIC_API_KEY` only in that app's service env, never globally. A global key makes Claude Code bill the API instead of Max.
- **Any other app that would call a cloud or metered API is an owner question.** The default is a local model.

## 3. Services and ports

Port rules:
- **FirstSpark:** read `Local_Setup/FirstSpark Port Registry.md` first. A project's preview port is its row under "Project previews", which the overnight runner adds before the first session; never ask the owner which port to use. For any other new service, take the first free port from its list and add the row in the same commit.
  - Free for dashboards and web apps: 8768, 8771, 8773–8786, 8790–8799
  - Free for agent tools and APIs: 9121–9199
  - Free for model servers: 8001–8009
  - Never use 8080, 8888, 3000, 5000 or 11434, nor the "unknown" ports 9333 and 11000.
- **Bind to `127.0.0.1` by default.** Publish to the tailnet only with Tailscale Serve: `sudo tailscale serve --bg --https=<port> http://127.0.0.1:<port>`, using the same number on both sides. **Never use Tailscale Funnel, and never bind 0.0.0.0** (Local Setup Index decision 4A; FirstSpark Port Registry).
- **Already taken on FirstSpark** (see the registry for the full list):
  - Apps and dashboards: 4173 God's Eye View, 5555 sparkDash, 8091 FreshRSS, 8443 YouTube Learning Center, 8765 Social Capture, 8766→:10000 Dunbar Dossier, 8772 Kaggle Learning Center, 8787 Fresh Brief, 8788 TikTok Learning Center, 3010→:8789 TikTok VPN browser
  - Reserved for apps not yet deployed: 8767 Expert Lens, 8769 Paper Logbook, 8770 Creator Content Engine, 18767 Expert Lens test server
  - Models and agent infrastructure: 8000 vLLM, 4000 LiteLLM, 8102 embeddings, 8888 (probably SearXNG), 9119 Hermes Serve, 9120 Hermes Dashboard, 3003 OpenCode web
  - MCP OAuth callbacks: 27910, 27913–27915, 27918, 27919
  - System: 22, 53, 443, 631
- **Taken on the desktop.** There is no registry file here, so check `Get-NetTCPConnection -State Listen` before binding anything.
  - 3000 Open WebUI, 3001 ODS dashboard, 3004 Perplexica, 3900 VoiceStudio backend
  - 8079 World Monitor redis-rest, 8095 openGym, 8096 World Monitor, 8188 ComfyUI
  - 8443 and 8444: Tailscale Serve routes for Ollama and Desktop Qwen
  - 8767 Local Setup dashboard (per expert-lens-skill REPORT Q6), 8768 Agents board
  - 8888 SearXNG, 11434 Ollama, 11435 Desktop Qwen, 11436 ODS llama-server (reserved)

## 4. Standing decisions (Question → default (why) (source))

Hosting
- Windows or FirstSpark? → **FirstSpark** for always-on, tailnet-reachable services and private-data loops. **Windows** for apps that need the RTX, Desktop Qwen, ComfyUI or local files, run on demand from Command Center. (Desktop GPU work and FirstSpark always-on agents split this way; the Windows Docker on-demand pattern only works for local processes.) (Local Setup Index decisions 4–5; World Monitor on Windows Workstation)
- New FirstSpark dashboard → a loopback service published with Tailscale Serve, "like YouTube Learning Center". (owner direction quoted in expert-lens-skill REPORT §6.1)
- Windows Docker apps → loopback only, started on demand when their Command Center tab opens and stopped after. Docker Desktop does not autostart. (openGym and World Monitor notes)
- Big frontier models → SecondSpark + ThirdSpark only, one model at a time. FirstSpark is never drained. (Three Spark Frontier Pair Handoff)
- Desktop GPU → one big job at a time: Qwen, ComfyUI video, or an Ollama Gemma. (Desktop Qwen Runbook)
- Duplicate model copies → don't. Ollama, LM Studio and HF/vLLM stores stay separate, and Spark models are not copied to the workstation. (Local Setup Index decision 8)
- New model versions → add them under a new alias and test them. Never overwrite `qwen3.6-35b-a3b` or revive a retired alias name. (Local Setup Index decision 10; Model And Provider Names)
- On FirstSpark → never run `ods` commands, because ODS was retired there on 2026-09-22. Use `docker compose -p spark-litellm …`. (FirstSpark Standalone LiteLLM Operations)

Data and storage
- Storage engine → SQLite in the project's data directory, with the data root set by env var (e.g. `CCE_DATA_DIR`, `STUDY_DATA_ROOT`). Verify runs on a temporary data root. (most BUILD_SPECs; creator-content-engine and personal-study-curriculum DECISIONS)
- Runtime data → a private, gitignored `data/` directory. Never commit it. Keep backups outside the repo, because untracked files confuse the runner. (AGENTS.md; paper-logbook DECISIONS)
- Dashboards over notes → Markdown is the source of truth. Weekly agent runs write a new draft with provenance and never overwrite daily sources. (Local Setup Index decisions 11–13)
- Obsidian vault writes → write only to a project-named subfolder or an export folder, behind a path guard, and never delete or rename existing notes. Hard write confinement for Hermes (`Agent Inbox/Spark Hermes/`) is planned but not enforced, so be conservative. (Local Setup Index; resume-blueprint-studio DECISIONS `RBS_PROTECTED_VAULT`)
- Model names in older notes → read them through the rename table. `spark-fast` was renamed `qwen3.6-35b-a3b` on 13 Oct. (Model And Provider Names)

Auth and secrets
- Google OAuth → recommended default: a Desktop-app OAuth client in the owner's own Google Cloud project, consent screen "In production" and unverified, because Testing mode tokens expire every 7 days. Still an open question. (paper-logbook BUILD_SPEC)
- Google Sheets → read-only OAuth with an allowlist. CSV import is the fallback. (language-learning-lab REPORT §6.16)
- Secrets → keep them in the app's gitignored `.env` or service env file, never in git, the registry, a URL or a log. FirstSpark machine secrets live in `~/.config/dgx-spark/secrets.env` (mode 600). Never print secret values. (DGX Spark Operations Setup Guide; God's Eye View; Dashboard Command Center README)
- Keys for tailnet-shared apps go in `.env`, not in in-app settings. Anyone on the tailnet can use a key the server brokers, so set quotas on metered keys first. (God's Eye View on FirstSpark)

Notifications and messaging
- Notification channel → no owner answer yet. Ask with "ntfy on the tailnet (recommended)" as the default. (expert-lens-skill REPORT Q1)
- Hermes already reports on Discord: `#automation-alerts` for failures, `#approvals` for consequential actions, with Telegram as fallback. Never run a bot token from a second gateway. (Always-On Hermes on DGX Spark)
- Sending any real message, post or email → owner approval, every time. (AGENTS.md)

Privacy
- Local-first: private data goes to the owner's own machines only (Spark and desktop over Tailscale) and never to a cloud API without approval. (ai-implementation-agency REPORT Q2; Playbook §4: "data stays local")
- Third-party map tiles and similar services leak what the user views. Ask, and name the leak in the question. (commute-copilot REPORT Q3)

Dashboard Command Center
- Registry location: `%APPDATA%\Dashboard Command Center`. The groups are **Learning, Operations, Personal, Monitoring, Nightly**. (live registry)
- Registration pattern:
  - Ids: `<id>`, endpoint `<id>-local` or `<id>-spark`, session `<id>-session`.
  - Health check on a cheap GET.
  - Back up first as `registry.pre-<id>-<yyyymmdd>.json`.
  - Pick the group by purpose; learning apps go in Learning.
  
  (World Monitor, openGym and God's Eye View notes; expert-lens-skill REPORT Q4)
- Never put cookies, tokens or passwords in the registry. Navigation groups are not auth groups. (DCC README)
- Overnight project previews go in the **Projects** group, and the Agents board's "Add previews to DCC" button puts them there through DCC's `project-dashboards.json` inbox. Agents only write `scripts/preview.ps1`/`preview.sh` and never touch the registry. Ports are under "Project previews" in the Port Registry. (owner request 2026-10-21)

Toolchain and verify
- Python → 3.12 with `uv`. Desktop has 3.12.10 and uv 0.12.17. (most BUILD_SPECs)
- Node → 22, which is what the desktop has (v22.23.1). Specs split between 22 and 24, so don't require 24 without checking. (BUILD_SPECs)
- Overnight eligibility needs `scripts/verify.ps1`. FirstSpark has no PowerShell, so Hermes-run projects also need `scripts/verify.sh`. (Project Priorities; AI Coding Playbook §6)
- Tests use synthetic fixtures and fakes (`ASR=fake`, a fake model). Real-data runs wait on an owner gate. (project DECISIONS)
- Overnight runs stay offline beyond normal package installs. Installing new system software or downloading models during a run counts as an owner gate. (paper-logbook and creator-content-engine DECISIONS)
- Lane choice:
  - Claude for UI and product feel
  - Codex for well-specified backend or CLI work
  - Hermes for private data, Spark-hosted services and long grinding work

  (Project Priorities)

## 5. Decide, don't ask

**Just decide, log it in `DECISIONS.md` and keep going:**
- Names, file layout, UI layout, ordering, copy wording, colours and placeholder art
- A port from the FirstSpark free list (registered in the same commit), or an unused loopback port on the desktop
- Any library already installed or already named in the spec. Prefer the standard library.
- Which local model or endpoint to use (section 2), timeouts and retry counts
- Fixture contents, test structure, verify gates and slice boundaries
- Docs, broken links, wikilinks, section numbering, typos and stale model names
- Which Command Center group to use (section 4) and the registry ids
- Defaults the spec calls "non-blocking". Take the spec's stated default.
- Owner gates (`G<n>`) and approval questions about anything on this list, even when BUILD_SPEC calls them owner gates: take the spec's default, else your recommended option, and log `Auto-decided <gate>` in `DECISIONS.md`. The owner overrides in the morning if they disagree.

**Wait for the owner, but never sit idle:**
- Missing credentials, tokens, OAuth clients, API keys, or sign-ins
- Spending money, enabling a metered API, sending, posting or messaging anyone
- Destructive or irreversible actions: deleting data or models, migrating real data, rewriting history, Funnel, binding 0.0.0.0
- Stopping or swapping shared services (vLLM, LiteLLM, Hermes, the GLM pair, Desktop Qwen)
- Privacy exposure: real personal data leaving the owner's machines, or a new third-party data flow
- Real data only the owner has: exports, device model, city, real accounts
- A real conflict with BUILD_SPEC, README or an earlier owner answer

When blocked:
1. Read `DECISIONS.md` → `## Owner answers (from the Agents board)` first.
2. If there is no answer, write the question into `REPORT.md` → `## Open questions` in the AGENTS.md format, with a `(recommended)` option or a `Default:` line.
3. Mark it BLOCKING only for the tasks it actually blocks.
4. Carry on with every unblocked task: fixtures, fakes, tests, docs. Stop only when nothing is left, and then write the handoff.

## 6. Where to look for more

- Shared rules: `F:\Vaults\LLMWiki\Nightly Runs\agent-rules\AGENTS.md`
- Workflow and lanes: `Nightly Runs\AI Coding Playbook.md`, `Nightly Runs\Project Priorities.md`, `Nightly Runs\Overnight Report.md`, `Nightly Runs\Preflight.md`
- Ports: `Local_Setup\FirstSpark Port Registry.md`
- Machine map and canonical decisions: `Local_Setup\Local Setup Index.md`
- Model names and renames: `Local_Setup\Model And Provider Names.md`
- Desktop LLM: `Local_Setup\Desktop Qwen Runbook.md`
- Workstation creative and search tools: `Local_Setup\Workstation ODS Lite ComfyUI VoiceStudio Runbook.md`
- Frontier pair: `Local_Setup\Three Spark Frontier Pair Handoff.md`, `Local_Setup\DGX Spark Dual-Node Configuration And Operations Reference.md`
- Router: `Local_Setup\FirstSpark Standalone LiteLLM Operations.md`
- Hermes: `Local_Setup\Always-On Hermes on DGX Spark.md`, `Local_Setup\Hermes Nightly Runs — Loop Engineering How-to.md`
- Example service write-ups: `Local_Setup\God's Eye View on FirstSpark.md` (FirstSpark), `Local_Setup\World Monitor on Windows Workstation.md` and `Local_Setup\openGym on Windows Workstation.md` (Windows on-demand)
- Command Center: `E:\GIT_ROOT\Projects\dashboard-command-center\README.md`, `docs\CAPABILITY_MANIFEST.md`
