load("//shlib/rules:execute_binary.bzl", "execute_binary", "file_placeholder")

def update_readme(name, generate_workspace_snippet, readme = None):
    """Declares an executable target that updates a README.md with an updated workspace snippet.

    The utility will replace the lines between `<!-- BEGIN WORKSPACE SNIPPET -->` and \
    `<!-- END WORKSPACE SNIPPET -->` with the workspace snippet provided by the \
    `generate_workspace_snippet` utility that is provided.

    Args:
        name: The name of the executable target as a `string`.
        generate_workspace_snippet: The label that should be executed to
                                    generate the workspace snippet.
        readme: A `string` representing the relative path to the README.md
                file from the root of the workspace.
    """
    file_arguments = {}
    arguments = []

    file_key = "generate_workspace_snippet"
    arguments.extend(["--generate_workspace_snippet", file_placeholder(file_key)])
    file_arguments[generate_workspace_snippet] = file_key

    if readme != None:
        arguments.extend(["--readme", readme])

    execute_binary(
        name = name,
        arguments = arguments,
        file_arguments = file_arguments,
        binary = "@cgrindel_bazel_starlib//bzlrelease/tools:update_readme",
    )
