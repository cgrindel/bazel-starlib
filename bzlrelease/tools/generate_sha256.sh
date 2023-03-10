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

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
source "${env_sh}"


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

# Define the hash function
case "${utility}" in
  shasum)
    function sumsha256() {
      shasum -a 256 | sed -E -n 's/^([^[:space:]]+).*/\1/gp'
    }
    ;;
  openssl)
    function sumsha256() {
      # On Ubuntu, we can see a prefix of '(stdin)= '
      # 2023-02-01:  This has recently changed to be 'SHA2-256(stdin)='.
      openssl dgst -sha256 | sed -E 's|^.*\(stdin\)= (.*)|\1|g'
    }
    ;;
  *)
    fail "Unrecognized utility. ${utility:-}"
    ;;
esac

# Generate the hash
sumsha256 < "${source_path:-/dev/stdin}" > "${output_path:-/dev/stdout}"
