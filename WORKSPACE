workspace(name = "cgrindel_bazel_starlib")

load("//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# MARK: - Prebuilt Buildtools Deps

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

# MARK: - NodeJS Deps

load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")

build_bazel_rules_nodejs_dependencies()

load("//markdown:defs.bzl", "markdown_register_node_deps")

markdown_register_node_deps()

# MARK: - Golang Deps (gh-md-toc)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("//markdown:deps.bzl", "bazel_starlib_markdown_dependencies")

bazel_starlib_markdown_dependencies()

go_rules_dependencies()

go_register_toolchains(version = "1.17.6")

gazelle_dependencies()

# MARK: - Integration Testing

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "contrib_rules_bazel_integration_test",
    sha256 = "6057e4ae6d1c80c129877d11c61b1fee1c05bb24334d0ab1810ce3ecdf24abf4",
    strip_prefix = "rules_bazel_integration_test-0.6.1",
    urls = [
        "http://github.com/bazel-contrib/rules_bazel_integration_test/archive/v0.6.1.tar.gz",
    ],
)

load("@contrib_rules_bazel_integration_test//bazel_integration_test:deps.bzl", "bazel_integration_test_rules_dependencies")

bazel_integration_test_rules_dependencies()

load("@contrib_rules_bazel_integration_test//bazel_integration_test:defs.bzl", "bazel_binaries")
load("//:bazel_versions.bzl", "SUPPORTED_BAZEL_VERSIONS")

bazel_binaries(versions = SUPPORTED_BAZEL_VERSIONS)
