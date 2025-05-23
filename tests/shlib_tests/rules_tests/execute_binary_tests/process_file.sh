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

# MARK - Locate Deps

data_file_txt_location=cgrindel_bazel_starlib/tests/shlib_tests/rules_tests/execute_binary_tests/data.txt
data_file_txt="$(rlocation "${data_file_txt_location}")" || \
  (echo >&2 "Failed to locate ${data_file_txt_location}" && exit 1)

args=()
while (("$#")); do
  case "${1}" in
    "--file")
      arg_file="${2}"
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done


data="$(< "${data_file_txt}")"
echo "Data: ${data}"

if [[ -n "${arg_file:-}" ]]; then
  arg_file_data="$(< "${arg_file}")"
  echo "Arg File: ${arg_file_data}"
fi
