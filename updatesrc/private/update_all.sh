#!/usr/bin/env bash

# This script will query for all of the updatesrc_update targets and execute
# each one.

set -uo pipefail

cd "${BUILD_WORKSPACE_DIRECTORY}"

# Collect targets that have been specified on the command-line
targets_to_run=("${@:-}")

# Query for any 'updatesrc_update' targets
bazel_query="kind(updatesrc_update, //...)"
targets_to_run+=( $(bazel query "${bazel_query}" | sort) )

# Execute each target
for target in "${targets_to_run[@]}" ; do
  if [[ -z "${target:-}" ]]; then
    continue
  fi
  bazel run "${target}"
done
