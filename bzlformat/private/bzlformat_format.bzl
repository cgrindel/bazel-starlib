"""Definition for bzlformat_format rule"""

load("//updatesrc:defs.bzl", "UpdateSrcsInfo", "update_srcs")

def _bzlformat_format_impl(ctx):
    updsrcs = []
    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename + ctx.attr.output_suffix)
        updsrcs.append(update_srcs.create(src = src, out = out))

        args = ctx.actions.args()
        lint_mode = "fix" if ctx.attr.fix_lint_warnings else "off"
        args.add_all(["--lint_mode", lint_mode])
        args.add_all(["--warnings", ctx.attr.warnings])
        args.add_all([src, out])

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
        "fix_lint_warnings": attr.bool(
            default = True,
            doc = "Should lint warnings be fixed, if possible.",
        ),
        "output_suffix": attr.string(
            default = ".formatted",
            doc = "The suffix added to the formatted output filename.",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "The Starlark source files to format.",
        ),
        "warnings": attr.string(
            doc = "The warnings that should be fixed if lint fix is enabled.",
            default = "all",
        ),
        "_buildifier": attr.label(
            default = "//bzlformat/tools:buildifier",
            executable = True,
            cfg = "host",
            allow_files = True,
            doc = "The `buildifier` script that executes the formatting.",
        ),
    },
    doc = "Formats Starlark source files using Buildifier.",
)
