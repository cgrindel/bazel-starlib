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

assertions_sh_location=cgrindel_bazel_starlib/lib/private/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

update_readme_sh_location=cgrindel_bazel_starlib/tests/rules_tests/update_readme_tests/update_readme.sh
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

readme_path="${BUILD_WORKSPACE_DIRECTORY}/foo/README.md"
mkdir -p "$(dirname "${readme_path}")"
echo "${readme_content}" > "${readme_path}"

tag_name="v99999.0.0"


# MARK - Test

# DEBUG BEGIN
set -x
# DEBUG END

"${update_readme_sh}" --readme "${readme_path}" "${tag_name}"

actual="$(< "${readme_path}")"

# DEBUG BEGIN
echo >&2 "*** CHUCK $(basename "${BASH_SOURCE[0]}") actual:"$'\n'"${actual}" 
fail "STOP"
# DEBUG END
