#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -o nounset -o pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

# tests/shlib_tests/rules_tests/execute_binary_tests
find_workspace_eb_location=cgrindel_bazel_starlib/tests/shlib_tests/rules_tests/execute_binary_tests/find_workspace_eb.sh
find_workspace_eb="$(rlocation "${find_workspace_eb_location}")" || \
  (echo >&2 "Failed to locate ${find_workspace_eb_location}" && exit 1)

# MARK - Test

# Create a workspace directory
workspace_dir="${PWD}/workspace"
mkdir -p "${workspace_dir}"
touch "${workspace_dir}/WORKSPACE"
export BUILD_WORKSPACE_DIRECTORY="${workspace_dir}"

# If the execute succeeds, then the test succeeds
"${find_workspace_eb}"
