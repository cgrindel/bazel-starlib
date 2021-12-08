#!/usr/bin/env bash

# Parses the specified status file (e.g. stable-status.txt, volatile-status.txt)
# and returns a script that creates Bash variables from the key-value pairs. 
# The Bash variable name is of the format "WKSP__<key>".
source_bazel_status_vars() {
  local status_path="${1}"
  # local export_vars="${2:-FALSE}"

  # Read line-by-line
  while IFS= read -r line; do
    # Break the line string into parts
    read -a line_parts <<< ${line}

    # The first part is the key. The remainder of the string is the value.
    key="${line_parts[0]}"
    if [[ ${#line_parts[@]} == 1 ]]; then
      value=""
    else
      value_offset=( ${#key} + 1 )
      value="${line:${value_offset}}"
      # Trim leading whitespace
      value="${value#"${value%%[![:space:]]*}"}"
      # Trim trailing whitespace
      value="${value%"${value##*[![:space:]]}"}"
    fi
    export_key="WKSP__${key}"
    printf "%s=%q\n" "${export_key}" "${value}"
    # echo "${export_key}=\"${value}\""
    # printf -v "${export_key}" %s "${value}"
    # export "${export_key}"
    # if [[ "${export_vars}" == TRUE ]]; then
    #   export "${export_key}"
    # fi
  done < "${status_path}"
}
