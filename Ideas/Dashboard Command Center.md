---
type: project-spec
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Dashboard Command Center and Multi-Webview Shell#1. Dashboard Command Center]]"
status: concept
difficulty: hard
priority: p1
category: Windows dashboard shell and workspace orchestration
form_factor:
  - Windows desktop application
  - multi-window dashboard workspace
  - system-tray launcher
deployment: Windows workstation with private Spark dashboards over Tailscale
source_ideas:
  - register localhost and URL dashboards in a browser-chrome-free desktop shell
  - organize dashboards as horizontal or vertical Excel-like tabs with nested child tabs
  - detach dashboards into multiple windows and restore layouts across monitors and orientations
  - keep a later Android companion possible without constraining the Windows-first design
tags:
  - dashboards
  - Windows
  - Electron
  - WebContentsView
  - multi-monitor
  - Tailscale
  - DGX-Spark
  - Obsidian
  - local-first
---

# Dashboard Command Center

> A Windows-first, browser-chrome-free operations shell for private dashboards: register localhost or Tailscale URLs once, organize them like workbook sheets, detach them across monitors, and restore the right dashboard scene without turning the shell into another general-purpose browser.

## Product Outcome

Build a native-feeling Windows workspace that displays the user's existing web dashboards while leaving each dashboard responsible for its own data, automation, authentication, and Obsidian integration. In this project, **dashboard** means any application or service whose usable interface is reached through a registered URL; it does not have to be a chart-heavy analytics page. The Command Center owns discovery, organization, display, desired runtime state, window choreography, health visibility, and recovery—not the finance logic, agent jobs, notes, or application APIs behind the pages.

Registration replaces repeated address entry. After a URL is approved once, its logical dashboard record, login/session boundary, navigation home, endpoint choice, enabled/paused state, resource policy, and optional schedule persist through app and Windows restarts. Persistence must not mean “keep one Chromium renderer alive forever.” The service can continue running on Spark or the workstation while its visual renderer is hibernated and recreated when needed.

The core daily loop is:

1. Register a logical dashboard such as Finance Signals, Agent Reports, Spark Health, Study Queue, or Net Worth.
2. Give it one or more endpoints: a Windows-local loopback URL, a private Spark URL, or a future device-specific endpoint.
3. Place it in a nested group and choose a navigation style: bottom sheet tabs like Excel, a collapsible vertical rail, or a compact top strip.
4. Open one dashboard, a split view, or a saved scene spanning several native windows and monitors.
5. Restore that arrangement after restart, display rotation, docking, or a temporarily missing monitor.
6. Diagnose an unavailable dashboard without confusing a stopped backend, disconnected Tailscale, failed login, blocked navigation, or crashed renderer.

The field calls this a **multi-service browser**, **web-app container**, **site-specific browser manager**, **workspace browser**, or **multi-webview shell**. This project is narrower: a **private dashboard operations shell**. It is not a browser replacement, a remote-desktop product, a homepage of links, or a mega-dashboard that absorbs every underlying project.

“Does not look like a browser” is an interface goal, not permission to hide trust information. The ordinary address bar can disappear, but the user must always be able to reveal the current origin, certificate/error state, session boundary, and an “open in system browser” action. A clean shell should never make a spoofed login page more convincing.

### Windows Interaction Model

- **Workbook navigation:** a workspace is analogous to an Excel workbook; the dashboards in the active group appear as colored sheet tabs along the bottom. The same hierarchy can render as a collapsible left rail without changing the underlying data.
- **Nested groups without infinite nesting:** start with two levels—group and dashboard. A group such as Money can contain Finance Signals, Net Worth, and Subscriptions; deeper arbitrary trees add drag-and-drop ambiguity before they add value.
- **Detach and reattach:** drag or command a sheet into its own native window, move it to another monitor, maximize or full-screen it, then reattach it to the original workspace.
- **Scene restore:** save named arrangements such as Morning Review, Agent Operations, Study, or Markets. A scene stores semantic display roles and split ratios rather than only brittle pixel coordinates.
- **Orientation-aware layouts:** a portrait monitor can use a vertical stack or full-height dashboard, while a landscape monitor uses a horizontal split. If the monitor disappears, the app gathers the window onto the primary display instead of restoring it off-screen.
- **Focused controls:** every dashboard gets back, forward, reload, hard reload, home, zoom, find, copy URL, reveal origin, reset session, and open in browser. Keep these in a compact command menu rather than a permanent browser toolbar.
- **Keyboard-first navigation:** Ctrl+K for dashboard search, configurable numeric sheet shortcuts, next/previous dashboard, detach, move to monitor, full screen, reload, and restore scene.
- **Visible state:** distinguish registered, running, suspended, unreachable, authentication required, stale, and crashed. A grey blank surface is not an error message.

## Personal V0

Build and dogfood a Windows-only personal beta against ten real dashboards. Do not build an account system or phone app.

- Register, edit, duplicate, reorder, disable, and remove a dashboard with title, icon, color, tags, expected origins, endpoint variants, authentication group, and optional health check.
- Give each dashboard an explicit state and runtime policy: disabled, paused, on-demand, warm, always-live, or scheduled. Show the expected RAM/background cost before accepting always-live.
- Resolve both Windows-local endpoints and private HTTPS Tailscale Serve endpoints. Label every loopback endpoint “this PC only.”
- Organize dashboards into two-level groups and switch between bottom Excel-like sheet tabs and a collapsible vertical rail.
- Open one live dashboard per native window. Add one controlled two-panel horizontal or vertical split only after single-window detach/reattach is stable.
- Detach a sheet into another window, move it between connected monitors, full-screen it, and reattach it without losing its logical dashboard identity.
- Save and restore three named scenes across the user's actual monitor setup. Clamp invalid/off-screen bounds when topology, DPI, work area, or orientation changes.
- Persist deliberate browser sessions by authentication boundary, not by navigation group. Finance dashboards may share one trusted session only when explicitly configured; unrelated services remain isolated.
- Keep only visible views plus a small warm cache alive. Suspend or destroy older hidden renderers without deleting their registration, login partition, or backend service state.
- Support simple view schedules such as “pre-warm at 08:55 and open in Morning Review at 09:00.” Record agent/backend job schedules and last/next run as dashboard metadata, but let the dashboard's own scheduler, Windows Task Scheduler, n8n, or Spark service execute the work independently of whether a webview is alive.
- Show specific diagnostics for localhost mismatch, Tailscale disconnection, DNS/TLS failure, backend unavailable, authentication required, navigation blocked, timeout, and renderer crash.
- Export and import a versioned, human-readable registry and scene file containing no cookies, passwords, bearer tokens, or monitor-specific secrets.
- Record cold/warm load time, memory, background CPU, crashes, restore corrections, and manual window rearrangements so the build can be compared with the Edge-app/FancyZones baseline.

The personal alpha should launch daily with Windows, live in the system tray, remember the last safe workspace, and offer a recovery start that opens the shell with no remote dashboards loaded. It should remain useful when Spark is offline: the registry and shell open normally, remote cards explain the failure, and Windows-local dashboards still work.

## Build Boundary

**MVP:** Windows 11; local registry; horizontal or vertical navigation; two-level groups; per-dashboard enabled/paused/on-demand/warm/always-live/scheduled policy; one active dashboard per window; detach/reattach; multi-monitor scene restore; device-aware endpoint resolution; named session partitions; health and error states; browser fallback; configuration export/import; installer; crash-safe startup.

**After the MVP is battle-tested:** split-pane trees; hibernation thumbnails; scene variants for different monitor topologies; optional private registry sync through Spark; dashboard manifests that declare job status, safe actions, and feedback capabilities; controlled download/print support; update channel; more polished Windows integration.

**Later scope expansion only:** a simplified Android companion may reuse the dashboard registry, groups, icons, and private Tailscale URLs while showing one dashboard at a time. It does not need desktop scene semantics, multi-window parity, shared cookies, or the same rendering stack. Do not choose Tauri, Capacitor, React Native, or a web-only architecture merely to preserve hypothetical phone code reuse.

Do not include in the first build: a general address bar and arbitrary web browsing; browser extensions; password manager; cookie synchronization; cloud accounts; notification aggregation; agent injection into remote pages; arbitrary JavaScript/CSS injection; remote desktop; dashboard data aggregation; public sharing; or a marketplace of dashboard recipes.

## Existing Products, Building Blocks, and Shortcuts

- [Rambox](https://rambox.app/how-it-works/) is the closest product benchmark: custom web apps, workspaces, persistent sessions, search, simultaneous tile view, and synchronized setup. Use it to test whether a private custom shell is actually needed. Its general app catalog, notification system, and cloud account are broader than this project.
- [Wavebox](https://wavebox.io/platform) provides the clearest conceptual separation between Spaces, Groups, Apps, and Profiles. Borrow the separation between navigation membership and cookie isolation; two dashboards can be in one group without sharing an authentication store.
- [WebCatalog](https://webcatalog.io/en/solutions/workspaces) demonstrates dedicated site-specific windows and isolated profiles. “Open as dedicated browser app” and “duplicate with separate session” are valuable fallbacks.
- [Ferdium](https://github.com/ferdium/ferdium-app) is a maintained open-source Electron service container with workspaces and custom services. Its [self-hostable server](https://github.com/ferdium/ferdium-server) shows how service/workspace metadata can sync without making the desktop client depend on a hosted vendor account. Study it; do not begin by forking its messaging-centric architecture.
- [Station](https://github.com/getstation/desktop-app) is useful historical source for service records, inactive-tab handling, a dock, and SQLite persistence. Its maintenance and Electron age must be treated as a warning, not a default dependency.
- [Homarr](https://github.com/homarr-labs/homarr) and [Heimdall](https://github.com/linuxserver/Heimdall) are self-hosted homepages that register and launch services. They are good alternatives if discovery is the real problem, but they do not own native windows, renderer sessions, or multi-monitor restore.
- [Tessera](https://github.com/nirkheashish-tech/tessera) and [Dockyard](https://github.com/MayR-Labs/dockyard-electron) are small open-source prototypes close to the requested multi-pane/detachable interaction. Read them for pane trees, domain policies, session partitions, hibernation, docks, and JSON configuration; independently audit every security-sensitive pattern before reusing code.
- Microsoft Edge can [install any website as an app](https://support.microsoft.com/en-us/edge/install-manage-or-uninstall-apps-in-microsoft-edge), producing a browser-chrome-light window with mature Chromium authentication and updates. [PowerToys FancyZones](https://learn.microsoft.com/en-us/windows/powertoys/fancyzones) already handles custom monitor layouts. Together they are the mandatory zero-build comparison.
- Electron's [BaseWindow](https://www.electronjs.org/docs/latest/api/base-window) and [WebContentsView](https://www.electronjs.org/docs/latest/api/web-contents-view) directly support several independently positioned web contents in one native window. Electron recommends WebContentsView over its older webview tag; ordinary iframes remain subject to the target site's framing policy.
- [Tailscale Serve](https://tailscale.com/docs/features/tailscale-serve) can expose a dashboard bound to loopback through a private HTTPS tailnet URL. [MagicDNS](https://tailscale.com/docs/features/magicdns) supplies stable device names, and access rules still apply. Use Serve, not public Funnel, for personal dashboards.

The simplest serious alternative is: a human-readable dashboard registry, five Edge-installed sites, two or three FancyZones layouts, and a small launcher/command palette. Dogfood this for two weeks. Build the embedded shell only if nested navigation, unified restore, endpoint resolution, health visibility, split views, or controlled hibernation remain recurring pain.

## Recommended Free-First Stack

### Chosen Windows V0

- **Desktop runtime:** current supported stable Electron. Its bundled Chromium and browser-process APIs fit a multi-dashboard shell better than a lightweight wrapper whose main benefit is binary size.
- **Shell UI:** TypeScript, React, Vite, CSS variables, and a small accessible component layer. Use one trusted local renderer for navigation and settings; remote dashboards never render inside that React DOM.
- **Remote surfaces:** BaseWindow plus WebContentsView. Avoid Electron's webview tag and avoid iframes as the core because iframe embedding can be blocked by Content-Security-Policy or X-Frame-Options.
- **Packaging:** Electron Forge with its Vite integration and Squirrel.Windows for a simple per-user installer. Add signing and an authenticated update channel only when the app leaves the personal machine.
- **Configuration:** versioned JSON validated with Zod, written through a staged temporary file plus atomic rename, with a last-known-good backup. The registry is small enough that a database is unnecessary at first.
- **Operational history:** newline-delimited JSON or a small SQLite database only after health/performance history becomes useful. Avoid a native SQLite packaging dependency until the data demands it.
- **Secrets:** dashboard cookies remain in Electron/Chromium session partitions. Use Electron safeStorage only for Command Center-owned secrets if one ever appears; never place tokens or passwords in the registry.
- **Networking:** HTTPS fetch/health checks plus optional read-only parsing of local Tailscale status for diagnostics. Dashboards remain loopback-bound and are exposed privately through Tailscale Serve.
- **Logging:** structured rotating local logs with redaction of query strings, authorization headers, cookies, and page content. Keep renderer crash and restore decisions, not private dashboard payloads.
- **Testing:** Vitest for schemas, endpoint selection, tree operations, and layout math; Playwright's Electron support for packaged interaction flows; golden fixture files for migration; Windows VM smoke tests for installer/restart; real mixed-DPI and monitor-unplug tests on the workstation.
- **No model requirement:** this is deterministic desktop infrastructure. Agents may edit or generate registry entries through a reviewed file/API later, but no LLM belongs in the rendering, security, or layout path.

### Why not the attractive alternatives first

- **Tauri v2:** viable and smaller, with remote webviews and multiple windows, but the runtime and session behavior depend on platform webviews and multi-webview orchestration is a lower-level path. Use it as a measured learning spike only if Electron's installed size or memory remains unacceptable after hibernation.
- **WinUI 3 plus WebView2:** the strongest native Windows alternative. It gives excellent OS integration and explicit WebView2 profiles, but requires more C#/Windows App SDK host work for the same multi-content shell. Choose it later if native Windows development is itself the learning goal.
- **Browser/PWA:** ideal for a registry or launcher but cannot reliably embed arbitrary dashboards or manage native multi-monitor windows. It is the shortcut, not the full requested shell.
- **Wails:** attractive for Go, but current multi-window/multi-view maturity is a worse fit for this security-sensitive browser-shell job than Electron or direct WebView2.

## Architecture and Data Model

### Trust architecture

1. **Electron main process:** the only owner of windows, views, sessions, registry persistence, endpoint resolution, permission policy, navigation policy, health checks, and lifecycle decisions.
2. **Trusted shell renderer:** a packaged local UI for groups, sheet tabs, search, settings, diagnostics, and scene commands. It receives a narrow typed IPC surface and cannot issue generic filesystem, shell, or arbitrary web-content commands.
3. **Untrusted dashboard renderers:** one WebContentsView for each visible dashboard panel, with Node integration disabled, context isolation and sandboxing enabled, no general preload bridge, and no access to Command Center state beyond normal web navigation.
4. **Dashboard backends:** Spark or workstation services own their data, writes, authentication, agents, and Obsidian access. The Command Center does not proxy internal dashboard APIs or write into the vault on their behalf.
5. **System browser fallback:** unsupported authentication, WebAuthn, downloads, or unregistered destinations open in the default browser after URL validation.

### Canonical records

- **Dashboard:** stable identity, title, aliases, description, icon, color, tags, group memberships, endpoint IDs, session-boundary ID, navigation policy, health-probe ID, preferred zoom, default route, desired state, runtime policy, optional schedule/status-manifest IDs, created/updated timestamps, and schema version.
- **Endpoint:** kind such as device-local or tailnet; URL; device binding; priority; expected origin; reachability rule; optional health URL; and last manual verification. A dashboard has several endpoints; a tab does not own a literal universal URL.
- **Group:** stable ID, title, color, parent ID, sort order, and dashboard references. V0 enforces at most two visible levels.
- **Workspace:** task-oriented navigation tree, favorites, recent policy, default scene, and preferred navigation dock.
- **TabNode:** a reference to a dashboard or group plus selected child, not a duplicate dashboard record.
- **Scene:** semantic window arrangement: display roles, window records, panel split trees, split ratios, full-screen state, and active dashboard IDs.
- **DisplayFingerprint:** runtime observations such as bounds, work area, scale factor, rotation, and best-effort hardware/display identity. It helps map roles but never becomes the sole key.
- **SessionBoundary:** named persistent or memory-only partition, intentionally shared dashboard IDs/origins, permission rules, and reset history.
- **NavigationPolicy:** allowed main-frame origins, temporary authentication origins, external-link action, popup policy, download policy, and protocol allowlist.
- **RuntimePolicy:** disabled, paused, on-demand, warm, always-live, or scheduled; warm-cache priority; pre-warm lead time; allowed background activity; and user-visible cost estimate.
- **ServiceStatusManifest:** optional dashboard-owned URLs or schema for health, last/next agent job, safe declared actions, and supported feedback types. It is a capability description, not permission for arbitrary DOM or shell automation.
- **ViewRuntime:** ephemeral renderer ID, load/crash state, memory priority, last focused time, health state, and current URL. It is not synchronized.
- **RegistryRevision:** schema version, content hash, revision/ETag, writer device, and conflict metadata for a later sync service.

Navigation organization, authentication isolation, endpoint selection, and window placement are separate concerns. Combining them into one “tab” object is the architectural mistake most likely to make later features brittle.

### Endpoint Resolution and Private Networking

The special name localhost always loops back to the machine opening it. On this Windows app, http://127.0.0.1:3000 means the Windows computer, never FirstSpark. Store a local endpoint with the Windows device ID and reject it on any other device rather than silently showing the wrong service.

For a Spark dashboard, prefer a full HTTPS Tailscale Serve address such as https://firstspark.example-tailnet.ts.net/finance. Using the stable private origin even from the main workstation avoids creating separate cookie, local-storage, permission, and service-worker worlds for localhost and tailnet URLs. Keep a loopback override only when offline use or latency makes it valuable.

Resolution order should be explicit and inspectable: forced endpoint for this scene; compatible device-local endpoint; healthy private tailnet endpoint; then a clear unavailable state. Never redirect silently between unrelated origins after authentication.

Keep backend services bound to loopback, publish them privately with Serve, and apply a narrow Tailscale access rule. Do not use Funnel. Note before future HTTPS naming work that a machine's certificate name can appear in public Certificate Transparency logs even though the service remains private; use non-sensitive node names.

If registry synchronization across Windows computers becomes useful, sync only dashboard, group, workspace, and semantic scene records. A tiny Spark API can use GET with ETag and PUT with If-Match, return 412 on conflicts, and write through a lock plus staged atomic rename. Keep cookies, bearer tokens, exact monitor coordinates, navigation history, permission decisions, and downloads local to each Windows installation.

### Sessions, Authentication, and Security

Map each explicit SessionBoundary to an Electron persistent partition. The safe default is isolation per origin or declared trust group. One global cookie jar creates accidental coupling; one partition per sheet forces duplicate logins and unnecessary storage. A “duplicate with isolated login” action creates a new dashboard instance or session boundary without changing the source dashboard.

OAuth is the largest compatibility trap. [RFC 8252](https://www.rfc-editor.org/info/rfc8252/) requires native applications to perform authorization through an external user agent, and providers such as Google may block embedded login flows. Offer “sign in/open in browser,” support a proper dashboard-owned redirect flow where available, and never scrape tokens from navigation events or cookies. Some third-party dashboards will remain browser-only; compatibility fallback is a feature, not a failure.

Follow Electron's [remote-content security checklist](https://www.electronjs.org/docs/latest/tutorial/security): load secure content; keep Node integration off; use context isolation and sandboxing; keep webSecurity enabled; deny permissions by default; constrain navigation and new windows; validate every IPC sender; avoid arbitrary preload scripts; validate URLs before opening them externally; and update Electron promptly. A registered URL is not automatically trusted code.

Retain a compact, user-invoked origin panel. It should show logical dashboard, selected endpoint, actual main-frame origin, session boundary, certificate/error status, allowed redirect origins, and the reason the current page was permitted. The shell must not make origin changes invisible.

### View Lifecycle and Resource Budget

Do not create one permanent renderer for every registered dashboard. The registry, service backend, agent schedule, login partition, and renderer are different lifecycles. The registry is cheap; Chromium renderers are not.

- **Disabled:** retain the record but exclude it from scenes, health polling, scheduled pre-warm, and normal navigation.
- **Paused:** retain the record and session, destroy its renderer, stop Command Center polling/pre-warm, and require an explicit resume. Its independent backend or agent scheduler may still run unless the dashboard exposes a separately confirmed service-control action.
- **On-demand:** create the renderer when opened and hibernate it after the idle threshold.
- **Warm:** keep it in the bounded recent-view cache for fast switching.
- **Always-live:** keep timers, SSE/WebSocket connections, and notifications alive only after explicit selection and measurement.
- **Scheduled:** pre-warm, open, focus, or hibernate the visual page on a local schedule. Do not pretend this schedule executes the dashboard's underlying agent job.
- Keep visible views live.
- Keep only the two to four most recently used hidden views warm after measuring the workstation.
- Leave background throttling enabled; an “always live” exception must be explicit and visible.
- Destroy older hidden WebContentsView webContents while preserving the session partition and logical tab state. BaseWindow does not automatically destroy child web contents, so every close/eviction path needs a leak test.
- Recreate an evicted view at its dashboard home or stored safe route, not by serializing arbitrary page memory.
- Treat thumbnails as sensitive. Make them opt-in per dashboard, store them locally, blur them in task switching if appropriate, and never capture financial or personal dashboards merely for decoration.
- Track a live-view budget and attribute memory/CPU to dashboard runtime IDs so one runaway page can be isolated and reset.

For scheduled agents, the preferred pattern is: Windows Task Scheduler, n8n, or a Spark service runs the job; the dashboard backend exposes last run, next run, result state, and a narrow retry/run action; the Command Center displays that contract. A later feedback manifest can expose dashboard-specific actions such as like, dislike, note, acknowledge, approve, or retry. Until such a contract exists, feedback stays inside the dashboard page that already owns its data and concurrency rules.

WebContentsView is controlled outside the DOM. The trusted shell reports the content rectangle whenever the navigation dock, window size, split ratio, or DPI changes; the main process applies bounds to each dashboard view. Test zoom and focus routing because the shell and dashboard are distinct renderers layered in one window.

### Scene and Window Restoration

Persist semantic roles such as primary, portrait-right, largest-available, or secondary-landscape along with relative split ratios. At launch, enumerate current displays, compare work areas, DPI, and rotation, map roles, clamp every window to a visible work area, and only then show content.

Save raw coordinates as a hint, not truth. Handle display-added, display-removed, and display-metrics-changed events. If a scene cannot be reproduced, open a preview explaining the remap and allow one-click accept rather than scattering windows unpredictably.

Crash recovery is separate from scene restore. Write state after a debounce and atomic checkpoint; keep the last known good scene; detect an unclean exit; and offer Safe Start, Restore Last Window Only, or Restore Scene. A repeatedly crashing dashboard should be quarantined from automatic reopen.

## Build Slices

1. **Zero-build baseline:** install five dashboards as Edge apps, define FancyZones layouts, create a simple registry, and record two weeks of tab hunting, window rearrangement, login friction, and restore failures.
2. **Registry contract:** implement Dashboard, Endpoint, Group, SessionBoundary, Workspace, Scene, and schema migrations with realistic fixtures and round-trip import/export.
3. **Secure single-view shell:** one trusted local navigation view plus one remote WebContentsView, origin panel, navigation allowlist, browser fallback, safe permissions, and crash screen.
4. **Workbook navigation:** bottom sheets, vertical rail, two-level grouping, reorder, favorites, recents, command palette, keyboard shortcuts, and per-dashboard controls.
5. **Endpoint resolver:** Windows device identity, loopback labels, Tailscale FQDN endpoints, health probes, resolution trace, and distinct offline/auth/TLS/backend error cards.
6. **Desired state and schedule:** disabled/paused/on-demand/warm/always-live/scheduled policies, schedule preview, pre-warm/open/hibernate events, and proof that hibernating a view does not stop its independent backend.
7. **Session boundaries:** persistent partitions, isolated duplicate, reset session, OAuth/browser fallback, and tests proving remote views cannot reach host IPC or files.
8. **Multi-window:** detach/reattach, window ownership, tray controls, taskbar behavior, full screen, per-window active dashboard, and renderer cleanup.
9. **Scene restore:** monitor fingerprints, semantic roles, mixed-DPI layout math, orientation variants, topology changes, off-screen recovery, and atomic checkpoints.
10. **Lifecycle budget:** warm-view LRU, background throttling, explicit always-live policy, renderer crash quarantine, resource inspector, and sensitive-thumbnail controls.
11. **Controlled split view:** horizontal/vertical two-panel layout, focus/keyboard routing, resizing, and bounds synchronization. General recursive pane trees come later.
12. **Packaging and recovery:** Electron Forge installer, auto-launch preference, safe start, local logs, backup/export, uninstall-data choice, and Windows VM smoke test.
13. **Private config sync only if needed:** Spark registry endpoint with ETag/If-Match, conflict UI, last-known-good cache, and no cookie/secret/window-coordinate transfer.
14. **Dashboard capability contract later:** read-only job schedule/result status first, then narrowly declared retry/run/feedback actions with per-action confirmation and backend-owned concurrency.

### Battle-Test Matrix

Use the same ten-dashboard fixture for Edge apps, Rambox/Ferdium, and the custom shell: two local dashboards; two Spark/Tailscale dashboards; one SSE/WebSocket dashboard; one login/popup flow; one download flow; one external-link flow; one duplicated account; and one deliberately unavailable backend.

Test cold and warm launch, idle and active memory, background CPU, authentication persistence, session isolation, popup routing, renderer crash containment, Spark outage, Tailscale disconnect, stale TLS/DNS, Windows reboot, app update, unclean exit, primary-monitor change, monitor unplug/reconnect, portrait rotation, mixed DPI, docking/undocking, sleep/wake, full keyboard navigation, and recovery to the system browser.

Keep a failure ledger. Every failure records dashboard ID, endpoint, stage, classified cause, recovery action, time to recovery, whether Edge handled it, and whether the same issue recurred. Fix frequent recovery costs before adding more layouts.

## Drawbacks, Concerns, and Failure Modes

- **It can quietly become a browser project.** Downloads, printing, media permissions, passkeys, client certificates, protocol handlers, extensions, spellcheck, popups, DevTools, and password management arrive one exception at a time. Define explicit non-goals and fall back to Edge.
- **Remote content raises workstation risk.** A compromised dashboard is ordinary web code only while Node, preload bridges, IPC, navigation, and permissions remain constrained. One convenient generic bridge can turn it into local-code execution.
- **OAuth and WebAuthn may fail inside the shell.** Embedded user agents can be blocked and passkey support differs. Never spoof a normal browser or steal its cookies; provide supported external authentication or a browser-only compatibility flag.
- **Memory and GPU usage scale with live views.** Twenty registered dashboards are cheap; twenty active Chromium renderers are not. Hibernation and measurement are product features.
- **A paused page is not a paused service.** Destroying a renderer does not stop a Spark process, cron job, n8n workflow, or Windows task. Service control needs an explicit dashboard-owned API and confirmation; never infer it from closing a tab.
- **BaseWindow view cleanup is manual.** Failing to close child webContents leaks memory after windows and scenes are closed.
- **A polished blank page hides the wrong failure.** Localhost mismatch, DNS, Tailscale, TLS, access denial, stopped service, authentication, navigation policy, and renderer crash require different evidence and recovery.
- **Window geometry is unstable.** Monitor IDs, taskbars, orientation, DPI, display order, remote desktop, and docking change. Raw coordinate restore can strand windows off-screen or make them unusably small.
- **Authentication grouping and navigation grouping differ.** Sharing cookies because two tabs sit beside each other is a privacy and correctness bug.
- **Origins can fragment one logical dashboard.** localhost and the Tailscale FQDN have different cookies, storage, service workers, and permission decisions. Prefer one stable private HTTPS origin.
- **Hidden browser chrome removes security cues.** Keep an origin inspector and surface redirects, certificate errors, and permission requests.
- **Dashboard assumptions vary.** Browser extensions, unusual user agents, popup opener chains, third-party cookies, downloads, or native deep links may break. Maintain a per-dashboard compatibility record and browser fallback.
- **Configuration sync can corrupt concurrent edits.** If agents and the desktop app edit the same registry, require schema validation, revision checks, ETags, conflict handling, backups, and atomic writes.
- **Screenshots can leak private data.** A visual suspended-tab cache may expose finances, health, messages, or agent reports. Default to icon/title/status placeholders.
- **The shell should not write dashboard data.** Agent or Obsidian mutations belong behind each dashboard's own narrow backend and concurrency controls; otherwise the container becomes a privileged universal automation surface.
- **The zero-build combination may win.** If Edge apps plus FancyZones and a registry solve the workflow, maintaining a custom Chromium application is poor leverage.

For the private single-user V0, load the user's own registered dashboards over local or tailnet endpoints and keep the chosen Windows stack. Before public distribution, accounts, hosted sync, team registries, third-party arbitrary URLs, or a plugin/recipe marketplace, run [[Scope Expansion Checklist]] for code/data licenses, browser-engine updates, code signing, auto-update integrity, privacy, authentication, URL abuse, accessibility, platform terms, and security review. That future release audit should not change the V0 stack merely to anticipate hypothetical users.

## Clever Hacks and Simpler Alternative

- Use Edge installed apps and FancyZones as a continuing regression baseline, not a disposable mock. A dashboard broken in Command Center but working in Edge immediately gets an “open in Edge” compatibility path.
- Start with one active dashboard per window. The user already gets multi-monitor use through detachable windows; recursive split panes can wait until restore is reliable.
- Render bottom Excel-style tabs as a view of the active group while the full collection stays in a searchable vertical tree. This preserves the requested metaphor without forcing a flat catalog.
- Store scenes by semantic display roles and relative ratios. “Portrait-right, full height” survives hardware changes better than a rectangle alone.
- Give every endpoint a resolution explanation: “Using Spark HTTPS because this dashboard has no endpoint for this Windows device.” This makes routing debuggable.
- Standardize on the Tailscale HTTPS origin even while sitting at the workstation; it prevents double login/storage worlds and exercises the same route used remotely.
- Keep the registry human-readable and agent-editable, but make agents propose validated patches rather than editing live runtime state. Import only schema-valid revisions.
- Use favicon plus health color as the default suspended state. Thumbnails are opt-in because private dashboards are more sensitive than ordinary websites.
- Cap live renderers and show the cost. “3 live, 2 warm, 17 asleep” turns hidden resource use into an understandable policy.
- Pre-warm a scheduled dashboard shortly before the user needs it instead of keeping it alive all day. Run the agent job independently and open the completed result page at review time.
- Quarantine a dashboard after repeated startup crashes and restore the rest of the scene. One bad page should not create a launch loop.
- Let the system browser handle authentication and specialist features. The product becomes more reliable when “open externally” is a designed route.
- The simplest alternative is a Homarr or JSON registry plus Edge-installed dashboard windows and PowerToys FancyZones. Keep it permanently if the custom shell cannot measurably beat it.

## Success Measures

- Ten real dashboards—Windows-local and Spark-hosted—can be registered, grouped, opened, moved, closed, and restored without losing the logical registry.
- The median time from shortcut to the intended dashboard or scene is lower than the normal browser-profile and Edge-app baselines.
- Three named scenes restore correctly after Windows restart and sleep/wake on the user's normal monitor setup.
- Unplugging, rotating, or changing the primary monitor never leaves a window entirely off-screen; recovery is explainable and reversible.
- Hidden dashboards stay within a measured live-view, memory, GPU, and background-CPU budget; closing windows returns renderer resources rather than leaking them.
- Disabled, paused, on-demand, warm, always-live, and scheduled policies behave distinctly across restart, and the UI never implies that pausing a view stopped its backend job.
- A scheduled dashboard can pre-warm and open at the requested review time while its agent job succeeds even when no renderer was alive beforehand.
- Session-isolation tests prove unrelated dashboards do not share cookies/storage, while explicitly shared dashboards keep login through restart.
- Remote dashboards have no Node integration, general preload bridge, filesystem access, shell access, or unvalidated IPC path.
- Every unavailable test endpoint produces the correct class of error and one useful recovery action instead of a blank page.
- OAuth/passkey/download incompatibilities fall back to the system browser without exposing tokens or broadening the remote renderer's privileges.
- Registry export/import round-trips exactly, validates migrations, contains no secrets, and recovers from an interrupted write.
- A forced renderer crash does not terminate unrelated dashboards; a repeated startup crash triggers quarantine and Safe Start.
- After four weeks, the failure ledger shows fewer manual rearrangements and less tab hunting than Edge plus FancyZones. If it does not, keep the simpler stack.

## Product Path

Edge apps plus FancyZones baseline -> Windows registry and secure single-view shell -> workbook tabs and endpoint diagnostics -> detachable multi-monitor scenes -> session isolation and hibernation -> controlled split views -> optional private Spark registry sync -> optional Android catalog/one-dashboard viewer -> only then consider a signed public Windows product or team workspace.

The durable differentiator is not “websites inside an app.” It is the private operational model around device-specific endpoints, explicit session boundaries, semantic monitor scenes, health evidence, safe hibernation, and dashboards produced by the user's own agents and Obsidian workflows.

## Related

- [[Any App Widget Maker]]
- [[Ambient TV]]
- [[Personal Signal Intelligence OS]]
- [[Finance Signals Dashboard]]
- [[Net Worth Command Center]]
- [[Project Similarity and Reuse Map]]
- [[Project Ideas Index]]
- [[Scope Expansion Checklist]]
