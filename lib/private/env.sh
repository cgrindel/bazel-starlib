#!/usr/bin/env bash

# Environment-related Functions

# This is used to determine if the library has been loaded
cgrindel_bazel_starlib_lib_private_env_loaded() { return; }

# Succeeds if the specified executable is found in the path. Otherwise, it fails.
is_installed() {
  local name="${1}"
  which "${name}" > /dev/null
}

