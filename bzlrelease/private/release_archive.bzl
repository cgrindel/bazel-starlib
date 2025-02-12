"""Definition for `release_archive` rule."""

_TAR_TOOLCHAIN_TYPE = "@aspect_bazel_lib//lib:tar_toolchain_type"

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

    # # Create the archive
    # args = ctx.actions.args()
    # args.add(out)
    # args.add(file_list_out)
    # ctx.actions.run_shell(
    #     outputs = [out],
    #     inputs = [file_list_out] + ctx.files.srcs,
    #     arguments = [args],
    #     command = """\
    # archive="$1"
    # file_list="$2"
    # shift 1
    # tar 2>/dev/null -hczvf "$archive" -T "${file_list}"
    # """,
    # )

    bsdtar = ctx.toolchains[_TAR_TOOLCHAIN_TYPE]

    args = ctx.actions.args()
    args.add("-f", out)
    args.add_all(["-h", "-c", "-z"])
    args.add("-T", file_list_out)
    ctx.actions.run(
        outputs = [out],
        # inputs = [file_list_out] + ctx.files.srcs,
        inputs = depset(
            direct = [file_list_out] + ctx.files.srcs,
            transitive = [bsdtar.default.files],
        ),
        arguments = [args],
        executable = bsdtar.tarinfo.binary,
        toolchain = _TAR_TOOLCHAIN_TYPE,
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
    toolchains = [_TAR_TOOLCHAIN_TYPE],
    doc = """\
Create a source release archive.

This rule uses `tar` to collect and compress files into an archive file \
suitable for use as a release artifact. Any permissions on the source files \
will be preserved.
""",
)
