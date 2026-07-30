# Personal Hermes, Obsidian, and Multi-Node Inference Design

## Recommended end state

Use the RTX 5000 workstation as the always-on personal control plane, the DGX Spark as the shared/project inference appliance and heavy-automation worker, and the laptop as a thin roaming client.

- Run the authoritative personal Hermes profile and personal model gateway on the workstation so Hermes can work directly with deliberately mounted local project folders and the workstation's normal Obsidian replica.
- Run public/project inference, larger models, and explicitly Spark-owned automations on the DGX Spark.
- Connect the laptop to the workstation Hermes gateway and both inference gateways through a private network such as Tailscale. Keep local laptop models only as an offline fallback.
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
3. The authoritative desktop Hermes reads and writes the desktop-local vault through a narrow bind mount or dedicated vault-writing tool. It does not need SMB/NFS access to another machine.
4. Start the Spark replica in `pull-only` mode. Change it to `bidirectional` only if a specifically Spark-owned automation must publish unique inbox notes; otherwise keep Spark read-only.

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

Run one authoritative personal Hermes profile on the workstation. The laptop should be a remote client of that profile, not an independent live copy. Spark does not need a copy of the personal profile merely to provide inference; the workstation Hermes can call Spark model endpoints while keeping memory and file access local.

A Hermes profile is a complete `HERMES_HOME` containing configuration, environment secrets, `SOUL.md`, memories, skills, cron state, sessions, gateway state, and the state database. Hermes sessions are stored in `~/.hermes/state.db` using SQLite/FTS5, while a sessions JSON file is used as a gateway routing index. This is runtime state, not a directory designed for active-active filesystem replication. [Hermes profiles](https://hermes-agent.nousresearch.com/docs/user-guide/profiles/), [Hermes sessions](https://hermes-agent.nousresearch.com/docs/user-guide/sessions/)

Do not:

- place `HERMES_HOME` inside the Obsidian vault;
- continuously sync `state.db`, `.env`, credentials, gateway state, or cron state with Obsidian Sync or Git;
- run the same profile concurrently from Spark and workstation;
- let both ODS installations own the same production automations.

Use Hermes profiles for real isolation, for example:

```text
personal      # authoritative conversational assistant on workstation
automation    # workstation-owned personal jobs with narrower tools and permissions
development   # disposable testing profile
```

Back up profiles with `hermes backup`, which uses SQLite's backup API and is safe while the database is running in WAL mode. A full backup may contain credentials, so store it as a secret. Profile export is better for a sanitized transferable configuration because it excludes credentials. [Hermes CLI reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands), [Hermes backup FAQ](https://hermes-agent.nousresearch.com/docs/reference/faq/)

### Memory and Obsidian are complementary

Hermes's built-in durable memory uses `MEMORY.md` and `USER.md` under the profile's memories directory. They are loaded as a frozen snapshot when a session starts; memory written during a session is visible in subsequent sessions. Keep these files in the workstation-owned profile. [Hermes memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory/)

Use Obsidian for larger, inspectable knowledge: project notes, decisions, research, runbooks, and agent-produced drafts. If useful, add an explicit job that exports selected, non-secret Hermes facts into a vault inbox. Do not make the vault a transparent replacement for Hermes's state database or credentials.

### Skills and configuration

Hermes loads local skills from `~/.hermes/skills` and can load additional directories through `skills.external_dirs`, including a shared `~/.agents/skills` tree. Writable external directories are mutable from Hermes, and local skills shadow same-named external skills. [Hermes skills](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)

Use a separate private Git repository as the canonical reviewed skills/config repository:

- mount or check it out read-only on the workstation's production personal profile and on Spark automation profiles where practical;
- list it in `skills.external_dirs`;
- keep learned or experimental skills in the local profile;
- promote changes to the canonical repository through review;
- keep `.env`, tokens, machine-specific paths, and credentials outside it.

This gives all devices the same reviewed skill definitions without trying to synchronize live Hermes databases. Machine-specific overlays should contain endpoint URLs, GPU assignments, and secret references.

### Remote access

Hermes can expose an OpenAI-compatible API server, bound by default to `127.0.0.1:8642`, and requires `API_SERVER_KEY`. Its dashboard can also connect to a remote gateway. The dashboard can read and write environment secrets and run commands, so Hermes warns not to expose it directly to the public internet. Bind services to localhost or the private Tailscale interface and require strong authentication. [Hermes API server](https://hermes-agent.nousresearch.com/docs/user-guide/features/api-server/), [Hermes web dashboard](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard/)

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
| Personal unified route | Workstation | LiteLLM | Private logical names across workstation and selected Spark endpoints |
| External/project route | Spark | LiteLLM | Per-project keys, quotas, stable service models, and isolation from personal Hermes |

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
workstation LiteLLM route and health policy
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
| Personal Hermes | Disabled or separate non-personal automation profile | Primary and authoritative |
| Personal cron/n8n jobs | Disabled unless explicitly Spark-owned | Primary |
| External/project cron jobs | Primary when they serve Spark-hosted projects | Disabled unless explicitly workstation-owned |
| LiteLLM gateway | External/project service gateway | Private personal/development gateway |
| Large always-on inference | Primary | Optional |
| 48 GB coding inference | Fallback | Primary while GPU is available |
| Fine-tuning/SLM work | Optional | Primary |
| Obsidian vault | Headless pull-only replica by default | Normal desktop replica used by personal Hermes |
| Open WebUI | External/project or model-testing UI | Personal/development UI; histories remain separate |

ODS's local model-management path is oriented around one local `llama-server`/GGUF process and restarts inference when the selected model changes. Its LiteLLM configurations provide local, cloud, and hybrid routing, but they are not a cross-host GPU scheduler. Use the workstation LiteLLM instance as the private entry point for Hermes and coding clients. Use the Spark LiteLLM instance as the separately authenticated entry point for external/project consumers. The workstation gateway may call selected Spark routes as an upstream, but Spark must never route external users back into personal workstation services. See the local ODS documentation: [MODEL-MANAGEMENT.md](../MODEL-MANAGEMENT.md), [ENGINE-PROVIDER-MODES.md](../ENGINE-PROVIDER-MODES.md), [Hermes integration](../HERMES.md), [LiteLLM service README](../../extensions/services/litellm/README.md), and [Tailscale guidance](../TAILSCALE.md).

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

- Make the workstation the production personal Hermes and personal-scheduler owner.
- Make Spark the owner of external/project inference and only those schedules explicitly attached to Spark-hosted services.
- Give every service a unique name, port, data directory, API key, and backup target.
- Disable or rename every duplicate automation so each job has exactly one owning ODS instance.
- Connect all hosts over Tailscale and keep service ports off the public internet.

### Phase 2: vault integration

- Back up the vault.
- Install official `obsidian-headless` on Spark and create a separate local replica.
- Keep the Spark replica pull-only first; the desktop Hermes uses the desktop-local replica.
- If Spark must publish notes, add a restricted `Agent Inbox/spark-automation` write path and change only that workflow to bidirectional after conflict tests.

### Phase 3: inference plane

- Start one stable large-model vLLM or SGLang endpoint on Spark.
- Start one coding endpoint on the workstation.
- Put the private LiteLLM gateway on the workstation in front of personal routes, with Spark fallbacks.
- Keep a separate Spark LiteLLM gateway for external/project virtual keys, quotas, and stable service routes.
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
