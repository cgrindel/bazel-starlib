def _do_filename_ends_with(ctx, files):
    suffix = ctx.attr.filename_ends_with
    return [f for f in files if f.path.endswith(suffix)]

def _filter_srcs_impl(ctx):
    files = ctx.files.srcs
    if ctx.attr.filename_ends_with != "":
        files = _do_filename_ends_with(ctx, files)
    else:
        fail("No filter criteria were provided.")

    expected_count = ctx.attr.expected_count
    if expected_count > -1 and len(files) != expected_count:
        fail(
            "Expected {expected_count} items, but found {actual_count}.".format(
                expected_count = expected_count,
                actual_count = len(files),
            ),
        )

    return [DefaultInfo(files = depset(files))]

filter_srcs = rule(
    implementation = _filter_srcs_impl,
    attrs = {
        "expected_count": attr.int(
            default = -1,
            doc = "The expected number of results.",
        ),
        "filename_ends_with": attr.string(
            doc = "The suffix of the path will be compared to this value.",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "The inputs that will be evaluated by the filter.",
        ),
    },
    doc = "Filters the provided inputs using the specified criteria.",
)
