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

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

generate_release_notes_sh_location=cgrindel_bazel_starlib/tools/generate_release_notes.sh
generate_release_notes_sh="$(rlocation "${generate_release_notes_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_release_notes_sh_location}" && exit 1)

workspace_snippet_tmpl_location=cgrindel_bazel_starlib/tests/tools_tests/workspace_snippet.tmpl
workspace_snippet_tmpl="$(rlocation "${workspace_snippet_tmpl_location}")" || \
  (echo >&2 "Failed to locate ${workspace_snippet_tmpl_location}" && exit 1)

is_installed git || fail "Could not find git."

# MARK - Setup

source "${setup_git_repo_sh}"
cd "${repo_dir}"

# MARK - Test

# These assertions are primarily making sure different sections have been included.

tag="v0.1.1"

# Test without template
actual="$( "${generate_release_notes_sh}" "${tag}" )"
[[ "${actual}" =~ "## What's Changed" ]]
[[ "${actual}" =~ "## Workspace Snippet" ]]
[[ "${actual}" =~ "http_archive(" ]]

# Test with template
actual="$( 
  "${generate_release_notes_sh}" --snippet_template "${workspace_snippet_tmpl}" "${tag}" 
)"
[[ "${actual}" =~ "## What's Changed" ]]
[[ "${actual}" =~ "## Workspace Snippet" ]]
[[ "${actual}" =~ "http_archive(" ]]
[[ "${actual}" =~ "bazel_starlib_dependencies()" ]]
