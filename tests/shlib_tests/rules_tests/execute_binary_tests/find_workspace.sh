#!/usr/bin/env bash

# This utility expects to be run at the root of a Bazel workspace. It fails if
# it is not.

[[ -f "MODULE.bazel" ]] || (
  echo >&2 "MODULE.bazel not found."
  exit 1
)
