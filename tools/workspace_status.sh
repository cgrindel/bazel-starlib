#!/usr/bin/env bash

# This script is executed by Bazel using the --workspace_status_command flag.
# It provides variables that can be accessed from certain rule attributes.
# https://docs.bazel.build/versions/main/user-manual.html#workspace_status

set -euo pipefail

# Get the current commit 
current_commit="$(git log -1 --pretty=format:%H)"

# Get the last release info
last_release_tag="$(git tag --sort=refname -l "v*" | tail -n 1)"
if [[ -z "${last_release_tag}" ]]; then
  last_release_tag="v0.0.0" 
  last_release_commit=""
else
  last_release_commit="$(git rev-list -1 "${last_release_tag}")"
fi

current_release_tag="${last_release_tag}"
[[ "${current_commit}" != "${last_release_commit}" ]] && \
  current_release_tag="${current_release_tag}-dirty"

echo "STABLE_LAST_RELEASE_TAG ${last_release_tag}"
echo "STABLE_LAST_RELEASE_COMMIT ${last_release_commit}"
echo "CURRENT_COMMIT ${current_commit}"
echo "CURRENT_RELEASE_TAG  ${current_release_tag}"
