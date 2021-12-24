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

assertions_lib="$(rlocation cgrindel_bazel_starlib/lib/private/assertions.sh)"
source "${assertions_lib}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)


# without_template_sh_location=cgrindel_bazel_starlib/tests/rules_tests/generate_release_notes_tests/without_template.sh
# without_template_sh="$(rlocation "${without_template_sh_location}")" || \
#   (echo >&2 "Failed to locate ${without_template_sh_location}" && exit 1)

# with_template_sh_location=cgrindel_bazel_starlib/tests/rules_tests/generate_release_notes_tests/with_template.sh
# with_template_sh="$(rlocation "${with_template_sh_location}")" || \
#   (echo >&2 "Failed to locate ${with_template_sh_location}" && exit 1)

generate_release_notes_sh_location=cgrindel_bazel_starlib/tests/rules_tests/generate_release_notes_tests/generate_release_notes.sh
generate_release_notes_sh="$(rlocation "${generate_release_notes_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_release_notes_sh_location}" && exit 1)


# MARK - Setup

source "${setup_git_repo_sh}"


# MARK - Test

tag="v999.0.0"

actual="$( "${generate_release_notes_sh}" "${tag}" )"
assert_match "## What's Changed" "${actual}" "Did not find release notes header."
assert_match "bazel_starlib_dependencies()" "${actual}" "Did not find template content."
# assert_no_match "bazel_starlib_dependencies()" "${actual}" "Did not find template content."

# # DEBUG BEGIN
# echo >&2 "*** CHUCK  actual:"$'\n'"${actual}" 
# fail "STOP"
# # DEBUG END

# DEBUG BEGIN
echo >&2 "*** CHUCK $(basename "${BASH_SOURCE[0]}") PWD: ${PWD}" 
# DEBUG END
