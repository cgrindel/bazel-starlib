load("//shlib/rules:execute_binary.bzl", "execute_binary", "file_placeholder")

def generate_release_notes(name, generate_workspace_snippet):
    """Defines an executable target that generates release notes as Github markdown.

    Typically, this macro is used in conjunction with the \
    `generate_workspace_snippet` macro. The `generate_workspace_snippet` \
    defines how to generate the workspace snippet. The resulting target \
    is then referenced by this macro.

    Args:
        name: The name of the executable target as a `string`.
        generate_workspace_snippet: The label that should be executed to
                                    generate the workspace snippet.
    """
    file_arguments = {}
    arguments = []

    file_key = "generate_workspace_snippet"
    arguments.extend(["--generate_workspace_snippet", file_placeholder(file_key)])
    file_arguments[generate_workspace_snippet] = file_key

    execute_binary(
        name = name,
        arguments = arguments,
        file_arguments = file_arguments,
        binary = "@cgrindel_bazel_starlib//bzlrelease/tools:generate_release_notes",
    )
