def _create(src, out):
    """Creates a `struct` specifying a source file and an output file that should be used to update it.

    Args:
        src: A `File` designating a file in the workspace.
        out: A `File` designating a file in the output directory.

    Returns:
        A `struct`.
    """
    return struct(
        src = src,
        out = out,
    )

update_srcs = struct(
    create = _create,
)
