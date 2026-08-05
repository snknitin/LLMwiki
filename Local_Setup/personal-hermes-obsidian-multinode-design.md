 # Personal Hermes, Obsidian, and Multi-Node Inference Design

## Recommended end state

Use the DGX Spark as the always-on personal Hermes control plane and large-model/service appliance, the RTX 5000 workstation as the development, local-file, training, and low-latency inference node, and the laptop as a thin roaming client.

- Run one authoritative personal Hermes profile on Spark. Supervise both `hermes serve` for remote Hermes Desktop clients and `hermes gateway` for messaging and cron.
- Connect Hermes Desktop on the workstation and laptop to Spark over Tailscale. Keep an optional, clearly named local workstation profile only for tasks that must directly manipulate workstation-only files.
- Run public/project inference, larger models, and durable automations on the DGX Spark. Keep workstation ODS and model services for development, fine-tuning, OCR, and low-latency coding workloads.
- Use two deliberately separated routing layers: a private workstation gateway for personal/coding traffic and a Spark service gateway for external/project traffic. Give agents stable logical model names such as `fast`, `code`, `deep`, and `vision`; do not make individual agents unload and replace a single global model.
- Treat the Obsidian vault as durable human-readable knowledge. Treat Hermes memory, sessions, credentials, and schedules as private runtime state that is backed up but never live-synced between machines.

This is the important distinction:

```text
Obsidian vault: multi-device replicas, synchronized by one sync system
Hermes profile: one authoritative active owner, backed up but not active-active
Model servers: many independent endpoints
Model gateway: one logical namespace and routing policy
Schedulers: one production owner for each job
```

## Obsidian on the Spark

Obsidian now has an official headless Sync client in open beta. It is explicitly intended for servers, agents, automated workflows, and remote backups. The `obsidian-headless` CLI requires Node.js 22 or later and supports a one-time sync or continuous operation with `ob sync --continuous`. It also supports bidirectional, pull-only, and mirror-remote modes plus merge or conflict-file behavior. [Obsidian Headless documentation](https://obsidian.md/help/headless), [official headless client repository](https://github.com/obsidianmd/obsidian-headless), [release announcement](https://obsidian.md/changelog/2026-02-27-sync/)

The safest arrangement for this desktop-first design is:

1. Desktop and laptop each open their own local vault replica using the normal Obsidian application and Obsidian Sync.
2. Spark owns a separate local replica maintained by `obsidian-headless`.
3. The authoritative Spark Hermes reads the Spark-local headless replica through a narrow filesystem permission or dedicated vault-writing tool.
4. Start the Spark replica in `pull-only` mode. If Spark must publish notes, change that replica to `bidirectional` and restrict Hermes writes to a dedicated inbox subtree such as `Agent Inbox/Spark Hermes/`. The sync mode applies to the replica; the narrow write boundary comes from filesystem/tool permissions.

Do not run desktop Obsidian Sync and Headless Sync against the same local vault on one machine. Obsidian explicitly says to use only one sync method per device because two clients can conflict. Also do not layer Git, Dropbox, OneDrive, Syncthing, or another bidirectional synchronizer over a vault already managed by Obsidian Sync; Obsidian warns that combining sync services can create duplicate or corrupted files. [Headless Sync guidance](https://obsidian.md/help/sync/headless), [Obsidian Sync FAQ](https://obsidian.md/help/sync/faq)

Linux is supported by both the desktop application and the headless client. The headless client notes that Linux cannot preserve file creation timestamps, but normal synchronization still works. [Obsidian download/install documentation](https://obsidian.md/help/Getting%2Bstarted/Download%2Band%2Binstall%2BObsidian), [headless client repository](https://github.com/obsidianmd/obsidian-headless)

### Safe agent-writing pattern

Give Hermes read/write access initially to a narrow vault subtree such as:

```text
Agent Inbox/
  spark-hermes/
Automations/
  outputs/
```

Prefer unique, immutable filenames containing a timestamp and task ID. Avoid allowing two processes to rewrite the same daily note, index, or frontmatter block. If an automation must update a shared file, serialize the operation with one local lock and write by temporary-file-plus-rename. A later human or single consolidation job can merge inbox notes into canonical notes.

Use `pull-only` for read-only knowledge retrieval. Use `bidirectional` for publishing agent output. Do not use `mirror-remote` on a replica where Hermes creates notes, because local-only changes are intentionally reverted in that mode. These modes are documented in the official headless client configuration. [Headless client configuration](https://github.com/obsidianmd/obsidian-headless)

Obsidian Sync is not a backup. Keep an independent backup from one designated replica. Obsidian recommends selecting one device as the backup device and explicitly distinguishes synchronization from backup. [Obsidian backup guidance](https://obsidian.md/help/backup)

### If Git is preferred instead of Obsidian Sync

Git can be the primary sync/versioning system on Windows, macOS, and Linux, but Obsidian describes it as a manual-sync option. Do not use it as a second live bidirectional sync layer on top of Obsidian Sync. [Sync notes across devices](https://obsidian.md/help/sync-notes)

With Git as the primary mechanism, every writer must serialize `pull/merge -> edit -> commit -> push`, and conflicts require explicit resolution. Git's own documentation notes that pulling integrates remote changes and may produce conflicts, and that a centralized workflow requires a writer to merge upstream work before pushing. [git-pull](https://git-scm.com/docs/git-pull), [Git centralized workflow](https://git-scm.com/book/en/v2/Distributed-Git-Distributed-Workflows)

For this setup, official Obsidian Sync plus one backup is operationally simpler than making three interactive clients and an autonomous agent coordinate Git writes.

## Hermes state and profile ownership

Run one authoritative personal Hermes profile on Spark. Hermes Desktop on the workstation and laptop should connect to Spark's `hermes serve` backend rather than running independent copies of that profile. The same Spark profile is used by the separately supervised `hermes gateway` process for Discord, Telegram, Buzz, and cron.

A Hermes profile is a complete `HERMES_HOME` containing configuration, environment secrets, `SOUL.md`, memories, skills, cron state, sessions, gateway state, and the state database. Hermes sessions are stored in `~/.hermes/state.db` using SQLite/FTS5, while a sessions JSON file is used as a gateway routing index. This is runtime state, not a directory designed for active-active filesystem replication. [Hermes profiles](https://hermes-agent.nousresearch.com/docs/user-guide/profiles/), [Hermes sessions](https://hermes-agent.nousresearch.com/docs/user-guide/sessions/)

Do not:

- place `HERMES_HOME` inside the Obsidian vault;
- continuously sync `state.db`, `.env`, credentials, gateway state, or cron state with Obsidian Sync or Git;
- run the same profile concurrently from Spark and workstation;
- let both ODS installations own the same production automations.

Use Hermes profiles for real isolation, for example:

```text
personal      # authoritative conversational assistant on Spark
automation    # Spark-owned unattended jobs with narrower tools and permissions
development   # disposable testing profile
desktop-files # optional workstation-only profile; no production messaging or cron
```

Back up profiles with `hermes backup`, which uses SQLite's backup API and is safe while the database is running in WAL mode. A full backup may contain credentials, so store it as a secret. Profile export is better for a sanitized transferable configuration because it excludes credentials. [Hermes CLI reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands), [Hermes backup FAQ](https://hermes-agent.nousresearch.com/docs/reference/faq/)

### Memory and Obsidian are complementary

Hermes's built-in durable memory uses `MEMORY.md` and `USER.md` under the profile's memories directory. They are loaded as a frozen snapshot when a session starts; memory written during a session is visible in subsequent sessions. Keep these files in the Spark-owned authoritative profile. [Hermes memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory/)

Use Obsidian for larger, inspectable knowledge: project notes, decisions, research, runbooks, and agent-produced drafts. If useful, add an explicit job that exports selected, non-secret Hermes facts into a vault inbox. Do not make the vault a transparent replacement for Hermes's state database or credentials.

### Skills and configuration

Hermes loads local skills from `~/.hermes/skills` and can load additional directories through `skills.external_dirs`, including a shared `~/.agents/skills` tree. Writable external directories are mutable from Hermes, and local skills shadow same-named external skills. [Hermes skills](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)

Use a separate private Git repository as the canonical reviewed skills/config repository:

- mount or check it out read-only on the Spark personal/automation profiles and on any optional workstation local profile where practical;
- list it in `skills.external_dirs`;
- keep learned or experimental skills in the local profile;
- promote changes to the canonical repository through review;
- keep `.env`, tokens, machine-specific paths, and credentials outside it.

This gives all devices the same reviewed skill definitions without trying to synchronize live Hermes databases. Machine-specific overlays should contain endpoint URLs, GPU assignments, and secret references.

### Remote access

Hermes Desktop's remote target is `hermes serve`, not the messaging daemon named `hermes gateway`. Run `hermes serve` on Spark's Tailscale interface with Hermes authentication, and run `hermes gateway` separately for messaging and cron. In remote mode the Spark is the execution boundary: tools, shell commands, file browsing, skills, memory, sessions, and configuration belong to the Spark profile. Desktop connection entries and UI preferences remain per device. Do not expose either the dashboard or the command-capable remote backend directly to the public internet. [Hermes Desktop](https://hermes-agent.nousresearch.com/docs/user-guide/desktop), [Hermes CLI reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands)

Hermes tools have the filesystem access of the host user unless restricted or sandboxed. Run unattended automation under a dedicated OS account or container, allow only the needed vault subtree, and disable unnecessary tools. [Hermes configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration/)

## Multi-node model serving

Model installation and model serving are separate choices. A downloaded model is just an artifact; Ollama, LM Studio, vLLM, and SGLang are alternative runtimes with different operational strengths.

### Recommended serving tiers

| Tier | Host | Runtime | Purpose |
|---|---|---|---|
| Always-hot production | Spark | vLLM or SGLang, one service per important model | Large models, concurrent agents, predictable stable endpoints |
| Always-hot/optional worker | RTX 5000 workstation | vLLM or SGLang | Coding and 48 GB-class workloads when workstation is awake |
| On-demand catalog | Spark and/or workstation | Ollama or LM Studio | Infrequent models, exploration, easy downloads, manual testing |
| Offline fallback | Laptop | Ollama or LM Studio | Small quantized model when disconnected |
| Personal unified route | Spark | LiteLLM | Always-available private logical names across Spark and selected workstation endpoints |
| External/project route | Spark, separately keyed and preferably separately deployed | LiteLLM | Per-project keys, quotas, stable service models, and isolation from personal Hermes |

vLLM is designed around continuous batching, PagedAttention, and an OpenAI-compatible server. NVIDIA publishes a DGX Spark-specific vLLM playbook and compatible model guidance. SGLang similarly has a DGX Spark-optimized CUDA 13 container and server workflow. These are the better fit for concurrent, always-on agent traffic. [NVIDIA DGX Spark vLLM playbook](https://build.nvidia.com/spark/vllm), [NVIDIA DGX Spark SGLang playbook](https://build.nvidia.com/spark/sglang)

Ollama is suitable for a changing local catalog. It supports keep-alive, multiple loaded models when memory permits, request parallelism, and queueing; models unload when idle or under memory pressure. [Ollama FAQ](https://docs.ollama.com/faq), [Ollama generate API](https://docs.ollama.com/api/generate)

LM Studio also supports programmatic model load/unload/download. Its JIT loading, TTL, and auto-evict behavior make it convenient for on-demand use; with auto-evict enabled, loading a new JIT model evicts the previously JIT-loaded model. NVIDIA documents LM Studio/`llmster` and LM Link on DGX Spark. [LM Studio TTL and auto-evict](https://lmstudio.ai/docs/developer/core/ttl-and-auto-evict), [LM Studio REST API](https://lmstudio.ai/docs/developer/rest), [NVIDIA DGX Spark LM Studio playbook](https://build.nvidia.com/spark/lm-studio)

LiteLLM provides a unified gateway across OpenAI-compatible and hosted providers, with routing, retries, fallbacks, load balancing, budgets, and access controls. [LiteLLM documentation](https://docs.litellm.ai/)

### Automatic hot swapping

Implement hot swapping as policy at the gateway, not as each agent mutating a server:

```text
personal agent/job requests logical model
        |
        v
Spark private LiteLLM route and health policy
        |
        +-- always-hot Spark endpoint
        +-- optional workstation endpoint
        +-- on-demand Ollama/LM Studio endpoint
        +-- hosted provider fallback, if policy permits
```

Suggested logical routes:

- `fast`: small always-hot Spark model, with laptop-local equivalent for offline use;
- `code`: workstation coding model when healthy, Spark fallback when it sleeps;
- `deep`: largest Spark model, lower concurrency and explicit queue limits;
- `vision`: dedicated compatible endpoint;
- `private-local`: local endpoints only, never hosted fallback;
- `hosted-best`: Claude/GPT/Gemini according to the applicable API account and policy.

For frequent workloads, keep dedicated vLLM/SGLang processes alive. For infrequent workloads, call the LM Studio or Ollama load API, wait for readiness, route traffic, and let TTL/keep-alive evict the model. Add prewarming before scheduled jobs. Do not route a job until the endpoint passes a health/readiness check.

Both machines are always on, but workstation fine-tuning and inference still compete for VRAM and memory bandwidth. A workstation GPU-lease/drain mechanism should move interactive and scheduled inference to Spark before training begins, then restore workstation routes afterward rather than relying on out-of-memory failure as scheduling.

## Running ODS on both machines

Two ODS installations do not automatically form one distributed control plane. Each instance can own its own Open WebUI history, Hermes profile, Qdrant data, n8n schedules, LiteLLM configuration/keys, dashboards, and local inference process. If both are configured identically, duplicate jobs and diverging state are likely.

Assign explicit ownership:

| Responsibility | Spark ODS | Workstation ODS |
|---|---|---|
| Personal Hermes | Current standalone Hermes beside ODS is primary; disable or rename the old ODS-bundled instance | Optional local `desktop-files`/development profile only |
| Personal cron/n8n jobs | Primary production owner | Development/staging only |
| External/project cron jobs | Primary when they serve Spark-hosted projects | Disabled unless explicitly workstation-owned |
| LiteLLM gateway | Always-available personal routes plus separately keyed/isolated external routes | Development gateway and optional healthy upstream |
| Large always-on inference | Primary | Optional |
| 48 GB coding inference | Fallback | Primary while GPU is available |
| Fine-tuning/SLM work | Optional | Primary |
| Obsidian vault | Headless pull-only replica first; restricted bidirectional replica when Spark must publish | Normal desktop replica for human editing and local-only tools |
| Open WebUI | External/project or model-testing UI | Personal/development UI; histories remain separate |

ODS's local model-management path is oriented around one local `llama-server`/GGUF process and restarts inference when the selected model changes. Its LiteLLM configurations provide local, cloud, and hybrid routing, but they are not a cross-host GPU scheduler. Use an always-available Spark LiteLLM route as the required entry point for the authoritative Hermes profile. Register workstation model services only as health-checked optional upstreams with Spark fallbacks. External consumers need separate keys, quotas, route allowlists, and preferably a separate LiteLLM deployment or network boundary; they must never be able to route into private workstation services. See the ODS documentation: [model management](https://github.com/Osmantic/ODS/blob/main/docs/MODEL-MANAGEMENT.md), [provider modes](https://github.com/Osmantic/ODS/blob/main/docs/ENGINE-PROVIDER-MODES.md), [Hermes integration](https://github.com/Osmantic/ODS/blob/main/docs/HERMES.md), [LiteLLM service](https://github.com/Osmantic/ODS/blob/main/extensions/services/litellm/README.md), and [Tailscale guidance](https://github.com/Osmantic/ODS/blob/main/docs/TAILSCALE.md).

Avoid nested independent routers unless there is a deliberate boundary. Here the personal-versus-external trust boundary justifies two gateways; keep their keys, logs, model aliases, quotas, and fallback policies distinct.

## Concurrency and failure rules

1. One active owner per Hermes profile and state database.
2. One production owner per cron, n8n workflow, notification, or other side-effecting automation.
3. One sync mechanism per Obsidian replica; no desktop Sync and Headless Sync on the same local vault.
4. Agent writes go to unique inbox files; shared-note mutation is serialized.
5. Model endpoints are immutable from the caller's perspective. The gateway changes routing; callers do not replace global server state.
6. Workstation routes have Spark fallback or an explicit queue/fail policy.
7. Hosted-provider fallback is opt-in per route so private data cannot silently leave the local network.
8. Backups cover the Obsidian vault, Hermes profiles, gateway config, automation definitions, and secrets through separate appropriate mechanisms.

## Suggested rollout

### Phase 1: establish ownership

- Make Spark the production personal Hermes, messaging, and Hermes-cron owner.
- Make Spark the owner of durable personal automation and external/project inference, with separate profiles, keys, and permissions for personal versus external work.
- Keep workstation automation in development/staging unless a job is explicitly workstation-owned.
- Give every service a unique name, port, data directory, API key, and backup target.
- Disable or rename every duplicate automation so each job has exactly one owning ODS instance.
- Connect all hosts over Tailscale and keep service ports off the public internet.

### Phase 2: vault integration

- Back up the vault.
- Install official `obsidian-headless` on Spark and create a separate local replica.
- Keep the Spark replica pull-only first.
- If Spark Hermes must publish notes, change the Spark replica to bidirectional after conflict tests and restrict Hermes filesystem/tool access to `Agent Inbox/Spark Hermes/` or another dedicated subtree.

### Phase 3: inference plane

- Start one stable large-model vLLM or SGLang endpoint on Spark.
- Start one coding endpoint on the workstation.
- Put an always-available private LiteLLM route on Spark in front of personal models, with the workstation registered only as an optional upstream.
- Keep external/project virtual keys, quotas, and route allowlists separate; prefer a second gateway deployment when external users are involved.
- Retain Ollama or LM Studio as the on-demand catalog, not the only production scheduler.

### Phase 4: shared engineering configuration

- Create a private canonical skills/config repository with no secrets.
- Load reviewed skills as an external Hermes directory.
- Keep per-host overlays and credentials local.
- Back up Hermes using its own backup command, not live filesystem synchronization.

### Phase 5: controlled automation

- Pin each scheduled job to a logical route and privacy class.
- Prewarm infrequent models before schedules.
- Add idempotency keys or durable job locks for side effects.
- Test workstation sleep, Spark restart, model load failure, vault conflict, and hosted-provider outage before trusting unattended operation.

This design preserves one coherent personal assistant while still letting every GPU contribute. It also prevents the most damaging failure modes: split-brain Hermes state, duplicated schedules, vault corruption from stacked sync systems, and agents racing to replace one shared model process.

## Related notes

- [[Always-On Hermes on DGX Spark]]
- [[local-ai-architecture-research|Local AI Architecture Research]]
- [[local-ai-tooling-catalog-and-rollout|Local AI Tooling Catalog and Rollout]]
- [[Local Setup Index]]
