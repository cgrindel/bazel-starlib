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

arrays_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/arrays.sh)"
# shellcheck source=SCRIPTDIR/../lib/arrays.sh
source "${arrays_lib}"

# MARK - Performance Tests

test_iterations=${1:-100}

create_array() {
  local item_count=${1}
  local max_val=$((item_count - 1))
  local width=$((${#max_val}))
  local output=()
  local val=0
  for (( ; val < item_count; val++)); do
    output+=("$(printf "%0${width}d" $val)")
  done
  print_by_line "${output[@]}"
}

do_contains_item_perf_test() {
  for ((i = 0; i < test_iterations; i++)); do
    for item in "${@}"; do
      contains_item "${item}" "${@}"
    done
  done
}

do_contains_item_sorted_perf_test() {
  for ((i = 0; i < test_iterations; i++)); do
    for item in "${@}"; do
      contains_item_sorted "${item}" "${@}"
    done
  done
}

echo "Test iterations: ${test_iterations}"
echo ""

array_sizes=(25 30 35 40 45 50)
for size in "${array_sizes[@]}"; do
  echo "array size: ${size}"
  array=()
  while IFS=$'\n' read -r line; do array+=("$line"); done < <(
    create_array "${size}"
  )
  contains_item_time="$( (time do_contains_item_perf_test "${array[@]}") 2>&1)"
  contains_item_sorted_time="$( (time do_contains_item_sorted_perf_test "${array[@]}") 2>&1)"
  echo "contains_item: ${contains_item_time}"
  echo "contains_item_sorted: ${contains_item_sorted_time}"
  echo ""
done
