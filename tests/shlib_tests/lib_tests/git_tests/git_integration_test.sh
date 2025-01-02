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

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/fail.sh
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/env.sh
source "${env_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

git_sh_location=cgrindel_bazel_starlib/shlib/lib/git.sh
git_sh="$(rlocation "${git_sh_location}")" || \
  (echo >&2 "Failed to locate ${git_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/git.sh
source "${git_sh}"

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" || \
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/arrays.sh
source "${arrays_sh}"

is_installed git || fail "Could not find git."

# MARK - Setup

# shellcheck source=SCRIPTDIR/../../../setup_git_repo.sh
source "${setup_git_repo_sh}"
cd "${repo_dir}"

git config user.email "noone@example.org"
git config user.name "No one"

# MARK - Test

is_valid_release_tag "v1.2.3" || fail "Expected v1.2.3 to be valid."
is_valid_release_tag "v1.2.3-rc" || fail "Expected v1.2.3-rc to be valid."
is_valid_release_tag "1.2.3" || fail "Expected 1.2.3 to be valid."
is_valid_release_tag "f1.2.3" && fail "Expected f1.2.3 to be invalid."
is_valid_release_tag "foo-1.2.3" && fail "Expected foo-1.2.3 to be invalid."

remote_url="$(get_git_remote_url)"
[[ "${remote_url}" =~ "bazel-starlib" ]] || fail "Unexpected remote URL."

# Make sure that fetch does not fail
# shellcheck disable=SC2119 # optional arguments
fetch_latest_from_git_remote

# Create a non-release tag
create_git_tag "howdy" "Message for howdy"
git_tag_exists "howdy" || fail "Expected tag 'howdy' to exist."

# Create a release tag of 3.2.1
create_git_release_tag "3.2.1"
git_tag_exists "3.2.1" || fail "Expected tag '3.2.1' to exist."

# release_tags=( $(get_git_release_tags) )
release_tags=()
while IFS=$'\n' read -r line; do release_tags+=("$line"); done < <(
  get_git_release_tags
)
[[ ${#release_tags[@]} -gt 0 ]] || fail "Did not find any release tags."
contains_item "v0.1.1" "${release_tags[@]}" || fail "Expected tag 'v0.1.1' to be found as a release tag."
contains_item "3.2.1" "${release_tags[@]}" || fail "Expected tag '3.2.1' to be found as a release tag."

git_tag_exists "v9999.0.0" && fail "Did not expect v9999.0.0 to exist."
git_tag_exists "v0.1.1" || fail "Did expect v0.1.1 to exist."

commit="$( get_git_commit_hash "v0.1.1" )"
expected_commit="fc5ed94542dc764ba17670803ca06eddafc5beb1"
[[ "${commit}" == "${expected_commit}" ]] || \
  fail "Unexpected commit hash. actual: ${commit}, expected:${expected_commit}"
