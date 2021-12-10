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

write_bazel_status_vars_sh_location=cgrindel_bazel_starlib/tools/write_bazel_status_vars.sh
write_bazel_status_vars_sh="$(rlocation "${write_bazel_status_vars_sh_location}")" || \
  (echo >&2 "Failed to locate ${write_bazel_status_vars_sh_location}" && exit 1)


# MARK - Set up Status Files

stable_status_path="stable-status.txt"
cat > "${stable_status_path}" <<-EOF
STABLE_VALUE chicken
STABLE_NOT_USED howdy
STABLE_CURRENT_RELEASE_TAG v1.2.3
STABLE_CURRENT_RELEASE 1.2.3
EOF

volatile_status_path="volatile-status.txt"
cat > "${volatile_status_path}" <<-EOF
VOLATILE_VALUE smidgen
EOF

# MARK - Test Write

output_path="bazel_status_vars.txt"

"${write_bazel_status_vars_sh}" \
  --status_file "${stable_status_path}" \
  --status_file "${volatile_status_path}" \
  --output "${output_path}"

[[ -f "${output_path}" ]] || fail "Failed to create the output file. ${output_path}"

output="$(< "${output_path}")"
expected_output="$(cat <<-EOF
STABLE_CURRENT_RELEASE=1.2.3
STABLE_CURRENT_RELEASE_TAG=v1.2.3
STABLE_NOT_USED=howdy
STABLE_VALUE=chicken
VOLATILE_VALUE=smidgen
EOF
)"

[[ "${output}" == "${expected_output}" ]] || \
  fail $'Output did not match expected.\nactual:\n'"${output}"$'\nexpected:\n'"${expected_output}"
