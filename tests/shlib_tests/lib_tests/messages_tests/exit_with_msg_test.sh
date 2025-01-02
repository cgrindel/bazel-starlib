#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/assertions.sh
source "${assertions_sh}"

messages_sh_location=cgrindel_bazel_starlib/shlib/lib/messages.sh
messages_sh="$(rlocation "${messages_sh_location}")" || \
  (echo >&2 "Failed to locate ${messages_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/messages.sh
source "${messages_sh}"

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

