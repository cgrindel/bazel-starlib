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

# MARK - Locate Depedencies

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

generate_sha256_sh_location=cgrindel_bazel_starlib/tools/generate_sha256.sh
generate_sha256_sh="$(rlocation "${generate_sha256_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_sha256_sh_location}" && exit 1)

# MARK - Utilities Check

utilities=(openssl shasum)
utilities_to_test=()
for utility in "${utilities[@]}" ; do
  which "${utility}" > /dev/null && utilities_to_test+=( "${utility}" )
done

[[ ${#utilities_to_test[@]} == 0 ]] && \
  fail "This platform does not support any of the SHA256 utilities."

# MARK - Setup

source_path="source"
echo "This file will be hashed." > "${source_path}"
expected_hash="d85406eb129904c21b9b7c286a0efb775cf6681815035bd82f8ad19285deb250"

# MARK - Tests

err_msg_prefix="Flags test"
output_path=output_flags
"${generate_sha256_sh}" --source "${source_path}" --output "${output_path}" || \
  fail "${err_msg_prefix} - Execution failed."
actual_hash="$(< "${output_path}")"
[[ "${actual_hash}" == "${expected_hash}" ]] || \
  fail "${err_msg_prefix} - Expected actual hash to equal expected. actual: ${actual_hash}, expected: ${expected_hash}"

for utility in "${utilities_to_test[@]}" ; do
  err_msg_prefix="Utility test for ${utility}"
  output_path="output_${utility}"
  "${generate_sha256_sh}" --source "${source_path}" --output "${output_path}" --utility "${utility}" || \
    fail "${err_msg_prefix} - Execution failed."
  actual_hash="$(< "${output_path}")"
  [[ "${actual_hash}" == "${expected_hash}" ]] || \
    fail "${err_msg_prefix} - Expected actual hash to equal expected. actual: ${actual_hash}, expected: ${expected_hash}"
done
