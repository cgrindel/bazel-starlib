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

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" || \
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/arrays.sh
source "${arrays_sh}"


# MARK - Even Numbered Array

array=(aa ab ac ba bb bc)

for item in "${array[@]}" ; do
  contains_item_sorted "${item}" "${array[@]}" || fail "Expected '${item}' to be found."
done

contains_item_sorted "za" "${array[@]}" && fail "Expected 'za' not to be found"

# MARK - Odd Numbered Array

array=(aa ab ac ba bb)

for item in "${array[@]}" ; do
  contains_item_sorted "${item}" "${array[@]}" || fail "Expected '${item}' to be found."
done

contains_item_sorted "zb" "${array[@]}" && fail "Expected 'zb' not to be found"


# MARK - One Item Array

array=(aa)

for item in "${array[@]}" ; do
  contains_item_sorted "${item}" "${array[@]}" || fail "Expected '${item}' to be found."
done

contains_item_sorted "zc" "${array[@]}" && fail "Expected 'zc' not to be found"


# MARK - Empty Array

contains_item_sorted "aa" && fail "Expected 'aa' not to be found in empty array"

# Made it to the end successfully
exit 0
