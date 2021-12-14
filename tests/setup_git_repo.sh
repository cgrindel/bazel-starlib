#!/usr/bin/env bash

# Clone this repo so that we have an actual git repository for the test
repo_dir="${PWD}/repo"
rm -rf "${repo_dir}"
repo_url="https://github.com/cgrindel/bazel-starlib"
git clone "${repo_url}" "${repo_dir}" 2>/dev/null

# Any utilities under test need to know where the workspace directory is. In
# this case, we are faking it out by setting it to our cloned repo directory.
export "BUILD_WORKSPACE_DIRECTORY=${repo_dir}"
