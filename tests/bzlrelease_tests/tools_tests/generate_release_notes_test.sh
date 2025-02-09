#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Dependencies

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../shlib/lib/env.sh
source "${env_sh}"

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../shlib/lib/assertions.sh
source "${assertions_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" || \
  (echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

generate_release_notes_sh_location=cgrindel_bazel_starlib/bzlrelease/tools/generate_release_notes.sh
generate_release_notes_sh="$(rlocation "${generate_release_notes_sh_location}")" || \
  (echo >&2 "Failed to locate ${generate_release_notes_sh_location}" && exit 1)

# MARK - Setup

generate_module_snippet_sh="${PWD}/generate_module_snippet.sh"
cat >"${generate_module_snippet_sh}" <<-EOF
#!/usr/bin/env bash
while (("\$#")); do
  case "\${1}" in
    "--version")
      version="\${2}"
      shift 2
      ;;
    *)
      echo >&2 "Unexpected arg. \${1}"
      exit 1
      ;;
  esac
done
if [[ -z "\${version:-}" ]]; then
  echo >&2 "Expected a version value."
  exit 1
fi
echo "MODULE SNIPPET CONTENT"
EOF
chmod +x "${generate_module_snippet_sh}"

generate_workspace_snippet_sh="${PWD}/generate_workspace_snippet.sh"
cat >"${generate_workspace_snippet_sh}" <<-EOF
#!/usr/bin/env bash
while (("\$#")); do
  case "\${1}" in
    "--tag")
      tag="\${2}"
      shift 2
      ;;
    *)
      echo >&2 "Unexpected arg. \${1}"
      exit 1
      ;;
  esac
done
if [[ -z "\${tag:-}" ]]; then
  echo >&2 "Expected a tag value."
  exit 1
fi
echo "WORKSPACE SNIPPET CONTENT"
EOF
chmod +x "${generate_workspace_snippet_sh}"


# shellcheck source=SCRIPTDIR/../../setup_git_repo.sh
source "${setup_git_repo_sh}"
cd "${repo_dir}"

# MARK - Test

# These assertions are primarily making sure different sections have been included.

tag="v0.1.1"

actual="$( 
  "${generate_release_notes_sh}" \
    --generate_workspace_snippet "${generate_workspace_snippet_sh}" \
    "${tag}" 
)"
assert_match "## What Has Changed" "${actual}"
assert_match "## Workspace Snippet" "${actual}"
assert_match "WORKSPACE SNIPPET CONTENT" "${actual}"
assert_no_match "## Bazel Module Snippet" "${actual}"

actual="$( 
  "${generate_release_notes_sh}" \
    --generate_module_snippet "${generate_module_snippet_sh}" \
    "${tag}" 
)"
assert_match "## What Has Changed" "${actual}"
assert_match "## Bazel Module Snippet" "${actual}"
assert_match "MODULE SNIPPET CONTENT" "${actual}"
assert_no_match "## Workspace Snippet" "${actual}"
