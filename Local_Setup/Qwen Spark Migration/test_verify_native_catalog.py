"""Sanitized picker fixtures; no network, service or model access."""
import copy
import unittest
import verify_native_catalog as checker


class CatalogTests(unittest.TestCase):
    def setUp(self):
        self.rows = [{'slug': 'desktop-ollama', 'models': list(checker.DESKTOP_MODELS)},
                     {'slug': checker.PROVIDER, 'api_url': checker.BASE, 'models': [checker.ALIAS]}]

    def test_expected_catalog(self):
        checker.check_rows(self.rows)

    def test_duplicate_gemma(self):
        self.rows[0]['models'].append(checker.GEMMAS[0])
        with self.assertRaises(AssertionError): checker.check_rows(self.rows)

    def test_duplicate_native(self):
        self.rows.append(copy.deepcopy(self.rows[1]))
        with self.assertRaises(AssertionError): checker.check_rows(self.rows)

    def test_visible_offline_provider(self):
        self.rows.append({'slug': 'spark-lmstudio', 'models': []})
        with self.assertRaises(AssertionError): checker.check_rows(self.rows)

    def test_wrong_native_endpoint(self):
        self.rows[1]['api_url'] = 'http://127.0.0.1:1234/v1'
        with self.assertRaises(AssertionError): checker.check_rows(self.rows)


if __name__ == '__main__': unittest.main()
