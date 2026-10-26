import json
import subprocess
import sys

import pytest

CSV = "region,product,amount\nnorth,a,10.10\nsouth,b,5\nnorth,c,2.333\neast,a,\nsouth,a,1\n"


def run(tmp_path, *args):
    f = tmp_path / "s.csv"
    f.write_text(CSV)
    return subprocess.run([sys.executable, "csvsum.py", str(f), "amount", *args],
                          capture_output=True, text=True, check=True).stdout


def test_group(tmp_path):
    d = json.loads(run(tmp_path, "--group-by", "region"))
    assert d == {"north": 12.43, "south": 6.0}
    assert list(d) == sorted(d)


def test_plain_skips_empty(tmp_path):
    assert float(run(tmp_path)) == pytest.approx(18.433)
