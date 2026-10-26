from csvsum import column_sum


def test_sum(tmp_path):
    f = tmp_path / "a.csv"
    f.write_text("region,amount\nn,1.5\ns,2\n")
    assert column_sum(f, "amount") == 3.5
