import unittest

import add_desktop_qwen as subject


class TransformTests(unittest.TestCase):
    def fixture(self):
        return {
            'model': {'default': 'qwen38-27b-spark', 'provider': 'spark-qwen38'},
            'providers': {subject.PROVIDER: {
                'api': subject.ENDPOINT,
                'extra_headers': {'Host': 'localhost:11434'},
                'discover_models': False,
                'models': {'gemma3:4b': {'context_length': 131072}},
            }},
            'fallback_providers': [{'provider': 'spark-qwen38'}],
        }

    def test_adds_exact_model_without_changing_routing(self):
        before = self.fixture()
        after = subject.transform(before)
        self.assertEqual(after['providers'][subject.PROVIDER]['models'][subject.MODEL],
                         subject.MODEL_METADATA)
        self.assertEqual(after['model'], before['model'])
        self.assertEqual(after['fallback_providers'], before['fallback_providers'])
        self.assertNotIn(subject.MODEL, before['providers'][subject.PROVIDER]['models'])

    def test_wrong_endpoint_or_host_is_rejected(self):
        for patch in ({'api': 'http://127.0.0.1:11434/v1'}, {'extra_headers': {}}):
            data = self.fixture()
            data['providers'][subject.PROVIDER].update(patch)
            with self.subTest(patch=patch), self.assertRaises(ValueError):
                subject.transform(data)


if __name__ == '__main__':
    unittest.main()
