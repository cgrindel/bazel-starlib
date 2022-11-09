"""Public API for markdown."""

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
