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

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../shlib/lib/assertions.sh
source "${assertions_sh}"

update_markdown_toc_sh_location=cgrindel_bazel_starlib/markdown/tools/update_markdown_toc.sh
update_markdown_toc_sh="$(rlocation "${update_markdown_toc_sh_location}")" || \
  (echo >&2 "Failed to locate ${update_markdown_toc_sh_location}" && exit 1)


# MARK - Test with Defaults

markdown_content="$(cat <<-'EOF'
# Document Title

## Table of Contents

<!-- MARKDOWN TOC: BEGIN -->
<!-- MARKDOWN TOC: END -->

## Chicken

### Smidgen
EOF
)"

markdown_path="original.md"
echo "${markdown_content}" > "${markdown_path}"

output_path="output.md"
"${update_markdown_toc_sh}" "${markdown_path}" "${output_path}"

output_content="$( < "${output_path}" )"

expected_content="$(cat <<-'EOF'
# Document Title

## Table of Contents

<!-- MARKDOWN TOC: BEGIN -->
* [Chicken](#chicken)
  * [Smidgen](#smidgen)
<!-- MARKDOWN TOC: END -->

## Chicken

### Smidgen
EOF
)"
assert_equal "${expected_content}" "${output_content}" "With defaults"


# MARK - Test --no_remove_toc_header_entry

markdown_content="$(cat <<-'EOF'
# Document Title

## Table of Contents

<!-- MARKDOWN TOC: BEGIN -->
<!-- MARKDOWN TOC: END -->

## Chicken

### Smidgen
EOF
)"

markdown_path="original.md"
echo "${markdown_content}" > "${markdown_path}"

output_path="output.md"
"${update_markdown_toc_sh}" --no_remove_toc_header_entry "${markdown_path}" "${output_path}"

output_content="$( < "${output_path}" )"

expected_content="$(cat <<-'EOF'
# Document Title

## Table of Contents

<!-- MARKDOWN TOC: BEGIN -->
* [Table of Contents](#table-of-contents)
* [Chicken](#chicken)
  * [Smidgen](#smidgen)
<!-- MARKDOWN TOC: END -->

## Chicken

### Smidgen
EOF
)"
assert_equal "${expected_content}" "${output_content}" "With --no_remove_toc_header_entry"


# MARK - Test --toc_header

markdown_content="$(cat <<-'EOF'
# Document Title

## Contents

<!-- MARKDOWN TOC: BEGIN -->
<!-- MARKDOWN TOC: END -->

## Chicken

### Smidgen
EOF
)"

markdown_path="original.md"
echo "${markdown_content}" > "${markdown_path}"

output_path="output.md"
"${update_markdown_toc_sh}" --toc_header "Contents" "${markdown_path}" "${output_path}"

output_content="$( < "${output_path}" )"

expected_content="$(cat <<-'EOF'
# Document Title

## Contents

<!-- MARKDOWN TOC: BEGIN -->
* [Chicken](#chicken)
  * [Smidgen](#smidgen)
<!-- MARKDOWN TOC: END -->

## Chicken

### Smidgen
EOF
)"
assert_equal "${expected_content}" "${output_content}" "With --no_remove_toc_header_entry"
