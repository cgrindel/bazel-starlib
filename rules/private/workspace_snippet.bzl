load("//rules:hash_sha256.bzl", "hash_sha256")

def _workspace_snippet_impl(ctx):
    workspace_name = ctx.attr.workspace_name
    if workspace_name == "":
        workspace_name = ctx.workspace_name

    out = ctx.actions.declare_file(ctx.label.name + ".bzl")

    args = ctx.actions.args()
    args.add("--status_file", ctx.info_file)
    args.add("--status_file", ctx.version_file)
    args.add("--output", out)
    args.add("--sha256_file", ctx.file.sha256_file)
    args.add("--workspace_name", workspace_name)
    for url_template in ctx.attr.url_templates:
        args.add("--url", url_template)

    ctx.actions.run(
        outputs = [out],
        inputs = [
            ctx.info_file,
            ctx.version_file,
            ctx.file.sha256_file,
        ],
        executable = ctx.executable._snippet_tool,
        arguments = [args],
    )

    return DefaultInfo(
        files = depset([out]),
        # To ensure that passing the outputs of this rule to a sh_binary or
        # sh_test data attribute works, we need to put the output in the
        # runfiles.
        # Bazel issue: https://github.com/bazelbuild/bazel/issues/4519
        runfiles = ctx.runfiles(files = [out]),
    )

_workspace_snippet = rule(
    implementation = _workspace_snippet_impl,
    attrs = {
        "pkg": attr.label(
            allow_single_file = True,
            doc = "The archive or package file that will be downloaded.",
            mandatory = True,
        ),
        "sha256_file": attr.label(
            allow_single_file = True,
            doc = "A file that contains the SHA256 for the package file.",
            mandatory = True,
        ),
        "url_templates": attr.string_list(
            mandatory = True,
            doc = """\
A list of URL templates that will be evaluated and the results added as \
download URLs in the snippet.\
""",
        ),
        "workspace_name": attr.string(
            doc = """\
The name of the workspace in the snippet. The current workspace name will be \
used if one is not provided.\
""",
        ),
        "_snippet_tool": attr.label(
            default = "@cgrindel_bazel_starlib//tools:generate_workspace_snippet",
            executable = True,
            cfg = "host",
            doc = "The utility used to generate the workspace snippet.",
        ),
    },
    doc = "Generates a workspace snippet.",
)

def workspace_snippet(name, pkg, url_templates, workspace_name = None, **kwargs):
    """Generates a workspace snippet for the download of a Bazel workspace.

    Args:
        name: The name for the label as a `string`.
        pkg: A file or `Label` for the package file to be downloaded.
        url_templates: A `list` of `string` values that are templates for the
                       download URLs.
        workspace_name: Optional. The name of the workspace in the snippet, as
                        a `string`.
    """

    # Generate a hash value for the package.
    hash_name = name + "_pkg_sha256"
    hash_sha256(
        name = hash_name,
        src = pkg,
    )

    # Generate the workspace snippet
    _workspace_snippet(
        name = name,
        pkg = pkg,
        sha256_file = hash_name,
        url_templates = url_templates,
        workspace_name = workspace_name,
        **kwargs
    )
