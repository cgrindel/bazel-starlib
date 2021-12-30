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

assertions_lib="$(rlocation cgrindel_bazel_shlib/lib/assertions.sh)"
source "${assertions_lib}"
source "$(rlocation cgrindel_rules_bzlformat/tools/missing_pkgs/common.sh)"

assert_equal "//foo/bar" "$(normalize_pkg "foo/bar")"
assert_equal "//foo/bar" "$(normalize_pkg "/foo/bar")"
assert_equal "//foo/bar" "$(normalize_pkg "//foo/bar")"
assert_equal "//foo/bar" "$(normalize_pkg "//foo/bar:some_target")"
assert_equal "//foo/bar" "$(normalize_pkg "foo/bar/")"
