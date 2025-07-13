#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -o nounset -o pipefail
f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" \
    | cut -f2- -d' ')" 2>/dev/null \
  || source "$0.runfiles/$f" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "$0.runfiles_manifest" \
    | cut -f2- -d' ')" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" \
    | cut -f2- -d' ')" 2>/dev/null \
  || {
    echo >&2 "ERROR: cannot find $f"
    exit 1
  }
f=
set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" \
  || (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/assertions.sh
source "${assertions_sh}"

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" \
  || (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/fail.sh
source "${fail_sh}"

# MARK - Test Setup

# Override do_exit to capture exit code instead of actually exiting
captured_exit_code=""
do_exit() {
  captured_exit_code="${1:-0}"
}

# MARK - Test

test_fail_with_args() {
  local actual
  captured_exit_code=""
  actual="$(fail "Error occurred" "Something went wrong" 2>&1)"
  assert_equal "Error occurred Something went wrong" "${actual}"
  assert_equal "1" "${captured_exit_code}"
}

test_fail_with_stdin() {
  local actual
  captured_exit_code=""
  actual="$(
    fail 2>&1 <<EOF
Critical error
EOF
  )"
  assert_equal "Critical error" "${actual}"
  assert_equal "1" "${captured_exit_code}"
}

test_fail_no_args_no_stdin() {
  local actual
  captured_exit_code=""
  actual="$(fail 2>&1 </dev/null)"
  assert_equal "" "${actual}"
  assert_equal "1" "${captured_exit_code}"
}

# Run tests
test_fail_with_args
test_fail_with_stdin
test_fail_no_args_no_stdin
