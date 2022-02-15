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

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

check_links_sh_location=cgrindel_bazel_starlib/markdown/tools/check_links.sh
check_links_sh="$(rlocation "${check_links_sh_location}")" || \
  (echo >&2 "Failed to locate ${check_links_sh_location}" && exit 1)

stdout_path="stdout.txt"
stderr_path="stderr.txt"
bar_md_path="bar.md"
foo_md_path="foo.md"

dump_out_files() {
  echo >&2 "*** $(basename "${BASH_SOURCE[0]}") stdout BEGIN:" 
  cat >&2 "${stdout_path}"
  echo >&2 "*** $(basename "${BASH_SOURCE[0]}") stdout END:" 
  echo >&2 "*** $(basename "${BASH_SOURCE[0]}") stderr BEGIN:" 
  cat >&2 "${stderr_path}"
  echo >&2 "*** $(basename "${BASH_SOURCE[0]}") stderr END:" 
}

do_cmd() {
  # DEBUG BEGIN
  echo >&2 "*** CHUCK do_cmd START" 
  # DEBUG END
  cmd=( "${check_links_sh}" "${bar_md_path}" "${foo_md_path}" )
  [[ ${#} > 0 ]] && cmd+=( "${@}" )
  "${cmd[@]}" > "${stdout_path}" 2> "${stderr_path}"
}

# MARK - Test Successful Check

# Bar content
echo "" > "${bar_md_path}"

# Foo content
foo_md_content="$(cat <<-'EOF'
This is foo.md.
- [Bar](bar.md)
EOF
)"
echo "${foo_md_content}" > "${foo_md_path}"

# Execute command
do_cmd || fail "Expected link checks to succeed."


# MARK - Test Failed Link Check

bar_md_path="bar.md"
echo "" > "${bar_md_path}"

foo_md_path="foo.md"
foo_md_content="$(cat <<-'EOF'
This is foo.md.
- [Bar](bar.md)
- [Bad](does_not_exist.md)
EOF
)"
echo "${foo_md_content}" > "${foo_md_path}"

do_cmd && fail "Expected bad link check to fail."

stdout_contents="$(< "${stdout_path}")"
assert_match "does_not_exist.md → Status: 400" "${stdout_contents}" "Did not find expected failed link."


# MARK - Test ECONNRESET Error Retry

export ECONNRESET_FAILURE_COUNT=0
do_econnreset_error() {
  # DEBUG BEGIN
  echo "*** CHUCK do_econnreset_error START" 
  echo "*** CHUCK do_econnreset_error ECONNRESET_FAILURE_COUNT: ${ECONNRESET_FAILURE_COUNT}" 
  # [[ ${ECONNRESET_FAILURE_COUNT} > 0 ]] && (echo "DIE"; exit 1)
  # DEBUG END
  local total_econnreset_failures=${1}
  if [[ ${ECONNRESET_FAILURE_COUNT} < ${total_econnreset_failures} ]]; then
    export ECONNRESET_FAILURE_COUNT=$(( ${ECONNRESET_FAILURE_COUNT} + 1 ))
    echo >&2 "Error: read ECONNRESET"
    return 1
  fi
}
export -f do_econnreset_error

check_with_one_econnreset() {
  # DEBUG BEGIN
  # echo >&2 "*** CHUCK check_with_one_econnreset START" 
  echo "*** CHUCK check_with_one_econnreset START" 
  # DEBUG END
  do_econnreset_error 1
}
export -f check_with_one_econnreset

# Bar content
echo "" > "${bar_md_path}"

# Foo content
foo_md_content="$(cat <<-'EOF'
This is foo.md.
- [Bar](bar.md)
EOF
)"
echo "${foo_md_content}" > "${foo_md_path}"

# DEBUG BEGIN
echo >&2 "*** CHUCK $(basename "${BASH_SOURCE[0]}") START" 
# DEBUG END

# Execute command
export ECONNRESET_FAILURE_COUNT=0
do_cmd --markdown_link_check_sh check_with_one_econnreset || \
  (dump_out_files ; fail "Expected link checks to succeed with one ECONNRESET error.")
  # fail "Expected link checks to succeed with one ECONNRESET error."

# stderr_contents="$(< "${stderr_path}")"
# assert_match "An ECONNRESET error occurred. attempts: 0" "${stderr_contents}" "Did not find ECONNRESET retry message."

# DEBUG BEGIN
dump_out_files
fail "STOP"
# DEBUG END
