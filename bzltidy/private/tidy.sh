#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Purposefully not using Bazel's Bash runfiles support. Running it here,
# appears to mess up the execution of targets that also use it.

# Use the Bazel binary specified by the integration test. Otherise, fall back
# to bazel.
bazel="${BIT_BAZEL_BINARY:-bazel}"

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
Executes one or more targets in the workspace.

Usage:
${utility} [OPTION] <target>...

Options:
  --help         Show this help message.

Arguments:
  <target>       Target to execute in the workspace.
EOF
}

run_bazel_targets() {
  while (("$#")); do
    local target="${1}"
    if [[ -n "${target:-}" ]]; then
      "${bazel}" run "${target}"
    fi
    shift 1
  done

}

# MARK - Process Args

targets=()
while (("$#")); do
  case "${1}" in
  "--help")
    show_usage
    ;;
  --*)
    usage_error "Unrecognized option. ${1}"
    ;;
  *)
    targets+=("${1}")
    shift 1
    ;;
  esac
done

if [[ ${#targets[@]} -eq 0 ]]; then
  usage_error "No targets were specified."
fi

# MARK - Execute the targets

# Switch to the workspace directory.
cd "${BUILD_WORKSPACE_DIRECTORY}"

# Run before targets
run_bazel_targets "${targets[@]}"
