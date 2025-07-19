#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -o nounset -o pipefail
f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" |
    cut -f2- -d' ')" 2>/dev/null ||
  source "$0.runfiles/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" |
    cut -f2- -d' ')" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" |
    cut -f2- -d' ')" 2>/dev/null ||
  {
    echo >&2 "ERROR: cannot find $f"
    exit 1
  }
f=
set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" ||
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/assertions.sh
source "${assertions_sh}"

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" ||
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/fail.sh
source "${fail_sh}"

# MARK - Test Setup

# Override do_exit to capture exit code instead of actually exiting
captured_exit_code=""
do_exit() {
  captured_exit_code="${1:-0}"
}

# Mock get_usage function required by usage_error
get_usage() {
  echo "Usage: command [options]"
}

# MARK - Test

test_usage_error_with_args() {
  local actual
  captured_exit_code=""
  actual="$(usage_error "Invalid option" "Try again" 2>&1)"
  assert_equal "Invalid option Try again
Usage: command [options]" "${actual}"
  assert_equal "1" "${captured_exit_code}"
}

test_usage_error_no_args() {
  local actual
  captured_exit_code=""
  actual="$(usage_error 2>&1)"
  assert_equal "Usage: command [options]" "${actual}"
  assert_equal "1" "${captured_exit_code}"
}

# Run tests
test_usage_error_with_args
test_usage_error_no_args
