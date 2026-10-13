# Hermes Provider Migration Scripts

> 18 nodes · cohesion 0.24

## Key Concepts

- **configure_hermes.py** (22 connections) — `Qwen Spark Migration/configure_hermes.py`
- **configure_hermes_native.py** (14 connections) — `Qwen Spark Migration/configure_hermes_native.py`
- **main()** (8 connections) — `Qwen Spark Migration/configure_hermes.py`
- **transform()** (6 connections) — `Qwen Spark Migration/configure_hermes_native.py`
- **rollback()** (5 connections) — `Qwen Spark Migration/configure_hermes.py`
- **explicit_desktop_references()** (4 connections) — `Qwen Spark Migration/configure_hermes.py`
- **qwen_desktop()** (4 connections) — `Qwen Spark Migration/configure_hermes.py`
- **transform()** (4 connections) — `Qwen Spark Migration/configure_hermes.py`
- **atomic_write()** (3 connections) — `Qwen Spark Migration/configure_hermes.py`
- **digest()** (3 connections) — `Qwen Spark Migration/configure_hermes.py`
- **endpoint()** (3 connections) — `Qwen Spark Migration/configure_hermes_native.py`
- **lmstudio_references()** (3 connections) — `Qwen Spark Migration/configure_hermes_native.py`
- **main()** (3 connections) — `Qwen Spark Migration/configure_hermes_native.py`
- **yaml_codec()** (3 connections) — `Qwen Spark Migration/configure_hermes.py`
- **inside()** (2 connections) — `Qwen Spark Migration/configure_hermes.py`
- **dump()** (2 connections) — `Qwen Spark Migration/configure_hermes.py`
- **FirstSpark-only native llama.cpp provider migration; dry-run by default. Keep…** (1 connections) — `Qwen Spark Migration/configure_hermes_native.py`
- **Preview/apply a bounded Hermes provider migration; never contacts a model…** (1 connections) — `Qwen Spark Migration/configure_hermes.py`

## Relationships

- [Migration Test Fixtures](Migration_Test_Fixtures.md) (6 shared connections)
- [Desktop Qwen Publish & GLM Shim](Desktop_Qwen_Publish_&_GLM_Shim.md) (4 shared connections)
- [Qwen 3.8 27B Migration & Fresh Brief](Qwen_3.8_27B_Migration_&_Fresh_Brief.md) (4 shared connections)
- [Native Qwen Runner & Memory Diagnose](Native_Qwen_Runner_&_Memory_Diagnose.md) (3 shared connections)
- [Native Download & Hermes Probes](Native_Download_&_Hermes_Probes.md) (2 shared connections)

## Source Files

- `Qwen Spark Migration/configure_hermes.py`
- `Qwen Spark Migration/configure_hermes_native.py`

## Audit Trail

- EXTRACTED: 53 (96%)
- INFERRED: 2 (4%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [index](index.md) to navigate.*