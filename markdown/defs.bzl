load(
    "//markdown/private:markdown_check_links_test.bzl",
    _markdown_check_links_test = "markdown_check_links_test",
)
load(
    "//markdown/private:markdown_register_node_deps.bzl",
    _markdown_register_node_deps = "markdown_register_node_deps",
)

markdown_check_links_test = _markdown_check_links_test
markdown_register_node_deps = _markdown_register_node_deps
