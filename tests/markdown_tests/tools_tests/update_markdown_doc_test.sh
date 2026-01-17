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
# shellcheck source=SCRIPTDIR/../../../shlib/lib/assertions.sh
source "${assertions_sh}"

update_markdown_doc_sh_location=cgrindel_bazel_starlib/markdown/tools/update_markdown_doc.sh
update_markdown_doc_sh="$(rlocation "${update_markdown_doc_sh_location}")" ||
  (echo >&2 "Failed to locate ${update_markdown_doc_sh_location}" && exit 1)

# MARK - Test Using --marker Flag

markdown_path="original.md"
markdown_content="$(
  cat <<-EOF
Text before snippet
<!-- FOO BAR: BEGIN -->
Text should be replaced
<!-- FOO BAR: END -->
Text after snippet
EOF
)"
echo "${markdown_content}" >"${markdown_path}"

update_path="update.md"
update_content="$(
  cat <<-EOF
Here is some new text.
This has 2 lines.
EOF
)"
echo "${update_content}" >"${update_path}"

output_path="output.md"
"${update_markdown_doc_sh}" \
  --marker "FOO BAR" \
  --update "${update_path}" \
  "${markdown_path}" "${output_path}"

output_content="$(<"${output_path}")"
expected_content="$(
  cat <<-'EOF'
Text before snippet
<!-- FOO BAR: BEGIN -->
Here is some new text.
This has 2 lines.
<!-- FOO BAR: END -->
Text after snippet
EOF
)"
assert_equal "${expected_content}" "${output_content}" "Content assertion for --marker test."

# MARK - Test Using --marker_begin and --marker_end Flags

another_markdown_path="another.md"
another_markdown_content="$(
  cat <<-EOF
Text before snippet
<!-- BEGIN FOO BAR -->
Text should be replaced
<!-- END FOO BAR -->
Text after snippet
EOF
)"
echo "${another_markdown_content}" >"${another_markdown_path}"

another_output_path="another_output.md"
"${update_markdown_doc_sh}" \
  --marker_begin "BEGIN FOO BAR" \
  --marker_end "END FOO BAR" \
  --update "${update_path}" \
  "${another_markdown_path}" "${another_output_path}"

another_output_content="$(<"${another_output_path}")"
expected_content="$(
  cat <<-'EOF'
Text before snippet
<!-- BEGIN FOO BAR -->
Here is some new text.
This has 2 lines.
<!-- END FOO BAR -->
Text after snippet
EOF
)"
assert_equal "${expected_content}" "${another_output_content}" \
  "Content assertion for --marker_begin --marker_end test."
