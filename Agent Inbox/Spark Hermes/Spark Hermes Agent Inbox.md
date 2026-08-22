---
created: 2026-08-21
source: DGX Spark
status: active
---

# Spark Hermes Agent Inbox

This folder receives new notes created by Hermes capture agents running on the DGX Spark.

## Capture rules

- Create a new Markdown note for each capture.
- Use a timestamp and a descriptive title in the filename.
- Treat captures as append-only drafts.
- Review, rename, and move accepted notes from desktop Obsidian.
- Do not place Hermes credentials, sessions, databases, or runtime state in this vault.

## Sync ownership

- Desktop, laptop, and phone use normal Obsidian Sync.
- DGX Spark uses the official Obsidian Headless client.
- The Spark replica runs continuous bidirectional synchronization.
- Desktop-to-Spark synchronization was verified after this note arrived from the Spark.

Related: [[Local_Setup/personal-hermes-obsidian-multinode-design|Personal Hermes, Obsidian, and Multi-Node Inference Design]]
