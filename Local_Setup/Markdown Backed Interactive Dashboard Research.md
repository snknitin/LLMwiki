# Markdown Backed Interactive Dashboard Research

Research date: 2026-08-22

## Decision

Yes, this can work well. Markdown can remain the durable source of truth while a dashboard shows agent reports and writes a small amount of user feedback into the same files. The clarified MVP—👍/👎 plus an optional short note—is substantially simpler than a general Markdown editor. Converting Markdown to HTML is easy; the small Spark service supplies the deliberate write-back operation.

The recommended path for the clarified use case is:

1. Let each scheduled agent create a new timestamped Markdown report in `LLMWiki/Agent Inbox/Scheduled Jobs/<job>/`.
2. Give each report an immutable `dashboard_id`, `feedback: none`, and optional `feedback_note` properties.
3. Run a narrow custom service on the DGX Spark. It renders those reports, watches the folder, and allows only `feedback`, `feedback_note`, and `feedback_updated_at` to be changed through the browser. Expose it only through T
4. ailscale Serve.
5. Keep weekly Claude or Hermes output as a new review draft in Markdown. It should not silently overwrite canonical tasks or reviewed notes.
6. Build the first version in **LLMWiki**, which is already Git-backed. The active Personal-Sync desktop vault was moved to `F:\Vaults\Personal-Sync` on 2026-08-22; leave its former Google Drive copy closed and verify the new local copy before adding automated writers there.

This provides the desired loop:

```text
Desktop / phone Obsidian
          |
          | Obsidian Sync
          v
Spark LLMWiki replica <-- dashboard storage service <-- tailnet-only HTML UI
          ^                         ^
          |                         |
   Hermes capture            checkbox/text edits
   and weekly review
```

The HTML view can update immediately after a local file event. Obsidian Sync remains eventually consistent across machines; it is not a transactional real-time database and does not promise zero-second propagation.

## What Is Easy And What Is Not

### Easy: Markdown To HTML

Markdown began as a readable plain-text format and a converter to HTML. CommonMark standardizes parsing and rendering but does not define a way for clicks in rendered HTML to mutate the source file. A static-site tool such as Astro can load local Markdown and render it to HTML, but build-time content changes appear only after a rebuild or server refresh. [CommonMark specification](https://spec.commonmark.org/spec), [Astro content collections](https://docs.astro.build/en/guides/content-collections/)

This is ideal for read-only publishing and poor as the whole answer to an editable dashboard. Once Markdown has been parsed into an abstract syntax tree and rendered, details such as whitespace, comments, property ordering, and author formatting may no longer have a reversible mapping from the resulting HTML.

### Not Automatic: HTML To Markdown

A checkbox in an HTML document changes only browser state unless JavaScript sends the change somewhere that can persist it. The browser File System Access API can write user-selected local files, but it requires explicit user permission and a secure context. That would address files on the device running the browser, not transparently write a remote Spark vault from the desktop or phone. [File System API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_API), [File System Access specification](https://wicg.github.io/file-system-access/)

For this setup, the correct writer is therefore one of:

- Obsidian itself or an Obsidian plugin;
- a browser-based Markdown editor whose server owns the files;
- a small Spark-hosted API that validates and writes Markdown.

### Real-Time Has Two Different Meanings

- **Dashboard real-time:** a browser edit can be written to the Spark filesystem and reflected in all open dashboard tabs within well under a second using Server-Sent Events or a WebSocket.
- **Vault sync time:** that write then travels through Obsidian Sync to the desktop and phone. A desktop edit travels the reverse path before the Spark watcher sees it. This is normally fast but remains asynchronous.

The UI should say **Saved on Spark** separately from **observed back after Sync**. Do not tell the user a remote device has received a change merely because the Spark write succeeded.

## Option Evaluation

| Option | Reads Markdown | Writes Markdown | Standalone browser UI | Main strength | Main limitation | Verdict |
|---|---:|---:|---:|---|---|---|
| Static site generator | Yes | No | Yes | Simple, polished read-only output | No source writeback without a backend | Not sufficient |
| Obsidian Bases | Yes | Yes, for properties | No; runs in Obsidian | Built in, local-first, lowest risk | Not a separate HTML site; body editing is still normal Obsidian editing | Best first step |
| Obsidian plus Meta Bind | Yes | Yes, for bound properties | No; runs in Obsidian | Toggles, text areas, selects, buttons, reactive fields | Community-plugin dependency; not a general remote web app | Best prototype controls |
| SilverBullet | Yes | Yes | Yes | Ready-made self-hosted browser Markdown editor with tasks and queries | Separate browser-to-server sync/conflict model; not an exact custom dashboard | Best off-the-shelf spike |
| Custom Spark dashboard | Yes | Yes | Yes | Exact UI, write boundary, concurrency rules, agent API | Small application to build and maintain | Recommended standalone dashboard |
| Git-backed CMS | Yes | Yes, through files/commits | Yes | Schemas, editorial workflow, review through Git | Git becomes the live transport and introduces pull/merge latency | Poor fit for this live Sync vault |

## Obsidian-Native First Step

### Bases

Obsidian Bases is now a core plugin. It creates table, list, card, and map views over local Markdown files and their properties; the data remains in Markdown and YAML properties. Bases can view and edit those properties, while the view definition lives in a `.base` file or a `base` code block. [Obsidian Bases](https://obsidian.md/help/bases), [Create a base](https://obsidian.md/help/bases/create-base)

This already covers much of the request:

- show today's open items;
- check a Boolean property;
- edit status, priority, due date, and short text;
- filter and sort notes;
- use the same data on desktop, laptop, and phone inside Obsidian;
- let Obsidian Sync carry the underlying Markdown changes.

Obsidian properties support text, lists, numbers, checkboxes, dates, and date-times and are stored as YAML at the top of the Markdown file. Properties are intentionally for small atomic values, not long Markdown prose. [Obsidian properties](https://obsidian.md/help/properties)

### Meta Bind

Meta Bind adds inline toggles, inputs, text areas, selects, and buttons that bind directly to a note's frontmatter. Its documentation shows a toggle writing a Boolean frontmatter field and an input bound to another note. This is a good way to prototype the dashboard behavior inside Obsidian before building a separate web service. [Meta Bind repository](https://github.com/mProjectsCode/obsidian-meta-bind-plugin), [Meta Bind input fields](https://www.moritzjung.dev/obsidian-meta-bind-plugin-docs/guides/inputfields/), [Meta Bind targets](https://www.moritzjung.dev/obsidian-meta-bind-plugin-docs/guides/bindtargets/)

The prototype should use Bases alone first. Add Meta Bind only for a control that Bases does not express cleanly. Community plugins execute code inside Obsidian, so pin the version, back up before upgrades, and avoid JavaScript-powered controls for the MVP.

### Why This Is A Better Schema Test Than Starting With HTML

If the fields, filters, and daily flow do not feel useful in Obsidian, a polished web front end will not fix the data model. Bases lets the user validate record granularity and property names with almost no new service surface. The same Markdown can later feed the HTML application without migration.

## SilverBullet As The Off-The-Shelf Browser Alternative

SilverBullet is a private, self-hosted, browser-based Markdown editor and programmable personal knowledge system. It stores content as Markdown pages, has live preview, wiki links, tasks, objects, queries, and a browser/server API. The current server has official Linux ARM64 binaries, so the DGX Spark architecture is supported. [SilverBullet repository](https://github.com/silverbulletmd/silverbullet), [binary installation](https://edge.silverbullet.md/Install/Binary)

It is the fastest route to "edit Markdown from a browser," but it is not automatically the safest route to "add a dashboard to an existing Obsidian vault":

- its progressive web app keeps another copy in browser IndexedDB and synchronizes that copy with the SilverBullet server;
- its documented sync cycle is roughly 4-5 seconds for the open file and 20 seconds for the full space;
- when two clients change the same file, SilverBullet creates a conflict copy instead of merging;
- its query and scripting system is SilverBullet-specific, while Obsidian plugins and every Obsidian Markdown extension are not automatically reproduced;
- pointing it at the whole LLMWiki vault would make a second editor index thousands of files when the desired dashboard needs only a narrow data set.

These behaviors are documented in [SilverBullet Sync](https://v2.silverbullet.md/Sync) and its [PWA documentation](https://silverbullet.md/PWA).

If tested, point SilverBullet only at a dedicated dashboard subtree or a disposable copy first. Enable its authentication, put TLS in front of it, and never expose it publicly. SilverBullet's install guidance explicitly requires authentication and HTTPS for remote access. [SilverBullet installation and security requirements](https://v2.silverbullet.md/Install)

SilverBullet is therefore the best **off-the-shelf spike**, not the default production choice. A one-week comparison against the Obsidian-native prototype can determine whether its richer editor is worth introducing another sync/conflict layer.

## Recommended Standalone Web Architecture

### Ownership Boundary

Run one small service on FirstSpark under a dedicated unprivileged account. It should:

- bind only to `127.0.0.1`;
- be exposed to authorized tailnet devices through Tailscale Serve over HTTPS;
- resolve and allow only paths under `LLMWiki/Dashboard/`;
- reject symlinks, parent traversal, hidden files, and arbitrary extensions;
- parse and write only the documented dashboard schema;
- keep its cache, database, logs, temporary files, and secrets outside the vault;
- provide a separate read-only route if a display-only screen is later wanted.

Tailscale Serve can reverse-proxy a local service and exposes it privately inside the tailnet over HTTPS. This should be Serve, not Funnel. [Tailscale Serve examples](https://tailscale.com/docs/reference/examples/serve), [hosting a tailnet-only website](https://tailscale.com/docs/features/tailscale-funnel/how-to/host-websites)

Tailnet membership is not the only control. Restrict the service with a Tailscale policy to the user's devices, retain application authentication, use secure same-site cookies, require CSRF protection on mutations, and record a small audit line for each write.

### Read And Update Flow

```text
GET item
  -> read exact file bytes
  -> parse allowed fields
  -> return data plus strong revision hash

PATCH item with expected revision
  -> acquire per-path lock
  -> reread exact bytes
  -> reject if revision changed
  -> validate the patch
  -> preserve unowned content
  -> write staged file and flush
  -> rename into place
  -> return new revision
```

Use a SHA-256 of the exact file bytes as a strong revision. Send it as an ETag and require `If-Match` for every update. HTTP defines this pattern specifically to prevent one client from accidentally overwriting another client's parallel work; a failed precondition returns `412 Precondition Failed`. [RFC 9110 conditional requests and If-Match](https://www.rfc-editor.org/rfc/rfc9110.html#name-if-match)

This detects changes that have already reached the Spark, including changes delivered by Obsidian Sync. It cannot detect an edit that remains offline on another device. The human rule still stands: do not deliberately edit the same dashboard record in two places while one device is offline.

### Atomic Writes

Do not edit the destination in place. Write the full new content to a staging file on the same Spark filesystem, flush it, and rename it into the vault. Node exposes stable filesystem write and rename operations, but also warns against overlapping `writeFile` calls on the same file, so the application still needs a per-file lock and a single awaited write sequence. [Node.js filesystem API](https://nodejs.org/api/fs.html)

Keep the staging directory outside the vault but on the same filesystem, for example a sibling of the replica, so transient files are never offered to Obsidian Sync. A startup recovery pass can remove stale staging files after verifying that none are canonical data.

### File Watching And Browser Updates

Watch only `Dashboard/**/*.md`, not the whole vault. Chokidar normalizes add/change/delete events, understands atomic-write patterns, and can delay events until chunked writes settle. After a debounced change, reread and validate the file, update the in-memory index, then notify open browsers by Server-Sent Events. [Chokidar repository and documentation](https://github.com/paulmillr/chokidar)

The browser should never optimistically claim a persistent save until the server returns the new revision. Optimistic visual changes are acceptable if the control rolls back on validation, permission, or conflict failure.

### Parser And Round-Trip Rule

Do not round-trip arbitrary vault notes through a general YAML/Markdown serializer. Many serializers normalize quoting, ordering, line endings, and whitespace. The MVP owns only files created from the dashboard template. It can then serialize those files deterministically.

For a longer free-text body, preserve the body byte-for-byte unless the user explicitly edits it. For an existing non-dashboard note, expose a link to open it in Obsidian rather than letting the service rewrite it.

## Recommended Markdown Schema

Use **one item per Markdown file**. That makes conflicts, audit history, linking, and atomic writes much simpler than many browser controls rewriting one large daily note.

Suggested layout:

```text
Dashboard/
  Dashboard.base
  Items/
    2026/
      08/
        01K3... - Call Insurance.md
  Daily Notes/
    2026-08-22.md
  Weekly Reviews/
    2026-W34 - Weekly Review Draft.md
  Templates/
    Dashboard Item.md
```

Suggested item:

```markdown
---
dashboard_type: task
dashboard_id: 01K3E6D8Q55F9N6M6KJ4G2A7R8
title: Call insurance
status: open
due: 2026-08-22
priority: 2
source: manual
created_at: 2026-08-22T09:10:00+05:30
updated_at: 2026-08-22T09:10:00+05:30
tags:
  - dashboard
---

Ask about the renewal quote and note the reference number here.
```

Rules:

- `dashboard_id` is immutable and independent of the filename.
- `dashboard_type` starts with `task`, `capture`, or `note`; do not invent new types without a schema change.
- `status` is one of `open`, `doing`, `waiting`, `done`, or `archived`.
- `priority` is an integer from 0 to 3.
- `due` is an ISO date or absent.
- timestamps include an offset and are written by the owning service.
- `source` records `manual`, `hermes-telegram`, `hermes-discord`, or `claude-weekly`.
- the body is free-form Markdown; structured state stays in properties.
- a dashboard completion checkbox changes `status` to `done`; do not maintain a second Boolean that can disagree.

The daily page should be a **view**, not a second copy of every item. The HTML UI and `Dashboard.base` both filter items by `due`, `status`, and `updated_at`. A short daily journal field may be a single `Daily Notes/YYYY-MM-DD.md` file, but its whole-body update must also use a revision check.

Avoid using Markdown task-list lines as the primary database for the MVP. `- [ ]` is excellent for human prose but needs a stable embedded identifier and precise line-preserving edits to be safe as a multi-client record store. The app may render task notes as checkboxes while persisting their canonical state in frontmatter.

## Weekly Claude Or Hermes Workflow

The weekly workflow should read dashboard items and selected daily notes for a fixed date range and create a new draft:

```text
Dashboard/Weekly Reviews/2026-W34 - Weekly Review Draft.md
```

Suggested review properties:

```yaml
dashboard_type: weekly-review
week: 2026-W34
status: draft
generated_by: claude
generated_at: 2026-08-23T20:00:00+05:30
source_from: 2026-08-17
source_through: 2026-08-23
```

The body should contain accomplishments, open loops, overdue items, decisions to revisit, and links to the source notes. It should clearly label inference separately from quoted facts.

Hermes cron is a good scheduler because recurring jobs can be pinned to an explicit provider and model, run in a fresh session, use a restricted toolset, and deliver results to a local file or messaging target. The gateway records execution history and prevents overlapping scheduler ticks with a lock. [Hermes scheduled tasks](https://hermes-agent.nousresearch.com/docs/user-guide/features/cron/)

Recommended job rules:

- run after the expected end-of-week sync window;
- use a self-contained prompt and a fixed input path allowlist;
- pin the provider and model explicitly;
- allow read access to the dashboard subtree and write access only to `Weekly Reviews/`;
- create a draft, never publish or rewrite reviewed notes;
- include the date range, source paths, and source revision hashes;
- if the target draft already exists, create a versioned retry or require its expected revision;
- send a short Telegram or Discord notification with a link after the file is saved;
- if using the Claude API, send only the selected notes that the user is comfortable transmitting to Anthropic. The Claude Messages API is a hosted REST call, not a local Spark inference path. [Claude Messages API](https://platform.claude.com/docs/en/api/messages/create)

A local Hermes model can implement the same workflow without sending vault content outside the tailnet. The scheduler and storage contract should stay model-independent so Claude can be used selectively rather than becoming a data dependency.

## Why Git-Backed CMS Tools Are Not The Default

Decap CMS, TinaCMS, and Keystatic are credible products, but they solve a different ownership problem.

- Decap is a single-page editor for content stored in a Git repository. Its normal save creates commits; editorial workflow creates branches and pull requests. [Decap CMS repository](https://github.com/decaporg/decap-cms), [Decap editorial workflow](https://decapcms.org/docs/editorial-workflows/)
- Tina's data layer serves Markdown and JSON through an indexed API, but Git remains the underlying content repository. [Tina data layer](https://tina.io/docs/reference/content-api/data-layer)
- Keystatic local mode writes the local filesystem, while GitHub mode requires repository access and runs its editor against GitHub-backed branches. [Keystatic local mode](https://keystatic.com/docs/local-mode), [Keystatic GitHub mode](https://keystatic.com/docs/github-mode)

These are good when a Git repository is the primary multi-user database and publication follows commits or pull requests. Here, Obsidian Sync is already the live transport between desktop, phone, laptop, and Spark. Adding a Git-backed editor means the live Spark replica must also pull and merge commits, or the desktop must push and then wait for a pull. That adds a second propagation path, makes conflicts less immediate, and can cause a Git checkout or merge to rewrite many synced files.

The existing desktop Git repository remains useful for version history and backup snapshots. Keep it commit-only with respect to the live vault; do not make automated `pull`, `reset`, checkout, or remote merges another bidirectional sync mechanism. Obsidian itself says Git is a manual-sync alternative and warns against combining multiple sync services on the same files. [Obsidian sync methods](https://obsidian.md/help/sync-notes), [Obsidian Sync FAQ](https://obsidian.md/help/sync/faq)

## Personal-Sync Move Out Of Google Drive

The active Personal-Sync desktop replica was moved to `F:\Vaults\Personal-Sync` on 2026-08-22. Obsidian currently registers that path as open and the former `I:\My Drive\Obsidian Vaults\Sync Remote` path as not open. This removes the active dual-sync condition, provided the old copy is not reopened against the same remote vault. Obsidian explicitly recommends moving a vault out of Google Drive, OneDrive, Dropbox, or other third-party sync storage because multiple solutions can cause conflicts. [Switch to Obsidian Sync](https://obsidian.md/help/sync/switch)

Therefore:

- build and test this dashboard in LLMWiki first because it already has Git history and the planned agent-output path;
- keep the former Google Drive copy closed while the new local vault finishes Sync verification;
- do not point the MVP writer at Personal-Sync until the new path reports fully synced and one restore test passes;
- use Google Drive only for a dated one-way backup snapshot, not live bidirectional management of the same files;
- archive or remove the old registered vault entry after the moved vault and backup have been verified.

The immediate dual-sync risk is now mitigated. The remaining risk is accidentally reopening the former Drive copy while the new local copy is connected to the same remote vault.

## Failure Modes And Controls

| Failure | Control | Evidence to retain |
|---|---|---|
| Desktop and dashboard edit the same record | Strong revision/ETag plus `If-Match`; show conflict, never last-write-wins | Two-client conflict test returns 412 and preserves both inputs |
| Process dies during a write | Staged write, flush, atomic rename, startup recovery | Kill process during repeated writes; every surviving file parses |
| Obsidian Sync delivers a partial/chunked event | Chokidar debounce/settle, then reread and validate | Watcher test with atomic and chunked writes |
| Agent writes outside its scope | Dedicated account or narrow storage API; canonical path allowlist | Attempted traversal and symlink writes are rejected |
| Browser is exposed publicly | Loopback bind, Tailscale Serve, ACL, application auth, no Funnel | LAN/public connection fails; allowed tailnet device succeeds |
| Parser reformats unrelated notes | Service owns dashboard files only; preserve bodies; golden round-trip tests | Byte comparison of unedited regions |
| Weekly model invents a fact | Draft status, source links/hashes, human review | Review note distinguishes source-backed statements and inference |
| Personal-Sync has two sync systems | Keep MVP out; move live vault outside Google Drive | New path is not under a cloud-managed folder |
| Git changes many live files | Snapshot commits only; no automated pull/checkout in the live tree | Git job logs show add/commit only |
| Offline device returns with stale edit | One record per file, Obsidian version history, conflict review | Offline reconnection drill preserves both versions or raises conflict |

## MVP Implementation Plan

### Phase 0: Data Safety

- [ ] Confirm LLMWiki desktop Git status and create a recoverable snapshot commit.
- [ ] Confirm the Spark LLMWiki headless Sync service is healthy, continuous, bidirectional, and at zero unexpected restarts.
- [ ] Confirm the dashboard MVP will not touch Personal-Sync.
- [ ] Record current Obsidian Sync version history access and restore one disposable test note.

**Gate:** a deleted or overwritten disposable note can be recovered before a new writer is introduced.

### Phase 1: Obsidian-Native Schema Prototype

- [ ] Create `Dashboard/Items`, `Dashboard/Daily Notes`, `Dashboard/Weekly Reviews`, and `Dashboard/Templates`.
- [ ] Create the item template with the exact properties above.
- [ ] Create `Dashboard.base` with Today, Open, Waiting, Done This Week, and Inbox views.
- [ ] Create at least ten realistic records, including a task, capture, overdue item, waiting item, and completed item.
- [ ] Edit every supported field from desktop and phone Obsidian.
- [ ] Confirm those bytes arrive on the Spark and render correctly after a round trip.
- [ ] Add Meta Bind only if a needed text area, toggle, or button is missing from Bases.

**Gate:** the user prefers the schema after seven days of real use and no conflicting duplicate field has appeared.

### Phase 2: Storage API

- [ ] Build schema validation, canonical path enforcement, per-file locks, revisions, conditional PATCH, staging writes, and audit logs.
- [ ] Make create operations idempotent with a client-provided `dashboard_id`.
- [ ] Add golden tests that prove untouched Markdown body bytes remain untouched.
- [ ] Add traversal, symlink, malformed YAML, duplicate ID, stale revision, and kill-during-write tests.
- [ ] Run the service under an unprivileged user with write permission only to `Dashboard/`.

**Gate:** all failure tests pass and the service cannot read or write a sibling vault note through its API.

### Phase 3: HTML Dashboard

- [ ] Build Today, Inbox, Waiting, Done, quick capture, task create, status toggle, due date, and note-body edit views.
- [ ] Use Server-Sent Events for file-change notifications.
- [ ] Display the saved revision and a visible conflict resolution panel.
- [ ] Separate `Saved on Spark` from Sync status; never imply remote delivery without evidence.
- [ ] Bind the app to loopback and expose it using Tailscale Serve with ACL and application authentication.
- [ ] Test desktop, laptop, and phone through the tailnet; prove the LAN and public internet cannot reach it.

**Gate:** a browser-created item appears in desktop Obsidian, and a desktop edit updates an already-open browser without manual reload.

### Phase 4: Conflict And Recovery Drill

- [ ] Edit the same test record in Obsidian and the browser from the same starting revision.
- [ ] Confirm the second save is rejected instead of overwriting.
- [ ] Stop the web service mid-write and verify the canonical file is either old or new, never truncated.
- [ ] Disconnect one client, edit, reconnect, and inspect Obsidian Sync version/conflict behavior.
- [ ] Reboot Spark and verify the dashboard, watcher, Tailscale route, Hermes, and both Sync services recover in the intended order.

**Gate:** no silent data loss in the concurrent, interrupted, offline, or reboot tests.

### Phase 5: Weekly Review Draft

- [ ] Write a self-contained Hermes cron prompt with explicit input and output paths.
- [ ] Pin provider and model and restrict the job to read dashboard files and write weekly drafts.
- [ ] Run the job manually against a disposable week.
- [ ] Confirm the output is a new draft with date range, source links, source hashes, and no canonical task mutation.
- [ ] Review the first four weekly drafts manually before allowing unattended recurrence.

**Gate:** four consecutive runs produce reviewable drafts, no unexpected file edits, and an auditable Hermes execution history.

### Phase 6: Decide Whether To Keep The Web Layer

- [ ] Compare one week of Obsidian Bases-only use with one week of the HTML dashboard.
- [ ] Retain the HTML service only if it materially improves phone capture, daily review, or automation control.
- [ ] If full browser Markdown editing is desired, test SilverBullet against a disposable dashboard subtree and compare its conflict behavior with the custom app.

**Gate:** one interface is designated canonical for daily use; redundant services are removed or left deliberately read-only.

## Acceptance Tests

The MVP is complete only when all of these pass:

1. Browser create -> Spark Markdown exists -> desktop Obsidian displays it -> hashes match.
2. Desktop property edit -> Spark file changes -> open dashboard updates without refresh.
3. Browser task completion -> exactly one canonical property changes -> desktop shows Done.
4. Browser free-text edit -> Markdown body retains all unedited bytes and valid UTF-8.
5. Stale browser revision -> HTTP 412 and a human-readable conflict screen; file is unchanged.
6. Forced process termination during 1,000 test updates -> zero truncated or invalid files.
7. Reboot -> Sync, dashboard, and private HTTPS access return without an interactive login.
8. Unauthorized tailnet identity, LAN client, and public client -> no access.
9. Weekly run -> one new draft, correct source range, source links/hashes, no canonical edits.
10. Git snapshot after dashboard activity -> expected Markdown diff only; no secrets, runtime database, logs, or staging files.

## Final Recommendation

For the clarified requirement, the easiest safe version is a **small HTML report viewer with a three-field feedback write-back API**. It reads one agent report per Markdown file and changes only `feedback`, `feedback_note`, and `feedback_updated_at`; Obsidian Sync handles propagation to the machines already in use.

This is a modest application, not a research gamble: the hard parts are well-understood file ownership, conflict detection, atomic writes, and access control. Use Markdown as the canonical store, ETags for optimistic concurrency, an allowlisted scheduled-output subtree, and Tailscale-only HTTPS. Obsidian Bases and Meta Bind remain useful only if the feedback interface should also live inside Obsidian.

SilverBullet is worth a disposable trial if the goal expands from a dashboard to a complete browser Markdown editor. Git-backed CMS tools are not recommended for this live vault because they would make Git a second propagation system beside Obsidian Sync.

The active Personal-Sync replica is now outside Google Drive. Keep the old Drive copy closed and verify full Sync plus recovery before any second-vault dashboard rollout.

## Primary Sources

- [CommonMark specification](https://spec.commonmark.org/spec)
- [Obsidian Bases](https://obsidian.md/help/bases)
- [Obsidian properties](https://obsidian.md/help/properties)
- [Obsidian Sync FAQ](https://obsidian.md/help/sync/faq)
- [Switch to Obsidian Sync](https://obsidian.md/help/sync/switch)
- [Meta Bind repository](https://github.com/mProjectsCode/obsidian-meta-bind-plugin)
- [SilverBullet repository](https://github.com/silverbulletmd/silverbullet)
- [SilverBullet Sync](https://v2.silverbullet.md/Sync)
- [RFC 9110 If-Match](https://www.rfc-editor.org/rfc/rfc9110.html#name-if-match)
- [Node.js filesystem API](https://nodejs.org/api/fs.html)
- [Chokidar repository](https://github.com/paulmillr/chokidar)
- [Tailscale Serve](https://tailscale.com/docs/reference/examples/serve)
- [Hermes scheduled tasks](https://hermes-agent.nousresearch.com/docs/user-guide/features/cron/)
- [Claude Messages API](https://platform.claude.com/docs/en/api/messages/create)
- [Decap CMS repository](https://github.com/decaporg/decap-cms)
- [Tina data layer](https://tina.io/docs/reference/content-api/data-layer)
- [Keystatic local mode](https://keystatic.com/docs/local-mode)

## Related Notes

[[Local Setup Index]]
[[Task Checklist]]
[[personal-hermes-obsidian-multinode-design|Personal Hermes, Obsidian, and Multi-Node Inference Design]]
[[Spark Hermes Setup Runbook]]
[[Always-On Hermes on DGX Spark]]
