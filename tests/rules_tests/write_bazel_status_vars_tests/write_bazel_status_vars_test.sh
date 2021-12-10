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

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

bazel_status_vars_sh_location=cgrindel_bazel_starlib/tests/rules_tests/write_bazel_status_vars_tests/bazel_status_vars.sh
bazel_status_vars_sh="$(rlocation "${bazel_status_vars_sh_location}")" || \
  (echo >&2 "Failed to locate ${bazel_status_vars_sh_location}" && exit 1)

env_output="$(
  source "${bazel_status_vars_sh}"
  # Print all defined variables
  set -o posix ; set
)"

# We are checking to see that variables that are created by /tools/workspace_status.sh are present
[[ "${env_output}" =~ "STABLE_LAST_RELEASE_TAG" ]] || fail "Expected STABLE_LAST_RELEASE_TAG"
[[ "${env_output}" =~ "STABLE_CURRENT_RELEASE_TAG" ]] || fail "Expected STABLE_CURRENT_RELEASE_TAG"
