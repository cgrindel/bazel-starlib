load("//rules/private:execute_binary.bzl", "execute_binary")

def create_release(name, workflow_name):
    """Declares an executable target that launches a Github Actions release workflow.

    This utility expects Github's CLI (`gh`) to be installed. Running this \
    utility launches a Github Actions workflow that creates a release tag, \
    generates release notes, creates a release, and creates a PR with an \
    updated README.md file.

    Args:
        name: The name of the executable target as a `string`.
        workflow_name: The name of the Github Actions workflow.
    """
    arguments = ["--workflow", workflow_name]
    execute_binary(
        name = name,
        arguments = arguments,
        binary = "@cgrindel_bazel_starlib//tools:create_release",
    )
