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

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" || \
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/arrays.sh
source "${arrays_sh}"


create_scratch_dir_sh_location=rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" || \
  (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)

# MARK - Functions

find_tidy_out_files() {
  local start_dir="$1"
  find "${start_dir}" -name "*.tidy_out" | sort -u
}

revert_changes() {
  local start_dir="$1"
  cd "${start_dir}"
  git clean -f
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

# Tidy all modified workspaces, but there are none.
assert_msg="//:tidy_modified, no modifications"
revert_changes "${scratch_dir}"
output="$( "${bazel}" run //:tidy_modified )"
tidy_out_files=()
while IFS=$'\n' read -r line; do tidy_out_files+=("$line"); done < <(
  find_tidy_out_files "${scratch_dir}"
)
assert_equal 0 ${#tidy_out_files[@]} "${assert_msg}"
assert_match "${output_prefix_regex}"\ No\ workspaces\ to\ tidy\. "${output}" "${assert_msg}"

# Tidy all modified workspaces with modification in bar
assert_msg="//:tidy_modified, modification in bar"
revert_changes "${scratch_dir}"
echo "# Modification" >> child_workspaces/bar/BUILD.bazel
output="$( "${bazel}" run //:tidy_modified )"
tidy_out_files=()
while IFS=$'\n' read -r line; do tidy_out_files+=("$line"); done < <(
  find_tidy_out_files "${scratch_dir}"
)
assert_equal 1 ${#tidy_out_files[@]} "${assert_msg}"
assert_match child_workspaces/bar/bar\.tidy_out "${tidy_out_files[0]}" "${assert_msg}"
assert_match "${output_prefix_regex}"\ Running\ //:my_tidy\ in\ .*bar "${output}" "${assert_msg}"

# Tidy all modified workspaces with modification in parent and bar
assert_msg="//:tidy_modified, modification in parent and bar"
revert_changes "${scratch_dir}"
echo "# Modification" >> BUILD.bazel
echo "# Modification" >> child_workspaces/bar/BUILD.bazel
output="$( "${bazel}" run //:tidy_modified )"
tidy_out_files=()
while IFS=$'\n' read -r line; do tidy_out_files+=("$line"); done < <(
  find_tidy_out_files "${scratch_dir}"
)
assert_equal 2 ${#tidy_out_files[@]} "${assert_msg}"
assert_match child_workspaces/bar/bar\.tidy_out "${tidy_out_files[0]}" "${assert_msg}"
assert_match parent\.tidy_out "${tidy_out_files[1]}" "${assert_msg}"
assert_match \
  "${output_prefix_regex}"\ Running\ //:my_tidy\ in\ .*child_workspaces/bar \
  "${output}" "${assert_msg}"

# Tidy all all workspaces.
assert_msg="//:tidy_all"
revert_changes "${scratch_dir}"
output="$( "${bazel}" run //:tidy_all )"
tidy_out_files=()
while IFS=$'\n' read -r line; do tidy_out_files+=("$line"); done < <(
  find_tidy_out_files "${scratch_dir}"
)
assert_equal 2 ${#tidy_out_files[@]} "${assert_msg}"
assert_match child_workspaces/bar/bar\.tidy_out "${tidy_out_files[0]}" "${assert_msg}"
assert_match parent\.tidy_out "${tidy_out_files[1]}" "${assert_msg}"
assert_match "${output_prefix_regex}"\ Skipping\ .*foo\. "${output}" "${assert_msg}"
