#!/usr/bin/env bash

# Since we are in a library, check if rlocation has been defined yet.
if [[ $(type -t rlocation) != function ]]; then
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
fi

if [[ $(type -t cgrindel_bazel_shlib_lib_paths_loaded) != function ]]; then
  paths_sh_location=cgrindel_bazel_starlib/shlib/lib/paths.sh
  paths_sh="$(rlocation "${paths_sh_location}")" || \
    (echo >&2 "Failed to locate ${paths_sh_location}" && exit 1)
  # shellcheck disable=SC1090 # external source
  source "${paths_sh}"
fi

# This is used to determine if the library has been loaded
cgrindel_bazel_shlib_lib_files_loaded() { return; }


# Recursively searches for a file starting from the current directory up to the root of the filesystem.
#
# Flags:
#  --start_dir: The directory where to start the search.
#  --error_if_not_found: If specified, the function will return 1 if the file is not found.
# 
# Args:
#  target_file: The basename for the file to be found.
#
# Outputs:
#   stdout: The fully-qualified path to the 
#   stderr: None.
upsearch() {
  # Lovingly inspired by https://unix.stackexchange.com/a/13474.

  local error_if_not_found=0
  local start_dir="${PWD}"
  local args=()
  while (("$#")); do
    case "${1}" in
      "--start_dir")
        local start_dir
        start_dir="$(normalize_path "${2}")"
        shift 2
        ;;
      "--error_if_not_found")
        local error_if_not_found=1
        shift 1
        ;;
      *)
        args+=( "${1}" )
        shift 1
        ;;
    esac
  done

  local target_file="${args[0]}"

  slashes=${start_dir//[^\/]/}
  directory="${start_dir}"
  for (( n=${#slashes}; n>0; --n ))
  do
    local test_path="${directory}/${target_file}"
    test -e "${test_path}" && \
      normalize_path "${test_path}" &&  return 
    directory="${directory}/.."
  done

  # Did not find the file
  if [[ ${error_if_not_found} == 1 ]]; then
    return 1
  fi
}

