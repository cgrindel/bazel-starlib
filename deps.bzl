"""Dependencies for bazel-starlib"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _bazeldoc_dependencies():
    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "0e1ed4a98f26e718776bd64d053d02bb34d98572ccd03d6ba355112a1205706b",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.7.2/stardoc-0.7.2.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.7.2/stardoc-0.7.2.tar.gz",
        ],
    )

def _prebuilt_buildtools_dependencies():
    maybe(
        http_archive,
        name = "buildifier_prebuilt",
        sha256 = "e31fe636a5004eb50b7b47ec31c3cea0afd597d14bb1991832aa213038837ecf",
        strip_prefix = "buildifier-prebuilt-8.0.0",
        urls = [
            "http://github.com/keith/buildifier-prebuilt/archive/8.0.0.tar.gz",
        ],
    )

def bazel_starlib_dependencies():
    """Declares the dependencies for bazel-starlib.
    """

    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "6b65cb7917b4d1709f9410ffe00ecf3e160edf674b78c54a894471320862184f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.39.0/rules_go-v0.39.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.50.0/rules_go-v0.39.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "bazel_gazelle",
        sha256 = "75df288c4b31c81eb50f51e2e14f4763cb7548daae126817247064637fd9ea62",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.36.0/bazel-gazelle-v0.36.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.36.0/bazel-gazelle-v0.36.0.tar.gz",
        ],
    )

    _bazeldoc_dependencies()
    _prebuilt_buildtools_dependencies()
