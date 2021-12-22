def file_placeholder(key):
    """Returns a placeholder string that is suitable for inclusion in the args for `execute_binary`.

    Args:
        key: The name for the placeholder as a `string`.

    Returns:
        A `string` that can be added to the arguments of `execute_binary`.
    """
    return "{%s}" % (key)

def _create_file_args_placeholder_dict(ctx):
    return {p: fa.files.to_list()[0] for fa, p in ctx.attr.file_args.items()}

def _substitute_placehodlers(placeholder_dict, out_files_dict, value):
    new_value = value
    for key, file in placeholder_dict.items():
        o_file = out_files_dict[file]
        p_str = file_placeholder(key)
        new_value = new_value.replace(p_str, o_file.short_path)
    return new_value

def _execute_binary_impl(ctx):
    bin_path = ctx.executable.binary.short_path
    out = ctx.actions.declare_file(ctx.label.name + ".sh")

    # Copy any input files to the output. This is required when for example an
    # execute_binary (#1) references another execute_binary (#2) and is tested
    # by an sh_test. Any file args for #2 need to be present and have the correct
    # permissions.
    # Note: The file_args attribute shows up as a dict under ctx.attr.file_args and
    # as a list under ctx.files.file_args
    out_files_dict = {}
    out_files_dir = ctx.label.name + "_eb_args"
    for in_file in ctx.files.file_args:
        out_file = ctx.actions.declare_file(out_files_dir + "/" + in_file.short_path)

        # Copy any input files so that the argument files have the correct
        # permissions if the execute_binary target is used by other
        # execute_binary targets.
        ctx.actions.run_shell(
            outputs = [out_file],
            inputs = [in_file],
            arguments = [in_file.path, out_file.path],
            command = "cp $1 $2",
        )
        out_files_dict[in_file] = out_file

    placeholder_dict = _create_file_args_placeholder_dict(ctx)
    quoted_args = []
    for arg in ctx.attr.args:
        arg = _substitute_placehodlers(placeholder_dict, out_files_dict, arg)
        if arg.startswith("\"") and arg.endswith("\""):
            quoted_args.append(arg)
        else:
            quoted_args.append("\"%s\"" % (arg))

    ctx.actions.write(
        output = out,
        is_executable = True,
        content = """\
#!/usr/bin/env bash

set -euo pipefail

# DEBUG BEGIN
echo >&2 "*** CHUCK  $(basename ${BASH_SOURCE[0]}) before RUNFILES_DIR: ${RUNFILES_DIR:-}" 
# DEBUG END

# Set the RUNFILES_DIR. If an embedded binary is a sh_binary, it has trouble 
# finding the runfiles directory. So, we help.
[[ -f "${RUNFILES_DIR:-}" ]] && [[ -f "${PWD}/../MANIFEST" ]] && export RUNFILES_DIR="${PWD}/.."

args=()
""" + """\
tmp_binary="{binary}"
""".format(binary = bin_path) + """\

# DEBUG BEGIN
echo >&2 "*** CHUCK  $(basename ${BASH_SOURCE[0]}) PWD: ${PWD}" 
echo >&2 "*** CHUCK  $(basename ${BASH_SOURCE[0]}) RUNFILES_DIR: ${RUNFILES_DIR:-}" 
# DEBUG END

""" + "\n".join([
            # Do not quote the {arg}. The values are already quoted. Adding the
            # quotes here will ruin the Bash substitution.
            """args+=( {arg} )""".format(arg = arg)
            for arg in quoted_args
        ]) + """
[[ $# > 0 ]] && args+=( "${@}" )
if [[ ${#args[@]} > 0 ]]; then
""" + """\
  "{binary}" "${{args[@]}}"
else
  "{binary}"
fi
""".format(binary = bin_path),
    )

    out_files = out_files_dict.values()
    runfiles = ctx.runfiles(files = ctx.files.data + out_files)
    runfiles = runfiles.merge(ctx.attr.binary[DefaultInfo].default_runfiles)

    # DEBUG BEGIN
    print("*** CHUCK ctx.label: ", ctx.label)
    print("*** CHUCK runfiles.files.to_list(): ")
    for idx, item in enumerate(runfiles.files.to_list()):
        print("*** CHUCK", idx, ":", item)

    # DEBUG END
    return DefaultInfo(executable = out, files = depset(out_files), runfiles = runfiles)

execute_binary = rule(
    implementation = _execute_binary_impl,
    attrs = {
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
        "file_args": attr.label_keyed_string_dict(
            allow_files = True,
            doc = """\
A `dict` mapping of file labels to placeholder names. If any of the specified \
args for `execute_binary` are paths to files, add an entry in this attribute \
where the key is the filename or label referencing the file and the value is \
a placeholder name. Use the `file_placeholder` function to create a suitable \
placeholder string for the args.

Example

```
execute_binary(
    name = "do_something",
    args = [
        "--input",
        file_placeholder("foo"),
        "--input",
        file_placeholder("bar"),
    ],
    file_args = {
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
