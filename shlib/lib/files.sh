#!/usr/bin/env bash

# This is used to determine if the library has been loaded
cgrindel_bazel_shlib_lib_files_loaded() { return; }

if [[ $(type -t cgrindel_bazel_shlib_lib_paths_loaded) != function ]]; then
  # shellcheck source=SCRIPTDIR/paths.sh
  source "shlib/lib/paths.sh"
fi

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

