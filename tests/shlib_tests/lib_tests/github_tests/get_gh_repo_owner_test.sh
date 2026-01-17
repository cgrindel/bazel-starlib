#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail
set +e
f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null ||
  source "$0.runfiles/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  {
    echo >&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"
    exit 1
  }
f=
set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" ||
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/fail.sh
source "${fail_sh}"

github_sh_location=cgrindel_bazel_starlib/shlib/lib/github.sh
github_sh="$(rlocation "${github_sh_location}")" ||
  (echo >&2 "Failed to locate ${github_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/github.sh
source "${github_sh}"

# MARK - Test

urls=()
urls+=(git@github.com:cgrindel/bazel-starlib.git)
urls+=(https://github.com/foo_bar/bazel-starlib.git)
urls+=(https://github.com/chicken-smidgen/bazel-starlib)
urls+=(https://api.github.com/repos/chicken-smidgen/bazel-starlib)
urls+=(***github.com/chicken-smidgen/bazel-starlib)

expected_owners=()
expected_owners+=(cgrindel)
expected_owners+=(foo_bar)
expected_owners+=(chicken-smidgen)
expected_owners+=(chicken-smidgen)
expected_owners+=(chicken-smidgen)

for ((i = 0; i < ${#urls[@]}; i++)); do
  url="${urls[$i]}"
  expected="${expected_owners[$i]}"
  actual="$(get_gh_repo_owner "${url}")"
  [[ "${actual}" == "${expected}" ]] ||
    fail "Expected owner not found. url: ${url}, expected: ${expected}, actual: ${actual}"
done
