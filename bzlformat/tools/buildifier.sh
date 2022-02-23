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

# Format Mode
# off - Do not format
# fix - Format the file.
format_modes=( off fix )
format_mode="fix"

# Lint Mode
# off - Do not lint
# warn - Report lint issues.
# fix = Attempt to fix lint issues.
lint_modes=( off warn fix )
lint_mode="off"

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
    "--format_mode")
      format_mode="${2}"
      shift 2
      ;;
    "--lint_mode")
      lint_mode="${2}"
      shift 2
      ;;
    "--no_fail_on_lint_warnings")
      fail_on_lint_warnings=false
      shift 1
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

contains_item "${format_mode}" "${format_modes[@]}" || \
  usage_error "Invalid format_mode (${format_mode}). Expected to be one of the following: $( join_by ", " "${format_modes[@]}" )."
contains_item "${lint_mode}" "${lint_modes[@]}" || \
  usage_error "Invalid lint_mode (${lint_mode}). Expected to be one of the following: $( join_by ", " "${lint_modes[@]}" )."


# MARK - Execute Buildifier

# cat "${bzl_path}" | "${buildifier}" "--path=${bzl_path}" > "${out_path}"

exec_buildifier() {
  local bzl_path="${1}"
  shift 1
  local buildifier_cmd=( "${buildifier}" "--path=${bzl_path}" )
  [[ ${#} > 0 ]] && buildifier_cmd+=( "${@}" )
  # cat "${bzl_path}" | "${buildifier_cmd[@]}"
  "${buildifier_cmd[@]}"
}

cat_cmd=( cat "${bzl_path}" ) 

format_cmd=()
if [[ "${format_mode}" == fix ]]; then
  format_cmd+=( exec_buildifier "${bzl_path}" )
fi

lint_cmd=()
case "${lint_mode}" in
  "fix")
    lint_cmd=( exec_buildifier "${bzl_path}" "--lint=fix" )
    ;;
  "warn")
    lint_cmd=( exec_buildifier "${bzl_path}" "--lint=warn" )
    ;;
esac


if [[ ${#format_cmd[@]} > 0 && ${#lint_cmd[@]} > 0 ]]; then
  "${cat_cmd[@]}" | "${format_cmd[@]}" | "${lint_cmd[@]}" > "${out_path}"
elif [[ ${#format_cmd[@]} > 0 ]]; then
  "${cat_cmd[@]}" | "${format_cmd[@]}" > "${out_path}"
elif [[ ${#lint_cmd[@]} > 0 ]]; then
  "${cat_cmd[@]}" | "${lint_cmd[@]}" > "${out_path}"
else
  "${tat_cmd[@]}" > "${out_path}"
fi
