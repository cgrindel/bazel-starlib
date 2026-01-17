"""Implementation of the `git_vars` rule."""

load(":git_toolchains.bzl", "git_toolchains")

def _git_vars_impl(ctx):
    git_info = ctx.toolchains[git_toolchains.type].git_info
    git = git_info.git
    template_variables = platform_common.TemplateVariableInfo({
        "GIT": git.path,
    })
    return [template_variables]

git_vars = rule(
    implementation = _git_vars_impl,
    provides = [
        platform_common.TemplateVariableInfo,
    ],
    toolchains = [git_toolchains.type],
    # The doc says that you can use the toolchain type, but they did not work
    # for me. I saw that rules_erlang did something like this.
    doc = "Provides make variable substitution for `genrule` and `sh_xxx`.",
)
