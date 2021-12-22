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

assertions_sh_location=cgrindel_bazel_starlib/lib/private/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

# MARK - Replace fail

FAIL_ERR_MSGS=()

fail() {
  local err_msg="${1:-Unspecified error occurred.}"
  FAIL_ERR_MSGS+=( "${err_msg}" )
}

reset_fail_err_msgs() {
  FAIL_ERR_MSGS=()
}

new_fail(){
  local err_msg="${1:-}"
  [[ -n "${err_msg}" ]] || err_msg="Unspecified error occurred."
  echo >&2 "${err_msg}"
  exit 1
}

assert_fail() {
  local pattern=${1}
  [[ ${#FAIL_ERR_MSGS[@]} == 0 ]] && new_fail "Expected a failure. None found. pattern: ${pattern}"
  [[ ${#FAIL_ERR_MSGS[@]} > 1 ]] && new_fail "Expected a single failure. Found ${#FAIL_ERR_MSGS[@]}. pattern: ${pattern}"
  [[ "${FAIL_ERR_MSGS[0]}" =~ ${pattern} ]] || new_fail "Unexpected failure. Found ${FAIL_ERR_MSGS[0]}. pattern: ${pattern}"
}

assert_no_fail(){
  [[ ${#FAIL_ERR_MSGS[@]} == 0 ]] || new_fail "Expected no failures. Found ${#FAIL_ERR_MSGS[@]}. ${FAIL_ERR_MSGS[@]}"
}

# MARK - Test assert_equal

reset_fail_err_msgs
assert_equal "hello" "goodbye"
assert_fail "Expected to be equal."
reset_fail_err_msgs

# reset_fail_err_msgs
# # DEBUG BEGIN
# echo >&2 "*** CHUCK  #FAIL_ERR_MSGS[@]: ${#FAIL_ERR_MSGS[@]}" 
# # DEBUG END
# assert_equal "hello" "goodbye" "Custom prefix"
# assert_fail "Custom prefix Expected to be equal."
# reset_fail_err_msgs

fail "IMPLEMENT ME!"
