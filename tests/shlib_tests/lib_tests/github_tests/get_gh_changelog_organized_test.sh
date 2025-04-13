#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail
set +e
f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
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

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" ||
	(echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/fail.sh
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" ||
	(echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/env.sh
source "${env_sh}"

github_sh_location=cgrindel_bazel_starlib/shlib/lib/github.sh
github_sh="$(rlocation "${github_sh_location}")" ||
	(echo >&2 "Failed to locate ${github_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/github.sh
source "${github_sh}"

setup_git_repo_sh_location=cgrindel_bazel_starlib/tests/setup_git_repo.sh
setup_git_repo_sh="$(rlocation "${setup_git_repo_sh_location}")" ||
	(echo >&2 "Failed to locate ${setup_git_repo_sh_location}" && exit 1)

# MARK - Setup

# shellcheck source=SCRIPTDIR/../../../setup_git_repo.sh
source "${setup_git_repo_sh}"
cd "${repo_dir}"

# MARK - Test

tag_name="v0.25.1"
prev_tag_name="v0.24.0"
result="$(
	get_gh_changelog_organized \
		--tag_name "${tag_name}" \
		--previous_tag_name "${prev_tag_name}"
)"
[[ "${result}" =~ \*\*Full\ Changelog\*\*:\ https://github\.com/cgrindel/bazel-starlib/compare/v0\.24\.0\.\.\.v0\.25\.1 ]] ||
	fail "Expected to find changelog URL for v0.24.0...v0.25.1. result: ${result}"

[[ "${result}" =~ "## What's Changed" ]] || fail "No What's Changed"

[[ "${result}" =~ "### Highlights" ]] || fail "No Highlights"

[[ "${result}" =~ "### Dependency Updates" ]] || fail "No Dependency Updates"

[[ ! "${result}" =~ "### Other Changes" ]] || fail "Found Other Changes"

[[ "${result}" =~ "### Dependency Updates" ]] || fail "No Dependency Updates"

# The single quotes around the EOF tell bash to not perform any expansion inside
# the string.
expected=$(cat << 'EOF'
## What's Changed

### Highlights

* chore: update README.md for v0.24.0 by @cgrindel-app-token-generator in https://github.com/cgrindel/bazel-starlib/pull/503
* feat: use BSD tar toolchain for release archive functionality by @cgrindel in https://github.com/cgrindel/bazel-starlib/pull/504
* chore: update README.md for v0.25.0 by @cgrindel-app-token-generator in https://github.com/cgrindel/bazel-starlib/pull/505
* fix: include `//tools/tar` in release by @cgrindel in https://github.com/cgrindel/bazel-starlib/pull/509

### Dependency Updates

* chore(deps): update dependency bazel to v8.1.0 by @cgrindel-self-hosted-renovate in https://github.com/cgrindel/bazel-starlib/pull/506
* chore(deps): update dependency bazel to v8.1.1 by @cgrindel-self-hosted-renovate in https://github.com/cgrindel/bazel-starlib/pull/507
* fix(deps): update dependency markdown-link-check to v3.13.7 by @cgrindel-self-hosted-renovate in https://github.com/cgrindel/bazel-starlib/pull/508

**Full Changelog**: https://github.com/cgrindel/bazel-starlib/compare/v0.24.0...v0.25.1
EOF
)

[[ "${result}" == "${expected}" ]] || fail "Does not equal"
