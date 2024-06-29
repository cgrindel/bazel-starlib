#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail
set +e
f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null \
  || source "$0.runfiles/$f" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null \
  || source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null \
  || {
    echo >&2 "ERROR: ${BASH_SOURCE[0]} cannot find $f"
    exit 1
  }
f=
set -e
# --- end runfiles.bash initialization v3 ---

# return a unix-style path on all platforms
# workaround for https://github.com/bazelbuild/bazel/issues/22803
function rlocation_as_unix() {
  path=$(rlocation ${1})
  case "$(uname -s)" in
    CYGWIN* | MINGW32* | MSYS* | MINGW*)
      path=${path//\\//} # backslashes to forward
      path=/${path//:/}  # d:/ to /d/
      ;;
  esac
  echo $path
}

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation_as_unix "${assertions_sh_location}")" \
  || (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../../../shlib/lib/assertions.sh
source "${assertions_sh}"

archive_tar_gz_location=cgrindel_bazel_starlib/tests/bzlrelease_tests/rules_tests/release_artifact_tests/archive.tar.gz
archive_tar_gz="$(rlocation_as_unix "${archive_tar_gz_location}")" \
  || (echo >&2 "Failed to locate ${archive_tar_gz_location}" && exit 1)

tar_exe_location=cgrindel_bazel_starlib/tools/tar/tar.exe
tar="$(rlocation "${tar_exe_location}")" \
  || (echo >&2 "Failed to locate ${tar_exe_location}" && exit 1)

# MARK - Test

contents="$("${tar}" -tf "${archive_tar_gz}")"
assert_match "bzlrelease/" "${contents}"
assert_match "bzlrelease/private/" "${contents}"
assert_match "bzlrelease/tools/" "${contents}"
