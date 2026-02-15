"""Implementation for `examples` module."""

def _new(dirname, bzlmod_modes = ["enabled"], oss = ["macos", "linux"]):
    """Create an example struct.

    Args:
        dirname: The directory name as a `string`.
        bzlmod_modes: A `list` of `string` values representing the bzlmod
            modes (e.g., `enabled`, `disabled`).
        oss: A `list` of operating systems (e.g., `linux`, `macos`).

    Returns:
    """
    return struct(
        dirname = dirname,
        bzlmod_modes = bzlmod_modes,
        oss = oss,
    )

examples = struct(
    new = _new,
)
