#!/usr/bin/env bash

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

targets=()
while (("$#")); do
  case "${1}" in
    "--target")
      targets+=( "$2" )
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

# MARK - Execute the targets

cd "${BUILD_WORKSPACE_DIRECTORY}"

# Run before targets
if [[ ${#targets[0]} -gt 0 ]]; then
  run_bazel_targets "${targets[@]}"
fi
