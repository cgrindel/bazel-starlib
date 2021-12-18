load("//rules/private:execute_binary.bzl", "execute_binary", "file_placeholder")

def generate_release_notes(name = "generate_release_notes", workspace_init_example_file = None):
    file_args = {}
    args = []
    data = []
    if workspace_init_example_file != None:
        file_key = "workspace_init_example_file"
        args.extend(["--workspace_init_example_file", file_placeholder(file_key)])
        file_args[workspace_init_example_file] = file_key
        data.append(workspace_init_example_file)

    execute_binary(
        name = name,
        args = args,
        data = data,
        file_args = file_args,
        binary = "@cgrindel_bazel_starlib//tools:generate_release_notes",
    )
