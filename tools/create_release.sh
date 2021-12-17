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

git_sh_location=cgrindel_bazel_starlib/lib/private/git.sh
git_sh="$(rlocation "${git_sh_location}")" || \
  (echo >&2 "Failed to locate ${git_sh_location}" && exit 1)
source "${git_sh}"

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

remote=origin
main_branch=main

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
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

# MARK - Create the release

cd "${BUILD_WORKSPACE_DIRECTORY}"

[[ ${#args[@]} == 0 ]] && usage_error "Expected a tag or semver. (e.g v.1.2.3)"
tag="${args[0]}"
[[ "${tag}" =~ ^v ]] || tag="v${tag}"

commit="$( get_git_commit_hash "${main_branch}" )"
git_tag_exists_on_remote "${tag}" "${remote}" && fail "This tag already exists on origin. tag: ${tag}"
git_tag_exists "${tag}" && fail "This tag exists locally, but does not exist on origin. tag: ${tag}"

echo "$(cat <<-EOF
Creating release tag.
Tag:    ${tag}
Branch: ${main_branch}
Commit: ${commit}
EOF
)"
create_git_release_tag "${tag}" "${commit}"

echo "Pushing release tag to ${remote}..."
push_git_tag_to_remote "${tag}" "${remote}"
