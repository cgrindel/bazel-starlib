#!/usr/bin/env bash

# This script performs an integration test for bzlformat.
# Changes are made to a build file and a bzl file, then the update
# all command is run to format the changes and copy them back to
# the workspace. Finally, the tests are run to be sure that everything
# is formatted.

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

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" ||
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/assertions.sh
source "${assertions_sh}"

paths_sh_location=cgrindel_bazel_starlib/shlib/lib/paths.sh
paths_sh="$(rlocation "${paths_sh_location}")" ||
  (echo >&2 "Failed to locate ${paths_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/paths.sh
source "${paths_sh}"

messages_sh_location=cgrindel_bazel_starlib/shlib/lib/messages.sh
messages_sh="$(rlocation "${messages_sh_location}")" ||
  (echo >&2 "Failed to locate ${messages_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/messages.sh
source "${messages_sh}"

create_scratch_dir_sh_location=rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" ||
  (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)

# MARK - Process Arguments

bazel="${BIT_BAZEL_BINARY:-}"
workspace_dir="${BIT_WORKSPACE_DIR:-}"

# Process args
while (("$#")); do
  case "${1}" in
  *)
    shift 1
    ;;
  esac
done

[[ -n "${bazel:-}" ]] || exit_with_msg "Must specify the location of the Bazel binary."
[[ -n "${workspace_dir:-}" ]] || exit_with_msg "Must specify the location of the workspace directory."

# MARK - Create Scratch Directory

scratch_dir="$("${create_scratch_dir_sh}" --workspace "${workspace_dir}")"
cd "${scratch_dir}"

# MARK - Ensure that all Bazel packages have bzlformat_pkg declarations

"${bazel}" run //:bzlformat_missing_pkgs_fix

# MARK - Execute Tests

# Make sure that all is well
"${bazel}" test //...

# MARK - Make poorly formatted changes, update the files, and execute the tests

internal_build_path="${scratch_dir}/mockascript/internal/BUILD.bazel"
mockascript_library_path="${scratch_dir}/mockascript/internal/mockascript_library.bzl"

# Add poorly formatted code to build file.
echo "load(':foo.bzl', 'foo')" >>"${internal_build_path}"

# Add poorly formatted code to bzl file.
echo "load(':foo.bzl', 'foo'); foo(tags=['b', 'a'],srcs=['d', 'c'])" \
  >>"${mockascript_library_path}"

# Confirm that the tests fail with poorly formatted files.
"${bazel}" test //... && fail "Expected tests to fail with poorly formatted files."

# Execute the update for the repository
"${bazel}" run //:update_all

# Make sure that all is well
"${bazel}" test //...
