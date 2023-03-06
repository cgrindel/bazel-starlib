"""Module for managing Starlark `list` values."""

def _compact(items):
    """Returns the provide items with any `None` values removed.

    Args:
        items: A `list` of items to evaluate.

    Returns:
        A `list` of items with the `None` values removed.
    """
    return _filter(items, lambda x: x != None)

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

    # We are intentionally not calling _find(). We want to be able to use the
    # lists functions together. For instance, we want to be able to use
    # lists.contains inside the lambda for lists.find.
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

def _filter(items, bool_fn):
    """Returns a new `list` with the items that satisfy the boolean function.

    Args:
        items: A `list` of items to evaluate.
        bool_fn: A `function` that takes a single parameter (list item) and
            returns a `bool` indicating whether the meets the criteria.

    Returns:
        A `list` of the provided items that satisfy the boolean function.
    """
    return [item for item in items if bool_fn(item)]

def _map(items, map_fn):
    """Returns a new `list` where each item is the result of calling the map \
    function on each item in the original `list`.

    Args:
        items: A `list` of items to evaluate.
        map_fn: A `function` that takes a single parameter (list item) and
            returns a value that will be added to the new list at the
            correspnding location.

    Returns:
        A `list` with the transformed values.
    """
    return [map_fn(item) for item in items]

lists = struct(
    compact = _compact,
    contains = _contains,
    filter = _filter,
    find = _find,
    flatten = _flatten,
    map = _map,
)
