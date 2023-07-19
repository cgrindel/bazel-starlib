#!/usr/bin/env bash

cd "${BUILD_WORKSPACE_DIRECTORY}" || \
  (echo >&2 "BUILD_WORKSPACE_DIRECTORY not defined." && exit 1)

echo "bar tidy ran" >> bar.tidy_out
