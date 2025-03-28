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

assertions_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/assertions.sh)"
# shellcheck source=SCRIPTDIR/../../../../../shlib/lib/assertions.sh
source "${assertions_lib}"
# shellcheck source=SCRIPTDIR/../../../../../bzlformat/tools/missing_pkgs/common.sh
source "$(rlocation cgrindel_bazel_starlib/bzlformat/tools/missing_pkgs/common.sh)"

assert_equal "//foo/bar" "$(normalize_pkg "foo/bar")"
assert_equal "//foo/bar" "$(normalize_pkg "/foo/bar")"
assert_equal "//foo/bar" "$(normalize_pkg "//foo/bar")"
assert_equal "//foo/bar" "$(normalize_pkg "//foo/bar:some_target")"
assert_equal "//foo/bar" "$(normalize_pkg "foo/bar/")"
