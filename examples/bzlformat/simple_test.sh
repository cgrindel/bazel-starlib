#!/usr/bin/env bash

# This script performs an integration test for rules_bzlformat.
# Changes are made to a build file and a bzl file, then the update
# all command is run to format the changes and copy them back to 
# the workspace. Finally, the tests are run to be sure that everything
# is formatted.

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

assertions_sh_location=cgrindel_bazel_shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

paths_sh_location=cgrindel_bazel_shlib/lib/paths.sh
paths_sh="$(rlocation "${paths_sh_location}")" || \
  (echo >&2 "Failed to locate ${paths_sh_location}" && exit 1)
source "${paths_sh}"

messages_sh_location=cgrindel_bazel_shlib/lib/messages.sh
messages_sh="$(rlocation "${messages_sh_location}")" || \
  (echo >&2 "Failed to locate ${messages_sh_location}" && exit 1)
source "${messages_sh}"

create_scratch_dir_sh_location=cgrindel_rules_bazel_integration_test/tools/create_scratch_dir.sh
create_scratch_dir_sh="$(rlocation "${create_scratch_dir_sh_location}")" || \
  (echo >&2 "Failed to locate ${create_scratch_dir_sh_location}" && exit 1)

# MARK - Process Arguments

# Process args
while (("$#")); do
  case "${1}" in
    "--bazel")
      bazel_rel_path="${2}"
      shift 2
      ;;
    "--workspace")
      workspace_path="${2}"
      shift 2
      ;;
    *)
      shift 1
      ;;
  esac
done

[[ -n "${bazel_rel_path:-}" ]] || exit_with_msg "Must specify the location of the Bazel binary."
[[ -n "${workspace_path:-}" ]] || exit_with_msg "Must specify the location of the workspace file."

starting_path="$(pwd)"
starting_path="${starting_path%%*( )}"
bazel="$(normalize_path "${bazel_rel_path}")"
workspace_dir="$(normalize_path "$(dirname "${workspace_path}")")"

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
echo "load(':foo.bzl', 'foo')" >> "${internal_build_path}"

# Add poorly formatted code to bzl file.
echo "load(':foo.bzl', 'foo'); foo(tags=['b', 'a'],srcs=['d', 'c'])" \
  >> "${mockascript_library_path}"

# Confirm that the tests fail with poorly formatted files.
"${bazel}" test //... && fail "Expected tests to fail with poorly formatted files."

# Execute the update for the repository
"${bazel}" run //:update_all

# Make sure that all is well
"${bazel}" test //...
