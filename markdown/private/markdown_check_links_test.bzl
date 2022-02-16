load("//bzllib:defs.bzl", "src_utils")
load("@bazel_skylib//lib:shell.bzl", "shell")

def _markdown_check_links_test_impl(ctx):
    if ctx.files.srcs == [] and ctx.files.data == []:
        fail("No files were specified in the srcs or the data.")

    if ctx.attr.max_econnreset_retry_count < 0:
        fail("The `max_econnreset_retry_count` must be greater than or equal to 0.")

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

    runfiles = ctx.runfiles(files = files).merge(
        ctx.attr._link_checker[DefaultInfo].default_runfiles,
    )

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
link_checker="{link_checker}"
md_files={md_files}
verbose="{verbose}"
quiet="{quiet}"
max_econnreset_retry_count={max_econnreset_retry_count}
""".format(
            config = config_file_path,
            link_checker = ctx.executable._link_checker.short_path,
            md_files = shell.array_literal([
                src.short_path
                for src in srcs
            ]),
            verbose = ctx.attr.verbose,
            quiet = ctx.attr.quiet,
            max_econnreset_retry_count = ctx.attr.max_econnreset_retry_count,
        ) + """

cmd=( "${link_checker}" --max_econnreset_retry_count ${max_econnreset_retry_count} )
[[ "${verbose}" == "True" ]] && cmd+=( --verbose )
[[ "${quiet}" == "True" ]] && cmd+=( --quiet )
[[ -n "${config_file:-}" ]] && cmd+=( --config "${config_file}" )
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
        "max_econnreset_retry_count": attr.int(
            default = 3,
            doc = "The maximum number of times to retry on an ECONNRESET error.",
        ),
        "_link_checker": attr.label(
            default = "@cgrindel_bazel_starlib//markdown/tools:check_links",
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
