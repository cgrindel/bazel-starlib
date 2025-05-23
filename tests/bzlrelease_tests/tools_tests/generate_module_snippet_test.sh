#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -o nounset -o pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"; exit 1; }; f=; set -o errexit
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../shlib/lib/assertions.sh
source "${assertions_sh}"

generate_module_snippet_sh_location=cgrindel_bazel_starlib/bzlrelease/tools/generate_module_snippet.sh
generate_module_snippet_sh="$(rlocation "${generate_module_snippet_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_module_snippet_sh_location}" && exit 1)

# MARK - Test

output="$( "${generate_module_snippet_sh}" --module_name "rules_chicken" --version "1.2.3" )"
expected="$(cat <<-EOF
\`\`\`python
bazel_dep(name = "rules_chicken", version = "1.2.3")
\`\`\`
EOF
)"
assert_equal "${expected}" "${output}" "module with version"

output="$( "${generate_module_snippet_sh}" --module_name "rules_chicken" --version "v1.2.3" )"
expected="$(cat <<-EOF
\`\`\`python
bazel_dep(name = "rules_chicken", version = "1.2.3")
\`\`\`
EOF
)"
assert_equal "${expected}" "${output}" "module with tag"

output="$( "${generate_module_snippet_sh}" --module_name "rules_chicken" --version "v1.2.3" --dev_dependency )"
expected="$(cat <<-EOF
\`\`\`python
bazel_dep(
    name = "rules_chicken",
    version = "1.2.3",
    dev_dependency = True,
)
\`\`\`
EOF
)"
assert_equal "${expected}" "${output}" "module with dev_dependency"
