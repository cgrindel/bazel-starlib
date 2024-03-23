#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/assertions.sh
source "${assertions_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

generate_release_notes_with_template_sh_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/rules_tests/generate_release_notes_tests/generate_release_notes_with_template.sh
generate_release_notes_with_template_sh="$(rlocation "${generate_release_notes_with_template_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_release_notes_with_template_sh_location}" && exit 1)

generate_release_notes_with_workspace_name_sh_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/rules_tests/generate_release_notes_tests/generate_release_notes_with_workspace_name.sh
generate_release_notes_with_workspace_name_sh="$(rlocation "${generate_release_notes_with_workspace_name_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_release_notes_with_workspace_name_sh_location}" && exit 1)

# MARK - Setup

# shellcheck source=SCRIPTDIR/../../../setup_git_repo.sh
source "${setup_git_repo_sh}"


# MARK - Test

tag="v999.0.0"

# Test with template
actual="$( "${generate_release_notes_with_template_sh}" "${tag}" )"
assert_match "name = \"cgrindel_bazel_starlib\"" "${actual}" "Did not find workspace name."
assert_match "## What Has Changed" "${actual}" "Did not find release notes header."
assert_match "bazel_starlib_dependencies()" "${actual}" "Did not find template content."

# Test with workspace_name
actual="$( "${generate_release_notes_with_workspace_name_sh}" "${tag}" )"
assert_match "name = \"foo_bar\"" "${actual}" "Did not find workspace name."
assert_match "## What Has Changed" "${actual}" "Did not find release notes header."
assert_match "bazel_starlib_dependencies()" "${actual}" "Did not find template content."
assert_match "bazel_dep\(" "${actual}" "Did not find module snippet"
