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

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

update_readme_sh_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/rules_tests/update_readme_tests/update_readme.sh
update_readme_sh="$(rlocation "${update_readme_sh_location}")" || \
  (echo >&2 "Failed to locate ${update_readme_sh_location}" && exit 1)


# MARK - Setup

source "${setup_git_repo_sh}"

readme_content="$(cat <<-EOF
Text before snippet
<!-- BEGIN WORKSPACE SNIPPET -->
Text should be replaced
<!-- END WORKSPACE SNIPPET -->
Text after snippet
EOF
)"

tag_name="v99999.0.0"


# MARK - Test Specify README path

readme_path="${BUILD_WORKSPACE_DIRECTORY}/foo/README.md"
mkdir -p "$(dirname "${readme_path}")"
echo "${readme_content}" > "${readme_path}"

"${update_readme_sh}" --readme "${readme_path}" "${tag_name}"

actual="$(< "${readme_path}")"
assert_match "Text before snippet" "${actual}" "Find README.md"
assert_match "Text after snippet" "${actual}" "Find README.md"
assert_no_match "Text should be replaced" "${actual}" "Find README.md"
assert_match "http_archive" "${actual}" "Find README.md"
assert_match "${tag_name}" "${actual}" "Find README.md"


# MARK - Test Find README.md

readme_path="${BUILD_WORKSPACE_DIRECTORY}/README.md"
echo "${readme_content}" > "${readme_path}"

"${update_readme_sh}" "${tag_name}"

actual="$(< "${readme_path}")"
assert_match "Text before snippet" "${actual}" "Find README.md"
assert_match "Text after snippet" "${actual}" "Find README.md"
assert_no_match "Text should be replaced" "${actual}" "Find README.md"
assert_match "http_archive" "${actual}" "Find README.md"
assert_match "${tag_name}" "${actual}" "Find README.md"
