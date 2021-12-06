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
        sha256 = "26b269eec6dda36f3f24a4ffef1b997f057c78a53300e6c83a110cd79cd0918e",
        strip_prefix = "bazel-doc-0.1.1",
        urls = ["https://github.com/cgrindel/bazel-doc/archive/v0.1.1.tar.gz"],
    )

    maybe(
        http_archive,
        name = "cgrindel_rules_bzlformat",
        sha256 = "df22d867e661de66a255a994caf814ff66426a43873194575bcaaaf9b9ad89ed",
        strip_prefix = "rules_bzlformat-0.2.0",
        urls = ["https://github.com/cgrindel/rules_bzlformat/archive/v0.2.0.tar.gz"],
    )
