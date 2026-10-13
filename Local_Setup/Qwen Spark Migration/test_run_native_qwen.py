"""Memory-readiness fixtures; never touch a model, GPU, service or real clock."""
import contextlib
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import run_native_qwen as worker


class Clock:
    def __init__(self):
        self.now = 0

    def time(self):
        return self.now

    def sleep(self, seconds):
        self.now += seconds


class MemoryReadinessTests(unittest.TestCase):
    def run_wait(self, readings, **kwargs):
        clock = Clock()
        values = iter(readings)
        with contextlib.redirect_stdout(io.StringIO()):
            result = worker.wait_for_memory(52, read_available=lambda: next(values),
                clock=clock.time, sleep=clock.sleep, **kwargs)
        return result, clock.now

    def test_three_stable_samples_required_even_when_initially_ready(self):
        self.assertEqual(self.run_wait([52, 52.5, 53]), (53, 10))

    def test_pressure_resets_stability_then_recovers(self):
        self.assertEqual(self.run_wait([51, 53, 51.9, 54, 54, 54]), (54, 25))

    def test_timeout_is_bounded_and_guard_never_relaxed(self):
        clock = Clock()
        samples = []

        def below_guard():
            samples.append(clock.now)
            return 51.99

        with contextlib.redirect_stdout(io.StringIO()), self.assertRaisesRegex(SystemExit, 'within 660s'):
            worker.wait_for_memory(52, read_available=below_guard,
                clock=clock.time, sleep=clock.sleep)
        self.assertEqual(clock.now, 660)
        self.assertEqual(len(samples), 133)
        self.assertGreater(clock.now, 600)

    def test_last_single_ready_sample_does_not_defeat_timeout(self):
        with self.assertRaisesRegex(SystemExit, 'did not remain'):
            self.run_wait([51, 51, 53], timeout=10)

    def test_proc_memavailable_units(self):
        with patch.object(worker.Path, 'read_text', return_value='MemTotal: 123 kB\nMemAvailable: 54525952 kB\n'):
            self.assertEqual(worker.memory_available_gib(), 52)


class DraftConfigurationTests(unittest.TestCase):
    def config(self):
        c = json.loads(Path(__file__).with_name('native-config.json').read_text())
        c.update(parallel=4, total_context=1048576, draft_p_min=0.0,
                 speculation='draft-dflash', draft_max=7, draft_model='/models/'+worker.DFLASH_FILENAME,
                 draft_model_sha256=worker.DFLASH_SHA256, draft_revision=worker.DFLASH_REVISION)
        return c

    def test_dflash_adds_only_matched_draft_and_preserves_target_capacity(self):
        c = self.config()
        args = worker.command(c)
        for flag, value in (('--model', c['model']), ('--ctx-size', '1048576'),
                            ('--parallel', '4'), ('--cache-type-k', 'q4_0'),
                            ('--cache-type-v', 'q4_0'), ('--spec-draft-model', c['draft_model']),
                            ('--spec-draft-n-max', '7'), ('--spec-draft-ngl', 'all'),
                            ('--spec-draft-type-k', 'q8_0'), ('--spec-draft-type-v', 'q8_0'),
                            ('--spec-draft-p-min', '0.0'),
                            ('--flash-attn', 'on')):
            self.assertEqual(args[args.index(flag)+1], value)
        self.assertIn('--no-kv-unified', args)
        c['draft_max'] = 3
        args = worker.command(c)
        self.assertEqual(args[args.index('--spec-draft-n-max')+1], '3')

    def test_unpinned_targets_drafts_modes_and_capacity_rejected(self):
        for update in ({'model_sha256': 'bad'}, {'model_size': 123}, {'draft_model_sha256': 'bad'},
                       {'draft_revision': 'main'}, {'draft_max': 8}, {'draft_model': ''},
                       {'speculation': 'draft-simple'}, {'parallel': 3},
                       {'parallel': 2, 'total_context': 1048576}, {'cache_v': 'q8_0'},
                       {'draft_p_min': 0.4}):
            with self.subTest(update=update), self.assertRaises(ValueError):
                worker.command({**self.config(), **update})

    def test_none_never_loads_configured_draft(self):
        c = self.config(); c['speculation'] = 'none'
        self.assertNotIn('--spec-draft-model', worker.command(c))

    def test_pinned_q4_target_retains_four_full_contexts(self):
        c = self.config()
        digest = '3f227079003add2511437e5b1e94812e363385225bf6a9b47b0054a72bc8b01e'
        c.update(model='/models/Qwen3.8-27B-UD-Q4_K_XL.gguf', model_sha256=digest,
                 model_size=17559178144)
        args = worker.command(c)
        self.assertEqual(args[args.index('--ctx-size')+1], '1048576')
        self.assertEqual(args[args.index('--parallel')+1], '4')
        c['model_sha256'] = '8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276'
        with self.assertRaises(ValueError): worker.command(c)

    def test_pinned_ggml_q4_target_and_dflash7(self):
        c = self.config()
        digest = 'c600de0300ae8a0eb3a6c0b8b5561b8b96f16bd2c863c2a66c42de29d391a747'
        c.update(model='/models/Qwen3.8-27B-Q4_K_M.gguf', model_sha256=digest,
                 model_size=18973870528, draft_max=7)
        args = worker.command(c)
        self.assertEqual(args[args.index('--model')+1], c['model'])
        self.assertEqual(args[args.index('--spec-type')+1], 'draft-dflash')
        self.assertEqual(args[args.index('--spec-draft-n-max')+1], '7')

    def test_prompt_lookup_can_stack_with_pinned_dflash(self):
        c = self.config()
        c.update(speculation='ngram-mod,draft-dflash', draft_max=7)
        args = worker.command(c)
        self.assertEqual(args[args.index('--spec-type')+1], 'ngram-mod,draft-dflash')
        self.assertEqual(args[args.index('--spec-draft-n-max')+1], '7')

    def test_pinned_q8_dflash_assistant(self):
        c = self.config()
        c.update(
            draft_model='/models/dflash-Qwen3.8-27B-Q8_0.gguf',
            draft_model_sha256=worker.DFLASH_Q8_SHA256,
            draft_max=7,
        )
        args = worker.command(c)
        self.assertEqual(args[args.index('--spec-draft-model')+1], c['draft_model'])

    def test_pinned_bf16_dflash_assistant(self):
        c = self.config()
        c.update(
            draft_model='/models/dflash-Qwen3.8-27B-BF16.gguf',
            draft_model_sha256=worker.DFLASH_BF16_SHA256,
            draft_max=7,
        )
        args = worker.command(c)
        self.assertEqual(args[args.index('--spec-draft-model')+1], c['draft_model'])

    def test_two_full_context_slots_for_fast_profile(self):
        c = self.config()
        c.update(parallel=2, total_context=524288)
        args = worker.command(c)
        self.assertEqual(args[args.index('--ctx-size')+1], '524288')
        self.assertEqual(args[args.index('--parallel')+1], '2')

    def test_qualified_dflash_confidence_cutoff(self):
        c = self.config()
        c['draft_p_min'] = 0.2
        args = worker.command(c)
        self.assertEqual(args[args.index('--spec-draft-p-min')+1], '0.2')

    def test_ggml_q4_requires_pinned_external_mtp(self):
        c = self.config()
        c.update(
            model='/models/Qwen3.8-27B-Q4_K_M.gguf',
            model_sha256='c600de0300ae8a0eb3a6c0b8b5561b8b96f16bd2c863c2a66c42de29d391a747',
            model_size=18973870528,
            speculation='draft-mtp',
            draft_max=2,
            draft_model='/models/mtp-Qwen3.8-27B-Q4_0.gguf',
            draft_model_sha256=worker.MTP_SHA256,
            draft_revision=worker.GGML_REVISION,
        )
        args = worker.command(c)
        self.assertEqual(args[args.index('--spec-draft-model')+1], c['draft_model'])
        self.assertEqual(args[args.index('--spec-draft-ngl')+1], 'all')
        self.assertEqual(args[args.index('--spec-draft-n-max')+1], '2')
        for update in ({'draft_model': ''}, {'draft_model_sha256': 'bad'},
                       {'draft_revision': 'main'}):
            with self.subTest(update=update), self.assertRaises(ValueError):
                worker.command({**c, **update})

    def test_artifact_receipt_missing_file_hash_and_size_guards(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            c = self.config()
            target = root / Path(c['model']).name
            draft = root / worker.DFLASH_FILENAME
            binary = root / 'llama-server'
            c.update(model=str(target), draft_model=str(draft), binary=str(binary))
            target.write_bytes(b'x'); binary.write_bytes(b'x')
            receipt = root / 'verified-sha256.json'
            receipt.write_text(json.dumps({target.name: c['model_sha256'], draft.name: worker.DFLASH_SHA256}))
            sizes = {target: worker.TARGET_MODELS[c['model_sha256']]['size'], draft: worker.DFLASH_SIZE}
            original_stat = Path.stat
            def fake_size(path, *args, **kwargs):
                result = original_stat(path, *args, **kwargs)
                fields = list(result)
                fields[6] = sizes.get(path, result.st_size)
                return os.stat_result(fields)
            with patch.object(Path, 'stat', fake_size):
                with self.assertRaisesRegex(SystemExit, 'not installed'): worker.validate_artifacts(c)
                draft.write_bytes(b'x')
                worker.validate_artifacts(c)
                receipt.write_text(json.dumps({target.name: c['model_sha256'], draft.name: 'bad'}))
                with self.assertRaisesRegex(SystemExit, 'verification receipt'): worker.validate_artifacts(c)
                receipt.write_text(json.dumps({target.name: c['model_sha256'], draft.name: worker.DFLASH_SHA256}))
                sizes[draft] -= 1
                with self.assertRaisesRegex(SystemExit, 'size differs'): worker.validate_artifacts(c)
                receipt.unlink()
                with self.assertRaisesRegex(SystemExit, 'no completed hash'): worker.validate_artifacts(c)


if __name__ == '__main__':
    unittest.main()
