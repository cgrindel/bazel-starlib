"""Implementation for the `git_toolchain` rule."""

load(":git_toolchains.bzl", "git_toolchains")

def _git_toolchain_impl(ctx):
    git = ctx.executable.git
    default_info = DefaultInfo(
        files = depset([git]),
        runfiles = ctx.runfiles(files = [git]),
    )
    template_variables = platform_common.TemplateVariableInfo({
        "GIT": git.path,
    })
    toolchain_info = platform_common.ToolchainInfo(
        git_info = git_toolchains.GitInfo(git = git),
        template_variables = template_variables,
    )

    return [
        default_info,
        toolchain_info,
        template_variables,
    ]

git_toolchain = rule(
    implementation = _git_toolchain_impl,
    attrs = {
        "git": attr.label(
            mandatory = True,
            executable = True,
            cfg = "exec",
            doc = "The `git` utility.",
            allow_single_file = True,
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
    doc = "Defines a toolchain for the GitHub CLI.",
)
