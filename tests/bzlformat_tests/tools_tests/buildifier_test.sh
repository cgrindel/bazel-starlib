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

buildifier_sh_location=cgrindel_bazel_starlib/bzlformat/tools/buildifier.sh
buildifier_sh="$(rlocation "${buildifier_sh_location}")" || \
  (echo >&2 "Failed to locate ${buildifier_sh_location}" && exit 1)


# MARK - Constants

out_path=result.bzl
bzl_path=foo.bzl


# MARK - Test Format

# bzl_content="$(cat <<-'EOF'
# FOO_LIST = [
# "first",
# "second"
# ]
# EOF
# )"

cat >"${bzl_path}" <<-'EOF'
FOO_LIST = [
"first",
"second"
]
EOF

expected="$(cat <<-'EOF'
FOO_LIST = [
    "first",
    "second",
]
EOF
)"

"${buildifier_sh}" --format_mode fix --lint_mode off "${bzl_path}" "${out_path}"
actual="$(< "${out_path}")"
assert_equal "${expected}" "${actual}" "Format fix, lint off."


# DEBUG BEGIN
fail "STOP"
# DEBUG END
