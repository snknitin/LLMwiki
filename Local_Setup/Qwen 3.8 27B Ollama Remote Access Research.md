# Qwen 3.8 27B Ollama Remote Access Research

**Checked:** 2026-08-20  
**Scope:** RTX PRO 5000 Windows workstation, workstation ODS/Open WebUI, Hermes Gateway on DGX Spark, and a Tailscale-connected laptop.

## Recommendation

Keep one copy of `qwen3.8:27b` in the workstation's native Ollama store and keep Ollama listening only on its normal local address, `127.0.0.1:11434`. Publish that loopback service privately with **Tailscale Serve**, then add the resulting HTTPS URL as a **named custom provider in Hermes on the Spark**.

This is the simplest stable arrangement for the current setup:

- ODS Open WebUI reaches the same workstation Ollama locally at `http://host.docker.internal:11434`.
- Spark Hermes reaches it through Tailscale Serve at `https://<workstation-name>.<tailnet>.ts.net/v1`.
- Hermes Desktop on the desktop or laptop, and the Telegram integration, continue connecting to the Spark Hermes Gateway; model inference still happens on the workstation.
- A laptop application that needs direct OpenAI-compatible access may use the same Tailscale Serve URL.

Do **not** move Ollama away from port 11434, bind it to the LAN with `OLLAMA_HOST=0.0.0.0`, or expose it with Tailscale Funnel. Ollama's local API does not authenticate callers, while Tailscale Serve can proxy a localhost-only service and enforce tailnet access policy. [Ollama authentication](https://docs.ollama.com/api/authentication), [Ollama networking and origins](https://docs.ollama.com/faq#how-can-i-expose-ollama-on-my-network), [Tailscale Serve](https://tailscale.com/docs/features/tailscale-serve)

LiteLLM on the Spark is **optional**, not required for this model. Add a LiteLLM route only when several backends must sit behind one durable alias, or when centralized fallback/load balancing is desired. Hermes already supports named OpenAI-compatible endpoints and mid-session switching, so inserting LiteLLM for this single workstation Ollama endpoint adds another service and another failure point without improving access. [Hermes provider documentation](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/integrations/providers.md#named-custom-providers)

## Official model facts

| Item | Official value |
|---|---|
| Ollama tag | `qwen3.8:27b` |
| Parameters | 27.3B |
| Quantization | `Q4_K_M` |
| Advertised download size | 18 GB |
| Exact registry payload | 17,741,872,154 bytes across the manifest, config, projector, model, license, and parameter layers (about 17.74 decimal GB / 16.52 GiB) |
| Maximum advertised context | 256K tokens |
| Modalities | Text and image |
| Ollama capability badges | Vision, tools, thinking |
| Minimum Ollama declared by the manifest | 0.32.12 |

Sources: [Ollama Qwen 3.8 library page](https://ollama.com/library/qwen3.8), [27B tag page](https://ollama.com/library/qwen3.8:27b), and the [official Ollama registry manifest](https://registry.ollama.ai/v2/library/qwen3.8/manifests/27b).

The 256K figure is the model's advertised maximum, not the workstation's active allocation. This workstation is configured for **128K**, and the existing Gemma runtime checks reported `CONTEXT 131072`. Qwen must be loaded and checked with `ollama ps` before the same value is added to Hermes; if Qwen reports a lower effective context, record that lower value instead. Hermes explicitly warns that Ollama metadata can report the model maximum rather than the effective configured `num_ctx`. [Ollama context documentation](https://docs.ollama.com/context-length), [Hermes context detection documentation](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/integrations/providers.md#context-length-detection)

Qwen 3.8 thinking is enabled by default according to its Ollama model page and can be disabled per request. Ollama supports separate thinking output and tool calls, but actual Hermes reliability must be verified with a real tool-call test after installation; capability labels are not a substitute for an end-to-end agent test. [Qwen 3.8 model page](https://ollama.com/library/qwen3.8), [Ollama thinking](https://docs.ollama.com/capabilities/thinking), [Ollama tool calling](https://docs.ollama.com/capabilities/tool-calling)

## Secure connection design

```text
Workstation Ollama (127.0.0.1:11434)
   |-- ODS Open WebUI (local Docker host connection)
   `-- Tailscale Serve HTTPS (tailnet only)
          |-- DGX Spark Hermes named provider
          `-- laptop applications, only if direct model access is needed

Desktop Hermes / Laptop Hermes / Telegram
   `-- DGX Spark Hermes Gateway
          `-- named provider -> workstation Tailscale Serve -> Ollama
```

Tailscale Serve is preferable to changing `OLLAMA_HOST` because it can proxy a service that still listens only on localhost. Tailscale says Serve is private to the tailnet, uses the tailnet's HTTPS certificates, and remains subject to access-control rules. Tailscale also recommends localhost binding when a service is reached through Serve. [Tailscale Serve documentation](https://tailscale.com/docs/features/tailscale-serve), [Tailscale security guidance](https://tailscale.com/docs/reference/best-practices/security)

### Important security limits

- Ollama's local API has no application-level authentication. An `api_key: ollama` value is only a compatibility placeholder and is ignored by Ollama's OpenAI-compatible API. Authorization therefore comes from Tailscale device/user identity and the tailnet ACL, not from Ollama. [Ollama authentication](https://docs.ollama.com/api/authentication), [Ollama OpenAI compatibility](https://docs.ollama.com/api/openai-compatibility)
- Restrict the Serve endpoint so only the Spark and the user's own laptop/desktop identities can reach it. Do not grant all tailnet users access merely because the service is private.
- Never use `tailscale funnel` for Ollama. Funnel is explicitly the public-internet publishing mechanism; Serve is the tailnet-only mechanism. [Tailscale Serve](https://tailscale.com/docs/features/tailscale-serve)
- Do not set a wildcard `OLLAMA_ORIGINS=*`. Server-to-server requests from Hermes and ODS do not require browser CORS. If a browser application calls Ollama directly, add only that exact HTTPS origin. Ollama documents `OLLAMA_ORIGINS` as the control for additional browser origins. [Ollama FAQ](https://docs.ollama.com/faq#how-can-i-allow-additional-web-origins-to-access-ollama)
- The model becomes unavailable when the workstation sleeps, Ollama exits, Tailscale disconnects, or the workstation reboots before Ollama/Serve recover. Verify startup behavior instead of assuming “downloaded” means “available 24/7.”
- Model weights stay on the workstation, but prompts and results traverse the encrypted tailnet between Spark/laptop and the workstation.

## Recommended Hermes provider entry

The provider already exists in both Spark Hermes profiles and in the Windows Local Gateway profile. Do not create another provider. After Qwen passes its runtime check, add only its per-model metadata beneath the existing `desktop-ollama` entry in `~/.hermes/config.yaml` and `~/.hermes/profiles/orchestrator/config.yaml`. The working Spark entry is:

```yaml
providers:
  desktop-ollama:
    name: Desktop Ollama via Tailscale
    api: https://nike-workstation.tail4a1242.ts.net:8443/v1
    transport: chat_completions
    discover_models: true
    extra_headers:
      Host: localhost:11434
    models:
      qwen3.8:27b:
        context_length: 131072
        supports_vision: true
```

Hermes documents named custom providers, per-model context settings, native-vision flags, and the switch syntax. With the entry above, the explicit switch is:

```text
/model custom:desktop-ollama:qwen3.8:27b
```

Because the inference request is executed by Hermes on the Spark, Hermes Desktop clients and messaging integrations that use that Spark Gateway do not need separate Ollama provider configuration. This is an architectural inference from the centralized Gateway arrangement; verify it from both Desktop clients and Telegram before calling the rollout complete. [Hermes named custom providers](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/integrations/providers.md#named-custom-providers), [Hermes CLI model switching](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/reference/cli-commands.md#hermes-model)

## Precise verification checklist

### Live installation record — 2026-08-20

- The first transfer stopped with `unexpected EOF`; rerunning the same pull resumed the content-addressed download and ended with SHA-256 verification, manifest write, and `success`.
- `ollama show` reported 27.3B parameters, `Q4_K_M`, model context `262144`, required Ollama `0.32.12`, and text, vision, tools, and thinking capabilities.
- The loaded model reported `100% GPU`, context `262144`, and workstation GPU use of about 37,890 MiB out of 48,935 MiB.
- The local text request and structured `multiply(a=7,b=8)` tool call passed. The vision path read the visible Gemma model names correctly but mislabeled the Open WebUI screenshot as LM Studio; capability works, but visual interpretation quality needs broader evaluation.
- ODS Open WebUI discovered `qwen3.8:27b` exactly once and completed a chat without an ODS-owned model copy.
- Spark listed and called the model through the tailnet-only endpoint, and a Hermes one-shot override through `custom:desktop-ollama` passed.
- Qwen metadata with context `262144` and vision support was added to the Windows Local Gateway, Spark main profile, and Spark orchestrator profile. The current default remains `spark-fast`.
- After testing, `ollama stop qwen3.8:27b` emptied `ollama ps`; the installed model remained in `ollama list`, and GPU use returned to about 2,082 MiB.

### A. Workstation model and storage

- [x] `ollama --version` is at least 0.32.12.
- [x] `OLLAMA_MODELS` points to `D:\LocalLLama\models\ollama`.
- [x] `ollama pull qwen3.8:27b` finishes successfully after resuming the interrupted first transfer.
- [x] `ollama list` shows exactly one `qwen3.8:27b` entry at roughly 17 GB.
- [x] `ollama show qwen3.8:27b` reports 27.3B parameters, `Q4_K_M`, vision/projector support, and model context `262144`.
- [x] A direct local `/api/chat` request returns a text answer.
- [x] A direct tool-call test returns a structured tool call, not tool syntax embedded as plain text.
- [ ] Repeat the direct image test on a broader image set; the first test read the model names but mislabeled the application.
- [x] During the configured-context test, `ollama ps` shows `100% GPU` and `262144`; Hermes metadata matches it.
- [x] `ollama stop qwen3.8:27b` unloads the model after testing.

### B. ODS Open WebUI

- [x] ODS retains one Ollama connection: `http://host.docker.internal:11434`.
- [x] No second Qwen download is created inside the ODS GGUF model directory.
- [x] After refreshing models, `qwen3.8:27b` appears once, not twice.
- [x] A new Open WebUI chat returns a response from `qwen3.8:27b`.
- [ ] An image and one Open WebUI tool/function are tested separately.

### C. Tailscale Serve

- [x] Ollama still answers on `127.0.0.1:11434` and is not listening on a LAN-wide address.
- [x] The workstation already publishes loopback Ollama through tailnet-only `https://nike-workstation.tail4a1242.ts.net:8443`, proxying `http://127.0.0.1:11434`.
- [x] The existing Spark provider sends `Host: localhost:11434`, which the reverse-proxied Ollama endpoint requires.
- [ ] The tailnet ACL permits the Spark and intended personal devices, and denies an unrelated tailnet identity/device.
- [x] From the Spark, request the workstation URL with `Host: localhost:11434` and confirm `/v1/models` lists `qwen3.8:27b`.
- [x] From the Spark, an OpenAI-compatible request to `/v1/chat/completions` returns a response.
- [ ] The same URL is unreachable when Tailscale is disconnected, confirming there is no accidental public/LAN exposure.

### D. Hermes Gateway and clients

- [x] Back up `~/.hermes/config.yaml` before editing it.
- [x] The named `desktop-ollama` provider already exists without replacing the current default model.
- [x] `hermes doctor` reports no provider/configuration warning; its remaining notices are unrelated optional-auth and build-tool notices.
- [x] A Spark Hermes one-shot override using `custom:desktop-ollama` and `qwen3.8:27b` succeeds without changing the default.
- [ ] A normal chat, a reasoning prompt, a real Hermes tool call, and an image are each tested.
- [x] The effective Hermes context is explicitly `262144`, matching the live `ollama ps` result.
- [ ] The model can be selected and used from Hermes Desktop on the workstation.
- [ ] The same Gateway session/model can be used from Hermes Desktop on the laptop.
- [ ] Telegram can invoke the model through the Spark Gateway without any laptop-side Ollama configuration.
- [ ] Restart Ollama, Tailscale, and Hermes Gateway one at a time; repeat one prompt after each restart.

## When to add a Spark LiteLLM route later

Add LiteLLM only if one of these becomes a real requirement:

1. A stable alias such as `workstation-general` must switch between Qwen and Gemma without reconfiguring every client.
2. Automatic fallback from workstation Ollama to a Spark vLLM/SGLang model is required.
3. Multiple non-Hermes applications should share the same routing, logging, quotas, or health checks.

In that future design, LiteLLM should call the same Tailscale Serve OpenAI endpoint, while Hermes points to the LiteLLM alias. Until then, the direct named provider preserves the fewest moving parts and leaves the existing Spark models unchanged.
