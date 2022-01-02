#!/usr/bin/env bash

# This is used to determine if the library has been loaded
cgrindel_bazel_shlib_lib_paths_loaded() { return; }

# Normalizes the path echoing the fully-qualified path.
#
# Args:
#  path: The path string to normalize.
#
# Outputs:
#   stdout: The fully-qualified path.
#   stderr: None.
normalize_path() {
  local path="${1}"
  if [[ -d "${path}" ]]; then
    local dirname="${path}"
  else
    local dirname="$(dirname "${path}")"
    local basename="$(basename "${path}")"
  fi
  dirname="$(cd "${dirname}" > /dev/null && pwd)"
  if [[ -z "${basename:-}" ]]; then
    echo "${dirname}"
  else
    echo "${dirname}/${basename}"
  fi
}

