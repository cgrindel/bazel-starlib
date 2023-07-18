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
Executes the tidy target and confirms that no changes occurred.

Usage:
${utility} [OPTION] <tidy-target>

Options:
  --help              Show this help message.

Arguments:
  <tidy-target>       The tidy target to execute.
EOF
}

git_status() {
  local out="${1}"
  git status --porcelain > "${out}"
}

git_diff() {
  local out="${1}"
  git diff > "${out}"
}

diff_files() {
  local first="${1}"
  local second="${2}"
  diff "${first}" "${second}" 
}

# MARK - Process Args

tidy_target=
while (("$#")); do
  case "${1}" in
    "--help")
      show_usage
      ;;
    --*)
      usage_error "Unrecognized option. ${1}"
      ;;
    *)
      if [[ -z "${tidy_target:-}" ]]; then
        tidy_target="${1}"
      else
        usage_error "Unrecognized argument. ${1}"
      fi
      shift 1
      ;;
  esac
done

if [[ -z "${tidy_target:-}" ]]; then
  usage_error "The tidy target must be specified."
fi
which git || fail "Cannot find git. This utility requires git be installed."

# MARK - Perform the check

# Switch to the workspace directory.
cd "${BUILD_WORKSPACE_DIRECTORY}"

cleanup() {
  rm -rf "${tmpdir}"
}
trap cleanup EXIT

# Create a temp directory to hold status info
tmpdir="$(mktemp -d)"
before_dir="${tmpdir}/before"
after_dir="${tmpdir}/after"
mkdir -p "${before_dir}" "${after_dir}"

# Capture the current state
before_status="${before_dir}/status"
git_status "${before_status}"
before_diff="${before_dir}/diff"
git_diff "${before_diff}"

# Execute tidy
bazel run "${tidy_target}"

# Capture after state
after_status="${after_dir}/status"
git_status "${after_status}"
after_diff="${after_dir}/diff"
git_diff "${after_diff}"

# Compare the before and after
status_diff="$( diff_files "${before_status}" "${after_status}" || true )"
if [[ -n "${status_diff:-}" ]]; then
  fail "The git status outputs changed." "${status_diff}"
fi

diff_diff="$( diff_files "${before_diff}" "${after_diff}" || true )" 
if [[ -n "${diff_diff:-}" ]]; then
  fail "The git diff outputs changed." "${diff_diff}"
fi
