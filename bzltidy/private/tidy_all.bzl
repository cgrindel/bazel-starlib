"""Macro that defines a target that executes a tidy target in all of the found 
workspaces.
"""

load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

def tidy_all(name, mode = "all", tidy_target = "//:tidy"):
    """Executes the specified tidy target in each of the found workspaces.

    Args:
        name: The name of the target as a `string`.
        mode: A `string` that specifies how the workspaces should be found.
            Valid values: `all`, `modified`. `all` will find all of the
            workspaces. `modified` will find the workspaces that have one or
            more modified files according to `git`.
        tidy_target: The fully-qualified label as a `string` that should be
            executed in each workspace.
    """
    sh_binary(
        name = name,
        srcs = ["@cgrindel_bazel_starlib//bzltidy/private:tidy_all.sh"],
        args = ["--mode", mode, "--tidy_target", tidy_target],
        deps = [
            "@cgrindel_bazel_starlib//shlib/lib:fail",
        ],
    )
