def _is_label(src):
    """Determines whether the provided string is a label.

    Args:
        src: A `string` value.

    Returns:
        A `bool` specifying whether the `string` value looks like a label.
    """
    return src.find("//") > -1 or src.find(":") > -1

def _is_path(src):
    """Determines whether the provided string is a path.

    Args:
        src: A `string` value.

    Returns:
        A `bool` specifying whether the `string` value looks like a path.
    """
    return not _is_label(src)

src_utils = struct(
    is_path = _is_path,
    is_label = _is_label,
)
