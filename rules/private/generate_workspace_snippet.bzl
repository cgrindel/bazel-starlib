load("//rules/private:execute_binary.bzl", "execute_binary", "file_placeholder")

# TODO: Add doc.

def generate_workspace_snippet(name = "generate_workspace_snippet", template = None):
    file_args = {}
    args = []
    if template != None:
        file_key = "template"
        args.extend(["--template", file_placeholder(file_key)])
        file_args[template] = file_key

    execute_binary(
        name = name,
        args = args,
        file_args = file_args,
        binary = "@cgrindel_bazel_starlib//tools:generate_workspace_snippet",
    )
