#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Purposefully not using Bazel's Bash runfiles support. Running it here,
# appears to mess up the execution of targets that also use it.

# shellcheck source=SCRIPTDIR/../../shlib/lib/fail.sh
source "shlib/lib/fail.sh"

# MARK - Functions

get_usage() {
  local utility
  utility="$(basename "${BASH_SOURCE[0]}")"
  cat <<-EOF
Executes tidy in all of the specified workspaces.

Usage:
${utility} [OPTION] 

Options:
  --help         Show this help message.
EOF
}

find_child_workspaces() {
  local start_dir="$1"
  find "${start_dir}" 
}

# MARK - Process Args

while (("$#")); do
  case "${1}" in
    "--help")
      show_usage
      ;;
    --*)
      usage_error "Unrecognized option. ${1}"
      ;;
    *)
      usage_error "Unrecognized argument. ${1}"
      # targets+=("${1}")
      # shift 1
      ;;
  esac
done

# MARK - Execute the targets

# DEBUG BEGIN
tree
# DEBUG END

# Switch to the workspace directory.
cd "${BUILD_WORKSPACE_DIRECTORY}"


# workspaces=( "${BUILD_WORKSPACE_DIRECTORY}" )
# while IFS=$'\n' read -r line; do workspaces+=("$line"); done < <(
#   find_child_workspaces "${BUILD_WORKSPACE_DIRECTORY}"
# )
