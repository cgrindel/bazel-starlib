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

# MARK - Functions

is_installed() {
  local name="${1}"
  which "${name}" > /dev/null
}

# MARK - Process Arguments

args=()
while (("$#")); do
  case "${1}" in
    "--source")
      source_path="${2}"
      shift 2
      ;;
    "--output")
      output_path="${2}"
      shift 2
      ;;
    "--utility")
      utility="${2}"
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

# if [[ -z "${source_path:-}" && -z "${output_path:-}" && ${#args[@]} == 2 ]]; then
#   source_path="${args[0]}"
#   output_path="${args[1]}"
# fi

[[ -z "${source_path:-}" ]] && fail "Expected a source path."
# [[ -z "${output_path:-}" ]] && fail "Expected an output path."

# Select the utility to use
if [[ -z "${utility:-}" ]]; then
  if is_installed shasum; then
    utility=shasum
  elif is_installed openssl; then
    utility=openssl
  else
    fail "Could not find a supported utility to generate a SHA256 hash."
  fi
fi

# Generate the hash
case "${utility}" in
  shasum)
    output="$(
    cat "${source_path}" | shasum -a 256 | sed -E -n 's/^([^[:space:]]+).*/\1/gp'
    )"
    ;;
  openssl)
    output="$( cat "${source_path}" | openssl dgst -sha256 )"
    ;;
  # shasum)
  #   output="$(
  #   shasum -a 256 "${source_path}" |  sed -E -n 's/^([^[:space:]]+).*/\1/gp'
  #   )"
  #   ;;
  # openssl)
  #   output="$(
  #   openssl dgst -sha256 "${source_path}" | \
  #     sed -E -n 's/^SHA256[^=]+= ([^[:space:]]+).*/\1/gp' 
  #   )"
  #   ;;
  *)
    fail "Unrecognized utility. ${utility:-}"
    ;;
esac
  
# Write the hash
if [[ -z "${output_path:-}" ]]; then
  echo "${output}"
else
  echo "${output}" > "${output_path}"
fi
