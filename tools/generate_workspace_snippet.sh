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

github_sh_location=cgrindel_bazel_starlib/lib/private/github.sh
github_sh="$(rlocation "${github_sh_location}")" || \
  (echo >&2 "Failed to locate ${github_sh_location}" && exit 1)
source "${github_sh}"

# MARK - Process Args

url_templates=()
while (("$#")); do
  case "${1}" in
    "--output")
      output_path="${2}"
      shift 2
      ;;
    "--workspace_name")
      workspace_name="${2}"
      shift 2
      ;;
    "--url")
      url_templates+=( "${2}" )
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

# MARK - Generate the snippet

cd "${BUILD_WORKSPACE_DIRECTORY}"

[[ -z "${output_path:-}" ]] && fail "Expected an output path."
# [[ -z "${workspace_name:-}" ]] && fail "Expected workspace name."
[[ -z "${sha256:-}" ]] && fail "Expected a SHA256 value."
# [[ ${#url_templates[@]} > 0 ]] || fail "Expected one ore more url templates."
# [[ ${#url_templates[@]} > 0 ]] || fail "Expected one ore more url templates."

repo_url="$( get_git_remote_url )"
is_github_repo_url "${repo_url}" || fail "This git repository's remote does not appear to be hosted by Github. repo_url: ${repo_url}"
owner="$( get_gh_repo_owner "${repo_url}" )"
repo="$( get_gh_repo_name "${repo_url}" )"

# Evaluate the URL template
urls="$(
  for url_template in "${url_templates[@]}" ; do
    url="$(eval echo "${url_template}")"
    echo "        \"${url}\","
  done
)"

# Generate the workspace snippet
snippet="$(cat  <<-EOF
http_archive(
    name = "${workspace_name}",
    sha256 = "${sha256}",
    urls = [
${urls}
    ],
)
EOF
)"


# Output the changelog
if [[ -z "${output_path:-}" ]]; then
  echo "${snippet}"
else
  echo "${snippet}" > "${output_path}"
fi
