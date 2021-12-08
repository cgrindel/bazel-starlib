load("//rules:hash_sha256.bzl", "hash_sha256")

def _workspace_snippet_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name + ".bzl")
    ctx.actions.run(
        outputs = [out],
        inputs = [
            ctx.info_file,
            ctx.version_file,
        ],
        executable = ctx.executable._snippet_tool,
        arguments = [
            "--status_file",
            ctx.info_file.path,
            "--status_file",
            ctx.version_file.path,
            "--output",
            out.path,
        ],
    )
    return DefaultInfo(files = depset([out]))

_workspace_snippet = rule(
    implementation = _workspace_snippet_impl,
    attrs = {
        "pkg": attr.label(
            allow_single_file = True,
            doc = "The archive or package file that will be downloaded.",
        ),
        "sha256_file": attr.label(
            allow_single_file = True,
            doc = "A file that contains the SHA256 for the package file.",
        ),
        "_snippet_tool": attr.label(
            default = "@cgrindel_bazel_starlib//tools:generate_workspace_snippet",
            executable = True,
            cfg = "host",
            doc = "The utility used to generate the workspace snippet.",
        ),
    },
    doc = "Generates a workspace snippet for the ",
)

def workspace_snippet(name, pkg):
    hash_name = name + "_pkg_sha256"
    hash_sha256(
        name = hash_name,
        src = pkg,
    )

    _workspace_snippet(
        name = name,
        pkg = pkg,
        sha256_file = hash_name,
    )

# def workspace_snippet(name, pkg, url):
#     hash_name = name + "_sha256"
#     hash_sha256(
#         name = hash_name,
#         src = pkg,
#     )

#     expand_make_vars(
#         name = "bazel_starlib_workspace_snippet",
#         template = "@cgrindel_bazel_starlib//rules/private:workspace_snippet.tmpl",
#         substitutions = {
#             "{WORKSPACE_NAME}": workspac,
#             "{SHA256}": sha256,
#             "{URL}": url,
#         },
#         out = name + ".snippet",
#     )
