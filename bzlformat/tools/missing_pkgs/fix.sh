#!/usr/bin/env bash

# Adds bzlformat_pkg declarations to any Bazel package that is missing one.

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

arrays_lib="$(rlocation cgrindel_bazel_starlib/shlib/lib/arrays.sh)"
source "${arrays_lib}"

common_sh_location=cgrindel_bazel_starlib/bzlformat/tools/missing_pkgs/common.sh
common_sh="$(rlocation "${common_sh_location}")" || \
  (echo >&2 "Failed to locate ${common_sh_location}" && exit 1)
source "${common_sh}"

find_missing_pkgs_bin="$(rlocation cgrindel_bazel_starlib/bzlformat/tools/missing_pkgs/find.sh)"
buildozer="$(rlocation com_github_bazelbuild_buildtools/buildozer/buildozer_/buildozer)"

exclude_pkgs=()
args=()
while (("$#")); do
  case "${1}" in
    "--exclude")
      exclude_pkgs+=( $(normalize_pkg "${2}") )
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done


cd "${BUILD_WORKSPACE_DIRECTORY}"

find_args=()
for pkg in "${exclude_pkgs[@]:-}" ; do
  find_args+=(--exclude "${pkg}")
done
missing_pkgs=( $(. "${find_missing_pkgs_bin}" "${find_args[@]:-}") )

# If no missing packages, we are done.
[[ ${#missing_pkgs[@]} == 0 ]] && echo "No missing package updates were found." && exit

echo "Updating the following packages:"
for pkg in "${missing_pkgs[@]}" ; do
  echo "${pkg}"
done

buildozer_cmds=()
buildozer_cmds+=( 'fix movePackageToTop' )
buildozer_cmds+=( 'new_load @cgrindel_bazel_starlib//bzlformat:defs.bzl bzlformat_pkg' )
buildozer_cmds+=( 'new bzlformat_pkg bzlformat' )
buildozer_cmds+=( 'fix unusedLoads' )

# Execute the buildozer commands
missing_pkgs_args=()
for pkg in "${missing_pkgs[@]}" ; do
  missing_pkgs_args+=( "${pkg}:__pkg__" )
done
"${buildozer}" "${buildozer_cmds[@]}" "${missing_pkgs_args[@]}"
