# Local AI architecture research: laptop, RTX workstation, and DGX Spark

Research date: 2026-07-27

This note verifies the constraints and building blocks behind a three-device setup using ChatGPT/Codex, Claude/Claude Code, Gemini, Hermes Agent, ODS, and locally served open models. It uses first-party product documentation, upstream source repositories, and this ODS checkout.

## Executive conclusions

1. **Do not treat the three $20 consumer subscriptions as three generic API keys.** ChatGPT and OpenAI API billing are separate; Claude.ai and Anthropic Console/API billing are separate; Gemini API uses its own AI Studio/Cloud project, quota, and billing. The subscriptions do cover certain official coding clients: ChatGPT Plus includes Codex, and Claude Pro includes Claude Code. Google AI Pro currently includes various Google developer-product benefits, but the Gemini API still has its own project/free-or-paid tier. ([OpenAI](https://help.openai.com/en/articles/8156019-is-api-usage-included-in-chatgpt-subscriptions-even-if-i-have-a-paid-chatgpt-account), [Anthropic](https://support.anthropic.com/en/articles/9876003-i-subscribe-to-a-paid-claude-ai-plan-why-do-i-have-to-pay-separately-for-api-usage-on-console), [Google Gemini API billing](https://ai.google.dev/gemini-api/docs/billing), [Google AI Pro benefits](https://support.google.com/googleone/answer/14534406))
2. **Use official sign-in flows where a client explicitly supports them.** Codex app/CLI/IDE can sign in with ChatGPT; Claude Code can sign in with Claude Pro/Max. Hermes upstream currently implements an OpenAI Codex device-code provider, but its Anthropic OAuth path explicitly says Claude Pro is unsupported: it requires Claude Max plus extra-usage credits, or an Anthropic API key. Hermes's Google/Gemini provider takes a Gemini API key, not a Google AI Pro consumer entitlement. ([OpenAI Codex plans](https://help.openai.com/en/articles/11369540/), [Claude Code with Pro/Max](https://support.anthropic.com/en/articles/11145838-using-claude-code-with-your-pro-or-max-plan), [Hermes providers](https://hermes-agent.nousresearch.com/docs/integrations/providers))
3. **Make the DGX Spark the always-on inference/agent appliance, not the only copy of state.** Run ODS, Hermes profiles/gateway, a model-serving tier, LiteLLM, schedules, observability, and durable storage there. Reach it from the laptop and workstation through an authenticated private network. The RTX workstation should remain a separate training/evaluation node and a secondary inference endpoint; the laptop should normally be a thin client with one small emergency local model.
4. **Start with ODS's supported llama.cpp/GGUF path or Ollama/LM Studio, not vLLM/SGLang by default.** Ollama and LM Studio are model managers plus servers and can load/unload on demand. vLLM and SGLang are higher-throughput serving runtimes; they accept compatible Hugging Face checkpoints directly and do not require Ollama or LM Studio first. NVIDIA publishes current DGX Spark playbooks for all of Ollama, LM Studio, llama.cpp, vLLM, and SGLang. ([NVIDIA Spark playbooks](https://build.nvidia.com/spark), [vLLM on Spark](https://build.nvidia.com/spark/vllm), [SGLang on Spark](https://build.nvidia.com/spark/sglang), [LM Studio on Spark](https://build.nvidia.com/spark/lm-studio))
5. **"Automatic hotswap" should mean routing plus controlled eviction, not changing one global model under active jobs.** Put stable logical model names behind a gateway, pin every scheduled job to a route, and let the serving layer keep, evict, or prewarm models. LM Studio has JIT loading, TTL, and auto-evict; Ollama exposes `keep_alive`, concurrent-model limits, and queuing. ODS's general model load path updates config and restarts its inference service, so it is an operator-level swap rather than a zero-cold-start multi-model scheduler. ([LM Studio TTL/auto-evict](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict), [Ollama FAQ](https://docs.ollama.com/faq), [ODS model management](https://github.com/Osmantic/ODS/blob/main/docs/MODEL-MANAGEMENT.md))

## Canonical Hermes deployment clarification

The authoritative personal Hermes profile is on Spark. Two separately supervised processes use that same Spark profile:

- `hermes serve` is the authenticated HTTP/WebSocket backend used by Hermes Desktop on the workstation and laptop.
- `hermes gateway` owns Discord, Telegram, other messaging adapters, and Hermes cron.

Tailscale provides private reachability but does not synchronize local Hermes installations. Profile-level skills, MCPs, providers, memory, sessions, and schedules changed through a Desktop client connected to Spark are stored on Spark. Desktop UI preferences remain per device, and remote file tools operate on the Spark filesystem. Use an optional, separately named workstation profile only when direct access to workstation-only files is required.

The ODS `hermes-proxy` is a Caddy/browser-cookie gate for ODS's embedded Hermes dashboard, not a substitute for the native remote Desktop endpoint. The ODS checkout reviewed for these notes pins Hermes `v2026.5.16`/v0.14, which predates the native Desktop/remote-backend release. Initially run a current standalone Hermes beside ODS, disable or clearly rename the old ODS-bundled Hermes, and upgrade the ODS integration only after backup and compatibility testing. The exact topology and rollout are in [[Always-On Hermes on DGX Spark]].

## Subscription and authentication boundaries

### ChatGPT Plus / Codex

- OpenAI says ChatGPT and the API are billed and managed separately. A ChatGPT Plus subscription is not a general-purpose `OPENAI_API_KEY` allowance. ([OpenAI](https://help.openai.com/en/articles/8156019-is-api-usage-included-in-chatgpt-subscriptions-even-if-i-have-a-paid-chatgpt-account))
- Codex is included with ChatGPT Plus and can be used through the Codex app, CLI, IDE extension, and web after signing in with ChatGPT. Usage is plan-limited, and additional credits may be offered after the included limit is reached. ([OpenAI](https://help.openai.com/en/articles/11369540/))
- The Codex client sign-in is not equivalent to making the OpenAI API free for LiteLLM, n8n, or arbitrary applications. OpenAI documents ChatGPT/API separation even though Codex has a supported ChatGPT sign-in surface.
- Hermes upstream advertises a first-class "OpenAI Codex" provider using device-code authentication and can import Codex CLI credentials from `~/.codex/auth.json`. This is a Hermes feature, not evidence that a ChatGPT subscription is a generic OpenAI API credential. Use Hermes's explicit `hermes model`/device-code flow; do not copy browser cookies or invent token bridges. ([Hermes providers](https://hermes-agent.nousresearch.com/docs/integrations/providers))

### Claude Pro / Claude Code

- Claude Pro is a Claude.ai subscription and does not include Anthropic Console API usage. API use is separately funded. ([Anthropic](https://support.anthropic.com/en/articles/9876003-i-subscribe-to-a-paid-claude-ai-plan-why-do-i-have-to-pay-separately-for-api-usage-on-console))
- Claude Code is included with Claude Pro and Max when the user selects the Claude App login option. It has plan rate limits and can separately offer continued use through API credits; declining that option keeps usage within the subscription allocation. ([Anthropic](https://support.anthropic.com/en/articles/11145838-using-claude-code-with-your-pro-or-max-plan), [Claude Code setup](https://docs.anthropic.com/en/docs/claude-code/getting-started))
- Hermes's current Anthropic OAuth documentation is narrower: it says the Hermes path works only for Claude Max with purchased extra-usage credits; Claude Pro subscribers cannot use it. Otherwise Hermes needs `ANTHROPIC_API_KEY`, billed independently. ([Hermes providers, Anthropic section](https://hermes-agent.nousresearch.com/docs/integrations/providers#anthropic-native))
- Claude Code can be pointed at an LLM gateway through `ANTHROPIC_BASE_URL`, and Anthropic documents LiteLLM as an example. That is a gateway/API configuration, not a promise that every non-Claude local model will behave correctly with Claude Code's prompts and tool protocol. Test tool use, streaming, thinking fields, context limits, and model-name mappings before relying on it. ([Anthropic LLM gateway configuration](https://docs.anthropic.com/en/docs/claude-code/llm-gateway))

### Google AI Pro / Gemini

- Gemini API access is organized around Google AI Studio/Cloud projects and API keys. New accounts may have an API free tier; paid tiers require linking billing and are metered separately. ([Gemini API billing](https://ai.google.dev/gemini-api/docs/billing))
- Google AI Pro includes consumer and developer-product benefits such as Gemini apps, Gemini in Workspace products, Jules, and Google developer-program benefits. This does not turn the consumer plan into an unlimited `GEMINI_API_KEY`. ([Google AI Pro benefits](https://support.google.com/googleone/answer/14534406))
- Hermes's Gemini provider explicitly expects `GOOGLE_API_KEY` or `GEMINI_API_KEY`; its Vertex route uses Google Cloud credentials/billing. ([Hermes providers](https://hermes-agent.nousresearch.com/docs/integrations/providers))
- A time-sensitive 2026 constraint: Google says consumer-account access for Gemini Code Assist IDE extensions and Gemini CLI, including Google AI Pro/Ultra tiers, was retired on 2026-06-18, directing consumers toward Antigravity products; Standard/Enterprise Code Assist was not affected. Verify the exact Google client you plan to use rather than assuming an older "Login with Google" Gemini CLI guide still applies. ([Google](https://developers.google.com/gemini-code-assist/docs/deprecations/code-assist-individuals))

### Practical rule

Keep four credential classes separate:

1. interactive consumer OAuth for official or explicitly supported clients;
2. metered API keys for unattended services and gateways;
3. local inference tokens for your private endpoints;
4. MCP/tool credentials for the external systems those tools can change.

Do not sync credential stores such as `auth.json`, browser cookies, `.env`, API keys, or service-account files through Git. Re-authenticate each device or provision secrets from a password manager/secret store. A 24x7 automation must not depend on a short-lived desktop login flow unless that provider explicitly documents unattended refresh.

## Recommended three-device topology

### DGX Spark: control plane plus large-model inference

The Spark has a 20-core ARM64 CPU, Blackwell GPU, 128 GB coherent unified memory, and 273 GB/s memory bandwidth. NVIDIA ships DGX OS, CUDA, Docker, and NVIDIA Container Runtime support, and recommends NGC/containers for compatible ARM64 software. Not every NIM has a DGX Spark build, so check the Spark collection/support matrix before pulling one. ([NVIDIA system overview](https://docs.nvidia.com/dgx/dgx-spark/system-overview.html), [specifications](https://www.nvidia.com/en-sg/products/workstations/dgx-spark/), [container runtime](https://docs.nvidia.com/dgx/dgx-spark/nvidia-container-runtime-for-docker.html), [NGC](https://docs.nvidia.com/dgx/dgx-spark/ngc.html))

Recommended responsibilities:

- ODS runtime, dashboard, Open WebUI, Hermes, LiteLLM, n8n, Qdrant, observability, and schedules;
- one large default agent/coding model;
- one smaller resident utility model if memory permits;
- remote OpenAI-compatible endpoints exposed only through authenticated LAN/VPN access;
- durable model, config, and workflow backups.

Use NVIDIA's ARM64/GB10 playbooks or known-compatible containers. Do not assume an arbitrary `linux/amd64` CUDA image will run efficiently or at all on the ARM64 host.

### RTX workstation: training/evaluation and burst inference

Recommended responsibilities:

- LoRA/QLoRA, distillation, SLM experiments, data preparation, and evaluations;
- a second OpenAI-compatible endpoint for models that fit in 48 GB;
- image/video or other GPU workloads that should not evict the Spark's always-on agent model;
- development copies of dashboards and automations before promotion.

Treat the exact GPU model, driver, OS, and CUDA compatibility as inputs to runtime selection. "RTX 5000 48 GB" is not enough to safely prescribe a particular quantization/kernel stack without verifying the full SKU and software versions.

### Gaming laptop: thin client with graceful offline mode

With 6 GB VRAM, prioritize:

- Codex/Claude official clients using their subscription sign-ins;
- remote access to the Spark gateway;
- a small quantized local model for offline/event use;
- local embeddings or a draft/utility model only if they do not interfere with the active workload.

Do not copy the full Spark model library to the laptop. Sync declarations and project instructions; fetch only the small artifacts needed for travel.

## Choosing an inference runtime

### ODS llama-server / llama.cpp

ODS's supported default local path is a llama.cpp `llama-server` serving GGUF over an OpenAI-compatible API. ODS selects a hardware-tier GGUF, manages it through the dashboard/CLI, and wires Open WebUI, Hermes, and LiteLLM around it. The current checkout assigns ARM64 unified-memory 90+ GB hosts such as DGX Spark to its `NV_ULTRA` policy and currently selects a Qwen 35B-class MoE GGUF rather than the AMD64 coding-model choice. ([ODS README](https://github.com/Osmantic/ODS), [model management](https://github.com/Osmantic/ODS/blob/main/docs/MODEL-MANAGEMENT.md), [Hermes integration](https://github.com/Osmantic/ODS/blob/main/docs/HERMES.md))

Best when:

- simplicity, broad GGUF support, and ODS integration matter most;
- request concurrency is moderate;
- you want partial CPU/GPU offload and quantized models.

Limitation for this design: loading a catalog/manual model updates ODS config and restarts the local inference service. Hermes also has its own model name in `data/hermes/config.yaml`, so manual changes must be kept aligned. ODS bootstrap promotion is automated, but normal arbitrary per-request model selection is not the same as keeping several independent model servers ready. ([ODS model management](https://github.com/Osmantic/ODS/blob/main/docs/MODEL-MANAGEMENT.md))

### Ollama

Ollama is the easiest headless model-manager/server path. `ollama pull` downloads into Ollama's store; API calls can set `keep_alive`; idle models unload; multiple models can remain resident if memory permits; otherwise requests queue until room is available. `OLLAMA_MAX_LOADED_MODELS`, `OLLAMA_NUM_PARALLEL`, and `OLLAMA_MAX_QUEUE` control those behaviors. ([Ollama API](https://docs.ollama.com/api/generate), [Ollama FAQ](https://docs.ollama.com/faq))

Best when:

- you want simple pull/run semantics and automatic memory management;
- model cold-start latency is acceptable;
- maximum throughput is not the primary goal.

ODS contains an Ollama extension, but ODS's core inference contract remains its own llama-server. Enabling the extension does not automatically make every ODS client dynamically route across Ollama models; configure the gateway/routes deliberately. ([ODS Ollama extension](https://github.com/Osmantic/ODS/blob/main/extensions/library/services/ollama/README.md))

### LM Studio / `llmster`

LM Studio is unusually well matched to the requested "no manual swapping" behavior. It supports a headless server, native load/unload/download APIs, OpenAI- and Anthropic-compatible endpoints, JIT model loading, idle TTL, and auto-eviction. With auto-evict enabled, a new JIT model unloads the prior JIT model before loading. NVIDIA's Spark guide also documents LM Link for encrypted access from another machine. ([LM Studio REST API](https://lmstudio.ai/docs/developer/rest), [TTL/auto-evict](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict), [DGX Spark guide](https://build.nvidia.com/spark/lm-studio))

Best when:

- interactive model discovery and remote administration matter;
- automatic JIT load/unload is more important than peak concurrent throughput;
- you want one runtime that can appear locally on the laptop while inference happens on Spark.

### vLLM

vLLM is a serving engine optimized for throughput with PagedAttention and continuous batching. NVIDIA's Spark playbook provides a pre-built-container or source-build path for ARM64/Blackwell and a tested model matrix. It takes a Hugging Face model ID or checkpoint; Ollama/LM Studio is not a prerequisite. ([NVIDIA vLLM playbook](https://build.nvidia.com/spark/vllm), [vLLM docs](https://docs.vllm.ai/))

Best when:

- one model has several concurrent agents/users;
- predictable server operation and high token throughput matter;
- the selected architecture/quantization is in the current support matrix.

Operationally, plan one persistent model deployment per server process (or separate instances/ports) and put a router above them. Dynamic replacement of a large vLLM process is a deployment event with a cold load, not an Ollama-style catalog switch.

### SGLang

SGLang is another high-performance LLM/VLM serving framework. NVIDIA publishes an optimized CUDA 13 container path for Spark and a tested model/quantization matrix. Like vLLM, it consumes compatible checkpoints directly. ([NVIDIA SGLang playbook](https://build.nvidia.com/spark/sglang), [SGLang docs](https://docs.sglang.ai/))

Best when:

- its supported model/runtime features benchmark better for the actual workload;
- structured/agentic serving or VLM workloads benefit from its runtime;
- you are prepared to manage server deployments rather than rely on a desktop model library.

### NIM / TensorRT-LLM

Consider these after the basic architecture is stable and a supported Spark model/profile exists. NVIDIA warns that not every NIM has a Spark-compatible image; production support may require NVIDIA AI Enterprise. ([NVIDIA NGC/NIM guidance](https://docs.nvidia.com/dgx/dgx-spark/ngc.html))

### Model acquisition rule

Choose the runtime and artifact format first:

- ODS/llama.cpp: download a compatible GGUF into ODS's model directory/catalog;
- Ollama: use `ollama pull` or create/import an Ollama model;
- LM Studio: use its catalog/download/import commands;
- vLLM/SGLang: point the server at a compatible Hugging Face model/checkpoint or mounted cache;
- NIM: pull the model-specific compatible NGC container/profile.

There is no need to install a model "through Ollama first" before vLLM or SGLang. GGUF and Hugging Face safetensors/FP8/NVFP4 checkpoints are different artifacts and may require separate disk copies. A shared Hugging Face cache can reduce duplicate downloads for runtimes that use the same checkpoint format.

## Routing, hot swapping, and scheduled work

Use a gateway model catalog with stable intent names instead of allowing every agent to choose raw model IDs:

| Logical route | Intended backend |
|---|---|
| `local/fast` | small resident model on Spark or workstation |
| `local/code` | coding model on the RTX workstation or Spark |
| `local/deep` | largest Spark model |
| `local/vision` | dedicated VLM endpoint |
| `cloud/codex` | supported Codex OAuth client path, interactive |
| `cloud/claude` | official Claude Code login or separately billed API |
| `cloud/gemini` | separately metered Gemini API route |

LiteLLM is suited to the northbound gateway: it exposes one OpenAI-compatible endpoint, multiple providers/deployments, retries/fallbacks, budgets, and routing. ODS already includes LiteLLM local/cloud/hybrid configurations. The shipped ODS configuration is a starting point, not the requested policy engine; add explicit routes for the Spark and workstation endpoints and avoid a wildcard that silently maps every requested name to one currently loaded GGUF. ([LiteLLM](https://docs.litellm.ai/), [ODS LiteLLM extension](https://github.com/Osmantic/ODS/blob/main/extensions/services/litellm/README.md))

Recommended serving patterns:

- **Interactive pool:** LM Studio or Ollama on Spark, with JIT/TTL/keep-alive and a short queue.
- **Always-hot pool:** one or two vLLM/SGLang/llama-server deployments for daily high-volume routes.
- **Training node:** workstation endpoints registered only when healthy; never make an automation depend exclusively on a sleeping workstation.
- **Prewarming:** a scheduler sends a tiny request before a known workload window, then permits TTL eviction afterward.
- **Admission control:** serialize large-model swaps and reject or queue when training has reserved the GPU.

Do not call a model replacement "zero downtime" unless there are at least two serving replicas/endpoints and the gateway drains traffic from the old one only after the new one passes health and a real completion probe.

Hermes has its own relevant controls:

- `/model` can switch among already configured providers/models; its API can accept a model field/header for per-request selection. ([Hermes programmatic integration](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/developer-guide/programmatic-integration.md))
- Hermes cron jobs can pin provider/model and attach skills. Upstream intentionally fails closed after an unpinned job's global provider changes, to avoid silently moving unattended work onto a paid model. Pin every recurring job. ([Hermes cron](https://hermes-agent.nousresearch.com/docs/user-guide/features/cron))
- Hermes supports isolated profiles, each with its own config, secrets, skills, memory, sessions, cron jobs, and database. Use separate `personal`, `coder`, `research`, and `automation` profiles rather than mixing all memory and permissions. ([Hermes profiles](https://hermes-agent.nousresearch.com/docs/user-guide/profiles))
- Hermes can delegate to isolated subagents. A durable background task should use cron/background execution rather than synchronous delegation, because interrupting the parent cancels its delegate children. ([Hermes delegation](https://hermes-agent.nousresearch.com/docs/guides/delegation-patterns/))

## Mixing GPT, Claude, Gemini, and open models

Yes, mixed-model orchestration is technically sound when the orchestrator owns a provider-neutral task contract:

1. the orchestrator decomposes a job;
2. subagents receive bounded inputs, tool permissions, time/token budgets, and an output schema;
3. a verifier checks evidence/tests rather than trusting model agreement;
4. the orchestrator merges only validated results.

Hermes supports multiple providers, custom OpenAI-compatible endpoints, auxiliary-model overrides, fallback providers, and child-agent delegation. LiteLLM supplies a common northbound API for metered API/local endpoints. ([Hermes providers](https://hermes-agent.nousresearch.com/docs/integrations/providers), [Hermes delegation](https://hermes-agent.nousresearch.com/docs/guides/delegation-patterns/), [LiteLLM](https://docs.litellm.ai/))

Important constraints:

- A consumer subscription usable in its official client is not automatically callable as a subagent API.
- Tool-call JSON, reasoning fields, multimodal input, context limits, and stop behavior differ across local models and compatibility layers.
- The orchestrator should route by measured capability and current availability, not brand name.
- Give destructive or externally visible tools to the smallest possible set of agents; let cheap/local subagents do read-only exploration and drafts.
- Preserve provenance: every subagent result should identify model route, prompt/version, source inputs, tool outputs, and validation status.

If a tool/service is built with a frontier model, its runtime does not inherently depend on that model. You can replace later inference with an open model if the tool boundary is explicit and you have regression evals for tool selection, argument correctness, structured output, safety, latency, and context length. The code and protocol are portable; behavior quality is not automatically portable.

## Configuration and state synchronization

There is no universal cross-app sync format. Use one version-controlled **declarative source repository** and generate client-specific files.

Recommended repository contents:

```text
ai-fleet/
  inventory/            # device names, URLs, capabilities; no secrets
  routes/               # logical model catalog and fallback policy
  skills/               # canonical Agent Skills folders
  mcp/                  # neutral server declarations/templates
  prompts/              # shared project instructions
  clients/
    codex/
    claude/
    gemini/
    hermes/
    ods/
  deploy/               # idempotent bootstrap/validation scripts
  checks/               # health, tool-call, and model regression tests
```

Sync these:

- project `AGENTS.md` and shared instruction fragments;
- canonical `SKILL.md` directories and non-secret assets/scripts;
- MCP server names, commands, URLs, scopes, and required secret names;
- ODS extension manifests, LiteLLM routes, Hermes non-secret profile templates, n8n workflow exports;
- pinned container/runtime/model versions and health checks.

Do not sync these through source control:

- OAuth/auth files, `.env`, API keys, refresh tokens, service-account JSON;
- chat histories, memory databases, personal profiles, raw tool logs containing private data;
- machine-specific absolute paths unless rendered from inventory.

Client adapters are necessary:

- Codex distinguishes global/project config, `AGENTS.md`, skills, plugins, and MCP settings; Codex's own source describes skills under `.codex` and supports symlinked skill folders. ([Codex source](https://github.com/openai/codex/blob/main/codex-rs/skills/src/assets/samples/openai-docs/SKILL.md), [Codex skill loading](https://github.com/openai/codex/blob/main/codex-rs/app-server/README.md#skills))
- Claude Code has user/project/local settings scopes and project `.mcp.json`; shared project MCP declarations can be committed, while local/user settings hold private overrides. ([Claude MCP](https://docs.anthropic.com/en/docs/claude-code/mcp), [Claude settings precedence](https://docs.anthropic.com/en/docs/claude-code/iam))
- Gemini CLI uses `~/.gemini/settings.json` and project `.gemini/settings.json`, with `mcpServers`; it can be configured to load `AGENTS.md` alongside `GEMINI.md`. Verify current product availability before standardizing around this client because Google's consumer CLI access changed in June 2026. ([Gemini settings](https://geminicli.com/docs/cli/settings/), [Gemini context files](https://geminicli.com/docs/cli/gemini-md/), [Gemini MCP](https://geminicli.com/docs/tools/mcp-server/))
- Hermes's source of truth is `~/.hermes/` or a named profile; it supports external skill directories and the Agent Skills standard. ODS containerizes this under its data directory and adds an ODS-generated provider/model config. ([Hermes skills](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills), [ODS Hermes](https://github.com/Osmantic/ODS/blob/main/docs/HERMES.md))

Use a one-way render/deploy process from the canonical repository into each application's native paths. Do not make three applications write into one live settings file: their schemas, update behavior, permission models, and credential stores differ.

## ODS-specific operating guidance

ODS is most valuable here as the appliance/control plane around inference, not as a distributed GPU scheduler:

- core local inference: llama-server/GGUF;
- stable client entry point: LiteLLM;
- user interface: Open WebUI and dashboard;
- agent: Hermes;
- automation: n8n and Hermes cron;
- RAG/observability: Qdrant, embeddings, Token Spy/Langfuse;
- extension framework for additional services.

The current ODS docs define local, cloud, hybrid, and other provider modes, with provider-neutral readiness as the goal. Its default LiteLLM local route points to one llama-server; cloud/hybrid routes require actual API keys. ([ODS provider modes](https://github.com/Osmantic/ODS/blob/main/docs/ENGINE-PROVIDER-MODES.md), [ODS mode switching](https://github.com/Osmantic/ODS/blob/main/docs/MODE-SWITCH.md), [ODS LiteLLM extension](https://github.com/Osmantic/ODS/blob/main/extensions/services/litellm/README.md))

Recommended division:

- **ODS on Spark:** authoritative production-like stack and shared gateway.
- **ODS on workstation:** development/staging stack, training-adjacent services, and secondary endpoint.
- Avoid two independent ODS instances both owning the same schedules or sending the same notifications. Assign a single scheduler leader.
- Back up ODS data/config using its supplied backup path, but keep model weights rebuildable from a manifest rather than copying them in every configuration sync.
- Pin an ODS release or audited commit for the 24x7 machine. The upstream README explicitly says `main` moves quickly and recommends tagged/audited revisions for appliance or production-like installs. ([ODS upstream](https://github.com/Osmantic/ODS))

ODS's documented Tailscale extension is Linux-only in its first version and is intended to expose the ODS host on a private tailnet, not the public internet. On any remote-access choice, require authentication, restrict ports/routes, and do not bind raw inference or Hermes admin surfaces publicly. ([ODS Tailscale](https://github.com/Osmantic/ODS/blob/main/docs/TAILSCALE.md))

## Suggested rollout order

1. Inventory exact OS, GPU SKU, driver, CUDA, RAM, storage, and network for each device.
2. Choose one private network and DNS scheme; verify SSH and authenticated API access from laptop to Spark.
3. Stabilize one ODS install on Spark using its supported llama-server model.
4. Create Hermes profiles and pin one small set of skills/tools; keep recurring jobs disabled.
5. Add LiteLLM logical routes and health checks for Spark local inference.
6. Add the workstation as a second endpoint and validate failure behavior when it sleeps.
7. Evaluate Ollama versus headless LM Studio for the on-demand model pool. LM Studio is the closest match to automatic JIT swap; Ollama is the simplest server-native alternative.
8. Add one vLLM or SGLang persistent deployment only after a benchmark shows a real concurrency/throughput need.
9. Create the canonical configuration repository and render adapters; provision secrets separately.
10. Build a regression suite covering completions, tool calls, structured JSON, long context, code edits, and cancellation.
11. Enable scheduled jobs one at a time with pinned routes, budgets, timeouts, delivery targets, and idempotency.
12. Add paid API fallback only after explicit spend caps and alerts are working.

The durable target is not one enormous process that swaps every model. It is a small fleet of independently health-checked endpoints behind stable routes, with explicit job pinning and controlled cold starts.

## Related notes

- [[Always-On Hermes on DGX Spark]]
- [[personal-hermes-obsidian-multinode-design|Personal Hermes, Obsidian, and Multi-Node Inference Design]]
- [[local-ai-tooling-catalog-and-rollout|Local AI Tooling Catalog and Rollout]]
- [[Local Setup Index]]
