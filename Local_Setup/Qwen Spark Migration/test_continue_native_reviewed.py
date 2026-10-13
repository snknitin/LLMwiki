"""No services, network, inference or real-home access."""
import copy
import io
import json
from pathlib import Path
import tempfile
import threading
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

import continue_native_reviewed as task


def sample(seconds, **changes):
    row = {'time': seconds, 'MemAvailable': 14 * 1024**2, 'pswpout': 10, 'pswpin': 0,
           'worker_vmswap_kib': 0, 'global_oom_kill': 0, 'cgroup_oom': 0, 'cgroup_oom_kill': 0,
           'psi_full_total_us': 0, 'cgroup_psi_full_total_us': 0,
           'worker_start_ticks': 10, 'worker_cgroup': '/test/native'}
    return {**row, **changes}


class PressureTests(unittest.TestCase):
    def test_sparkfast_completion_is_bounded_and_requires_visible_output(self):
        def response(value):
            handle = io.BytesIO(json.dumps(value).encode())
            handle.status = 200
            return handle
        for content, succeeds in [('OK', True), ('OK.', True), ('', False)]:
            responses = [response({}), response({'data': [{'id': 'spark-fast-test'}]}),
                         response({'choices': [{'finish_reason': 'stop', 'message': {'content': content}}]})]
            with self.subTest(content=content), patch.object(task.urllib.request, 'urlopen', side_effect=responses) as call:
                if succeeds:
                    self.assertTrue(task.spark_fast_responsiveness()['passed'])
                else:
                    with self.assertRaisesRegex(RuntimeError, 'no visible content'):
                        task.spark_fast_responsiveness()
                request = call.call_args_list[2].args[0]
                self.assertEqual(json.loads(request.data)['max_tokens'], 16)
                self.assertEqual(json.loads(request.data)['chat_template_kwargs'], {'enable_thinking': False})
                self.assertEqual(call.call_args_list[2].kwargs['timeout'], 60)

    def test_sparkfast_failure_saves_sanitized_reasoning_diagnostics(self):
        def response(value):
            handle = io.BytesIO(json.dumps(value).encode()); handle.status = 200
            return handle
        replies = [response({}), response({'data': [{'id': 'test'}]}), response({'choices': [{
            'finish_reason': 'length', 'message': {'content': '', 'reasoning_content': 'private-reasoning'}}]})]
        with tempfile.TemporaryDirectory() as directory, patch.object(task.urllib.request, 'urlopen', side_effect=replies):
            receipt = Path(directory) / 'sparkfast.json'
            with self.assertRaisesRegex(RuntimeError, 'no visible content'):
                task.spark_fast_responsiveness(receipt)
            saved = json.loads(receipt.read_text())
            self.assertFalse(saved['passed'])
            self.assertEqual(saved['finish_reason'], 'length')
            self.assertEqual(saved['reasoning_characters'], len('private-reasoning'))
            self.assertNotIn('private-reasoning', receipt.read_text())

    def test_tiny_global_pageout_alone_is_diagnostic(self):
        self.assertEqual(task.pressure_failures([sample(0), sample(61, pswpout=54)], final=True), [])

    def test_each_pressure_and_identity_failure(self):
        for change in ({'MemAvailable': 11 * 1024**2}, {'worker_vmswap_kib': 4},
                       {'global_oom_kill': 1}, {'cgroup_oom': 1}, {'cgroup_oom_kill': 1},
                       {'worker_start_ticks': 11}, {'worker_cgroup': '/another'},
                       {'psi_full_total_us': 700000}, {'cgroup_psi_full_total_us': 700000}):
            with self.subTest(change=change):
                self.assertTrue(task.pressure_failures([sample(0), sample(61, **change)], final=True))

    def test_sustained_pageout_aborts_but_short_burst_does_not(self):
        rows = [sample(i, pswpout=10 + i * 2048) for i in range(6)]
        self.assertTrue(task.pressure_failures(rows))
        self.assertEqual(task.pressure_failures(rows[:5]), [])

    def test_missing_telemetry_and_short_observation_refused(self):
        self.assertTrue(task.pressure_failures([]))
        self.assertTrue(task.pressure_failures([sample(0), sample(59)], final=True))
        broken = sample(61)
        del broken['worker_vmswap_kib']
        with self.assertRaises(KeyError):
            task.pressure_failures([sample(0), broken])

    def test_missing_live_telemetry_aborts_before_work_and_saves_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            aborted = threading.Event()
            def check_abort():
                if aborted.is_set():
                    raise RuntimeError('aborted')
            module = SimpleNamespace(NATIVE='test.service', RUNS=Path(directory),
                                     abort=aborted, check_abort=check_abort, status=Mock())
            run = Mock()
            with patch.object(task.subprocess, 'check_output', return_value='123'), \
                    patch.object(task.os, 'sysconf', return_value=4096, create=True), \
                    patch.object(task, 'telemetry', side_effect=KeyError('VmSwap')):
                with self.assertRaisesRegex(RuntimeError, 'aborted'):
                    task.pressure_wrapped_run(module, run, ['unused'], 'hermes-four')
            run.assert_not_called()
            self.assertTrue(aborted.is_set())
            report = json.loads((Path(directory) / 'reviewed-pressure-qualification.json').read_text())
            self.assertFalse(report['passed'])
            self.assertTrue(any('telemetry' in reason for reason in report['failures']))


class ReuseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.old, self.here = self.root / 'old', self.root / 'current'
        self.old.mkdir(); self.here.mkdir()
        config = b'{"speculation":"none"}\n'
        (self.old / 'native-config-initial.json').write_bytes(config)
        (self.here / 'native-config.json').write_bytes(config)
        (self.old / 'accelerator-decision.json').write_text('{"accelerator":"none"}')
        self.receipt = {'passed': True, 'response_gate_passed': True, 'memory_gate_passed': True,
                        'observed_concurrency_gate_passed': True, 'aggregate_token_gate_passed': True,
                        'model': 'qwen38-27b-spark', 'requested_context': 262144,
                        'minimum_required_prompt_tokens_per_request': 100000, 'parallel_requests': 4,
                        'configured_slots': 4, 'memory_floor_gib': 12, 'hard_abort_memory_gib': 8,
                        'kv_mode': 'separate', 'cache_k': 'q4_0', 'cache_v': 'q4_0',
                        'total_kv_capacity_tokens': 1048576, 'independent_slot_capacity_tokens': 262144,
                        'maximum_observed_busy_slots': 4, 'swap_out_pages_delta': 0,
                        'minimum_mem_available_gib': 14, 'memory_floor_breached': False,
                        'cancellation_reasons': [], 'runtime_flags': {'--spec-type': 'none'},
                        'memory_samples': [sample(0), sample(61)],
                        'requests': [{'passed': True, 'finish_reason': 'stop', 'safety_cancellation_observed': False,
                                      'usage': {'prompt_tokens': 100100, 'completion_tokens': 200}} for _ in range(4)]}
        hundred = json.dumps(self.receipt).encode()
        (self.old / 'long-none-four-100k.json').write_bytes(hundred)
        twoforty = copy.deepcopy(self.receipt)
        twoforty.update(passed=False, memory_gate_passed=False, minimum_mem_available_gib=13.747,
                       swap_out_pages_delta=44, minimum_required_prompt_tokens_per_request=240000)
        for row in twoforty['requests']:
            row['usage']['prompt_tokens'] = 240100
        self.twoforty_raw = json.dumps(twoforty).encode()
        self.path240 = self.old / 'long-none-four-240k.json'
        self.path240.write_bytes(self.twoforty_raw)
        review = {'receipt': {'path': str(self.path240), 'sha256': task.digest(self.twoforty_raw)},
                  'decision': {'original_strict_zero_gate': 'FAIL_RETAINED'},
                  'preregistered_followup': {'memory_target_gib': 12, 'emergency_floor_gib': 8,
                    'worker_vmswap_max_kib': 0, 'oom_kill_delta_max': 0,
                    'memory_psi_full_stall_fraction_max': 0.01,
                    'sustained_swap_out_mib_per_second': 8, 'sustained_swap_seconds': 5}}
        raw_review = json.dumps(review).encode()
        (self.here / task.REVIEW_NAME).write_bytes(raw_review)
        self.review_hash = task.digest(raw_review)
        for name, value in [('RECEIPT_SHA', task.digest(hundred)), ('CONFIG_SHA', task.digest(config))]:
            scope = patch.object(task, name, value)
            scope.start(); self.addCleanup(scope.stop)

    def validate(self):
        return task.reviewed_evidence(self.here, self.old, self.review_hash)

    def test_review_reuse_retains_original_failed_receipt(self):
        files, receipt = self.validate()
        self.assertFalse(json.loads(files['240k'])['passed'])
        self.assertEqual(receipt['original_strict_zero_swap_gate'], 'FAIL_RETAINED')
        self.assertEqual(self.path240.read_bytes(), self.twoforty_raw)

    def test_changed_config_refused(self):
        (self.here / 'native-config.json').write_text('{"speculation":"draft-mtp"}')
        with self.assertRaisesRegex(RuntimeError, 'byte-for-byte'):
            self.validate()

    def test_changed_receipt_refused(self):
        self.path240.write_bytes(self.twoforty_raw + b' ')
        with self.assertRaisesRegex(RuntimeError, 'changed after review'):
            self.validate()

    def test_changed_review_refused(self):
        (self.here / task.REVIEW_NAME).write_text('{}')
        with self.assertRaisesRegex(RuntimeError, 'review receipt hash'):
            self.validate()

    def test_bad100k_gate_refused_even_with_matching_hash(self):
        self.receipt['memory_gate_passed'] = False
        raw = json.dumps(self.receipt).encode()
        (self.old / 'long-none-four-100k.json').write_bytes(raw)
        with patch.object(task, 'RECEIPT_SHA', task.digest(raw)):
            with self.assertRaisesRegex(RuntimeError, 'memory_gate_passed'):
                self.validate()


if __name__ == '__main__':
    unittest.main()
