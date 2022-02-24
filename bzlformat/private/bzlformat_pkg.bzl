load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("//bzllib/rules:defs.bzl", "src_utils")
load("//updatesrc:defs.bzl", "updatesrc_update")
load(":bzlformat_format.bzl", "bzlformat_format")
load(":bzlformat_lint_test.bzl", "bzlformat_lint_test")

def bzlformat_pkg(
        name = "bzlformat",
        srcs = None,
        lint_test = True,
        format_visibility = None,
        update_visibility = None,
        lint_test_visibility = None):
    """Defines targets that format, test, and update the specified Starlark source files.

    NOTE: Any labels detected in the `srcs` will be ignored.

    Args:
        name: The prefix `string` that is used when creating the targets.
        srcs: Optional. A `list` of Starlark source files. If no value is
              provided, any files that match `*.bzl`, `BUILD` or `BUILD.bazel`
              are used.
        format_visibility: Optional. A `list` of Bazel visibility declarations
                           for the format targets.
        update_visibility: Optional. A `list` of Bazel visibility declarations
                           for the update target.
        lint_test_visibility: Optional. A `list` of Bazel visibility declarations
                              for the lint test target.

    Returns:
        None.
    """
    if srcs == None:
        srcs = native.glob(["*.bzl", "BUILD", "BUILD.bazel", "WORKSPACE"])

    # Only process paths; ignore labels
    src_paths = [src for src in srcs if src_utils.is_path(src)]

    name_prefix = name + "_"
    format_names = []
    for src in src_paths:
        src_name = src_utils.path_to_name(src)
        format_name = name_prefix + src_name + "_fmt"
        format_names.append(":" + format_name)

        bzlformat_format(
            name = format_name,
            srcs = [src],
            visibility = format_visibility,
        )
        diff_test(
            name = name_prefix + src_name + "_fmttest",
            file1 = src,
            file2 = ":" + format_name,
        )

    if lint_test:
        bzlformat_lint_test(
            name = name + "_lint_test",
            srcs = srcs,
        )

    updatesrc_update(
        name = name + "_update",
        deps = format_names,
        visibility = update_visibility,
    )
