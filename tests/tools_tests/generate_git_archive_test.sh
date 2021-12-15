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

# MARK - Dependencies

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/lib/private/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
source "${env_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

generate_git_archive_sh_location=cgrindel_bazel_starlib/tools/generate_git_archive.sh
generate_git_archive_sh="$(rlocation "${generate_git_archive_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_git_archive_sh_location}" && exit 1)

generate_sha256_sh_location=cgrindel_bazel_starlib/tools/generate_sha256.sh
generate_sha256_sh="$(rlocation "${generate_sha256_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_sha256_sh_location}" && exit 1)

is_installed git || fail "Could not find git."

# MARK - Setup

source "${setup_git_repo_sh}"
cd "${repo_dir}"


# MARK - Test

compressed_sha256="81ab205a4a57be6f1c9cf86ed510eba72ec3fca366b50b054f1250814ea99c08"
uncompressed_sha256="82a33d1d182fe73805fe1f48870313fdc8d3457adfeab6b346c2f51e7db33de0"

actual="$( "${generate_git_archive_sh}" --tag_name "v0.1.1" | "${generate_sha256_sh}" )"
expected="${compressed_sha256}"
[[ "${actual}" == "${expected}" ]] || \
  fail "SHA256 for compressed archive did not match. actual: ${actual}, expected: ${expected}"


actual="$( "${generate_git_archive_sh}" --tag_name "v0.1.1"  --nocompress | "${generate_sha256_sh}" )"
expected="${uncompressed_sha256}"
[[ "${actual}" == "${expected}" ]] || \
  fail "SHA256 for uncompressed archive did not match. actual: ${actual}, expected: ${expected}"

output_path="output.tar.gz"
"${generate_git_archive_sh}" --tag_name "v0.1.1" --output "${output_path}"
[[ -f "${output_path}" ]] || fail "Expected compressed file to exist. ${output_path}"
actual="$( "${generate_sha256_sh}" --source "${output_path}" )"
expected="${compressed_sha256}"
[[ "${actual}" == "${expected}" ]] || \
  fail "SHA256 for compressed archive file did not match. actual: ${actual}, expected: ${expected}"

output_path="output.tar"
"${generate_git_archive_sh}" --tag_name "v0.1.1" --output "${output_path}" --nocompress
[[ -f "${output_path}" ]] || fail "Expected uncompressed file to exist. ${output_path}"
actual="$( "${generate_sha256_sh}" --source "${output_path}" )"
expected="${uncompressed_sha256}"
[[ "${actual}" == "${expected}" ]] || \
  fail "SHA256 for uncompressed archive file did not match. actual: ${actual}, expected: ${expected}"
