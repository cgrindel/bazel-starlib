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
        sha256 = "b0434d14d8ca6eb87ae1d0e71911aeb83ffa3096c6b81db7e26c1698fd980d42",
        strip_prefix = "buildifier-prebuilt-8.2.1",
        urls = [
            "http://github.com/keith/buildifier-prebuilt/archive/8.2.1.tar.gz",
        ],
    )

def bazel_starlib_dependencies():
    """Declares the dependencies for bazel-starlib.
    """

    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "3b5b49006181f5f8ff626ef8ddceaa95e9bb8ad294f7b5d7b11ea9f7ddaf8c59",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.9.0/bazel-skylib-1.9.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.9.0/bazel-skylib-1.9.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "6b65cb7917b4d1709f9410ffe00ecf3e160edf674b78c54a894471320862184f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.39.0/rules_go-v0.39.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.60.0/rules_go-v0.39.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "bazel_gazelle",
        sha256 = "675114d8b433d0a9f54d81171833be96ebc4113115664b791e6f204d58e93446",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.47.0/bazel-gazelle-v0.47.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.47.0/bazel-gazelle-v0.47.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "5c42b1547cd4fab56fb90f75295aaf6d9e4aed5b51bfcb2457e44b886204a6e2",
        strip_prefix = "bazel-lib-3.2.1",
        url = "https://github.com/aspect-build/bazel-lib/releases/download/v3.2.1/bazel-lib-v3.2.1.tar.gz",
    )

    _bazeldoc_dependencies()
    _prebuilt_buildtools_dependencies()
