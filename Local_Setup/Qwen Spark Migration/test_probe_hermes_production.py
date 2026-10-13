"""Request-shape fixtures only; never runs an agent or inference."""
import unittest
import argparse
import contextlib
import io
import json
import os
from pathlib import Path
import tempfile
from types import ModuleType
from unittest.mock import patch, Mock
import probe_hermes_production as probe


class ProductionWireTests(unittest.TestCase):
    def test_both_socket_methods_allow_only_native_during_inference(self):
        for name in ('socket.connect', 'socket.connect_ex'):
            with self.subTest(method=name):
                connector = Mock(return_value=0)
                failures = []
                guarded = probe.guard_socket_connector(connector, True, failures, name)
                sock = object()
                self.assertEqual(guarded(sock, ('127.0.0.1', 1235)), 0)
                connector.assert_called_once_with(sock, ('127.0.0.1', 1235))
                for address in (('127.0.0.1', 8000), ('100.94.199.98', 1235), '/tmp/socket'):
                    with self.assertRaises(OSError): guarded(sock, address)
                self.assertEqual(connector.call_count, 1)
                with self.assertRaises(OSError):
                    probe.guard_socket_connector(connector, False, failures, name)(sock, ('127.0.0.1', 1235))
                self.assertEqual(connector.call_count, 1)

    def test_child_uses_selected_runtime_not_calling_python(self):
        environments = ModuleType('pm.environments')
        environments.selected_venv = Mock(return_value=Path('/selected/python314'))
        environments.venv_command = Mock(return_value=['/store/python314', '-S', '/entry.py', '/selected/site-packages'])
        with patch.dict('sys.modules', {'pm.environments': environments}), patch.dict(os.environ), patch('sys.path', []):
            command = probe.production_python_command()
            self.assertEqual(command[0], '/store/python314')
            self.assertEqual(os.environ['HERMES_DISABLE_LAZY_INSTALLS'], '1')
        environments.venv_command.assert_called_once_with(probe.SOURCE, Path('/selected/python314'))

    def test_uncapped_no_tools_native_request(self):
        self.assertIsNone(probe.validate_payload(probe.BASE+'/chat/completions', {'model':probe.MODEL})['output_token_cap'])

    def test_caps_tools_and_fallback_model_rejected(self):
        for fields in ({'max_tokens':8192}, {'max_completion_tokens':8192}, {'tools':[{}]}, {'model':'spark-fast'}):
            with self.subTest(fields=fields), self.assertRaises(AssertionError):
                probe.validate_payload(probe.BASE+'/chat/completions', {'model':probe.MODEL, **fields})

    def test_other_endpoint_rejected(self):
        with self.assertRaises(AssertionError):
            probe.validate_payload('http://127.0.0.1:8000/v1/chat/completions', {'model':probe.MODEL})

    @unittest.skipUnless(hasattr(os, 'fchmod'), 'FirstSpark POSIX permission test')
    def test_failure_log_private_and_content_not_printed(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'receipt.json'
            log = io.StringIO('Traceback (most recent call last):\nAssertionError: SYNTHETIC_PRIVATE_DETAIL\n')
            printed = io.StringIO()
            with contextlib.redirect_stdout(printed):
                probe.save_failure(log, argparse.Namespace(output=str(output)), 1, 'fixture_failure')
            receipt = json.loads(output.read_text())
            saved = Path(receipt['private_diagnostic_log'])
            self.assertEqual(saved.stat().st_mode & 0o777, 0o600)
            self.assertIn('SYNTHETIC_PRIVATE_DETAIL', saved.read_text())
            self.assertNotIn('SYNTHETIC_PRIVATE_DETAIL', printed.getvalue())
            self.assertEqual(receipt['child_exception_type'], 'AssertionError')


if __name__ == '__main__': unittest.main()
