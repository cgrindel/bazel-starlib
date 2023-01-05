"""Module for managing Starlark `list` values."""

def _compact(items):
    """Returns the provide items with any `None` values removed.

    Args:
        items: A `list` of items to evaluate.

    Returns:
        A `list` of items with the `None` values removed.
    """
    new_items = []
    for item in items:
        if item != None:
            new_items.append(item)
    return new_items

def _contains(items, target_or_fn):
    """Determines if the provide value is found in a list.

    Args:
        items: A `list` of items to evaluate.
        target_or_fn: The item that may be contained in the items list or a
            `function` that takes a single value and returns a `bool`.

    Returns:
        A `bool` indicating whether the target item was found in the list.
    """
    if type(target_or_fn) == "function":
        bool_fn = target_or_fn
    else:
        bool_fn = lambda x: x == target_or_fn

    for item in items:
        if bool_fn(item):
            return True
    return False

def _find(items, bool_fn):
    """Returns the list item that satisfies the provide boolean function.

    Args:
        items: A `list` of items to evaluate.
        bool_fn: A `function` that takes a single parameter (list item) and
            returns a `bool` indicating whether the meets the criteria.

    Returns:
        A list item or `None`.
    """
    for item in items:
        if bool_fn(item):
            return item
    return None

def _flatten(items):
    """Flattens the items to a single list.

    If provided a single item, it is wrapped in a list and processed as if
    provided as a `list`.

    Args:
        items: A `list` or a single item.

    Returns:
        A `list` with all of the items flattened (i.e., no items in the result
        are an item of type `list`).
    """
    if type(items) == "list":
        results = items
    else:
        results = [items]

    finished = False
    for _ in range(1000):
        if finished:
            break
        finished = True
        to_process = list(results)
        results = []
        for item in to_process:
            if type(item) == "list":
                results.extend(item)
                finished = False
            else:
                results.append(item)

    if not finished:
        fail("Exceeded the maximum number of iterations to flatten the items.")

    return results

lists = struct(
    compact = _compact,
    contains = _contains,
    find = _find,
    flatten = _flatten,
)