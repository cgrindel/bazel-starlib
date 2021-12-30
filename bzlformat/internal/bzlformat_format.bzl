load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "@cgrindel_rules_updatesrc//updatesrc:updatesrc.bzl",
    "UpdateSrcsInfo",
    "update_srcs",
)

def _bzlformat_format_impl(ctx):
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
            executable = ctx.executable._buildifier,
            arguments = [args],
        )

    return [
        DefaultInfo(files = depset([updsrc.out for updsrc in updsrcs])),
        UpdateSrcsInfo(update_srcs = depset(updsrcs)),
    ]

bzlformat_format = rule(
    implementation = _bzlformat_format_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "The Starlark source files to format.",
        ),
        "output_suffix": attr.string(
            default = ".formatted",
            doc = "The suffix added to the formatted output filename.",
        ),
        "_buildifier": attr.label(
            default = "@cgrindel_rules_bzlformat//tools:buildifier",
            executable = True,
            cfg = "host",
            allow_files = True,
            doc = "The `buildifier` script that executes the formatting.",
        ),
    },
    doc = "Formats Starlark source files using Buildifier.",
)
