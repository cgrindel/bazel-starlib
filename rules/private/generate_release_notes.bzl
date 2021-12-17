load("//rules:execute_binary.bzl", "execute_binary")

def generate_release_notes(name = "generate_release_notes", workspace_init_example_file = None):
    args = []
    data = []
    if workspace_init_example_file != None:
        args.extend(["--workspace_init_example_file", workspace_init_example_file])
        data.append(workspace_init_example_file)

    execute_binary(
        name = name,
        args = args,
        data = data,
        binary = "@cgrindel_bazel_starlib//tools:generate_release_notes",
    )
