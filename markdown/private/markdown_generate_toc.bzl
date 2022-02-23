load("//updatesrc:defs.bzl", "UpdateSrcsInfo", "update_srcs")

def _markdown_generate_toc_impl(ctx):
    if ctx.files.srcs == []:
        fail("No markdown files were specified.")

    updsrcs = []
    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(ctx.label.name + "_" + src.basename + ctx.attr.output_suffix)
        updsrcs.append(update_srcs.create(src = src, out = out))

        args = ctx.actions.args()
        if not ctx.attr.remove_toc_header_entry:
            args.add("--no_remove_toc_header_entry")
        if ctx.attr.toc_header != "":
            args.add_all(["--toc_header", ctx.attr.toc_header])

        args.add_all([
            src,
            out,
        ])
        ctx.actions.run(
            outputs = [out],
            inputs = [src],
            executable = ctx.executable._toc_generator,
            arguments = [args],
        )

    return [
        DefaultInfo(files = depset([updsrc.out for updsrc in updsrcs])),
        UpdateSrcsInfo(update_srcs = depset(updsrcs)),
    ]

markdown_generate_toc = rule(
    implementation = _markdown_generate_toc_impl,
    attrs = {
        "output_suffix": attr.string(
            default = ".toc_updated",
            doc = "The suffix added to the output file with the updated TOC.",
        ),
        "remove_toc_header_entry": attr.bool(
            default = True,
            doc = """\
Specifies whether the header for the TOC should be removed from the TOC.\
""",
        ),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".md", ".markdown"],
            doc = """\
The markdown files that will be updated with a table of contents.\
""",
        ),
        "toc_header": attr.string(
            default = "Table of Contents",
            doc = "The header that leads the TOC.",
        ),
        "_toc_generator": attr.label(
            default = "@cgrindel_bazel_starlib//markdown/tools:update_markdown_toc",
            executable = True,
            cfg = "host",
            doc = "Utility that generates a TOC and updates the markdown document.",
        ),
    },
    # TODO: Add documentation.
    doc = "",
)
