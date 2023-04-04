"""Macro that defines a target that generates a Bazel module snippet."""

load("//shlib/rules:execute_binary.bzl", "execute_binary")

def generate_module_snippet(name, module_name, dev_dependency = False):
    """Generate Bazel module snippet.

    Args:
        name: The name of the target as a `string`.
        module_name: The name of the Bazel module as a `string`.
        dev_dependency: Optional. The `dev_dependency` value for the snippet.
            If the value is `False`, the snippet will not contain a
            `dev_dependency` value.
    """
    arguments = ["--module_name", module_name]
    if dev_dependency:
        arguments.append("--dev_dependency")
    execute_binary(
        name = name,
        arguments = arguments,
        binary = "@cgrindel_bazel_starlib//bzlrelease/tools:generate_module_snippet",
    )
