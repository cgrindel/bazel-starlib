# TODO: FINISH ME!

def _bzlformat_lint_test_impl(ctx):
    # for src in ctx.files.srcs:
    #     write_execute_binary_action(ctx.actions, exec_binary_out, )
    pass

bzlformat_lint_test = rule(
    implementation = _bzlformat_lint_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "The Starlark source files to lint.",
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
    doc = "Lints the specified Starlark files using Buildifier.",
)

# def bzlformat_lint_test(name, srcs, warnings = None):
#     for src in srcs:
#         exec_buildifier_name =
#         execute_binary(
#         )
