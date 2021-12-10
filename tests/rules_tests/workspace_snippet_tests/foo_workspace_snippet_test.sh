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

# MARK - Locate Resources

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

bazel_workspace_vars_sh_location=cgrindel_bazel_starlib/tests/rules_tests/workspace_snippet_tests/bazel_workspace_vars.sh
bazel_workspace_vars_sh="$(rlocation "${bazel_workspace_vars_sh_location}")" || \
  (echo >&2 "Failed to locate ${bazel_workspace_vars_sh_location}" && exit 1)

foo_workspace_snippet_bzl_location=cgrindel_bazel_starlib/tests/rules_tests/workspace_snippet_tests/foo_workspace_snippet.bzl
foo_workspace_snippet_bzl="$(rlocation "${foo_workspace_snippet_bzl_location}")" || \
  (echo >&2 "Failed to locate ${foo_workspace_snippet_bzl_location}" && exit 1)

# MARK - Test the Snippet

# NOTE: This test is focused on testing the plumbing of the rule. The workspace snippet generation
# is tested in the generate_workspace_snippet_test.sh.

actual_snippet="$(< "${foo_workspace_snippet_bzl}")"

$(
# Load the Bazel status variables
source "${bazel_workspace_vars_sh}"

# NOTE: The SHA256 value is from evaluating the output of the package defined in the BUILD file. 
expected_snippet=$(cat <<-EOF
http_archive(
    name = "acme_rules_fun",
    sha256 = "2e2f0a03043aedd9bd9a1f742c821ff36c778cb1d439ad31fa4c7ba06af2abdf",
    urls = [
        "http://github.com/acme/rules_fun/releases/download/${STABLE_CURRENT_RELEASE_TAG}/rules_fun-${STABLE_CURRENT_RELEASE}.tar.gz",
    ],
)
EOF
)

[[ "${actual_snippet}" == "${expected_snippet}" ]] || \
  fail $'Snippet did not match expected.  actual:\n'"${actual_snippet}"$'\nexpected:\n'"${expected_snippet}"
)
