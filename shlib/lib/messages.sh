#!/usr/bin/env bash

# This is used to determine if the library has been loaded
cgrindel_bazel_shlib_lib_messages_loaded() { return; }

# Outputs a message to stderr and exits.
#
# Flags:
#   --exit_code: Used to specify the exit code to return/exit.
#   --no_exit: If specified, the function will `return` the exit code instead of calling `exit`.
#
# Args:
#   *: All of the collected args are combined to create an error message. If no values are
#      specified, then a default error message is used.
#
# Outputs:
#   stdout: None.
#   stderr: The error message
exit_with_msg() {
  local exit_code=1
  local no_exit=0

  local args=()
  while (("$#")); do
    case "${1}" in
    "--exit_code")
      local exit_code
      exit_code=$(($2))
      shift 2
      ;;
    "--no_exit")
      local no_exit=1
      shift 1
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
    esac
  done

  local err_msg="${args[*]:-}"

  [[ -n "${err_msg}" ]] || err_msg="Unspecified error occurred."
  echo >&2 "${err_msg}"
  if [[ ${no_exit} == 1 ]]; then
    return ${exit_code}
  fi
  exit ${exit_code}
}
