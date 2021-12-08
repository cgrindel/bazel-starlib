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

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

source_bazel_status_vars_sh_location=cgrindel_bazel_starlib/lib/private/source_bazel_status_vars.sh
source_bazel_status_vars_sh="$(rlocation "${source_bazel_status_vars_sh_location}")" || \
  (echo >&2 "Failed to locate ${source_bazel_status_vars_sh_location}" && exit 1)
source "${source_bazel_status_vars_sh}"


status_file="status_file.txt"
cat > "${status_file}" <<-EOF
STABLE_CHICKEN_SMIDGEN hello
NO_VALUE
SPACES_AND_QUOTES this value has "quotes" and spaces
CHICKEN_SMIDGEN goodbye
EOF

output=$( source_bazel_status_vars "${status_file}" )
eval "${output}"

[[ "${WKSP__STABLE_CHICKEN_SMIDGEN:-}" == "hello" ]] || \
  fail "Invalid WKSP_STABLE_CHICKEN_SMIDGEN value. actual: ${WKSP__STABLE_CHICKEN_SMIDGEN:-}"

[[ "${WKSP__CHICKEN_SMIDGEN:-}" == "goodbye" ]] || \
  fail "Invalid WKSP_CHICKEN_SMIDGEN value. actual: ${WKSP__CHICKEN_SMIDGEN:-}"

[[ -z "${WKSP__NO_VALUE:-}" ]] || \
  fail "Invalid WKSP_NO_VALUE value. actual: ${WKSP__NO_VALUE}"

[[ "${WKSP__SPACES_AND_QUOTES:-}" == "this value has \"quotes\" and spaces" ]] || \
  fail "Invalid WKSP_SPACES_AND_QUOTES value. actual: ${WKSP__SPACES_AND_QUOTES:-}"
