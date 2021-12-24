load("//rules/private:execute_binary.bzl", "execute_binary", "file_placeholder")

def update_readme(name, generate_workspace_snippet, readme = None):
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
        binary = "@cgrindel_bazel_starlib//tools:update_readme",
    )
