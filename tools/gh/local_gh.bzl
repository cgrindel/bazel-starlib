"""Implementation of the `local_gh` repository rule."""

_BUILD_TPL = """\
load("@cgrindel_bazel_starlib//tools/gh:gh_toolchain.bzl", "gh_toolchain")

gh_toolchain(
    name = "local_gh",
    gh = ":{link_name}",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "local_gh_toolchain",
    toolchain = ":local_gh",
    toolchain_type = "@cgrindel_bazel_starlib//tools/gh:toolchain_type",
    # visibility = ["//visibility:public"],
)
"""

def _local_gh_impl(rctx):
    # DEBUG BEGIN
    print("*** CHUCK local_gh_impl")

    # DEBUG END
    gh_path = rctx.which("gh")
    if not gh_path:
        fail("Could not find `gh` in the PATH.")

    link_name = "gh"
    rctx.symlink(gh_path, link_name)

    rctx.file("BUILD.bazel", _BUILD_TPL.format(
        link_name = link_name,
    ))

local_gh = repository_rule(
    implementation = _local_gh_impl,
    local = True,
    doc = "Detect the local installation of the GitHub CLI and define a toolchain.",
)
