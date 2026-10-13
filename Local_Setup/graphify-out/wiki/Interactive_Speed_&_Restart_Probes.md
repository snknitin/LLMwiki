# Interactive Speed & Restart Probes

> 14 nodes · cohesion 0.19

## Key Concepts

- **time** (28 connections)
- **probe_qwen.py** (12 connections) — `Qwen Spark Migration/probe_qwen.py`
- **urllib_request** (12 connections)
- **measure_interactive_speed.py** (9 connections) — `Qwen Spark Migration/measure_interactive_speed.py`
- **main()** (8 connections) — `Qwen Spark Migration/probe_qwen.py`
- **read_hermes_restart_evidence.py** (8 connections) — `Qwen Spark Migration/read_hermes_restart_evidence.py`
- **concurrent_futures** (5 connections)
- **measure()** (3 connections) — `Qwen Spark Migration/measure_interactive_speed.py`
- **one()** (2 connections) — `Qwen Spark Migration/probe_qwen.py`
- **post()** (2 connections) — `Qwen Spark Migration/probe_qwen.py`
- **Bounded, identical streaming probes; does not alter production settings.** (1 connections) — `Qwen Spark Migration/measure_interactive_speed.py`
- **memory()** (1 connections) — `Qwen Spark Migration/probe_qwen.py`
- **Bounded OpenAI API checks; never loads a cold alias deliberately or changes…** (1 connections) — `Qwen Spark Migration/probe_qwen.py`
- **Read-only restart evidence; emits counts and process identities, never chat…** (1 connections) — `Qwen Spark Migration/read_hermes_restart_evidence.py`

## Relationships

- [Native Download & Hermes Probes](Native_Download_&_Hermes_Probes.md) (8 shared connections)
- [Parallel Pinned Downloads](Parallel_Pinned_Downloads.md) (7 shared connections)
- [Native Qwen Qualification Probes](Native_Qwen_Qualification_Probes.md) (7 shared connections)
- [Frontier Model Probe Script](Frontier_Model_Probe_Script.md) (7 shared connections)
- [Migration Test Fixtures](Migration_Test_Fixtures.md) (5 shared connections)
- [Qwen 3.8 27B Migration & Fresh Brief](Qwen_3.8_27B_Migration_&_Fresh_Brief.md) (5 shared connections)
- [Native Qwen Runner & Memory Diagnose](Native_Qwen_Runner_&_Memory_Diagnose.md) (5 shared connections)
- [Reviewed Native Continuation](Reviewed_Native_Continuation.md) (5 shared connections)
- [Desktop Qwen Publish & GLM Shim](Desktop_Qwen_Publish_&_GLM_Shim.md) (3 shared connections)
- [spark-frontier-check Script](spark-frontier-check_Script.md) (3 shared connections)
- [Native Install Finisher](Native_Install_Finisher.md) (2 shared connections)
- [Dashboard Preview Server](Dashboard_Preview_Server.md) (1 shared connections)

## Source Files

- `Qwen Spark Migration/measure_interactive_speed.py`
- `Qwen Spark Migration/probe_qwen.py`
- `Qwen Spark Migration/read_hermes_restart_evidence.py`

## Audit Trail

- EXTRACTED: 73 (96%)
- INFERRED: 3 (4%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [index](index.md) to navigate.*