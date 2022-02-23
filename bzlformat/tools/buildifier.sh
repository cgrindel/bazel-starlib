#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" || \
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
source "${arrays_sh}"

buildifier_location=bazel_starlib_buildtools/buildifier
buildifier="$(rlocation "${buildifier_location}")" || \
  (echo >&2 "Failed to locate ${buildifier_location}" && exit 1)


# MARK - Process Args

# Lint Mode
# off - Do not lint
# warn - Report lint issues.
# fix = Attempt to fix lint issues.
lint_modes=( off warn fix )
lint_mode="off"

warnings="all"
fail_on_lint_warnings=true

# TODO: Update usage.

get_usage() {
  local utility="$(basename "${BASH_SOURCE[0]}")"
  echo "$(cat <<-EOF
One line description of the utility.

Usage:
${utility} --flag <flag_value> [OPTION]... <arg0>

Options:
  --flag <flag_value>  Describe flag
  <arg0>               Describe arg0
EOF
  )"
}

args=()
while (("$#")); do
  case "${1}" in
    "--help")
      show_usage
      exit 0
      ;;
    "--lint_mode")
      lint_mode="${2}"
      shift 2
      ;;
    "--warnings")
      warnings="${2}"
      shift 2
      ;;
    "--no_fail_on_lint_warnings")
      fail_on_lint_warnings=false
      shift 1
      ;;
    --*)
      usage_error "Unexpected option. ${1}"
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ ${#args[@]} < 2 ]] && usage_error "Expected an input path and an output path."
bzl_path="${args[0]}"
out_path="${args[1]}"

contains_item "${lint_mode}" "${lint_modes[@]}" || \
  usage_error "Invalid lint_mode (${lint_mode}). Expected to be one of the following: $( join_by ", " "${lint_modes[@]}" )."


# MARK - Execute Buildifier

exec_buildifier() {
  local bzl_path="${1}"
  shift 1
  local buildifier_cmd=( "${buildifier}" "--path=${bzl_path}" )
  [[ ${#} > 0 ]] && buildifier_cmd+=( "${@}" )
  "${buildifier_cmd[@]}"
}

cat_cmd=( cat "${bzl_path}" ) 

lint_cmd=( exec_buildifier "${bzl_path}" "--warnings=${warnings}" )
case "${lint_mode}" in
  "fix")
    lint_cmd+=( "--lint=fix" )
    ;;
  "warn")
    lint_cmd+=( "--lint=warn" )
    ;;
  "off")
    lint_cmd+=( "--lint=off" )
    ;;
esac

"${cat_cmd[@]}" | "${lint_cmd[@]}" > "${out_path}"
