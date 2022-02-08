load("//bzllib:defs.bzl", "src_utils")
load("@bazel_skylib//lib:shell.bzl", "shell")

def _markdown_check_links_test_impl(ctx):
    if ctx.files.srcs == []:
        fail("Expected at least one markdown file to check.")

    files = [ctx.executable._link_checker] + ctx.files.srcs + ctx.files.data
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
""".format(
            config = config_file_path,
            md_link_check = ctx.executable._link_checker.short_path,
            md_files = shell.array_literal([
                src.short_path
                for src in ctx.files.srcs
            ]),
            verbose = ctx.attr.verbose,
        ) + """

# DEBUG BEGIN
set -x
# DEBUG END

cmd=( "${md_link_check}" )
[[ -n "${config_file:-}" ]] && cmd+=( -c "${config_file}" )
[[ "${verbose}" == "True" ]] && cmd+=( -v )
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
            mandatory = True,
            doc = "The markdown files that should be checked.",
        ),
        "config": attr.label(
            allow_single_file = True,
            doc = "A `markdown-link-check` JSON configuration file.",
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
        "_link_checker": attr.label(
            default = "@npm//markdown-link-check/bin:markdown-link-check",
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

# # TODO: Add doc comment
# def markdown_check_links_tests(name, srcs, **kwargs):
#     for src in srcs:
#         test_name = src_utils.path_to_name(src, prefix = name)
#         markdown_check_links_test(
#             name = test_name,
#             src = src,
#             **kwargs
#         )
