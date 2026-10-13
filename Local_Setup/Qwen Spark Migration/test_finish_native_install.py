"""No services or inference: regression fixtures for the systemctl GC seam."""
import importlib.util
from pathlib import Path
import subprocess
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('installer', Path(__file__).with_name('finish_native_install.py'))
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class ResetStartLimitsTests(unittest.TestCase):
    def setUp(self):
        installer.abort.clear()

    def run_fixture(self, state='loaded', active='inactive', other_error=None, fail_show=False):
        calls = []

        def fake_systemctl(command, **kwargs):
            calls.append(command)
            self.assertEqual(kwargs['env']['LC_ALL'], 'C')
            if command[2] == 'reset-failed':
                unit = command[3]
                error = other_error or f'Failed to reset failed state of unit {unit}: Unit {unit} not loaded.\n'
                return subprocess.CompletedProcess(command, 1, '', error)
            self.assertEqual(command[2], 'show')
            self.assertTrue(kwargs['check'])
            if fail_show:
                raise subprocess.CalledProcessError(1, command)
            return subprocess.CompletedProcess(command, 0, f'LoadState={state}\nActiveState={active}\n', '')

        with patch.object(installer.subprocess, 'run', side_effect=fake_systemctl):
            installer.reset_worker_start_limits()
        return calls

    def test_collected_valid_inactive_units_can_proceed(self):
        calls = self.run_fixture()
        self.assertEqual([call[2] for call in calls], ['reset-failed', 'show'] * 2)
        self.assertEqual([call[3] for call in calls[::2]], [installer.NATIVE, installer.PROXY])

    def test_successful_reset_does_not_query(self):
        with patch.object(installer.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, '', '')) as run:
            installer.reset_worker_start_limits()
        self.assertEqual(run.call_count, 2)

    def test_missing_masked_bad_or_active_units_are_not_ignored(self):
        for state, active in [('not-found', 'inactive'), ('masked', 'inactive'),
                              ('bad-setting', 'inactive'), ('loaded', 'active'), ('loaded', 'failed')]:
            with self.subTest(state=state, active=active), self.assertRaises(RuntimeError):
                self.run_fixture(state=state, active=active)

    def test_permission_and_show_errors_are_not_ignored(self):
        with self.assertRaises(subprocess.CalledProcessError):
            self.run_fixture(other_error='Failed to connect to bus: Permission denied')
        with self.assertRaises(subprocess.CalledProcessError):
            self.run_fixture(fail_show=True)

    def test_real_start_errors_still_propagate(self):
        with patch.object(installer.subprocess, 'run', side_effect=subprocess.CalledProcessError(1, ['systemctl'])), self.assertRaises(subprocess.CalledProcessError):
            installer.systemctl('start', installer.NATIVE, installer.PROXY)


if __name__ == '__main__':
    unittest.main()
