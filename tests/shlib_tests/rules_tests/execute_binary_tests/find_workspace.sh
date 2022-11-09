#!/usr/bin/env bash

# This utility expects to be run at the root of a Bazel workspace. It fails if
# it is not.

[[ -f "WORKSPACE" ]] || (echo >&2 "WORKSPACE not found." ; exit 1)
