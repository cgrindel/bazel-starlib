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

if [[ -z "${source_path:-}" && -z "${output_path:-}" && ${#args[@]} == 2 ]]; then
  source_path="${1}"
  output_path="${2}"
fi

[[ -z "${source_path:-}" ]] && fail "Expected a source path."
[[ -z "${output_path:-}" ]] && fail "Expected an output path."

if [[ -z "${utility:-}" ]]; then
  if is_installed openssl; then
    utility=openssl
  elif is_installed sha256sum; then
    utility=sha256sum
  else
    fail "Could not find a supported utility to generate a SHA256 hash."
  fi
fi

case "${utility}" in
  "openssl")
    output="$(
    openssl dgst -sha256 "${source_path}" | \
      sed -E -n 's/^SHA256[^=]+= ([^[:space:]]+).*/\1/gp' 
    )"
    ;;
  "sha256sum")
    sha256sum "${source_path}" |  sed -E -n 's/^([^[:space:]]+).*/\1/gp'
    ;;
  *)
    fail "Unrecognized utility. ${utility}"
    ;;
esac
  
# Write the hash
echo "${output}" > "${output_path}"

# if is_installed openssl; then
  # openssl dgst -sha256 "${source_path}" | sed -E -n 's/^SHA256[^=]+= ([^[:space:]]+).*/\1/gp' > "${output_path}"
# elif is_installed sha256sum; then
  # sha256sum "${source_path}" | sed -E -n 's/^([^[:space:]]+).*/\1/gp' > "${output_path}"
# else
  # fail "Could not find a supported utility to generate a SHA256 hash."
# fi
