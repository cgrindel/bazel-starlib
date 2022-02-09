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

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"


# MARK - Process Args

args=()
while (("$#")); do
  case "${1}" in
    "--marker_begin")
      marker_begin="${2}"
      shift 2
      ;;
    "--marker_end")
      marker_begin="${2}"
      shift 2
      ;;
    "--marker")
      marker="${2}"
      shift 2
      [[ "${marker}" =~ :$ ]] || marker="${marker}:"
      marker_begin="${marker} BEGIN"
      marker_end="${marker} END"
      ;;
    "--update")
      update_path="${2}"
      shift 2
      ;;
    --*)
      fail "Unrecognized flag. ${1}"
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ -z "${update_path:-}" ]] && fail "No update file was specified."

([[ -z "${marker_begin:-}" ]] || [[ -z "${marker_end:-}" ]]) && \
  fail "No markers were specified."

[[ ${#args[@]} == 0 ]]
md_path=

# MARK - Perform the update
