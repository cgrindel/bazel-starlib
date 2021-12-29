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

# MARK - Locate Dependencies

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

required_software="Both git and Github CLI (gh) are required to run this utility."
is_installed gh || fail "Could not find Github CLI (gh)." "${required_software}"
is_installed git || fail "Could not find git." "${required_software}"


# MARK - Process Args

get_usage() {
  utility="$(basename "${BASH_SOURCE[0]}")"
  echo "$(cat <<-EOF
Create a release tag and push it to the remote.

Usage:
${utility} [--remote <remote>] [--branch <branch>] <tag>
EOF
  )"
}

# remote=origin
# main_branch=main
reset_tag=false

args=()
while (("$#")); do
  case "${1}" in
    "--help")
      show_usage
      exit 0
      ;;
    --remote)
      remote="${2}"
      shift 2
      ;;
    --branch)
      main_branch="${2}"
      shift 2
      ;;
    --reset_tag)
      reset_tag=true
      shift 1
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

# MARK - Create the release

starting_dir="${PWD}"
cd "${BUILD_WORKSPACE_DIRECTORY}"

[[ ${#args[@]} == 0 ]] && usage_error "Expected a version tag. (e.g v.1.2.3)"
tag="${args[0]}"
# [[ "${tag}" =~ ^v ]] || tag="v${tag}"

gh_release_exists "${tag}" && fail "A release for this tag already exists. tag: ${tag}"

if [[ "${reset_tag}" == true ]]; then
  echo "Deleting tag (${tag}) locally and on remote (${remote})..."
  git_tag_exists "${tag}" && delete_git_tag "${tag}"
  git_tag_exists_on_remote "${tag}" "${remote}" && delete_git_tag_on_remote "${tag}" "${remote}"
fi

git_tag_exists_on_remote "${tag}" "${remote}" && fail "This tag already exists on origin. tag: ${tag}"

if git_tag_exists "${tag}"; then
  echo "The tag (${tag}) exists locally, but does not exist on origin."
else
  fetch_latest_from_git_remote "${remote}" "${main_branch}"
  commit="$( get_git_commit_hash "${remote}/${main_branch}" )"
  echo "$(cat <<-EOF
Creating release tag.
Tag:    ${tag}
Branch: ${main_branch}
Commit: ${commit}
EOF
)"
  create_git_release_tag "${tag}" "${commit}"
fi

echo "Pushing release tag (${tag}) to ${remote}..."
push_git_tag_to_remote "${tag}" "${remote}"
