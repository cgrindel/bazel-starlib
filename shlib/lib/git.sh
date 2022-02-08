#!/usr/bin/env bash

# Git-related Functions

# This is used to determine if the library has been loaded
cgrindel_bazel_starlib_lib_private_git_loaded() { return; }

# MARK - Default Values

remote=origin
main_branch=main

# Returns the URL for the git repository. It is typically in the form:
#  git@github.com:cgrindel/bazel-starlib.git
# OR 
#  https://github.com/cgrindel/bazel-starlib.git
get_git_remote_url() {
  git config --get remote.origin.url
}

# Fetch the latest info from the remote.
fetch_latest_from_git_remote() { 
  local remote="${1:-}"
  local branch="${2:-}"
  fetch_cmd=(git fetch)
  if [[ ! -z "${remote:-}" ]]; then
    fetch_cmd+=( "${remote}" )
    [[ -z "${branch:-}" ]] || fetch_cmd+=( "${branch}" )
  fi
  "${fetch_cmd[@]}" 2> /dev/null
}

# MARK - Tag Functions

is_valid_release_tag() {
  local tag="${1}"
  [[ "${tag}" =~ ^v?[0-9]+[.][0-9]+[.][0-9]+ ]] || return -1
}

# Returns the commit hash for the provided branch or tag.
get_git_commit_hash() {
  local branch="${1:-}"
  git log -n 1 --pretty=format:'%H' "${branch:-}"
}

# Returns the list of release tags sorted by most recent to oldest.
get_git_release_tags() {
  local tags=( $(git tag --sort=refname -l) )
  [[ ${#tags[@]} == 0 ]] && return
  local release_tags=()
  for tag in "${tags[@]}" ; do
    is_valid_release_tag "${tag}" && release_tags+=( "${tag}" )
  done
  [[ ${#release_tags[@]} == 0 ]] && return
  echo "${release_tags[@]}"
}

git_tag_exists() {
  local target_tag="${1}"
  local tags=( $(get_git_release_tags) )
  # Make sure that the for loop variable is not tag or something else common.
  for cur_tag in "${tags[@]}" ; do
    [[ "${cur_tag}" == "${target_tag}" ]] && return
  done
  return -1
}

create_git_release_tag() {
  local tag="${1}"
  local commit="${2:-}"
  msg="Release ${tag}"
  git_tag_cmd=(git tag -a -m "${msg}" "${tag}")
  [[ -z "${commit:-}" ]] || git_tag_cmd+=( "${commit}" )
  "${git_tag_cmd[@]}"
}

git_tag_exists_on_remote() {
  local tag="${1}"
  local remote="${2:-origin}"
  git ls-remote --exit-code "${remote}" "refs/tags/${tag}" > /dev/null
}

delete_git_tag() {
  local tag="${1}"
  git tag -d "${tag}" > /dev/null
}

push_git_tag_to_remote() {
  local tag="${1}"
  local remote="${2:-origin}"
  git push "${remote}" "${tag}"
}

delete_git_tag_on_remote() {
  local tag="${1}"
  local remote="${2:-origin}"
  git push --delete "${remote}" "${tag}" > /dev/null
}


# MARK - Branch Functions

get_current_branch_name() {
  git rev-parse --abbrev-ref HEAD
}
