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

# MARK - Locate Deps

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

update_markdown_doc_sh_location=cgrindel_bazel_starlib/markdown/tools/update_markdown_doc.sh
update_markdown_doc_sh="$(rlocation "${update_markdown_doc_sh_location}")" || \
  (echo >&2 "Failed to locate ${update_markdown_doc_sh_location}" && exit 1)

gh_md_toc_location=ekalinin_github_markdown_toc/gh_md_toc
gh_md_toc="$(rlocation "${gh_md_toc_location}")" || \
  (echo >&2 "Failed to locate ${gh_md_toc_location}" && exit 1)


# MARK - Process args

gh_md_toc_cmd=( "${gh_md_toc}" )

# hide_header="false"
# hide_footer="false"
# start_depth=0
# depth=0
# indent=2

args=()
while (("$#")); do
  case "${1}" in
    "--hide_header")
      gh_md_toc_args+=( --hide-header )
      shift 1
      ;;
    "--hide_footer")
      gh_md_toc_args+=( --hide-footer )
      shift 1
      ;;
    "--no_escape")
      gh_md_toc_args+=( --no-escape )
      shift 1
      ;;
    "--debug")
      gh_md_toc_args+=( --debug )
      shift 1
      ;;
    "--start_depth")
      gh_md_toc_args+=( "--start-depth=${2}" )
      shift 2
      ;;
    "--depth")
      gh_md_toc_args+=( "--depth=${2}" )
      shift 2
      ;;
    "--indent")
      gh_md_toc_args+=( "--indent=${2}" )
      shift 2
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

gh_md_toc_cmd+=( "${in_path}" )
toc="$( "${gh_md_toc_cmd[@]}" )"


