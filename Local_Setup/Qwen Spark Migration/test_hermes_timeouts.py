"""Pure config fixtures for the patch; no network, agents or service access."""
import importlib.util
import ast
from pathlib import Path
import sys
import types
import unittest
from unittest.mock import patch
import patch_hermes_timeouts as patcher


class TimeoutTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        source = (patcher.ROOT / 'hermes_cli/timeouts.py').read_text()
        if 'def _route_timeout(' not in source:
            source = patcher.transform('hermes_cli/timeouts.py', source)
        cls.helper = types.ModuleType('timeout_fixture')
        exec(compile(source, '<timeout_fixture>', 'exec'), cls.helper.__dict__)

    def setUp(self):
        self.config = {'providers': {
            'spark-qwen38': {'request_timeout_seconds': 7200, 'stale_timeout_seconds': 7200,
                            'models': {'special': {'timeout_seconds': 111, 'stale_timeout_seconds': 222}}},
            'spark-fast': {'request_timeout_seconds': 45, 'stale_timeout_seconds': 60},
            'custom': {'request_timeout_seconds': 80}}}
        module = types.ModuleType('hermes_cli.config')
        module.load_config_readonly = lambda: self.config
        self.scope = patch.dict(sys.modules, {'hermes_cli.config': module})
        self.scope.start(); self.addCleanup(self.scope.stop)

    def test_named_custom_native(self):
        for fn in (self.helper.get_provider_request_timeout, self.helper.get_provider_stale_timeout):
            self.assertEqual(fn('custom', 'qwen38-27b-spark', requested_provider='custom:spark-qwen38'), 7200)

    def test_per_model_precedence(self):
        self.assertEqual(self.helper.get_provider_request_timeout('custom', 'special', requested_provider='custom:spark-qwen38'), 111)
        self.assertEqual(self.helper.get_provider_stale_timeout('custom', 'special', requested_provider='custom:spark-qwen38'), 222)

    def test_other_provider_unchanged(self):
        self.assertEqual(self.helper.get_provider_request_timeout('spark-fast', requested_provider='custom:spark-qwen38'), 45)
        self.assertEqual(self.helper.get_provider_stale_timeout('spark-fast'), 60)

    def test_bare_custom_and_absent_defaults_unchanged(self):
        self.assertEqual(self.helper.get_provider_request_timeout('custom'), 80)
        self.assertIsNone(self.helper.get_provider_request_timeout('absent'))
        self.assertIsNone(self.helper.get_provider_stale_timeout('custom'))

    def test_invalid_setting_stays_unset(self):
        self.config['providers']['spark-qwen38']['request_timeout_seconds'] = -1
        self.assertEqual(self.helper.get_provider_request_timeout('custom', requested_provider='custom:spark-qwen38'), 80)

    def test_named_without_override_preserves_generic_custom(self):
        self.config['providers']['other-local'] = {'models': {}}
        self.assertEqual(self.helper.get_provider_request_timeout('custom', requested_provider='custom:other-local'), 80)
        self.assertIsNone(self.helper.get_provider_stale_timeout('custom', requested_provider='custom:other-local'))

    def test_all_seven_runtime_calls_pass_route_identity(self):
        count = 0
        for relative in patcher.FILES[1:]:
            source = (patcher.ROOT / relative).read_text()
            if 'requested_provider=getattr(' not in source:
                source = patcher.transform(relative, source)
            for node in ast.walk(ast.parse(source)):
                if (isinstance(node, ast.Call) and isinstance(node.func, ast.Name)
                        and node.func.id in ('get_provider_request_timeout', 'get_provider_stale_timeout')):
                    self.assertIn('requested_provider', [key.arg for key in node.keywords])
                    count += 1
        self.assertEqual(count, 7)


if __name__ == '__main__': unittest.main()
