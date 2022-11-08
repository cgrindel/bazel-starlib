"""Dependency Functions for markdown"""

# load("@bazel_gazelle//:deps.bzl", "go_repository")
# load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//markdown:github_markdown_toc_go_repositories.bzl", "github_markdown_toc_go_repositories")

def bazel_starlib_markdown_dependencies():
    """Defines the dependencies for the markdown functionality.
    """

    # GH140: Temporarily disable markdown while adding support for
    # --incompatible_disallow_empty_glob.

    # maybe(
    #     http_archive,
    #     name = "build_bazel_rules_nodejs",
    #     sha256 = "e328cb2c9401be495fa7d79c306f5ee3040e8a03b2ebb79b022e15ca03770096",
    #     urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.4.2/rules_nodejs-5.4.2.tar.gz"],
    # )

    # maybe(
    #     go_repository,
    #     name = "com_github_ekalinin_github_markdown_toc_go",
    #     importpath = "github.com/ekalinin/github-markdown-toc.go",
    #     sum = "h1:Y3V7JoKbxDnWKpHV7KIektVSNA7CScWc1ECBgAsyMco=",
    #     version = "v0.0.0-20201214095852-3ab0fa2ca613",
    # )

    # maybe(
    #     go_repository,
    #     name = "com_github_ekalinin_github_markdown_toc_go",
    #     importpath = "github.com/ekalinin/github-markdown-toc.go",
    #     commit = "563f2322eacc2fc3ea5be26d14c6f4d12076f87c",
    #     remote = "https://github.com/cgrindel/github-markdown-toc.go.git",
    #     build_external = "external",
    #     vcs = "git",
    # )

    # maybe(
    #     http_archive,
    #     name = "ekalinin_github_markdown_toc",
    #     sha256 = "",
    #     strip_prefix = "github-markdown-toc.go-b75d2a6d1f6518a287cf24f162ec14d4c82e7739",
    #     urls = ["https://github.com/ekalinin/github-markdown-toc.go/archive/refs/tags/1.2.0.tar.gz"],
    #     build_file_content = """\
    # load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")
    # go_binary(
    # name = "gh_md_toc",
    # srcs = glob(["*.go"], exclude = ["*_test.go"]),
    # deps = [
    #     "@in_gopkg_alecthomas_kingpin_v2//:go_default_library",
    # ],
    # visibility = ["//visibility:public"],
    # )
    # """,
    # )

    # Deps for github-markdown-toc.go
    github_markdown_toc_go_repositories()
