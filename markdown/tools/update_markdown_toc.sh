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

# MARK - Locate Deps

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/fail.sh
source "${fail_sh}"

update_markdown_doc_sh_location=cgrindel_bazel_starlib/markdown/tools/update_markdown_doc.sh
update_markdown_doc_sh="$(rlocation "${update_markdown_doc_sh_location}")" || \
  (echo >&2 "Failed to locate ${update_markdown_doc_sh_location}" && exit 1)

generate_toc_location=cgrindel_bazel_starlib/markdown/tools/markdown_toc/cmd/generate_toc/generate_toc_/generate_toc
generate_toc="$(rlocation "${generate_toc_location}")" || \
  (echo >&2 "Failed to locate ${generate_toc_location}" && exit 1)



# MARK - Process args

remove_toc_header_entry=true
toc_header="Table of Contents"
generate_toc_cmd=( "${generate_toc}" --start-level=2 )

args=()
while (("$#")); do
  case "${1}" in
    "--no_remove_toc_header_entry")
      remove_toc_header_entry=false
      shift 1
      ;;
    "--toc_header")
      toc_header="${2}"
      shift 2
      ;;
    --*)
      fail "Unexpected flag ${1}"
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done


[[ ${#args[@]} != 2 ]] && fail "Expected exactly two files: input and output."
in_path="${args[0]}"
out_path="${args[1]}"


# MARK - Generate the TOC

toc_dir_path="$( mktemp -d )"
toc_path="${toc_dir_path}/toc.md"

cleanup() {
  rm -rf "${toc_dir_path}"
}
trap cleanup EXIT

# Generate the TOC 
generate_toc_cmd+=( "${in_path}" )
"${generate_toc_cmd[@]}" > "${toc_path}"


# MARK - Clean up the TOC

# Set up the sed command
sed_cmd=( sed -i.bak -E )

# Remove blank linkes
sed_cmd+=( -e '/^\s*$/d' ) 

# Remove the TOC header entry
[[ "${remove_toc_header_entry}" == true ]] && \
  sed_cmd+=( -e '/^[*] \['"${toc_header}"'\]/d' )

# Specify the path to the TOC.
sed_cmd+=( "${toc_path}" ) 

# Execute the sed command
"${sed_cmd[@]}"


# MARK - Update the markdown file with the TOC

"${update_markdown_doc_sh}" \
  --marker "MARKDOWN TOC" \
  --update "${toc_path}" \
  "${in_path}" "${out_path}"
