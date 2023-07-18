#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Purposefully not using Bazel's Bash runfiles support. Running it here,
# appears to mess up the execution of targets that also use it.

# MARK - Functions

warn() {
  if [[ $# -gt 0 ]]; then
    local msg="${1:-}"
    shift 1
    while (("$#")); do
      msg="${msg:-}"$'\n'"${1}"
      shift 1
    done
    echo >&2 "${msg}"
  else
    cat >&2
  fi
}

# Echos the provided message to stderr and exits with an error (1).
fail() {
  warn "$@"
  exit 1
}

# Print an error message and dump the usage/help for the utility.
# This function expects a get_usage function to be defined.
usage_error() {
  local msg="${1:-}"
  cmd=(fail)
  [[ -z "${msg:-}" ]] || cmd+=("${msg}" "")
  cmd+=("$(get_usage)")
  "${cmd[@]}"
}

show_usage() {
  get_usage
  exit 0
}

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

# Sorts the arguments and outputs a unique and sorted list with each item on its own line.
#
# Args:
#   *: The items to sort.
#
# Outputs:
#   stdout: A line per unique item.
#   stderr: None.
sort_items() {
  local IFS=$'\n'
  sort -u <<<"$*"
}

find_child_workspaces() {
  local start_dir="$1"
  find "${start_dir}" -name "WORKSPACE"
}

target_exists() {
  local target="$1"
  bazel query "${target}" &>/dev/null
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

# Switch to the workspace directory.
cd "${BUILD_WORKSPACE_DIRECTORY}"

# Find all of the workspaces
workspaces=()
while IFS=$'\n' read -r line; do workspaces+=("$line"); done < <(
  find_child_workspaces "${BUILD_WORKSPACE_DIRECTORY}"
)

# Execute tidy target in the workspaces, if it exists.
tidy_target="//:tidy"
for workspace in "${workspaces[@]}" ; do
  workspace_dir="$(dirname "${workspace}")"
  cd "${workspace_dir}"
  if target_exists "${tidy_target}"; then
    echo "Running ${tidy_target} in ${workspace_dir}."
    bazel run "${tidy_target}" --experimental_convenience_symlinks=ignore
  else
    echo "Skipping ${workspace_dir}. ${tidy_target} does not exist."
  fi
done
