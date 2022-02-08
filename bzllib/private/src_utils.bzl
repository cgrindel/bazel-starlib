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

def _path_to_name(path, prefix = None, suffix = None):
    """Converts a path string to a name suitable for use as a label name.

    Args:
        path: A path as a `string`.
        prefix: Optional. A string which will be prefixed to the namefied
                path with an underscore separating the prefix.

    Returns:
        A `string` suitable for use as a label name.
    """
    prefix_str = ""
    if prefix != None:
        prefix_str = prefix + "_" if not prefix.endswith("_") else prefix
    suffix_str = ""
    if suffix != None:
        suffix_str = "_" + suffix if not suffix.startswith("_") else suffix
    return prefix_str + path.replace("/", "_").replace(".", "_") + suffix_str

src_utils = struct(
    is_path = _is_path,
    is_label = _is_label,
    path_to_name = _path_to_name,
)
