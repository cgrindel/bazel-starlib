#!/usr/bin/env bash

# Echos the provided message to stderr and exits with an error (1).
fail() {
  local msg="${1}"
  echo >&2 "${msg}" 
  exit 1
}
