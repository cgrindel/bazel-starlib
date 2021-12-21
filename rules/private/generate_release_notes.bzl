load("//rules/private:execute_binary.bzl", "execute_binary", "file_placeholder")

def generate_release_notes(name = "generate_release_notes", generate_workspace_snippet = None):
    file_args = {}
    args = []
    if generate_workspace_snippet != None:
        file_key = "generate_workspace_snippet"
        args.extend(["--generate_workspace_snippet", file_placeholder(file_key)])
        file_args[generate_workspace_snippet] = file_key

    execute_binary(
        name = name,
        args = args,
        file_args = file_args,
        binary = "@cgrindel_bazel_starlib//tools:generate_release_notes",
    )
