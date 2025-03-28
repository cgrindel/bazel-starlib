#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -o nounset -o pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

git_exe_location=cgrindel_bazel_starlib/tools/git/git.exe
git="$(rlocation "${git_exe_location}")" || \
  (echo >&2 "Failed to locate ${git_exe_location}" && exit 1)

tar_exe_location=cgrindel_bazel_starlib/tools/tar/tar.exe
tar="$(rlocation "${tar_exe_location}")" || \
  (echo >&2 "Failed to locate ${tar_exe_location}" && exit 1)

# MARK - Test

# We do not run git, because on MacOS it is tied to xcodebuild which may fail
# if that is not the version of git being used on the system (i.e., using
# Homebrew).
if [[ ! -e "${git}" ]]; then
  fail "Did not find git."
fi

output="$( "${tar}" --help )"
assert_match tar "${output}" "tar help output"
