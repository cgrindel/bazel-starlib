#!/usr/bin/env bash

# Generates a Bazel module snippet suitable for inclusion in a MODULE.bazel 
# file.

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

# MARK - Process Args

dev_dependency="false"
args=()
while (("$#")); do
  case "${1}" in
    "--module_name")
      module_name="${2}"
      shift 2
      ;;
    "--version")
      version="${2}"
      shift 2
      ;;
    "--output")
      output_path="${2}"
      shift 2
      ;;
    "--dev_dependency")
      dev_dependency="true"
      shift 1
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done

if [[ -z "${module_name:-}" ]]; then
  fail "A module name must be specified."
fi

if [[ -z "${version:-}" ]]; then
  fail "A version must be specified."
fi
if [[ "${version}" =~ ^v ]]; then
  version="${version:1}"
fi

# MARK - Generate the Snippet

if [[ "${dev_dependency}" == "true" ]]; then
  snippet="$(cat <<-EOF
bazel_dep(
    name = "${module_name}",
    version = "${version}",
    dev_dependency = True,
)
EOF
)"
else
  snippet="$(cat <<-EOF
bazel_dep(name = "${module_name}", version = "${version}")
EOF
)"
fi


snippet="$(cat <<-EOF
\`\`\`python
${snippet}
\`\`\`
EOF
)"

# MARK - Output the Snippet

# Output the snippet
if [[ -z "${output_path:-}" ]]; then
  echo "${snippet}"
else
  echo "${snippet}" > "${output_path}"
fi
