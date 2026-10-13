# Desktop Qwen Publish & GLM Shim

> 18 nodes · cohesion 0.15

## Key Concepts

- **argparse** (31 connections)
- **add_desktop_qwen.py** (12 connections) — `Qwen Spark Migration/add_desktop_qwen.py`
- **glm-reasoning-shim.py** (10 connections) — `scripts/glm-reasoning-shim.py`
- **main()** (7 connections) — `Qwen Spark Migration/add_desktop_qwen.py`
- **copy** (6 connections)
- **test_verify_native_catalog.py** (5 connections) — `Qwen Spark Migration/test_verify_native_catalog.py`
- **BridgeServer** (4 connections) — `scripts/glm-reasoning-shim.py`
- **http_server** (3 connections)
- **transform()** (3 connections) — `Qwen Spark Migration/add_desktop_qwen.py`
- **test_add_desktop_qwen.py** (3 connections) — `Qwen Spark Migration/test_add_desktop_qwen.py`
- **main()** (3 connections) — `scripts/glm-reasoning-shim.py`
- **http_client** (2 connections)
- **config_paths()** (2 connections) — `Qwen Spark Migration/add_desktop_qwen.py`
- **Publish the verified workstation Qwen tag in every FirstSpark Hermes profile.** (1 connections) — `Qwen Spark Migration/add_desktop_qwen.py`
- **Sanitized picker fixtures; no network, service or model access.** (1 connections) — `Qwen Spark Migration/test_verify_native_catalog.py`
- **Translate vLLM ``reasoning`` fields for LiteLLM's OpenAI adapter. The pinned…** (1 connections) — `scripts/glm-reasoning-shim.py`
- **ThreadingHTTPServer** (1 connections)
- **typing** (1 connections)

## Relationships

- [Native Download & Hermes Probes](Native_Download_&_Hermes_Probes.md) (11 shared connections)
- [Migration Test Fixtures](Migration_Test_Fixtures.md) (8 shared connections)
- [Native Qwen Runner & Memory Diagnose](Native_Qwen_Runner_&_Memory_Diagnose.md) (6 shared connections)
- [Native Qwen Qualification Probes](Native_Qwen_Qualification_Probes.md) (5 shared connections)
- [Hermes Provider Migration Scripts](Hermes_Provider_Migration_Scripts.md) (4 shared connections)
- [Reviewed Native Continuation](Reviewed_Native_Continuation.md) (3 shared connections)
- [Interactive Speed & Restart Probes](Interactive_Speed_&_Restart_Probes.md) (3 shared connections)
- [GLM Reasoning Bridge](GLM_Reasoning_Bridge.md) (3 shared connections)
- [Parallel Pinned Downloads](Parallel_Pinned_Downloads.md) (2 shared connections)
- [Frontier Model Probe Script](Frontier_Model_Probe_Script.md) (2 shared connections)
- [Dashboard Preview Server](Dashboard_Preview_Server.md) (1 shared connections)
- [Desktop Qwen Transform Tests](Desktop_Qwen_Transform_Tests.md) (1 shared connections)

## Source Files

- `Qwen Spark Migration/add_desktop_qwen.py`
- `Qwen Spark Migration/test_add_desktop_qwen.py`
- `Qwen Spark Migration/test_verify_native_catalog.py`
- `scripts/glm-reasoning-shim.py`

## Audit Trail

- EXTRACTED: 73 (100%)
- INFERRED: 0 (0%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [index](index.md) to navigate.*