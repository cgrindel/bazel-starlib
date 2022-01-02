"""A macro that defines a runnable target that will copy all of the formatted 
Swift source files to the workspace directory.
"""

def updatesrc_update_all(name, targets_to_run = []):
    """Defines a runnable target that will query for `updatesrc_update` targets and run them.

    The utility queries for all of the `updatesrc_update` rules in the
    workspace and executes each one. Hence, source files that are mapped
    in these targets will be updated.

    Additional targets to execute can be specified using the `targets_to_run`
    attribute.

    Args:
        name: The name of the target.
        targets_to_run: A `list` of labels to execute in addition to the
                        `updatesrc_update` targets.

    Returns:
        None.
    """
    native.sh_binary(
        name = name,
        args = targets_to_run,
        srcs = [
            "@cgrindel_bazel_starlib//updatesrc/private:update_all.sh",
        ],
    )
