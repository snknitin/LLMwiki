---
created: 2026-10-13
status: live
tags: [naming, hermes, litellm, reference]
---

# Model and provider names

What each local model and provider is called now, and which old names still work. Notes dated before 13 October 2026 use the old names; read them through this table.

## Renamed 13 October 2026

| What | Old name | New name | Where it's set |
|---|---|---|---|
| Hermes provider for the FirstSpark LiteLLM gateway (127.0.0.1:4000) | `spark-fast` / `custom:spark-fast` | **`local-models`** / **`custom:local-models`** | `~/.hermes/config.yaml` and `profiles/*/config.yaml` on FirstSpark |
| Qwen 3.6 35B-A3B NVFP4 (the fast always-on Spark model) via LiteLLM | `spark-fast` | **`qwen3.6-35b-a3b`** | LiteLLM `~/ai/services/litellm/config.yaml` |
| Desktop Qwen 3.8 27B (Windows RTX) in Hermes | `qwen3.8:27b-q4_k_m` | **`qwen3.8-27b-desktop`** (provider `desktop-qwen`) | Hermes configs + `scripts/desktop-qwen-apply.ps1` alias |

The `local-models` provider also carries the other LiteLLM aliases (`qwen27-dflash`, `nemotron3-omni`, `qwen38-tensorfold-second`, …); only the 35B's own alias changed.

## Old names that still work, on purpose

- **LiteLLM `spark-fast`**: a hidden alias (`router_settings.model_group_alias`, `hidden: true`) for `qwen3.6-35b-a3b`. Not listed in `/v1/models`, still accepted, so older scripts don't break. Remove it once nothing calls it (check `docker logs spark-litellm | grep spark-fast`).
- **Hermes credential**: `~/.hermes/auth.json` has the LiteLLM credential under both `custom:local-models` and `custom:spark-fast`.
- **Desktop server**: answers any model name, so `qwen3.8:27b-q4_k_m` still works.
- **Fresh Brief** (FirstSpark, since 16 October 2026) calls the vLLM container **directly** at `127.0.0.1:8000` with the served model name `spark-fast`, not through LiteLLM. If the vLLM served name changes, update `LLM_MODEL` in `fresh-brief/compose.yaml` and redeploy.

## When renaming a LiteLLM alias again

Hermes caches each provider's discovered model list in `~/.hermes/provider_models_cache.json` (and `profiles/*/provider_models_cache.json`), keyed by base URL. After changing LiteLLM aliases, delete the `custom:http://127.0.0.1:4000/v1#…` entry in each of those files and refresh the picker (`/model --refresh`). Otherwise the picker keeps showing the old names.

## Internal names that were deliberately NOT renamed

These are plumbing, not what you pick. Renaming them would restart the 35B and edit boot-time scripts. Commands in older notes that use them are still correct.

| Name | What it is |
|---|---|
| `vllm-spark-fast` | Docker container serving the 35B (`~/ai/services/qwen35/compose.yaml`) |
| `spark-fast` (hostname) | Its Docker network name; LiteLLM reaches it at `http://spark-fast:8000/v1` |
| `spark-fast` (vLLM served name) | The model name on port 8000 directly. Used by YouTube Learning Center, the Hermes `youtube_analysis` and `social_capture_vision` helpers, and the Social Capture plugin, which all call port 8000 directly |
| `wait-for-spark-fast` | `~/.local/bin` startup helper; the Spark Qwen 27B service waits on it |
| `spark-frontier` lanes, `spark-gpu-audit`, `spark-clear-orphans`, sparkDash | Operations scripts that refer to the container |
| `YLC_MODEL_PROFILE=local-spark-fast` | YouTube Learning Center profile name |

## Updated alongside

- Kaggle Learning Center (FirstSpark repo): its isolated Hermes now uses `custom:local-models` / `qwen3.6-35b-a3b`; setup re-run, 14 tests pass, service restarted.
- `~/.local/bin/spark-frontier` (lane switch / `restore-spark-fast`) now writes `custom:local-models`, and restores `model.default qwen3.6-35b-a3b`; `spark-frontier-check` expects `custom:local-models`. The command names themselves are unchanged.
- Tutorial commands (`hermes config set model.default …`, `--provider custom:…`) updated in the current guides plus the Gemma 4, Muse Glimmer, Nemotron Omni, Nemotron 3.5 and TensorFold tutorials. The retired v0.30 `qwen38-tp1-second` tutorial and the DeepSeek comparison protocol keep their original commands as records.
- Backups: `~/.hermes/backups/local-models-rename-20261013/` (configs + auth.json), `~/ai/services/litellm/config.yaml.bak-20261013-pre-local-models-rename`, `~/.local/bin/spark-frontier{,-check}.before-local-models-20261013`.

## Retired alias (not part of the rename)

`qwen38-tp1-second` was already disabled (its LiteLLM `api_base` was the dead `127.0.0.1:1`). On 13 Oct it was removed from LiteLLM and from the Hermes model lists, so it no longer appears in the picker; requests to it now get "invalid model". Backups: `~/.hermes/backups/hide-tp1-20261013/`, `~/ai/services/litellm/config.yaml.bak-20261013-pre-hide-tp1`. The live SecondSpark model is `qwen38-tensorfold-second` (`Qwen3.8-Flash-Next`, container `qwen38-flash-next-tf`).
