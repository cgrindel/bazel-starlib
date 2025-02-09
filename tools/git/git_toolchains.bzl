"""Implementation of the `git_toolchains` module."""

_TOOLCHAIN_TYPE = "@cgrindel_bazel_starlib//tools/git:toolchain_type"

_GitInfo = provider(
    fields = {
        "git": "The `git` utility as an exeutable `File`.",
    },
    doc = "Information about the GitHub CLI.",
)

git_toolchains = struct(
    type = _TOOLCHAIN_TYPE,
    GitInfo = _GitInfo,
)
