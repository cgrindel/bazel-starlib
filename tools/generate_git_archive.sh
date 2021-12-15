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

is_installed git || fail "This utility requires git to be installed and in the path."

# MARK - Process Args

remote_name=origin
main_branch=main
compress=true

args=()
while (("$#")); do
  case "${1}" in
    # "--prefix")
    #   prefix="${2}"
    #   shift 2
    #   ;;
    "--repo")
      repo="${2}"
      shift 2
      ;;
    "--tag_name")
      tag_name="${2}"
      shift 2
      ;;
    "--nocompress")
      compress=false
      shift 1
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ -z "${tag_name:-}" ]] && fail "Expected a tag name."

# MARK - Main

cd "${BUILD_WORKSPACE_DIRECTORY}"

# Fetch the latest from origin
fetch_latest_from_git_remote

# Make sure that we have a repo name
if [[ -z "${repo:-}" ]]; then
  repo_url="$( get_git_remote_url )"
  is_github_repo_url "${repo_url}" || \
    fail "Could not figure out repo name. Please specify the repo name using the --repo flag."
  repo="$( get_gh_repo_name "${repo_url}" )"
fi
prefix_suffix="${tag_name}"
[[ "${prefix_suffix}" =~ ^v ]] && prefix_suffix="${prefix_suffix:1}"
prefix="${repo}-${prefix_suffix}"
# prefix="${repo}-${tag_name}"

# Figure out which commit
if git_tag_exists "${tag_name}"; then
  # DEBUG BEGIN
  echo >&2 "*** CHUCK tag exists" 
  # DEBUG END
  # commit="$( get_latest_git_commit_hash "${tag_name}" )"
  # commit="${tag_name}"
  commit="tags/${tag_name}"
else
  # DEBUG BEGIN
  echo >&2 "*** CHUCK tag does not exist" 
  # DEBUG END
  # The tag does not exist. Assume that we are about to tag the code in the main branch.
  commit="$( get_latest_git_commit_hash "${remote_name}/${main_branch}" )"
fi

# DEBUG BEGIN
echo >&2 "*** CHUCK  prefix: ${prefix}" 
echo >&2 "*** CHUCK  commit: ${commit}" 
echo >&2 "*** CHUCK  compress: ${compress}" 
set -x
# DEBUG END

# Wrap the archive call
create_archive() {
  git archive --format=tar "--prefix=${prefix}/" "${commit}" 
}

if [[ "${compress}" == true ]]; then
  create_archive | gzip
else
  create_archive
fi
