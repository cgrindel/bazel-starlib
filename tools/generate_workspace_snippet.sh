#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# MARK - Locate Depedencies

fail_sh_location=cgrindel_bazel_starlib/lib/private/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

source_bazel_status_vars_sh_location=cgrindel_bazel_starlib/lib/private/source_bazel_status_vars.sh
source_bazel_status_vars_sh="$(rlocation "${source_bazel_status_vars_sh_location}")" || \
  (echo >&2 "Failed to locate ${source_bazel_status_vars_sh_location}" && exit 1)
source "${source_bazel_status_vars_sh}"

# MARK - Process Args

status_file_paths=()
while (("$#")); do
  case "${1}" in
    "--status_file")
      status_file_paths+=( "${2}" )
      shift 2
      ;;
    "--output")
      output_path="${2}"
      shift 2
      ;;
    "--workspace_name")
      workspace_name="${2}"
      shift 2
      ;;
    "--url")
      url_template="${2}"
      shift 2
      ;;
    "--sha256")
      sha256="${2}"
      shift 2
      ;;
    *)
      shift 1
      ;;
  esac
done


[[ -z "${output_path:-}" ]] && fail "Expected an output path."
[[ -z "${workspace_name:-}" ]] && fail "Expected workspace name."
[[ -z "${url_template:-}" ]] && fail "Expected a url template."
[[ -z "${sha256:-}" ]] && fail "Expected a SHA256 value."

# # Source the stable-status.txt and volatile-status.txt values as Bash variables
# for status_file_path in "${status_file_paths[@]:-}" ; do
#   eval "$( source_bazel_status_vars "${status_file_path}" )"
# done

# # Create the URL
# url="$(eval echo "${url_template}")"

# Evaluate the URL template
url="$(
  # Source the stable-status.txt and volatile-status.txt values as Bash variables
  for status_file_path in "${status_file_paths[@]:-}" ; do
    eval "$( source_bazel_status_vars "${status_file_path}" )"
  done

  eval echo "${url_template}"
)"

# DEBUG BEGIN
echo >&2 "*** CHUCK  url: ${url}" 
# DEBUG END

# Generate the workspace snippet
cat > "${output_path}" <<-EOF
http_archive(
    name = "${workspace_name}",
    sha256 = "${sha256}",
    url = "${url}",
)
EOF
