#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

update_markdown_doc_sh_location=cgrindel_bazel_starlib/markdown/tools/update_markdown_doc.sh
update_markdown_doc_sh="$(rlocation "${update_markdown_doc_sh_location}")" || \
  (echo >&2 "Failed to locate ${update_markdown_doc_sh_location}" && exit 1)

# MARK - Test Using --marker Flag

markdown_path="original.md"
markdown_content="$(cat <<-EOF
Text before snippet
<!-- FOO BAR: BEGIN -->
Text should be replaced
<!-- FOO BAR: END -->
Text after snippet
EOF
)"
echo "${markdown_content}" > "${markdown_path}"

update_path="update.md"
update_content="$(cat <<-EOF
Here is some new text.
This has 2 lines.
EOF
)"
echo "${update_content}" > "${update_path}"

output_path="output.md"
"${update_markdown_doc_sh}" \
  --marker "FOO BAR" \
  --update "${update_path}" \
  "${markdown_path}" "${output_path}"

output_content="$(< "${output_path}" )"
# DEBUG BEGIN
echo >&2 "*** CHUCK $(basename "${BASH_SOURCE[0]}") output_content:"$'\n'"${output_content}" 
# DEBUG END

# TODO: ADD ASSERTION

# DEBUG BEGIN
fail "IMPLEMENT ME!"
# DEBUG END
