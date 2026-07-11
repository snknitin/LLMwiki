---
title: "X"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2026-05-01"
tweet_url: "https://x.com/TheAhmadOsman/status/2050062045471740303"
tweet_type: "original"
likes: 608
retweets: 49
replies: 14
bookmarks: 1540
views: 256900
has_media: false
article_id: "2050058966072524800"
tags: ["twitter-bookmark", "mcp", "agents"]
---

# X

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2026-05-01 · 👍 608 · 💬 14 · 🔖 1540 · 👁 256900

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/2050062045471740303)

## Article Content

Someone asked me recently if [I’d duplicated my local homelab into the cloud](https://x.com/HafeezHaqq/status/2049886136060043398)

.

Not really. The more accurate answer is that I’ve built enough cloud-like infrastructure around the homelab that it now behaves like a small private cloud. Same local machines, same Proxmox nodes, same hardware, but the operating model is completely different.

Instead of a pile of dashboards, random ports, one-off VMs, and manual SSH sessions, the lab is organized around access layers, gateways, routing policy, searchable state, and compute lanes. That’s the difference between “I run some services at home” and “I have a private control plane for my own infrastructure.” Right now that control plane spans more than several dozen active Proxmox guests, LXC containers plus a handful of VMs, with workstations and dedicated LAN model appliances joining the fabric where they make sense.

This article explains the general shape of that system without publishing my real hostnames, IPs, service names, container IDs, domains, or secrets.

### How This Article Builds

This starts with the high-level idea, then walks downward through each layer until the whole private-cloud operating model is visible.

1. High-level claim: why this is still local hardware, but no longer feels like a pile of one-off homelab services.
2. Redaction model: what is real, what is anonymized, and what stays private.
3. Big picture: the full platform shape from offsite clients to VPN, DNS, service gateway, agents, state, compute, and backups.
4. Physical substrate: the Proxmox, container, VM, storage, and rollback foundation.
5. Access path: WireGuard, split/full tunnel modes, SNAT, DNS/DHCP, and firewall/ACL policy.
6. Application edge: the gateway, public/private routes, stable front doors, and human-facing apps.
7. Agent platform: model routing, generated client profiles, skill workflows, and web evidence tooling.
8. State and recovery: traces, searchable memory, app backups, parity checks, health checks, and restore drills.
9. Compute fabric: CPU lanes, GPU lanes, LAN model appliances, work placement, artifacts, and logs.
10. Synthesis: how the paths connect, why this is more than a reverse proxy, and the lesson worth copying.

### The Redaction Model

This is a public article, and it’s intentionally anonymized. The names here are role names, not my real inventory names. Product names are included only where they explain the pattern; inventory labels, addresses, domains, account names, and route names are not.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059304347254784The architecture is true to the system. The identifiers are not.

### The Big Picture

The [diagram I posted](https://x.com/TheAhmadOsman/status/2049841755789619554)

 was meant to show the topology, not a single product.

At the top are offsite clients: laptop, phone, tablet. They enter through a WireGuard tunnel that lands on a VPN concentrator. From there traffic passes through firewall/NAT policy, private DNS/DHCP, and then into an internal service gateway.

Below that gateway are the useful planes:

- an agent and automation plane
- human-facing app surfaces
- a searchable state plane
- a compute fabric
- supporting web/evidence tools
- storage, backups, health checks, and restore workflows

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059359166869504That last line is the whole point.

The laptop isn’t the whole system. The phone isn’t the whole system. The browser UI isn’t the whole system. They’re clients of a private platform.

### The Physical Layer: Proxmox As The Substrate

At the foundation it’s still a normal homelab: local hardware, virtualization, containers, storage, and a LAN. In my case the Proxmox box is a workstation-class node with a couple dozen logical CPU threads, roughly 100 GiB of RAM, a few TiB of LVM-thin guest storage, and a separate pool of half a dozen spinning-rust drives merged with MergerFS and covered by SnapRAID parity. Bulk data lives on the pool; guest root disks live on LVM-thin. NFS exports make the bulk storage available to other LAN machines that need it.

I use Proxmox as the main substrate because it gives me clean operational boundaries:

- lightweight containers for narrow services
- VMs for heavier workloads or stronger isolation
- snapshots before risky changes
- direct console access when networking is broken
- storage attachment for stateful services
- a place to separate failure domains

So my answer to “[should I ditch Proxmox?](https://x.com/HafeezHaqq/status/2049886136060043398)

” is no.

Proxmox isn’t the cloud by itself; it’s the substrate. The cloud-like part is what sits above it: names, routes, gateways, tokens, generated configs, health checks, traces, backups, and job placement.

You can build this style of system on other substrates too. The important thing is that the substrate stays boring. It should run the workloads and give you rollback points. It shouldn’t be the only layer of organization.

### The Network Entry Point: WireGuard

The first real control point is the VPN edge.

When I’m away from home, I don’t want every internal tool exposed to the public internet. My laptop, phone, and tablet connect to a WireGuard endpoint that lands on a small VPN concentrator inside the homelab.

The concentrator owns peer identity, VPN address assignment, split-tunnel and full-tunnel profiles, the route between VPN clients and the LAN, and NAT behavior for traffic crossing that boundary. In my setup it’s an LXC container running WireGuard with a small dashboard for managing peers, not a heavyweight VPN appliance.

The public endpoint for remote access is just the door. The useful system starts after the handshake succeeds.

There are two main client modes, and I provision both configs per device. Then I pick which one to activate depending on where I am.

Split Tunnel vs Full Tunnel

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059416993738752In the real setup I also care about IPv4 and IPv6 behavior. The tunnel itself runs dual-stack internally: each peer gets both an IPv4 address and an IPv6 ULA address. But the public endpoint that devices connect to is kept IPv4-only by design, with client tooling that pins the A record if DNS drifts, because I’ve seen mobile carriers block WireGuard UDP over IPv6.

### Why SNAT Matters

Because I want to maintain the same IP Address / Identity while on VPN or at home.

SNAT means Source Network Address Translation.

The practical problem is simple: a VPN client has an address from the VPN network, while most LAN services expect traffic from the LAN. You could teach every LAN host a route back to every VPN subnet. That works, but it spreads VPN awareness everywhere.

Instead, the VPN edge translates the source address when traffic crosses from the VPN into the LAN. In my setup this goes a step further than simple MASQUERADE: each VPN peer gets mapped to its own stable LAN-side identity instead of a shared edge address. That way the LAN can still tell which physical device made the request, even through the tunnel, which helps logging and per-device policy without teaching every LAN host a route back to the VPN subnet.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059454549524480That last point matters. SNAT isn’t a security model by itself. WireGuard handles encryption. Peer keys handle tunnel identity. Firewall rules and ACLs handle policy. DNS handles names. SNAT just solves the address translation problem so your devices identities are preserved locally and on VPN.

### Private DNS And DHCP: The Lab Needs Names

Once clients can enter the network, they need stable names.

This is where private DNS and DHCP become more important than people expect. Without them, every dashboard turns into “which IP was that again?” Every script gets a hard-coded address. Every migration becomes annoying. I run Pi-hole as the LAN DNS/DHCP control point. Ad blocking is a bonus; the real value is that there is one place where internal services get stable names.

In my setup, internal names represent roles:

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059505304772608The useful pattern is that clients depend on role names, not machine trivia. If a backend moves from one container to another, the name can stay stable. If a service gets rebuilt, clients shouldn’t need to care. If a health check runs, it targets the role.

Private DNS also ties the VPN back into the rest of the system. A remote phone or laptop on the tunnel can resolve the same private names the LAN uses. That’s what makes remote access feel native instead of bolted on.

### Firewall And ACL Policy

The firewall layer decides what the VPN clients, LAN clients, service gateways, and internal tools are allowed to reach.

In my setup, Proxmox-level firewalling is not the primary isolation layer. Most access control is enforced by the service gateway, the agent router’s token boundary, and the fact that most services simply don’t have public routes. The network boundary is real, but policy lives at the application and routing layers more than at the packet filter.

I don’t want every internal service to be equally reachable from every place. Some things are public-facing web apps behind the CDN. Some are LAN-only dashboards. Some are only for automation. Some are loopback-only behind a proxy. Some should accept traffic only from the model router or the evidence gateway.

That turns the network into role-based paths:

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059545956032513The important part is that the boundaries are explicit. A service being on the LAN doesn’t automatically mean it should be a public API.

### The Internal Service Gateway

After access, DNS, and firewalling, the next big piece is the internal service gateway.

Think of it as the homelab’s application edge. Some traffic is private-only. Some traffic is public. Some public traffic arrives through an upstream CDN or DNS proxy. Some traffic comes directly from the LAN. The gateway normalizes those paths and forwards to the correct backend. In my case this is Caddy running on its own VM, handling TLS termination, DNS-validated certificates through an upstream DNS provider, and the public/private route split.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059579892060160The backend can move. The container can restart. The VM can be rebuilt. The client still speaks to the same front door.

For public-facing services, I also care about real client IP handling. If a request comes through an upstream proxy, the gateway should trust the right header only when it came from the right place, strip spoofed forwarded headers, and rebuild what the upstream app needs. That keeps logs and rate limits useful without letting random clients forge their identity.

### Human Apps: Dashboards, Chat, Search, And Workspaces

Above the gateway are the things I actually use:

- a homepage dashboard with system metrics
- a chat UI backed by an open-source frontend
- a dedicated RAG-style web interface for document search and retrieval
- an AI workspace UI with session management, provider switching, and skills
- operational status pages and admin tools

The important detail is that these aren’t all allowed to talk directly to everything.

For example, a human-facing RAG or chat UI shouldn’t need raw access to every model provider credential, browser automation port, embedding worker, reranker, database, and trace store. It should call narrower internal routes:

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059621793239040That makes the UI a client of the platform instead of a giant trusted everything-box.

This boundary isn’t just aspirational; I maintain an explicit cross-service standard that defines what each container in the agent plane is allowed to reach. The RAG UI must route model traffic through the router, document search through the router’s RAG endpoints, and web search through the search backend. It must not have direct access to the vector database, the embedding workers, the reranker, the browser automation ports, or the raw evidence cache. The chat UI, the workspace UI, and the skill dashboard each have their own allowlists. If a service needs a new internal route, it goes through a boundary review, not a quick firewall exception.

### The Agent And Automation Plane

The agent plane is the part that surprised people most.

I run a lot of AI and automation tooling, but I don’t want each tool to carry a different hand-written provider configuration. That becomes impossible to audit once you have terminal agents, editor integrations, web UIs, local model runners, hosted provider APIs, and compatibility proxies.

So the lab has an internal model routing layer and generated client profiles.

The routing layer is actually two pieces working together: a read-only settings registry that publishes generated profiles, model catalogs, and route metadata without exposing any secrets, and an authenticated router that validates machine tokens before forwarding requests to the selected backend. The registry tells clients what’s available. The router controls who’s allowed through. The registry is backed by a structured catalog with a validation pipeline and a renderer that materializes profile files for each agent client; so when a provider changes, I update the catalog input, re-render, and every client picks up the new config without anyone hand-editing a dotfile.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059657373470720The backends behind the router are a mix: compatibility proxy lanes that translate API formats, LAN-only local inference on nodes/VMs that have GPUs, dedicated LAN model appliances, cloud provider routes for heavy lifting, and fallback routes for when the preferred backend is down. Each LAN machine gets its own router token, so I can revoke one machine without touching the others. The router surface isn’t just chat completions either: it also handles embeddings, reranking, RAG queries, and even Anthropic-format message translation, all through the same authenticated front door.

This is the part that makes AI tooling feel like infrastructure instead of a collection of hacks.

If a tool needs a model list, it should ask the registry or router. If a tool needs a generation route, it should use an authenticated route. If a provider changes, the generated profiles update from the source of truth instead of every client being hand-edited.

The same idea extends to agent skills. There’s a separate dashboard, its own container and LAN-only, that mines the trace corpus for candidate skills, surfaces them for review, and tracks what’s been promoted to the curated skill library. The skills themselves live in a repo, get validated before promotion, and are symlinked into each agent client’s discovery root. That way a skill isn’t a random script in someone’s home directory; it’s a versioned, tested unit that every agent client can discover.

### The Web Evidence Lane

Agents need web access, but raw web access is messy.

Search, scraping, crawling, browser automation, saved pages, and evidence cache shouldn’t be a pile of unrelated scripts on my laptop. They’re a lane in the homelab. In practice this runs on its own VM: a self-hosted search engine aggregator with several dozen configured engines, a web scraper with JavaScript rendering, a headless browser fallback for the hard cases, and an evidence gateway that sits in front of all of it, presenting a unified tool API to agents.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059699631140864The cache matters. If an agent made a decision based on a page, I want a saved artifact or at least a record of what was fetched. Otherwise debugging becomes “the agent saw something on the internet,” which isn’t enough.

### The Searchable State Plane

The state plane is the memory of the system.

It collects the operational metadata that would otherwise be scattered across apps: logs, traces, agent events, tool calls, conversation metadata, job artifacts, saved web evidence, backup metadata, health check results, and restore drill evidence. In [my setup](https://github.com/eric-tramel/moraine)

 this is backed by a ClickHouse instance running in its own container, with an MCP endpoint so agent clients can query it programmatically, a monitor dashboard, and near-live sync from the workstations and runtime hosts that produce agent state.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059731759497216This is where the homelab starts to feel much less like a hobby dashboard collection and much more like a real platform.

The state plane is deliberately separate from the model router. Generation shouldn’t depend synchronously on the trace store being perfect. If the state plane is unavailable, clients should degrade by spooling or retrying later, not turn every model call into an outage.

The sync story matters here. Each covered workstation or runtime host runs a near-live file watcher that mirrors new session archives to the central corpus over SSH. Proxmox-side timers handle the heavier work: backing up conversation surfaces from the UI apps, syncing router proxy traces, and running parity checks that confirm the central store agrees with every source host. If the numbers diverge, the parity check fails with a specific exit code so I know whether it’s a host-unavailable gap or a confirmed drift.

### The Compute Fabric

The compute layer is where work actually runs.

My laptop is a control surface, not the only machine that should do the work. Some tasks are cheap CPU jobs. Some want a GPU. Some need a high-memory box. Some should run close to a dataset. Some should run in an isolated workspace. Some should leave behind artifacts that can be inspected later.

Let’s use my RTX 3070 VM as an example. In practice the compute fabric looks like this: a GPU-equipped VM runs local llama.cpp inference for fallback and canary lanes, dedicated LAN model appliances expose larger models through OpenAI-compatible APIs, and the router on the agent plane can direct work to whichever backend fits the job: local GPU, LAN model appliance, or cloud provider. The workspace UI on the GPU VM gives me a browser-based front end for all of it, with provider switching wired back to the router catalog so I’m not hand-editing API endpoints.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059791503106048That runner selection can be implemented with simple scripts, queues, SSH, systemd services, containers, or more formal schedulers. The implementation can evolve.

The system should know where CPU work can run, where GPU work can run, where larger memory jobs fit, where artifacts belong, where logs go, how traces get captured, and how the user gets back to the result.

That’s what “every job routable” means.

### How The Pieces Connect

Here are the main paths through the system.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059823866368000### Why This Is Not Just “A Reverse Proxy

A reverse proxy is only one layer.

The full system has several control planes: network access control through VPN and firewall policy, naming and discovery through private DNS, application routing through the service gateway, model and provider routing through the agent plane, evidence routing through the web tools lane, operational memory through the state plane, work placement through the compute fabric, and safety through backups, snapshots, and health checks.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059884004315136That’s why the setup feels like “cloud” even though the hardware is local.

### What The Backups Are Doing In This Story

Backups aren’t a side quest. They’re part of the architecture.

Any system with gateways, generated configs, model routes, traces, and stateful apps needs a recovery story. Otherwise the platform only works until the first bad edit or disk problem.

The pattern I use is: snapshot before risky change, edit the intended live file, validate config with the same environment the service will use, reload instead of restart when possible, smoke test the actual route, capture a post-change backup, document the rollback path. I follow this workflow religiously for the gateway config: the Caddyfile gets validated against its environment file before every reload, and I keep timestamped backups of every working config so I can diff and roll back.

This matters especially for gateway config. A small typo in a central gateway can break many services. The answer isn’t fear; the answer is a boring change workflow.

Stateful services get their own backup and restore logic. The searchable state plane gets periodic restore drills to verify the backups actually work. The conversation surfaces, including chat UIs, workspace state, and agent session data, get backed up on a Proxmox-side timer and synced into the state plane as redacted snapshots. The web evidence cache, generated profiles, gateway config, and service runbooks all need to be recoverable too.

The platform is only real if it can be rebuilt.

Health checks are part of that story too. The router and the proxy lanes each have automated health endpoints that get polled on timers; every 15 minutes from the workstation, plus Proxmox-side systemd timers on the containers themselves. There are two levels: health-only checks that are safe to run as background jobs (just hitting /health endpoints), and real-client smokes that actually send prompts through the providers. The real-client smokes can spend quota and hit rate limits, so they’re deliberate operations, not automated background noise. The health-only checks feed into parity and alert scripts that tell me when a route is down before I discover it by surprise.

### Security Boundaries That Matter

The public version of the architecture hides details, but the design principles are worth saying plainly.

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050059974861348864### The Main Lesson

The thing worth copying isn’t my exact set of services.

The thing worth copying is the shape:

https://x.com/TheAhmadOsman/article/2050062045471740303/media/2050060022680535041You don’t need to start with all of it. In fact, you probably shouldn’t.

Start with: a virtualization or host layout you understand, private DNS, a VPN edge, a reverse proxy or internal service gateway, snapshots and backups, health checks, a central place for logs/traces, compute runners, a model/agent router if you use AI tools heavily, and web evidence tooling if agents browse or research for you.

That order keeps the foundation boring.

The agents, GPUs, browser tools, and searchable memory are much easier to trust after the network, naming, gateways, and recovery path are already sane.

### The Short Answer To “Is This The Cloud?”

It isn’t public cloud.

It isn’t infinite scale.

It isn’t a replacement for every managed service.

It’s a private cloud-like operating model running on local infrastructure.

The important part is that clients don’t need to know the whole topology. They use stable entry points. The platform handles the private backends, routes, policies, runners, traces, and recovery workflows.

That’s why my answer was:

> No, I did not duplicate my homelab to the cloud. My homelab became the cloud I use.

> 📄 Original article URL: https://x.com/i/article/2050058966072524800

