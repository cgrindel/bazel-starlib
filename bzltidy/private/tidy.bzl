"""Macro that defines targets for executing targets against the workspace and 
confirming that the changes have been checked in.
"""

def tidy(name, targets):
    """Defines targets for executing targets against the workspace and \
    confirming that there are no changes.

    Args:
        name: The name of the target.
        targets: A `list` of targets to execute.
    """
    args = targets
    native.sh_binary(
        name = name,
        args = args,
        srcs = ["@cgrindel_bazel_starlib//bzltidy/private:tidy.sh"],
    )

    native.sh_binary(
        name = "{}_check".format(name),
        args = [":{}".format(name)],
        srcs = ["@cgrindel_bazel_starlib//bzltidy/private:check_tidy.sh"],
    )
