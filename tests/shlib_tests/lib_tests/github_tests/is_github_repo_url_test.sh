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

good_urls=()
good_urls+=(git@github.com:cgrindel/bazel-starlib.git)
good_urls+=(https://github.com/cgrindel/bazel-starlib.git)
good_urls+=(https://github.com/cgrindel/bazel-starlib)

for url in "${good_urls[@]}"; do
  is_github_repo_url "${url}" || fail "Expected '${url}' to be a Github URL."
done

bad_urls=()
bad_urls+=(git@example.org:cgrindel/bazel-starlib.git)
bad_urls+=(https://example.org/cgrindel/bazel-starlib.git)

for url in "${bad_urls[@]}"; do
  is_github_repo_url "${url}" && fail "Expected '${url}' to not be a Github URL."
done

# Because the negative tests have failures when the test is working, we need to
# end on a positive note.
echo "ALL IS WELL"
