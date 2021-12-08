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
  # Break the line string into parts
  read -a line_parts <<< ${line}

  # The first part is the key. The remainder of the string is the value.
  key="${line_parts[0]}"
  if [[ ${#line_parts[@]} == 1 ]]; then
    value=""
  else
    value_offset=( ${#key} + 1 )
    value="${line:${value_offset}}"
    # Trim leading whitespace
    value="${value#"${value%%[![:space:]]*}"}"
    # Trim trailing whitespace
    value="${value%"${value##*[![:space:]]}"}"
  fi
  # DEBUG BEGIN
  echo >&2 "*** CHUCK  key: ${key}" 
  echo >&2 "*** CHUCK  value: ${value}" 
  # DEBUG END
  export_key="WKSP__${key}"
  printf -v "${export_key}" %s "${value}"
  # DEBUG BEGIN
  echo >&2 "*** CHUCK  export_key: ${export_key}" 
  echo >&2 "*** CHUCK  !export_key: ${!export_key}" 
  # DEBUG END
done < "${stable_status_path}"

