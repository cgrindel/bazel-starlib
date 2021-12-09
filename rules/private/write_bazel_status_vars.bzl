def _write_bazel_status_vars_impl(ctx):
    pass

write_bazel_status_vars = rule(
    implementation = _write_bazel_status_vars_impl,
    attrs = {},
    doc = "",
)
