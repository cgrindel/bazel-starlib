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

# Use the Bazel binary specified by the integration test. Otherise, fall back 
# to bazel.
bazel="${BIT_BAZEL_BINARY:-bazel}"

arrays_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/arrays.sh)"
# shellcheck source=SCRIPTDIR/../../../shlib/lib/arrays.sh
source "${arrays_lib}"

common_sh_location=cgrindel_bazel_starlib/bzlformat/tools/missing_pkgs/common.sh
common_sh="$(rlocation "${common_sh_location}")" || \
  (echo >&2 "Failed to locate ${common_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/common.sh
source "${common_sh}"

query_for_pkgs() {
  local query="${1}"
  # We need to add a prefix here (//). Otherwise, the root package would be an 
  # empty string. Empty strings are easily lost in Bash.
  "${bazel}" query "${query}" --output package | sed -e 's|^|//|'
}

fail_on_missing_pkgs=false
exclude_pkgs=()
args=()
while (("$#")); do
  case "${1}" in
    "--exclude")
      exclude_pkgs+=( "$(normalize_pkg "${2}")" )
      shift 2
      ;;
    "--fail_on_missing_pkgs")
      fail_on_missing_pkgs=true
      shift 1
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

cd "${BUILD_WORKSPACE_DIRECTORY}"

# The output `package` appears to sort the results
all_pkgs=()
while IFS=$'\n' read -r line; do all_pkgs+=("$line"); done < <(
  query_for_pkgs //...
)
pkgs_with_format=()
while IFS=$'\n' read -r line; do pkgs_with_format+=("$line"); done < <(
  query_for_pkgs 'kind(bzlformat_format, //...)'
)

pkgs_missing_format=()
if [[ "${#all_pkgs[@]}" -gt 0 ]]; then
  for pkg in "${all_pkgs[@]}" ; do
    if ! contains_item "${pkg}" "${pkgs_with_format[@]:-}" && ! contains_item "${pkg}" "${exclude_pkgs[@]:-}"; then
      pkgs_missing_format+=( "${pkg}" )
    fi
  done
fi

if [[ ${#pkgs_missing_format[@]} -gt 0 ]]; then
  # Output the missing packages.
  print_by_line "${pkgs_missing_format[@]:-}"

  # If configured to fail on missing packages, do so.
  if [[ "${fail_on_missing_pkgs}" == true ]]; then
    exit 1
  fi
fi

