"""Definition for generate_release_notes macro."""

load("//shlib/rules:execute_binary.bzl", "execute_binary", "file_placeholder")

def generate_release_notes(
        name,
        generate_workspace_snippet = None,
        generate_module_snippet = None):
    """Defines an executable target that generates release notes as Github markdown.

    Typically, this macro is used in conjunction with the \
    `generate_workspace_snippet` macro. The `generate_workspace_snippet` \
    defines how to generate the workspace snippet. The resulting target \
    is then referenced by this macro.

    Args:
        name: The name of the executable target as a `string`.
        generate_workspace_snippet: Optional.The label that should be executed to
            generate the workspace snippet.
        generate_module_snippet: Optional.The label that should be executed to
            generate the Bazel module snippet.
    """
    file_arguments = {}
    arguments = []

    if generate_workspace_snippet != None:
        file_key = "generate_workspace_snippet"
        arguments.extend(["--generate_workspace_snippet", file_placeholder(file_key)])
        file_arguments[generate_workspace_snippet] = file_key
    if generate_module_snippet != None:
        file_key = "generate_module_snippet"
        arguments.extend(["--generate_module_snippet", file_placeholder(file_key)])
        file_arguments[generate_module_snippet] = file_key

    execute_binary(
        name = name,
        arguments = arguments,
        file_arguments = file_arguments,
        binary = "@cgrindel_bazel_starlib//bzlrelease/tools:generate_release_notes",
    )
