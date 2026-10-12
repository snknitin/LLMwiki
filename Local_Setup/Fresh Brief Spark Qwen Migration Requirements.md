# Fresh Brief Spark Qwen Migration Requirements

> [!important] Deferred by user decision — 12 October 2026
> **Fresh Brief stays on Windows Ollama.** This optional future migration is not a dependency of the Hermes coding migration. Proposed adapter edits were reverted, preserving the pre-task source changes; running containers and saved settings were untouched. See [[Qwen 3.8 27B Spark Serving Options]]. The specification below is retained only for a future separately requested move.

Checked against the local source on **12 October 2026 (IST)**. **Specification only: Fresh Brief has not been migrated or tested against Spark.** Its recurring desktop Qwen load remains intentional in the current scope.

Fresh Brief currently runs in Windows Docker and can invoke desktop Ollama at **8 AM and 8 PM IST**. Moving Hermes alone does not move this workload. Keep the existing dashboard at `http://localhost:8787`, subscriptions, saved editions, and schedule.

## Why a URL change is insufficient

- [app.py](E:/GIT_ROOT/Projects/fresh-brief/app.py:283) `model_points()` and [newsroom.py](E:/GIT_ROOT/Projects/fresh-brief/newsroom.py:69) `local_json()` send Ollama-native `/api/chat` bodies and read `response['message']['content']`. LM Studio requires `/v1/chat/completions` and a different body/response.
- [app.py](E:/GIT_ROOT/Projects/fresh-brief/app.py:297) passes the Ollama endpoint through `build_issue()` into the article/essay pipeline. Both inference boundaries must migrate; changing only the older gist helper is insufficient.
- `setting('model', MODEL)` reads SQLite first. Changing `OLLAMA_MODEL` in Compose does not replace an existing saved model. `/api/settings` rejects IDs outside `MODELS`.
- [compose.yaml](E:/GIT_ROOT/Projects/fresh-brief/compose.yaml:14) points to `host.docker.internal:11434`; [start.ps1](E:/GIT_ROOT/Projects/fresh-brief/start.ps1:8) actively starts/checks desktop Ollama. The startup guard must become provider-aware too.

## Small implementation specification

1. Add one shared JSON-generation function used by both call sites. Retain the standard-library HTTP helper and its response-size bound; do not replace the FreshRSS/article-fetch transport or add a proxy pretending to be Ollama.
2. Introduce explicit proposed configuration: `LLM_PROVIDER=openai`, `LLM_BASE_URL=<verified private route ending /v1>`, `LLM_MODEL=qwen38-27b-spark`, and optional `LLM_API_KEY`. These variables **do not exist yet**; implementation must read and validate them. Preserve the Ollama path only as an explicitly selected legacy provider.
3. Register `qwen38-27b-spark` in the model allowlist and display its Spark ownership. Route this ID only to the Spark connection. Never send an Ollama ID to LM Studio or silently retry on Windows when Spark fails.
4. For OpenAI mode, construct the following payload and append `/chat/completions` exactly once to the configured `/v1` base:

```python
payload = {
    'model': 'qwen38-27b-spark', 'messages': messages,
    'stream': False, 'temperature': 0, 'max_tokens': output_limit,
    'response_format': {
        'type': 'json_schema',
        'json_schema': {'name': 'fresh_brief_result', 'strict': True, 'schema': schema}
    }
}
# HTTP helper returns the decoded outer response; validate before indexing.
text = response['choices'][0]['message']['content']
result = json.loads(text)
```

5. Preserve each caller's schema, prompts, Unicode article text, citation checks and output bound: gist 1,500; article notes 1,800; default JSON 2,600; essays 6,000 tokens. Keep the current 180/240-second request limits initially; measure before changing them.
6. Do not forward Ollama `format`, `options`, `num_ctx`, `num_predict`, `keep_alive` or `think` fields. LM Studio context/residency belongs to the qualified server load. Configure and verify non-thinking behavior using the installed LM Studio runtime's supported control; do not assume Ollama `think:false` transfers or strip arbitrary reasoning text to disguise malformed JSON.
7. Validate nonempty `choices`, textual content, successful finish reason, JSON shape, and existing semantic/citation rules. Treat truncation, refusal, HTTP errors, empty content and schema failures as failed inference. Keep retries bounded and surface a sanitized dependency error; never mark a partial edition complete.
8. Add the optional bearer header only for the inference host. Never log API keys, raw article bodies, model prompts or response bodies. Keep credentials outside Git and out of health responses.
9. Make `start.ps1` check the selected Spark route and exact model ID in OpenAI mode instead of requiring/starting Ollama. Keep `localhost:8787` and the existing FreshRSS startup behavior.

The payload/response mapping follows [LM Studio structured output](https://lmstudio.ai/docs/developer/openai-compat/structured-output) and [chat completions](https://lmstudio.ai/docs/developer/openai-compat/chat-completions). Native model capability is not proof that this application's schemas and retries pass.

## Private connection choices

**Preferred for the current Windows deployment: SSH forwarding to Spark loopback.** Keep Spark LM Studio on `127.0.0.1:1234`; reuse the verified SSH identity from the main runbook. A visible Windows terminal can initially run this template, after checking port 12340 is unused:

```powershell
$SshConfig = Join-Path $env:LOCALAPPDATA 'NVIDIA Corporation\Sync\config\ssh_config'
ssh -F $SshConfig -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -L 127.0.0.1:12340:127.0.0.1:1234 FirstSpark
```

Test `http://127.0.0.1:12340/v1/models` on Windows, then test `http://host.docker.internal:12340/v1/models` **from the Fresh Brief container**. Container reachability of a Windows loopback listener must be demonstrated; it is not guaranteed. If it fails, stop: use a reviewed SSH tunnel sidecar reachable only on the private Docker network, with no published host ports. Do not fix it by binding Spark port 1234 to `0.0.0.0`. Make tunnel startup/recovery explicit before enabling scheduled use.

**Alternative: Windows LM Link.** Pin FirstSpark as the preferred device, use its remote model and test the Windows API from the container. Windows, Docker and LM Studio must all remain running; LM Link does not move Fresh Brief's scheduler to Spark. Verify the named resident alias is visible through the actual Windows API before saving it. [LM Link routing](https://lmstudio.ai/docs/developer/core/lmlink).

**Optional future route: native Tailscale exposure.** Requires explicit approval and a reviewed binding, authentication and tailnet ACL design for this service. Expose only through an approved tailnet path; never open unauthenticated port 1234 to the LAN/public internet. Do not assume an existing Ollama Tailscale route also serves LM Studio.

Windows shutdown still stops this Windows-hosted dashboard/scheduler, even with Spark inference. Moving Fresh Brief and FreshRSS to an always-on host is a separate migration with one authoritative database/feed owner.

## Cutover and preservation

1. Wait until `/api/health` reports `busy:false`. Record the selected model, schedule, latest complete edition and `brief_cursor`; make a consistent SQLite/volume backup including WAL state before rebuilding. Never delete `brief_data` or run `docker compose down -v`.
2. Implement and test the adapter/configuration, then rebuild using the provider-aware startup path. Do not interrupt an active edition by recreating its container.
3. Through Reading room settings, explicitly select **qwen38-27b-spark** after it exists in the allowlist. Verify the API/UI reports that persisted value. Preserve `twice_daily` at **08:00 and 20:00 Asia/Kolkata** and current one-slot catch-up behavior.
4. Keep immutable historical editions, bookmarks, read state, preferences, article-text cache and interval migration intact. `reading_notes` keys already include model identity: new Spark notes may legitimately be recomputed; retain old cache entries and never relabel historical notes as Spark-generated.
5. Record the complete private route, provider/model identity and verification results. Keep old weights as rollback until this and the Hermes qualification gates pass. If Spark is unavailable, show the dependency failure and preserve readable saved editions; no automatic desktop fallback.

## Required acceptance gates

- Run existing `python test_app.py` plus focused transport tests: both call sites, correct schema/body mapping, optional auth, malformed/empty/refused/truncated responses, bounded retries and no cross-provider fallback.
- From the real container, list models and generate schema-constrained JSON using the exact resident Spark alias. A Windows-host-only request or `/api/health` success does not qualify inference connectivity.
- Build a small real edition with article notes, essays and valid citations; confirm model identity in the new document, complete status and correct cursor advance. Repeat with cached data and verify old editions remain unchanged.
- Make the Spark route unavailable during a bounded test: confirm a visible error, unchanged successful cursor, preserved caches/editions, and **zero requests to desktop Ollama**.
- Run one Fresh Brief build overlapping the qualified Hermes workload; record latency, memory and error rates. Observe Windows GPU processes to confirm no Qwen inference locally. Extra clients consume the same Spark concurrency budget.
- Verify container/tunnel startup after a controlled application restart and observe a scheduled 08:00 or 20:00 IST run on Spark. Do not claim scheduled migration complete from configuration inspection alone.

Related: [[Local Setup Index]]. The main Spark Qwen migration runbook must treat these unchecked gates as outstanding work, not completed deployment.
