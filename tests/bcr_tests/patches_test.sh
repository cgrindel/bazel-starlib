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

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" ||
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/assertions.sh
source "${assertions_sh}"

patch_file_location=cgrindel_bazel_starlib/.bcr/patches/remove_last_green.patch
patch_file="$(rlocation "${patch_file_location}")" ||
  (echo >&2 "Failed to locate ${patch_file_location}" && exit 1)

module_bazel_location=cgrindel_bazel_starlib/MODULE.bazel
module_bazel="$(rlocation "${module_bazel_location}")" ||
  (echo >&2 "Failed to locate ${module_bazel_location}" && exit 1)

# MARK - Set up

test_dir="$(mktemp -d)"
cd "${test_dir}"

cleanup() {
  rm -rf "${test_dir}"
}
trap cleanup EXIT

# Copy the actual MODULE.bazel to the test directory
cp "${module_bazel}" MODULE.bazel

# MARK - Test patch removes last_green

# Verify the file contains last_green before patching
if ! grep -q 'bazel_binaries.download(version = "last_green")' MODULE.bazel; then
  fail "ERROR: MODULE.bazel does not contain last_green download line (test setup is broken)"
fi

# Apply the patch
patch -p1 <"${patch_file}"

# Verify last_green download line is removed
if grep -q 'bazel_binaries.download(version = "last_green")' MODULE.bazel; then
  warn "ERROR: Patch did not remove last_green download line"
  cat >&2 MODULE.bazel
  exit 1
fi

# Verify last_green use_repo entry is removed
if grep -q '"build_bazel_bazel_last_green"' MODULE.bazel; then
  warn "ERROR: Patch did not remove last_green use_repo entry"
  cat >&2 MODULE.bazel
  exit 1
fi

# Verify the version_file download line is still present
assert_match 'bazel_binaries.download\(version_file = "//:.bazelversion"\)' \
  "$(<MODULE.bazel)" \
  "Expected version_file download to remain"

# Verify other use_repo entries are still present
assert_match '"bazel_binaries"' "$(<MODULE.bazel)" \
  "Expected bazel_binaries repo to remain"
assert_match '"build_bazel_bazel_.bazelversion"' "$(<MODULE.bazel)" \
  "Expected .bazelversion repo to remain"
