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

generate_gh_changelog_sh_location=cgrindel_bazel_starlib/tools/generate_gh_changelog.sh
generate_gh_changelog_sh="$(rlocation "${generate_gh_changelog_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_gh_changelog_sh_location}" && exit 1)

generate_git_archive_sh_location=cgrindel_bazel_starlib/tools/generate_git_archive.sh
generate_git_archive_sh="$(rlocation "${generate_git_archive_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_git_archive_sh_location}" && exit 1)

generate_sha256_sh_location=cgrindel_bazel_starlib/tools/generate_sha256.sh
generate_sha256_sh="$(rlocation "${generate_sha256_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_sha256_sh_location}" && exit 1)

generate_workspace_snippet_sh_location=cgrindel_bazel_starlib/tools/generate_workspace_snippet.sh
generate_workspace_snippet_sh="$(rlocation "${generate_workspace_snippet_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_workspace_snippet_sh_location}" && exit 1)

# MARK - Process Arguments

remote_name=origin
main_branch=main

args=()
while (("$#")); do
  case "${1}" in
    # "--previous_tag_name")
    #   previous_tag_name="${2}"
    #   shift 2
    #   ;;
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

# TODO: Add warning if this is being run on MacOS about SHA256 for archive not
# being the same as Github archive.

changelog_md="$( "${generate_gh_changelog_sh}" "${tag_name}" )"
archive_sha256="$( "${generate_git_archive_sh}" --tag_name "${tag_name}" | "${generate_sha256_sh}")"
# workspace_snippet="$( "${generate_workspace_snippet_sh}" )"
workspace_snippet=""

release_notes_md="$(cat <<-EOF
${changelog_md}

## Workspace Snippet

\`\`\`python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

${workspace_snippet}
\`\`\`
EOF
)"

# Output the changelog
if [[ -z "${output_path:-}" ]]; then
  echo "${release_notes_md}"
else
  echo "${release_notes_md}" > "${output_path}"
fi
