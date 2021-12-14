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

env_sh_location=cgrindel_bazel_starlib/lib/private/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
source "${env_sh}"

git_sh_location=cgrindel_bazel_starlib/lib/private/git.sh
git_sh="$(rlocation "${git_sh_location}")" || \
  (echo >&2 "Failed to locate ${git_sh_location}" && exit 1)
source "${git_sh}"

github_sh_location=cgrindel_bazel_starlib/lib/private/github.sh
github_sh="$(rlocation "${github_sh_location}")" || \
  (echo >&2 "Failed to locate ${github_sh_location}" && exit 1)
source "${github_sh}"


# MARK - Check for Required Software

is_installed gh || fail "Could not find Github CLI (gh)."
is_installed git || fail "Could not find git."
is_installed jq || fail "Could not find jq for JSON manipulation."
is_installed curl || fail "Could not find curl for Github API execution."


# MARK - Process Arguments

remote_name=origin
main_branch=main

args=()
while (("$#")); do
  case "${1}" in
    "--prev_tag")
      previous_tag_name="${2}"
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ ${#args[@]} == 0 ]] && fail "A tag name for the release must be specified."
tag_name="${args[0]}"

# MARK - Generate the changelog.

starting_dir="${PWD}"
cd "${BUILD_WORKSPACE_DIRECTORY}"

repo_url="$( get_git_remote_url )"
is_github_repo_url "${repo_url}" || \
  fail "The git repository's remote URL does not appear to be a Github URL. ${repo_url}"

auth_status="$( get_gh_auth_status )"
username="$( get_gh_username "${auth_status}" )"
auth_token="$( get_gh_auth_token "${auth_status}")"
api_base_url="$( get_gh_api_base_url "${repo_url}" )"


# Fetch the latest from origin
fetch_latest_from_git_remote

changelog_args=( "${api_base_url}" )
changelog_args+=(--tag_name "${tag_name}")
if ! git_tag_exists "${tag_name}"; then
  last_commit_on_main="$( get_latest_git_commit_hash "${remote_name}/${main_branch}" )"
  changelog_args+=(--target_commitish "${last_commit_on_main}")
fi
[[ -z "${previous_tag_name:-}" ]] || changelog_args+=(--previous_tag_name "${previous_tag_name}")

# DEBUG BEGIN
echo >&2 "*** CHUCK  changelog_args:"
for (( i = 0; i < ${#changelog_args[@]}; i++ )); do
  echo >&2 "*** CHUCK   ${i}: ${changelog_args[${i}]}"
done
# DEBUG END

get_gh_changelog "${changelog_args[@]}"

# tag_name="v0.1.1"

# If tag_name does not exist, get the last commit on main at orgin

# If tag_name does exist, get the commit hash for the tag.
# target_commit="$(git rev-list -n 1 "tags/${tag_name}")"


# # Get the current commit
# target_commit="$(git log --pretty=format:'%H' -n 1)"

# api_url="${api_base_url}/releases/generate-notes"

# # The changelog from the last release.
# request_data="$(
#   jq -n \
#     --arg tag_name "${tag_name}" \
#     --arg target_commitish "${target_commit}" \
#     '{tag_name: $tag_name, target_commitish: $target_commitish}'
# )"

# # previous_tag_name="v0.1.0"
# # request_data="$(
# #   jq -n \
# #     --arg tag_name "${tag_name}" \
# #     --arg previous_tag_name "${previous_tag_name}" \
# #     --arg target_commitish "${target_commit}" \
# #     '{tag_name: $tag_name, previous_tag_name: $previous_tag_name, target_commitish: $target_commitish}'
# # )"

# # DEBUG BEGIN
# echo >&2 "*** CHUCK  api_url: ${api_url}" 
# echo >&2 "*** CHUCK  request_data: ${request_data}" 
# # DEBUG END

# curl \
#   -u "cgrindel:${auth_token}" \
#   -X POST \
#   -H "Accept: application/vnd.github.v3+json" \
#   "${api_url}" \
#   -d "${request_data}"
