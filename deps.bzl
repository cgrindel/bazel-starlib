load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_starlib_dependencies():
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "cgrindel_bazel_doc",
        sha256 = "3ccc6d205a7f834c5e89adcb4bc5091a9a07a69376107807eb9aea731ce92854",
        strip_prefix = "bazel-doc-0.1.2",
        urls = ["https://github.com/cgrindel/bazel-doc/archive/v0.1.2.tar.gz"],
    )

    maybe(
        http_archive,
        name = "cgrindel_rules_bzlformat",
        sha256 = "df22d867e661de66a255a994caf814ff66426a43873194575bcaaaf9b9ad89ed",
        strip_prefix = "rules_bzlformat-0.2.0",
        urls = ["https://github.com/cgrindel/rules_bzlformat/archive/v0.2.0.tar.gz"],
    )

    maybe(
        http_archive,
        name = "rules_pkg",
        sha256 = "a89e203d3cf264e564fcb96b6e06dd70bc0557356eb48400ce4b5d97c2c3720d",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.5.1/rules_pkg-0.5.1.tar.gz",
            "https://github.com/bazelbuild/rules_pkg/releases/download/0.5.1/rules_pkg-0.5.1.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "5b80d60e00a7ea2d9d540c594e5ec41c946c163e272056c626026fcbb7918de2",
        url = "https://github.com/aspect-build/bazel-lib/releases/download/v0.2.7/bazel_lib-0.2.7.tar.gz",
    )
