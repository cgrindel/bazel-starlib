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

markdown_link_check_sh_location=cgrindel_bazel_starlib_markdown_npm/markdown-link-check/bin/markdown-link-check.sh
markdown_link_check_sh="$(rlocation "${markdown_link_check_sh_location}")" || \
  (echo >&2 "Failed to locate ${markdown_link_check_sh_location}" && exit 1)


# MARK - Process Args

# TODO: Add real usage.

verbose=false
quiet=false
max_econnreset_retry_count=3

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
    "--config")
      config_path="${2}"
      shift 2
      ;;
    "--verbose")
      verbose="true"
      shift 1
      ;;
    "--quiet")
      quiet="true"
      shift 1
      ;;
    "--max_econnreset_retry_count")
      max_econnreset_retry_count=${2}
      shift 2
      ;;
    --*)
      usage_error "Unrecognized flag. ${1}"
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ ${#args[@]} == 0 ]] && usage_error "Expected one or more markdown files."
md_paths=( "${args[@]}" )

# MARK - Check Links

# Construct the command for markdown_link_check
cmd=( "${markdown_link_check_sh}" )
[[ "${verbose}" == "true" ]] && cmd+=( -v )
[[ "${quiet}" == "true" ]] && cmd+=( -q )
[[ -n "${config_path:-}" ]] && cmd+=( -c "${config_path}" )
cmd+=( "${md_paths[@]}" )

# Collect stderr b/c we may need to execute multiple times.
stderr_file="$( mktemp )"
cleanup() {
  rm -rf "${stderr_file}"
}
trap cleanup EXIT

# Execute markdown_link_check
success=false
attempts=0
while [[ ${attempts} < ${max_econnreset_retry_count} ]]; do
  # Execute the command directing stderr to a file.
  if "${cmd[@]}" 2> "${stderr_file}"; then
    success=true
    break
  # If the error was an ECONNRESET, the increment counter and loop to try again.
  elif cat "${stderr_file}" | grep 'Error: read ECONNRESET'; then
    echo >&2 "An ECONNRESET error occurred. attempts: ${attempts}"
    attempts+=1
  # Else the utility failed.
  else
    success=false
    break
  fi
done

# If the utility was not successful, dump the last stderr file and exit with
# failure.
if [[ "${success}" != true ]]; then
  cat >&2 "${stderr_file}"
  exit 1
fi
