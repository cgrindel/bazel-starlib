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

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

check_links_sh_location=cgrindel_bazel_starlib/markdown/tools/check_links.sh
check_links_sh="$(rlocation "${check_links_sh_location}")" || \
  (echo >&2 "Failed to locate ${check_links_sh_location}" && exit 1)


# MARK - Test Successful Check

bar_md_path="bar.md"
touch "${bar_md_path}"

foo_md_path="foo.md"
foo_md_content="$(cat <<-'EOF'
This is foo.md.
- [Bar](bar.md)
EOF
)"
echo "${foo_md_content}" > "${foo_md_path}"

"${check_links_sh}" "${bar_md_path}" "${foo_md_path}"

# DEBUG BEGIN
fail "STOP"
# DEBUG END
