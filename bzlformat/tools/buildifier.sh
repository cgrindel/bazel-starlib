#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail
set +e
f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null ||
  source "$0.runfiles/$f" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  {
    echo >&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"
    exit 1
  }
f=
set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Locate Deps

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" ||
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/fail.sh
source "${fail_sh}"

arrays_sh_location=cgrindel_bazel_starlib/shlib/lib/arrays.sh
arrays_sh="$(rlocation "${arrays_sh_location}")" ||
  (echo >&2 "Failed to locate ${arrays_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/arrays.sh
source "${arrays_sh}"

buildifier_location=buildifier_prebuilt/buildifier/buildifier
buildifier="$(rlocation "${buildifier_location}")" ||
  (echo >&2 "Failed to locate ${buildifier_location}" && exit 1)

# MARK - Process Args

# Lint Mode
# off - Do not lint
# warn - Report lint issues.
# fix = Attempt to fix lint issues.
lint_modes=(off warn fix)
lint_mode="off"

warnings="all"

get_usage() {
  local utility
  utility="$(basename "${BASH_SOURCE[0]}")"
  cat <<-EOF
Executes buildifier for a Starlark file and writes the resulting output to a file.

Usage:
${utility} [OPTION]... <input> <output>

Options:
  --lint_mode <lint_mode>  The buildifier lint mode: $(join_by ", " "${lint_modes[@]}") (default: ${lint_mode})
  --warnings <warnings>    A comma-separated warnings used in the lint mode or "all" (default: ${warnings})
  <input>                  A path to a Starlark file
  <output>                 A path where to write the output from buildifier
EOF
}

args=()
while (("$#")); do
  case "${1}" in
  "--help")
    show_usage
    ;;
  "--lint_mode")
    lint_mode="${2}"
    shift 2
    ;;
  "--warnings")
    warnings="${2}"
    shift 2
    ;;
  --*)
    usage_error "Unexpected option. ${1}"
    ;;
  *)
    args+=("${1}")
    shift 1
    ;;
  esac
done

[[ ${#args[@]} -lt 1 ]] && usage_error "Expected a path to a Starlark file."
bzl_path="${args[0]}"
[[ ${#args[@]} -gt 1 ]] && out_path="${args[1]}"

contains_item "${lint_mode}" "${lint_modes[@]}" ||
  usage_error "Invalid lint_mode (${lint_mode}). Expected to be one of the following: $(join_by ", " "${lint_modes[@]}")."

# MARK - Execute Buildifier

exec_buildifier() {
  local bzl_path="${1}"
  shift 1
  local buildifier_cmd=("${buildifier}" "--path=${bzl_path}")
  [[ ${#} -gt 0 ]] && buildifier_cmd+=("${@}")
  "${buildifier_cmd[@]}"
}

cat_cmd=(cat "${bzl_path}")

buildifier_cmd=(exec_buildifier "${bzl_path}" "--warnings=${warnings}")
case "${lint_mode}" in
"fix")
  buildifier_cmd+=("--lint=fix")
  ;;
"warn")
  buildifier_cmd+=("--lint=warn")
  ;;
"off")
  buildifier_cmd+=("--lint=off")
  ;;
esac

if [[ -n "${out_path:-}" ]]; then
  "${cat_cmd[@]}" | "${buildifier_cmd[@]}" >"${out_path}"
else
  "${cat_cmd[@]}" | "${buildifier_cmd[@]}" >/dev/null
fi
