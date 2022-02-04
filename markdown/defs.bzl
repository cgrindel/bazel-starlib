load(
    "//markdown/private:markdown_link_check.bzl",
    _markdown_link_check = "markdown_link_check",
)

package(default_visibility = ["//visibility:public"])

markdown_link_check = _markdown_link_check
