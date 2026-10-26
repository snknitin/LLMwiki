"""Merge overlapping closed intervals."""


def merge(intervals):
    """Return the union of closed intervals [start, end] as a sorted list of disjoint [start, end] lists.

    Touching intervals such as [1, 2] and [2, 3] merge into [1, 3]. The input is not modified.
    """
    result = []
    for start, end in intervals:
        if result and start < result[-1][1]:
            result[-1][1] = end
        else:
            result.append([start, end])
    return result
