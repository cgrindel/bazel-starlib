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

# MARK - Locate Depedencies

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

get_gh_auth_token_sh_location=cgrindel_bazel_starlib/tools/get_gh_auth_token.sh
get_gh_auth_token_sh="$(rlocation "${get_gh_auth_token_sh_location}")" || \
  (echo >&2 "Failed to locate ${get_gh_auth_token_sh_location}" && exit 1)

# MARK - Functions

is_installed() {
  local name="${1}"
  which "${name}" > /dev/null
}


# MARK - Check for Required Software

is_installed jq || fail "Could not find jq for JSON manipulation."

# MARK - Generate the changelog.

starting_dir="${PWD}"
cd "${BUILD_WORKSPACE_DIRECTORY}"

auth_token="$( "${get_gh_auth_token_sh}" )"

owner="cgrindel"
repo="bazel-starlib"
api_base_url="https://api.github.com/repos/${owner}/${repo}"

api_url="${api_base_url}/releases/generate-notes"

tag_name="v0.1.1"
prev_tag_name="v0.1.0"

# If tag_name does not exist, get the last commit on main at orgin

# If tag_name does exist, get the commit hash for the tag.
target_commit="$(git rev-list -n 1 "tags/${tag_name}")"


# # Get the current commit
# target_commit="$(git log --pretty=format:'%H' -n 1)"

request_data="$(
  jq -n \
    --arg tag_name "${tag_name}" \
    --arg prev_tag_name "${prev_tag_name}" \
    --arg target_commitish "${target_commit}" \
    '{tag_name: $tag_name, previous_tag_name: $prev_tag_name, target_commitish: $target_commitish}'
)"

# DEBUG BEGIN
echo >&2 "*** CHUCK  api_url: ${api_url}" 
echo >&2 "*** CHUCK  request_data: ${request_data}" 
# DEBUG END

curl \
  -u "cgrindel:${auth_token}" \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  "${api_url}" \
  -d "${request_data}"
