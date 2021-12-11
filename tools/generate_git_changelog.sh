#!/usr/bin/env bash

# Lovingly inspired by https://gist.github.com/kingkool68/09a201a35c83e43af08fcbacee5c315a.

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

# MARK - Process Args

starting_dir="${PWD}"
cleanup() {
  cd "${starting_dir}"
}
trap cleanup EXIT

args=()
while (("$#")); do
  case "${1}" in
    "--repo_url")
      repository_url="${2}"
      shift 2
      ;;
    "--current_tag")
      current_release_tag="${2}"
      shift 2
      ;;
    "--last_tag")
      last_release_tag="${2}"
      shift 2
      ;;
    "--git")
      git="${2}"
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

# DEBUG BEGIN
echo >&2 "*** CHUCK START" 
# DEBUG END

[[ -z "${git:-}" ]] && git="$(which git)"
[[ -z "${git:-}" ]] && fail "No git was provided and it could not be found."

cd "${BUILD_WORKSPACE_DIRECTORY}"

[[ -z "${repository_url:-}" ]] && repository_url="$(git config --get remote.origin.url)"
[[ -z "${repository_url:-}" ]] && fail "Expected a repository URL."
[[ "${repository_url}" =~ "git@github.com:" ]] && repository_url="$( 
  # Try to coerce a git URL to an https URL
  # Example: git@github.com:cgrindel/bazel-starlib.git
  echo "${repository_url}" | sed -E 's|^[^:]+:([^/]+)/(.*)[.]git$|https://github.com/\1/\2|g'
)"
[[ "${repository_url}" =~ "https:" ]] || fail "Expected an https URL. ${repository_url}"

# MARK - Get the tags

# Get all of the release tags in reverse order
release_tags=( $(git tag --sort=-version:refname -l "v*") )
[[ ${#release_tags[@]} == 0 ]] && fail "No release tags were found."

# Find the current release tag
[[ -z "${current_release_tag:-}" ]] && current_release_tag="${release_tags[0]}"
for (( i = 0; i < ${#release_tags[@]}; i++ )); do
  if [[ "${release_tags[$i]}" == "${current_release_tag}" ]]; then
    current_release_tag_idx=$i
  fi
done
[[ -z "${current_release_tag_idx:-}" ]] && fail "Could not find the current release tag. ${current_release_tag}"

# Find the last release tag
if [[ -z "${last_release_tag:-}" ]]; then
  last_release_tag_idx=$(( ${current_release_tag_idx} + 1 ))
  # DEBUG BEGIN
  echo >&2 "*** CHUCK  current_release_tag_idx: ${current_release_tag_idx}" 
  echo >&2 "*** CHUCK  last_release_tag_idx: ${last_release_tag_idx}" 
  echo >&2 "*** CHUCK  #release_tags[@]: ${#release_tags[@]}" 
  # DEBUG END
  if [[ ${last_release_tag_idx} < ${#release_tags[@]} ]]; then
    last_release_tag="${release_tags[$last_release_tag_idx]}"
  fi
else
  # Make sure that we can find the release tag.
  for (( i = 0; i < ${#release_tags[@]}; i++ )); do
    if [[ "${release_tags[$i]}" == "${last_release_tag}" ]]; then
      last_release_tag_idx=$i
    fi
  done
  [[ -z "${last_release_tag_idx:-}" ]] && fail "Could not find the last release tag. ${last_release_tag}"
  [[ ${last_release_tag_idx} < ${current_release_tag_idx} ]] && \
    fail "The last release tag appears to have occurred after the current release tag. current: ${current_release_tag} , last: ${last_release_tag}"
fi

# DEBUG BEGIN
echo >&2 "*** CHUCK  repository_url: ${repository_url}" 
echo >&2 "*** CHUCK  current_release_tag: ${current_release_tag}" 
echo >&2 "*** CHUCK  last_release_tag: ${last_release_tag}" 
# DEBUG END

# Find the commits
if [[ -z "${last_release_tag:-}" ]]; then
  rev_range="${current_release_tag}"
else
  rev_range="${last_release_tag}..${current_release_tag}"
fi
commits=( $(git log "${rev_range}" --pretty=format:"%H") )

# DEBUG BEGIN
echo >&2 "*** CHUCK  commits:"
for (( i = 0; i < ${#commits[@]}; i++ )); do
  echo >&2 "*** CHUCK   ${i}: ${commits[${i}]}"
done
# DEBUG END
