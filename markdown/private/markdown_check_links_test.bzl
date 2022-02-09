load("//bzllib:defs.bzl", "src_utils")
load("@bazel_skylib//lib:shell.bzl", "shell")

def _markdown_check_links_test_impl(ctx):
    if ctx.files.srcs == [] and ctx.files.data == []:
        fail("No files were specified in the srcs or the data.")

    # If no srcs were provided, assume that we are testing every markdown file
    # provided in the data.
    if ctx.files.srcs == []:
        srcs = [
            d
            for d in ctx.files.data
            if d.extension == "md" or d.extension == "markdown"
        ]
    else:
        srcs = ctx.files.srcs

    files = [ctx.executable._link_checker] + srcs + ctx.files.data
    if ctx.file.config != None:
        files.append(ctx.file.config)

    runfiles = ctx.runfiles(files = files).merge_all([
        ctx.attr._link_checker[DefaultInfo].default_runfiles,
    ])

    config_file_path = ""
    if ctx.file.config != None:
        config_file_path = ctx.file.config.short_path

    check_links_sh = ctx.actions.declare_file(
        ctx.label.name + "_check_links.sh",
    )
    ctx.actions.write(
        output = check_links_sh,
        is_executable = True,
        content = """
#!/usr/bin/env bash

set -euo pipefail

""" + """
config_file="{config}"
md_link_check="{md_link_check}"
md_files={md_files}
verbose="{verbose}"
quiet="{quiet}"
""".format(
            config = config_file_path,
            md_link_check = ctx.executable._link_checker.short_path,
            md_files = shell.array_literal([
                src.short_path
                for src in srcs
            ]),
            verbose = ctx.attr.verbose,
            quiet = ctx.attr.quiet,
        ) + """

cmd=( "${md_link_check}" )
[[ "${verbose}" == "True" ]] && cmd+=( -v )
[[ "${quiet}" == "True" ]] && cmd+=( -q )
[[ -n "${config_file:-}" ]] && cmd+=( -c "${config_file}" )
cmd+=( "${md_files[@]}" )
"${cmd[@]}"
""",
    )

    return [DefaultInfo(executable = check_links_sh, runfiles = runfiles)]

markdown_check_links_test = rule(
    implementation = _markdown_check_links_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".md", ".markdown"],
            doc = """\
The markdown files that should be checked. If no srcs are provided, all of \
the markdown files (.md, .markdown) in the `data` will be checked.\
""",
        ),
        "config": attr.label(
            allow_single_file = True,
            doc = "A `markdown-link-check` JSON configuration file.",
            default = "@cgrindel_bazel_starlib//markdown:default_markdown_link_check_config",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = """\
Any data files that need to be present for the link check to succeed.\
""",
        ),
        "verbose": attr.bool(
            doc = """\
If set to true, the markdown-link-check will be configured for verbose output.\
""",
        ),
        "quiet": attr.bool(
            default = True,
            doc = """\
If set to true, the markdown-link-check will be configured to only display \
errors.\
""",
        ),
        "_link_checker": attr.label(
            default = "@cgrindel_bazel_starlib_markdown_npm//markdown-link-check/bin:markdown-link-check",
            executable = True,
            cfg = "host",
            doc = "The link checker utility.",
        ),
    },
    doc = """\
Using [`markdown-link-check`](https://github.com/tcort/markdown-link-check), \
check the links in a markdown file to ensure that they are valid.\
""",
)
