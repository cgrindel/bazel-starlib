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


without_init_example_sh_location=cgrindel_bazel_starlib/tests/rules_tests/generate_release_notes_tests/without_init_example.sh
without_init_example_sh="$(rlocation "${without_init_example_sh_location}")" || \
  (echo >&2 "Failed to locate ${without_init_example_sh_location}" && exit 1)

with_init_example_sh_location=cgrindel_bazel_starlib/tests/rules_tests/generate_release_notes_tests/with_init_example.sh
with_init_example_sh="$(rlocation "${with_init_example_sh_location}")" || \
  (echo >&2 "Failed to locate ${with_init_example_sh_location}" && exit 1)


# MARK - Setup

source "${setup_git_repo_sh}"

# MARK - Test

tag="v999.0.0"

actual="$( "${without_init_example_sh}" "${tag}" )"
[[ "${actual}" =~ "## What's Changed" ]] || \
  fail "Without Init Example: Did not find release notes header."

actual="$( "${with_init_example_sh}" "${tag}" )"
[[ "${actual}" =~ "## What's Changed" ]] || \
  fail "With Init Example: Did not find release notes header."
[[ "${actual}" =~ "Workspace Init for Test" ]] || \
  fail "With Init Example: Did not find init example."


