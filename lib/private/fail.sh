#!/usr/bin/env bash

# Echos the provided message to stderr and exits with an error (1).
fail() {
  local msg="${1:-}"
  shift 1
  while (("$#")); do
    msg="${msg:-}"$'\n'"${1}"
    shift 1
  done
  echo >&2 "${msg}" 
  exit 1
}

# Prints the message to stderr.
warn() {
  # local msg="${1}"
  msg="WARNING: ${1}"
  shift 1
  while (("$#")); do
    msg="${msg}"$'\n'"${1}"
    shift 1
  done
  echo >&2 "${msg}" 
}

# Print an error message and dump the usage/help for the utility.
# This function expects a get_usage function to be defined.
usage_error() {
  local msg="${1:-}"
  cmd=(fail)
  [[ -z "${msg:-}" ]] || cmd+=("${msg}" "")
  cmd+=("$(get_usage)")
  "${cmd[@]}"
}

show_usage() {
  echo "$(get_usage)"
  exit 0
}
