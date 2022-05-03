"""Public API for markdown."""

# GH140: Temporarily disable markdown while adding support for
# --incompatible_disallow_empty_glob.

# load(
#     "//markdown/private:markdown_check_links_test.bzl",
#     _markdown_check_links_test = "markdown_check_links_test",
# )

# markdown_check_links_test = _markdown_check_links_test
# markdown_register_node_deps = _markdown_register_node_deps

load(
    "//markdown/private:markdown_generate_toc.bzl",
    _markdown_generate_toc = "markdown_generate_toc",
)
load(
    "//markdown/private:markdown_pkg.bzl",
    _markdown_pkg = "markdown_pkg",
)

markdown_generate_toc = _markdown_generate_toc
markdown_pkg = _markdown_pkg
