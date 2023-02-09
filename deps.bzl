"""Dependencies for bazel-starlib"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(":bazel_starlib_buildtools.bzl", "bazel_starlib_buildtools")

def _bazeldoc_dependencies():
    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "3fd8fec4ddec3c670bd810904e2e33170bedfe12f90adf943508184be458c8bb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz",
        ],
    )

def _prebuilt_buildtools_dependencies():
    maybe(
        http_archive,
        name = "buildifier_prebuilt",
        sha256 = "95387c9dded7f8e3bdd4c598bc2ca4fbb6366cb214fa52e7d7b689eb2f421e01",
        strip_prefix = "buildifier-prebuilt-6.0.0",
        urls = [
            "http://github.com/keith/buildifier-prebuilt/archive/6.0.0.tar.gz",
        ],
    )

    bazel_starlib_buildtools(
        name = "bazel_starlib_buildtools",
        buildozer_target = "@buildifier_prebuilt//buildozer",
        buildozer_location = "buildifier_prebuilt/buildozer/buildozer",
        buildifier_target = "@buildifier_prebuilt//buildifier",
        buildifier_location = "buildifier_prebuilt/buildifier/buildifier",
    )

def _compile_from_source_buildtools_dependencies():
    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "930c2c3b5ecc6c9c12615cf5ad93f1cd6e12d0aba862b572e076259970ac3a53",
        strip_prefix = "protobuf-3.21.12",
        urls = [
            "https://github.com/protocolbuffers/protobuf/archive/v3.21.12.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "com_github_bazelbuild_buildtools",
        sha256 = "ca524d4df8c91838b9e80543832cf54d945e8045f6a2b9db1a1d02eec20e8b8c",
        strip_prefix = "buildtools-6.0.1",
        urls = [
            "https://github.com/bazelbuild/buildtools/archive/refs/tags/6.0.1.tar.gz",
        ],
    )

    bazel_starlib_buildtools(
        name = "bazel_starlib_buildtools",
        buildozer_target = "@com_github_bazelbuild_buildtools//buildozer",
        buildozer_location = "com_github_bazelbuild_buildtools/buildozer/buildozer_/buildozer",
        buildifier_target = "@com_github_bazelbuild_buildtools//buildifier",
        buildifier_location = "com_github_bazelbuild_buildtools/buildifier/buildifier_/buildifier",
    )

def bazel_starlib_dependencies(
        use_prebuilt_buildtools = True,
        use_bazeldoc = True):
    """Declares the dependencies for bazel-starlib.

    Args:
        use_prebuilt_buildtools: A `bool` specifying whether to use a prebuilt
                                 version of `bazelbuild/buildtools`.
        use_bazeldoc: A `bool` specifying whether the `bazeldoc` dependencies
                      should be loaded.
    """

    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "dd926a88a564a9246713a9c00b35315f54cbd46b31a26d5d8fb264c07045f05d",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.38.1/rules_go-v0.38.1.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.38.1/rules_go-v0.38.1.zip",
        ],
    )

    maybe(
        http_archive,
        name = "bazel_gazelle",
        sha256 = "ecba0f04f96b4960a5b250c8e8eeec42281035970aa8852dda73098274d14a1d",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.29.0/bazel-gazelle-v0.29.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.29.0/bazel-gazelle-v0.29.0.tar.gz",
        ],
    )

    if use_bazeldoc:
        _bazeldoc_dependencies()

    if use_prebuilt_buildtools:
        _prebuilt_buildtools_dependencies()
    else:
        _compile_from_source_buildtools_dependencies()
