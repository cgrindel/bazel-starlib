workspace(name = "cgrindel_bazel_starlib")

load("//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

# gazelle:repo bazel_gazelle
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("//markdown:deps.bzl", "bazel_starlib_markdown_dependencies")

bazel_starlib_markdown_dependencies()

# load("//:markdown/github_markdown_toc_go_repositories.bzl", "github_markdown_toc_go_repositories")
# # gazelle:repository_macro markdown/github_markdown_toc_go_repositories.bzl%github_markdown_toc_go_repositories
# github_markdown_toc_go_repositories()

go_rules_dependencies()

go_register_toolchains(version = "1.19.1")

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

# GH140: Temporarily disable markdown while adding support for
# --incompatible_disallow_empty_glob.

# # MARK: - NodeJS Deps

# load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")

# build_bazel_rules_nodejs_dependencies()

# load("//markdown:defs.bzl", "markdown_register_node_deps")

# markdown_register_node_deps()

# MARK: - Integration Testing

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

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
