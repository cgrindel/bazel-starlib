"""Macro that defines targets for executing targets against the workspace and 
confirming that the changes have been checked in.
"""

def tidy(name, targets):
    """Executes the specified targets in order.

    Args:
        name: The name of the target.
        targets: A `list` of targets to execute.
    """
    args = targets
    native.sh_binary(
        name = name,
        args = args,
        srcs = ["@cgrindel_bazel_starlib//tidy/private:tidy.sh"],
    )
