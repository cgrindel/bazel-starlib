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
        sha256 = "b3fd85ae7e45c2f36bce52cfdbdb6c20261761ea5928d1686edc8873b0d0dad0",
        strip_prefix = "buildifier-prebuilt-5.1.0",
        urls = [
            "http://github.com/keith/buildifier-prebuilt/archive/5.1.0.tar.gz",
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
        sha256 = "1add10f9bd92775b91f326da259f243881e904dd509367d5031d4c782ba82810",
        strip_prefix = "protobuf-3.21.9",
        urls = [
            "https://github.com/protocolbuffers/protobuf/archive/v3.21.9.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "com_github_bazelbuild_buildtools",
        sha256 = "e3bb0dc8b0274ea1aca75f1f8c0c835adbe589708ea89bf698069d0790701ea3",
        strip_prefix = "buildtools-5.1.0",
        urls = [
            "https://github.com/bazelbuild/buildtools/archive/refs/tags/5.1.0.tar.gz",
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

    # 2022-11-08: Retrieving the source archive so that I can use the gazelle
    # plugin. Work is happening to include it in the distribution.
    # https://github.com/bazelbuild/bazel-skylib/pull/400
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 =
            "3b620033ca48fcd6f5ef2ac85e0f6ec5639605fa2f627968490e52fc91a9932f",
        strip_prefix = "bazel-skylib-1.3.0",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/archive/1.3.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "099a9fb96a376ccbbb7d291ed4ecbdfd42f6bc822ab77ae6f1b5cb9e914e94fa",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.35.0/rules_go-v0.35.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.35.0/rules_go-v0.35.0.zip",
        ],
    )

    maybe(
        http_archive,
        name = "bazel_gazelle",
        sha256 = "448e37e0dbf61d6fa8f00aaa12d191745e14f07c31cabfa731f0c8e8a4f41b97",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.28.0/bazel-gazelle-v0.28.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.28.0/bazel-gazelle-v0.28.0.tar.gz",
        ],
    )

    if use_bazeldoc:
        _bazeldoc_dependencies()

    if use_prebuilt_buildtools:
        _prebuilt_buildtools_dependencies()
    else:
        _compile_from_source_buildtools_dependencies()
