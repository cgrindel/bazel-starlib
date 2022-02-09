load(
    "//markdown/private:markdown_check_links_test.bzl",
    _markdown_check_links_test = "markdown_check_links_test",
)
load(
    "//markdown/private:markdown_register_node_deps.bzl",
    _markdown_register_node_deps = "markdown_register_node_deps",
)
load(
    "//markdown/private:markdown_generate_toc.bzl",
    _markdown_generate_toc = "markdown_generate_toc",
)
load(
    "//markdown/private:markdown_pkg.bzl",
    _markdown_pkg = "markdown_pkg",
)

markdown_check_links_test = _markdown_check_links_test
markdown_register_node_deps = _markdown_register_node_deps
markdown_generate_toc = _markdown_generate_toc
markdown_pkg = _markdown_pkg
