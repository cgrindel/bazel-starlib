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

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/fail.sh
source "${fail_sh}"

github_sh_location=cgrindel_bazel_starlib/shlib/lib/github.sh
github_sh="$(rlocation "${github_sh_location}")" || \
  (echo >&2 "Failed to locate ${github_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/github.sh
source "${github_sh}"


# MARK - Test

auth_status="
github.com
  ✓ Logged in to github.com as cgrindel (/Users/chuck/.config/gh/hosts.yml)
  ✓ Git operations for github.com configured to use ssh protocol.
  ✓ Token: 1234567899b95cd24c3e91d210388a28bf560b73
"

expected="1234567899b95cd24c3e91d210388a28bf560b73"
actual="$( get_gh_auth_token "${auth_status}" )"
[[ "${actual}" == "${expected}" ]] || \
  fail "Expected auth token not found. actual: ${actual}, expected: ${expected}"
