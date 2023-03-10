#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

assertions_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/assertions.sh)"
source "${assertions_lib}"

paths_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/paths.sh)"
source "${paths_lib}"

current_dir="${PWD}"

child_dirname="foo"
mkdir "${child_dirname}"
child_filename="${child_dirname}/bar"
touch "${child_filename}"

result="$(normalize_path "${child_dirname}")"
assert_equal "${current_dir}/${child_dirname}" "${result}"

result="$(normalize_path "${child_filename}")"
assert_equal "${current_dir}/${child_filename}" "${result}"
