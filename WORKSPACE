workspace(name = "cgrindel_bazel_starlib")

load("//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

# gazelle:repo bazel_gazelle
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("//:go_deps.bzl", "bazel_starlib_go_dependencies")

# gazelle:repository_macro go_deps.bzl%bazel_starlib_go_dependencies
bazel_starlib_go_dependencies()

go_rules_dependencies()

go_register_toolchains(version = "1.19.1")

gazelle_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# Starlark Gazelle Extension

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# http_archive(
#     name = "bazel_skylib_gazelle_plugin",
#     sha256 = "3b620033ca48fcd6f5ef2ac85e0f6ec5639605fa2f627968490e52fc91a9932f",
#     # strip_prefix = "bazel-skylib-1.3.0/gazelle",
#     strip_prefix = "bazel-skylib-1.3.0",
#     urls = [
#         "https://github.com/bazelbuild/bazel-skylib/archive/1.3.0.tar.gz",
#     ],
# )

# load("@bazel_skylib_gazelle_plugin//:workspace.bzl", "bazel_skylib_gazelle_plugin_workspace")

# bazel_skylib_gazelle_plugin_workspace()

# load("@bazel_skylib_gazelle_plugin//:setup.bzl", "bazel_skylib_gazelle_plugin_setup")

# bazel_skylib_gazelle_plugin_setup()

# MARK: - Prebuilt Buildtools Deps

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

# MARK: - Integration Testing

http_archive(
    name = "contrib_rules_bazel_integration_test",
    sha256 = "0259d529d1a056025f19269aa911633e5c0e86ca9292d405fa513bb0ea4f1abc",
    strip_prefix = "rules_bazel_integration_test-0.8.0",
    urls = [
        "http://github.com/bazel-contrib/rules_bazel_integration_test/archive/v0.8.0.tar.gz",
    ],
)

load("@contrib_rules_bazel_integration_test//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("@contrib_rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")
load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
