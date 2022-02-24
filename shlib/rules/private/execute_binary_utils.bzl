load("@bazel_skylib//lib:paths.bzl", "paths")

def _file_placeholder(key):
    """Returns a placeholder string that is suitable for inclusion in the args for `execute_binary`.

    Args:
        key: The name for the placeholder as a `string`.

    Returns:
        A `string` that can be added to the arguments of `execute_binary`.
    """
    return "{%s}" % (key)

def _substitute_placehodlers(workspace_name, placeholder_dict, value):
    new_value = value
    for key, file in placeholder_dict.items():
        p_str = _file_placeholder(key)
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

def _write_execute_binary_script(
        write_file,
        out,
        bin_path,
        arguments,
        workspace_name,
        placeholder_dict = {}):
    quoted_args = _prepare_arguments(arguments, workspace_name, placeholder_dict)
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
""".format(bin_path = bin_path, workspace_name = workspace_name) + """\

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

def _collect_runfiles(runfiles, targets):
    """Interrogates the targets for `DefaultInfo` and merges any `default_runfiles` into the provided runfiles.

    Args:
        runfiles: A `runfiles` container as provided by `ctx.runfiles`.
        targets: A `list` of attributes/targets that may provide `DefaultInfo`
                 providers.

    Returns:
        A `runfiles` container wth all of the `default_runfiles` merged together.
    """
    for target in targets:
        if DefaultInfo in target:
            runfiles = runfiles.merge(target[DefaultInfo].default_runfiles)
    return runfiles

execute_binary_utils = struct(
    file_placeholder = _file_placeholder,
    write_execute_binary_script = _write_execute_binary_script,
    collect_runfiles = _collect_runfiles,
)
