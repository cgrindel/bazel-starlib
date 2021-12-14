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
    "--previous_tag_name")
      previous_tag_name="${2}"
      shift 2
      ;;
    "--output")
      output_path="${2}"
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

# Construct the args for generating the changelog.
changelog_args=( "${api_base_url}" )
changelog_args+=(--tag_name "${tag_name}")
if ! git_tag_exists "${tag_name}"; then
  last_commit_on_main="$( get_latest_git_commit_hash "${remote_name}/${main_branch}" )"
  changelog_args+=(--target_commitish "${last_commit_on_main}")
fi
[[ -z "${previous_tag_name:-}" ]] || changelog_args+=(--previous_tag_name "${previous_tag_name}")

# Generate the changelog
response_json="$( get_gh_changelog "${changelog_args[@]}" )"
changelog_md="$( echo "${response_json}" | jq '.body' )"
# Evaluate the embedded newlines
changelog_md="$( printf "%b\n" "${changelog_md}" )"
# Remove the double quotes at beginning and end
changelog_md="${changelog_md%\"}"
changelog_md="${changelog_md#\"}"

# Output the changelog
if [[ -z "${output_path:-}" ]]; then
  echo "${changelog_md}"
else
  echo "${changelog_md}" > "${output_path}"
fi
