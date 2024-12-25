"""A macro that defines a runnable target that will copy all of the formatted 
Swift source files to the workspace directory.
"""

load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

def updatesrc_update_all(name, targets_to_run = [], targets_to_run_before = []):
    """Defines a runnable target that will query for `updatesrc_update` targets and run them.

    The utility queries for all of the `updatesrc_update` rules in the
    workspace and executes each one. Hence, source files that are mapped
    in these targets will be updated.

    Additional targets to execute can be specified using the `targets_to_run`
    and `targets_to_run_before` attributes.

    Args:
        name: The name of the target.
        targets_to_run: A `list` of labels to execute after the
            `updatesrc_update` targets.
        targets_to_run_before: A `list` of labels to execute before the
            `updatesrc_update` targets.

    Returns:
        None.
    """
    args = []
    for t in targets_to_run_before:
        args.extend(["--run_before", t])
    for t in targets_to_run:
        args.extend(["--run_after", t])

    native_binary(
        name = name,
        args = args,
        src = "@cgrindel_bazel_starlib//updatesrc/private:update_all",
    )

#     sh_binary(
#         name = name,
#         args = args,
#         srcs = [
#             "@cgrindel_bazel_starlib//updatesrc/private:update_all.sh",
#         ],
#         # deps = [
#         #     "@bazel_tools//tools/bash/runfiles",
#         # ],
#     )
