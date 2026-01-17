"""Implementation of bzlmod extensions related to GitHub CLI."""

load(":local_git.bzl", "local_git")

def _local_git_ext(_):
    local_git(name = "bazel_starlib_git_toolchains")

local_git_ext = module_extension(
    implementation = _local_git_ext,
)
