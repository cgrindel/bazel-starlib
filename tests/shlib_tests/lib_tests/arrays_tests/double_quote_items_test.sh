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

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/assertions.sh
source "${assertions_sh}"

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" || \
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/arrays.sh
source "${arrays_sh}"


# MARK - Test

args=(a b c)
actual=()
while IFS=$'\n' read -r line; do actual+=("$line"); done < <(
  double_quote_items "${args[@]}" 
)
assert_equal 3 ${#actual[@]}
assert_equal "\"a\"" "${actual[0]}"
assert_equal "\"b\"" "${actual[1]}"
assert_equal "\"c\"" "${actual[2]}"

# Ensure args with spaces works properly.
args=("hello world" "chicken smidgen" "howdy, joe")
actual=()
while IFS=$'\n' read -r line; do actual+=("$line"); done < <(
  double_quote_items "${args[@]}" 
)
assert_equal 3 ${#actual[@]}
assert_equal "\"hello world\"" "${actual[0]}"
assert_equal "\"chicken smidgen\"" "${actual[1]}"
assert_equal "\"howdy, joe\"" "${actual[2]}"
