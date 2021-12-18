# def _replace_file_arg_placeholders(ctx, value):
#     result = value
#     for file_arg, placeholder in ctx.attr.file_args.items():

#         print("*** CHUCK file_arg: ", file_arg)
#         print("*** CHUCK placeholder: ", placeholder)

def file_placeholder(key):
    return "{%s}" % (key)

def _create_file_args_placeholder_dict(ctx):
    return {p: fa.files.to_list()[0] for fa, p in ctx.attr.file_args.items()}
    # placeholder_dict = {}
    # for file_arg, placeholder in ctx.attr.file_args.items():
    #     placeholder_dict[placeholder] = file_arg.files.to_list()[0]
    # return placeholder_dict

def _substitute_placehodlers(placeholder_dict, value):
    new_value = value
    for key, file in placeholder_dict.items():
        p_str = file_placeholder(key)
        new_value = new_value.replace(p_str, file.path)
    return new_value

def _execute_binary_impl(ctx):
    bin_path = ctx.executable.binary.short_path
    out = ctx.actions.declare_file(ctx.label.name + ".sh")

    # # DEBUG BEGIN
    # print("*** CHUCK placeholder_dict: ")
    # for key in placeholder_dict:
    #     print("*** CHUCK", key, ":", placeholder_dict[key])
    # # chuck_test = "foo {workspace_init_example_file} bar".format(**placeholder_dict)
    # chuck_test = _substitute_placehodlers(placeholder_dict, "foo {workspace_init_example_file} bar")
    # print("*** CHUCK chuck_test: ", chuck_test)
    # # DEBUG END

    placeholder_dict = _create_file_args_placeholder_dict(ctx)
    quoted_args = []
    for arg in ctx.attr.args:
        arg = _substitute_placehodlers(placeholder_dict, arg)
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

# Set the RUNFILES_DIR. If an embedded binary is a sh_binary, it has trouble 
# finding the runfiles directory. So, we help.
[[ -f "${PWD}/../MANIFEST" ]] && export RUNFILES_DIR="${PWD}/.."

args=()
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
    runfiles = ctx.runfiles(files = ctx.files.data)
    runfiles = runfiles.merge(ctx.attr.binary[DefaultInfo].default_runfiles)
    return DefaultInfo(executable = out, runfiles = runfiles)

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
