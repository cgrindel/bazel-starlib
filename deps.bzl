"""Dependencies for bazel-starlib"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _bazeldoc_dependencies():
    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "ab6b747b3164510547f7696c6e06921966ccec7e08d9b81ec60133c3b09d5e5e",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.8.1/stardoc-0.8.1.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.8.1/stardoc-0.8.1.tar.gz",
        ],
    )

def _prebuilt_buildtools_dependencies():
    maybe(
        http_archive,
        name = "buildifier_prebuilt",
        sha256 = "4e5627d22359c87f1026354d2bd47832eec1f4d3f4dc42e0ebdb4cce7d5d73c4",
        strip_prefix = "buildifier-prebuilt-10.1.0",
        urls = [
            "http://github.com/keith/buildifier-prebuilt/archive/10.1.0.tar.gz",
        ],
    )

def bazel_starlib_dependencies():
    """Declares the dependencies for bazel-starlib.
    """

    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "37cdfbc6faefea94f7b37760a305c98c08981116c2bc9e821e3b423221fad8c8",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "6b65cb7917b4d1709f9410ffe00ecf3e160edf674b78c54a894471320862184f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.39.0/rules_go-v0.39.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.64.1/rules_go-v0.39.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "bazel_gazelle",
        sha256 = "9dae87c03ea06b2990b8836256909a18367e191f885d5bb1d030e8ba80491b42",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.54.0/bazel-gazelle-v0.54.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.54.0/bazel-gazelle-v0.54.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "c75f8c375f9f2c73a565dba188f91a4e8d7ca16dd2b6152d3886c26bbf1c6532",
        strip_prefix = "bazel-lib-3.7.2",
        url = "https://github.com/aspect-build/bazel-lib/releases/download/v3.7.2/bazel-lib-v3.7.2.tar.gz",
    )

    _bazeldoc_dependencies()
    _prebuilt_buildtools_dependencies()
