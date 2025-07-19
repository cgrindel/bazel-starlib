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

# MARK - Locate Dependencies

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" ||
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
# shellcheck source=SCRIPTDIR/../../shlib/lib/fail.sh
source "${fail_sh}"

# MARK - Process Args

args=()
while (("$#")); do
  case "${1}" in
  "--marker_begin")
    marker_begin="${2}"
    shift 2
    ;;
  "--marker_end")
    marker_end="${2}"
    shift 2
    ;;
  "--marker")
    marker="${2}"
    shift 2
    [[ "${marker}" =~ :$ ]] || marker="${marker}:"
    marker_begin="${marker} BEGIN"
    marker_end="${marker} END"
    ;;
  "--update")
    update_path="${2}"
    shift 2
    ;;
  --*)
    fail "Unrecognized flag. ${1}"
    ;;
  *)
    args+=("${1}")
    shift 1
    ;;
  esac
done

[[ -z "${update_path:-}" ]] && fail "No update file was specified."

{ [[ -z "${marker_begin:-}" ]] || [[ -z "${marker_end:-}" ]]; } &&
  fail "No markers were specified."

[[ ${#args[@]} != 2 ]] && fail "Expected exactly two files: input and output."
in_path="${args[0]}"
out_path="${args[1]}"

# MARK - Perform the update

# Create a copy of the input file
cp -f "${in_path}" "${out_path}"

# Update the output file replacing with the contents of update_path.
#
# sed script explanation
#
# /<!-- '"${marker_begin}"' -->/{      # Find the begin marker
#   p                                  # Print the begin marker
#   r '"${update_path}"'               # Read in the snippet
#   :a                                 # Declare label 'a'
#   n                                  # Read the next line
#   /<!-- '"${marker_end}"' -->/!b a   # If not the end marker, loop to 'a'
# }
# /<!-- '"${marker_begin}"' -->/!p     # Print any line that is not begin marker
#
sed -n -i.bak \
  -e '
/<!-- '"${marker_begin}"' -->/{
  p
  r '"${update_path}"'
  :a
  n
  /<!-- '"${marker_end}"' -->/!b a
}
/<!-- '"${marker_begin}"' -->/!p
' \
  "${out_path}"
