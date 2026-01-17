#!/usr/bin/env bash

# This script will query for all of the updatesrc_update targets and execute
# each one.

set -o errexit -o nounset -o pipefail

# Use the Bazel binary specified by the integration test. Otherise, fall back
# to bazel.
bazel="${BIT_BAZEL_BINARY:-bazel}"

# MARK - Functions

run_bazel_targets() {
  while (("$#")); do
    local target="${1}"
    if [[ -n "${target:-}" ]]; then
      "${bazel}" run "${target}"
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
    targets_to_run_before+=("$2")
    shift 2
    ;;
  "--run_after")
    targets_to_run_after+=("$2")
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
starlark_file="$(mktemp)"
cleanup() {
  rm -f "${starlark_file}"
}
trap cleanup EXIT
cat >"${starlark_file}" <<-EOF
def format(target):
  # Only include targets that compatible with the platform
  if "IncompatiblePlatformProvider" not in providers(target):
    return target.label
  return ""
EOF
bazel_query="kind(updatesrc_update, //...)"
update_targets=()
while IFS=$'\n' read -r line; do update_targets+=("$line"); done < <(
  "${bazel}" cquery "${bazel_query}" \
    --output=starlark \
    --starlark:file="${starlark_file}" |
    sort
)
if [[ ${#update_targets[@]} -gt 0 ]]; then
  run_bazel_targets "${update_targets[@]}"
fi

# Run after targets
if [[ ${#targets_to_run_after[0]} -gt 0 ]]; then
  run_bazel_targets "${targets_to_run_after[@]}"
fi
