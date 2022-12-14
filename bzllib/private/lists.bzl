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

lists = struct(
    compact = _compact,
    contains = _contains,
    find = _find,
)
