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

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

source_bazel_status_vars_sh_location=cgrindel_bazel_starlib/lib/private/source_bazel_status_vars.sh
source_bazel_status_vars_sh="$(rlocation "${source_bazel_status_vars_sh_location}")" || \
  (echo >&2 "Failed to locate ${source_bazel_status_vars_sh_location}" && exit 1)
source "${source_bazel_status_vars_sh}"

# MARK - Process Args

status_file_paths=()
while (("$#")); do
  case "${1}" in
    "--status_file")
      status_file_paths+=( "${2}" )
      shift 2
      ;;
    "--output")
      output_path="${2}"
      shift 2
      ;;
    *)
      shift 1
      ;;
  esac
done


[[ -z "${output_path:-}" ]] && fail "Expected an output path."
[[ ${#status_file_paths[@]} > 0 ]] || fail "Expected one ore more status files."


output="$(
  # Source the stable-status.txt and volatile-status.txt values as Bash variables
  for status_file_path in "${status_file_paths[@]:-}" ; do
    source_bazel_status_vars "${status_file_path}"
  done
)"

echo "${output}" | sort > "${output_path}"
