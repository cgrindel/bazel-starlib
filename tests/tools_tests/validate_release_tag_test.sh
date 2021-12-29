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

assertions_sh_location=cgrindel_bazel_starlib/lib/private/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

validate_release_tag_sh_location=cgrindel_bazel_starlib/tools/validate_release_tag.sh
validate_release_tag_sh="$(rlocation "${validate_release_tag_sh_location}")" || \
  (echo >&2 "Failed to locate ${validate_release_tag_sh_location}" && exit 1)


# MARK - Setup

source "${setup_git_repo_sh}"


# MARK - Test Format Checks

"${validate_release_tag_sh}" "v1.2.3" || fail "Expected v1.2.3 to be valid."
"${validate_release_tag_sh}" "v1.2.3-rc" || fail "Expected v1.2.3-rc to be valid."
"${validate_release_tag_sh}" "1.2.3" && fail "Expected 1.2.3 to be invalid."

# MARK - Test Tag Existence

actual="$("${validate_release_tag_sh}" "v0.1.1")"
assert_match "Exists Locally: true" "${actual}"
assert_match "Exists on Remote: true" "${actual}"

actual="$("${validate_release_tag_sh}" "v999.0.0")"
assert_match "Exists Locally: false" "${actual}"
assert_match "Exists on Remote: false" "${actual}"
