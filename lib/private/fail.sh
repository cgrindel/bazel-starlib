#!/usr/bin/env bash

# Echos the provided message to stderr and exits with an error (1).
fail() {
  local msg="${1}"
  echo >&2 "${msg}" 
  exit 1
}

# Prints the message to stderr.
warn() {
  # local msg="${1}"
  msg="WARNING: ${1}"
  shift 1
  args=()
  while (("$#")); do
    msg="${msg}"$'\n'"${1}"
    shift 1
  done
  echo >&2 "${msg}" 
}
