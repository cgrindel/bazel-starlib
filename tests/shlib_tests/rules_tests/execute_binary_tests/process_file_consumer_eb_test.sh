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

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

process_file_consumer_eb_sh_location=cgrindel_bazel_starlib/tests/shlib_tests/rules_tests/execute_binary_tests/process_file_consumer_eb.sh
process_file_consumer_eb_sh="$(rlocation "${process_file_consumer_eb_sh_location}")" || \
  (echo >&2 "Failed to locate ${process_file_consumer_eb_sh_location}" && exit 1)


# MARK - Test

output="$( "${process_file_consumer_eb_sh}" )"

# Look for output from process_file.sh
assert_match "Data: This is a data file." "${output}"
assert_match "Arg File: This is an arg file." "${output}"
