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

# MARK - Locate Resources

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

generate_workspace_snippet_sh_location=cgrindel_bazel_starlib/tools/generate_workspace_snippet.sh
generate_workspace_snippet_sh="$(rlocation "${generate_workspace_snippet_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_workspace_snippet_sh_location}" && exit 1)


# MARK - Setup

source "${setup_git_repo_sh}"
cd "${repo_dir}"

# MARK - Set up Status Files

stable_status_path="stable-status.txt"
cat > "${stable_status_path}" <<-EOF
STABLE_VALUE chicken
STABLE_NOT_USED howdy
STABLE_CURRENT_RELEASE_TAG v1.2.3
STABLE_CURRENT_RELEASE 1.2.3
EOF

volatile_status_path="volatile-status.txt"
cat > "${volatile_status_path}" <<-EOF
VOLATILE_VALUE smidgen
EOF

# MARK - Test Successful Snippet Generation

output_path="actual_snippet.bzl"
workspace_name="acme_rules_fun"
url1='http://github.com/acme/rules_fun/releases/download/${STABLE_CURRENT_RELEASE_TAG}/rules_fun-${STABLE_CURRENT_RELEASE}.tar.gz'
url2='http://mirror.bazel.build/github.com/acme/rules_fun/releases/download/${STABLE_CURRENT_RELEASE_TAG}/rules_fun-${STABLE_CURRENT_RELEASE}.tar.gz'
sha256=5b80d60e00a7ea2d9d540c594e5ec41c946c163e272056c626026fcbb7918de2
sha256_file="sha256.txt"

echo "${sha256}" > "${sha256_file}"

"${generate_workspace_snippet_sh}" \
  --status_file "${stable_status_path}" \
  --status_file "${volatile_status_path}" \
  --output "${output_path}" \
  --workspace_name "${workspace_name}" \
  --url "${url1}" \
  --url "${url2}" \
  --sha256_file "${sha256_file}"

[[ -f "${output_path}" ]] || fail "Expected output file to exist. ${output_path}"
actual_snippet="$(< "${output_path}")"
expected_snippet=$(cat <<-EOF
http_archive(
    name = "acme_rules_fun",
    sha256 = "5b80d60e00a7ea2d9d540c594e5ec41c946c163e272056c626026fcbb7918de2",
    urls = [
        "http://github.com/acme/rules_fun/releases/download/v1.2.3/rules_fun-1.2.3.tar.gz",
        "http://mirror.bazel.build/github.com/acme/rules_fun/releases/download/v1.2.3/rules_fun-1.2.3.tar.gz",
    ],
)
EOF
)
[[ "${actual_snippet}" == "${expected_snippet}" ]] || \
  fail $'Snippet did not match expected.  actual:\n'"${actual_snippet}"$'\nexpected:\n'"${expected_snippet}"

# MARK - Test Arg Checks

err_output="$(
"${generate_workspace_snippet_sh}" \
  --status_file "${stable_status_path}" \
  --status_file "${volatile_status_path}" \
  --workspace_name "${workspace_name}" \
  --url "${url1}" \
  --url "${url2}" \
  --sha256_file "${sha256_file}" \
  2>&1 || true
)"
[[ "${err_output}" =~ "Expected an output path." ]] || fail "Missing output path failure."

err_output="$(
"${generate_workspace_snippet_sh}" \
  --status_file "${stable_status_path}" \
  --status_file "${volatile_status_path}" \
  --output "${output_path}" \
  --url "${url1}" \
  --url "${url2}" \
  --sha256_file "${sha256_file}" \
  2>&1 || true
)"
[[ "${err_output}" =~ "Expected workspace name." ]] || fail "Missing workspace name failure."


err_output="$(
"${generate_workspace_snippet_sh}" \
  --status_file "${stable_status_path}" \
  --status_file "${volatile_status_path}" \
  --output "${output_path}" \
  --workspace_name "${workspace_name}" \
  --sha256_file "${sha256_file}" \
  2>&1 || true
)"
[[ "${err_output}" =~ "Expected one ore more url templates." ]] || fail "Missing url template failure."


err_output="$(
"${generate_workspace_snippet_sh}" \
  --status_file "${stable_status_path}" \
  --status_file "${volatile_status_path}" \
  --output "${output_path}" \
  --workspace_name "${workspace_name}" \
  --url "${url1}" \
  --url "${url2}" \
  2>&1 || true
)"
[[ "${err_output}" =~ "Expected a SHA256 file." ]] || fail "Missing SHA256 file failure."
