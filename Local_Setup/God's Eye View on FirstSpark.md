---
updated: 2026-10-16
status: completed
scope: dgx-spark, firstspark, monitoring, osint, dashboard-command-center, docker
---

# God's Eye View on FirstSpark

[God's Eye View](https://github.com/bilawalsidhu/gods-eye-view) (MIT, Bilawal Sidhu) is a browser 3D globe with live public feeds: flights (OpenSky/adsb.lol), military aircraft, satellites (CelesTrak), launches, earthquakes (USGS), CCTV and transit. It runs always-on on FirstSpark and is the **God's Eye View** tab in the Dashboard Command Center **Monitoring** group.

| Item | Value |
|---|---|
| URL | `https://spark-07a8.tail4a1242.ts.net:4173/` (tailnet only) |
| Checkout | FirstSpark `~/Workspace/GIT_ROOT/Projects/gods-eye-view` |
| Runtime | repo `compose.yaml` (loopback `127.0.0.1:4173`) + local `compose.override.yaml` (`restart: unless-stopped`, runs as `snknitin`, `GEV_ALLOWED_HOSTS=spark-07a8.tail4a1242.ts.net`); the override is in `.git/info/exclude` so `git pull` stays clean |
| Publish | `tailscale serve --bg --https=4173 http://127.0.0.1:4173` |
| Control | `aux-services start|stop gods-eye-view` (managed: drained with the other light services before a Frontier lane) |
| Dashboard | registry ids `gods-eye-view`, endpoint `gods-eye-view-spark`, session `gods-eye-view-session`; registry backup `registry.pre-gods-eye-view-20261016.json` |

## Verified 2026-10-16

- Root HTTP 200 locally and from Windows over the tailnet.
- `/api/flights` returned 6,429 live states with a current timestamp. The aircraft shown near Austin (N582RD `a77ed1`, SWA900, JUS518, AAL691) matched an independent `api.adsb.lol` point query.
- `/api/military`, `/api/military-installations`, `/api/adsbdb/type/*`, `/api/flights/track` and `/api/terrain/heights` all returned 200.
- Expected non-200s with no keys: `/api/vessels` 503 (needs AISStream key), `/api/google/*` 403/404 and `/api/openai/*` 403 (no keys; Provider Settings refuses proxied requests by design).

## Keys (optional)

Keys must go in `.env` in the checkout, not the in-app Provider Settings: the tab is reached through Tailscale Serve, which the app treats as proxied. Then `docker compose up -d`. Free keys worth adding first: `AISSTREAM_API_KEY` (ships), the NASA FIRMS map key (fires), a Cesium ion token (photorealistic 3D/terrain). `OPENAI_API_KEY` (voice, HUD summary) and `GOOGLE_MAPS_API_KEY` are metered; set provider quotas first. The server brokers keys to anyone on the tailnet who can reach `:4173`.

## Update

```bash
cd ~/Workspace/GIT_ROOT/Projects/gods-eye-view && git pull && docker compose down -v && docker compose up -d --build
```

The `down -v` drops the anonymous `node_modules` volume so new dependencies install.

## Caveats from upstream

Keyless traffic is simulated, camera poses are estimates until calibrated, and launch ascent playback is a reconstruction. Upstream says not to use it for navigation, emergency, medical or investment decisions.
