"""Definition for `release_archive` rule."""

def _release_archive_impl(ctx):
    out_basename = ctx.attr.out
    if out_basename == "":
        out_basename = "{name}{ext}".format(
            name = ctx.label.name,
            ext = ctx.attr.ext,
        )
    out = ctx.actions.declare_file(out_basename)

    # Write the file list to a file
    file_list_out = ctx.actions.declare_file(ctx.label.name + "_files")
    file_list_args = ctx.actions.args()
    file_list_args.add_all(ctx.files.srcs)
    ctx.actions.write(
        output = file_list_out,
        content = file_list_args,
    )

    # Create the archive
    args = ctx.actions.args()
    args.add(out)
    args.add(file_list_out)
    ctx.actions.run_shell(
        outputs = [out],
        inputs = [file_list_out] + ctx.files.srcs,
        arguments = [args],
        command = """\
archive="$1"
file_list="$2"
shift 1
# tar -Lczvf "$archive" "$@" 2>/dev/null
tar -Lczvf "$archive" -T "${file_list}" 2>/dev/null
""",
    )
    return DefaultInfo(
        files = depset([out]),
        runfiles = ctx.runfiles(files = [out]),
    )

release_archive = rule(
    implementation = _release_archive_impl,
    attrs = {
        "ext": attr.string(
            default = ".tar.gz",
            doc = "The extension for the archive.",
        ),
        "out": attr.string(
            doc = "The name of the output file.",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
    },
    doc = """\
Create a source release archive.

This rule uses `tar` to collect and compress files into an archive file \
suitable for use as a release artifact. Any permissions on the source files \
will be preserved.
""",
)
