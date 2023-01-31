"""Definition for generate_workspace_snippet macro."""

load("//shlib/rules:execute_binary.bzl", "execute_binary", "file_placeholder")

def generate_workspace_snippet(
        name,
        template = None,
        workspace_name = None,
        sha256_file = None,
        url_templates = []):
    """Defines an executable target that generates a workspace snippet suitable \
    for inclusion in a markdown document.

    Without a template, the utility will output an `http_archive` declaration. \
    With a template, the utility will output the template replacing \
    `${http_archive_statement}` with the `http_archive` declaration.

    Args:
        name: The name of the executable target as a `string`.
        template: Optional. The path to a template file  as a `string`.
        workspace_name: Optional. The name of the workspace. If not provided,
            the workspace name is derived from the owner and repository name.
        sha256_file: Optional. The path to a file with the SHA256 value for the
            release archive.
        url_templates: Optional. A `list` of templates to use when generating
            the URL values for the release archive.
    """
    file_arguments = {}
    arguments = []
    if template != None:
        file_key = "template"
        arguments.extend(["--template", file_placeholder(file_key)])
        file_arguments[template] = file_key
    if workspace_name != None:
        arguments.extend(["--workspace_name", workspace_name])
    if sha256_file != None:
        # If you give us a SHA256 file, then we assume that you do not want the
        # source archive.
        arguments.append("--no_github_source_archive_url")
        file_key = "sha256_file"
        arguments.extend(["--sha256_file", file_placeholder(file_key)])
        file_arguments[sha256_file] = file_key
    for url_template in url_templates:
        # Need to escape the dollar signs so that they will pass through the
        # shell.
        url_template = url_template.replace("$", "\\$")
        arguments.extend(["--url", url_template])

    execute_binary(
        name = name,
        arguments = arguments,
        file_arguments = file_arguments,
        binary = "@cgrindel_bazel_starlib//bzlrelease/tools:generate_workspace_snippet",
    )
