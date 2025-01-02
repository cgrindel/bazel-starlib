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

is_installed gh || fail "Could not find Github CLI (gh)."


# MARK - Usage

get_usage() {
  local utility
  utility="$(basename "${BASH_SOURCE[0]}")"
  cat <<-EOF
Execute a Github Action workflow to create a relase with the specified tag.

Usage:
${utility} --worklfow <workflow_name> [OPTION]... <tag>

Required:
  --workflow <name>   The name of the Github Actions workflow that will create 
                      the release.
  <tag>               The release tag.

Options:
  --ref <ref>         The ref (e.g. branch) from which to run the workflow.
  --reset_tag         If specified and if a release does not exist for the tag,
                      the existing tag will be deleted and a new one created.
EOF
}


# MARK - Process Arguments

reset_tag=false

args=()
while (("$#")); do
  case "${1}" in
    "--help")
      show_usage
      ;;
    --workflow)
      workflow_name="${2}"
      shift 2
      ;;
    --ref)
      ref="${2}"
      shift 2
      ;;
    --reset_tag)
      reset_tag=true
      shift 1
      ;;
    --*)
      fail "Unrecognized flag. ${1}"
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ -z "${workflow_name:-}" ]] && usage_error "Expected a workflow name."

[[ ${#args[@]} == 0 ]] && usage_error "Expected a version tag for the release. (e.g v.1.2.3)"
tag="${args[0]}"
is_valid_release_tag "${tag}" || fail "Invalid version tag. Expected it to start with 'v'."


# MARK - Run the workflow

cd "${BUILD_WORKSPACE_DIRECTORY}"

# Launch the workflow
gh_cmd=(gh workflow run "${workflow_name}")
[[ -z "${ref:-}" ]] || gh_cmd+=(--ref "${ref}")
gh_cmd+=(-f "release_tag=${tag}")
gh_cmd+=(-f "reset_tag=${reset_tag}")
"${gh_cmd[@]}"
