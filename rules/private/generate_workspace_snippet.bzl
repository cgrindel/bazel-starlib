load("//rules/private:execute_binary.bzl", "execute_binary", "file_placeholder")

# TODO: Add doc.

def generate_workspace_snippet(name = "generate_workspace_snippet", template = None):
    file_arguments = {}
    arguments = []
    if template != None:
        file_key = "template"
        arguments.extend(["--template", file_placeholder(file_key)])
        file_arguments[template] = file_key

    execute_binary(
        name = name,
        arguments = arguments,
        file_arguments = file_arguments,
        binary = "@cgrindel_bazel_starlib//tools:generate_workspace_snippet",
    )
