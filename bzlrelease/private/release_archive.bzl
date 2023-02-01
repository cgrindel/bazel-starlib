"""Definition for `release_archive` rule."""

def _release_archive_impl(ctx):
    out_basename = ctx.attr.out
    if out_basename == "":
        out_basename = "{name}{ext}".format(
            name = ctx.label.name,
            ext = ctx.attr.ext,
        )
    out = ctx.actions.declare_file(out_basename)
    args = ctx.actions.args()
    args.add(out)
    args.add_all(ctx.files.srcs)
    ctx.actions.run_shell(
        outputs = [out],
        inputs = ctx.files.srcs,
        arguments = [args],
        command = """\
archive="$1"
shift 1
tar -Lczvf "$archive" "$@" 2>/dev/null
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
    doc = "Create a source release archive.",
)
