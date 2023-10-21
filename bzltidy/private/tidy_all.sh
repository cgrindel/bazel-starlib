#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Purposefully not using Bazel's Bash runfiles support. Running it here,
# appears to mess up the execution of targets that also use it.

# Use the Bazel binary specified by the integration test. Otherise, fall back 
# to bazel.
bazel="${BIT_BAZEL_BINARY:-bazel}"

# MARK - Functions from Library

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

# Recursively searches for a file starting from the current directory up to the root of the filesystem.
#
# Flags:
#  --start_dir: The directory where to start the search.
#  --error_if_not_found: If specified, the function will return 1 if the file is not found.
# 
# Args:
#  target_file: The basename for the file to be found.
#
# Outputs:
#   stdout: The fully-qualified path to the 
#   stderr: None.
upsearch() {
  # Lovingly inspired by https://unix.stackexchange.com/a/13474.

  local error_if_not_found=0
  local start_dir="${PWD}"
  local args=()
  while (("$#")); do
    case "${1}" in
      "--start_dir")
        local start_dir
        start_dir="$(normalize_path "${2}")"
        shift 2
        ;;
      "--error_if_not_found")
        local error_if_not_found=1
        shift 1
        ;;
      *)
        args+=( "${1}" )
        shift 1
        ;;
    esac
  done

  local target_file="${args[0]}"

  slashes=${start_dir//[^\/]/}
  directory="${start_dir}"
  for (( n=${#slashes}; n>0; --n ))
  do
    local test_path="${directory}/${target_file}"
    test -e "${test_path}" && \
      normalize_path "${test_path}" &&  return 
    directory="${directory}/.."
  done

  # Did not find the file
  if [[ ${error_if_not_found} == 1 ]]; then
    return 1
  fi
}

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
    local dirname
    dirname="$(dirname "${path}")"
    local basename
    basename="$(basename "${path}")"
  fi
  dirname="$(cd "${dirname}" > /dev/null && pwd)"
  if [[ -z "${basename:-}" ]]; then
    echo "${dirname}"
  else
    echo "${dirname}/${basename}"
  fi
}

# MARK - Functions

info_prefix="[tidy_all]"
info() {
  echo "${info_prefix}" "${@}"
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

find_all_workspaces() {
  local start_dir="$1"
  find "${start_dir}" -name "WORKSPACE"
}

find_workspaces_with_modifications() {
  local start_dir="$1"
  cd "${start_dir}"

  # Find the modified files
  local modified_files=()
  while IFS=$'\n' read -r line; do modified_files+=("$line"); done < <(
    git ls-files -m
  )

  # If there are no modified files, return immediately.
  if [[ ${#modified_files[@]} -eq 0 ]]; then
    return
  fi

  # Find the workspace file for each modified file.
  local workspaces=()
  for file in "${modified_files[@]}" ; do
    local dir
    dir="$( dirname "${file}" )"
    workspaces+=( "$(upsearch --error_if_not_found --start_dir "${dir}" "WORKSPACE")" )
  done

  # Return a unique list 
  sort_items "${workspaces[@]}"
}

target_exists() {
  local target="$1"
  "${bazel}" query "${target}" &>/dev/null
}

# MARK - Process Args

find_workspace_mode=all
tidy_target="//:tidy"

while (("$#")); do
  case "${1}" in
    "--help")
      show_usage
      ;;
    "--mode")
      find_workspace_mode="$2"
      shift 2
      ;;
    "--tidy_target")
      tidy_target="$2"
      shift 2
      ;;
    --*)
      usage_error "Unrecognized option. ${1}"
      ;;
    *)
      usage_error "Unrecognized argument. ${1}"
      ;;
  esac
done

# MARK - Execute the targets

# Switch to the workspace directory.
cd "${BUILD_WORKSPACE_DIRECTORY}"

# Find all of the workspaces
find_workspace_cmd=()
case "${find_workspace_mode}" in
  "all")
    find_workspace_cmd=( find_all_workspaces "${BUILD_WORKSPACE_DIRECTORY}" )
    ;;
  "modified")
    find_workspace_cmd=( find_workspaces_with_modifications "${BUILD_WORKSPACE_DIRECTORY}" )
    ;;
  *)
    fail "Unrecognized find_workspace_mode: ${find_workspace_mode}."
esac
workspaces=()
while IFS=$'\n' read -r line; do workspaces+=("$line"); done < <(
  "${find_workspace_cmd[@]}"
)

if [[ ${#workspaces[@]} -eq 0 ]]; then
  info "No workspaces to tidy."
  exit 0
fi

# Execute tidy target in the workspaces, if it exists.
for workspace in "${workspaces[@]}" ; do
  workspace_dir="$(dirname "${workspace}")"
  cd "${workspace_dir}"
  if target_exists "${tidy_target}"; then
    info "Running ${tidy_target} in ${workspace_dir}."
    "${bazel}" run "${tidy_target}" --experimental_convenience_symlinks=ignore
  else
    info "Skipping ${workspace_dir}. ${tidy_target} does not exist."
  fi
done
