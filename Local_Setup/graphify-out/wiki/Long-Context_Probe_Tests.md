# Long-Context Probe Tests

> 23 nodes · cohesion 0.12

## Key Concepts

- **.run_fake()** (19 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **ProbeTests** (13 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_four_100k_requests_keep_four_independent_262k_slots()** (2 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_four_240k_is_accepted_only_with_full_independent_capacity()** (2 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_hard_floor_interrupts_silent_prefill_socket()** (2 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_sustained_swap_interrupts_silent_prefill_socket()** (2 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_target_is_failed_gate_without_hard_abort()** (2 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_two_240k_requests_still_verify_four_server_slots()** (2 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_unified_option_retains_two_240k_shared_pool_qualification()** (2 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_wrong_cache_type_or_shared_override_prevents_inference()** (2 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **close()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **connect()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **__enter__()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **__exit__()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **getresponse()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **__init__()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **memory()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **readline()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **request()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **slots()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_flags_do_not_capture_credentials_or_unrelated_arguments()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_four_240k_shared_pool_is_rejected_before_metadata()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`
- **.test_separate_capacity_cannot_be_silently_reduced()** (1 connections) — `Qwen Spark Migration/test_probe_qwen_long.py`

## Relationships

- [Migration Test Fixtures](Migration_Test_Fixtures.md) (1 shared connections)

## Source Files

- `Qwen Spark Migration/test_probe_qwen_long.py`

## Audit Trail

- EXTRACTED: 29 (94%)
- INFERRED: 2 (6%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [index](index.md) to navigate.*