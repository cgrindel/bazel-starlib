#!/usr/bin/env bash

# Git-related Functions

# This is used to determine if the library has been loaded
cgrindel_bazel_starlib_lib_private_git_loaded() { return; }

# Returns the URL for the git repository. It is typically in the form:
#  git@github.com:cgrindel/bazel-starlib.git
# OR 
#  https://github.com/cgrindel/bazel-starlib.git
get_git_remote_url() {
  git config --get remote.origin.url
}

