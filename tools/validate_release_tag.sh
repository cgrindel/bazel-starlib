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

is_installed git || fail "Could not find git."


# MARK - Process Args

args=()
while (("$#")); do
  case "${1}" in
    --remote)
      remote="${2}"
      shift 2
      ;;
    --branch)
      main_branch="${2}"
      shift 2
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

[[ ${#args[@]} == 0 ]] && usage_error "Expected a version tag. (e.g v.1.2.3)"
tag="${args[0]}"

# MARK - Format Check

# DEBUG BEGIN
set -x
# DEBUG END

[[ "${tag}" =~ ^v ]] || fail "Invalid version tag. Expected it to start with 'v'."


# MARK - Check for Existence

cd "${BUILD_WORKSPACE_DIRECTORY}"

fetch_latest_from_git_remote "${remote}" "${main_branch}"

tag_exists_local=false
git_tag_exists "${tag}" && tag_exists_local=true

tag_exists_remote=false
git_tag_exists_on_remote "${tag}" && tag_exists_remote=true


# MARK - Output Existence Values

output="$(cat <<-EOF
Exists Locally: ${tag_exists_local}
Exists on Remote: ${tag_exists_remote}
EOF
)"
echo "${output}"
