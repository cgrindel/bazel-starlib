#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/assertions.sh
source "${assertions_sh}"

create_scratch_dir_sh_location=rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" || \
  (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)

# MARK - Functions

find_tidy_out_files() {
  local start_dir="$1"
  find "${start_dir}" -name "*.tidy_out"
}

# MARK - Initialize Important Variables

bazel="${BIT_BAZEL_BINARY:-}"
workspace_dir="${BIT_WORKSPACE_DIR:-}"

[[ -n "${bazel:-}" ]] || fail "Must specify the location of the Bazel binary."
[[ -n "${workspace_dir:-}" ]] || fail "Must specify the location of the workspace directory."

# MARK - Set up scratch workspace with git

# Copy the workspace files to the scratch directory
scratch_dir="$("${create_scratch_dir_sh}" --workspace "${workspace_dir}")"
cd "${scratch_dir}"

# Initialize a git repository in the scratch directory
git init
git add .
git config user.name "Test Account"
git config user.email test@nowhere.org
git commit -m "Initial commit"

# MARK - Test

output_prefix_regex='\[tidy_all\]'

# Attempt to tidy all for modified workspaces, but there are none.
output="$( bazel run //:tidy_all_modified )"
tidy_out_files=()
while IFS=$'\n' read -r line; do tidy_out_files+=("$line"); done < <(
  find_tidy_out_files "${scratch_dir}"
)
assert_msg="//:tidy_all_modified, no modifications"
assert_equal 0 ${#tidy_out_files[@]} "${assert_msg}"
assert_match "${output_prefix_regex}"\ No\ workspaces\ to\ tidy\. "${output}" "${assert_msg}"

fail "IMPLEMENT ME!"
