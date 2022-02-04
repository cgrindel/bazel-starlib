def _markdown_link_check_impl(ctx):
    pass

markdown_link_check = rule(
    implementation = _markdown_link_check_impl,
    test = True,
    attrs = {
        "_link_checker": attr.label(
            default = "@npm//markdown-link-check/bin:markdown-link-check",
            executable = True,
            cfg = "host",
            doc = "The link checker utility.",
        ),
    },
    doc = "",
)
