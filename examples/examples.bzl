"""Implementation for `examples` module."""

def _new(dirname, bzlmod_modes = ["enabled"], oss = ["macos", "linux"], target_compatible_with = None):
    """Create an example struct.

    Args:
        dirname: The directory name as a `string`.
        bzlmod_modes: A `list` of `string` values representing the bzlmod
            modes (e.g., `enabled`, `disabled`).
        oss: A `list` of operating systems (e.g., `linux`, `macos`).
        target_compatible_with: Optional. The value that should be set for the
            the integration test.

    Returns:
    """
    return struct(
        dirname = dirname,
        bzlmod_modes = bzlmod_modes,
        oss = oss,
        target_compatible_with = target_compatible_with,
    )

examples = struct(
    new = _new,
)
