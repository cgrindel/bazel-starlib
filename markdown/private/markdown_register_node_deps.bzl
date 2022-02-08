load("@build_bazel_rules_nodejs//:index.bzl", "yarn_install")

def markdown_register_node_deps(name = "cgrindel_bazel_starlib_markdown_npm"):
    yarn_install(
        name = name,
        package_json = "@cgrindel_bazel_starlib//markdown/private:package.json",
        yarn_lock = "@cgrindel_bazel_starlib//markdown/private:yarn.lock",
    )
