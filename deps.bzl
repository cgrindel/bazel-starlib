load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _create_location_from_target(target):
    # If there is no target specified, add it.
    if target.find(":") < 0:
        _, _, pkg_name = target.rpartition("/")
        if pkg_name == target:
            fail("Could not find the package name. {}".format(target))
        target = "{target}:{pkg_name}".format(
            target = target,
            pkg_name = pkg_name,
        )
    return target.replace("@", "").replace("//", "/").replace(":", "/")

def _generate_trampoline_content(repository_ctx, filename, exec_target):
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
        executable_location = _create_location_from_target(exec_target),
    ) + """\
executable="$(rlocation "${executable_location}")" || \\
  (echo >&2 "Failed to locate ${executable_location}" && exit 1)

cmd=( "${executable}" )
[[ ${#} > 0 ]] && cmd+=( "${@}" )
"${cmd[@]}"
"""
    repository_ctx.file(filename, content, True)

def _bazel_starlib_buildtools(repository_ctx):
    _generate_trampoline_content(repository_ctx, "buildifier.sh", repository_ctx.attr.buildifier)
    _generate_trampoline_content(repository_ctx, "buildozer.sh", repository_ctx.attr.buildozer)

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
        buildifier = repository_ctx.attr.buildifier,
        buildozer = repository_ctx.attr.buildozer,
    )
    repository_ctx.file("BUILD.bazel", build_content)

bazel_starlib_buildtools = repository_rule(
    implementation = _bazel_starlib_buildtools,
    attrs = {
        "buildifier": attr.string(
            mandatory = True,
            doc = "The `buildifier` target.",
        ),
        "buildozer": attr.string(
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

    # Buildifier Deps

    if use_prebuilt_buildtools:
        maybe(
            http_archive,
            name = "buildifier_prebuilt",
            sha256 = "6f34c8d18d50d4b697bfe57061d3dfc305e9bb195f8cb66582b62b4a1f0d1ce6",
            strip_prefix = "buildifier-prebuilt-d907e49acfa4655eafb089447af661e2dab95ac7",
            urls = [
                "http://github.com/cgrindel/buildifier-prebuilt/archive/d907e49acfa4655eafb089447af661e2dab95ac7.tar.gz",
            ],
        )
        buildozer_target = "@buildifier_prebuilt//buildozer"
        buildifier_target = "@buildifier_prebuilt//buildifier"
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
        buildifier_target = "@com_github_bazelbuild_buildtools//buildifier"

    bazel_starlib_buildtools(
        name = "bazel_starlib_buildtools",
        buildifier = buildifier_target,
        buildozer = buildozer_target,
    )
