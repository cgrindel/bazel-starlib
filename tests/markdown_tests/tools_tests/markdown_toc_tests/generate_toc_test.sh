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

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/assertions.sh
source "${assertions_sh}"

generate_toc_location=cgrindel_bazel_starlib/markdown/tools/markdown_toc/cmd/generate_toc/generate_toc_/generate_toc
generate_toc="$(rlocation "${generate_toc_location}")" || \
  (echo >&2 "Failed to locate ${generate_toc_location}" && exit 1)


# MARK - Setup

input_file="input.md"
cat >"${input_file}" <<-EOF
# Heading 1

Some text

## Heading 2a

More Text

### Heading 3

## Heading 2b
EOF

# MARK - Test read stdin, write stdout, default start level

msg="read stdin, write stdout, default start level "
output="$( "${generate_toc}" < "${input_file}" )"
assert_match "Heading 1" "${output}" "${msg}"
assert_match "Heading 2" "${output}" "${msg}"

# MARK - Test read stdin, write stdout, start level 2

msg="read stdin, write stdout, start level 2"
output="$( "${generate_toc}" --start-level 2 < "${input_file}" )"
assert_no_match "Heading 1" "${output}" "${msg}"
assert_match "Heading 2" "${output}" "${msg}"

# MARK - Test read file, write stdout, default start level

msg="read file, write stdout, default start level "
output="$( "${generate_toc}" "${input_file}" )"
assert_match "Heading 1" "${output}" "${msg}"
assert_match "Heading 2" "${output}" "${msg}"

# MARK - Test read file, write file, default start level

msg="read file, write stdout, default start level "
output_file="output.md"
"${generate_toc}" --output "${output_file}" "${input_file}"
output="$( < "${output_file}" )"
assert_match "Heading 1" "${output}" "${msg}"
assert_match "Heading 2" "${output}" "${msg}"

# MARK - Test invalid start level

msg="invalid start level"
fail_result=false
"${generate_toc}" --start-level 0 < "${input_file}" || fail_result=true
assert_equal "true" "${fail_result}" "${msg}"
