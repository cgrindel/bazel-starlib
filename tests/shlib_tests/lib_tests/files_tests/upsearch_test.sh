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

files_sh_location=cgrindel_bazel_starlib/shlib/lib/files.sh
files_sh="$(rlocation "${files_sh_location}")" || \
  (echo >&2 "Failed to locate ${files_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/files.sh
source "${files_sh}"

# MARK - Setup

starting_dir="${PWD}"

# Create a subdirectory
subdir="path/to/search/from"
mkdir -p "${subdir}"

# Create a file to find
target_file="file_to_find"
touch "${target_file}"

# MARK - Tests

# Find a file, using the --start_dir flag
actual=$(upsearch --start_dir "${subdir}" "${target_file}")
assert_equal "$starting_dir/${target_file}" "${actual}"

# Do not find a file, no error
actual=$(upsearch "file_does_not_exist")
assert_equal "" "${actual}"

# Do not find a file, error
set +e
actual=$(upsearch --error_if_not_found "file_does_not_exist")
exit_code=$?
assert_equal "" "${actual}"
assert_equal 1 ${exit_code}
set -e

# Switch to the subdir
cd "${subdir}"

# Find a file starting from current directory
actual=$(upsearch "${target_file}")
assert_equal "$starting_dir/${target_file}" "${actual}"
