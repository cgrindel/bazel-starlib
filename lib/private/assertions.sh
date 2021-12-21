#!/usr/bin/env bash

# This is used to determine if the library has been loaded
cgrindel_bazel_shlib_lib_assertions_loaded() { return; }

# Fail a test with the specified message.
#
# Args:
#   err_msg: The message to print to stderr.
#
# Outputs:
#   stdout: None.
#   stderr: The error message.
fail() {
  local err_msg="${1:-}"
  [[ -n "${err_msg}" ]] || err_msg="Unspecified error occurred."
  echo >&2 "${err_msg}"
  exit 1
}

# Asserts that the actual value equals the expected value.
#
# Args:
#   expected: The expected value.
#   actual: The actual value.
#   err_msg: Optional. The error message to print if the assertion fails.
#
# Outputs:
#   stdout: None.
#   stderr: None.
assert_equal() {
  local expected="${1}"
  local actual="${2}"
  local err_msg_prefix="${3:-}"
  local err_msg="Expected to be equal. expected: ${expected}, actual: ${actual}"
  if [[ ! -z "${err_msg_prefix}" ]]; then
    local err_msg="${err_msg_prefix} ${err_msg}"
  fi
  [[ "${expected}" == "${actual}" ]] || fail "${err_msg}"
}

# Asserts that the actual value contains the specified regex pattern.
#
# Args:
#   pattern: The expected pattern.
#   actual: The actual value.
#   err_msg: Optional. The error message to print if the assertion fails.
#
# Outputs:
#   stdout: None.
#   stderr: None.
assert_match() {
  local pattern=${1}
  local actual="${2}"
  local err_msg_prefix="${3:-}"
  local err_msg="Expected to match. pattern: ${pattern}, actual: ${actual}"
  if [[ ! -z "${err_msg_prefix}" ]]; then
    local err_msg="${err_msg_prefix} ${err_msg}"
  fi
  [[ "${actual}" =~ ${pattern} ]] || fail "${err_msg}"
}

