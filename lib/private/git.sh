#!/usr/bin/env bash

# Git-related Functions

# This is used to determine if the library has been loaded
cgrindel_bazel_starlib_lib_private_git_loaded() { return; }

# Returns the URL for the git repository. It is typically in the form:
#  git@github.com:cgrindel/bazel-starlib.git
# OR 
#  https://github.com/cgrindel/bazel-starlib.git
get_git_remote_url() {
  git config --get remote.origin.url
}

# Fetch the latest info from the remote.
fetch_latest_from_git_remote() { 
  git fetch 2> /dev/null
}

# Returns the commit hash for the provided branch or tag.
get_git_commit_hash() {
  local branch="${1:-}"
  git log -n 1 --pretty=format:'%H' "${branch:-}"
}

# Returns the list of release tags sorted by most recent to oldest.
get_git_release_tags() {
  git tag --sort=refname -l "v*"
}

git_tag_exists() {
  local target_tag="${1}"
  tags=( $(get_git_release_tags) )
  for tag in "${tags[@]}" ; do
    [[ "${tag}" == "${target_tag}" ]] && return
  done
  return -1
}
