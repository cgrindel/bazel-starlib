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

# MARK - Dependencies

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/lib/private/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
source "${env_sh}"

generate_gh_changelog_sh_location=cgrindel_bazel_starlib/tools/generate_gh_changelog.sh
generate_gh_changelog_sh="$(rlocation "${generate_gh_changelog_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_gh_changelog_sh_location}" && exit 1)

is_installed git || fail "Could not find git."

# MARK - Setup

# Clone this repo so that we have an actual git repository for the test
repo_dir="${PWD}/repo"
rm -rf "${repo_dir}"
repo_url="https://github.com/cgrindel/bazel-starlib"
git clone "${repo_url}" "${repo_dir}"
cd "${repo_dir}"
export "BUILD_WORKSPACE_DIRECTORY=${repo_dir}"

# DEBUG BEGIN
echo >&2 "*** CHUCK  BUILD_WORKSPACE_DIRECTORY: ${BUILD_WORKSPACE_DIRECTORY}" 
# DEBUG END

# MARK - Test changelog between two known tags 

tag_name="v0.1.1"
prev_tag_name="v0.1.0"
result="$( "${generate_gh_changelog_sh}" --previous_tag_name "${prev_tag_name}" "${tag_name}" )"

# DEBUG BEGIN
echo >&2 "*** CHUCK  result: ${result}" 
# DEBUG END

fail "IMPLEMENT ME!"
