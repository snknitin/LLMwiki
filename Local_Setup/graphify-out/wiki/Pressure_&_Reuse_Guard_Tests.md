# Pressure & Reuse Guard Tests

> 20 nodes · cohesion 0.14

## Key Concepts

- **PressureTests** (8 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **ReuseTests** (8 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.validate()** (6 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **sample()** (6 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_each_pressure_and_identity_failure()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_missing_live_telemetry_aborts_before_work_and_saves_failure()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_missing_telemetry_and_short_observation_refused()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_sparkfast_completion_is_bounded_and_requires_visible_output()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_sparkfast_failure_saves_sanitized_reasoning_diagnostics()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_sustained_pageout_aborts_but_short_burst_does_not()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_tiny_global_pageout_alone_is_diagnostic()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.setUp()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_bad100k_gate_refused_even_with_matching_hash()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_changed_config_refused()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_changed_receipt_refused()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_changed_review_refused()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **.test_review_reuse_retains_original_failed_receipt()** (2 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **check_abort()** (1 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **response()** (1 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`
- **response()** (1 connections) — `Qwen Spark Migration/test_continue_native_reviewed.py`

## Relationships

- [Migration Test Fixtures](Migration_Test_Fixtures.md) (3 shared connections)

## Source Files

- `Qwen Spark Migration/test_continue_native_reviewed.py`

## Audit Trail

- EXTRACTED: 29 (97%)
- INFERRED: 1 (3%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [index](index.md) to navigate.*