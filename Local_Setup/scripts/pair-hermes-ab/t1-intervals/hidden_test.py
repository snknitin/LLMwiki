from intervals import merge


def test_contained():
    assert merge([[1, 10], [2, 3]]) == [[1, 10]]


def test_empty():
    assert merge([]) == []


def test_input_not_mutated():
    data = [[5, 6], [1, 2]]
    merge(data)
    assert data == [[5, 6], [1, 2]]


def test_many():
    assert merge([[1, 4], [0, 0], [3, 5], [6, 7], [7, 7]]) == [[0, 0], [1, 5], [6, 7]]
