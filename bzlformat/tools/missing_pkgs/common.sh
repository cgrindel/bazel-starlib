#!/usr/bin/env bash

# Normalize a Bazel package name to `//path/to/package`.
#
# Args:
#   pkg: A string representing a Bazel package.
#
# Outputs:
#   stdout: A string representing a Bazel package.
#   stderr: None.
normalize_pkg() {
  # Strip any target specifications
  local pkg="${1%:*}"
  # Strip a trailing slash
  local pkg="${pkg%/}"
  # Strip a trailing slash
  # Make sure to add prefix (//)
  case "${pkg}" in
    "//"*)
      ;;
    "/"*)
      local pkg="/${pkg}"
      ;;
    *)
      local pkg="//${pkg}"
      ;;
  esac
  echo "${pkg}"
}
