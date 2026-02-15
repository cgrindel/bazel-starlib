"""Implementation for `examples` module."""

def _new(dirname, oss = ["macos", "linux"]):
    """Create an example struct.

    Args:
        dirname: The directory name as a `string`.
        oss: A `list` of operating systems (e.g., `linux`, `macos`).

    Returns:
    """
    return struct(
        dirname = dirname,
        oss = oss,
    )

examples = struct(
    new = _new,
)
