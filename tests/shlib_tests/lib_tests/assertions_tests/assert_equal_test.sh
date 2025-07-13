#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail
set +e
f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null \
  || source "$0.runfiles/$f" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null \
  || {
    echo >&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"
    exit 1
  }
f=
set -e
# --- end runfiles.bash initialization v3 ---

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" \
  || (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/assertions.sh
source "${assertions_sh}"

assert_fail_sh_location=cgrindel_bazel_starlib/tests/shlib_tests/lib_tests/assertions_tests/assert_fail.sh
assert_fail_sh="$(rlocation "${assert_fail_sh_location}")" \
  || (echo >&2 "Failed to locate ${assert_fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/assert_fail.sh
source "${assert_fail_sh}"

# MARK - Test assert_equal

reset_fail_err_msgs
assert_equal "hello" "goodbye"
assert_fail "Expected to be equal."
reset_fail_err_msgs

reset_fail_err_msgs
assert_equal "hello" "goodbye" "Custom prefix."
assert_fail "Custom prefix. Expected to be equal."
reset_fail_err_msgs

reset_fail_err_msgs
assert_equal "hello" "hello"
assert_no_fail
reset_fail_err_msgs

# Test diff functionality with multi-line strings
reset_fail_err_msgs
assert_equal "line1
line2
line3" "line1
line2_modified
line3"
assert_fail 'Diff \(expected vs actual\):'
reset_fail_err_msgs
