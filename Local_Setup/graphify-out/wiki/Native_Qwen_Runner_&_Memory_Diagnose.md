# Native Qwen Runner & Memory Diagnose

> 24 nodes · cohesion 0.16

## Key Concepts

- **os** (36 connections)
- **run_native_qwen.py** (22 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **patch_hermes_timeouts.py** (17 connections) — `Qwen Spark Migration/patch_hermes_timeouts.py`
- **diagnose_native_memory.py** (12 connections) — `Qwen Spark Migration/diagnose_native_memory.py`
- **socket** (12 connections)
- **main()** (8 connections) — `Qwen Spark Migration/patch_hermes_timeouts.py`
- **main()** (8 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **validate_artifacts()** (6 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **command()** (5 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **atomic()** (4 connections) — `Qwen Spark Migration/patch_hermes_timeouts.py`
- **wait_for_memory()** (4 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **ast** (3 connections)
- **digest()** (3 connections) — `Qwen Spark Migration/patch_hermes_timeouts.py`
- **transform()** (3 connections) — `Qwen Spark Migration/patch_hermes_timeouts.py`
- **check_co_residents()** (3 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **dflash_model_metadata()** (3 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **target_model_metadata()** (3 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **available()** (1 connections) — `Qwen Spark Migration/diagnose_native_memory.py`
- **Bounded local allocation trace; no inference, routing changes or downloads.** (1 connections) — `Qwen Spark Migration/diagnose_native_memory.py`
- **Preview/apply/rollback the named-custom timeout fix on FirstSpark only. Backs…** (1 connections) — `Qwen Spark Migration/patch_hermes_timeouts.py`
- **memory_available_gib()** (1 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **Start the pinned Spark worker from an explicit configuration; never downloads.** (1 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **Require completed download receipts; never fetch or replace weights.** (1 connections) — `Qwen Spark Migration/run_native_qwen.py`
- **Wait for boot/restart pressure to settle without lowering the load guard. A…** (1 connections) — `Qwen Spark Migration/run_native_qwen.py`

## Relationships

- [Native Download & Hermes Probes](Native_Download_&_Hermes_Probes.md) (16 shared connections)
- [Migration Test Fixtures](Migration_Test_Fixtures.md) (13 shared connections)
- [Desktop Qwen Publish & GLM Shim](Desktop_Qwen_Publish_&_GLM_Shim.md) (6 shared connections)
- [Native Qwen Qualification Probes](Native_Qwen_Qualification_Probes.md) (6 shared connections)
- [Qwen 3.8 27B Migration & Fresh Brief](Qwen_3.8_27B_Migration_&_Fresh_Brief.md) (6 shared connections)
- [Parallel Pinned Downloads](Parallel_Pinned_Downloads.md) (5 shared connections)
- [Interactive Speed & Restart Probes](Interactive_Speed_&_Restart_Probes.md) (5 shared connections)
- [Hermes Provider Migration Scripts](Hermes_Provider_Migration_Scripts.md) (3 shared connections)
- [Reviewed Native Continuation](Reviewed_Native_Continuation.md) (2 shared connections)
- [spark-frontier-check Script](spark-frontier-check_Script.md) (2 shared connections)
- [Dashboard Preview Server](Dashboard_Preview_Server.md) (2 shared connections)
- [Native Install Finisher](Native_Install_Finisher.md) (2 shared connections)

## Source Files

- `Qwen Spark Migration/diagnose_native_memory.py`
- `Qwen Spark Migration/patch_hermes_timeouts.py`
- `Qwen Spark Migration/run_native_qwen.py`

## Audit Trail

- EXTRACTED: 114 (99%)
- INFERRED: 1 (1%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [index](index.md) to navigate.*