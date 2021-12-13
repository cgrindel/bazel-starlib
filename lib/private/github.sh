#!/usr/bin/env bash

# Github-related Functions

# This is used to determine if the library has been loaded
cgrindel_bazel_starlib_lib_private_github_loaded() { return; }

# Returns the raw gh auth status displyaing the auth token.
get_gh_auth_status() {
  gh auth status -t
}

# Example gh auth status:
# $ gh auth status
# github.com
#   ✓ Logged in to github.com as cgrindel (/Users/chuck/.config/gh/hosts.yml)
#   ✓ Git operations for github.com configured to use ssh protocol.
#   ✓ Token: *******************

# Returns the current user's username from the auth status.
get_gh_username() {
  local auth_status="${1:-}"
  [[ -z "${auth_status}" ]] && auth_status="$( get_gh_auth_status )"
  echo "${auth_status}" | \
    sed -E -n 's/^.* Logged in to [^[:space:]]+ as ([^[:space:]]+).*/\1/gp'
}

# Returns the current user's auth token from the auth status.
get_gh_auth_token() {
  local auth_status="${1:-}"
  [[ -z "${auth_status}" ]] && auth_status="$( get_gh_auth_status )"
  echo "${auth_status}" | \
    sed -E -n 's/^.* Token:[[:space:]]+([^[:space:]]+).*/\1/gp'
}

# List of valid Github URL patterns
_github_url_patterns=(git@github.com https://github.com)

# Succeeds if the URL is a Github repo URL. Otherwise, it fails.
is_github_repo_url() {
  local repo_url="${1}"
  for pattern in "${_github_url_patterns[@]}" ; do
    [[ "${repo_url}" =~ "${pattern}" ]] && return
  done
  return -1
}

get_gh_repo_owner() {
  local repo_url="${1}"

}
