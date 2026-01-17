#!/usr/bin/env bash

# Generate a git archive for a tag.
# NOTE: The OS where the archive is compressed is important. The SHA256 value
# for a compressed archive on MacOS does not match the one generated on
# Ubuntu. If you are trying to generate an archive that is identical to the
# one downloaded from https://github.com/<user>/<repo>/archive/<tag>.tar.gz,
# be sure to generate it on Ubuntu.

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail
set +e
f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null ||
  source "$0.runfiles/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  {
    echo >&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"
    exit 1
  }
f=
set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" ||
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/fail.sh
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" ||
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/env.sh
source "${env_sh}"

git_sh_location=cgrindel_bazel_starlib/shlib/lib/git.sh
git_sh="$(rlocation "${git_sh_location}")" ||
  (echo >&2 "Failed to locate ${git_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/git.sh
source "${git_sh}"

github_sh_location=cgrindel_bazel_starlib/shlib/lib/github.sh
github_sh="$(rlocation "${github_sh_location}")" ||
  (echo >&2 "Failed to locate ${github_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/github.sh
source "${github_sh}"

git_exe_location=cgrindel_bazel_starlib/tools/git/git.exe
git="$(rlocation "${git_exe_location}")" ||
  (echo >&2 "Failed to locate ${git_exe_location}" && exit 1)

# MARK - Process Args

remote_name=origin
main_branch=main
compress=true

args=()
while (("$#")); do
  case "${1}" in
  "--remote")
    remote="${2}"
    shift 2
    ;;
  "--main")
    main_branch="${2}"
    shift 2
    ;;
  "--repo")
    repo="${2}"
    shift 2
    ;;
  "--tag_name")
    tag_name="${2}"
    shift 2
    ;;
  "--prefix")
    prefix="${2}"
    shift 2
    ;;
  "--nocompress")
    compress=false
    shift 1
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

[[ -z "${tag_name:-}" ]] && fail "Expected a tag name."

# MARK - Main

cd "${BUILD_WORKSPACE_DIRECTORY}"

# Fetch the latest from origin
# shellcheck disable=SC2119
fetch_latest_from_git_remote

if [[ -z "${prefix:-}" ]]; then
  # Make sure that we have a repo name
  if [[ -z "${repo:-}" ]]; then
    repo_url="$(get_git_remote_url)"
    is_github_repo_url "${repo_url}" ||
      fail "Could not figure out repo name. Please specify the repo name using the --repo flag."
    repo="$(get_gh_repo_name "${repo_url}")"
  fi
  prefix_suffix="${tag_name}"
  [[ "${prefix_suffix}" =~ ^v ]] && prefix_suffix="${prefix_suffix:1}"
  prefix="${repo}-${prefix_suffix}"
fi

# Figure out which commit or tag to use
if git_tag_exists "${tag_name}"; then
  commit_or_tag="${tag_name}"
else
  # The tag does not exist. Assume that we are about to tag the code in the main branch.
  commit_or_tag="$(get_git_commit_hash "${remote_name}/${main_branch}")"
fi

# Wrap the archive call
create_archive() {
  "${git}" archive --format=tar "--prefix=${prefix}/" "${commit_or_tag}"
}

# Compress
if [[ "${compress}" == true ]]; then
  function do_archive() {
    # The -n flag for gzip ensures that compression is consistent with every invocation.
    create_archive | gzip -n
  }
else
  function do_archive() {
    create_archive
  }
fi

# Output
if [[ -z "${output_path:-}" ]]; then
  do_archive
else
  do_archive >"${output_path}"
fi
