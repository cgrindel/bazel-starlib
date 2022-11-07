"""Dependency Functions for markdown"""

load("@bazel_gazelle//:deps.bzl", "go_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//markdown:github_markdown_toc_go_repositories.bzl", "github_markdown_toc_go_repositories")

def bazel_starlib_markdown_dependencies():
    # GH140: Temporarily disable markdown while adding support for
    # --incompatible_disallow_empty_glob.

    # maybe(
    #     http_archive,
    #     name = "build_bazel_rules_nodejs",
    #     sha256 = "e328cb2c9401be495fa7d79c306f5ee3040e8a03b2ebb79b022e15ca03770096",
    #     urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.4.2/rules_nodejs-5.4.2.tar.gz"],
    # )

    maybe(
        go_repository,
        name = "com_github_ekalinin_github_markdown_toc_go",
        importpath = "github.com/ekalinin/github-markdown-toc.go",
        sum = "h1:Y3V7JoKbxDnWKpHV7KIektVSNA7CScWc1ECBgAsyMco=",
        version = "v0.0.0-20201214095852-3ab0fa2ca613",
    )

    # Deps for github-markdown-toc.go
    github_markdown_toc_go_repositories()
