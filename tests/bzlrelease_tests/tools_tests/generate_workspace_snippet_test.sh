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

# MARK - Locate Resources

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../shlib/lib/fail.sh
source "${fail_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

generate_workspace_snippet_sh_location=cgrindel_bazel_starlib/bzlrelease/tools/generate_workspace_snippet.sh
generate_workspace_snippet_sh="$(rlocation "${generate_workspace_snippet_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_workspace_snippet_sh_location}" && exit 1)

workspace_snippet_tmpl_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/tools_tests/workspace_snippet.tmpl
workspace_snippet_tmpl="$(rlocation "${workspace_snippet_tmpl_location}")" || \
  (echo >&2 "Failed to locate ${workspace_snippet_tmpl_location}" && exit 1)

# MARK - Setup

# shellcheck source=SCRIPTDIR/../../setup_git_repo.sh
source "${setup_git_repo_sh}"
cd "${repo_dir}"

sha256=5b80d60e00a7ea2d9d540c594e5ec41c946c163e272056c626026fcbb7918de2
tag="v1.2.3"
strip_prefix="bazel-starlib-1.2.3"

# MARK - Test Extracting Info from Git Repository

actual_snippet="$(
"${generate_workspace_snippet_sh}" \
  --sha256 "${sha256}" \
  --tag "${tag}"
)"

expected_snippet=$(cat <<-EOF
\`\`\`python
http_archive(
    name = "cgrindel_bazel_starlib",
    sha256 = "${sha256}",
    strip_prefix = "${strip_prefix}",
    urls = [
        "http://github.com/cgrindel/bazel-starlib/archive/${tag}.tar.gz",
    ],
)
\`\`\`
EOF
)
[[ "${actual_snippet}" == "${expected_snippet}" ]] || \
  fail $'Snippet with defaults did not match expected.  actual:\n'"${actual_snippet}"$'\nexpected:\n'"${expected_snippet}"

# MARK - Test with custom workspace_name

actual_snippet="$(
"${generate_workspace_snippet_sh}" \
  --workspace_name "foo_bar" \
  --sha256 "${sha256}" \
  --tag "${tag}"
)"

expected_snippet=$(cat <<-EOF
\`\`\`python
http_archive(
    name = "foo_bar",
    sha256 = "${sha256}",
    strip_prefix = "${strip_prefix}",
    urls = [
        "http://github.com/cgrindel/bazel-starlib/archive/${tag}.tar.gz",
    ],
)
\`\`\`
EOF
)
[[ "${actual_snippet}" == "${expected_snippet}" ]] || \
  fail $'Snippet with custom workspace_name did not match expected.  actual:\n'"${actual_snippet}"$'\nexpected:\n'"${expected_snippet}"

# MARK - Test write to file

output_path="snippet.bzl"

expected_snippet=$(cat <<-EOF
\`\`\`python
http_archive(
    name = "cgrindel_bazel_starlib",
    sha256 = "${sha256}",
    strip_prefix = "${strip_prefix}",
    urls = [
        "http://github.com/cgrindel/bazel-starlib/archive/${tag}.tar.gz",
    ],
)
\`\`\`
EOF
)

"${generate_workspace_snippet_sh}" \
  --sha256 "${sha256}" \
  --tag "${tag}" \
  --output "${output_path}"
actual_snippet="$(< "${output_path}")"
[[ "${actual_snippet}" == "${expected_snippet}" ]] || \
  fail $'Snippet written to file did not match expected.  actual:\n'"${actual_snippet}"$'\nexpected:\n'"${expected_snippet}"


# MARK - Test Without Template

owner=acme
repo=rules_fun
# shellcheck disable=SC2016 # Template string
url1='http://github.com/${owner}/${repo}/releases/download/${tag}/${repo}-${tag:1}.tar.gz'
# shellcheck disable=SC2016 # Template string
url2='http://mirror.bazel.build/github.com/${owner}/${repo}/releases/download/${tag}/${repo}-${tag:1}.tar.gz'
strip_prefix="rules_fun-1.2.3"

actual_snippet="$(
"${generate_workspace_snippet_sh}" \
  --sha256 "${sha256}" \
  --tag "${tag}" \
  --no_github_source_archive_url \
  --url "${url1}" \
  --url "${url2}" \
  --owner "${owner}" \
  --repo "${repo}"
)"

expected_snippet=$(cat <<-EOF
\`\`\`python
http_archive(
    name = "${owner}_${repo}",
    sha256 = "${sha256}",
    strip_prefix = "${strip_prefix}",
    urls = [
        "http://github.com/${owner}/${repo}/releases/download/${tag}/${repo}-${tag:1}.tar.gz",
        "http://mirror.bazel.build/github.com/${owner}/${repo}/releases/download/${tag}/rules_fun-${tag:1}.tar.gz",
    ],
)
\`\`\`
EOF
)
[[ "${actual_snippet}" == "${expected_snippet}" ]] || \
  fail $'Snippet with specified parameters did not match expected.  actual:\n'"${actual_snippet}"$'\nexpected:\n'"${expected_snippet}"


# MARK - Test With Template

actual_snippet="$(
"${generate_workspace_snippet_sh}" \
  --sha256 "${sha256}" \
  --tag "${tag}" \
  --template "${workspace_snippet_tmpl}"
)"

[[ "${actual_snippet}" =~ load.*http_archive ]] || \
  fail "Did not find load statement from the template."
[[ "${actual_snippet}" =~ http_archive\( ]] || \
  fail "Did not find http_archive statement from the utility."


# MARK - Test Arg Checks

err_output="$(
"${generate_workspace_snippet_sh}" \
  --sha256 "${sha256}" \
  2>&1 || true
)"
[[ "${err_output}" =~ Expected\ a\ tag\ value\. ]] || fail "Missing tag failure."

err_output="$(
"${generate_workspace_snippet_sh}" \
  --tag "${tag}" \
  --sha256 "${sha256}" \
  --no_github_source_archive_url \
  2>&1 || true
)"
[[ "${err_output}" =~ Expected\ one\ or\ more\ url\ templates\. ]] || fail "Missing url template failure."

