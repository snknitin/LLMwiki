---
title: Kaggle Lab Operations
kind: reference
topics: workflow, operations
status: ready
updated: 2026-09-26
minutes: 4
---
# Kaggle Lab Operations

**Open [Kaggle Learning Lab](https://spark-07a8.tail4a1242.ts.net:8772/)** while connected to Tailscale.

## Code and data are separate

| Item | Location |
| --- | --- |
| Windows Git project | `E:\GIT_ROOT\Projects\kaggle-learning-center` |
| Spark application | `/home/snknitin/Workspace/GIT_ROOT/Projects/kaggle-learning-center` |
| Windows Markdown | `F:\Vaults\LLMWiki\Kaggle` |
| Spark Markdown | `/home/snknitin/vaults/LLMWiki/Kaggle` |

The existing Obsidian Sync service transfers Markdown. There is no second data mirror, no database in the vault, and no copying of the rest of the vault into Git. A fresh Markdown edit appears after Obsidian finishes syncing and the dashboard refreshes.

## Service controls — FirstSpark terminal

```bash
~/.local/bin/aux-services status
```

To start only this dashboard:

```bash
~/.local/bin/aux-services start kaggle-learning-center
```

To stop only this dashboard:

```bash
~/.local/bin/aux-services stop kaggle-learning-center
```

The Python server listens only on `127.0.0.1:8772`. Tailscale Serve provides the private HTTPS address. Stopping the dashboard does not stop Obsidian Sync or change your model route.

## Learn or compare solutions now

Open **Learn** or **Competitions**, select a note, and click **Teach me with SparkFast**. You can also use **Add Kaggle link**. A focus question is optional. The app reads public Kaggle pages, runs local Hermes generation and review with the ADHD skill, and saves a new Markdown lesson. It shows progress and opens the result. Original notes remain intact.

Both a learning topic and a competition have passed live source-to-model-to-Markdown tests. Some generated scientific advice still needed explicit editorial corrections; model review does not certify correctness or mean an experiment was run. Competition coverage includes ten slots, with missing sources and unverified placements visible. Older generated files remain in Obsidian; the app lists the latest version.

For the learning loop, attempt a diagnostic, read only what resolves your gap, reproduce one controlled change, and try it on another case. Store actual experiments in [[Kaggle/Journey/Practice Log]]. Interactive answer tracking is a planned next stage.

## Hermes handoff — scheduling disabled

The intended runner is **Hermes with the existing `spark-fast` model alias**. The former Codex heartbeat was deleted at your request. No replacement cron is active.

Before enabling a Hermes job, run one manual request using the application project's `DAILY_REVIEW.md`, inspect the generated citations and missing-evidence handling, and verify the worker actually executes. An earlier cron inspection reported a missing dependency. The canonical isolated Hermes CLI has since passed live on-demand teaching tests; that does not validate the separate daily cron workflow or enable a schedule.

Suggested daily schedule after testing: 08:00 Asia/Kolkata. Keep source research bounded, process one request, write only within Kaggle, and never auto-enter or submit to competitions. Keep `Practice Log.md` user-owned. A drained/unavailable model should produce a visible failure, not an automatic model restart.

## Provenance and progress

Top-ten tables include every rank, but some methods are missing or unverified. Generated lessons and displayed notes do not imply course completion or mastery. Profile observations carry a timestamp. Reports older than 48 hours are stale. Public profile reads cannot reveal every private notebook or submission.
