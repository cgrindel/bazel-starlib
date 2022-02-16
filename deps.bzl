load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _generate_trampoline_content(repository_ctx, filename, exec_target, exec_location):
    content = """\
#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \\
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \\
  source "$0.runfiles/$f" 2>/dev/null || \\
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \\
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \\
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

""" + """\
executable_location={executable_location}
""".format(
        executable_location = exec_location,
    ) + """\
executable="$(rlocation "${executable_location}")" || \\
  (echo >&2 "Failed to locate ${executable_location}" && exit 1)

cmd=( "${executable}" )
[[ ${#} > 0 ]] && cmd+=( "${@}" )
"${cmd[@]}"
"""
    repository_ctx.file(filename, content, True)

def _bazel_starlib_buildtools(repository_ctx):
    _generate_trampoline_content(
        repository_ctx,
        "buildifier.sh",
        repository_ctx.attr.buildifier_target,
        repository_ctx.attr.buildifier_location,
    )
    _generate_trampoline_content(
        repository_ctx,
        "buildozer.sh",
        repository_ctx.attr.buildozer_target,
        repository_ctx.attr.buildozer_location,
    )

    build_content = """\
package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "buildifier",
    srcs = ["buildifier.sh"],
    data = ["{buildifier}"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

sh_binary(
    name = "buildozer",
    srcs = ["buildozer.sh"],
    data = ["{buildozer}"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)
""".format(
        buildifier = repository_ctx.attr.buildifier_target,
        buildozer = repository_ctx.attr.buildozer_target,
    )
    repository_ctx.file("BUILD.bazel", build_content)

bazel_starlib_buildtools = repository_rule(
    implementation = _bazel_starlib_buildtools,
    attrs = {
        "buildifier_target": attr.string(
            mandatory = True,
            doc = "The `buildifier` target.",
        ),
        "buildifier_location": attr.string(
            mandatory = True,
            doc = "The `buildifier` location in runfiles.",
        ),
        "buildozer_target": attr.string(
            mandatory = True,
            doc = "The `buildozer` target.",
        ),
        "buildozer_location": attr.string(
            mandatory = True,
            doc = "The `buildozer` target.",
        ),
    },
)

def bazel_starlib_dependencies(use_prebuilt_buildtools = True):
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    )

    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "c9794dcc8026a30ff67cf7cf91ebe245ca294b20b071845d12c192afe243ad72",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "cgrindel_rules_bazel_integration_test",
        sha256 = "39071d2ec8e3be74c8c4a6c395247182b987cdb78d3a3955b39e343ece624982",
        strip_prefix = "rules_bazel_integration_test-0.5.0",
        urls = [
            "http://github.com/cgrindel/rules_bazel_integration_test/archive/v0.5.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "build_bazel_rules_nodejs",
        sha256 = "c077680a307eb88f3e62b0b662c2e9c6315319385bc8c637a861ffdbed8ca247",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.1.0/rules_nodejs-5.1.0.tar.gz"],
    )

    # maybe(
    #     http_archive,
    #     name = "ekalinin_github_markdown_toc",
    #     sha256 = "7f6079026a32c03d6e7254e5921b94f6802c2d52c9d74d85a1f8015d864b58d0",
    #     strip_prefix = "github-markdown-toc-0.8.0",
    #     urls = ["https://github.com/ekalinin/github-markdown-toc/archive/refs/tags/0.8.0.tar.gz"],
    #     build_file_content = """\
    # sh_binary(
    # name = "gh_md_toc",
    # srcs = ["gh-md-toc"],
    # visibility = ["//visibility:public"],
    # )
    # """,
    # )

    maybe(
        http_archive,
        name = "io_bazel_rules_go",
        sha256 = "d6b2513456fe2229811da7eb67a444be7785f5323c6708b38d851d2b51e54d83",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.30.0/rules_go-v0.30.0.zip",
            "https://github.com/bazelbuild/rules_go/releases/download/v0.30.0/rules_go-v0.30.0.zip",
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

    # Buildifier Deps

    if use_prebuilt_buildtools:
        maybe(
            http_archive,
            name = "buildifier_prebuilt",
            sha256 = "49b7edf3490c13eae5b4b8aa98ed051fdd4f1b8dd60276d818e4f559614bf083",
            strip_prefix = "buildifier-prebuilt-0.2.0",
            urls = [
                "http://github.com/keith/buildifier-prebuilt/archive/0.2.0.tar.gz",
            ],
        )
        buildozer_target = "@buildifier_prebuilt//buildozer"
        buildozer_location = "buildifier_prebuilt/buildozer/buildozer"
        buildifier_target = "@buildifier_prebuilt//buildifier"
        buildifier_location = "buildifier_prebuilt/buildifier/buildifier"
    else:
        maybe(
            http_archive,
            name = "io_bazel_rules_go",
            sha256 = "2b1641428dff9018f9e85c0384f03ec6c10660d935b750e3fa1492a281a53b0f",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.29.0/rules_go-v0.29.0.zip",
                "https://github.com/bazelbuild/rules_go/releases/download/v0.29.0/rules_go-v0.29.0.zip",
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
            sha256 = "9b4ee22c250fe31b16f1a24d61467e40780a3fbb9b91c3b65be2a376ed913a1a",
            strip_prefix = "protobuf-3.13.0",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v3.13.0.tar.gz",
            ],
        )

        maybe(
            http_archive,
            name = "com_github_bazelbuild_buildtools",
            sha256 = "ae34c344514e08c23e90da0e2d6cb700fcd28e80c02e23e4d5715dddcb42f7b3",
            strip_prefix = "buildtools-4.2.2",
            urls = [
                "https://github.com/bazelbuild/buildtools/archive/refs/tags/4.2.2.tar.gz",
            ],
        )

        buildozer_target = "@com_github_bazelbuild_buildtools//buildozer"
        buildozer_location = "com_github_bazelbuild_buildtools/buildozer/buildozer_/buildozer"
        buildifier_target = "@com_github_bazelbuild_buildtools//buildifier"
        buildifier_location = "com_github_bazelbuild_buildtools/buildifier/buildifier_/buildifier"

    bazel_starlib_buildtools(
        name = "bazel_starlib_buildtools",
        buildifier_target = buildifier_target,
        buildifier_location = buildifier_location,
        buildozer_target = buildozer_target,
        buildozer_location = buildozer_location,
    )
