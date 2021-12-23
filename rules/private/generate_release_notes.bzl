load("//rules/private:execute_binary.bzl", "execute_binary", "file_placeholder")

def generate_release_notes(name = "generate_release_notes", generate_workspace_snippet = None):
    file_arguments = {}
    arguments = []
    if generate_workspace_snippet != None:
        file_key = "generate_workspace_snippet"
        arguments.extend(["--generate_workspace_snippet", file_placeholder(file_key)])
        file_arguments[generate_workspace_snippet] = file_key

    execute_binary(
        name = name,
        arguments = arguments,
        file_arguments = file_arguments,
        binary = "@cgrindel_bazel_starlib//tools:generate_release_notes",
    )
