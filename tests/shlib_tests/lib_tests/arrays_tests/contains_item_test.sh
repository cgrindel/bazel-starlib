#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

assertions_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/assertions.sh)"
source "${assertions_lib}"

arrays_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/arrays.sh)"
source "${arrays_lib}"

# Unsorted array
array=(z b y c x aa az)

# Confirm that we find an entry deep in the array
contains_item az "${array[@]}" || fail "Expected 'az' to be contained in array."

# This test will exit from the shortcut
contains_item m "${array[@]}" && fail "Expected 'm' not to be contained in array."

# This test will pass the shortcut, but will not find the entry
contains_item a "${array[@]}" && fail "Expected `a` not to be contained in array."

# If we made it this far, we want to be sure to exit success
exit 0
