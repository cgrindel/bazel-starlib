load("//rules/private:execute_binary.bzl", "execute_binary", "file_placeholder")

def generate_release_notes(name = "generate_release_notes", snippet_template = None):
    file_arguments = {}
    arguments = []
    if snippet_template != None:
        file_key = "snippet_template"
        arguments.extend(["--snippet_template", file_placeholder(file_key)])
        file_arguments[snippet_template] = file_key

    execute_binary(
        name = name,
        arguments = arguments,
        file_arguments = file_arguments,
        binary = "@cgrindel_bazel_starlib//tools:generate_release_notes",
    )
