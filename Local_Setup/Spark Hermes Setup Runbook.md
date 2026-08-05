---
title: Spark Hermes Setup Runbook
created: 2026-08-05
updated: 2026-08-05
status: active-runbook
tags:
  - dgx-spark
  - hermes
  - ods
  - runbook
---

# Spark Hermes Setup Runbook

The single ordered do-list from today's state (ODS on Spark + workstation, vLLM playbook tried once and container deleted, NVIDIA Sync working) to the target: one 24×7 Hermes on Spark serving the workstation and laptop, local-model coding in VS Code/Cursor, scheduled automations, and apps that fall back to Spark models. Rationale lives in the linked research notes; this file is only what to do, in order. Work top to bottom; each phase has a "done when" gate — do not start the next phase before passing it.

Related: [[Local Setup Index]] | [[Always-On Hermes on DGX Spark]] | [[DGX Spark ODS Playbook and Model Roadmap]] | [[personal-hermes-obsidian-multinode-design|Personal Hermes Multi-Node Design]]

## Standing answers

**Do I need ODS on Spark if the workstation also has it?** Yes — keep both, with different jobs ([[Local Setup Index]] decision 4). Spark ODS is the 24×7 plane: LiteLLM gateway, small llama.cpp automation model, Open WebUI, n8n, Qdrant/TEI. Workstation ODS is development/training only, plus an optional coding upstream. The standalone vLLM service and standalone Hermes run **beside** Spark ODS, not inside it. If one ODS is ever dropped, drop the workstation's — never Spark's.

**NVIDIA Sync vs Tailscale.** Keep NVIDIA Sync for LAN convenience (quick SSH, file drops). Tailscale is the real access layer: it is what makes the laptop work from anywhere and what every service binds to.

**Laptop role.** Thin client only: Hermes Desktop, VS Code, Tailscale, plus one small offline GGUF in LM Studio (Qwen3.5-4B class) for hackathons with no network. Nothing else is installed there.

**What runs 24×7 on Spark — and nothing else does:**

1. vLLM serving `nvidia/Qwen3.6-35B-A3B-NVFP4` → alias `spark-fast`
2. ODS llama.cpp with Qwen3.5-4B Q4 → alias `spark-small`, behind the ODS LiteLLM gateway
3. `hermes serve` + `hermes gateway` (one profile, two systemd services)
4. Hermes cron + n8n — the only production schedulers anywhere
5. Tailscale, DGX Dashboard, monitoring

Everything else (SGLang, big models, fine-tunes, demos) is on-demand or ephemeral.

---

## Phase 0 — Foundation (one evening, ~2–3 h)

Goal: Spark is safely reachable and inventoried before anything new is installed.
**Done when:** SSH and VS Code reach Spark over Tailscale from the laptop on a phone hotspot, and the audit output is saved.

1. Install Tailscale on all three machines — Spark via the [Tailscale playbook](https://build.nvidia.com/spark/tailscale) (configure the existing ODS/host path, one owner, don't double-install). Same tailnet, MagicDNS on.
2. From the laptop on a **non-home** network: `ssh <user>@spark` (tailnet name). Must work before continuing.
3. Audit the Spark and paste the output into a new ops note in this folder:

   ```bash
   ods status && ods list
   docker ps --format 'table {{.Names}}\t{{.Ports}}\t{{.Status}}'
   df -h && free -h && nvidia-smi
   ```

4. Create the canonical model root once: `sudo mkdir -p /srv/models/hf` on the big NVMe ([[DGX Spark ODS Playbook and Model Roadmap#Safe installation pattern]]). Confirm ≥ 200 GB free.
5. VS Code Remote-SSH into Spark ([playbook](https://build.nvidia.com/spark/vscode)); confirm the [DGX Dashboard](https://build.nvidia.com/spark/dgx-dashboard) loads. Note ports already in use: ODS llama.cpp 8080, ODS hermes-proxy 9120.

## Phase 1 — Serving core online (half a day; downloads run unattended)

Goal: `spark-fast` and `spark-small` answering through one gateway with stable aliases.
**Done when:** an OpenAI client on the workstation gets completions from `http://spark:4000/v1` for both aliases, and both containers auto-restart after `sudo reboot`.

1. Download weights into the canonical root (start these first; they run while you do step 2):

   ```bash
   hf download nvidia/Qwen3.6-35B-A3B-NVFP4 --local-dir /srv/models/hf/qwen3.6-35b-a3b-nvfp4
   hf download Qwen/Qwen3-Embedding-0.6B --local-dir /srv/models/hf/qwen3-embedding-0.6b
   hf download Qwen/Qwen3-Reranker-0.6B --local-dir /srv/models/hf/qwen3-reranker-0.6b
   ```

   Plus one trusted Q4 GGUF of **Qwen3.5-4B** into the ODS model directory ([[dgx-spark-current-models-report]] tier 2).
2. Redo the [vLLM playbook](https://build.nvidia.com/spark/vllm) — this time persistent: pinned NVIDIA vLLM container tag, weights mounted from `/srv/models`, `--restart unless-stopped`, port 8000. Use the full model-card flag set from [[DGX Spark ODS Playbook and Model Roadmap#2. Qwen3.6 primary vLLM service]] with two overrides while validating: `--max-model-len 65536 --max-num-seqs 4`.

   ```bash
   docker run -d --name vllm-spark-fast --restart unless-stopped \
     --gpus all --ipc=host -p 8000:8000 \
     -v /srv/models/hf:/models \
     <pinned nvidia vllm image> \
     vllm serve /models/qwen3.6-35b-a3b-nvfp4 [model-card flags, 64K/4-seq]
   ```

   Record image digest + flags in the ops note. Because weights live on the host, deleting the container never re-downloads the model.
3. Smoke test: one completion, one tool-call, one streamed response, then 4 parallel requests. Check `nvidia-smi` memory and that answers stay coherent.
4. Point the existing ODS llama.cpp service at the Qwen3.5-4B Q4 GGUF with 32K context. Verify port 8080 answers. Do not install a second llama.cpp server.
5. Enable the ODS LiteLLM extension (port 4000) and add aliases: `spark-fast` → `localhost:8000/v1`, `spark-small` → `localhost:8080/v1`. Create two virtual keys: `personal` and `apps`. Test both aliases from the workstation over the tailnet. From now on, **nothing ever talks to :8000 or :8080 directly** — aliases only ([[Always-On Hermes on DGX Spark#Model routing]]).

## Phase 2 — Hermes 24×7 (half a day)

Goal: one authoritative Hermes on Spark; workstation + laptop + phone are clients of it.
**Done when:** after `sudo reboot` with no manual action, Hermes Desktop on both machines reconnects, Discord answers, and a skill added from the workstation is visible from the laptop.

1. On Spark: create a dedicated unprivileged `hermes` user, install the **current standalone Hermes release** (not the ODS-bundled v0.14 image), set one explicit `HERMES_HOME`, profile `personal`.
2. Configure its provider as OpenAI-compatible → `http://localhost:4000/v1`, default model `spark-fast`, auxiliary/background model `spark-small`, using the `personal` LiteLLM key. Hermes never sees ports 8000/8080 or checkpoint names.
3. Create two systemd services — `hermes-serve` (bind to the Spark Tailscale IP, port 9119) and `hermes-gateway` — absolute paths, `After=network-online.target`, `Restart=on-failure` ([[Always-On Hermes on DGX Spark#24×7 service shape]]). Restrict 9119 with Tailscale ACLs to your workstation + laptop identities. Reboot and verify both come back.
4. Disable or clearly rename the ODS-bundled Hermes so there is exactly one personal agent ([[Always-On Hermes on DGX Spark#ODS Hermes auth proxy]] — do not point Desktop at :9120).
5. Install Hermes Desktop on workstation and laptop → remote connection to Spark. Then run `hermes gateway setup` for Discord using the channel scheme in [[Always-On Hermes on DGX Spark#Daily phone interface]] (`#inbox` free-response, rest mention-gated, failures → `#automation-alerts`), Telegram as fallback. Allowlist only your own Discord identity. Back up the profile with `hermes backup` and test a restore.

## Phase 3 — Coding on local models (2–3 h)

Goal: VS Code and Cursor use Spark models daily; subscription decision comes from data, not vibes.
**Done when:** one real coding task per day runs through `spark-fast` for two weeks.

1. VS Code (workstation + laptop): install Continue (or Cline), add an OpenAI-compatible provider `http://spark:4000/v1` with the `personal` key — chat/edit → `spark-fast`, autocomplete → `spark-small`. NVIDIA's [Vibe Coding](https://build.nvidia.com/spark/vibe-coding) / [CLI Coding Agent](https://build.nvidia.com/spark/cli-coding-agent) playbooks are the reference — reuse your endpoint, don't let them install another model stack.
2. Cursor: Settings → Models → override OpenAI base URL → `http://spark:4000/v1` + key, add custom model `spark-fast`. Known limit: Cursor Tab autocomplete still runs on Cursor's cloud; chat/composer requests go local.
3. Claude Code against local (experiment): `ANTHROPIC_BASE_URL=http://spark:4000` via LiteLLM's Anthropic-format passthrough mapped to `spark-fast`. Test tool-calls, streaming, and long context hard before trusting it ([[local-ai-architecture-research]] gateway caution).
4. Optional low-latency `code` route: on the RTX 5000, serve a coder GGUF (Qwen3.6-27B or Gemma 4 31B QAT — [[dgx-spark-current-models-report]] workstation-first picks) with llama-server or LM Studio; register it in Spark LiteLLM as `code` with fallback → `spark-fast`, so coding survives workstation sleep.
5. Keep all subscriptions for two weeks; note which tasks local handled fully. Then cut, remembering consumer subscriptions are not API keys for unattended services ([[Local Setup Index]] decision 9).

## Phase 4 — Automation (half a day, then grows)

Goal: scheduled jobs run on Spark, pinned to aliases, reporting to Discord.
**Done when:** the chaos test passes — reboot Spark (everything returns), stop vLLM (jobs fail gracefully and alert), sleep the workstation (`code` falls back).

1. First Hermes cron job: a morning brief pinned to `spark-small`, with timeout, budget, and delivery to `#daily-brief`. Pin model + route on **every** job — Hermes intentionally fails closed on unpinned jobs after provider changes.
2. `ods enable n8n` on **Spark** for deterministic multi-step workflows; every LLM node calls a LiteLLM alias. Workstation n8n stays development-only — one production owner per job ([[personal-hermes-obsidian-multinode-design|design note]] failure rules).
3. Routing discipline for jobs: hourly/routine → `spark-small`; only genuinely hard steps → `spark-fast`. Don't wake the big lane on a schedule.
4. Failures → `#automation-alerts`; anything consequential (sends, publishes, deletes) waits in `#approvals`. Add an idempotency key to any job with side effects.
5. Run the chaos test above and fix what breaks before adding more jobs.

## Phase 5 — Obsidian + retrieval (2–3 h, plus an eval)

Goal: Hermes can read the vault safely; retrieval is measured before it's trusted.
**Done when:** vault questions answer correctly from the Spark replica and a bad-retrieval spot-check is documented.

1. On Spark: Node.js 22+, official `obsidian-headless`, a **new replica directory** (never inside `HERMES_HOME`, never the same folder as another sync tool), `pull-only` mode, `ob sync --continuous` as a service.
2. Give Hermes read-only access to the replica. No write access anywhere in the vault yet.
3. Stand up TEI embeddings + reranker (the 0.6B pair from Phase 1) as services; index the replica; benchmark retrieval on ~20 real questions about your own notes before believing it ([[DGX Spark ODS Playbook and Model Roadmap]] tier 3).
4. Only after deliberate conflict testing: flip the replica to bidirectional and restrict Hermes writes to `Agent Inbox/Spark Hermes/` with unique timestamped filenames ([[personal-hermes-obsidian-multinode-design#Safe agent-writing pattern]]).

## Phase 6 — Exploration lanes (ongoing — this order)

Now the fun: engines, big models, fine-tuning. One lane at a time, always through the gateway.

1. **SGLang A/B** ([playbook](https://build.nvidia.com/spark/sglang)): same checkpoint, quant, context, prompts, and concurrency as vLLM; record TTFT p50/p95, per-stream and aggregate tok/s, tool-call validity. Keep the winner per workload. Never Laguna-NVFP4 on SGLang while Poolside's corrupt-output warning stands.
2. **Big-model exclusive lane** (`spark-big`): Qwen3.5-122B-A10B-NVFP4 first, using the drain → stop → verify-memory → start → smoke-test → switch-alias protocol in [[DGX Spark ODS Playbook and Model Roadmap#Concurrency-safe routing and automatic switching]]. Then Laguna-S-2.1 (own pinned vLLM env, coding evals); Step-3.7 and DeepSeek V4 last, maintenance windows only. Never fit-to-OOM on the production Spark — post-OOM low-power state requires a power cycle ([[dgx-spark-twitter-bookmarks-analysis]]).
3. **Vision/document lane**: Gemma-4-26B-A4B-NVFP4 on demand as `spark-vision`; add Nemotron Omni when document/VSS work starts.
4. **Fine-tuning ladder** (workstation-first): [PyTorch](https://build.nvidia.com/spark/pytorch-fine-tune) → [Unsloth](https://build.nvidia.com/spark/unsloth) → [LLaMA Factory](https://build.nvidia.com/spark/llama-factory) → [NeMo](https://build.nvidia.com/spark/nemo-fine-tune), one base model + dataset + eval across all four; [NVFP4-quantize](https://build.nvidia.com/spark/nvfp4-quantization) the winner and serve it through the same gateway as an alias. Also on the ladder later: [TRT-LLM](https://build.nvidia.com/spark/trt-llm), [NIM](https://build.nvidia.com/spark/nim-llm), [speculative decoding](https://build.nvidia.com/spark/speculative-decoding).
5. **FDE portfolio** (ephemeral demos, reuse gateway services): [RAG in AI Workbench](https://build.nvidia.com/spark/rag-ai-workbench) → [txt2kg](https://build.nvidia.com/spark/txt2kg) → [multi-agent chatbot](https://build.nvidia.com/spark/multi-agent-chatbot) → [multi-modal](https://build.nvidia.com/spark/multi-modal-inference) → [VSS capstone](https://build.nvidia.com/spark/vss). Make two of them production-shaped with evals, observability, and failure handling.

Skip list (unchanged from [[dgx-spark-playbook-roadmap-draft|roadmap draft]]): multi-Spark topologies (no second Spark), Isaac/Reachy (no hardware), domain demos unless role-relevant, OpenClaw/NemoClaw except as isolated comparisons after Hermes is stable.

## Guardrails — never do these

- Two Hermes instances with the same profile, bot tokens, or schedules.
- Two sync systems on one vault replica, or Hermes state/secrets inside the vault.
- Hot-swapping a production alias per request; the big lane is queued and exclusive.
- OOM experiments on the production Spark.
- External/project traffic routed into workstation services, or hosted fallback on private routes without explicit opt-in.
- Secrets, OAuth sessions, `state.db`, or browser cookies in Git or Obsidian.
