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

# MARK - Args Count

echo "Args Count: ${#}"
for ((i = 1; i <= ${#}; i++)); do
  echo "  ${i}: ${!i}"
done

# MARK - Look for specific args

check_data_file=false

args=()
while (("$#")); do
  case "${1}" in
  "--check_data_file")
    check_data_file=true
    shift 1
    ;;
  "--input")
    input_file="${2}"
    shift 2
    ;;
  *)
    args+=("${1}")
    shift 1
    ;;
  esac
done

if [[ "${check_data_file}" == true ]]; then
  data_txt_location=cgrindel_bazel_starlib/tests/shlib_tests/rules_tests/execute_binary_tests/data.txt
  data_txt="$(rlocation "${data_txt_location}")" ||
    (echo >&2 "Failed to locate ${data_txt_location}" && exit 1)
  echo "Data: $(<"${data_txt}")"
fi

[[ -z "${input_file:-}" ]] || echo "Input: $(<"${input_file}")"
