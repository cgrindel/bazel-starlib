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
source "${assertions_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

without_template_sh_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/rules_tests/generate_workspace_snippet_tests/without_template.sh
without_template_sh="$(rlocation "${without_template_sh_location}")" || \
  (echo >&2 "Failed to locate ${without_template_sh_location}" && exit 1)

with_template_sh_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/rules_tests/generate_workspace_snippet_tests/with_template.sh
with_template_sh="$(rlocation "${with_template_sh_location}")" || \
  (echo >&2 "Failed to locate ${with_template_sh_location}" && exit 1)

with_sha256_file_and_url_template_sh_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/rules_tests/generate_workspace_snippet_tests/with_sha256_file_and_url_template.sh
with_sha256_file_and_url_template_sh="$(rlocation "${with_sha256_file_and_url_template_sh_location}")" || \
  (echo >&2 "Failed to locate ${with_sha256_file_and_url_template_sh_location}" && exit 1)

archive_sha256_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/rules_tests/generate_workspace_snippet_tests/archive_sha256
archive_sha256="$(rlocation "${archive_sha256_location}")" || \
  (echo >&2 "Failed to locate ${archive_sha256_location}" && exit 1)

# MARK - Setup

source "${setup_git_repo_sh}"

# MARK - Test

tag="v999.0.0"

actual="$( "${without_template_sh}" --tag "${tag}" )"
assert_match 'http_archive\(' "${actual}" "Without Template http_archive"
assert_match 'name = "cgrindel_bazel_starlib"' "${actual}" "Without Template name attribute"
assert_no_match bazel_starlib_dependencies "${actual}" "Without Template bazel_starlib_dependencies"

actual="$( "${with_template_sh}" --tag "${tag}" )"
assert_match 'http_archive\(' "${actual}" "With Template http_archive"
assert_match 'name = "cgrindel_bazel_starlib"' "${actual}" "With Template name attribute"
assert_match bazel_starlib_dependencies "${actual}" "With Template bazel_starlib_dependencies"

actual="$( "${with_sha256_file_and_url_template_sh}" --tag "${tag}" )"
assert_match \
  'https://github.com/cgrindel/bazel-starlib/releases/download/v999.0.0/bazel-starlib.v999.0.0.tar.gz' \
  "${actual}" \
  "With SHA256 File and URL Template correct release artifact URL"
assert_match \
  'https://mirror.foo.org/cgrindel/bazel-starlib/bazel-starlib.v999.0.0.tar.gz' \
  "${actual}" \
  "With SHA256 File and URL Template correct custom URL"
assert_no_match 'strip_prefix' "${actual}"  "With SHA256 File and URL Template no strip_prefix"
assert_match \
  'name = "cgrindel_bazel_starlib"' \
  "${actual}" \
  "With SHA256 File and URL Template name attribute"
expected_sha256="$(< "${archive_sha256}")"
assert_match \
  'sha256 = "'"${expected_sha256}"'"' \
  "${actual}" \
  "With SHA256 File and URL Template sha256 attribute"
