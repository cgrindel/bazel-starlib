"""Implementation for the `gh_toolchain` rule."""

load(":providers.bzl", "GhInfo")

def _gh_toolchain_impl(ctx):
    gh = ctx.executable.gh

    # DEBUG BEGIN
    print("*** CHUCK gh_toolchain")
    print("*** CHUCK gh: ", gh)
    # DEBUG END

    default_info = DefaultInfo(
        files = depset([gh]),
        runfiles = ctx.runfiles(files = [gh]),
    )
    template_variables = platform_common.TemplateVariableInfo({
        "GH": gh.path,
    })
    toolchain_info = platform_common.ToolchainInfo(
        gh_info = GhInfo(gh = gh),
        template_variables = template_variables,
    )

    return [
        default_info,
        toolchain_info,
        template_variables,
    ]

gh_toolchain = rule(
    implementation = _gh_toolchain_impl,
    attrs = {
        "gh": attr.label(
            mandatory = True,
            executable = True,
            cfg = "exec",
            doc = "The `gh` utility.",
            allow_single_file = True,
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
    doc = "Defines a toolchain for the GitHub CLI.",
)
