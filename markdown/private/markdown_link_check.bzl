def _markdown_link_check_impl(ctx):
    check_links_sh = ctx.actions.declare_file(
        ctx.label.name + "_check_links.sh",
    )
    runfiles = ctx.runfiles(
        files = [ctx.file.src, ctx.executable._link_checker],
    )

    return [DefaultInfo(executable = check_links_sh, runfiles = runfiles)]

markdown_link_check = rule(
    implementation = _markdown_link_check_impl,
    test = True,
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The markdown file that should be checked.",
        ),
        "_link_checker": attr.label(
            default = "@npm//markdown-link-check/bin:markdown-link-check",
            executable = True,
            cfg = "host",
            doc = "The link checker utility.",
        ),
    },
    doc = "Check the links in a markdown file to ensure that they are valid.",
)
