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

def _markdown_dependencies():
    # GH140: Temporarily disable markdown while adding support for
    # --incompatible_disallow_empty_glob.

    # maybe(
    #     http_archive,
    #     name = "build_bazel_rules_nodejs",
    #     sha256 = "e328cb2c9401be495fa7d79c306f5ee3040e8a03b2ebb79b022e15ca03770096",
    #     urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.4.2/rules_nodejs-5.4.2.tar.gz"],
    # )

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
        sha256 = "de69a09dc70417580aabf20a28619bb3ef60d038470c7cf8442fafcf627c21cb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "ekalinin_github_markdown_toc",
        sha256 = "6bfeab2b28e5c7ad1d5bee9aa6923882a01f56a7f2d0f260f01acde2111f65af",
        strip_prefix = "github-markdown-toc.go-1.2.0",
        urls = ["https://github.com/ekalinin/github-markdown-toc.go/archive/refs/tags/1.2.0.tar.gz"],
        build_file_content = """\
load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")

go_binary(
    name = "gh_md_toc",
    srcs = glob(["*.go"], exclude = ["*_test.go"]),
    deps = [
        "@in_gopkg_alecthomas_kingpin_v2//:go_default_library",
    ],
    visibility = ["//visibility:public"],
)
""",
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
        sha256 = "de69a09dc70417580aabf20a28619bb3ef60d038470c7cf8442fafcf627c21cb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
        ],
    )

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
        use_bazeldoc = True,
        use_markdown = True):
    """Declares the dependencies for bazel-starlib.

    Args:
        use_prebuilt_buildtools: A `bool` specifying whether to use a prebuilt
                                 version of `bazelbuild/buildtools`.
        use_bazeldoc: A `bool` specifying whether the `bazeldoc` dependencies
                      should be loaded.
        use_markdown: A `bool` specifying whether the `markdown` depdendencies
                      should be loaded.
    """
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
        ],
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
    )

    if use_bazeldoc:
        _bazeldoc_dependencies()

    if use_markdown:
        _markdown_dependencies()

    if use_prebuilt_buildtools:
        _prebuilt_buildtools_dependencies()
    else:
        _compile_from_source_buildtools_dependencies()
