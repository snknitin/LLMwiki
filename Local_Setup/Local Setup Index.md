---
updated: 2026-07-30
---

# Local Setup Index

## Start here

- [[Always-On Hermes on DGX Spark]] — canonical Hermes host, Tailscale, ODS proxy, device sync boundaries, Obsidian, messaging, and Buzz.
- [[local-ai-architecture-research|Local AI Architecture Research]] — hardware topology, subscriptions, model runtimes, routing, and configuration synchronization.
- [[personal-hermes-obsidian-multinode-design|Personal Hermes, Obsidian, and Multi-Node Inference Design]] — detailed state ownership, vault safety, model serving, ODS division, and failure rules.
- [[local-ai-tooling-catalog-and-rollout|Local AI Tooling Catalog and Rollout]] — categorized tools, skills, plugins, overlaps, licenses, placement, and staged adoption.

## Canonical decisions

1. Spark owns the authoritative personal Hermes profile, memory, messaging, and Hermes cron.
2. `hermes serve` handles remote Desktop; `hermes gateway` handles channels and schedules.
3. Workstation and laptop use Hermes Desktop over Tailscale; workstation may retain an isolated local-file profile.
4. Spark ODS is the always-available inference/automation plane; workstation ODS is development/training and an optional inference upstream.
5. Run current standalone Hermes beside ODS initially because the reviewed ODS Hermes image predates native remote Desktop support.
6. Obsidian uses one replica per device and one sync system per replica. Spark starts pull-only; restricted bidirectional writing is enabled only after conflict testing.
7. Stable model aliases and routing replace manual global model swapping.
8. Discord is the organized mobile surface; Telegram is the fallback; Buzz is an experimental project workspace.
9. Consumer subscriptions are not generic API credits for unattended services.
10. Skills/config declarations can be version-controlled, but secrets, OAuth sessions, live databases, and Hermes runtime state cannot.
