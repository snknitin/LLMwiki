# Social Capture

This folder contains the canonical **action queue**, not a bookmark library or web application.

## Canonical synced files

- [[Social Capture Action Queue]] — Markdown source of truth.
- [[Social Capture Preferences]] — explicit reusable intent defaults.

The dashboard application is deliberately outside the Obsidian vault:

`/home/snknitin/Workspace/Projects/GIT_ROOT/social-capture`

Run a copy of that repository on the Windows desktop and point it at the locally synced queue. It reads and safely updates Markdown directly; Hermes on the Spark does not generate or synchronize HTML.

## Processing rule

When Nitin shares a post, page, screenshot, file, or forwarded message, Hermes must:

1. retrieve and understand it;
2. use Nitin's caption as intended-use context;
3. infer intent for a bare source and label it inferred;
4. check the active queue and archives for a duplicate action;
5. append one smallest useful action with a completion artifact and timebox; or
6. discard it explicitly when no useful action is justified.

A reply to an `Added [sc_…]` Telegram receipt updates that exact task. It must not create a duplicate. One-off corrections stay task-specific; only explicit `remember`/`always` instructions become reusable preferences.

Do not create one Markdown note per source. Do not sort capture destinations by topic. Classify internally, then write one action to the queue.

Canonical design: [[Local_Setup/Social Capture Pipeline]].
