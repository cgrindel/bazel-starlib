"""Implementation of bzlmod extensions related to GitHub CLI."""

load(":local_gh.bzl", "local_gh")

def _local_gh_ext(_):
    local_gh(name = "bazel_starlib_gh_toolchains")

local_gh_ext = module_extension(
    implementation = _local_gh_ext,
)
