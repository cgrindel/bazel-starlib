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

generate_gh_changelog_sh_location=cgrindel_bazel_starlib/tools/generate_gh_changelog.sh
generate_gh_changelog_sh="$(rlocation "${generate_gh_changelog_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_gh_changelog_sh_location}" && exit 1)

# MARK - Process Arguments

starting_dir="${PWD}"

args=()
while (("$#")); do
  case "${1}" in
    "--output")
      output_path="${2}"
      shift 2
      ;;
    "--generate_workspace_snippet")
      # If the input path is not absolute, then resolve it to be relative to
      # the starting directory. We do this before we starting changing
      # directories.
      generate_workspace_snippet="${2}"
      [[ "${generate_workspace_snippet}" =~ ^/ ]] || \
        generate_workspace_snippet="${starting_dir}/${generate_workspace_snippet}"
      shift 2
      ;;
    --*)
      fail "Unrecognized flag ${1}."
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

[[ ${#args[@]} == 0 ]] && fail "A tag name for the release must be specified."
tag_name="${args[0]}"

[[ -z "${generate_workspace_snippet:-}" ]] && \
  fail "Expected a value for --generate_workspace_snippet."


# MARK - Generate the changelog.

cd "${BUILD_WORKSPACE_DIRECTORY}"

[[ "$(uname)" =~ "Linux" ]] || warn \
  "Incompatible SHA256 for archive may occur due to the current OS ($(uname))!" \
  "The result of gzip compression varies based upon the operating system. The archive file" \
  "that Github produces appears to be compatible with Linux implementations of gzip. Hence," \
  "generating release notes on this OS may result in an incompatible SHA256 value."

changelog_md="$( "${generate_gh_changelog_sh}" "${tag_name}" )"

workspace_snippet="$( "${generate_workspace_snippet}" --tag "${tag_name}" )"

release_notes_md="$(cat <<-EOF
${changelog_md}

## Workspace Snippet

${workspace_snippet}
EOF
)"

# Output the changelog
if [[ -z "${output_path:-}" ]]; then
  echo "${release_notes_md}"
else
  echo "${release_notes_md}" > "${output_path}"
fi
