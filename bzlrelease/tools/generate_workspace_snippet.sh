#!/usr/bin/env bash

# Generates a workspace snippet suitable for inclusion in a WORKSPACE file.

# The --url flag accepts a string template that will be evaluated with the
# result being added to the list of download URLs. The available parameters
# are:
#   ${owner}: The owner of the current Github hosted repository.
#   ${repo}: The name of the current Github hosted repository.
#   ${tag}: The tag name, if one is provided.
#   ${workspace_name}: The name used in the workspace snippet.

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
# shellcheck source=SCRIPTDIR/../../shlib/lib/fail.sh
source "${fail_sh}"

git_sh_location=cgrindel_bazel_starlib/shlib/lib/git.sh
git_sh="$(rlocation "${git_sh_location}")" || \
  (echo >&2 "Failed to locate ${git_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/git.sh
source "${git_sh}"

github_sh_location=cgrindel_bazel_starlib/shlib/lib/github.sh
github_sh="$(rlocation "${github_sh_location}")" || \
  (echo >&2 "Failed to locate ${github_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/github.sh
source "${github_sh}"

generate_git_archive_sh_location=cgrindel_bazel_starlib/bzlrelease/tools/generate_git_archive.sh
generate_git_archive_sh="$(rlocation "${generate_git_archive_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_git_archive_sh_location}" && exit 1)

generate_sha256_sh_location=cgrindel_bazel_starlib/bzlrelease/tools/generate_sha256.sh
generate_sha256_sh="$(rlocation "${generate_sha256_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_sha256_sh_location}" && exit 1)

# MARK - Keep Track of the starting directory

starting_dir="${PWD}"

# MARK - Process Args

add_strip_prefix=true
add_github_src_archive_url=true
add_github_release_archive_url=false
url_templates=()
args=()
while (("$#")); do
  case "${1}" in
    "--sha256")
      sha256="${2}"
      shift 2
      ;;
    "--sha256_file")
      sha256_file="${2}"
      shift 2
      ;;
    "--tag")
      tag="${2}"
      shift 2
      ;;
    "--url")
      url_templates+=( "${2}" )
      shift 2
      ;;
    "--github_release_archive_url")
      add_github_release_archive_url=true
      add_github_src_archive_url=false
      add_strip_prefix=false
      shift 1
      ;;
    "--no_github_source_archive_url")
      add_github_src_archive_url=false
      shift 1
      ;;
    "--no_strip_prefix")
      add_github_src_archive_url=false
      shift 1
      ;;
    "--owner")
      owner="${2}"
      shift 2
      ;;
    "--repo")
      repo="${2}"
      shift 2
      ;;
    "--workspace_name")
      workspace_name="${2}"
      shift 2
      ;;
    "--output")
      output_path="${2}"
      shift 2
      ;;
    "--template")
      # If the input path is not absolute, then resolve it to be relative to
      # the starting directory. We do this before we starting changing
      # directories.
      template="${2}"
      [[ "${template}" =~ ^/ ]] || template="${starting_dir}/${2}"
      shift 2
      ;;
    *)
      args+=( "${1}" )
      shift 1
      ;;
  esac
done

[[ ${#args[@]} -gt 0 ]] && fail "Received unexpected arguments:" "${args[@]}"

[[ -z "${tag:-}" ]] && fail "Expected a tag value."

# shellcheck disable=SC2016
[[ "${add_github_src_archive_url}" == true ]] && \
  url_templates+=( 'http://github.com/${owner}/${repo}/archive/${tag}.tar.gz' )
# shellcheck disable=SC2016
[[ "${add_github_release_archive_url}" == true ]] && \
  url_templates+=( 'https://github.com/${owner}/${repo}/releases/download/${tag}/${repo}.${tag}.tar.gz' )
[[ ${#url_templates[@]} -gt 0 ]] || fail "Expected one or more url templates."

# MARK - Ensure that we have a SHA256 value

if [[ -n "${sha256_file:-}" ]]; then
  sha256="$(< "${sha256_file}")"
fi
if [[ -z "${sha256:-}" ]]; then
  sha256="$( "${generate_git_archive_sh}" --tag_name "${tag}" | "${generate_sha256_sh}" )"
fi

# MARK - Generate the snippet

cd "${BUILD_WORKSPACE_DIRECTORY}"

if [[ -z "${owner:-}" ]] || [[ -z "${repo:-}" ]]; then
  repo_url="$( get_git_remote_url )"
  is_github_repo_url "${repo_url}" || \
    fail "This git repository's remote does not appear to be hosted by Github. repo_url: ${repo_url}"
  owner="$( get_gh_repo_owner "${repo_url}" )"
  repo="$( get_gh_repo_name "${repo_url}" )"
fi

strip_prefix_suffix="${tag}"
[[ "${strip_prefix_suffix}" =~ ^v ]] && strip_prefix_suffix="${strip_prefix_suffix:1}"
strip_prefix="${repo}-${strip_prefix_suffix}"

if [[ -z "${workspace_name:-}" ]]; then
  workspace_name="${owner}_${repo}"
  # Replace hyphens with underscores
  workspace_name="${workspace_name//-/_}"
fi

# Evaluate the URL template
urls="$(
  for url_template in "${url_templates[@]}" ; do
    url="$(eval echo "${url_template}")"
    echo "        \"${url}\","
  done
)"


if [[ "${add_strip_prefix}" == true ]]; then
  # Generate the workspace snippet
  http_archive_statement="$(cat  <<-EOF
http_archive(
    name = "${workspace_name}",
    sha256 = "${sha256}",
    strip_prefix = "${strip_prefix}",
    urls = [
${urls}
    ],
)
EOF
  )"
else
  http_archive_statement="$(cat  <<-EOF
http_archive(
    name = "${workspace_name}",
    sha256 = "${sha256}",
    urls = [
${urls}
    ],
)
EOF
  )"
fi


if [[ -z "${template:-}" ]]; then
  snippet="${http_archive_statement}"
else
  # Evaluate the template
  snippet="$(
    # Write the multline http_archive statement to a temp file. Be sure to
    # remove the temp file when we are done.
    tmp_snippet_path="$(mktemp)"
    trap 'rm -rf "${tmp_snippet_path}"' EXIT
    echo "${http_archive_statement}" > "${tmp_snippet_path}"

    # Replace the '${http_archive_statement}' with the generated http_archive
    # statement.
    sed -E \
      -e '/\$\{http_archive_statement\}/r '"${tmp_snippet_path}"  \
      -e '/\$\{http_archive_statement\}/d'  \
      "${template}"
  )"
fi

# Wrap the resulting snippet in a markdown codeblock.
snippet="$(cat <<-EOF
\`\`\`python
${snippet}
\`\`\`
EOF
)"

# Output the changelog
if [[ -z "${output_path:-}" ]]; then
  echo "${snippet}"
else
  echo "${snippet}" > "${output_path}"
fi
