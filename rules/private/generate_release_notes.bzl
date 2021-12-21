load("//rules/private:execute_binary.bzl", "execute_binary", "file_placeholder")

def generate_release_notes(name = "generate_release_notes", snippet_template = None):
    file_args = {}
    args = []
    if snippet_template != None:
        file_key = "snippet_template"
        args.extend(["--snippet_template", file_placeholder(file_key)])
        file_args[snippet_template] = file_key

    execute_binary(
        name = name,
        args = args,
        file_args = file_args,
        binary = "@cgrindel_bazel_starlib//tools:generate_release_notes",
    )
