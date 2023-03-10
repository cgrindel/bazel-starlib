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
source "${assertions_sh}"

generate_fake_snippet_sh_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/tools_tests/generate_fake_snippet.sh
generate_fake_snippet_sh="$(rlocation "${generate_fake_snippet_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_fake_snippet_sh_location}" && exit 1)

update_readme_sh_location=cgrindel_bazel_starlib/bzlrelease/tools/update_readme.sh
update_readme_sh="$(rlocation "${update_readme_sh_location}")" || \
  (echo >&2 "Failed to locate ${update_readme_sh_location}" && exit 1)


# MARK - Set up

export BUILD_WORKSPACE_DIRECTORY="${PWD}"

tag_name="v99999.0.0"

readme_content="$(cat <<-EOF
Text before snippet
<!-- BEGIN WORKSPACE SNIPPET -->
Text should be replaced
<!-- END WORKSPACE SNIPPET -->
Text after snippet
EOF
)"


# MARK - Test Find README.md

readme_path="${BUILD_WORKSPACE_DIRECTORY}/README.md"

# Write README.md
echo "${readme_content}" > "${readme_path}"

"${update_readme_sh}" \
  --generate_workspace_snippet "${generate_fake_snippet_sh}" \
  "${tag_name}"

actual="$(< "${readme_path}")"
assert_match "Text before snippet" "${actual}" "Find README.md"
assert_match "Text after snippet" "${actual}" "Find README.md"
assert_no_match "Text should be replaced" "${actual}" "Find README.md"
assert_match "fake snippet" "${actual}" "Find README.md"
