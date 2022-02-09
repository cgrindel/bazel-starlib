load("//updatesrc:defs.bzl", "UpdateSrcsInfo", "update_srcs")

def _markdown_generate_toc_impl(ctx):
    if ctx.files.srcs == []:
        fail("No markdown files were specified.")

    updsrcs = []
    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename + ctx.attr.output_suffix)
        updsrcs.append(update_srcs.create(src = src, out = out))

        args = ctx.actions.args()
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
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = [".md", ".markdown"],
            doc = """\
The markdown files that will be updated with a table of contents.\
""",
        ),
        "output_suffix": attr.string(
            default = ".toc_updated",
            doc = "The suffix added to the output file with the updated TOC.",
        ),
        "_toc_generator": attr.label(
            default = "@ekalinin_github_markdown_toc//:gh_md_toc",
            executable = True,
            cfg = "host",
            doc = "TOC generator utility.",
        ),
    },
    doc = "",
)
