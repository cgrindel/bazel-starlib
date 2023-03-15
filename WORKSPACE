# This file marks the root of the Bazel workspace.
# See MODULE.bazel for dependencies and setup.

workspace(name = "cgrindel_bazel_starlib")

load("//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

# gazelle:repo bazel_gazelle
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("//:go_deps.bzl", "bazel_starlib_go_dependencies")

# gazelle:repository_macro go_deps.bzl%bazel_starlib_go_dependencies
bazel_starlib_go_dependencies()

# MARK: - Skylib Gazelle Extension

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib_gazelle_plugin",
    sha256 = "0a466b61f331585f06ecdbbf2480b9edf70e067a53f261e0596acd573a7d2dc3",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-gazelle-plugin-1.4.1.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-gazelle-plugin-1.4.1.tar.gz",
    ],
)

load("@bazel_skylib_gazelle_plugin//:workspace.bzl", "bazel_skylib_gazelle_plugin_workspace")

bazel_skylib_gazelle_plugin_workspace()

go_rules_dependencies()

go_register_toolchains(version = "1.19.5")

gazelle_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# MARK: - Prebuilt Buildtools Deps

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

# MARK: - Integration Testing

# TODO(chuck): Update with latest release of rules_bazel_integration_test.

# http_archive(
#     name = "rules_bazel_integration_test",
#     sha256 = "6263b8d85a125e1877c463bf4d692bebc2b6479c924f64a3d45c81fbfbc495df",
#     strip_prefix = "rules_bazel_integration_test-0.10.3",
#     urls = [
#         "http://github.com/bazel-contrib/rules_bazel_integration_test/archive/v0.10.3.tar.gz",
#     ],
# )
local_repository(
    name = "rules_bazel_integration_test",
    path = "/Users/chuck/code/bazel-contrib/rules_bazel_integration_test/gh125_reduce_bzlmod_boilerplate",
)

load("@rules_bazel_integration_test//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load(
    "@rules_bazel_integration_test//bazel_integration_test/bzlmod:workspace_bazel_binaries.bzl",
    "workspace_bazel_binaries",
)

# This is only necessary while bazel-starlib switches back and forth between WORKSPACE repositories
# and bzlmod repositories.
workspace_bazel_binaries(name = "bazel_binaries")

load("@rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")
load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
