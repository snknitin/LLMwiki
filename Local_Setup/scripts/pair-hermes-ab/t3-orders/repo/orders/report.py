"""Invoice totals for the monthly accounting export."""


def order_total(order):
    subtotal = sum(line["qty"] * float(line["unit_price"]) for line in order["lines"])
    pct = float(order["discount"]["percent"])
    return round(subtotal * (1 - pct / 100), 2)


def report(orders):
    """Return {order id: total as a string}, e.g. {"A1": "17.99"}."""
    return {o["id"]: str(order_total(o)) for o in orders}
