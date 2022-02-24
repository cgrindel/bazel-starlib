"""Definittion for execute_binary rule."""

load(":execute_binary_utils.bzl", "execute_binary_utils")

file_placeholder = execute_binary_utils.file_placeholder

def _create_file_args_placeholder_dict(ctx):
    return {p: fa.files.to_list()[0] for fa, p in ctx.attr.file_arguments.items()}

def _execute_binary_impl(ctx):
    if len(ctx.attr.args) > 0:
        fail("""\
The args attribute is not supported for execute_binary. Use the arguments instead.\
""")

    placeholder_dict = _create_file_args_placeholder_dict(ctx)
    out = ctx.actions.declare_file(ctx.label.name + ".sh")
    execute_binary_utils.write_execute_binary_script(
        write_file = ctx.actions.write,
        out = out,
        bin_path = ctx.executable.binary.short_path,
        arguments = ctx.attr.arguments,
        placeholder_dict = placeholder_dict,
        workspace_name = ctx.workspace_name,
    )

    # The file_arguments attribute shows up as a dict under ctx.attr.file_arguments and
    # as a list under ctx.files.file_arguments
    runfiles = ctx.runfiles(files = ctx.files.data + ctx.files.file_arguments)
    runfiles = execute_binary_utils.collect_runfiles(
        runfiles,
        [ctx.attr.binary] + ctx.attr.file_arguments.keys(),
    )

    return DefaultInfo(executable = out, runfiles = runfiles)

execute_binary = rule(
    implementation = _execute_binary_impl,
    attrs = {
        "arguments": attr.string_list(
            doc = """\
The list of arguments that will be embedded into the resulting executable. 

NOTE: Use this attribute instead of `args`. The `args` attribute is not \
processed for file arguments and is not preserved in the resulting script. 
""",
        ),
        "binary": attr.label(
            executable = True,
            mandatory = True,
            cfg = "target",
            doc = "The binary to be executed.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Files needed by the binary at runtime.",
        ),
        "file_arguments": attr.label_keyed_string_dict(
            allow_files = True,
            doc = """\
A `dict` mapping of file labels to placeholder names. If any of the specified \
`arguments` for `execute_binary` are paths to files, add an entry in this attribute \
where the key is the filename or label referencing the file and the value is \
a placeholder name. Use the `file_placeholder` function to create a suitable \
placeholder string for the arguments.

Example

```
execute_binary(
    name = "do_something",
    arguments = [
        "--input",
        file_placeholder("foo"),
        "--input",
        file_placeholder("bar"),
    ],
    file_arguments = {
        # The key is the path 
        "foo.txt": "foo",
        ":bar":  "bar",
    },
)
```
""",
        ),
    },
    doc = """\
This rule executes a binary target with the specified arguments. It generates \
a Bash script that contains a call to the binary with the arguments embedded \
in the script. This is useful in the following situations:

1. If one wants to embed a call to a binary target with a set of arguments in \
another rule.

2. If you define a binary target that has a number of dependencies and other \
configuration values and you do not want to replicate it elsewhere.

Why Not Use A Macro?

You can use a macro which encapsulates the details of the xxx_binary \
declaration. However, the dependencies for the xxx_binary declaration must be \
visible anywhere the macro is used.
""",
    executable = True,
)
