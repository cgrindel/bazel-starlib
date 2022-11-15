#!/usr/bin/env bash

# This script will query for all of the updatesrc_update targets and execute
# each one.

set -o errexit -o nounset -o pipefail

# MARK - Functions

run_bazel_targets() {
  while (("$#")); do
    local target="${1}"
    if [[ -n "${target:-}" ]]; then
      bazel run "${target}"
    fi
    shift 1
  done

}

# MARK - Process Args

targets_to_run_before=()
targets_to_run_after=()
while (("$#")); do
  case "${1}" in
    "--run_before")
      targets_to_run_before+=( "$2" )
      shift 2
      ;;
    "--run_after")
      targets_to_run_after+=( "$2" )
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

cd "${BUILD_WORKSPACE_DIRECTORY}"

# Run before targets
if [[ ${#targets_to_run_before[0]} -gt 0 ]]; then
  run_bazel_targets "${targets_to_run_before[@]}"
fi

# Query for any 'updatesrc_update' targets
bazel_query="kind(updatesrc_update, //...)"
update_targets=()
while IFS=$'\n' read -r line; do update_targets+=("$line"); done < <(
  bazel query "${bazel_query}" | sort
)
if [[ ${#update_targets[@]} -gt 0 ]]; then
  run_bazel_targets "${update_targets[@]}"
fi

# Run after targets
if [[ ${#targets_to_run_after[0]} -gt 0 ]]; then
  run_bazel_targets "${targets_to_run_after[@]}"
fi
