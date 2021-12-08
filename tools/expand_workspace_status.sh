#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

# printf -v "WKSP__${key}" %s "$value"

status_path="${script_dir}/../bazel-out"
stable_status_path="${status_path}/stable-status.txt"
cat "${stable_status_path}"

key_values=( $(< "${stable_status_path}")  )
# DEBUG BEGIN
echo >&2 "*** CHUCK  key_values:"
for (( i = 0; i < ${#key_values[@]}; i++ )); do
  echo >&2 "*** CHUCK   ${i}: ${key_values[${i}]}"
done
# DEBUG END


# Read line-by-line
lines=()
while IFS= read -r line; do
  lines+=( "${line}" )
done < "${stable_status_path}"


# DEBUG BEGIN
echo >&2 "*** CHUCK  lines:"
for (( i = 0; i < ${#lines[@]}; i++ )); do
  echo >&2 "*** CHUCK   ${i}: ${lines[${i}]}"
done
# DEBUG END
