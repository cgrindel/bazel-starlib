"""Definition for `release_archive` rule."""

load("//tools/tar:tar_toolchains.bzl", "tar_toolchains")

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

    bsdtar = ctx.toolchains[tar_toolchains.type]

    args = ctx.actions.args()
    args.add("-f", out)
    args.add_all(["-h", "-c", "-z"])
    args.add("-T", file_list_out)
    ctx.actions.run(
        outputs = [out],
        inputs = depset(
            direct = [file_list_out] + ctx.files.srcs,
            transitive = [bsdtar.default.files],
        ),
        arguments = [args],
        executable = bsdtar.tarinfo.binary,
        toolchain = tar_toolchains.type,
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
    toolchains = [tar_toolchains.type],
    doc = """\
Create a source release archive.

This rule uses `tar` to collect and compress files into an archive file \
suitable for use as a release artifact. Any permissions on the source files \
will be preserved.
""",
)
