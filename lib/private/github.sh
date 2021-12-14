#!/usr/bin/env bash

# Github-related Functions

# This is used to determine if the library has been loaded
cgrindel_bazel_starlib_lib_private_github_loaded() { return; }

# MARK - Github Auth Status Functions

# Returns the raw gh auth status displyaing the auth token.
get_gh_auth_status() {
  gh auth status -t 2>&1
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

# MARK - Github Repo URL Functions

# List of valid Github URL patterns
_github_url_patterns=()
_github_url_owner_sed_cmds=()

# Example: git@github.com:cgrindel/bazel-starlib.git
_github_url_patterns+=(git@github.com:)
_github_url_owner_sed_cmds+=('s|git@[^:]+:([^/]+).*|\1|gp')

# Example: https://github.com/cgrindel/bazel-starlib.git
_github_url_patterns+=(https://github.com/)
_github_url_owner_sed_cmds+=('s|https://github.com/([^/]+)/.*|\1|gp')

# Example: https://api.github.com/repos/cgrindel/bazel-starlib
_github_url_patterns+=(https://api.github.com/repos/)
_github_url_owner_sed_cmds+=('s|https://api.github.com/repos/([^/]+)/.*|\1|gp')

# Returns the index for the Github URL pattern. This index can be used look up
# owner and repo name.
_get_github_repo_pattern_index() {
  local repo_url="${1}"
  for (( i = 0; i < ${#_github_url_patterns[@]}; i++ )); do
    pattern="${_github_url_patterns[$i]}"
    [[ "${repo_url}" =~ "${pattern}" ]] && echo $i && return
  done
  return -1
}

# Succeeds if the URL is a Github repo URL. Otherwise, it fails.
is_github_repo_url() {
  local repo_url="${1}"
  _get_github_repo_pattern_index "${repo_url}" > /dev/null
}

# Return the Github repository owner from the repository URL.
get_gh_repo_owner() {
  local repo_url="${1}"
  local pattern_index=$( _get_github_repo_pattern_index "${repo_url}" )
  local sed_cmd="${_github_url_owner_sed_cmds[${pattern_index}]}"
  echo "${repo_url}" | sed -E -n "${sed_cmd}"
}

# Return the Github repository name from the repository URL.
get_gh_repo_name() {
  local repo_url="${1}"
  basename -s .git "${repo_url}"
}

# MARK - Github API Functions

get_gh_api_base_url() {
  local repo_url="${1}"
  local owner="$( get_gh_repo_owner "${repo_url}" )"
  local name="$( get_gh_repo_name "${repo_url}" )"
  echo "https://api.github.com/repos/${owner}/${name}"
}

get_gh_changelog() {
  local args=()
  local api_args=()
  while (("$#")); do
    case "${1}" in
      --*)
        # Add the arg name and the value to the api args array
        api_args+=("${1:2}" "${2}")
        shift 2
        ;;
      *)
        args+=("${1}")
        shift 1
        ;;
    esac
  done

  [[ ${#args[@]} == 0 ]] && fail "Expected an api_base_url."
  local api_base_url="${args[0]}"
  [[ -z "${tag_name:-}" ]] && fail "Expected a tag_name."

  local request_data='{}'
  for (( i = 0; i < ${#api_args[@]}; i = i + 2 )); do
    local arg_name="${api_args[$i]}"
    local arg_value="${api_args[$i + 1]}"
    request_data="$( 
      echo "${request_data}" | \
        jq \
          --arg arg_name "${arg_name}" \
          --arg arg_value "${arg_value}" \
          '. + {($arg_name) : $arg_value}'
    )"
  done

  # Execute the API
  local api_url="${api_base_url}/releases/generate-notes"
  curl \
    --silent \
    -u "cgrindel:${auth_token}" \
    -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    "${api_url}" \
    -d "${request_data}"
}
