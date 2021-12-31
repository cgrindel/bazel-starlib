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

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

hello_world_pkg_sh_location=cgrindel_bazel_starlib/tests/rules_tests/binary_pkg_tests/hello_world_pkg.sh
hello_world_pkg_sh="$(rlocation "${hello_world_pkg_sh_location}")" || \
  (echo >&2 "Failed to locate ${hello_world_pkg_sh_location}" && exit 1)

# MARK - No Args

output="$("${hello_world_pkg_sh}")"
assert_match "Hello, World!" "${output}" 
assert_match "Args Count: 0" "${output}" 

# MARK - With Args

output="$("${hello_world_pkg_sh}" chicken smidgen)"
assert_match "Hello, World!" "${output}" 
assert_match "Args Count: 2" "${output}" 
assert_match "Arg 1: chicken" "${output}"
assert_match "Arg 2: smidgen" "${output}"
