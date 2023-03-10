#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

update_markdown_doc_sh_location=cgrindel_bazel_starlib/markdown/tools/update_markdown_doc.sh
update_markdown_doc_sh="$(rlocation "${update_markdown_doc_sh_location}")" || \
  (echo >&2 "Failed to locate ${update_markdown_doc_sh_location}" && exit 1)


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
    "--readme")
      # This is a relative path from the root of the workspace.
      readme_path="${2}"
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


# MARK - Update README.md

cd "${BUILD_WORKSPACE_DIRECTORY}"

[[ -z "${readme_path:-}" ]] && readme_path="README.md"
[[ -f "${readme_path}" ]] || fail "Could not find the README.md file. ${readme_path}"

# Set up the cleanup
readme_backup="${readme_path}.bak"
snippet_path="$(mktemp)"
cleanup() {
  local exit_code="${1}"
  rm -f "${snippet_path}" 
  if [[ ${exit_code} == 0 ]]; then
    rm -f "${readme_backup}"
  fi
}
trap 'cleanup $?' EXIT

# Generate the snippet
"${generate_workspace_snippet}" --tag "${tag_name}" --output "${snippet_path}"

# Copy the readme
cp "${readme_path}" "${readme_backup}"

# Update the original
"${update_markdown_doc_sh}" \
  --marker_begin "BEGIN WORKSPACE SNIPPET" \
  --marker_end "END WORKSPACE SNIPPET" \
  --update "${snippet_path}" \
  "${readme_backup}" "${readme_path}"
