def _write_bazel_status_vars_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name + ".sh")

    args = ctx.actions.args()
    args.add("--status_file", ctx.info_file)
    args.add("--status_file", ctx.version_file)
    args.add("--output", out)

    ctx.actions.run(
        outputs = [out],
        inputs = [
            ctx.info_file,
            ctx.version_file,
        ],
        executable = ctx.executable._write_tool,
        arguments = [args],
    )

    return DefaultInfo(files = depset([out]))

write_bazel_status_vars = rule(
    implementation = _write_bazel_status_vars_impl,
    attrs = {
        "_write_tool": attr.label(
            default = "@cgrindel_bazel_starlib//tools:write_bazel_status_vars",
            doc = "The tool that performs the write.",
        ),
    },
    doc = "Writes the Bazel status variables as environment variables to a file.",
)
