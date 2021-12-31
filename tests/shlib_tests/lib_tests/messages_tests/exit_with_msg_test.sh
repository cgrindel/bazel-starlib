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

assertions_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/assertions.sh)"
source "${assertions_lib}"

messages_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/messages.sh)"
source "${messages_lib}"

# Disable errexit so that we can capture the exit codes
set +e

msg=$(exit_with_msg --no_exit 2>&1)
exit_code=$?
assert_equal "Unspecified error occurred." "${msg}"
assert_equal 1 ${exit_code}

msg=$(exit_with_msg --no_exit "My custom message"  2>&1)
exit_code=$?
assert_equal "My custom message" "${msg}"
assert_equal 1 ${exit_code}

msg=$(exit_with_msg --no_exit --exit_code 123 2>&1)
exit_code=$?
assert_equal "Unspecified error occurred." "${msg}"
assert_equal 123 ${exit_code}

msg=$(exit_with_msg --no_exit --exit_code 123 "My custom message"  2>&1)
exit_code=$?
assert_equal "My custom message" "${msg}"
assert_equal 123 ${exit_code}

msg=$(exit_with_msg --no_exit "First msg" "Second msg" 2>&1)
exit_code=$?
assert_equal "First msg Second msg" "${msg}"
assert_equal 1 ${exit_code}

