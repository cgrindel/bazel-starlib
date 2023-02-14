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

http_archive(
    name = "contrib_rules_bazel_integration_test",
    sha256 = "a10fae360743bad8fa07b2a7ddd406297287374d3edc938c2dbae5fce6186ee0",
    strip_prefix = "rules_bazel_integration_test-0.10.2",
    urls = [
        "http://github.com/bazel-contrib/rules_bazel_integration_test/archive/v0.10.2.tar.gz",
    ],
)

load("@contrib_rules_bazel_integration_test//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("@contrib_rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")
load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
