from orders.report import report


def test_no_discount():
    assert report([{"id": "A", "lines": [{"qty": 2, "unit_price": "9.00"}]}]) == {"A": "18.00"}


def test_null_discount():
    lines = [{"qty": 1, "unit_price": "0.10"}, {"qty": 1, "unit_price": "0.20"}]
    assert report([{"id": "B", "discount": None, "lines": lines}]) == {"B": "0.30"}


def test_half_up():
    assert report([{"id": "C", "lines": [{"qty": 1, "unit_price": "1.005"}]}]) == {"C": "1.01"}


def test_discount_half_up():
    # 3 x 0.35 = 1.05, half off = 0.525 -> 0.53
    order = {"id": "D", "discount": {"percent": "50"}, "lines": [{"qty": 3, "unit_price": "0.35"}]}
    assert report([order]) == {"D": "0.53"}


def test_discounted_format():
    order = {"id": "A1", "discount": {"percent": "10"}, "lines": [{"qty": 2, "unit_price": "10.00"}]}
    assert report([order]) == {"A1": "18.00"}
