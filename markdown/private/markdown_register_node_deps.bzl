"""Configures the node dependencies for the markdown functionality."""

load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories", "yarn_install")

def markdown_register_node_deps(name = "cgrindel_bazel_starlib_markdown_npm"):
    """Configures the installation of the Javascript node dependencies for the markdown functionality.

    Args:
        name: Optional. The name of the `yarn` repository that will be defined.
    """
    node_repositories(
        node_version = "16.13.2",
        yarn_version = "1.22.17",
    )
    yarn_install(
        name = name,
        package_json = "@cgrindel_bazel_starlib//markdown/private:package.json",
        yarn_lock = "@cgrindel_bazel_starlib//markdown/private:yarn.lock",
    )
