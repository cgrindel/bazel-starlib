# def _create_file_args_placeholder_dict(file_arguments):
#     """Creates a `dict` with the key being the placeholder name and the value is the file.
    
#     Args:
#         file_arguments: A label-keyed string `dict` mapping (key: label/file, 
#                         value: placeholder name).
    
#     Returns:
#         A ``
#     """
#     return {p: fa.files.to_list()[0] for fa, p in file_arguments.items()}

def _substitute_placehodlers(workspace_name, placeholder_dict, value):
    new_value = value
    for key, file in placeholder_dict.items():
        p_str = file_placeholder(key)

        path = paths.join("${RUNFILES_DIR}", workspace_name, file.short_path)
        new_value = new_value.replace(p_str, path)
    return new_value

def _prepare_arguments(arguments, workspace_name, placeholder_dict):
    """Prepares arguments by resolving file placeholders with actual values and adding double quotes.
    
    Args:
        arguments: A `list` of arguments (`string` values) to prepare.
        workspace_name: The name of the workspace.
        placeholder_dict: A `dict` where the key is the placeholder name and
                          the value is the actual `File`.
    
    Returns:
        A `list` of `string` values suitable to be substituted into a Bash script.
    """
    quoted_args = []
    for arg in arguments:
        arg = _substitute_placehodlers(workspace_name, placeholder_dict, arg)
        if arg.startswith("\"") and arg.endswith("\""):
            quoted_args.append(arg)
        else:
            quoted_args.append("\"%s\"" % (arg))
    return quoted_args


def _write_execute_binary_script(write_file, create_runfiles, out, arguments, placeholder_dict):
    write_file(
        output = out,
        is_executable = True,
        content = """\
#!/usr/bin/env bash

set -euo pipefail

# Set the RUNFILES_DIR. If an embedded binary is a sh_binary, it has trouble 
# finding the runfiles directory. So, we help.
[[ -z "${RUNFILES_DIR:-}" ]] && \
  [[ -f "${PWD}/../MANIFEST" ]] && \
  export RUNFILES_DIR="${PWD}/.."

[[ -z "${RUNFILES_DIR:-}" ]] && \
  echo >&2 "The RUNFILES_DIR for $(basename "${BASH_SOURCE[0]}") could not be found."

""" + """\
workspace_name="{workspace_name}"
bin_path="{bin_path}"
""".format(bin_path = bin_path, workspace_name = ctx.workspace_name) + """\

# If the bin_path can be found relative to the current directory, use it.
# Otherwise, look for it under the runfiles directory.
if [[ -f "${bin_path}" ]]; then
  binary="${bin_path}"
else
  binary="${RUNFILES_DIR}/${workspace_name}/${bin_path}"
fi

# Construct the command (binary plus args).
cmd=( "${binary}" )
""" + "\n".join([
            # Do not quote the {arg}. The values are already quoted. Adding the
            # quotes here will ruin the Bash substitution.
            """cmd+=( {arg} )""".format(arg = arg)
            for arg in quoted_args
        ]) + """

# Add any args that were passed to this invocation
[[ $# > 0 ]] && cmd+=( "${@}" )

# Execute the binary with its args
"${cmd[@]}"
""",
    )

execute_binary_utils = struct(
    # prepare_arguments = _prepare_arguments,
    write_execute_binary = _write_execute_binary_script,
)
