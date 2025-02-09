#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/fail.sh
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/env.sh
source "${env_sh}"

git_sh_location=cgrindel_bazel_starlib/shlib/lib/git.sh
git_sh="$(rlocation "${git_sh_location}")" || \
  (echo >&2 "Failed to locate ${git_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/git.sh
source "${git_sh}"

github_sh_location=cgrindel_bazel_starlib/shlib/lib/github.sh
github_sh="$(rlocation "${github_sh_location}")" || \
  (echo >&2 "Failed to locate ${github_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/github.sh
source "${github_sh}"


# MARK - Check for Required Software

is_installed git || fail "Could not find git."


# MARK - Process Arguments

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

# Fetch the latest from origin
# shellcheck disable=SC2119
fetch_latest_from_git_remote

# Construct the args for generating the changelog.
changelog_args=()
changelog_args+=(--tag_name "${tag_name}")
if ! git_tag_exists "${tag_name}"; then
  last_commit_on_main="$( get_git_commit_hash "${remote}/${main_branch}" )"
  changelog_args+=(--target_commitish "${last_commit_on_main}")
fi
[[ -z "${previous_tag_name:-}" ]] || changelog_args+=(--previous_tag_name "${previous_tag_name}")

# Generate the changelog
changelog_md="$( get_gh_changelog "${changelog_args[@]}" )"

# Output the changelog
if [[ -z "${output_path:-}" ]]; then
  echo "${changelog_md}"
else
  echo "${changelog_md}" > "${output_path}"
fi
