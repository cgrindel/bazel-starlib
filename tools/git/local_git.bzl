"""Implementation of the `local_git` repository rule."""

load(":git_toolchains.bzl", "git_toolchains")

_BUILD_TPL = """\
load("@cgrindel_bazel_starlib//tools/git:git_toolchain.bzl", "git_toolchain")
load("@cgrindel_bazel_starlib//tools/git:git_vars.bzl", "git_vars")

git_toolchain(
    name = "local_git",
    git = ":{link_name}",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "local_git_toolchain",
    toolchain = ":local_git",
    toolchain_type = "{toolchain_type}",
    # visibility = ["//visibility:public"],
)
"""

def _local_git_impl(rctx):
    git_path = rctx.which("git")
    if not git_path:
        fail("Could not find `git` in the PATH.")

    link_name = "git"
    rctx.symlink(git_path, link_name)

    rctx.file("BUILD.bazel", _BUILD_TPL.format(
        link_name = link_name,
        toolchain_type = git_toolchains.type,
    ))

local_git = repository_rule(
    implementation = _local_git_impl,
    local = True,
    doc = "Detect the local installation of the GitHub CLI and define a toolchain.",
)
