#!/usr/bin/env bash

do_exit() {
  local exit_code=${1:-0}
  exit "${exit_code}"
}

# Prints the message to stderr.
warn() {
  if [[ ${#} -gt 0 ]]; then
    echo >&2 "${@}"
  else
    cat >&2
  fi
}

# Echos the provided message to stderr and exits with an error (1).
fail() {
  local cmd=(warn)
  if [[ ${#} -gt 0 ]]; then
    cmd+=("${@}")
  fi
  "${cmd[@]}"
  do_exit 1
}

# Print an error message and dump the usage/help for the utility.
# This function expects a get_usage function to be defined.
usage_error() {
  [[ ${#} -gt 0 ]] && warn "${@}"
  fail "$(get_usage)"
}

show_usage() {
  get_usage
  do_exit 0
}
