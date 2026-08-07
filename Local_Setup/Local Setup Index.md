---
updated: 2026-08-07
---
 
# Local Setup Index

## Start here

- [[DGX Spark Operations Setup Guide]] — copy-paste foundation for `.bashrc`, secrets, model/cache layout, container conventions, registries, and the first vLLM model.

- [[Spark Hermes Setup Runbook]] — the ordered do-list with phase gates; execute this, read the rest for rationale.
- [[Always-On Hermes on DGX Spark]] — canonical Hermes host, Tailscale, ODS proxy, device sync boundaries, Obsidian, messaging, and Buzz.
- [[DGX Spark ODS Playbook and Model Roadmap]] — consolidated recommendation covering ODS overlap, learning order, current models, serving engines, and concurrency-safe deployment.
- [[local-ai-architecture-research|Local AI Architecture Research]] — hardware topology, subscriptions, model runtimes, routing, and configuration synchronization.
- [[personal-hermes-obsidian-multinode-design|Personal Hermes, Obsidian, and Multi-Node Inference Design]] — detailed state ownership, vault safety, model serving, ODS division, and failure rules.
- [[local-ai-tooling-catalog-and-rollout|Local AI Tooling Catalog and Rollout]] — categorized tools, skills, plugins, overlaps, licenses, placement, and staged adoption.

## DGX Spark supporting research

- [[DGX Spark Aug 2026 Model Deployment Research]] — primary-source comparison of the current single-Spark community recipes, model/runtime differences, benchmark caveats, and promotion gates.
- [[dgx-spark-playbook-roadmap-draft|DGX Spark Playbook Roadmap Draft]] — complete 44-card live-catalog inventory and ODS overlap classification.
- [[dgx-spark-current-models-report|DGX Spark Current Models Report]] — detailed model shortlist, engines, context/concurrency profiles, and benchmark caveats as of 2026-08-02.
- [[dgx-spark-twitter-bookmarks-analysis|DGX Spark Twitter Bookmarks Analysis]] — evidence audit of the saved DGX Twitter export, including hardware and metric mismatches.

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
