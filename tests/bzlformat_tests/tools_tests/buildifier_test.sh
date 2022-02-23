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
bad_bzl_path=bad.bzl
good_bzl_path=good.bzl
dep_a_path=aaa.bzl
dep_z_path=zzz.bzl

cat >"${dep_a_path}" <<-'EOF'
AAA_LIST = []
EOF

cat >"${dep_z_path}" <<-'EOF'
ZZZ_LIST = []
EOF


cat >"${bad_bzl_path}" <<-'EOF'
load(":zzz.bzl", "ZZZ_LIST")
load(":aaa.bzl", "AAA_LIST")

FOO_LIST = [
"first",
"second"
] + AAA_LIST + ZZZ_LIST
EOF


# MARK - Test With Defaults 

expected="$(cat <<-'EOF'
load(":zzz.bzl", "ZZZ_LIST")
load(":aaa.bzl", "AAA_LIST")

FOO_LIST = [
    "first",
    "second",
] + AAA_LIST + ZZZ_LIST
EOF
)"

"${buildifier_sh}" "${bad_bzl_path}" "${out_path}"
actual="$(< "${out_path}")"
assert_equal "${expected}" "${actual}" "With defaults"


# MARK - Test Format Only (lint: off)

expected="$(cat <<-'EOF'
load(":zzz.bzl", "ZZZ_LIST")
load(":aaa.bzl", "AAA_LIST")

FOO_LIST = [
    "first",
    "second",
] + AAA_LIST + ZZZ_LIST
EOF
)"

"${buildifier_sh}" --lint_mode off "${bad_bzl_path}" "${out_path}"
actual="$(< "${out_path}")"
assert_equal "${expected}" "${actual}" "Format only."


# MARK - Test Lint Fix (lint: fix)

expected="$(cat <<-'EOF'
load(":aaa.bzl", "AAA_LIST")
load(":zzz.bzl", "ZZZ_LIST")

FOO_LIST = [
    "first",
    "second",
] + AAA_LIST + ZZZ_LIST
EOF
)"

"${buildifier_sh}" --lint_mode fix "${bad_bzl_path}" "${out_path}"
actual="$(< "${out_path}")"
assert_equal "${expected}" "${actual}" "Format and lint fix."


# MARK - Test Lint Warn (lint: warn) With Bad File

expected="$(cat <<-'EOF'
load(":zzz.bzl", "ZZZ_LIST")
load(":aaa.bzl", "AAA_LIST")

FOO_LIST = [
    "first",
    "second",
] + AAA_LIST + ZZZ_LIST
EOF
)"

exit_code=0
"${buildifier_sh}" --lint_mode warn "${bad_bzl_path}" "${out_path}" || exit_code=$?
assert_equal 4 ${exit_code} "Expected check mode failure (4)."
actual="$(< "${out_path}")"
assert_equal "${expected}" "${actual}" "Format and lint (warn) with bad file."


# MARK - Test Lint Warn (lint: warn) With Good File

cat >"${good_bzl_path}" <<-'EOF'
"""Module doc comment."""

load(":aaa.bzl", "AAA_LIST")
load(":zzz.bzl", "ZZZ_LIST")

FOO_LIST = [
    "first",
    "second",
] + AAA_LIST + ZZZ_LIST
EOF

expected="$(cat <<-'EOF'
"""Module doc comment."""

load(":aaa.bzl", "AAA_LIST")
load(":zzz.bzl", "ZZZ_LIST")

FOO_LIST = [
    "first",
    "second",
] + AAA_LIST + ZZZ_LIST
EOF
)"

"${buildifier_sh}" --lint_mode warn "${good_bzl_path}" "${out_path}"
actual="$(< "${out_path}")"
assert_equal "${expected}" "${actual}" "Format and lint (warn) with good file."


# MARK - Test Help

output="$( "${buildifier_sh}" --help )"
assert_match "Executes buildifier for a Starlark file" "${output}" "Confirm help output."
