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

# MARK - Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../shlib/lib/fail.sh
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../shlib/lib/env.sh
source "${env_sh}"

generate_gh_changelog_sh_location=cgrindel_bazel_starlib/bzlrelease/tools/generate_gh_changelog.sh
generate_gh_changelog_sh="$(rlocation "${generate_gh_changelog_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_gh_changelog_sh_location}" && exit 1)

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

is_installed git || fail "Could not find git."

# MARK - Setup

# shellcheck source=SCRIPTDIR/../../setup_git_repo.sh
source "${setup_git_repo_sh}"
cd "${repo_dir}"


# MARK - Test changelog between two known tags 

tag_name="v0.1.1"
prev_tag_name="v0.1.0"
result="$( "${generate_gh_changelog_sh}" --previous_tag_name "${prev_tag_name}" "${tag_name}" )"
# [[ "${result}" =~ "**Full Changelog**: https://github.com/cgrindel/bazel-starlib/compare/v0.1.0...v0.1.1" ]] || \
[[ "${result}" =~ \*\*Full\ Changelog\*\*:\ https://github.com/cgrindel/bazel-starlib/compare/v0\.1\.0\.\.\.v0\.1\.1 ]] || \
  fail "Expected to find changelog URL for v0.1.0...v0.1.1. result: ${result}"


# MARK - Test changelog to a new tag

tag_name="v99999.0.0"
result="$( "${generate_gh_changelog_sh}" "${tag_name}" )"
match='[*][*]Full Changelog[*][*].*v9999'
[[ "${result}" =~ $match ]] || fail "Expected to find changelog URL for ${tag_name}. result: ${result}"
