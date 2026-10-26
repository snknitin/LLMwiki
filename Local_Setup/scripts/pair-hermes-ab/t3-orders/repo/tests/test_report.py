from orders import report


def test_discounted():
    order = {"id": "A1", "discount": {"percent": "10"}, "lines": [{"qty": 2, "unit_price": "10.00"}]}
    assert report([order]) == {"A1": "18.0"}
