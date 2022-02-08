def _markdown_check_links_test_impl(ctx):
    files = [ctx.file.src, ctx.executable._link_checker] + ctx.files.data
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
md_file="{md_file}"
verbose="{verbose}"
""".format(
            config = config_file_path,
            md_link_check = ctx.executable._link_checker.short_path,
            md_file = ctx.file.src.short_path,
            verbose = ctx.attr.verbose,
        ) + """

# DEBUG BEGIN
# tree >&2 -d
# echo >&2 "*** CHUCK $(basename "${BASH_SOURCE[0]}") PWD: ${PWD}" 
# echo >&2 "*** CHUCK $(basename "${BASH_SOURCE[0]}") verbose: ${verbose}" 
# set -x
# DEBUG END

cmd=( "${md_link_check}" )
[[ -n "${config_file:-}" ]] && cmd+=( -c "${config_file}" )
[[ "${verbose}" == "True" ]] && cmd+=( -v )
cmd+=( "${md_file}" )
"${cmd[@]}"
""",
    )

    return [DefaultInfo(executable = check_links_sh, runfiles = runfiles)]

markdown_check_links_test = rule(
    implementation = _markdown_check_links_test_impl,
    test = True,
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The markdown file that should be checked.",
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
    doc = "Check the links in a markdown file to ensure that they are valid.",
)

# def markdown_check_links_test(name, src, config = None, **kwargs):
#     _markdown_check_links_test(
#         name = name,
#         src = src,
#         config = config,
#         local = True,
#         **kwargs
#     )
