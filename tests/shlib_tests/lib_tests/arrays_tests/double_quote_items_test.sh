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

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" || \
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
source "${arrays_sh}"


# MARK - Test

args=(a b c)
actual=( $( double_quote_items "${args[@]}" ) )
assert_equal 3 ${#actual[@]}
assert_equal "\"a\"" "${actual[0]}"
assert_equal "\"b\"" "${actual[1]}"
assert_equal "\"c\"" "${actual[2]}"

# GH076: Figure out how to handle returning items with spaces.
# # Ensure args with spaces works properly.
# args=("hello world" "chicken smidgen" "howdy, joe")
# actual=( $( double_quote_items "${args[@]}" ) )
# assert_equal 3 ${#actual[@]}
# assert_equal "\"hello world\"" "${actual[0]}"
# assert_equal "\"chicken smidgen\"" "${actual[1]}"
# assert_equal "\"howdy, joe\"" "${actual[2]}"
