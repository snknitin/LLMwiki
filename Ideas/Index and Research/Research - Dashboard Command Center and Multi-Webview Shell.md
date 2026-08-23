---
type: research-note
status: active
created: 2026-08-23
scope: dashboard-command-center-and-multi-webview-shell
tags:
  - research
  - dashboards
  - desktop-app
  - multi-webview
  - multi-monitor
  - app-container
  - electron
  - local-first
  - self-hosted
---

# Research - Dashboard Command Center and Multi-Webview Shell

This dossier investigates the existing product and open-source landscape around a private Windows desktop “command center” that registers local and remote URL-based applications, presents them as durable tabs rather than ordinary browser tabs, and restores multi-window and multi-monitor arrangements. A later Android viewer may reuse the registry, but it is not a V0 requirement and must not constrain the Windows stack. The dossier distinguishes products that actually host web applications from start pages that merely link to them, identifies the smallest useful alternatives, and extracts the UX and architecture patterns worth reusing.

## 1. Dashboard Command Center

### Executive finding

The idea is feasible, but the generic category already exists. The established names are **multi-service browser**, **web-app container**, **site-specific browser manager**, **workspace browser**, and **multi-webview shell**. Rambox, Wavebox, Franz, Ferdium, WebCatalog, and Station all demonstrate some form of “persistent web apps in a dedicated desktop workspace.” Self-hosted products such as Homarr and Heimdall demonstrate a different category: a home page or dashboard of links and widgets that usually opens the target application rather than becoming its browser runtime.

The proposed project remains meaningfully different if it is kept narrow and personal:

- it is a **dashboard registry and display surface**, not a general replacement browser or messaging aggregator;
- it understands that the same dashboard may have a Windows-local endpoint, a Spark/Tailscale endpoint, and a mobile endpoint;
- it treats nested tab groups, saved multi-window arrangements, monitor orientation, kiosk/full-screen presentation, health state, and quick “open this workspace” scenes as first-class objects;
- it syncs the **registry and layout**, while leaving each dashboard responsible for its own data and authentication;
- it is designed for private agent-generated and Obsidian-backed dashboards rather than a public catalog of SaaS services.

The best personal V0 is Windows-only. First validate the registry and screen-layout workflow with one of two deliberately smaller approaches:

1. **Fastest validation:** install each dashboard as an Edge app, store a small registry, and use PowerToys FancyZones for monitor layouts. This proves whether named workspaces, dedicated browserless windows, hotkeys, and multi-monitor placement improve the daily workflow before building a browser engine.
2. **First real shell:** build a Windows-first Electron application with one active `WebContentsView` per visible panel, durable dashboard records, nested navigation, explicit cookie/session partitions, and window-scene restore. This is justified when a single tabbed surface, split panes, child tabs, consistent error handling, and one-click scenes matter enough that independent Edge windows are no longer adequate.

Do not start by forking a general browser, building a custom synchronization account, reproducing Chrome extensions, or promising identical desktop and mobile behavior. Those are separate product-sized problems.

### The product categories are easy to confuse

| Category | What it owns | Closest examples | Fit for this idea |
|---|---|---|---|
| Multi-service browser / web-app container | Web rendering, cookies, navigation, notifications, app catalog, workspaces | Rambox, Wavebox, Franz, Ferdium, Station | Closest technical precedent; broader than needed |
| Site-specific browser manager | Creates dedicated app-like windows and isolated profiles for websites | WebCatalog, Edge installed apps | Excellent shortcut or fallback |
| Self-hosted application dashboard | Link tiles, widgets, service status, discovery and launch | Homarr, Heimdall | Useful registry/front-door precedent; does not provide the desktop multi-window shell |
| Multi-pane wrapper | Several web apps visible side by side in one native window | Tessera, Dockyard | Closest open-source interaction prototype; maturity and security require review |
| Window layout manager | Places independent native windows in reusable screen zones | PowerToys FancyZones | Solves much of the multi-monitor layout problem without owning web content |
| Ordinary browser workspaces | Tabs, groups, profiles, history and extensions | Edge/Chrome/Firefox/Vivaldi-class browsers | Mature renderer and authentication, but retains browser metaphors and tab clutter |

The key product decision is therefore not “can a web page be shown in a desktop app?” It can. The decision is which layers the Command Center must own and which should remain delegated to the operating system, a browser, Tailscale, and the dashboards themselves.

### Closest commercial precedents

#### Rambox: closest feature benchmark

Rambox is the strongest off-the-shelf comparison for the desired desktop experience. Its official product page supports custom web applications, contexts called Workspaces, multiple signed-in sessions, session persistence, quick search, notifications, a **Tile View** for simultaneous applications, and synchronization of the setup across devices ([Rambox: How it works](https://rambox.app/how-it-works/)).

What to borrow:

- a fixed app rail whose entries outlive ordinary browsing sessions;
- named workspaces rather than a flat tab pile;
- a fast switcher and predictable numeric shortcuts;
- a distinction between an app identity and a signed-in profile/instance;
- tile mode as a temporary view over the same registered apps;
- badges and health indicators attached to the correct app entry;
- sleep/wake policy instead of keeping every remote page fully active.

What not to copy:

- a huge app catalog is unnecessary when the owner registers private URLs;
- unified notifications and extensions add significant browser complexity before the dashboard workflow is proven;
- account-based cloud sync is excessive for a private V0;
- keeping many services perpetually alive can consume substantial memory and background CPU.

Rambox can also be used as a **buy-before-build experiment**: register several Spark and localhost dashboards as custom apps and measure what is still missing. If the only gap is appearance, the new project may not yet justify its own runtime. If endpoint resolution, nested dashboard trees, scene restore, orientation-specific layouts, or local-first configuration are painful, those are validated differentiators.

#### Wavebox: best information architecture precedent

Wavebox has the clearest published hierarchy. It uses Chromium; **Spaces** isolate cookies, **Groups** collect apps and tabs, and permanent **Apps** are enhanced tabs. A group has its own tab strip, while Profiles are separate Wavebox instances. Its official platform page also describes cross-computer profile sync ([Wavebox platform](https://wavebox.io/platform)), and its documentation explains that Spaces isolate or deliberately share cookie jars ([Wavebox Spaces](https://kb.wavebox.io/kb/what-are-profiles-and-how-do-i-create-one-in-wavebox-sandboxing/)).

This suggests a vocabulary for the Command Center:

- **Dashboard** — one durable registered resource, not necessarily one URL;
- **Endpoint** — one device- or network-specific URL for that dashboard;
- **Group** — a nested navigation collection such as Finance, Research, Agents, or System Health;
- **Workspace** — the set of dashboards and groups relevant to one activity;
- **Scene** — the actual window/panel arrangement opened on the connected displays;
- **Session boundary** — which dashboards may share cookies and storage.

Do not collapse these into one tree node. Wavebox’s separation of organization from cookie isolation is especially important. Two dashboards can belong to the same Finance group while requiring separate authentication storage; conversely, several dashboards on the same trusted origin may intentionally share a login.

#### WebCatalog: site-specific browser and isolated-profile precedent

WebCatalog makes websites into dedicated desktop apps and groups them into workspaces. Its official documentation describes each workspace as a dedicated window and each profile as a separate identity with its own login, cookies, and data ([WebCatalog workspaces](https://webcatalog.io/en/solutions/workspaces), [WebCatalog Desktop documentation](https://docs.webcatalog.io/en/collections/6321386-webcatalog-desktop)).

This is the cleanest precedent for two fallback capabilities:

- “Open as dedicated window” when a dashboard does not behave correctly inside the main shell;
- “Duplicate with isolated session” when the same service needs two accounts.

It also reinforces a security rule: synchronize the dashboard definition and layout, not raw cookies. A second device can recreate the app record, but the user should authenticate there through the dashboard’s normal flow.

#### Franz and Ferdium: recipes, workspaces, and self-hosted configuration

Franz currently presents each added service as an isolated container, supports custom websites, and aggregates notification state ([Franz official site](https://meetfranz.com/en)). Ferdium is its community-driven open-source descendant. The Ferdium repository describes the desktop app as combining favorite apps into one application and shows Workspaces and a service store ([Ferdium application repository](https://github.com/ferdium/ferdium-app)). Its companion server supports services, workspaces, import/export, custom service recipes, and self-hosting ([Ferdium server repository](https://github.com/ferdium/ferdium-server)).

Ferdium is valuable as a code-reading reference for:

- separating a service definition or “recipe” from a user-created instance;
- synchronizing service and workspace metadata through a small server;
- allowing a completely local client mode and an optional self-hosted control plane;
- user-provided styling for the surrounding shell;
- migration and import/export as explicit features.

It is less suitable as a direct product base. Its inherited architecture is optimized for messaging/service recipes, notification integrations, and a broad catalog. Adapting it to multi-monitor dashboard scenes and device-specific endpoints could become harder than implementing a narrower registry and shell.

#### Station: useful historical open-source architecture, not a default dependency

Station’s open-source Electron repository remains a useful implementation reference for a web-app dock, persistent service records, inactive-tab handling, and a local data store. The repository exposes an environment switch that prevents webviews from loading, an inactivity check, and a SQLite-backed application database ([Station desktop repository](https://github.com/getstation/desktop-app)). Its archived documentation describes a dock and app store limited to web applications ([Station application FAQ](https://github.com/getstation/desktop-app/wiki/FAQ-%7C-%F0%9F%93%B1-Applications-%26-extensions)).

Treat it as an architecture study, not a library choice. Before adopting any code, verify its present maintenance, Electron version, dependency health, security posture, and whether its license and internal abstractions still fit. The lesson is that a web-app container accumulates browser-maintenance obligations even when the visible product looks small.

#### Sidekick and Stack-style browsers

Sidekick, Stack, Arc-style Spaces, and similar productivity browsers helped popularize the visual language of persistent sidebar apps, accounts, and workspaces. However, current first-party evidence and reusable open-source foundations are much clearer for Rambox, Wavebox, Ferdium, WebCatalog, and Station. They should be treated as visual references encountered during design review, not as the foundation of the technical plan until their current product status and terms are checked directly.

### Self-hosted dashboards are partial substitutes, not the same product

#### Homarr

Homarr is a mature self-hosted dashboard with drag-and-drop boards, application records, integrations, user/group permissions, OIDC/LDAP, live widget updates, search, and a large icon picker. The official repository describes it as Apache-2.0 and compatible with common self-hosted hardware ([Homarr repository](https://github.com/homarr-labs/homarr)); its documentation distinguishes an app URL used to open the application from an integration that powers widgets ([Homarr apps](https://homarr.dev/docs/management/apps/), [Homarr integrations](https://homarr.dev/docs/management/integrations/)).

Homarr can replace the **registry home page** of the Command Center, especially on mobile. It does not replace:

- native multi-window control;
- durable app-like tabs without browser chrome;
- renderer-level session isolation;
- placement and restoration across displays;
- switching one dashboard between Spark, workstation, and mobile endpoints;
- a local desktop keyboard/focus model.

Its strongest reusable idea is the separation between an **app record** and an **integration**. The Command Center should likewise keep “where to open this dashboard” separate from optional health checks, icon discovery, metadata, screenshots, or status adapters.

#### Heimdall

Heimdall is an application dashboard and launcher: it stores tiles for arbitrary links, can enhance known apps with live API data, and can search tiles. It can run through PHP or Docker and supports offline hosting of its app list ([Heimdall repository](https://github.com/linuxserver/Heimdall)).

Heimdall is the simplest self-hosted alternative if the actual need is “one attractive private page from which I can find every dashboard.” It is not a tabbed shell and does not own the destination page after launch. That limitation may be a benefit: all authentication, downloads, popups, WebAuthn, and browser compatibility stay in the normal browser.

#### Strategic implication

If a later Android viewer becomes useful, a Homarr/Heimdall-style responsive registry may be enough. The Windows desktop shell can consume the same registry without forcing a phone app to reproduce multi-window desktop behavior. This reduces the future cross-platform problem from “one identical app everywhere” to “one shared catalog with device-appropriate viewers.”

### Open-source prototypes closest to the interaction model

#### Tessera

Tessera describes itself as an Electron multi-pane wrapper for arbitrary web apps, with vertical/horizontal/grid splits, per-pane address bars, domain locking, OAuth-domain routing, external-link rules, profiles, notifications, JSON import/export, and customizable shortcuts ([Tessera repository](https://github.com/nirkheashish-tech/tessera)). It is remarkably close to the requested split-view interaction.

Its repository also explicitly lists missing features such as tab mode, session restore, drag-and-drop pane reordering, auto-update, and Windows release work. This makes it a useful disposable prototype and code-reading reference, not a battle-tested base. The project is small enough that every security-sensitive decision—navigation handling, script injection, preload exposure, session partitioning, and updates—must be independently reviewed.

Useful pieces to prototype from its design:

- a pane tree generated by horizontal and vertical split operations;
- focus-next/focus-previous shortcuts;
- per-pane domain allowlists for login flows;
- a summon/hide global hotkey;
- declarative JSON import/export;
- a distinction between profile configuration and current pane state.

Avoid its custom JavaScript injection feature in the first Command Center release. Remote-page injection greatly enlarges the attack and maintenance surface and can silently break dashboards after upstream updates.

#### Dockyard

Dockyard is another small Electron workspace prototype. Its published concepts are directly relevant: profiles, workspaces, custom URLs, duplicated instances, workspace-shared or isolated persistent partitions, configurable docks on any edge, split layouts, detachable windows, per-app zoom, auto-hibernation, performance inspection, and local JSON storage ([Dockyard repository](https://github.com/MayR-Labs/dockyard-electron)).

The two highest-value ideas are:

1. **session policy is explicit per instance** rather than an accidental global cookie jar;
2. **hibernation is part of the product model**, not an afterthought added when 20 dashboards overwhelm memory.

Its documentation still refers to Electron’s older `BrowserView`; a new build should use current Electron primitives and not copy the implementation mechanically. Like Tessera, it is evidence that the UX is feasible, not evidence that a small repository is production-ready.

### The 80-percent alternatives

#### Edge “Install this site as an app”

Microsoft Edge can install any website as an app, not only sites that publish a PWA manifest. Installed sites open in separate app windows, appear under `edge://apps`, can be pinned, and can start automatically ([Microsoft Support: install websites as apps](https://support.microsoft.com/en-us/edge/install-manage-or-uninstall-apps-in-microsoft-edge)).

For a personal Windows deployment, this is the fastest way to obtain:

- no ordinary browser tab strip;
- mature Chromium authentication and permissions;
- independent taskbar entries;
- normal browser updates and security fixes;
- easy per-dashboard troubleshooting in a real browser runtime.

It does not produce one nested tab tree, one synchronized dashboard catalog, or one saved multi-window scene. A tiny launcher can fill much of that gap without embedding any web content: store dashboard records, launch installed apps or URLs, and remember which scene should open.

#### PowerToys FancyZones

FancyZones provides per-monitor grid or canvas layouts, orientation-specific defaults, hotkeys for quickly applying custom layouts, and repositioning when resolution changes. Microsoft documents vertical/horizontal orientation defaults, multi-monitor selection, quick-layout shortcuts, and persisted layout files ([PowerToys FancyZones](https://learn.microsoft.com/en-us/windows/powertoys/fancyzones)).

This directly replaces the most expensive early form of custom multi-monitor layout management. The practical experiment is:

1. install five dashboards as Edge apps;
2. create named FancyZones layouts for the desk’s normal monitor arrangements;
3. create a launcher scene that opens the selected dashboard set;
4. use the workflow for two weeks;
5. record which actions still require manual dragging or tab hunting.

If this works, keep it. The Command Center can remain a registry/launcher. If it fails because layouts must move as one coherent workspace, panes must split inside a single window, hidden dashboards must hibernate, or scene restore must survive changing display topology, then the custom desktop shell has a specific validated job.

#### Homarr or Heimdall as the mobile companion

A responsive self-hosted catalog behind the private network can solve mobile discovery immediately. The phone opens one registry, searches dashboards, and launches the selected page in its normal web runtime. This will often be better than placing multiple hidden mobile webviews in one app, which is expensive and awkward on small screens.

#### A normal browser profile with pinned tabs

This is the zero-build baseline. Create one browser profile called Dashboards, pin the core tabs, use tab groups, and let the browser sync them. The custom product must beat this baseline on at least one measurable dimension: time to the right dashboard, reliable scene restore, screen utilization, endpoint choice, authentication isolation, or reduced memory while idle.

### What existing products teach about the data model

The dominant mistake would be storing a tab as `{title, url}`. The precedents show at least six independent concepts:

```yaml
dashboard:
  id: finance-signals
  title: Finance Signals
  icon: local-asset-or-favicon
  group_ids: [money, morning-review]
  endpoints:
    windows_local: http://127.0.0.1:4312
    windows_tailnet: https://firstspark.example.ts.net/finance
    mobile_tailnet: https://firstspark.example.ts.net/finance
  health_probe:
    path: /health
    expected_status: 200
  session_policy: share:spark-personal-dashboards
  navigation_policy:
    allowed_origins: [https://firstspark.example.ts.net]
    external_link_action: system-browser

workspace:
  id: money-morning
  navigation_tree: [finance-signals, net-worth, subscriptions]
  default_scene_id: desk-three-monitor

scene:
  id: desk-three-monitor
  windows:
    - display_role: portrait-right
      bounds_mode: full-work-area
      active_dashboard: finance-signals
    - display_role: center-primary
      split_tree: {direction: horizontal, children: [net-worth, subscriptions]}
```

The registry should store a stable dashboard identity and resolve an endpoint at open time. `localhost` on a phone is the phone, not the workstation or Spark. A single copied URL therefore cannot meet the multi-device promise.

Cookie sharing is also not the same as grouping. Borrow Wavebox’s and WebCatalog’s conceptual separation: membership controls navigation; a session policy controls whether persistent browser storage is shared. A safe default is one persistent partition per origin or explicit trust group, with isolated partitions available for duplicate accounts.

### UX patterns worth reusing

#### Navigation

- Allow left, right, top, or bottom navigation, but pick one default. Dockyard’s any-edge dock and Wavebox’s hierarchical sidebar prove the flexibility; configurable direction does not require four unrelated designs.
- Use Excel-like sheet tabs as a **view** over the current group, not as the only hierarchy. A collapsible group/sidebar can reveal the whole collection while bottom tabs make the active group feel like a workbook.
- Provide search and a command palette before elaborate drag-and-drop nesting. Large registries are faster to navigate by name, alias, or tag.
- Distinguish “pin,” “recent,” “favorite,” “running,” and “registered.” They are different states.

#### Windows and scenes

- Let a dashboard detach into a new window and later reattach.
- Save a scene by semantic display role and relative layout, not only raw pixel coordinates.
- When a monitor disappears, collect off-screen windows onto the primary display instead of restoring them invisibly.
- Support an orientation-aware scene variant for portrait displays.
- Allow one active dashboard per full-screen window first; add nested split trees only after the multi-window model is stable.

#### Loading and failure states

- Show “service unreachable,” “authentication required,” “certificate problem,” and “navigation blocked” as different errors.
- Give every dashboard reload, hard reload, zoom, copy URL, open in system browser, and reset-session actions.
- Capture a thumbnail only after a successful load and use it while a suspended dashboard is cold.
- Expose last successful health check and source device so a dead Spark service is not mistaken for an app bug.

#### Resource control

- Keep visible panes live.
- Throttle hidden panes, then suspend or destroy long-idle views while retaining navigation/session state.
- Let the user mark a dashboard “always live” only when it genuinely needs timers, streams, or notifications.
- Set a live-view budget per window and show which dashboard exceeds it.

#### Persistent registration, service state, and renderer state

The user's clarification exposes three lifecycles that existing products often blur:

1. **Registered:** the dashboard identity, URL variants, login partition, groups, desired state, and schedule survive restarts.
2. **Service or agent runtime:** a Spark service, Windows process, n8n workflow, cron job, or agent schedule runs independently of the display page.
3. **Visual renderer:** Chromium is created only when the dashboard must be visible, warm, or truly always-live.

“Persistent” should mean the first lifecycle is durable, not that every registered URL keeps a renderer in RAM. Model at least disabled, paused, on-demand, warm, always-live, and scheduled policies. Paused destroys the visual renderer and suppresses Command Center polling/pre-warm; it does not silently stop an independent backend. Scheduled can pre-warm or open a view near review time while the actual agent job runs in its own scheduler.

For later agent controls and feedback, prefer a dashboard-owned capability manifest that declares health, last/next job run, safe named actions, and accepted feedback types. The shell can display or invoke that narrow contract with confirmation. It should not inject automation into the page DOM or keep the page alive merely so a cron job can run.

### Architecture implications from the prior art

Electron is the pragmatic desktop V0 because the problem is explicitly “several Chromium pages in native windows.” Current Electron exposes `WebContentsView` for independently sized web contents and shows multiple views inside a `BaseWindow` ([Electron `WebContentsView`](https://www.electronjs.org/docs/latest/api/web-contents-view)). Persistent or in-memory sessions can be created from named partitions ([Electron `session`](https://www.electronjs.org/docs/latest/api/session)), and the `screen` module exposes all displays and DPI-independent geometry for external-display placement ([Electron `screen`](https://www.electronjs.org/docs/latest/api/screen/)).

That convenience creates a serious obligation. Electron warns that arbitrary remote content is a severe security risk and requires no Node integration for remote pages, context isolation, sandboxing, explicit permission handling, intact web security, navigation restrictions, controlled new-window behavior, validated IPC senders, and current Electron releases ([Electron security checklist](https://www.electronjs.org/docs/latest/tutorial/security)). A dashboard shell should load only registered private origins and open unknown destinations in the system browser. It should not present itself as a safe general-purpose browser.

The strongest high-level separation is:

- **local shell UI** owns navigation, settings, window layout, endpoint resolution, health state, and scene commands;
- **remote dashboard webviews** have no Node access and receive no general privileged bridge;
- **registry sync** transfers declarative records and revisions, not cookies, passwords, arbitrary scripts, or dashboard data;
- **dashboard backends** own their own APIs, authentication, writes, and Obsidian interaction;
- **system browser fallback** handles unsupported sign-in flows, downloads, WebAuthn, or untrusted navigation.

Tauri v2 and WinUI 3/WebView2 remain credible alternatives, but neither should be selected to anticipate an Android app. Tauri can create multiple remote webviews, yet platform webview/session differences and lower-level child-view orchestration add risk to this exact V0 ([Tauri WebviewWindow](https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/)). WinUI 3 plus WebView2 is the strongest native Windows option and supports app-specific persistent or isolated profiles, but it requires more Windows App SDK/C# host code for a multi-view shell ([Microsoft WebView2 for WinUI 3](https://learn.microsoft.com/en-us/windows/apps/develop/ui/controls/webview2)). Use Electron first; re-run a measured Tauri or WebView2 spike only if packaged size, RAM after hibernation, or native Windows integration becomes the dominant constraint.

### Windows, localhost, Spark, and Tailscale

`localhost` is device-relative: a loopback URL opened by Command Center targets the Windows PC, not FirstSpark. Store it as a device-bound endpoint. A Spark-hosted dashboard should use a full private HTTPS name such as `https://firstspark.<tailnet>.ts.net/...`, preferably through [Tailscale Serve](https://tailscale.com/docs/features/tailscale-serve). Serve reverse-proxies loopback services, keeps them within the tailnet, and can attach authenticated identity headers while removing spoofed incoming copies. The backend must remain loopback-only if it trusts those headers.

Prefer the stable `.ts.net` origin even when using the main workstation where practical. Opening one logical dashboard through both localhost and tailnet URLs creates separate cookies, local storage, service workers, and permission decisions. [MagicDNS](https://tailscale.com/docs/features/magicdns) supplies stable names, and Tailscale's current [Grants](https://tailscale.com/docs/features/access-control/grants) are the recommended least-privilege control model. Use Serve, not public Funnel.

Tailscale HTTPS certificate names are written to Certificate Transparency logs. Choose non-sensitive node names before enabling certificates; the service remains private, but its fully qualified name is public metadata ([Tailscale HTTPS](https://tailscale.com/docs/how-to/set-up-https-certificates)).

Synchronize only registry/group/semantic-scene records. Keep cookies, bearer tokens, exact window coordinates, downloads, and permission decisions on each Windows installation. If a Spark registry API is later justified, use ETags and `If-Match`, reject conflicts with HTTP 412, retain a last-known-good copy, and write through a lock plus staged atomic rename.

### What should be tested before adopting or forking anything

For each candidate—Rambox, Ferdium, Tessera, Dockyard, or a custom shell—run the same ten-dashboard fixture:

1. two plain local dashboards;
2. two Spark/Tailscale dashboards;
3. one app with WebSocket/SSE updates;
4. one dashboard requiring sign-in and popup redirects;
5. one dashboard with file download;
6. one dashboard that opens external links;
7. one duplicate account requiring an isolated cookie store;
8. one intentionally unavailable endpoint.

Measure:

- cold and warm time to usable content;
- idle and active memory per dashboard;
- background CPU after ten minutes;
- login persistence across restart;
- whether OAuth popups return to the correct app;
- notification and permission behavior;
- crash containment when one renderer fails;
- window restoration after unplugging a monitor;
- behavior at mixed DPI and portrait orientation;
- full keyboard-only navigation;
- fallback to the browser without losing the source context.

Do not infer maturity from a polished README. Check release cadence, Electron/Chromium age, dependency audit, signing and update path, open authentication bugs, Windows support, crash recovery, and security documentation.

### Drawbacks and failure modes exposed by the market

- **This can become a browser project.** Downloads, popups, permissions, credential managers, client certificates, extensions, WebAuthn, printing, find-in-page, DevTools, media capture, and protocol handlers appear one edge case at a time.
- **Authentication flows detect embedded runtimes.** A page may reject an older Chromium user agent, send links to a native app, or require a popup/opener chain. Station’s public issue history illustrates how a stale Electron runtime can break services ([Station Slack login issue](https://github.com/getstation/desktop-app/issues/45)).
- **Every live webview costs memory.** A tab strip that keeps twenty dashboards running may use more resources than independent PWAs. Lazy creation and hibernation are core requirements.
- **Cloud sync is not session sync.** Transferring raw cookie stores is fragile and risky. Re-authentication per device should be expected.
- **A launcher may already be sufficient.** Homarr, Heimdall, Edge installed apps, and FancyZones can deliver most of the benefit at effectively zero engineering cost.
- **Remote content is privileged-adjacent.** A shell bug that exposes IPC or local file access turns a normal dashboard compromise into a workstation compromise.
- **Arbitrary script/CSS injection creates permanent maintenance.** It can break logins, violate page assumptions, and make security review nearly impossible.
- **Window geometry is unstable.** Monitor IDs, position, orientation, resolution, and DPI change. Raw coordinates are not durable scene definitions.
- **A phone is not a small desktop.** Multi-window monitor scenes and always-live panels do not translate. The shared asset is the registry; the renderer and navigation should be device-specific.
- **Naming collisions are likely.** “Command center,” “workspace,” “dashboard,” “group,” “space,” “profile,” “tab,” and “scene” are overloaded across competitors. Define them once in the product spec.

### Recommended build-or-buy sequence

#### Experiment 0 — no custom renderer

- Register the current dashboard set in a Markdown/YAML or JSON file.
- Install the five most important dashboards as Edge apps.
- Create two or three FancyZones layouts.
- Build only a launcher/search palette that opens a named scene.
- Track launches, manual rearrangements, failures, and time to the correct dashboard for two weeks.

This experiment identifies whether the real pain is discovery, browser chrome, login separation, or window choreography.

#### Experiment 1 — evaluate an existing container

Configure Rambox or Ferdium with the same dashboards. Test custom URLs, separate accounts, restart restore, popups, and memory. This establishes a feature and reliability baseline for the custom build.

#### Personal V0 — dashboard-specific Electron shell

Build only:

- registry CRUD and endpoint resolution;
- group tree plus horizontal or vertical navigation;
- one active live view per window;
- detach/reattach and multi-window scene restore;
- explicit session partitions;
- health/error states;
- browser fallback;
- export/import of non-secret configuration.

Delay split panes until multi-window restore is trustworthy. Delay mobile until the registry proves stable.

#### V1 — split scenes and private registry sync

Add split trees, scene variants per display topology, hibernation budgets, thumbnails, optimistic revision sync through a small private endpoint, and a read-only mobile catalog/viewer.

#### Product scope

Only after sustained personal use should the project consider team accounts, hosted sync, extension support, public app catalogs, credential integrations, remote administration, notification aggregation, or arbitrary websites. At that point re-evaluate release signing, auto-update security, licenses, privacy, accessibility, mobile-store policies, and public-service terms. These future checks should not change the local-first stack selected for the private V0.

### Clever hacks and simpler alternatives

1. **Use the system browser as an escape hatch, not as a failure.** Unsupported login, download, or WebAuthn flows can open outside and return later.
2. **Resolve endpoints by device.** One logical dashboard can select localhost on the workstation and a private HTTPS tailnet URL on mobile.
3. **Make scenes declarative.** A scene can specify `primary`, `portrait-right`, or `largest-available` display roles instead of fragile monitor serials alone.
4. **Show screenshot thumbnails for suspended tabs.** The workspace still feels visually persistent while hidden Chromium processes are destroyed.
5. **Reuse FancyZones during development.** Let the OS manage independent windows until the custom scene system is demonstrably better.
6. **Borrow Ferdium’s recipe split without its catalog.** A tiny optional adapter can provide icon, health path, allowed origins, and default zoom for a class of dashboards.
7. **Keep a browser-profile baseline.** Regression-test against ordinary Edge: if the shell breaks a dashboard that works there, fallback immediately and record the incompatibility.
8. **Ship one navigation direction.** Use CSS to flip the same hierarchy between left rail and bottom sheets later; do not implement independent UI systems.
9. **Use a live-view budget.** For example, only visible views plus two pinned background dashboards remain live; everything else hibernates.
10. **Let the registry remain human-readable.** A versioned YAML/JSON export makes recovery, agent edits, and migration easier than an opaque cloud account.
11. **Do not inject agents into dashboard pages.** If agents need to act, call the dashboard’s backend/API through its own service boundary; the Command Center remains a display and orchestration shell.
12. **Simplest useful alternative:** Homarr as the private catalog, Edge apps as chrome-free viewers, and FancyZones as the scene manager. Build a native shell only after this combination’s limits are recorded.

### Source ledger

| Source | Owner / type | What it establishes |
|---|---|---|
| [Rambox: How it works](https://rambox.app/how-it-works/) | Rambox, official product page | Custom web apps, workspaces, sessions, tile view, sync, quick search and notifications |
| [Wavebox platform](https://wavebox.io/platform) | Wavebox, official product page | Chromium base; Spaces, Groups, Apps, Profiles and profile sync |
| [Wavebox Spaces](https://kb.wavebox.io/kb/what-are-profiles-and-how-do-i-create-one-in-wavebox-sandboxing/) | Wavebox, official documentation | Cookie isolation and sharing semantics |
| [WebCatalog workspaces](https://webcatalog.io/en/solutions/workspaces) | WebCatalog, official product page | Dedicated app environments and per-account isolated profiles |
| [Franz official site](https://meetfranz.com/en) | Franz, official product page | Custom sites, isolated services, workspaces and notification aggregation |
| [Ferdium application](https://github.com/ferdium/ferdium-app) | Ferdium, official source | Open-source service container, workspaces and custom styling |
| [Ferdium server](https://github.com/ferdium/ferdium-server) | Ferdium, official source | Self-hosted services/workspaces, custom recipes, import and export |
| [Station desktop](https://github.com/getstation/desktop-app) | Station, official source | Electron web-app container architecture and persistence references |
| [Homarr](https://github.com/homarr-labs/homarr) | Homarr, official source | Self-hosted boards, app records, integrations, auth and live widgets |
| [Heimdall](https://github.com/linuxserver/Heimdall) | LinuxServer/Heimdall, official source | Link launcher, enhanced app tiles, search and offline self-hosting |
| [Tessera](https://github.com/nirkheashish-tech/tessera) | Open-source prototype | Multi-pane wrapper, auth-domain routing, profiles and declared missing features |
| [Dockyard](https://github.com/MayR-Labs/dockyard-electron) | Open-source prototype | Session partitions, hibernation, split layouts and detachable windows |
| [Edge installed apps](https://support.microsoft.com/en-us/edge/install-manage-or-uninstall-apps-in-microsoft-edge) | Microsoft, official support | Any site can be installed and launched as a separate app window |
| [PowerToys FancyZones](https://learn.microsoft.com/en-us/windows/powertoys/fancyzones) | Microsoft, official documentation | Per-monitor layouts, orientation defaults, quick switching and restore behavior |
| [Electron `WebContentsView`](https://www.electronjs.org/docs/latest/api/web-contents-view) | Electron, official API | Multiple independently bounded web contents in native windows |
| [Electron `session`](https://www.electronjs.org/docs/latest/api/session) | Electron, official API | Persistent and in-memory named browser-session partitions |
| [Electron `screen`](https://www.electronjs.org/docs/latest/api/screen/) | Electron, official API | Display enumeration, external display placement and DPI-independent geometry |
| [Electron security](https://www.electronjs.org/docs/latest/tutorial/security) | Electron, official guidance | Required isolation, permission, navigation, IPC and update protections for remote content |
| [Tauri WebviewWindow](https://v2.tauri.app/reference/javascript/api/namespacewebviewwindow/) | Tauri, official API | Multiple remote webviews/windows as an alternative stack |
| [Microsoft WebView2 for WinUI 3](https://learn.microsoft.com/en-us/windows/apps/develop/ui/controls/webview2) | Microsoft, official documentation | Native Windows web embedding, profile isolation and external OAuth boundary |
| [Tailscale Serve](https://tailscale.com/docs/features/tailscale-serve) | Tailscale, official documentation | Private HTTPS reverse proxy, identity headers and loopback-backend rule |
| [Tailscale Grants](https://tailscale.com/docs/features/access-control/grants) | Tailscale, official documentation | Recommended least-privilege tailnet access model |
| [Tailscale HTTPS](https://tailscale.com/docs/how-to/set-up-https-certificates) | Tailscale, official documentation | Full `.ts.net` TLS names and Certificate Transparency disclosure |

### Research conclusion

There is no technical novelty in “put URLs in persistent desktop tabs,” and trying to compete with full browsers on that premise would be wasteful. The compelling project is a **private dashboard operations shell** that knows about endpoint variants, dashboard health, nested task-oriented groups, semantic display scenes, resource budgets, and an Obsidian/agent-generated dashboard ecosystem.

The market research also supplies a hard stop rule: if Edge apps + FancyZones + a responsive Homarr/Heimdall registry satisfy the workflow, keep that solution and invest in the dashboards themselves. Build the custom Electron shell only where it can demonstrate repeatable advantages in scene restore, navigation, endpoint resolution, split views, health visibility, or resource control.
