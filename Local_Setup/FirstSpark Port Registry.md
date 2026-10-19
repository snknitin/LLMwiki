---
updated: 2026-10-19
host: FirstSpark (spark-07a8, tailnet spark-07a8.tail4a1242.ts.net)
---

# FirstSpark Port Registry

Every port in use on FirstSpark, so no two services get the same one. **Before giving a new service a port, pick one from "Free for new services", then add its row here in the same change.** Agents follow this through the shared rules ([[AI Coding Playbook]]).

Taken from `ss -ltnp`, `tailscale serve status`, systemd units and `docker ps` on 2026-10-19. Re-check any time with:

```bash
ssh FirstSpark 'ss -ltnH; tailscale serve status'
```

## Dashboards and apps (loopback, published on the tailnet by Tailscale Serve)

| Local port | Tailnet URL port | Service | Runs as |
|---|---|---|---|
| 4173 | :4173 | God's Eye View | Docker `gods-eye-view` |
| 5555 | — (Windows SSH tunnel) | sparkDash | Docker `sparkDash`, host network |
| 8091 | :8091 | FreshRSS | Docker `freshrss` (container :80) |
| 8443 | :8443 | YouTube Learning Center (`ylc`) | process |
| 8765 | :8765 | Social Capture | `social-capture.service` (user) |
| 8766 | :10000 | Dunbar Dossier | `dunbar-dossier.service` |
| 8772 | :8772 | Kaggle Learning Center | `kaggle-learning-center.service` (user) |
| 8787 | :8787 | Fresh Brief | process `python app.py` |
| 8788 | :8788 | TikTok Learning Center (`tlc`) | process |
| 3010 | :8789 | TikTok VPN browser (Selkies) | Docker `tlc-vpn-gluetun` (container :3000) |
| 27910, 27913–27915, 27918, 27919 | :443 `/mcp-oauth/*` | MCP OAuth callbacks (notion, vercel, stripe, figma, linear, cloudflare) | reserved; only listening during an OAuth sign-in |

## Models and agent infrastructure

| Port | Bind | Service | Runs as |
|---|---|---|---|
| 8000 | 127.0.0.1 (+ 0.0.0.0 in container) | vLLM `spark-fast` = Qwen3.6-35B-A3B NVFP4 | Docker `vllm-spark-fast` |
| 4000 | 127.0.0.1 | LiteLLM gateway (routes `spark-fast`, `glm53-flash`, ...) | Docker `spark-litellm` |
| 8102 | 127.0.0.1 | EmbeddingGemma 2 (llama.cpp), used by Fresh Brief | Docker `fresh-brief-embeddings` (container :8080) |
| 8888 | 127.0.0.1 | Docker container on network 172.18 (likely SearXNG): **confirm** | Docker |
| 9119 | tailnet IP | Hermes Serve | `hermes-serve.service` (user) |
| 9120 | tailnet IP | Hermes Dashboard | `hermes-dashboard.service` (user) |
| 3003 | 127.0.0.1 | OpenCode web | `opencode-web.service` (user) |

## System and unknown

| Port | Service |
|---|---|
| 22 | SSH |
| 443 | Tailscale Serve (root URL, MCP OAuth paths) |
| 53 | systemd-resolved |
| 631 | CUPS printing |
| 9333 | **unknown**, loopback: identify before reusing |
| 11000 | **unknown**, loopback: identify before reusing |
| 39765, 41480 | Tailscale internals (change on restart) |

## Free for new services

Use these in order and move each one into a table above once it's taken.

- **Dashboards / web apps:** 8767, 8768, 8769, 8770, 8771, 8773–8786, 8790–8799
- **Agent tools and APIs:** 9121–9199
- **Model servers:** 8001–8009 (8000 is spark-fast)
- Avoid 8080 (common default, used inside containers), 8888, 3000, 5000, 11434 (Ollama default).

Publishing on the tailnet: `sudo tailscale serve --bg --https=<port> http://127.0.0.1:<port>`. Use the same number on both sides unless a row above says otherwise.
